import 'dart:ui';
import 'dart:async';
import '/custom_code/actions/index.dart' as actions;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'auth/supabase_auth/supabase_user_provider.dart';
import 'auth/supabase_auth/auth_util.dart';

import '/backend/supabase/supabase.dart';
import 'backend/firebase/firebase_config.dart';
import 'flutter_flow/analytics_service.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
import 'flutter_flow/revenue_cat_util.dart' as revenue_cat;
import 'flutter_flow/notification_service.dart';
import 'backend/remote_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  final environmentValues = FFDevEnvironmentValues();
  await environmentValues.initialize();

  // Ключ живёт в environment.json, поэтому поднимаем Amplitude сразу после
  // него и до createRouter() — роутер забирает навигационный observer.
  await AnalyticsService.instance.init();

  // Start Supabase early — runs in parallel with Firebase init
  final supaFuture = SupaFlow.initialize();

  await initFirebase();

  // Catch all Flutter framework errors.
  // IMPORTANT: We call recordError() directly instead of recordFlutterFatalError()
  // because the latter calls FlutterError.presentError() synchronously, which
  // calls this same handler again → infinite recursion → stack overflow → crash loop.
  FlutterError.onError = (FlutterErrorDetails details) {
    // GoTrue background token refresh network errors are non-fatal —
    // the user doesn't see a crash, the SDK retries automatically.
    final stack = details.stack?.toString() ?? '';
    final exceptionStr = details.exception.toString();
    final isNonFatal = stack.contains('_autoRefreshTokenTick') ||
        stack.contains('GoTrueClient') ||
        stack.contains('google_fonts_base') ||
        stack.contains('_httpFetchFontAndSaveToDevice') ||
        // Network failures surfaced through a FutureBuilder bound to a
        // Supabase/Postgrest query — the UI shows an error state, not a crash.
        stack.contains('postgrest_builder.dart') ||
        exceptionStr.contains('ClientException') ||
        exceptionStr.contains('SocketException') ||
        exceptionStr.contains('TimeoutException');
    FirebaseCrashlytics.instance.recordError(
      details.exception,
      details.stack,
      reason: details.context,
      fatal: !isNonFatal,
    );
  };
  // Catch errors outside Flutter (platform, isolates, async)
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Start initial custom actions code
  await actions.lockOrientation();
  // End initial custom actions code

  await FFLocalizations.initialize();

  final appState = FFAppState(); // Initialize FFAppState
  await appState.initializePersistedState();

  // Wait for Supabase to finish (likely already done by now)
  await supaFuture;

  runApp(ChangeNotifierProvider(
    create: (context) => appState,
    child: MyApp(),
  ));

  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(fetchRemoteConfig());

    unawaited(revenue_cat
        .initialize(
      "appl_nlqWcEvNVGNUCbMcdEcsbKbwNrV",
      "",
      debugLogEnabled: true,
      loadDataAfterLaunch: true,
    )
        .then((_) {
      // configure() lands after the auth stream has already fired, and
      // revenue_cat.login() is a no-op while the SDK is unconfigured — so the
      // listener in _MyAppState alone leaves RevenueCat on its anonymous
      // app_user_id. Re-assert identity once the SDK is up: without it a
      // purchase carries no Supabase UUID and the webhook has no user to
      // resolve, which is how a paid subscription ends up owned by nobody.
      if (currentUserUid.isNotEmpty) {
        unawaited(revenue_cat.login(
          currentUserUid,
          anonymous: currentUser is MiRRADevSupabaseUser &&
              (currentUser as MiRRADevSupabaseUser).isAnonymous,
        ));
      }
    }));
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.entryPage});

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;

  final Widget? entryPage;
}

class MyAppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class _MyAppState extends State<MyApp> {
  Locale? _locale = FFLocalizations.getStoredLocale();

  ThemeMode _themeMode = ThemeMode.system;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  StreamSubscription? _linkSubscription;
  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();
  late Stream<BaseAuthUser> userStream;

  /// Диагностика раскрутки (только non-prod). Снять после отладки.
  int _debugAuthEvents = 0;

  /// When the last guest session was requested — see the debounce below.
  DateTime? _lastAnonMint;

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier, widget.entryPage);
    userStream = miRRADevSupabaseUserStream()
      ..listen((user) {
        if (FFDevEnvironmentValues.isNonProd) {
          debugPrint('[diag] auth event #${++_debugAuthEvents}'
              ' loggedIn=${user.loggedIn} uid=${user.uid}');
        }
        // A logged-out event that arrives while Supabase actually holds a
        // session is stale, and acting on it is destructive: loggedIn flips
        // false, every requireAuth route redirects to '/' (parking the tab the
        // user asked for in _redirectLocation, which later fires and swaps the
        // page out from under them), and '/' renders the guest entry screen.
        // The launch-time anonymous sign-in can outrun the client's own
        // startup event, so this ordering is reachable on a cold start.
        if (!user.loggedIn && SupaFlow.client.auth.currentUser != null) {
          return;
        }
        _appStateNotifier.update(user);
        if (user.loggedIn) {
          // Anonymous sessions count: the whole point of creating one up front
          // is that RevenueCat gets a Supabase UUID before any purchase can
          // happen.
          unawaited(revenue_cat.login(
            user.uid,
            anonymous: user is MiRRADevSupabaseUser && user.isAnonymous,
          ));
          NotificationService.instance.onUserLogin();
          FirebaseCrashlytics.instance.setUserIdentifier(user.uid ?? '');
          // Аккаунт получает user_id, аноним ходит без него: Amplitude склеит
          // анонимную историю устройства в первый user_id, который появится.
          unawaited(AnalyticsService.instance.setSupabaseUid(
            user.uid,
            anonymous: user is MiRRADevSupabaseUser && user.isAnonymous,
          ));
        } else {
          unawaited(revenue_cat.login(null));
          FirebaseCrashlytics.instance.setUserIdentifier('');
          unawaited(AnalyticsService.instance
              .setSupabaseUid(null, anonymous: true));
          // Mint the guest session from here rather than from a launch
          // callback: driven by the auth stream it cannot start before the
          // client has reported that there is no session, which is what made
          // the two race in the first place.
          //
          // Sign-out goes through here too, by design: the app has no
          // session-less state any more. Every screen keys off a uuid, and
          // "signed out" would mean empty-string queries and a paywall with
          // nobody to attach a purchase to. Ending a session returns the user
          // to a fresh guest, which is what a first install looks like.
          //
          // Debounced: a sign-out or an account deletion can emit several
          // logged-out events in a row, and one account per event would both
          // litter the users table and spin the router through a rebuild each
          // time. One guest per five seconds is far more than any real flow
          // needs.
          final now = DateTime.now();
          if (_lastAnonMint == null ||
              now.difference(_lastAnonMint!) > const Duration(seconds: 5)) {
            _lastAnonMint = now;
            unawaited(authManager
                .signInAnonymously(appNavigatorKey.currentContext ?? context));
          }
        }
      });
    jwtTokenStream.listen((_) {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appStateNotifier.stopShowingSplashImage();
    });

    // Handle Universal Links (mirra.up.railway.app/product/{id})
    _initDeepLinks();

    // Push notifications
    NotificationService.instance.init(
      onTap: (data) {
        if (data['route'] == 'routine') {
          _router.go('/routineCalendar');
          return;
        }
        final imageId = data['image_id'];
        if (imageId != null) _router.go('/itemcard2?imageid=$imageId');
      },
    );
  }

  void _initDeepLinks() {
    final appLinks = AppLinks();

    // App opened from a link while terminated
    appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleDeepLink(uri);
    });

    // App opened from a link while running/in background
    _linkSubscription = appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    // Handle mirra.up.railway.app/product/{id}
    final segments = uri.pathSegments;
    if (segments.length == 2 && segments[0] == 'product') {
      final id = int.tryParse(segments[1]);
      if (id != null) {
        _router.go('/itemcard2?imageid=$id');
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void setLocale(String language) {
    safeSetState(() => _locale = createLocale(language));
    FFLocalizations.storeLocale(language);
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MiRRA',
      scrollBehavior: MyAppScrollBehavior(),
      localizationsDelegates: [
        FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackMaterialLocalizationDelegate(),
        FallbackCupertinoLocalizationDelegate(),
      ],
      locale: _locale,
      supportedLocales:
          kSupportedLanguages.map((language) => createLocale(language)).toList(),
      theme: ThemeData(
        brightness: Brightness.light,
        scrollbarTheme: ScrollbarThemeData(
          interactive: false,
          thickness: WidgetStateProperty.all(4.0),
          radius: Radius.circular(8.0),
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.dragged)) {
              return Color(4284253657);
            }
            if (states.contains(WidgetState.hovered)) {
              return Color(4284253657);
            }
            return Color(4284253657);
          }),
        ),
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
      builder: (context, child) {
        if (child == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return child;
      },
    );
  }
}
