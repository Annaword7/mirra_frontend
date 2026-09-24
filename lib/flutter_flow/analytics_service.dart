import 'dart:async';

import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/autocapture/autocapture.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_flutter/constants.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:amplitude_flutter/events/identify.dart';
import 'package:amplitude_flutter/observers/amplitude_navigator_observer.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '/environment_values.dart';
import 'device_identity.dart';

/// Singleton analytics service wrapping Amplitude.
/// Usage: AnalyticsService.instance.trackCardOpened(source: 'home');
///
/// Event names and properties follow the marketing event map maintained by the
/// product team (docs/analytics_events.md). Call sites never spell an event
/// name out — every event is a method here, so the schema lives in one file and
/// a rename is a compile error rather than silent data loss.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  Amplitude? _amplitude;

  /// Keychain-идентичность устройства — `device_id` в Amplitude. Переживает
  /// переустановку, поэтому аноним после неё остаётся тем же пользователем.
  String? _identity;

  /// Та же идентичность для чужих отправителей: RevenueCat шлёт свои события
  /// в Amplitude сам и должен подписывать их тем же `device_id`.
  String? get deviceIdentity => _identity;

  /// Готовность к отправке: SDK поднят и на нём стоит наш `device_id`. Все
  /// отправители ждут именно её, а не `isBuilt`, иначе первые события гонялись
  /// бы с `setDeviceId` и уходили под id от SDK.
  Future<bool> _ready = Future.value(false);

  /// Initialised from `main()` once the environment values are loaded.
  /// Без ключа (local-сборка, забытый ключ в environment.json) сервис остаётся
  /// выключенным и каждый вызов — no-op: приложение работает как обычно.
  Future<void> init() async {
    final apiKey = FFDevEnvironmentValues().amplitudekey;
    if (apiKey.isEmpty) {
      debugPrint('Amplitude: no key for '
          '${FFDevEnvironmentValues.currentEnvironment} — analytics disabled');
      return;
    }
    // Если Keychain недоступен, стартуем без user_id — SDK поработает на
    // своём device_id. Аналитика не должна ронять запуск.
    try {
      _identity = await DeviceIdentity.get();
    } catch (e) {
      debugPrint('Amplitude: device identity unavailable: $e');
    }
    final amplitude = Amplitude(Configuration(
      apiKey: apiKey,
      // Свой device_id вместо сгенерированного SDK: тот живёт в UserDefaults и
      // стирается с приложением, а этот лежит в Keychain. user_id придёт из
      // auth-стрима, когда станет ясно, аккаунт это или аноним.
      // Отсюда его берёт только Android-плагин. iOS-плагин (4.7.1) этот ключ
      // не читает, а у нативного AmplitudeSwift такого поля нет вовсе, так что
      // на iOS id ставится явным setDeviceId в _applyDeviceIdentity.
      deviceId: _identity,
      // Проект живёт в европейском дата-центре. По умолчанию SDK шлёт в США, и
      // события просто не долетают — молча, без ошибки на клиенте.
      serverZone: ServerZone.eu,
      logLevel:
          FFDevEnvironmentValues.isNonProd ? LogLevel.debug : LogLevel.warn,
      // screenViews требует и эту опцию, и observer в navigatorObservers —
      // нативный автокапчур не видит переходов внутри Flutter.
      autocapture: const AutocaptureOptions(
        sessions: true,
        appLifecycles: true,
        deepLinks: true,
        screenViews: true,
      ),
    ));
    _amplitude = amplitude;
    _ready = _applyDeviceIdentity(amplitude);
    // Дожидаемся здесь, а не только в отправителях: наблюдатель экранов из
    // плагина шлёт события в SDK напрямую, и первый экран после runApp иначе
    // ушёл бы с id от SDK. Таймаут только на случай зависшей нативной
    // инициализации: запуск приложения от аналитики зависеть не должен.
    await _ready.timeout(const Duration(seconds: 2), onTimeout: () => false);
    unawaited(_identifyInstall());
  }

  /// Ставит Keychain-идентичность как `device_id`, когда нативная сторона
  /// готова. Возвращает готовность SDK: false — события отправлять некуда.
  ///
  /// Автособытия самого SDK при старте (Application Installed, Start Session,
  /// Application Opened) уходят раньше этого вызова и на первом запуске после
  /// установки несут id от SDK. Дальше SDK хранит наш id сам, и следующие
  /// запуски начинаются уже с него.
  Future<bool> _applyDeviceIdentity(Amplitude amplitude) async {
    try {
      if (!await amplitude.isBuilt) return false;
    } catch (e) {
      debugPrint('Amplitude init failed: $e');
      return false;
    }
    final identity = _identity;
    if (identity == null) return true;
    try {
      await amplitude.setDeviceId(identity);
    } catch (e) {
      // Лучше события с id от SDK, чем никаких.
      debugPrint('Amplitude setDeviceId failed: $e');
    }
    return true;
  }

  /// Откуда приехало приложение и на каком окружении собрано. Именно свойства
  /// пользователя, а не события: они приклеиваются ко всем последующим
  /// событиям, и один сегмент «только App Store» чистит сразу все графики, а
  /// не одно событие.
  ///
  /// `app_env` нужен на случай, который уже случался: дев-дефайн залипает в
  /// `Generated.xcconfig` и уезжает в релиз. Со свойством это видно в первый
  /// же день, а не через месяц по кривым цифрам.
  Future<void> _identifyInstall() async {
    try {
      final info = await PackageInfo.fromPlatform();
      await setUserProperties({
        'install_source': _installSource(info.installerStore),
        'app_env': FFDevEnvironmentValues.currentEnvironment,
      });
    } catch (e) {
      debugPrint('Amplitude: install source unavailable: $e');
    }
  }

  /// `com.apple` в подписи графика не читается — раскладываем в слова.
  ///
  /// Сборка, поставленная из Xcode на устройство, несёт такой же песочный чек,
  /// как и TestFlight, поэтому различить их нельзя и врать об этом не будем.
  /// Граница, которая нужна на практике, проходит между App Store и всем
  /// остальным, и она определяется надёжно.
  static String _installSource(String? store) {
    if (store == null || store.isEmpty) return 'unknown';
    switch (store) {
      case 'com.apple':
        return 'app_store';
      case 'com.apple.testflight':
        return 'testflight_or_xcode';
      case 'com.apple.simulator':
        return 'simulator';
      default:
        return store; // Android: com.android.vending и прочие
    }
  }

  /// Attach to the router's `observers` — this is what emits
  /// `[Amplitude] Screen Viewed` for every named route. Пустой список, пока
  /// сервис выключен.
  List<NavigatorObserver> get navigatorObservers {
    final amplitude = _amplitude;
    return amplitude == null
        ? const []
        : [AmplitudeNavigatorObserver(amplitude)];
  }

  // ── Identity ──────────────────────────────────────────────────────────────

  /// Вызывается из auth-стрима при каждой смене сессии.
  ///
  /// `user_id` получает только аккаунт. Аноним ходит без него, на одном
  /// `device_id`: Amplitude склеивает анонимную историю устройства в первого
  /// `user_id`, который на нём появится, и только в него. Если бы анонимный
  /// uuid уходил как `user_id`, ни регистрация, ни вход уже ничего бы не
  /// склеили — двух разных `user_id` Amplitude не объединяет.
  ///
  /// Свойство `supabase_uid` ставится всем: по нему анонима можно найти в
  /// базе. Пустой uid — окно между выходом и чеканкой нового анонима.
  Future<void> setSupabaseUid(String? uid, {required bool anonymous}) async {
    final amplitude = _amplitude;
    if (amplitude == null) return;
    try {
      if (!await _ready) return;
      final hasUid = uid != null && uid.isNotEmpty;
      await amplitude.setUserId(hasUid && !anonymous ? uid : null);
      final identify = Identify();
      if (hasUid) {
        identify.set('supabase_uid', uid);
      } else {
        identify.unset('supabase_uid');
      }
      await amplitude.identify(identify);
    } catch (e) {
      debugPrint('Amplitude setSupabaseUid failed: $e');
    }
  }

  /// Удаление аккаунта. Сам профиль вычищает бэкенд через Deletion API по
  /// Supabase uuid — SDK с устройства этого сделать не может. Здесь вторая
  /// половина: Amplitude приписывает анонимные события устройства последнему
  /// известному `user_id`, и без нового `device_id` следующий аноним лёг бы
  /// в историю удалённого. Сбрасываем SDK, чеканим новую идентичность и
  /// заново ставим свойства установки.
  Future<void> forgetUser() async {
    final amplitude = _amplitude;
    if (amplitude == null) return;
    try {
      await amplitude.reset();
      _identity = await DeviceIdentity.rotate();
      await amplitude.setDeviceId(_identity);
      await _identifyInstall();
    } catch (e) {
      debugPrint('Amplitude forgetUser failed: $e');
    }
  }

  Future<void> setUserProperties(Map<String, Object?> properties) async {
    final amplitude = _amplitude;
    if (amplitude == null) return;
    try {
      // Как и в _log: до готовности нативной стороны вызов теряется молча.
      if (!await _ready) return;
      final identify = Identify();
      properties.forEach((key, value) {
        if (value != null) identify.set(key, value);
      });
      await amplitude.identify(identify);
    } catch (e) {
      debugPrint('Amplitude identify failed: $e');
    }
  }

  // ── Onboarding ────────────────────────────────────────────────────────────

  Future<void> trackOnboardingGo() => _log('onboarding_go');

  Future<void> trackOnboardingSkip() => _log('onboarding_skip');

  Future<void> trackOnboardingClose() => _log('onboarding_close');

  /// Ушёл из анкеты через «Да, пропустить» — профиль не сохранён.
  Future<void> trackOnboardingSkipAll() => _log('onboarding_skip_all');

  /// [from] — шаг, с которого нажали стрелку назад.
  Future<void> trackTapBack({required String from}) =>
      _log('tap_back', {'from': from});

  /// [via] отличает прямой выбор типа кожи от ветки «Не знаю» → «определим
  /// вместе»: без него пользователи под-квиза не видны в воронке.
  Future<void> trackOnboardingSkin({
    required String typeSkin,
    required String via, // direct | determine
  }) =>
      _log('onboarding_skin', {'type_skin': typeSkin, 'via': via});

  Future<void> trackOnboardingSkinNew({required bool typeNew}) =>
      _log('onboarding_skin_new', {'type_new': typeNew});

  Future<void> trackOnboardingSkinEruption({required bool typeEruption}) =>
      _log('onboarding_skin_eruption', {'type_eruption': typeEruption});

  /// «Далее» на шаге «Как кожа себя ведёт?». Добавлено сверх таблицы
  /// маркетинга: без него завершение второго шага воронки видно только
  /// косвенно, по событиям третьего. Несёт оба ответа шага, как
  /// `onboarding_important_continue` несёт цели.
  Future<void> trackOnboardingSkinContinue({
    required bool typeNew,
    required bool typeEruption,
  }) =>
      _log('onboarding_skin_continue', {
        'type_new': typeNew,
        'type_eruption': typeEruption,
      });

  Future<void> trackOnboardingImportantContinue({
    required List<String> typeImportant,
  }) =>
      _log('onboarding_important_continue', {
        'type_important': typeImportant,
        'goals_count': typeImportant.length,
      });

  Future<void> trackOnboardingNoGoal() => _log('onboarding_no_goal');

  /// Анкета пройдена и профиль сохранён — это та же кнопка «Сохранить и
  /// сканировать», что в таблице значилась как `onbording_scan`; отдельного
  /// экрана «Готово» в приложении нет. Возраст и бюджет мы не спрашиваем, их
  /// место заняли реальные ответы анкеты.
  Future<void> trackOnboardingDone({
    required String? skinType,
    required bool? sensitive,
    required bool? acneProne,
    required int goalsCount,
  }) =>
      _log('onboarding_done', {
        if (skinType != null) 'skin_type': skinType,
        if (sensitive != null) 'sensitive': sensitive,
        if (acneProne != null) 'acne_prone': acneProne,
        'goals_count': goalsCount,
      });

  Future<void> trackOnboardingEdit() => _log('onboarding_edit');

  // ── Рамки рутины (было onbording_pregnancy / onbording_routine_continue) ──
  //
  // Вопросы про беременность и рамки рутины переехали из онбординга в «Разбор
  // косметички», поэтому и события названы по месту, где живут.

  Future<void> trackCareFramesPregnancy({required String typePregnancy}) =>
      _log('care_frames_pregnancy', {'type_pregnancy': typePregnancy});

  Future<void> trackCareFramesContinue({
    required bool fragranceFree,
    required int? maxSteps,
  }) =>
      _log('care_frames_continue', {
        'fragrance_free': fragranceFree,
        'steps_routine': maxSteps ?? 'no_limit',
      });

  // ── Scan screen ───────────────────────────────────────────────────────────

  Future<void> trackScanPhotoTap() => _log('scan_photo_tap');

  Future<void> trackScanPhotoTipsOpen() => _log('scan_photo_tips_open');

  Future<void> trackScanPhotoTipsClose() => _log('scan_photo_tips_close');

  Future<void> trackScanPhotoTake() => _log('scan_photo_take');

  Future<void> trackScanPhotoChooseGallery() =>
      _log('scan_photo_choose_gallery');

  Future<void> trackQuickSetupContinue({
    required String interfaceLanguage,
    required String yourRegion,
  }) =>
      _log('quick_setup_continue', {
        'interface_language': interfaceLanguage,
        'your_region': yourRegion,
      });

  Future<void> trackQuickSetupSwipe() => _log('quick_setup_swipe');

  Future<void> trackScanProductNotRecognizedOk() =>
      _log('scan_product_not_recognized_ok');

  Future<void> trackScanPhotoIngredients() => _log('scan_photo_ingredients');

  /// Только форма ввода, не содержимое: сам состав уже уходит на бэкенд и
  /// лежит против записи скана, а свободный текст из буфера в аналитике — это
  /// и неограниченная кардинальность (по такому свойству не построить ни
  /// сегмент, ни воронку), и чужие данные, которых мы не звали.
  /// [length] и [ingredientsCount] отвечают на реальный вопрос: вставили
  /// полный INCI с этикетки или вбили пару слов руками и сдались.
  Future<void> trackScanIngredientsManually({
    required int length,
    required int ingredientsCount,
  }) =>
      _log('scan_ingredients_manually', {
        'length': length,
        'ingredients_count': ingredientsCount,
      });

  // ── Home ──────────────────────────────────────────────────────────────────

  Future<void> trackHomeTap() => _log('home_tap');

  Future<void> trackAccountTap() => _log('account_tap');

  Future<void> trackAddProduct() => _log('add_product');

  // ── Account settings ──────────────────────────────────────────────────────

  Future<void> trackShareTap() => _log('share_tap');

  Future<void> trackFeedbackTap() => _log('feedback_tap');

  Future<void> trackFeedbackSend() => _log('feedback_send');

  Future<void> trackFeedbackSwipe() => _log('feedback_swipe');

  Future<void> trackSkinProfile() => _log('skin_profile');

  Future<void> trackAppLanguage({required String language}) =>
      _log('app_language', {'language': language});

  Future<void> trackYourRegion({required String region}) =>
      _log('your_region', {'region': region});

  Future<void> trackCreateAccount({required String from}) =>
      _log('create_account', {'from': from});

  Future<void> trackLogIn() => _log('log_in');

  Future<void> trackCreateProfileEmailTap() =>
      _log('create_profile_email_tap');

  Future<void> trackCreateProfilePasswordTap() =>
      _log('create_profile_password_tap');

  Future<void> trackCreateProfileAppleId() => _log('create_profile_apple_id');

  Future<void> trackProfileSettingsPhoto({required String source}) =>
      _log('profile_settings_photo', {'source': source});

  Future<void> trackProfileSettingsContinue({
    required String interfaceLanguage,
  }) =>
      _log('profile_settings_continue', {
        'interface_language': interfaceLanguage,
      });

  Future<void> trackProfileEdit({required String from}) =>
      _log('profile_edit', {'from': from});

  Future<void> trackProfileEditSave() => _log('profile_edit_save');

  Future<void> trackLinkTelegram() => _log('link_telegram');

  Future<void> trackLinkTelegramLink() => _log('link_telegram_link');

  Future<void> trackLinkTelegramSwipe() => _log('link_telegram_swipe');

  Future<void> trackAccountExit() => _log('account_exit');

  Future<void> trackAccountDelete() => _log('account_delete');

  // ── Overview (вкладка Explore) ────────────────────────────────────────────

  Future<void> trackOverviewTap() => _log('overview_tap');

  Future<void> trackOverviewFilter() => _log('overview_filter');

  Future<void> trackOverviewFilterReset() => _log('overview_filter_reset');

  Future<void> trackOverviewFilterSwipe() => _log('overview_filter_swipe');

  /// Каждый фасет — отдельное свойство, как ответы анкеты в
  /// [trackOnboardingDone]: одна колонка со строками `фасет:значение` не даёт
  /// в Amplitude ни разбивки по одному фасету, ни сегмента по нему. Фасеты
  /// без выбора не отправляются.
  Future<void> trackOverviewFilterAdd({
    required Map<String, Set<String>> facets,
    required String sort,
  }) =>
      _log('overview_filter_add', {
        for (final e in facets.entries)
          if (e.value.isNotEmpty) e.key: e.value.toList(),
        'sort': sort,
        'filters_count': facets.values.fold<int>(0, (n, s) => n + s.length),
      });

  Future<void> trackOverviewProductTap() => _log('overview_product_tap');

  // ── Product screen ────────────────────────────────────────────────────────

  Future<void> trackProductSkin({required String skinName}) =>
      _log('product_skin', {'skin_name': skinName});

  Future<void> trackProductSettings() => _log('product_settings');

  Future<void> trackProductSettingsCopy() => _log('product_settings_copy');

  Future<void> trackProductSettingsSpam() => _log('product_settings_spam');

  Future<void> trackProductSettingAddBag() => _log('product_setting_add_bag');

  Future<void> trackProductSettingShare() => _log('product_setting_share');

  Future<void> trackProductSettingPrint() => _log('product_setting_print');

  Future<void> trackProductSettingClose() => _log('product_setting_close');

  // Скрыть / открыть в общем каталоге и удалить. Скрытие и открытие срабатывают
  // сразу по тапу в меню, окно после них — информационное; удаление сначала
  // спрашивает, поэтому product_delete — это намерение, а не факт.

  Future<void> trackProductHidden() => _log('product_hidden');

  Future<void> trackProductHiddenOk() => _log('product_hidden_ok');

  Future<void> trackProductPublicCatalog() => _log('product_public_catalog');

  Future<void> trackProductPublicCatalogOk() =>
      _log('product_public_catalog_ok');

  Future<void> trackProductDelete() => _log('product_delete');

  // ── Cosmetic bag ──────────────────────────────────────────────────────────

  Future<void> trackBeautyBagTap() => _log('beauty_bag_tap');

  Future<void> trackBeautyBagProductAdd() => _log('beauty_bag_product_add');

  Future<void> trackBeautyBagProductDelete() =>
      _log('beauty_bag_product_delete');

  Future<void> trackBeautyBagCheckFit() => _log('beauty_bag_check_fit');

  /// «Открыть разбор» из косметички. Вход из рутины — отдельное событие
  /// [trackRoutineViewAnalysis]: префикс события называет экран, с которого
  /// нажали, поэтому свойство `from` тут не нужно.
  Future<void> trackBeautyBagViewAnalysis() =>
      _log('beauty_bag_view_analysis');

  Future<void> trackBeautyBagNotes() => _log('beauty_bag_notes');

  Future<void> trackBeautyBagAddCalendar() => _log('beauty_bag_add_calendar');

  // ── Routine ───────────────────────────────────────────────────────────────

  Future<void> trackRoutineTap() => _log('routine_tap');

  Future<void> trackRoutineDay({required String day}) =>
      _log('routine_day', {'day': day});

  Future<void> trackRoutinePush({required bool enabled, String? time}) =>
      _log('routine_push', {
        'state': enabled ? 'on' : 'off',
        if (time != null) 'time': time,
      });

  Future<void> trackRoutineProduct({required String time}) =>
      _log('routine_product', {'time': time});

  Future<void> trackRoutineProductSave({required String day}) =>
      _log('routine_product_save', {'day': day});

  Future<void> trackRoutineProductPause() => _log('routine_product_pause');

  /// «Открыть разбор» из рутины — пара к [trackBeautyBagViewAnalysis].
  Future<void> trackRoutineViewAnalysis() => _log('routine_view_analysis');

  // ── Review prompt ─────────────────────────────────────────────────────────

  Future<void> trackPopupReviewsShow() => _log('popup_reviews_show');

  Future<void> trackPopupReviewsYes() => _log('popup_reviews_yes');

  Future<void> trackPopupReviewsNo() => _log('popup_reviews_no');

  Future<void> trackPopupReviewsTapComment() =>
      _log('popup_reviews_tap_comment');

  Future<void> trackPopupReviewsTapEmail() => _log('popup_reviews_tap_email');

  Future<void> trackPopupReviewsTapSend() => _log('popup_reviews_tap_send');

  // ── Session ───────────────────────────────────────────────────────────────

  /// Создана гостевая сессия: первый запуск, после выхода, после удаления
  /// аккаунта. Шлётся из auth-менеджера при чеканке анонима, без `user_id`.
  Future<void> trackAnonSessionStarted() => _log('anon_session_started');

  /// Гость стал новым аккаунтом. [method] — `email` или `apple`. Вход гостя в
  /// существующий аккаунт не считается: это возвращение, а не конверсия.
  Future<void> trackAnonConverted({required String method}) =>
      _log('anon_converted', {'method': method});

  // ── Analysis ──────────────────────────────────────────────────────────────

  Future<void> trackAnalysisStarted({required String source}) =>
      _log('analysis_started', {'source': source}); // source: camera | gallery

  /// [score] is null when the card is not scored yet — the 202 "research
  /// pending" path still completes the scan from the user's point of view.
  Future<void> trackAnalysisCompleted({
    required int imageId,
    double? score,
    String? productType,
  }) =>
      _log('analysis_completed', {
        'image_id': imageId,
        if (score != null) 'score': score.round(),
        if (productType != null) 'product_type': productType,
      });

  Future<void> trackAnalysisFailed({String? reason}) =>
      _log('analysis_failed', {if (reason != null) 'reason': reason});

  // ── Product card ──────────────────────────────────────────────────────────

  Future<void> trackCardOpened({
    required int imageId,
    required String source, // home | toprated | favorites | board | search
  }) =>
      _log('card_opened', {'image_id': imageId, 'source': source});

  Future<void> trackIngredientsTabOpened({required int imageId}) =>
      _log('ingredients_tab_opened', {'image_id': imageId});

  // ── Share ─────────────────────────────────────────────────────────────────

  Future<void> trackShareLinkTapped({required int imageId}) =>
      _log('share_link_tapped', {'image_id': imageId});

  Future<void> trackShareCardCreated({
    required int imageId,
    required String format, // story | square
  }) =>
      _log('share_card_created', {'image_id': imageId, 'format': format});

  // ── Boards ────────────────────────────────────────────────────────────────

  Future<void> trackBoardCreated() => _log('board_created');

  Future<void> trackProductAddedToBoard({required int imageId}) =>
      _log('product_added_to_board', {'image_id': imageId});

  // ── Favourites ────────────────────────────────────────────────────────────

  Future<void> trackFavouriteAdded({required int imageId}) =>
      _log('favourite_added', {'image_id': imageId});

  Future<void> trackFavouriteRemoved({required int imageId}) =>
      _log('favourite_removed', {'image_id': imageId});

  // ── Upgrade ───────────────────────────────────────────────────────────────

  /// Показ любого промо подписки. Отдельного события в таблице маркетинга нет —
  /// это впечатление, а не тап, и без него у `premium_tap` нет знаменателя.
  Future<void> trackUpgradePromptShown({required String trigger}) =>
      _log('upgrade_prompt_shown', {'trigger': trigger});

  /// Тап по любому входу в подписку. Значения [from] точнее, чем
  /// `home/account` из таблицы: у экрана продукта, косметички и упёршихся в
  /// лимит — свои входы, и различать их дороже, чем схлопывать.
  Future<void> trackPremiumTap({required String from}) =>
      _log('premium_tap', {'from': from});

  // ── Paywall & purchase ────────────────────────────────────────────────────

  /// Logged every time the paywall finishes resolving RevenueCat offerings.
  /// [ready] is false when the plan cards cannot be rendered — the paywall is
  /// then a dead end, which is otherwise invisible in analytics.
  Future<void> trackPaywallOfferingsLoaded({
    required bool ready,
    required bool configured,
  }) =>
      _log('paywall_offerings_loaded', {
        'ready': ready,
        'configured': configured,
      });

  /// «Восстановить покупки». Событие одно, но с исходом: голый тап не отличает
  /// «человеку нечего восстанавливать» от «заплатил, а доступ не вернулся» —
  /// а это разные вещи, и вторая генерирует тикеты в поддержку и единицы в
  /// App Store.
  /// [result]: `restored` — доступ вернулся и записан в нашу базу;
  /// `nothing_to_restore` — RevenueCat не нашёл активной подписки;
  /// `error` — цепочка оборвалась, до восстановления не дошло.
  Future<void> trackPurchaseRestore({required String result}) =>
      _log('purchase_restore', {'result': result});

  Future<void> trackPurchaseStarted({required String package}) =>
      _log('purchase_started', {'package': package});

  Future<void> trackPurchaseCompleted({required String package}) =>
      _log('purchase_completed', {'package': package});

  /// [code] is the RevenueCat `PurchasesErrorCode` string, or
  /// `entitlement_not_active` when the store charged but the entitlement did
  /// not turn on.
  Future<void> trackPurchaseFailed({
    required String package,
    required String code,
    required bool cancelled,
  }) =>
      _log('purchase_failed', {
        'package': package,
        'code': code,
        'cancelled': cancelled,
      });

  // ── Internal ──────────────────────────────────────────────────────────────

  /// Аналитика не должна ронять экран: нативный канал может ответить ошибкой
  /// (нет сети, SDK ещё не поднялся), и это не повод показывать пользователю
  /// сбой. Ждём `_ready` — до инициализации нативная сторона события теряет.
  Future<void> _log(String name, [Map<String, Object?>? parameters]) async {
    final amplitude = _amplitude;
    if (amplitude == null) return;
    try {
      if (!await _ready) return;
      await amplitude.track(BaseEvent(
        name,
        eventProperties: parameters == null
            ? null
            : {
                for (final entry in parameters.entries)
                  if (entry.value != null) entry.key: entry.value,
              },
      ));
    } catch (e) {
      debugPrint('Amplitude track "$name" failed: $e');
    }
  }
}
