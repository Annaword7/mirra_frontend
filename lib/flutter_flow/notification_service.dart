import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    // Foreground: show as local notification
    FirebaseMessaging.onMessage.listen((message) {
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
        payload: message.data['image_id'],
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
    } catch (e) {
      debugPrint('[Push] Failed to deactivate token: $e');
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
    } catch (e) {
      debugPrint('[Push] Failed to save token: $e');
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
      onDidReceiveNotificationResponse: (response) {
        final imageId = response.payload;
        if (imageId != null) _onTap?.call({'image_id': imageId});
      },
    );
  }
}
