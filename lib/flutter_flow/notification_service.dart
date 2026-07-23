import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

// Top-level handler for background messages (required by firebase_messaging)
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  debugPrint('[Push] Background message: ${message.messageId}');
}

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _fcm = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  void Function(Map<String, dynamic>)? _onTap;
  String? _cachedToken;

  static const _androidChannel = AndroidNotificationChannel(
    'mirra_default',
    'MiRRA Notifications',
    description: 'Product analysis results and updates',
    importance: Importance.high,
  );

  // Waits up to 5s for the APNs token iOS must register before FCM getToken() works.
  Future<bool> _waitForApnsToken() async {
    if (!Platform.isIOS) return true;
    for (int i = 0; i < 10; i++) {
      final t = await _fcm.getAPNSToken();
      if (t != null) {
        debugPrint('[Push] APNs token ready');
        return true;
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
    debugPrint('[Push] WARNING: APNs token not available after 5s');
    return false;
  }

  /// Call once from _MyAppState.initState() after the router is ready.
  Future<void> init({required void Function(Map<String, dynamic>) onTap}) async {
    _onTap = onTap;

    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    await _setupLocalNotifications();

    // Local scheduling for routine reminders (isolated from the FCM path;
    // failures here must never break push delivery).
    await _initScheduling();

    if (!await _waitForApnsToken()) return;

    final token = await _fcm.getToken();
    if (token != null) {
      _cachedToken = token;
      debugPrint('[Push] FCM token obtained: ${token.substring(0, 20)}...');
      _saveToken(token);
    } else {
      debugPrint('[Push] WARNING: getToken() returned null');
    }

    // Save token whenever auth state changes (login, anonymous sign-in, etc.)
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final userId = data.session?.user.id;
      if (userId != null && _cachedToken != null) {
        debugPrint('[Push] Auth state changed, saving token for $userId');
        _saveToken(_cachedToken!);
      }
    });

    _fcm.onTokenRefresh.listen((newToken) {
      _cachedToken = newToken;
      _saveToken(newToken);
    });

    // Foreground: if message carries image_id (analysis complete), navigate immediately.
    // Otherwise show as local notification so user can tap at their convenience.
    FirebaseMessaging.onMessage.listen((message) {
      final imageId = message.data['image_id'];
      if (imageId != null) {
        _onTap?.call(message.data);
        return;
      }
      final n = message.notification;
      if (n == null) return;
      _localNotifications.show(
        n.hashCode,
        n.title,
        n.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: imageId,
      );
    });

    // Background → foreground tap
    FirebaseMessaging.onMessageOpenedApp.listen((m) => _onTap?.call(m.data));

    // Terminated state tap
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      await Future.delayed(const Duration(milliseconds: 1200));
      _onTap?.call(initial.data);
    }
  }

  /// Call on any auth state change (anonymous → authenticated, or fresh login).
  Future<void> onUserLogin() async {
    if (!await _waitForApnsToken()) return;
    final token = await _fcm.getToken() ?? _cachedToken;
    if (token != null) {
      _cachedToken = token;
      debugPrint('[Push] onUserLogin: saving token');
      await _saveToken(token);
    } else {
      debugPrint('[Push] WARNING: no FCM token on login');
    }
  }

  /// Call on logout to deactivate token.
  Future<void> onUserLogout() async {
    final token = _cachedToken ?? await _fcm.getToken();
    if (token == null) return;
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await Supabase.instance.client
          .from('device_tokens')
          .update({'is_active': false})
          .eq('user_id', userId)
          .eq('token', token);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, fatal: false, reason: 'deactivate push token failed');
    }
  }

  Future<void> _saveToken(String token) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      debugPrint('[Push] _saveToken: userId is null, skipping');
      return;
    }
    try {
      await Supabase.instance.client.from('device_tokens').upsert(
        {
          'user_id': userId,
          'token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
          'is_active': true,
        },
        onConflict: 'user_id,token',
      );
      debugPrint('[Push] Token saved for user $userId');
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, fatal: false, reason: 'save push token failed');
    }
  }

  Future<void> _setupLocalNotifications() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) =>
          _routeLocalPayload(response.payload),
    );

    // App launched from a terminated state by tapping a local notification.
    final launch =
        await _localNotifications.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      final payload = launch!.notificationResponse?.payload;
      if (payload != null) {
        await Future.delayed(const Duration(milliseconds: 1200));
        _routeLocalPayload(payload);
      }
    }
  }

  // Local-notification payloads carry an image id. Stale 'routine' payloads
  // from the removed experiment are ignored (non-numeric id → no navigation).
  void _routeLocalPayload(String? payload) {
    if (payload == null || payload == 'routine' || payload == 'care') return;
    _onTap?.call({'image_id': payload});
  }

  // ── Scheduled local reminders (generic weekly mechanism) ────────────────────

  bool _schedulingReady = false;

  Future<void> _initScheduling() async {
    try {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(_resolveLocalLocation());
      if (Platform.isIOS) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      }
      _schedulingReady = true;
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, fatal: false, reason: 'init scheduling failed');
    }
  }

  /// Best-effort local timezone. Uses the current UTC offset mapped to an
  /// Etc/GMT zone. Caveat: whole-hour offsets only; DST shifts are not tracked
  /// (a fixed-offset zone). Half-hour zones fall back to UTC.
  tz.Location _resolveLocalLocation() {
    try {
      final offset = DateTime.now().timeZoneOffset;
      if (offset.inMinutes % 60 == 0) {
        final h = offset.inHours;
        // Etc/GMT signs are inverted relative to the UTC offset.
        final name = h == 0 ? 'UTC' : 'Etc/GMT${h > 0 ? '-' : '+'}${h.abs()}';
        return tz.getLocation(name);
      }
    } catch (_) {}
    return tz.getLocation('UTC');
  }

  tz.TZDateTime _nextInstanceOf(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (scheduled.weekday != weekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Schedule a weekly-repeating reminder for each weekday (1=Mon..7=Sun).
  /// Per-weekday notification ids derive from [baseId] so they can be cancelled.
  Future<void> scheduleWeeklyReminders({
    required int baseId,
    required List<int> weekdays,
    required int hour,
    required int minute,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_schedulingReady) return;
    for (final wd in weekdays) {
      await _localNotifications.zonedSchedule(
        baseId * 10 + wd,
        title,
        body,
        _nextInstanceOf(wd, hour, minute),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: payload,
      );
    }
  }

  Future<void> cancelReminders(int baseId) async {
    for (var wd = 1; wd <= 7; wd++) {
      await _localNotifications.cancel(baseId * 10 + wd);
    }
  }
}
