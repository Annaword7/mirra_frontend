import 'dart:ui';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import '/custom_code/actions/index.dart' as actions;
import 'shared_image_state.dart';
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
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
import 'flutter_flow/revenue_cat_util.dart' as revenue_cat;
import 'flutter_flow/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  final environmentValues = FFDevEnvironmentValues();
  await environmentValues.initialize();

  await initFirebase();

  // Catch all Flutter framework errors
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // Catch errors outside Flutter (platform, isolates, async)
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Start initial custom actions code
  await actions.lockOrientation();
  // End initial custom actions code

  await SupaFlow.initialize();

  await FFLocalizations.initialize();

  final appState = FFAppState(); // Initialize FFAppState
  await appState.initializePersistedState();

  await revenue_cat.initialize(
    "appl_nlqWcEvNVGNUCbMcdEcsbKbwNrV",
    "",
    debugLogEnabled: true,
    loadDataAfterLaunch: true,
  );

  runApp(ChangeNotifierProvider(
    create: (context) => appState,
    child: MyApp(),
  ));
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

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier, widget.entryPage);
    userStream = miRRADevSupabaseUserStream()
      ..listen((user) {
        _appStateNotifier.update(user);
      });
    jwtTokenStream.listen((_) {});
    Future.delayed(
      Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );

    // Handle Universal Links (mirra.up.railway.app/product/{id})
    _initDeepLinks();

    // Handle images shared from external apps ("Open in MiRRA")
    _initShareChannel();

    // Push notifications
    NotificationService.instance.init(
      onTap: (data) {
        final imageId = data['image_id'];
        if (imageId != null) _router.go('/itemcard2?imageid=$imageId');
      },
    );
  }

  static const _shareChannel = MethodChannel('mirra/share');

  void _initShareChannel() {
    _shareChannel.setMethodCallHandler((call) async {
      if (call.method == 'sharedImage') {
        await _loadAndRoutePendingSharedImage();
      }
    });
    // Check for an image that arrived before Flutter was ready
    // (e.g. cold launch via "Open In")
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAndRoutePendingSharedImage();
    });
  }

  Future<void> _loadAndRoutePendingSharedImage() async {
    try {
      final result =
          await _shareChannel.invokeMethod<Uint8List>('getPendingSharedImage');
      if (result != null && result.isNotEmpty) {
        SharedImageState.instance.pendingImage = result;
        _router.go('/takeorUploadPage');
      }
    } catch (_) {
      // Channel not available (Android / web) — ignore silently
    }
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
      title: 'MiRRA dev',
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
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
        Locale('es'),
      ],
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
        if (FFDevEnvironmentValues.currentEnvironment != 'Development') {
          return child!;
        }
        // Dev-only banner: shows which backend is active
        return Stack(
          children: [
            child!,
            Positioned(
              top: MediaQuery.of(context).padding.top + 4,
              right: 8,
              child: IgnorePointer(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xCCFF6B00),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'DEV',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
