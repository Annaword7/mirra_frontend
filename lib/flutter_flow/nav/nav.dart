import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';


import '/auth/base_auth_user_provider.dart';
import '/auth/supabase_auth/auth_util.dart';

import '/design_system/components/screen_loader.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/analytics_service.dart';

import '/index.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

/// Диагностика раскрутки перестроений (только non-prod). Снять после отладки.
int _debugInitializeBuilds = 0;

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Заглушка между экранами, пока поднимается сессия. Белое полотно и спиннер
/// приложения: дефолтный Scaffold красился в grey50 и мигал серым на каждом
/// холодном старте.
class _RouteLoader extends StatelessWidget {
  const _RouteLoader();

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).alternate,
        body: const ScreenLoader(),
      );
}

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(BaseAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier, [Widget? entryPage]) =>
    GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      // Пусто, когда ключа Amplitude нет: сервис выключен, наблюдать нечем.
      observers: AnalyticsService.instance.navigatorObservers,
      errorBuilder: (context, state) {
        if (appStateNotifier.loading) {
          return const _RouteLoader();
        }

        // A real account goes to Home. Everyone else — including the anonymous
        // session minted at launch — starts on the scan page: it is the whole
        // product, and Home has nothing on it until something is scanned.
        if (appStateNotifier.loggedIn && !currentUserIsAnonymous) {
          return entryPage ?? HomeWidget();
        }

        return TakeorUploadPageWidget();
      },
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) {
            if (FFDevEnvironmentValues.isNonProd) {
              debugPrint('[diag] / build #${++_debugInitializeBuilds}'
                  ' loading=${appStateNotifier.loading}'
                  ' loggedIn=${appStateNotifier.loggedIn}'
                  ' anon=$currentUserIsAnonymous');
            }
            if (appStateNotifier.loading) {
              return const _RouteLoader();
            }

            // See errorBuilder above: real account → Home, guest → scan page.
            if (appStateNotifier.loggedIn && !currentUserIsAnonymous) {
              return entryPage ?? HomeWidget();
            }

            // Новый гость — сначала онбординг (экран 0 по docs/onboarding_spec):
            // профиль появляется до первого скана, поэтому и первый разбор уже
            // персональный. И «Пройти настройку», и «Пропустить» выводят на
            // сканер, флаг ставит сама анкета — второй раз она не покажется.
            if (!FFAppState().onboardingDone) {
              return OnboardingQuizWidget();
            }

            return TakeorUploadPageWidget();
          },
        ),
        FFRoute(
          name: CreateAccountPageWidget.routeName,
          path: CreateAccountPageWidget.routePath,
          builder: (context, params) => CreateAccountPageWidget(),
        ),
        FFRoute(
          name: LogInPageWidget.routeName,
          path: LogInPageWidget.routePath,
          builder: (context, params) => LogInPageWidget(),
        ),
        FFRoute(
          name: OnboardingProfileWidget.routeName,
          path: OnboardingProfileWidget.routePath,
          builder: (context, params) => OnboardingProfileWidget(),
        ),
        FFRoute(
          name: OnboardingQuizWidget.routeName,
          path: OnboardingQuizWidget.routePath,
          builder: (context, params) => OnboardingQuizWidget(
            returnTo: params.getParam('returnTo', ParamType.String),
          ),
        ),
        // Boards и ImagesbyAlbum выведены из обращения: переходов из
        // интерфейса на них нет, маршруты сняты, чтобы экраны нельзя было
        // открыть и по прямой ссылке. Код остаётся в lib/boards/.
        FFRoute(
          name: HomeWidget.routeName,
          path: HomeWidget.routePath,
          requireAuth: true,
          builder: (context, params) => HomeWidget(),
        ),
        FFRoute(
          name: SearchWidget.routeName,
          path: SearchWidget.routePath,
          requireAuth: true,
          builder: (context, params) => const SearchWidget(),
        ),
        FFRoute(
          name: ProfileWidget.routeName,
          path: ProfileWidget.routePath,
          requireAuth: true,
          builder: (context, params) => ProfileWidget(),
        ),
        FFRoute(
          name: ForgotPasswordWidget.routeName,
          path: ForgotPasswordWidget.routePath,
          builder: (context, params) => ForgotPasswordWidget(),
        ),
        FFRoute(
          name: EditProfileWidget.routeName,
          path: EditProfileWidget.routePath,
          builder: (context, params) => EditProfileWidget(),
        ),
        FFRoute(
          name: TopratedWidget.routeName,
          path: TopratedWidget.routePath,
          requireAuth: true,
          builder: (context, params) => TopratedWidget(),
        ),
        FFRoute(
          name: PaywallpageWidget.routeName,
          path: PaywallpageWidget.routePath,
          builder: (context, params) => PaywallpageWidget(),
        ),
        FFRoute(
          name: LangsWidget.routeName,
          path: LangsWidget.routePath,
          builder: (context, params) => LangsWidget(),
        ),
        FFRoute(
          name: TakeorUploadPageWidget.routeName,
          path: TakeorUploadPageWidget.routePath,
          builder: (context, params) => TakeorUploadPageWidget(),
        ),
        FFRoute(
          name: CountriesWidget.routeName,
          path: CountriesWidget.routePath,
          builder: (context, params) => CountriesWidget(),
        ),
        FFRoute(
          name: NewblankWidget.routeName,
          path: NewblankWidget.routePath,
          builder: (context, params) => NewblankWidget(),
        ),
        FFRoute(
          name: BagWidget.routeName,
          path: BagWidget.routePath,
          requireAuth: true,
          builder: (context, params) => BagWidget(),
        ),
        FFRoute(
          name: RoutineWidget.routeName,
          path: RoutineWidget.routePath,
          requireAuth: true,
          builder: (context, params) => RoutineWidget(),
        ),
        FFRoute(
          name: CareReviewWidget.routeName,
          path: CareReviewWidget.routePath,
          requireAuth: true,
          builder: (context, params) => CareReviewWidget(),
        ),
        FFRoute(
          name: Itemcard2Widget.routeName,
          path: Itemcard2Widget.routePath,
          builder: (context, params) => Itemcard2Widget(
            imageid: params.getParam(
              'imageid',
              ParamType.int,
            ),
          ),
        ),
        FFRoute(
          name: 'productDeepLink',
          path: '/product/:id',
          builder: (context, params) => Itemcard2Widget(
            imageid: int.tryParse(params.getParam('id', ParamType.String) ?? ''),
          ),
        ),
        FFRoute(
          name: ShareproductWidget.routeName,
          path: ShareproductWidget.routePath,
          builder: (context, params) => ShareproductWidget(
            imageid: params.getParam(
              'imageid',
              ParamType.int,
            ),
          ),
        )
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    List<String>? collectionNamePath,
    StructBuilder<T>? structBuilder,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
      collectionNamePath: collectionNamePath,
      structBuilder: structBuilder,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) {
          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }

          if (requireAuth && !appStateNotifier.loggedIn) {
            appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
            // '/' is the real splash/initialize route. Once auth restores,
            // the saved redirectLocation forwards to the requested screen
            // (e.g. a routine-reminder deep link). '/Splash' isn't a route —
            // returning it rendered a blank/grey screen.
            return '/';
          }
          return null;
        },
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = appStateNotifier.loading
              ? ColoredBox(
                  color: Colors.white,
                  child: Center(
                    child: Image.asset(
                      'assets/images/splash.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  name: state.name,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey, name: state.name, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
