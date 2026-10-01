import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/confetti_overlay.dart';
import '/components/save_subscription_sheet.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/analytics_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/revenue_cat_util.dart' as revenue_cat;
import '/index.dart';

const _entitlementId = 'EntitlementMirra';

/// Единственная точка входа в подписку. Какой пейвол увидит человек — собранный
/// в дашборде RevenueCat или наш собственный экран — решает флаг
/// `rc_paywall_enabled` в app_config: эксперимент включается и выключается
/// строкой в базе, не дожидаясь ревью App Store.
///
/// [from] — тот же вход, что у `premium_tap`. [asSheet] просит мягкую подачу
/// листом; пейвол RevenueCat на iOS и так показывается листом.
Future<void> showPaywall(
  BuildContext context, {
  required String from,
  bool asSheet = false,
}) {
  if (FFAppState().rcPaywallEnabled) {
    return _showRevenueCatPaywall(context, from: from, asSheet: asSheet);
  }
  return _showOwnPaywall(context, from: from, asSheet: asSheet);
}

Future<void> _showOwnPaywall(
  BuildContext context, {
  required String from,
  required bool asSheet,
}) {
  if (!asSheet) {
    return context.pushNamed(
      PaywallpageWidget.routeName,
      queryParameters: {'from': from},
    );
  }
  // Лист, а не полный экран: карточка остаётся видна за ним, и свайп вниз
  // закрывает. Виджет пейвола тот же, поэтому покупка и её аналитика живут в
  // одном месте, а не переписываются под лист.
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.92,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: PaywallpageWidget(from: from, asSheet: true),
      ),
    ),
  );
}

Future<void> _showRevenueCatPaywall(
  BuildContext context, {
  required String from,
  required bool asSheet,
}) async {
  final shownAt = DateTime.now();
  // Покупка внутри пейвола уйдёт на того, под кем SDK залогинен в этот момент.
  // Без этого подписка анонима не привязывается к аккаунту, и вебхуку некого
  // разрешить по supabase_uid.
  await actions.rcEnsureLogin(context, currentUserUid);

  // Без параметра offering: вариант эксперимента RevenueCat раздаёт через
  // current offering, и жёстко заданный оффер обошёл бы сплит.
  final result = await RevenueCatUI.presentPaywall();

  switch (result) {
    case PaywallResult.purchased:
    case PaywallResult.restored:
      await _deliverPro(result);
    case PaywallResult.cancelled:
      // Крестик, свайп и «назад» внутри нативного пейвола неразличимы — у RC
      // один исход на всех. Вход и время на экране остаются нашими.
      unawaited(AnalyticsService.instance.trackPaywallDismissed(
        method: 'rc_cancelled',
        from: from,
        secondsOnScreen: DateTime.now().difference(shownAt).inSeconds,
      ));
    case PaywallResult.error:
    case PaywallResult.notPresented:
      // Пейвол не показался — сбой презентации или в оффере его нет. Человек
      // остался бы без способа заплатить, поэтому открываем свой экран в той же
      // подаче, о которой просили.
      final ctx = appNavigatorKey.currentContext;
      if (ctx != null) {
        await _showOwnPaywall(ctx, from: from, asSheet: asSheet);
      }
  }
}

/// Хвост покупки, который RevenueCat за нас не делает: entitlement в их базе —
/// ещё не доступ в нашей. Пока /subscription/sync не записал премиум, сервер
/// считает человека бесплатным и отказывает в скане, за который тот только что
/// заплатил.
Future<void> _deliverPro(PaywallResult result) async {
  final info = await _refreshedCustomerInfo();
  final entitlement = info?.entitlements.active[_entitlementId];
  final package = _packageIdFor(entitlement?.productIdentifier);

  if (entitlement == null) {
    // Магазин списал деньги, а entitlement не включился: человек заплатил и
    // остался на бесплатном тарифе.
    if (result == PaywallResult.purchased) {
      unawaited(AnalyticsService.instance.trackPurchaseFailed(
        package: package,
        code: 'entitlement_not_active',
        cancelled: false,
      ));
    } else {
      unawaited(AnalyticsService.instance.trackPurchaseRestore(result: 'error'));
    }
    return;
  }

  // Пейвол RevenueCat — нативный экран поверх Flutter, маршрут под ним не
  // меняется. Слушатели маршрута, которые обновляют Главную после покупки, не
  // сработают, поэтому статус разносится уведомлением: иначе человек заплатил,
  // а экран под пейволом всё ещё предлагает купить.
  FFAppState().update(() => FFAppState().isprouser = true);
  await SubscriptionSyncCall.call(token: currentJwtToken);

  if (result == PaywallResult.restored) {
    unawaited(AnalyticsService.instance.trackPurchaseRestore(result: 'restored'));
    return;
  }

  unawaited(AnalyticsService.instance.trackPurchaseCompleted(package: package));

  final (form, message) = switch (package) {
    r'$rc_weekly' => ('Monthpayment', 'Wow! You have a new month subscription!'),
    r'$rc_annual' => (
        'subscription year',
        'Wow! You have a new YEAR subscription!'
      ),
    _ => ('subscription', 'Wow! You have a new subscription: $package!'),
  };
  // Уведомление разработчику. Ждать его незачем.
  unawaited(SendAppMessageCall.call(
    token: currentJwtToken,
    email: currentUserEmail,
    form: form,
    message: message,
  ));

  await offerToSaveSubscription();
}

/// Свежий CustomerInfo, а не rcRefreshEntitlement: нужен не только факт
/// подписки, но и купленный продукт — по нему определяется пакет для аналитики
/// и уведомления.
Future<CustomerInfo?> _refreshedCustomerInfo() async {
  try {
    await Purchases.invalidateCustomerInfoCache();
    final info = await Purchases.getCustomerInfo();
    revenue_cat.customerInfo = info;
    return info;
  } catch (e, s) {
    FirebaseCrashlytics.instance.recordError(e, s,
        fatal: false, reason: 'customerInfo refresh after paywall failed');
    return null;
  }
}

/// Пакет, за который заплатили: в PaywallResult его нет, а событиям Amplitude
/// нужен тот же словарь (`$rc_weekly`, `$rc_annual`), что и у своего пейвола.
/// Когда пакет не опознан, идентификатор продукта информативнее пустоты.
String _packageIdFor(String? productIdentifier) {
  if (productIdentifier == null) {
    return 'unknown';
  }
  final packages = revenue_cat.offerings?.current?.availablePackages ?? const [];
  for (final package in packages) {
    if (package.storeProduct.identifier == productIdentifier) {
      return package.identifier;
    }
  }
  return productIdentifier;
}

/// A guest who has just paid holds the subscription through an anonymous
/// session that exists only on this device — losing it means losing access,
/// recoverable in practice only by a "restore purchases" tap nobody thinks to
/// make. Offer an account once, after the charge, never as a condition of it.
///
/// Runs off any widget's own context: the paywall that called it is being torn
/// down, and the two sheets would otherwise stack.
Future<void> offerToSaveSubscription() async {
  if (!currentUserIsAnonymous) return;
  final app = FFAppState();
  if (app.saveProPromptShown) return;
  app.saveProPromptShown = true;

  // Let the paywall finish leaving before the next sheet arrives.
  await Future.delayed(const Duration(milliseconds: 350));
  var ctx = appNavigatorKey.currentContext;
  if (ctx == null) return;

  final theme = FlutterFlowTheme.of(ctx);
  unawaited(HapticFeedback.heavyImpact());

  final wantsAccount = await showModalBottomSheet<bool>(
    context: ctx,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    // Full-height stack so the confetti falls across the screen behind the
    // sheet. Nothing here absorbs touches outside the sheet itself, so a tap
    // above it still reaches the barrier and dismisses.
    builder: (_) => Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: ConfettiOverlay(
              colors: [
                theme.primary,
                theme.secondary,
                theme.tertiary,
                const Color(0xFFFFC93C),
                const Color(0xFFFF7BA9),
              ],
            ),
          ),
        ),
        const Align(
          alignment: Alignment.bottomCenter,
          child: SaveSubscriptionSheet(),
        ),
      ],
    ),
  );
  if (wantsAccount != true) return;

  ctx = appNavigatorKey.currentContext;
  // createAccountWithEmail links the address to this anonymous account and
  // keeps the uuid; the Apple path mints a new one, and the sync call in
  // _claimAnonScans is what carries the subscription across.
  ctx?.pushNamed(
    LogInPageWidget.routeName,
    queryParameters: {
      'tab': serializeParam('register', ParamType.String),
    }.withoutNulls,
  );
}
