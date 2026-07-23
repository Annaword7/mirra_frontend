# M!RRA — полное описание функционала приложения

> Технический справочник по всей кодовой базе Flutter-приложения Mirra (анализ состава косметики, скинкер-профиль, косметичка, рутина).
> Составлен пофайлово и пометодно, чтобы можно было формулировать гипотезы с учётом мельчайших деталей поведения.
>
> **Охват:** 264 `.dart`-файла, ~61 000 строк в `lib/`. Идентификаторы кода — на английском, пояснения — на русском.
> **Версия на момент составления:** 2.4.0 (build 100), окружение по умолчанию — `prod` (`web-production-47a2d.up.railway.app`).

---

## 0. Как устроено приложение (обзор архитектуры)

**Стек:**
- **Клиент:** Flutter, сгенерирован через FlutterFlow (отсюда стиль: `xxx_widget.dart` + `xxx_model.dart`, тема `FlutterFlowTheme`, локализация `FFLocalizations`, глобальный стейт `FFAppState`).
- **Данные:** Supabase (Postgres + Auth + Storage + Edge Functions на Deno). Таблицы обёрнуты сгенерированными Dart-классами (`Row` + `Table`).
- **Основной бэкенд анализа:** отдельный Python/gunicorn-сервис на Railway (эндпоинты `/api/mirra/*`), вызывается из `lib/backend/api_requests/api_calls.dart`. Живёт в отдельном репозитории `mirra_backend-main`.
- **Подписки:** RevenueCat (offering `defaultmirra`, entitlement `EntitlementMirra`, пакеты `$rc_weekly`/`$rc_annual`).
- **Инфраструктура:** Firebase (Crashlytics, push через FCM), deep links `/product/:id`, локальные уведомления (`flutter_local_notifications` + `timezone`).

**Выбор окружения:** `String.fromEnvironment('APP_ENV', defaultValue: 'prod')` → выбирает `assets/environment_values/environment.json` (prod) либо `environment.dev.json` / `environment.local.json`.

**Три ключевые пользовательские петли:**
1. **Скан → анализ состава.** FAB в навбаре → `TakeorUploadPageWidget` (камера/галерея → загрузка в Supabase → 3 стадии бэкенда: extract-product-info → search/set-ingredients → scientific-analysis) → карточка результата `Itemcard2Widget`. Лимит бесплатных сканов — из `/api/mirra/quota`.
2. **Онбординг(и).** Два независимых: (а) профиль кожи — `OnboardingQuizWidget`, буфер `FFAppState.ob*`, флаг `onboardingDone`; (б) имя/аватар/язык — `Onboarding_ProfileWidget` после регистрации. Плюс домашний чек-лист «Попробуй все возможности» (`HomePipelineWidget`).
3. **Косметичка → совместимость → рутина.** `CosmeticBagWidget` (слоты продуктов) → `CompatibilityResultWidget` (AI-разбор AM/PM через edge-функцию `analyze-compatibility`) → `RoutineCalendarWidget` (расписание + локальные напоминания-дайджесты AM/PM).

**Модель монетизации (актуальная):** free/аноним — до 3 продуктов в косметичке, замена/удаление бесплатно, совместимость для 3 продуктов бесплатна; Pro — >3 продуктов и совместимость для любого числа. Единственный клиентский гейт — булев `FFAppState().isprouser`.

---

## 1. Сквозные концепции (must-know перед чтением деталей)

### 1.1. `FFAppState` — глобальные флаги
Персистятся в `SharedPreferences` с префиксом `ff_`. Самые важные для гипотез:
- **PRO:** `isprouser` — сессионный, **не** персистится; источник правды — `users.subscription_plan == 'premium'` (бэкенд), клиент поднимает его после покупки по entitlement.
- **Онбординг кожи:** `onboardingDone`, буфер ответов `ob*` (обнуляемый), счётчик `obStep`.
- **Онбординг косметички:** `bagOnboardingDone`, `bagOnboardingActive`, `bagScanCount`, `pendingBagSlot` (+ сентинел `kNewBagSlotPending`).
- **Домашний пайплайн:** `homePipelineDoneUsers` — список user-id, для кого чек-лист уже скрыт навсегда (per-user, чтобы не течь между аккаунтами при логауте).
- **Лимиты:** `freeScanLimit`, `analysesused`, `weekResetDate` (окно 7 дней).
- Прочее: `feedback*` (App Store rating), `showLinkTelegram`.

> Полная таблица всех полей — в разделе «Ядро FlutterFlow → app_state.dart».

### 1.2. Навигация и доступ
Развилка новичка — в корневом роуте `/` и `errorBuilder`: `loading→Splash`, `loggedIn→Home`, иначе `onboardingDone ? Newblank : OnboardingQuiz`. `requireAuth` защищает Home/Search/Profile/Boards/Toprated/CosmeticBag/RoutineCalendar. **Важно:** анонимная сессия Supabase считается «залогиненной», поэтому защищённые экраны доступны гостю.

### 1.3. Гейтинг Pro
Только `isprouser`. Ставится в `paywallpage_widget` после `rcPurchasePackage` → проверки entitlement `EntitlementMirra` → бэкенд `SubscriptionupgradeNEWBCNDCall`. Фичи за Pro: >3 продукта в косметичке, полный разбор совместимости для >3, объяснения предупреждений в карточке, часть действий (hide/скрытие).

---

## 2. Расхождения и зацепки для гипотез
Ниже — замеченные при обходе несоответствия и «подозрительные» места. Это **кандидаты на проверку**, а не подтверждённые баги. Каждое отражает состояние кода на момент составления — проверяйте перед использованием.

**Pro / подписки:**
- В обработчике **Restore Purchases** `isprouser`, судя по коду, явно не выставляется, хотя entitlement проверяется → восстановившие покупку могут не получить Pro в UI.
- Расхождение по сбросу Pro при logout: один путь (`signOut` в auth) чистит только сессию Supabase и **не** сбрасывает `isprouser`; другой путь («End session» / логаут в настройках) сбрасывает `isprouser/onboardingDone/analysesused`. Стоит свести к одному.
- `ProductCardV2Widget` местами вызывается с хардкодом `isPro: true` — проверить, не открывает ли это Pro-контент бесплатным.

**Скан / лимиты:**
- Часть Mirra-эндпоинтов ходит **без токена** (только `user_id` в теле) — поверхность для подделки user_id.
- Два вызова оборачивают серверный gunicorn-timeout 120с в `statusCode == -1` — обработка этого кода на клиенте требует проверки.
- Легаси-инверсия суффиксов полей модели Camera/Gallary в `takeor_upload` (не баг, но путает при чтении).

**Бэкенд-слой:**
- `remote_config.dart` читает колонку `app_config.value`, которой нет в сгенерированной обёртке (там `int_value`) — потенциально битое чтение конфига.
- Захардкоженные секреты в клиенте (OpenAI key, Telegram bot token, Supabase anon key, статичный Bearer) — риск безопасности.

**Локализация / UI-консистентность:**
- Хардкод-строки вне i18n: статусы `ingredient_bubbles` (русский), `error_popup` («Анализировать»), `delete_confirmation`, весь `guest_prefs_sheet`.
- Несогласованный цвет статуса «working»: амбер в bubbles vs зелёный в radar/card.
- `light_dark_toggle` не переключает тему; тёмная тема на уровне палитры не реализована (`FlutterFlowTheme.of()` всегда отдаёт `LightModeTheme`).

**Мёртвый/дублирующий код:** заглушки `startanalys` (кнопка с `print` без навигации), `ScoreCard`, пустые `actions.dart` (`se`, `accountSetup`), дубли `makepublic`/`makepubluc`.

---

## Оглавление
1. [Backend (lib/backend/)](#backend-libbackend) — таблицы, api_calls, RoutineService, CosmeticBagService, edge-функции, квоты.
2. [Ядро FlutterFlow (lib/flutter_flow/)](#ядро-flutterflow-libflutter_flow) — app_state (все флаги), навигация, уведомления, тема, i18n.
3. [Компоненты (lib/components/)](#компоненты-libcomponents) — навбар, home_pipeline, product_card_v2, sheets, guest_prefs.
4. [Экраны (lib/pages/)](#экраны-libpages) — онбординги, косметичка, совместимость, рутина, auth, paywall.
5. [Главный экран и флоу сканирования (lib/home, lib/itemcard2, lib/item_card)](#главный-экран-и-флоу-сканирования-libhome-libitemcard2-libitem_card)
6. [Прочие модули (paywall, topratings, boards, search, settings, limits, auth, custom_code, main)](#прочие-модули-paywall-topratings-boards-search-settings-limits-auth-custom_code-main)

---


---

# Backend (lib/backend/)

Техническая документация backend-слоя Flutter-приложения **Mirra** (сканер/анализ косметики). Директория `lib/backend/` содержит 80 `.dart`-файлов (~10857 строк). Слой смешанный: часть кода сгенерирована FlutterFlow (обёртки Supabase-таблиц, data-структуры, HTTP-инфраструктура, Firestore-обвязка), часть — написанная вручную бизнес-логика (кастомные сервисы, определения API-вызовов к собственному бэкенду и внешним LLM).

Ключевые бэкенды, с которыми работает приложение:
- **Supabase** (`https://pjapsfbztorijypnldam.supabase.co`) — основная БД (Postgres через PostgREST), Storage, Auth, а также Edge Functions (`/functions/v1/...`).
- **Собственный бэкенд Mirra** (host из `FFDevEnvironmentValues().backendhost`) — эндпоинты `/api/mirra/...` (анализ, поиск состава, квоты, подписки, поиск продуктов).
- **Внешние LLM/сервисы**: OpenAI (chat/completions, dall-e, responses, fine-tuned модель), Google Gemini, `api.localizecamp.com`, Telegram Bot API.
- **Firebase** (Firestore для коллекции `errors`, Crashlytics для логирования ошибок).
- **Algolia** — присутствует инфраструктура, но ключи пустые (фактически не используется).

> ВАЖНО для гипотез (общая картина гейтинга): в самом `lib/backend/` **нет** явных проверок `isProUser`/Pro. Гейтинг реализован снаружи (виджеты, `FFAppState`), а backend отражает его через:
> - таблицы/поля подписки: `users.subscription_plan`, `user_subscription_info`, `cosmetic_bag.*`;
> - лимиты сканов: RemoteConfig-ключ `free_scan_limit` (пишется в `FFAppState().freeScanLimit`), эндпоинт `GET /api/mirra/quota` (`GetScanQuotaCall`, поля `plan`, `is_unlimited`, `quota_used`, `quota_limit`, `remaining`, `reset_at`), 429-ответы `SCAN_QUOTA_EXCEEDED`;
> - фичефлаги через таблицу `app_config` (`feedbackCollectorEnabled`).
> - Косметичка (`CosmeticBagService`) содержит комментарии про "Pro swap UI", но сам сервис Pro не проверяет — фильтрует только по `user_id`.

---

## 1. Ядро и точки входа

### `lib/backend/backend.dart` (188 строк)
Назначение: агрегирующий барель + Firestore-хелперы для единственной коллекции Firestore `errors`.

Реэкспортирует: `dart:async` (StreamSubscription), `cloud_firestore`, `firebase_core`, `schema/index.dart`, схемные утилиты, `errors_record.dart`.

Функции запросов к Firestore-коллекции `errors` (документируется таблица переводов ошибок — `code`, `lang_code`, `text`):
- `queryErrorsRecordCount({queryBuilder, limit=-1}) → Future<int>` — счётчик документов.
- `queryErrorsRecord({queryBuilder, limit=-1, singleRecord=false}) → Stream<List<ErrorsRecord>>` — стрим.
- `queryErrorsRecordOnce({...}) → Future<List<ErrorsRecord>>` — единичное чтение.

Обобщённые хелперы (используются всеми Firestore-запросами приложения):
- `queryCollectionCount(collection, {queryBuilder, limit})` — `.count().get()`; при ошибке пишет в **Crashlytics** (`recordError(..., fatal:false, reason:'queryCollectionCount failed')`) и пробрасывает исключение.
- `queryCollection<T>(...)` — стрим; ошибки стрима логируются в Crashlytics (не фатально), десериализация каждого документа через `safeGet` (битые документы отбрасываются, печатается ошибка).
- `queryCollectionOnce<T>(...)` — то же, но `.get()` один раз.
- `queryCollectionPage<T>(...)` — пагинация (startAfterDocument, pageSize), возвращает `FFFirestorePage` (data + optional stream + маркер следующей страницы).

Побочные эффекты: сеть (Firestore), логирование в Crashlytics. `singleRecord=true` форсит `limit(1)`. Edge-case: пустой результат → `nextPageMarker == null`.

Фильтр-хелперы: `filterIn`, `filterArrayContainsAny`, extension `QueryExtension` (`whereIn/whereNotIn/whereArrayContainsAny`) — при пустом/`null` списке передают `null` (Firestore тогда не фильтрует).

### `lib/backend/supabase/supabase.dart` (29 строк)
Назначение: инициализация Supabase-клиента (синглтон `SupaFlow`).

- Хардкод: `_kSupabaseUrl` и `_kSupabaseAnonKey` (anon JWT, `exp` 2035 год) — вшиты в исходник.
- `SupaFlow.client` (статический геттер) → `Supabase.instance.client`. Это основная точка доступа к Postgres/Storage/Auth во всём backend.
- `SupaFlow.initialize()` → `Supabase.initialize(...)`: заголовок `X-Client-Info: flutterflow`, `authFlowType: AuthFlowType.implicit`, `debug:false`.
- Реэкспортирует `database/database.dart` и `storage/storage.dart`.

### `lib/backend/supabase/database/database.dart` (52 строки)
Барель: реэкспорт `lat_lng`, `supabase_flutter`, `row.dart`, `table.dart` и **всех 45 файлов таблиц** из `tables/`. Единая точка импорта для доступа к любой таблице.

### `lib/backend/supabase/database/row.dart` (102 строки)
Назначение: базовый класс строки Supabase + (де)сериализация значений.

- `abstract class SupabaseDataRow` — держит `Map<String,dynamic> data`, абстрактный `table`.
  - `getField<T>(name, [default])` — десериализует значение поля; `setField`, `getListField<T>`, `setListField`.
  - `==`/`hashCode` — по содержимому `data`.
- `supaSerialize<T>` — DateTime/PostgresTime → ISO8601; LatLng → `{lat,lng}`.
- `_supaDeserialize<T>` — **важные edge-cases**:
  - `int`: `num` → `round()`; **строка** ("75.00" от DECIMAL/NUMERIC PostgREST) → `int.tryParse`, иначе `double.tryParse()?.round()`. То есть числовые колонки Postgres, приходящие строками, корректно кастятся.
  - `double`: `num`→`toDouble`, строка→`double.tryParse`.
  - `DateTime`: `DateTime.tryParse(...).toLocal()` (значения приводятся к локальному времени!).
  - `LatLng`: понимает и `lat/lng`, и `latitude/longitude`.

### `lib/backend/supabase/database/table.dart` (157 строк)
Назначение: базовый класс таблицы + null-safe фильтры.

- `abstract class SupabaseTable<T>`:
  - `queryRows({queryFn, limit?, columns='*'})` — `SELECT columns`, применяет `queryFn`, опциональный `limit`, маппит в Row.
  - `querySingleRow({queryFn})` — `.limit(1).maybeSingle()`; **при ошибке логирует в Crashlytics** (`querySingleRow failed: <table>`) и возвращает пустой список (не бросает).
  - `insert(data)` — вставка одной строки, возвращает Row (`.select().single()`).
  - `update({data, matchingRows, returnRows=false})` — UPDATE; при `returnRows=false` строки не возвращаются.
  - `delete({matchingRows, returnRows=false})` — DELETE.
- Extension `NullSafePostgrestFilters` — `eqOrNull/neqOrNull/lt/lte/gt/gte/contains/overlaps/inFilterOrNull`: если значение `null`, фильтр **не применяется** (пропуск). Активно используется в сервисах (`eqOrNull('user_id', userId)`).
- Аналогичный extension для стримов.
- `class PostgresTime` — парсинг `TIME`-колонок (подставляет сегодняшнюю дату, `toLocal()`).

### `lib/backend/supabase/storage/storage.dart` (56 строк)
Назначение: работа с Supabase Storage.
- `uploadSupabaseStorageFiles({bucketName, selectedFiles})` — параллельная загрузка (`Future.wait`).
- `uploadSupabaseStorageFile({bucketName, selectedFile})` — `uploadBinary(storagePath, bytes, contentType:null)`, возвращает публичный URL.
- `deleteSupabaseFileFromPublicUrl(publicUrl)` — вычленяет bucket+path из публичного URL и удаляет; если путь не распарсился — тихий no-op.
- private extension `pathFromPublicUrl` — парсит URL вида `$url/object/public/...`.

---

## 2. Кастомные сервисы (написаны вручную — документируется детально)

### `lib/backend/backend/routine_service.dart` → `lib/backend/routine_service.dart` (195 строк)
Назначение: напоминания о рутине ухода. Источник истины — таблица `routine_events`. Вместо пуша на каждый продукт планируются **ДВА дневных дайджест-напоминания** (утро/вечер), диплинк ведёт на календарь рутины.

Синглтон `RoutineService.instance`. `_userId` = `Supabase.instance.client.auth.currentUser?.id`.
Константы: `_amBase=990001`, `_pmBase=990002` (фиксированные id локальных уведомлений для AM/PM дайджестов).

Методы:
- `getEvents() → Future<List<RoutineEventsRow>>` — читает `routine_events` where `user_id = текущий`, order by `created_at`. Если не авторизован → `[]`.
- `addEvent({imageId, title, weekdays, hour, minute})` — **INSERT в `routine_events`**. No-op если `userId==null` или `weekdays` пуст. `part_of_day` вычисляется: `hour<12 ? 'am' : 'pm'`. `time_of_day` форматируется `HH:MM:00`. `enabled:true`.
- `generateFromRoutine({am, pm, amHour=8, amMinute=0, pmHour=21, pmMinute=0}) → Future<int>` — превращает LLM-рутину (списки шагов am/pm) в события для продуктов косметички. Логика:
  1. Берёт слоты из `CosmeticBagService.getSlots()`, собирает `imageId` (не-null).
  2. Читает `images` по этим id (`inFilterOrNull('id', ids)`), строит мапу `productName(lowercase.trim) → id`.
  3. Матчит `step['product']` к сканированному продукту по имени; **пропускает** дженерик-шаги (пустое имя) и продукты без совпадения.
  4. Дедупликация: если для пары `imageId_partOfDay` событие уже есть — пропуск.
  5. Все дни недели `[1..7]`. Возвращает число созданных событий. No-op (0) если не авторизован или косметичка пуста.
  Побочные эффекты: чтение `bag_slots`, `images`, `routine_events`; множественные INSERT.
- `deleteEvent(row)` — DELETE `routine_events` by `id` (если `row.id != null`).
- `setPartTime(part, hour, minute)` — UPDATE `time_of_day` для **всех** событий пользователя данного `part_of_day` (одно время на всю секцию am/pm).
- `syncDigests({amTitle, amBody, pmTitle, pmBody, defaultAmHour=8, defaultPmHour=21})` — пересобирает два дайджеста:
  1. Отменяет прежние уведомления `_amBase`, `_pmBase` (`NotificationService.cancelReminders`).
  2. Берёт события где `enabled==true` И `weekdays` непусты.
  3. Раздельно планирует AM/PM (`partOfDay ?? 'am'`).
  Вызывать после любого изменения и при открытии календаря.
- `_scheduleDigest(events, baseId, defaultHour, title, body)` — планирует **одно недельное напоминание на каждый покрытый день недели**, в **самое раннее** время продукта этой части дня (чтобы напоминание пришло до начала рутины). Дефолт времени = `defaultHour:00`, если ни у одного события нет валидного времени. Payload `'routine'`. No-op если событий/дней нет.

Гипотезы: напоминания не зависят от Pro; полностью на локальных уведомлениях; время «дайджеста» = минимум по всем продуктам части дня (не среднее).

### `lib/backend/cosmetic_bag_service.dart` (128 строк)
Назначение: управление слотами «Косметички». 3 онбординговых плейсхолдера + произвольные доп-слоты.

Синглтон `CosmeticBagService.instance`. Константы:
- `kBagOnboardingSlots = 3` — число плейсхолдеров онбординг-геймфлоу.
- `kNewBagSlotPending = -2` — sentinel для `pendingBagSlot` («создать новый слот под следующий скан», для тайла «+»).

`_userId` из Supabase Auth. Все методы фильтруют по `user_id` и делают no-op/`[]` если не авторизован.

Методы (все работают с таблицей `bag_slots`):
- `ensureSlots() → Future<List<BagSlotsRow>>` — гарантирует существование строк slot_index 0..2; недостающие **INSERT** батчем; возвращает все слоты по `slot_index`.
- `getSlots()` — SELECT `bag_slots` where user, order by `slot_index`.
- `filledOnboardingCount() → Future<int>` — сколько из первых 3 плейсхолдеров заполнены (`slot_index<3 && imageId!=null`).
- `addEmptySlot() → Future<int?>` — добавляет пустой слот с `slot_index = max+1`; возвращает его индекс. INSERT.
- `assignSlot(slotIndex, imageId?)` — UPDATE `image_id` для слота (used by "Pro swap UI" — но проверки Pro тут нет).
- `removeFromSlot(slotIndex)` — если `slotIndex >= 3` → **DELETE** слота целиком; иначе (плейсхолдер) → просто очищает (`assignSlot(...,null)`).
- `onScanCompleted(imageId) → Future<int>` — при успешном скане в онбординге:
  - Если `FFAppState().bagOnboardingDone` → сразу возвращает 3 (no-op).
  - Идемпотентно: если `imageId` уже в каком-то слоте — не добавляет повторно.
  - Иначе кладёт в первый пустой плейсхолдер (`slot_index<3 && imageId==null`).
  - Синхронизирует `FFAppState().bagScanCount = filledOnboardingCount()`. Возвращает 0..3.

Гипотезы: онбординг косметички завязан на `FFAppState().bagOnboardingDone` и `bagScanCount`; доп-слоты (индекс ≥3) удаляются полностью, плейсхолдеры (0..2) только очищаются.

### `lib/backend/remote_config.dart` (32 строки)
Назначение: чтение фичефлагов из Supabase-таблицы `app_config` (anon-доступно, можно звать до авторизации).

`fetchRemoteConfig()`:
- `SELECT key, value FROM app_config`, строит `Map<key,value>`.
- `feedbackCollectorEnabled` (строка `'true'`, case-insensitive) → `FFAppState().feedbackCollectorEnabled` (bool). Логирует debugPrint.
- `free_scan_limit` → `int.tryParse`; если валидно и `>0` → `FFAppState().freeScanLimit`.
- Всё в try/catch: при ошибке только debugPrint (тихо, дефолты `FFAppState` сохраняются).

> ВНИМАНИЕ (несоответствие): `remote_config.dart` читает колонку **`value`** (`SELECT key, value`), а сгенерированная обёртка `app_config` (см. таблицы) знает колонки `key`, `int_value`, `updated_at` — колонки `value` в обёртке нет. То есть RemoteConfig использует колонку, которой нет в Row-обёртке (обёртка тут не задействована, запрос сырой). Ключи `feedbackCollectorEnabled` и `free_scan_limit` хранятся строками в `value`.

---

## 3. API-вызовы к бэкендам (написаны вручную/сгенерированы FF — документируется детально)

### `lib/backend/api_requests/api_manager.dart` (613 строк)
Назначение: универсальный HTTP-движок FlutterFlow. Через него проходят **все** вызовы из `api_calls.dart`.

Классы:
- `enum ApiCallType { GET, POST, DELETE, PUT, PATCH }`, `enum BodyType { NONE, JSON, TEXT, X_WWW_FORM_URL_ENCODED, MULTIPART }`.
- `ApiCallOptions` (Equatable) — иммутабельный конфиг вызова (callName, callType, apiUrl, headers, params, body/bodyType, флаги returnBody/encodeBodyUtf8/decodeUtf8/alwaysAllowBody/cache/isStreamingApi). `copyWith`, `clone` (глубокое клонирование map через json round-trip). `props` → используется как **ключ кэша** (два одинаковых вызова == равны).
- `ApiCallResponse(jsonBody, headers, statusCode, {response, streamedResponse, exception, requestOptions})`:
  - `succeeded` = `statusCode >= 200 && < 300`. **Важно**: при сетевой ошибке `makeApiCall` возвращает `statusCode = -1` → `succeeded == false` (этот контракт используется таймаут-обёртками в `api_calls.dart`).
  - `bodyText`, `getHeader`, `exceptionMessage`.
  - `fromHttpResponse(response, returnBody, decodeUtf8)` — парсит JSON (опц. utf8-декод), ошибки парсинга глотаются (`catch {}`), `jsonBody=null`.
  - `fromCloudCallResponse(map)` — для cloud-функций, дефолтный statusCode `400`.
- `class ApiManager` (синглтон):
  - `static _apiCache` — кэш `ApiCallOptions → ApiCallResponse`; `clearCache(callName)` чистит по имени.
  - `getClient({withCredentials})` — web → `BrowserClient`, иначе `http.Client`.
  - `_accessToken` (static) — если задан, добавляет `Authorization: Bearer` во **все** вызовы (в текущем коде не устанавливается — токены передаются явно в headers каждого call).
  - `urlRequest(...)` — GET/DELETE без тела; поддержка streaming.
  - `requestWithBody(...)` — POST/PUT/PATCH (+ DELETE при `alwaysAllowBody`); assert на тип; MULTIPART → `multipartRequest`.
  - `multipartRequest(...)` — сборка `FFUploadedFile` в MultipartFile.
  - `createBody(...)` — выставляет Content-Type по BodyType (JSON→application/json и т.д.), опц. utf8-encode.
  - `makeApiCall({...})` — центральный метод:
    - Если `_accessToken != null` → добавляет Bearer.
    - Если URL не начинается с `http` → префикс `https://`.
    - Если `cache && закэшировано` → возврат из кэша.
    - **try/catch: любое исключение → `ApiCallResponse(null,{},-1, exception:e)`** (не бросает наружу). Это ключевой фолбэк для всех вызовов.

### `lib/backend/api_requests/api_calls.dart` (1556 строк)
Назначение: определения всех внешних/бэкенд вызовов. Каждый класс = один эндпоинт с `call(...)` и статическими парсерами полей ответа (JSONPath через `getJsonField`). Host по умолчанию для собственного бэкенда: `FFDevEnvironmentValues().backendhost`.

> ВАЖНО (безопасность/гипотезы): в исходнике **захардкожены секреты** — OpenAI API key (`sk-proj-...`), Telegram bot token, Supabase anon key, статичный Bearer `dGVzdHVzZXI6...` (base64 `testuser:hashd$123456`) для `localizecamp`/`Analyzeingredients`. Часть эндпоинтов OpenAI имеет плейсхолдер `Bearer OPENAI_API_KEY` (нерабочий).

Хелперы в конце файла: `escapeStringForJson` (экранирует `\ " \n \t` — используется при ручной сборке JSON-строк; **не экранирует прочие control-символы**), `_serializeList`, `_serializeJson`, `_toEncodable`, `class ApiPagingParams`.

Внешние LLM/сервисные вызовы:
- **`OpenAIImageGenerationAPICall`** — DALL-E 3 генерация изображения. Bearer — плейсхолдер `OPENAI_API_KEY` (не настоящий). Парсеры `revisedPrompt`, `tempURL`.
- **`TelegrammessegeCall`** — отправка сообщения в Telegram (`chat_id: 170963862`, вшитый bot token). Текст: «У нас новое сообщение из приложения beaty box! Пользователь с почтой… Форма… Сообщение…». Используется как канал фидбэка/форм.
- **`OpenAIFineTunedModelCall`** — fine-tuned `ft:gpt-4.1-...:BPsYjUR8`, temperature 0. Возвращает одно значение свойства продукта по label+parametr. Парсер `content`.
- **`OpenAIComponenAnalysCall`** — `gpt-4o`, temp 0.2. Огромный system-prompt: строгая оценка INCI-состава (категоризация ингредиентов, позиционно-чувствительная оценка top5/6-10/после10, штрафы за Cyclohexasiloxane −3.0, синергии/конфликты, формула скоринга Base 5.0 ±…, вывод + строка `Rating: X.X` для парсинга). Парсер `analysresult`. `decodeUtf8:true`.
- **`OpenAINameProductFromImageCall`** — `gpt-4o` vision, по image_url возвращает полное коммерческое название. Парсер `analysresult`.
- **`OpenAIFineTunedModelWebSearchCall`** — `gpt-4.1` + tool `web_search_preview` (эндпоинт `/v1/responses`), достаёт полный INCI по названию. Парсер `ingridientsoutput` (`$.output[1].content[0].text`).
- **`LocalizecampgetproductparameterCall`** / **`Localizecampextractproductnamefromimage`** / **`Localizecampgetincilist`** — обёртки над `api.localizecamp.com` (get-product-parameter, extract-product-name-from-image, get-inci-list). Парсеры `value` / `productname` / `incilist`.

Supabase Edge Functions (`/functions/v1/...`, Bearer = user token):
- **`CloneimageandparamsCall`** — `clone_image_and_params` (клон изображения и параметров по `image_id`).
- **`LinkTelegramCall`** — `link-telegram` (привязка по коду). Парсеры `ok`, `errorCode`.
- **`LinkitemtoalbumsCall`** — `link_item_to_albums` (`image_id` + `album_ids[]`).
- **`AnalyzeCompatibilityCall`** — `analyze-compatibility` (`image_ids[]`, `language_code`, `user_id`, `skin_profile{}`). Парсер `score`. **Основной анализ совместимости косметички.**

Собственный бэкенд Mirra (`${host}api/mirra/...`):
- **`AnalyzeingredientsCall`** — `${host}analyze-ingredients` (статичный Bearer `dGVzdHVzZXI6...`). Тело: `inci_string`, `product_name`, `image_id`, `user_id`. Парсеры `score`, `cleandescription`.
- **`AnalyzeproductNEWBCNDCall`** — `api/mirra/analyze-product` (**без Authorization-заголовка**). Тело: image_id/user_id/language_code/country. Парсеры message/error/resettime/limit/details (обрабатывает лимиты).
- **`SearchingredientsNEWBCNDCall`** — `api/mirra/search-ingredients` (Bearer token). **Таймаут 120с** → при истечении возвращает `ApiCallResponse(null,{},-1)` (statusCode -1), чтобы UI сбросил состояние «Ищем состав». Парсеры message/error/resettime/limit/details/code.
- **`SetProductIngredientsCall`** — PATCH `api/mirra/product/{imageId}/ingredients` (`ingredients`, `normalize:true`).
- **`ScientificanalysisNEWBCNDCall`** — POST `api/mirra/scientific-analysis` (Bearer). Богатые парсеры: `consumersummary`, `coveragepercent`, `expertsummary`, `productname`, `formatteddisplay`, `bestfor[]`, `avoidif[]`, `errorcode`. **Основной научный анализ продукта.**
- **`FeedbackNEWBCNDCall`** — POST `${host}/api/mirra/feedback` (обратите внимание — двойной слэш из-за `${host}/api/...`). Тело: image_id/user_id/`vote` (передаётся как строка `"true"`/`"false"`). Возвращает те же поля анализа.
- **`GetimageNEWBCNDCall`** — GET `api/mirra/scientific-analysis/{imageId}` (**без Authorization**). Много парсеров: brand/name/type, ingredients, overall_score, rating_text, ingredient_coverage/coverage_percent, `top_ingredients[]` (category/concentration/description/efficacy_contribution/name/position), `skin_compatibility[]` (label/score/skin_type), summary, how_to_use. **Полное чтение результата анализа.**
- **`ExtractproductinfoNEWBCNDCopyCall`** — POST `api/mirra/extract-product-info` (Bearer). **Таймаут 120с** → `-1`. Парсеры name/brand/image_id/language_code; **+ quota-поля на 429 `SCAN_QUOTA_EXCEEDED`**: `quotaUsed(limit)`, `resetTime`, `quotaCode(code)`, `remaining`, `resetAt`, `retryAfterSeconds`. **Первый шаг скана — распознавание продукта + гейтинг квоты.**
- **`GetScanQuotaCall`** — GET `api/mirra/quota` (Bearer). Парсеры `plan`, `is_unlimited`, `quota_used`, `quota_limit`, `remaining`, `reset_at`, `retry_after_seconds`. **Источник истины по квоте сканов (гейтинг Free/Pro).**
- **`CopyproductNEWBCNDCall`** — POST `api/mirra/copy-product` (`source_image_id`, `target_user_id`). Парсеры `answer(message)`, `newimageid`.
- **`ResearchAndAnalyzeCall`** — POST `api/mirra/research-and-analyze` (`image_id`, `language_code`).
- **`SubscriptionupgradeNEWBCNDCall`** — POST `api/mirra/subscription/upgrade` (`user_id`, `duration_days`; **без Authorization**). Парсер `answer(message)`.
- **`SubscriptioncheckNEWBCNDCall`** — POST `api/mirra/subscription/check` (`user_id`; без Authorization). Парсеры `remaining`, `allowed`. **Проверка права на анализ (гейтинг).**
- **`DeleteUserNEWBCNDCall`** — DELETE `api/mirra/user/{userId}` (Bearer). Удаление аккаунта.
- **`ParseSearchPhraseCall`** (B3) — POST `api/mirra/search/parse` (`phrase`, `lang`). NL-фраза → фасеты. Парсеры `facets[]`, `unparsed`, `sort`.
- **`SearchProductsCall`** (B4) — POST `api/mirra/search` (`facets{}`, `sort='fit'`, `profile{}`, `cursor`, `limit=20`). Фасетный поиск продуктов. Парсеры `results[]`, `total`, `cursor`, `hasMore`, `narrowestFacet`.

Гипотезы: несколько эндпоинтов (`analyze-product`, subscription check/upgrade) идут **без токена** — авторизация только по `user_id` в теле. Квота отдаётся 429-ответом с `SCAN_QUOTA_EXCEEDED`. Таймаут 120с завязан на серверный gunicorn timeout; при зависании UI получит `succeeded=false`.

### `lib/backend/api_requests/get_streamed_response.dart` (5 строк)
`getStreamedResponse(request)` → `Client().send(request)`. Используется для streaming-вызовов в `api_manager`.

### `lib/backend/api_requests/browser_client_stub.dart` (29 строк)
Заглушка `BrowserClient` для не-web платформ (`withCredentials` — no-op). Никогда фактически не инстанцируется на mobile (там `http.Client()`), нужна для совместимости типов при условном импорте.

---

## 4. Внешние интеграции

### `lib/backend/gemini/gemini.dart` (86 строк)
Google Generative AI. Вшитый `_kGeminiApiKey`.
- `geminiGenerateText(context, prompt)` — `gemini-1.5-pro` `generateContent`. При ошибке: Crashlytics + `showSnackbar` + `null`.
- `geminiCountTokens(context, prompt)` — подсчёт токенов (`gemini-1.5-pro`).
- `loadImageBytesFromUrl(url)` — GET картинки; при не-200 бросает Exception.
- `geminiTextFromImage(context, prompt, {imageNetworkUrl, uploadImageBytes})` — `gemini-1.5-flash` мультимодально (image/jpeg). assert: должен быть задан URL или байты. При ошибке: Crashlytics + snackbar + null.

Гипотеза: Gemini используется как fallback/вспомогательный LLM; ошибки не фатальны, пользователю показывается snackbar.

### `lib/backend/algolia/algolia_manager.dart` (87 строк) и `serialization_util.dart` (76 строк)
Инфраструктура Algolia. **`kAlgoliaApplicationId` и `kAlgoliaApiKey` пусты** → фактически поиск через Algolia не работает (поиск продуктов реализован через собственный бэкенд `SearchProductsCall`).
- `FFAlgoliaManager` (синглтон) — кэш запросов, `algoliaQuery({index, term, maxResults, location, searchRadiusMeters, useCache})`. Требует term или location, иначе `[]`. Ошибки печатаются, возвращается `[]`.
- `serialization_util.dart` — `convertAlgoliaParam<T>` конвертирует Algolia-данные в типы FF (int/double/DateTime(ms)/LatLng(`_geoloc`)/Color/DocumentReference/DataStruct). Ошибки → `null` + print.

### `lib/backend/firebase/firebase_config.dart` (18 строк)
`initFirebase()` — web: явные `FirebaseOptions` (project `mirra-9c10a`); mobile: `Firebase.initializeApp()` (из платформенных конфигов).

---

## 5. Firestore-схема (schema/)

### `lib/backend/schema/errors_record.dart` (104 строки)
Единственная Firestore-коллекция — **`errors`** (переводы текстов ошибок).
- `class ErrorsRecord extends FirestoreRecord` — поля `code`, `lang_code`, `text` (все `String`, дефолт `''`), `hasX()` проверки на null.
- Стандартные FF-методы: `collection`, `getDocument` (stream), `getDocumentOnce`, `fromSnapshot`, `getDocumentFromData`.
- `createErrorsRecordData({code, langCode, text})` — строит map для записи (через `mapToFirestore`, `withoutNulls`).
- `ErrorsRecordDocumentEquality` — сравнение по трём полям.

### `lib/backend/schema/index.dart` (5 строк)
Реэкспорт `cloud_firestore` (hide Order), Color/Colors, lat_lng, `structs/index.dart`.

### `lib/backend/schema/util/firestore_util.dart` (150 строк)
Инфраструктура Firestore (FF-генерация):
- `abstract FirestoreRecord`, `abstract FFFirebaseStruct extends BaseStruct` (держит `FirestoreUtilData`).
- `FirestoreUtilData({fieldValues, clearUnsetFields=true, create=false, delete=false})` — управляет как FF пишет структуры в Firestore.
- `mapFromFirestore` / `mapToFirestore` — конвертация Timestamp↔DateTime, GeoPoint↔LatLng, Color↔css, рекурсивно для вложенных map/списков.
- `mergeNestedFields` — «foo.bar» ключи → вложенные map.
- `safeGet<T>` — try/catch-обёртка с опц. reportError. `toRef(ref)` — строка → DocumentReference.

### `lib/backend/schema/util/schema_util.dart` (107 строк)
- `typedef StructBuilder<T>`, `abstract BaseStruct` (`toSerializableMap`, `serialize()` → json).
- `deserializeStructParam` / `convertAlgoliaStruct` — десериализация структур (из param/Algolia).
- `getStructList`, `getSchemaColor`, `getColorsList`, `getDataList<T>` — хелперы построения списков/цветов из динамики.

---

## 6. Data-структуры анализа (schema/structs/, 15 файлов)

**Общий шаблон (FlutterFlow-генерация):** каждый `XStruct extends FFFirebaseStruct extends BaseStruct`. Приватные поля `_field` + геттеры с дефолтом (`?? ''`/`0`/`0.0`/`false`/`const []`) — то есть **`null`-безопасные, невалидные данные не роняют UI**, а дают нейтральный дефолт. Есть сеттеры, `hasX()`-проверки, `fromMap`/`toMap`/`toSerializableMap`/`fromSerializableMap`, фабрика `createXStruct(...)`, `fromAlgolia`, `==`/`hashCode` (ListEquality), extension на nullable. Это чисто модель данных ответа анализа (маппинг JSON бэкенда `scientific-analysis`/`analyze-product` в типизированные объекты FF). Ниже — только поля каждой структуры.

- **`ScientificanalysStruct`** (корневая) — `analysis: AnalysisStruct`, `brand`, `databaseCoverage: DatabaseCoverageStruct`, `formattedDisplay`, `imageId` (String), `legacyScore` (double), `productName`.
- **`AnalysisStruct`** — `avoidIf[]`, `bestFor[]`, `consumerSummary`, `coveragePercent` (double), `expertSummary`, `formattedConclusions: FormattedConclusionsStruct`, `incompatibilities[]`, `ingredientAnalysis: List<IngredientAnalysisStruct>`, `keyReferences: List<KeyReferencesStruct>`, `patchTestAdvised` (bool), `problematicIngredients[]`, `productType`, `recognizedIngredients` (int), `recommendedTime`, `requiresSpf` (bool), `scores: ScoresStruct`, `skinTypeSuitability: SkinTypeSuitabilityStruct`, `synergies[]`, `topActives[]`, `totalIngredients` (int).
- **`ScoresStruct`** — `compositeScore` (double), `compositeCalculation`, вложенные `comedogenicity`, `efficacy`, `safety`, `stability`, `userExperience`.
- **`ComedogenicityStruct` / `EfficacyStruct` / `SafetyStruct` / `StabilityStruct` / `UserExperienceStruct`** — единый под-шаблон: `score` (int), `confidence` (int), `keyFactors[]`, `calculationBreakdown` (текст расчёта).
- **`IngredientAnalysisStruct`** — `inciName`, `position` (int), `category`, `estimatedConcentration`, `efficacyContribution` (int), `efficacyTier` (int), `comedogenicityRating` (int), `safetyContribution` (int), `evidenceLevel`, `mechanism`, `isActive` (bool), `isProblematic` (bool).
- **`FormattedConclusionsStruct`** — `finalVerdict`, `outstandingPoints[]`, `problematicPoints[]`, `idealFor[]`, `notRecommendedFor[]`, `concentrationNote`, `synergyHighlight`.
- **`SkinTypeSuitabilityStruct`** — оценки (int) по типам кожи: `dry`, `oily`, `combination`, `normal`, `sensitive`, `acneProne`.
- **`KeyReferencesStruct`** — `finding`, `source`, `year` (int) — научные ссылки.
- **`DatabaseCoverageStruct`** — `totalIngredients`, `foundInDb`, `queuedForResearch` (все int) — покрытие ингредиентов БД.
- **`MessegefrompaymentStruct`** — `ok` (bool), `cancelled` (bool), `code`, `message` — результат платежа/подписки (сообщение из платёжного потока).

---

## 7. Supabase-таблицы (supabase/database/tables/, 45 файлов — сгенерированы)

**Общий шаблон обёртки (описан один раз):** каждый файл содержит два класса:
1. `XTable extends SupabaseTable<XRow>` — только `tableName` (реальное имя в Postgres) и `createRow(data)`. Наследует от базового `SupabaseTable` методы `queryRows/querySingleRow/insert/update/delete` (см. `table.dart`).
2. `XRow extends SupabaseDataRow` — геттеры полей через `getField<T>('col')` (`!` = NOT NULL/обязательное; `?` = nullable) и `getListField<T>('col')` (Postgres-массивы). Значения (де)сериализуются по `row.dart` (числовые строки → int/double, DateTime → local).

Ниже — по каждой таблице: имя, колонки (тип: Dart-тип; `!` = обязательное), нетипичные детали.

### Продукты / изображения / анализ
- **`images`** (`images`) — центральная таблица сканов/продуктов. Колонки: `id`(int!), `created_at`(DateTime!), `image_url`(String!), `user`(String?), `product_name`, `favourite`(bool?), `language_code`, `brand`, `personal_notes`, `ingredients`, `hided`(bool?). Блок научного анализа `sa_*`: `sa_composite_score`, `sa_legacy_score`, `sa_efficacy_score`, `sa_safety_score`, `sa_stability_score`, `sa_ux_score` (double?), `sa_quick_summary`, `sa_expert_analysis`, `sa_best_for_tags`(List<String>), `sa_ingredients_total`(int?), `sa_analyzed_at`(DateTime?), `sa_rating_text`, `sa_how_to_use`, `sa_language_code`, `sa_scoring_log`(dynamic/JSON), `sa_one_percent_line_pos`(int?), `sa_confidence_level`, `sa_confidence`(dynamic), `sa_goal_support`(dynamic), `sa_claim_audit`(dynamic), `sa_inci_list`(List<String>), `product_category`, `product_type`. **Фильтрация по `user` (владелец).** dynamic-поля = JSON-блобы анализа.
- **`unsorted_images`** (view) — `id`, `created_at`, `image_url`, `user`, `product_name` (все nullable). Несортированные сканы.
- **`top_10_parametrs_with_images`** (view) — то же 5 колонок. Топ-параметры с картинками.
- **`parameters`** (`parameters`) — `id`(int!), `created_at`(DateTime!), `name`, `value`, `image_id`(int?), `user`, `parameter_number`(int?), `score`(double?). Параметры продукта по изображению/пользователю.
- **`product_datasheet`** (`product_datasheet`) — справочник продуктов: `id`(int!), `brand`, `name`(String!), `type`, `country`, `ingredients`(String!), `after_use`, `created_at`(DateTime!), `inci_embedding` (вектор как строка).
- **`product_prices`** (`product_prices`) — **нетипично: кастомный `_parseNumeric`** для `avg_price`/`price_min`/`price_max` (double?, парсит из num или строки; DECIMAL приходит строкой). Ключи: `product_name_key`(String!), `brand_key`(String!), `country_code`(String!), `price_currency_code`(String!), `price_searched_at`(DateTime?). Кэш цен по продукту/стране.

### Прогресс анализа (стриминг статуса)
- **`analysis_progress`** (`analysis_progress`) — `id`(int!), `analysis_id`(String!), `user_id`(String!), `image_id`(int?), `current_step`(int!), `total_steps`(int!), `status`(String!), `step_key`(String!), `progress_percentage`(int!), `error_message`, `error_code`, `created_at`/`updated_at`(DateTime!), `completed_at`(DateTime?). **Отслеживание прогресса анализа в реальном времени; фильтр по `user_id`.**
- **`analysis_progress_with_steps`** (view) — то же + `language_code`, `step_title`, `step_description` (все nullable; JOIN с progress_steps).
- **`progress_steps`** (`progress_steps`) — локализованные шаги: `id`(int!), `step_key`(String!), `step_number`(int!), `language_code`(String!), `title`(String!), `description`(String!).

### Результаты анализа изображения
- **`image_conclusions`** (`image_conclusions`) — `id`(int!), `image_id`(int!), `conclusion_type`(String!), `content`(String!), `sort_order`(int?), `created_at`(DateTime?).
- **`image_top_ingredients`** (`image_top_ingredients`) — `id`(int!), `image_id`(int!), `ingredient_name`(String!), `inci_position`(int?), `efficacy_contribution`(double?), `category`, `sort_order`(int?), `created_at`, `description`, `status`, `mec`(double?), `evidence_level`.
- **`image_skin_compatibility`** (`image_skin_compatibility`) — `id`(int!), `image_id`(int!), `skin_type`(String!), `compatibility_score`(int!), `created_at`(DateTime?), `label`, `verdict`.
- **`image_ingredient_issues`** (`image_ingredient_issues`) — `id`(int!), `image_id`(int!), `ingredient_name`(String!), `issue_type`(String!), `severity`(String!), `description`, `created_at`, `relevant_for`(List<String> — для каких профилей кожи актуально).
- **`image_claims_v`** (view) — покрытие + булевы claim/warn флаги: `image_id`, `ingredients`, `parsed_count`/`matched_count`/`unmatched_count`(int?), `coverage_pct`(double?), `claim_*`(hydration/softening/texture_smoothing/gel_texture/emulsion_base/film_smoothing/barrier_support/soothing/exfoliation — bool?), `warn_*`(fragrance_allergen/eye_area_caution/dry_skin_unfriendly — bool?).
- **`image_score_v`** (view) — всё из `image_claims_v` + скоринг: `score_100`(int?), `score_10`(double?), `score_components_comfort/barrier/actives/texture`(int?), `n_low_coverage`(int?). **Готовый агрегированный скор продукта.**

### Альбомы / коллекции
- **`album`** (`album`) — `created_at`(DateTime!), `user`, `name`, `id`(String!), `cover`.
- **`album_images`** (view/таблица) — денормализованная связка: `id`(int?), `album_id`, `owner_id`, `image_id`(int?), `created_at`, `image_url`, `image_user`, `product_name`, `brand`, `rating`, `score`(double?), `sa_composite_score`(double?), `stars_from_user`(int?), `pros`, `cons`, `warnings`, `summary`.
- **`images_albums_connection`** (`images_albums_connection`) — M2M: `id`(int!), `created_at`(DateTime!), `album_id`, `image_id`(int?), `user`.

### Косметичка / рутина
- **`cosmetic_bag`** (`cosmetic_bag`) — `user_id`, `last_compatibility_score`(double?), `last_result`(dynamic/JSON), `last_analyzed_at`(DateTime?), `created_at`. **Кэш последнего анализа совместимости косметички на пользователя.**
- **`bag_slots`** (`bag_slots`) — `id`(String?), `user_id`, `slot_index`(int?), `image_id`(int?), `created_at`. Слоты косметички (см. CosmeticBagService).
- **`routine_events`** (`routine_events`) — `id`(String?), `user_id`, `image_id`(int?), `title`, `part_of_day`(am/pm), `weekdays`(List<int>), `time_of_day`(String — HH:MM:SS), `enabled`(bool?), `local_notification_id`(int?), `created_at`. См. RoutineService.

### Пользователи / подписки / квоты
- **`users`** (`users`) — `created_at`(DateTime!), `name`, `email`, `id`(String!), `first_name`, `last_name`, `profile_image`, `nickname`, `onboarded`(bool?), **`subscription_plan`** (гейтинг Pro/Free), `language_code`, `country_id`(int?), `monthly_analyses_used`(int?), `last_reset_date`(DateTime?), профиль кожи: `skin_type`, `skin_sensitivity`(bool?), `skin_goals`(List<String>), `acne_prone`(bool?), `age_range`, `budget_range`, `trusted_brands`(List<String>). **Профиль кожи используется в `skin_profile`/`profile` вызовов анализа/поиска.**
- **`user_subscription_info`** (view) — `id`, `email`, `subscription_plan`, `monthly_analyses_used`(int?), `last_reset_date`, `monthly_limit`(int?), `remaining_analyses`(int?), `subscription_status`, `days_until_expiry`(int?). **Готовое представление лимитов/статуса подписки.**
- **`user_usage_stats`** (view) — `user_id`, `hourly_count`, `daily_count`, `monthly_count`, `total_count` (int?). Агрегаты использования (рейт-лимиты).
- **`api_usage`** (`api_usage`) — `id`(int!), `user_id`(String!), `endpoint`(String!), `created_at`(DateTime!). Лог вызовов API.
- **`feedback`** (`feedback`) — `id`(int!), `image_id`(int!), `user_id`(String!), `vote`(bool!), `previous_value`(bool?), `created_at`(DateTime!), `last_changed_at`(DateTime!). Голоса лайк/дизлайк по анализу.
- **`countries`** (`countries`) — `id`(int!), `code`(String!), `name_en/ru/es`(String!), `flag_emoji`, `created_at`. Локализованные страны.

### Справочники ингредиентов (научная база)
- **`ingredients`** (`ingredients`) — `id`(int!), `inci_name`(String!), `rating`, `description`, `category`, `embedding`(вектор строкой), `created_at`(DateTime!), `normalized_inci_name`(String!), `updated_at`(DateTime!).
- **`ingredient_synonyms`** — `id`(int!), `ingredient_id`(int!), `synonym`(String!), `normalized_synonym`(String!), `created_at`(DateTime!).
- **`ingredients_efficacy`** — эффективность: `id`, `inci_name`, `inci_name_normalized`(!), `category`(!), `subcategory`, `efficacy_tier`(int!), веса `hydration/brightening/anti_aging/soothing/acne_control_weight`(int?), `evidence_level`(String!), `evidence_multiplier`(double!), `optimal_concentration`(double?), `mechanism_of_action`, `description_en/ru/es`, `created_at`/`updated_at`.
- **`ingredients_safety`** — безопасность: `id`, `inci_name`, `inci_name_normalized`(!), `overall_safety_score`(int!), `ewg_score`(int?), `irritation_risk`/`sensitization_risk`/`photosensitivity_risk`(String!), булевы `is_allergen`/`is_harsh_surfactant`/`is_drying_alcohol`/`is_fragrance`/`is_essential_oil`/`eu_restricted`/`eu_banned`(bool?), `safety_notes`, `contraindications`, `created_at`/`updated_at`.
- **`ingredients_comedogenicity`** — `id`, `inci_name`, `inci_name_normalized`(!), `fulton_rating`(int! — шкала Фултона 0-5), `rating_confidence`, `can_clog_pores`/`acne_safe`/`fungal_acne_safe`/`concentration_dependent`(bool?), `safe_below_position`(int?), `notes`, `created_at`/`updated_at`.
- **`ingredient_function_map`** — M2M ингредиент↔функция: `ingredient_id`(!), `function_id`(!), `weight`(int!), `evidence_level`(String!), `notes`, `created_at`.
- **`functions`** — справочник функций: `id`, `code`(!), `title`(!), `description`, `created_at`.
- **`ingredient_risk_map`** — M2M ингредиент↔риск: `ingredient_id`(!), `risk_flag_id`(!), `severity`(int!), `evidence_level`(String!), `conditions`, `notes`, `created_at`.
- **`risk_flags`** — справочник рисков: `id`, `code`(!), `title`(!), `description`, `created_at`.
- **`ingredient_incompatibilities`** — конфликты пар: `id`, `ingredient_a`/`ingredient_b`(!), `severity`(String!), `penalty_multiplier`(double!), `incompatibility_type`(String!), `affects_efficacy/stability/safety`(bool?), `can_be_mitigated`(bool?), `mitigation_notes`, `mechanism`, `warning_message`, `scientific_reference`, `created_at`/`updated_at`.
- **`ingredient_synergies`** — синергии пар: `id`, `ingredient_a`/`ingredient_b`(!), `synergy_type`(String!), `synergy_strength`(double!), `affects_efficacy/stability/safety`(bool?), `mechanism`, `scientific_reference`, `created_at`/`updated_at`.
- **`product_type_weights`** — веса компонентов скора по типу продукта: `id`, `product_type`(!), `efficacy_weight`/`safety_weight`/`stability_weight`/`ux_weight`/`comedogenicity_weight`(double!), `display_name_en/ru`, `created_at`/`updated_at`. **Определяет, как складывается composite score для разных категорий.**

### Очередь исследования ингредиентов (backend-пайплайн)
- **`ingredient_research_queue`** — `id`, `inci_name`(!), `normalized_name`(!), `status`(String!), `priority`(int!), `request_count`(int!), `first_seen_image_id`(int?), `first_seen_product`, `first_seen_brand`, `research_result`(dynamic/JSON), `research_model`, `research_tokens_used`(int?), `error_message`, `retry_count`(int!), `max_retries`(int!), `created_at`/`updated_at`, `research_started_at`. **Неизвестные ингредиенты ставятся в очередь на LLM-исследование.**
- **`ingredient_queue_summary`** (view) — `status`, `count`(int?). Агрегат по статусам очереди.

### Конфигурация / промпты
- **`app_config`** (`app_config`) — фичефлаги: `key`(String!), `int_value`(int?), `updated_at`(DateTime?). **ВНИМАНИЕ:** обёртка знает `int_value`, но `remote_config.dart` читает колонку `value` напрямую (строкой) — фактическое хранилище флагов в `value`.
- **`default_parameters`** — `id`(int!), `created_at`(DateTime!), `default_parameter_name`, `lang`. Дефолтные параметры по языку.
- **`default_prompts`** — `id`(int!), `created_at`(DateTime!), `prompt_1`, `prompt_2`, `lang`. Дефолтные промпты по языку.

---

## Сводка находок для гипотез

1. **Скан-пайплайн (по вызовам):** `ExtractproductinfoNEWBCNDCopyCall` (распознать продукт + проверка квоты, 429 SCAN_QUOTA_EXCEEDED, таймаут 120с) → `SearchingredientsNEWBCND` / `SetProductIngredients` (состав) → `ScientificanalysisNEWBCND` / `research-and-analyze` (анализ) → чтение `GetimageNEWBCND` / таблиц `images.sa_*`, `image_score_v`, `image_top_ingredients`, `image_skin_compatibility`. Прогресс — через `analysis_progress`.
2. **Гейтинг Free/Pro** не в этом слое; отражён через `GetScanQuotaCall` (`plan`/`is_unlimited`/`quota_limit`), `users.subscription_plan`, `user_subscription_info`, RemoteConfig `free_scan_limit` → `FFAppState().freeScanLimit`, `SubscriptioncheckNEWBCND` (`allowed`/`remaining`). Косметичка комментирует «Pro swap», но код Pro не проверяет.
3. **Безопасность:** секреты захардкожены в `api_calls.dart`/`supabase.dart`/`gemini.dart` (OpenAI key, Telegram token, статичный Bearer, anon key). Часть OpenAI-вызовов с нерабочим плейсхолдером ключа.
4. **Отказоустойчивость:** `makeApiCall` любую ошибку превращает в `statusCode=-1` (`succeeded=false`); два вызова оборачивают серверный gunicorn-timeout в те же `-1`. Структуры анализа `null`-безопасны (нейтральные дефолты). Firestore-запросы и `querySingleRow` логируют в Crashlytics и не роняют поток.
5. **Особенности данных:** числовые Postgres-колонки (DECIMAL) приходят строками — корректно кастятся в `row.dart` и кастомном `_parseNumeric` (product_prices); все DateTime приводятся к локальному времени; `app_config` читается в обход обёртки (колонка `value`).


---

# Ядро FlutterFlow (lib/flutter_flow/)

Раздел документирует инфраструктурное ядро Flutter-приложения Mirra: тема, локализация, навигация, глобальный стейт (`app_state.dart`), push- и локальные уведомления, RevenueCat, аналитика, а также генерируемые FlutterFlow утилиты и виджеты.

Директория `lib/flutter_flow/` содержит **22 .dart файла** (~13 854 строки; из них 8 666 — сгенерированная таблица переводов). Дополнительно в этом разделе описан ключевой для гейтинга файл `lib/app_state.dart` (лежит уровнем выше, но именно он — источник всех флагов).

Оглавление:
1. `app_state.dart` — глобальный стейт и ВСЕ флаги (ключ к гейтингу)
2. `notification_service.dart` — push + локальные уведомления
3. `nav/nav.dart` — роутинг и редиректы
4. `nav/serialization_util.dart` — (де)сериализация параметров роутов
5. `internationalization.dart` — механизм локализации
6. `flutter_flow_theme.dart` — тема/типографика/дизайн-токены
7. `flutter_flow_util.dart` — утилиты общего назначения
8. `flutter_flow_widgets.dart` — кнопка FFButton, focus-индикатор
9. `flutter_flow_model.dart` — базовая модель страницы/компонента
10. `revenue_cat_util.dart` — подписки/entitlement
11. `analytics_service.dart` — Firebase Analytics события
12. `custom_functions.dart` — кастомные функции
13. `upload_data.dart` — выбор медиа/файлов
14. Мелкие виджеты и value-типы (drop_down, icon_button, toggle_icon, language_selector, animations, form_field_controller, lat_lng, place, uploaded_file, random_data_util)

---

## 1. `lib/app_state.dart` — глобальный стейт `FFAppState` (КЛЮЧ К ГЕЙТИНГУ)

**Путь:** `/Users/usuario/DEVELOPMENT/mi_r_r_a_dev/lib/app_state.dart`
**Назначение:** singleton-хранилище всего кросс-экранного состояния приложения. Наследует `ChangeNotifier`. Часть полей персистится в `SharedPreferences` (ключи с префиксом `ff_`), часть — только на время сессии (in-memory).

### Класс `FFAppState extends ChangeNotifier`
- Реализован как **синглтон**: `factory FFAppState() => _instance`, приватный конструктор `_internal()`.
- `static void reset()` — пересоздаёт `_instance` (используется при полном сбросе/логауте).
- `Future initializePersistedState()` — читает `SharedPreferences` и восстанавливает ВСЕ персистентные поля. Каждое чтение обёрнуто в `_safeInit(...)` (глотает исключения, чтобы битый ключ не ронял старт).
- `void update(VoidCallback callback)` — выполняет мутацию и вызывает `notifyListeners()` (стандартный способ менять стейт с ре-билдом слушателей).
- `late SharedPreferences prefs` — экземпляр prefs, инициализируется в `initializePersistedState`.

### ⚠️ ВАЖНО про персистентность
Сеттеры персистентных полей пишут в `prefs`, но **НЕ вызывают `notifyListeners()`** сами по себе (нотификация идёт только через `update()`). Некоторые сеттеры пишут в prefs напрямую, значит значение сохранится, даже если менять поле в обход `update()`.

### ПОЛНЫЙ СПИСОК ПОЛЕЙ

#### Персистентные (сохраняются в SharedPreferences)

| Поле (get/set) | Тип | Ключ в prefs | Дефолт | Назначение |
|---|---|---|---|---|
| `onboardingDone` | bool | `ff_onboardingDone` | `false` | Пройден ли квиз типа кожи (онбординг). Управляет тем, куда попадает неавторизованный юзер: `NewblankWidget` (done) vs `OnboardingQuizWidget`. |
| `homePipelineDoneUsers` | List\<String\> | `ff_homePipelineDoneUsers` | `[]` | Список user-id, для которых домашний 3-шаговый пайплайн «попробуй все фичи» завершён навсегда. Хранится по id, чтобы не «протекать» между аккаунтами и не появляться заново. |
| `bagOnboardingDone` | bool | `ff_bagOnboardingDone` | `false` | Завершил ли юзер начальный 3-сканный интро-флоу косметички. **Отдельно** от `onboardingDone` (квиз кожи). |
| `bagOnboardingActive` | bool | `ff_bagOnboardingActive` | `false` | True **только пока** новый юзер внутри 3-сканного game-flow. Гейтит reroute после успешного скана, чтобы у существующих юзеров сканы не «угонялись» в онбординг. |
| `pendingBagSlot` | int | `ff_pendingBagSlot` | `-1` | Индекс слота косметички, ожидающего свежий скан (флоу «новый скан» в постоянной косметичке). `-1` = нет ожидания. Персистится, чтобы пережить round-trip скана при размонтировании виджета. |
| `bagScanCount` | int | `ff_bagScanCount` | `0` | Сколько из первых 3 онбординг-сканов сделано (0..3). Отличается от `obStep` (точка возобновления квиза). |
| `darkModeSet` | bool | `ff_darkModeSet` | `false` | Флаг, что пользователь вручную задавал тёмную тему. |
| `freeScanLimit` | int | `ff_freeScanLimit` | `10` | Бесплатный недельный лимит сканов. Источник истины — строка `app_config` (`free_scan_limit`) в БД, читается раз за сессию; персистится для оффлайна/первой отрисовки до ответа БД. |
| `showLinkTelegram` | bool | `ff_showLinkTelegram` | `true` | Показывать ли пункт «Link Telegram» в меню профиля. Источник истины — `app_config` (`show_link_telegram`). |
| `userProfilePicture` | String | `ff_userProfilePicture` | `''` | URL аватара пользователя. |
| `feedbackCollectorEnabled` | bool | `ff_feedbackCollectorEnabled` | `false` | Включён ли сбор фидбэка (feature-flag коллектора отзывов). |
| `feedbackReviewSubmitted` | bool | `ff_feedbackReviewSubmitted` | `false` | Отправил ли юзер отзыв (чтобы не просить повторно). |
| `feedbackBannerDismissed` | bool | `ff_feedbackBannerDismissed` | `false` | Закрыл ли юзер баннер фидбэка. |
| `feedbackLastShownVersion` | String | `ff_feedbackLastShownVersion` | `''` | Версия приложения, в которой последний раз показывали запрос фидбэка. |
| `feedbackLastShownMs` | int | `ff_feedbackLastShownMs` | `0` | Timestamp (ms) последнего показа фидбэка. |
| `feedbackUserId` | String | `ff_feedbackUserId` | `''` | User-id, привязанный к фидбэку. |
| `obSkinType` | String? | `ff_obSkinType` | `null` | Онбординг-буфер: тип кожи. `null` → `prefs.remove`. |
| `obSensitive` | bool? | `ff_obSensitive` | `null` | Онбординг-буфер: чувствительная кожа (nullable трёхзначно). Читается только если ключ существует. |
| `obAcneProne` | bool? | `ff_obAcneProne` | `null` | Онбординг-буфер: склонность к акне. |
| `obGoals` | List\<String\> | `ff_obGoals` | `[]` | Онбординг-буфер: цели ухода. |
| `obAgeRange` | String? | `ff_obAgeRange` | `null` | Онбординг-буфер: возрастной диапазон. |
| `obBudgetRange` | String? | `ff_obBudgetRange` | `null` | Онбординг-буфер: бюджетный диапазон. |
| `obTrustedBrands` | List\<String\> | `ff_obTrustedBrands` | `[]` | Онбординг-буфер: доверенные бренды. |
| `obPendingFlush` | bool | `ff_obPendingFlush` | `false` | Флаг «есть несброшенные ответы квиза». На первом авторизованном экране, если true, буфер сливается в таблицу `users` и очищается. |
| `obStep` | int | `ff_obStep` | `0` | Точка возобновления прерванного квиза (индекс шага). Позволяет продолжить квиз после kill приложения. |

> **Онбординг-буфер (`ob*`)** — блок из 9 полей. Ответы собираются ДО логина и персистятся, чтобы квиз пережил kill приложения на середине. Метод `clearOnboardingBuffer()` стирает весь буфер (`obSkinType`…`obStep`), НЕ трогая `onboardingDone`. Вызывается после успешного flush или на «Пропустить».

#### Сессионные (in-memory, НЕ персистятся)

| Поле | Тип | Дефолт | Назначение |
|---|---|---|---|
| `uploadedimageurl` | String | `''` | URL загруженного изображения (текущий скан). |
| `numberofparametrs` | int | `0` | Число параметров анализа. |
| `subscriptionmonth` | bool | `false` | Флаг месячной подписки. |
| **`isprouser`** | bool | `false` | **Ключевой флаг PRO-статуса.** Выдаётся per-account из БД (после покупки/по RC-webhook), а НЕ из RevenueCat напрямую. RevenueCat-листенер только СНИМАЕТ pro при потере entitlement (см. `revenue_cat_util.dart`). |
| `analysisloading` | bool | `false` | Идёт ли анализ (флаг лоадера). |
| `countrycode` | String | `''` | Код страны (телефонный/регион). |
| `countrycodeiso` | String | `''` | ISO-код страны. |
| `uploudedimagepath` | String | `''` | Локальный путь загруженного изображения (опечатка в имени — `uploudedimagepath`). |
| `spamlist` | List\<int\> | `[]` | Список id, помеченных как спам. Есть хелперы: `addToSpamlist`, `removeFromSpamlist`, `removeAtIndexFromSpamlist`, `updateSpamlistAtIndex`, `insertAtIndexInSpamlist`. |
| `analysesused` | int | `0` | Сколько анализов использовано в текущем окне. |
| `weekResetDate` | DateTime? | `null` | Начало текущего 7-дневного окна сканов (из `users.last_reset_date`). `null` = окно ещё не начато (0 сканов). |
| `Producanalysstate` | int | `0` | Состояние анализа продукта (имя с опечаткой — `Producanalysstate`). |
| `extractedProductName` | String | `''` | Распознанное название продукта. |
| `extractedBrand` | String | `''` | Распознанный бренд. |
| `feedbackPendingScan` | bool | `false` | Сессионный флаг «ждём скан для фидбэка» (комментарий: not persisted). |

**Гипотезы/нюансы для владельца продукта:**
- **Два независимых онбординга**: квиз типа кожи (`onboardingDone`/`ob*`) и косметичка (`bagOnboardingDone`/`bagOnboardingActive`/`bagScanCount`). Их легко перепутать при формулировании гипотез.
- **PRO-статус (`isprouser`) — сессионный и НЕ персистентный**; его выдаёт бэкенд, RevenueCat только отзывает. При перезапуске приложения он должен переустанавливаться из БД.
- **Лимиты сканов** завязаны на `freeScanLimit` (из `app_config`), `analysesused` и `weekResetDate` (окно 7 дней из `users.last_reset_date`).
- `homePipelineDoneUsers` хранит список id — гейтинг домашнего пайплайна per-user, устойчив к смене аккаунта.

---

## 2. `notification_service.dart` — push (FCM) + локальные уведомления

**Путь:** `/Users/usuario/DEVELOPMENT/mi_r_r_a_dev/lib/flutter_flow/notification_service.dart`
**Назначение:** единый сервис для Firebase Cloud Messaging (push) и flutter_local_notifications (локальные напоминания рутины). Синглтон `NotificationService.instance`.

**Внешние зависимости:** `firebase_messaging`, `firebase_crashlytics`, `flutter_local_notifications`, `supabase_flutter`, `timezone`.

### Поля
- `_fcm = FirebaseMessaging.instance`, `_localNotifications = FlutterLocalNotificationsPlugin()`.
- `_onTap: void Function(Map<String,dynamic>)?` — колбэк обработки тапа/навигации, задаётся в `init`.
- `_cachedToken: String?` — последний известный FCM-токен.
- `_androidChannel` — канал `mirra_default` («MiRRA Notifications», importance.high).
- `_schedulingReady: bool` — готовность локального планировщика.

### Топ-левел
- `_firebaseBackgroundHandler(RemoteMessage)` (`@pragma('vm:entry-point')`) — обязательный обработчик фоновых сообщений; только логирует.

### Методы
- **`Future<bool> _waitForApnsToken()`** — на iOS ждёт до 5с (10×500мс) появления APNs-токена (без него `getToken()` не работает). На не-iOS сразу true.
- **`Future<void> init({required onTap})`** — вызывается один раз из `_MyAppState.initState()` после готовности роутера. Действия:
  1. Сохраняет `_onTap`.
  2. Регистрирует фоновый обработчик.
  3. `requestPermission(alert, badge, sound)`.
  4. `_setupLocalNotifications()`.
  5. `_initScheduling()` (изолирован от FCM: его падения не ломают push).
  6. Ждёт APNs, получает FCM-токен → `_saveToken`.
  7. Подписка на `auth.onAuthStateChange` — при появлении userId пересохраняет токен.
  8. `onTokenRefresh` — обновляет и пересохраняет токен.
  9. **Foreground `onMessage`**: если в `data` есть `image_id` (анализ готов) → сразу `_onTap(data)` (навигация). Иначе показывает локальное уведомление (payload = imageId).
  10. **`onMessageOpenedApp`** (тап из фона) → `_onTap(data)`.
  11. **`getInitialMessage`** (тап из terminated) → задержка 1200мс, затем `_onTap(data)`.
- **`Future<void> onUserLogin()`** — на смену авторизации: ждёт APNs, берёт токен, `_saveToken`.
- **`Future<void> onUserLogout()`** — деактивирует токен: `device_tokens.update({is_active:false})` по `user_id`+`token`. Ошибки → Crashlytics (non-fatal).
- **`Future<void> _saveToken(String token)`** — upsert в Supabase-таблицу **`device_tokens`** `{user_id, token, platform(ios/android), is_active:true}` c `onConflict:'user_id,token'`. Если userId null — пропускает.
- **`_setupLocalNotifications()`** — создаёт Android-канал, инициализирует плагин; `onDidReceiveNotificationResponse → _routeLocalPayload`. Обрабатывает запуск из terminated по локальному уведомлению (задержка 1200мс).
- **`_routeLocalPayload(String? payload)`** — маршрутизация payload'а: `'routine'` → `_onTap({'route':'routine'})` (открыть календарь рутины); иначе payload трактуется как image id → `_onTap({'image_id': payload})`.

### Планирование локальных напоминаний рутины
- **`_initScheduling()`** — `tzdata.initializeTimeZones()`, `setLocalLocation(_resolveLocalLocation())`, на iOS запрашивает разрешения. Ставит `_schedulingReady=true`. Ошибки → Crashlytics.
- **`_resolveLocalLocation()`** — best-effort таймзона: маппит текущее UTC-смещение на зону `Etc/GMT±N`. ⚠️ Только целочасовые смещения; DST не отслеживается; получасовые зоны → UTC.
- **`_nextInstanceOf(weekday, hour, minute)`** — ближайший будущий момент для заданного дня недели.
- **`scheduleWeeklyReminders({baseId, weekdays, hour, minute, title, body, payload})`** — планирует еженедельно повторяющееся уведомление на каждый день недели. id уведомления = `baseId*10 + weekday` (1=Пн..7=Вс), `matchDateTimeComponents: dayOfWeekAndTime`, Android-режим `inexactAllowWhileIdle`. Если `_schedulingReady=false` — no-op.
- **`cancelReminders(int baseId)`** — отменяет все 7 (`baseId*10+1..7`).

**Deep-link payload'ы (важно для гипотез):**
- `image_id` в push-`data` → открыть карточку продукта (в foreground сразу навигирует, минуя показ уведомления).
- `route: 'routine'` (payload `'routine'` у локального) → открыть календарь рутины.
- Прочие локальные payload'ы трактуются как image id.

---

## 3. `nav/nav.dart` — роутинг (GoRouter), редиректы, requireAuth

**Путь:** `/Users/usuario/DEVELOPMENT/mi_r_r_a_dev/lib/flutter_flow/nav/nav.dart`
**Назначение:** конфигурация GoRouter, логика редиректа новичка, глубокие ссылки, обёртки безопасной навигации.

### `AppStateNotifier extends ChangeNotifier` (синглтон `.instance`)
Отвечает за авторизацию и splash. Поля:
- `initialUser`, `user: BaseAuthUser?`; `showSplashImage = true`; `_redirectLocation: String?`; `notifyOnAuthChange = true`.
- Геттеры: `loading` (= showSplashImage), `loggedIn` (user.loggedIn), `initiallyLoggedIn`, `shouldRedirect` (loggedIn && есть redirectLocation).
- Redirect API: `getRedirectLocation`, `hasRedirect`, `setRedirectLocationIfUnset`, `clearRedirectLocation`.
- `updateNotifyOnAuthChange(bool)` — отключает ре-билд на auth-событие, когда после логина/логаута надо самим навигировать.
- **`update(BaseAuthUser newUser)`** — обновляет пользователя; вызывает `notifyListeners()` только если uid реально изменился и `notifyOnAuthChange`. Всегда возвращает `notifyOnAuthChange=true` в конце.
- `stopShowingSplashImage()` — гасит splash + notify.

### `createRouter(AppStateNotifier, [Widget? entryPage]) → GoRouter`
- `initialLocation:'/'`, `debugLogDiagnostics:true`, `refreshListenable: appStateNotifier`, `navigatorKey: appNavigatorKey`, `observers:[AnalyticsService.instance.observer]` (экраны логируются в Firebase Analytics).
- **`errorBuilder`** и **корневой роут `/` (`_initialize`)** содержат ОДНУ И ТУ ЖЕ логику стартового редиректа:
  1. если `loading` → `CircularProgressIndicator`;
  2. если `loggedIn` → `entryPage ?? HomeWidget()`;
  3. иначе → `appState.onboardingDone ? NewblankWidget() : OnboardingQuizWidget()`.
  Т.е. **новичок без логина** попадает на квиз (`OnboardingQuizWidget`), а прошедший квиз, но не залогиненный — на `NewblankWidget` (лендинг/логин).

### Полный список роутов
Каждый роут — `FFRoute(name, path, builder, requireAuth?)`, конвертируется через `.toRoute(appStateNotifier)`.

| name | path | requireAuth | Экран / примечание |
|---|---|---|---|
| `_initialize` | `/` | — | Стартовый редирект (см. выше) |
| CreateAccountPage | (routePath) | — | Регистрация |
| LogInPage | (routePath) | — | Логин |
| OnboardingProfile | (routePath) | — | Профиль-онбординг |
| OnboardingQuiz | (routePath) | — | Квиз типа кожи |
| Boards | (routePath) | ✅ | Доски |
| Home | (routePath) | ✅ | Главная |
| Search | (routePath) | ✅ | Поиск (`const SearchWidget()`) |
| Profile | (routePath) | ✅ | Профиль |
| ImagesbyAlbum | (routePath) | — | Изображения альбома, параметр `albumid:String` |
| ForgotPassword | (routePath) | — | Восстановление пароля |
| EditProfile | (routePath) | — | Редактирование профиля |
| Toprated | (routePath) | ✅ | Топ-рейтинг |
| Paywallpage | (routePath) | — | Пейволл |
| Langs | (routePath) | — | Выбор языка |
| TakeorUploadPage | (routePath) | — | Съёмка/загрузка |
| Countries | (routePath) | — | Страны |
| Newblank | (routePath) | — | Лендинг/логин-экран |
| CosmeticBagIntro | (routePath) | — | Интро косметички |
| CompatibilityResult | (routePath) | — | Результат совместимости |
| CosmeticBag | (routePath) | ✅ | Косметичка |
| RoutineCalendar | (routePath) | ✅ | Календарь рутины (цель deep-link `routine`) |
| Itemcard2 | (routePath) | — | Карточка продукта, параметр `imageid:int` |
| **`productDeepLink`** | **`/product/:id`** | — | Deep-link на карточку → `Itemcard2Widget(imageid: int.tryParse(id))` |
| Shareproduct | (routePath) | — | Шеринг продукта, параметр `imageid:int` |

### Логика редиректа `FFRoute.toRoute(...).redirect`
1. Если `appStateNotifier.shouldRedirect` → берёт и очищает `redirectLocation`, редиректит туда.
2. Если `requireAuth && !loggedIn` → сохраняет текущий URI как redirectLocation и редиректит на **`/Splash`**.
3. Иначе — без редиректа.

`pageBuilder`: чинит статус-бар (iOS16-), собирает `FFParameters`; если есть async-параметры — оборачивает в `FutureBuilder`. Пока `loading` — показывает `assets/images/splash.png` на белом фоне. Переход — `CustomTransitionPage` (если задан `TransitionInfo`) или `MaterialPage`.

### Вспомогательное
- **`NavigationExtensions on BuildContext`**: `goNamedAuth`/`pushNamedAuth` (учитывают `mounted` и redirect), `safePop()` (pop или `go('/')`).
- **`GoRouterExtensions`**: `prepareAuthEvent`, `shouldRedirect`, управление redirectLocation.
- **`FFParameters`** — извлечение параметров роута (path/query/extra), поддержка async-параметров (`completeFutures`), `getParam<T>(name, ParamType, ...)` с десериализацией.
- **`FFRoute`**, **`TransitionInfo`** (тип/длительность/выравнивание перехода, `appDefault()` = без анимации), **`RootPageContext`** (пометка корневой страницы), **`GoRouterLocationExtension.getCurrentLocation()`**.

**Гипотезы:** ключевая развилка новичка целиком в корневом роуте `/` и `errorBuilder`; `requireAuth` защищает Home/Search/Profile/Boards/Toprated/CosmeticBag/RoutineCalendar, редиректя на `/Splash` (обратите внимание — путь `/Splash` не объявлен явным FFRoute в этом списке). Глубокая ссылка `/product/:id` открывает карточку без авторизации.

---

## 4. `nav/serialization_util.dart` — (де)сериализация параметров роутов

**Путь:** `/Users/usuario/DEVELOPMENT/mi_r_r_a_dev/lib/flutter_flow/nav/serialization_util.dart`
**Назначение:** конвертация значений параметров навигации в строки и обратно (для передачи через URL/extra).

- `enum ParamType` — int, double, String, bool, DateTime, DateTimeRange, LatLng, Color, FFPlace, FFUploadedFile, JSON, Document, DocumentReference, DataStruct, **SupabaseRow**.
- `serializeParam(param, ParamType, {isList})` — сериализация в строку (даты → ms epoch, Color → css, place/uploadedFile → JSON, SupabaseRow → `json.encode(data)`). Ошибки логируются, возвращает null.
- `deserializeParam<T>(param, ParamType, isList, {...})` — обратно. Для **SupabaseRow** содержит большой `switch (T)` по ~40 типам строк БД (ImagesRow, UsersRow, IngredientsRow, FeedbackRow, ProductDatasheetRow и т.д.) — по сути реестр всех сериализуемых таблиц, которые могут передаваться между экранами.
- Хелперы: `dateTimeRangeToString/FromString`, `placeToString/placeFromString`, `latLngFromString`, `getDoc`/`getDocList` (Firestore).

---

## 5. `internationalization.dart` — механизм локализации

**Путь:** `/Users/usuario/DEVELOPMENT/mi_r_r_a_dev/lib/flutter_flow/internationalization.dart` (8 666 строк, из них подавляющая часть — таблица переводов).

### Как это работает
- **`class AppLanguage(code, flag, nativeName)`** — метаданные языка для пикеров.
- **`const List<AppLanguage> kAppLanguages`** — ЕДИНЫЙ источник поддерживаемых языков (11): `en, ru, es, de, fr, it, pt(🇧🇷), tr, ja, ko, zh`. Комментарий обязывает держать список в синхроне с iOS `CFBundleLocalizations` и языковыми картами бэкенда.
- **`kSupportedLanguages`** = список кодов из `kAppLanguages`.
- **`class FFLocalizations`**:
  - `FFLocalizations.of(context)` — доступ через `Localizations.of`.
  - `initialize()` / `storeLocale(locale)` / `getStoredLocale()` — сохранение выбранной локали в SharedPreferences под ключом `__locale_key__`.
  - **`String getText(String key)`** — ищет `kTranslationsMap[key][locale]`; если пусто → **fallback на `'en'`** (новые локали никогда не рендерят пустую строку); если и того нет → `''`.
  - `languageShortCode` — для набора языков с короткой формой (`_languagesWithShortCode`, отдельный расширенный список ~30 кодов, используется для `_short`-вариантов, напр. timeago).
- **`kTranslationsMap: List<Map<String, Map<String, String>>>`** — гигантская сгенерированная структура: список блоков (по экранам, с комментариями вроде `// CreateAccountPage`), каждый блок — map `{ключ_перевода: {код_языка: строка}}`. Ключи — короткие хэши (напр. `v4ogufdc`).
- Делегаты: `FFLocalizationsDelegate`, `FallbackMaterialLocalizationDelegate`, `FallbackCupertinoLocalizationDelegate` — подставляют дефолтные Material/Cupertino локализации для неподдерживаемых системой локалей.
- `createLocale(language)` — строит `Locale` (с поддержкой `_`-скрипта).
- `_isSupportedLocale(locale)` — проверка по `kSupportedLanguages`.

**Гипотезы:** добавление языка = добавить `AppLanguage` в `kAppLanguages` (+ iOS + бэкенд, см. чек-лист в памяти). Fallback-на-английский означает, что непереведённые строки НЕ ломают UI, но и не сигналят о пропуске.

---

## 6. `flutter_flow_theme.dart` — тема, типографика, дизайн-токены

**Путь:** `/Users/usuario/DEVELOPMENT/mi_r_r_a_dev/lib/flutter_flow/flutter_flow_theme.dart`

- **`abstract class FlutterFlowTheme`** — `FlutterFlowTheme.of(context)` определяет `DeviceSize` (mobile <479, tablet <991, desktop) и **ВСЕГДА возвращает `LightModeTheme()`** (тёмной темы как отдельного класса нет; несмотря на флаг `darkModeSet` в app_state, здесь всегда светлая палитра). Много `@Deprecated`-алиасов старых имён (title1/subtitle1/bodyText1 → новая шкала).
- **Палитра `LightModeTheme`** (резюме, ключевые): `primary #5C85D9` (голубой), `secondary #F2EBB4`, `tertiary #F4CFBC`, `alternate #FFFFFF`, `primaryText #1A1A1A`, `secondaryText #929292`, `primaryBackground #EBF0FC`, `secondaryBackground #CBDDFE`, accent1..4, `success #048178`, `warning #FCDC0C`, `error #FF5963`, `info #E7E8EB`.
- **Типографика** — абстрактный `Typography` + `MobileTypography`/`TabletTypography`/`DesktopTypography` (выбор по `deviceSize`). Все стили строятся `GoogleFonts.raleway(...)` (основной шрифт **Raleway**), шкала: displayLarge(57)…bodySmall. Есть `*Family` и `*IsCustom` геттеры.
- **Дизайн-токены** `FFDesignTokens(theme)`: `spacing` (`FFSpacing`: xs4/sm8/md16/lg24/xl32), `radius` (`FFRadius`: sm8/md16/lg24/full9999), `shadow` (`FFShadows`: sm/md/lg/xl — BoxShadow разной глубины с `#1A000000`).
- **`extension TextStyleHelper on TextStyle { TextStyle override({...}) }`** — центральный хелпер: переопределяет шрифт/цвет/размер/вес/интервалы/decoration, опционально подключает GoogleFonts по имени семейства.

**Гипотеза:** тёмная тема на уровне палитры фактически не реализована (`of()` жёстко отдаёт светлую), хотя в app_state и util есть инфраструктура для ThemeMode — расхождение стоит учитывать.

---

## 7. `flutter_flow_util.dart` — утилиты общего назначения

**Путь:** `/Users/usuario/DEVELOPMENT/mi_r_r_a_dev/lib/flutter_flow/flutter_flow_util.dart`
Barrel-файл: ре-экспортирует `app_state.dart`, `environment_values.dart`, `flutter_flow_model.dart`, `internationalization.dart` (FFLocalizations, kAppLanguages), `nav/nav.dart`, `lat_lng`, `place`, `uploaded_file`, intl, page_transition и др. Импортируется почти везде.

Ключевые API:
- `valueOrDefault<T>` — дефолт для null/пустой строки.
- `dateTimeFormat(format, dateTime, {locale})` — форматирование дат; спец-режим `'relative'` через timeago (locale-messages для en/ru/es + short).
- `launchURL(url)` — открытие ссылки (url_launcher).
- `formatNumber(...)` — форматирование чисел (decimal/percent/scientific/compact/custom, валюта, локаль).
- `getJsonField(response, jsonPath, [isForList])` — извлечение по JSONPath.
- `castToType<T>`, `getWidgetBoundingBox`, `colorFromCssString`.
- Платформа: `isAndroid`, `isiOS`, `isWeb`; брейкпоинты `kBreakpointSmall/Medium/Large`, `isMobileWidth`, `responsiveVisibility(...)`.
- Регэкспы валидации: `kTextValidatorUsernameRegex`, `kTextValidatorEmailRegex`, `kTextValidatorWebsiteRegex`.
- **`setAppLanguage(context, language)`** → `MyApp.of(context).setLocale(...)` (смена языка приложения).
- **`setDarkModeSetting(context, ThemeMode)`** → `MyApp.of(context).setThemeMode(...)`.
- `showSnackbar(context, message, {loading, duration})`.
- `getCurrentRoute(context)`, `getCurrentRouteStack(context)`.
- Множество extension: `DateTimeComparisonOperators` (<,>,<=,>=), `ListDivideExt` (`divide`, `around`, `addToStart/End`, `paddingTopEach`), `IterableExt` (`sortedList`, `mapIndexed`), `ListUniqueExt.unique`, `StatefulWidgetExtensions.safeSetState`, `ColorOpacityExt.applyAlpha`, `FFStringExt` (overflow, capitalization), фильтры `withoutNulls`.
- `fixStatusBarOniOS16AndBelow(context)` — синхронизация статус-бара с яркостью темы (iOS ≤16).

---

## 8. `flutter_flow_widgets.dart` — кнопка и focus-индикатор

**Путь:** `/Users/usuario/DEVELOPMENT/mi_r_r_a_dev/lib/flutter_flow/flutter_flow_widgets.dart`
- **`FFButtonOptions`** — конфиг стиля кнопки (цвета, размеры, паддинги, границы, hover/disabled-состояния, iconSize/iconColor/iconAlignment, borderRadius, elevation, maxLines).
- **`FFButtonWidget` (Stateful)** — основная кнопка приложения. Ключевая деталь: при `showLoadingIndicator=true` `onPressed` оборачивается так, что во время `await onPressed()` кнопка показывает `CircularProgressIndicator` и **блокирует повторные нажатия** (`loading` guard). Рендерится как `ElevatedButton` / `ElevatedButton.icon` / `IconButton` (если только иконка). `AutoSizeText` для текста.
- `_getTextWidth` — измерение ширины текста через `TextPainter`.
- **`FFFocusIndicator` (Stateful)** — обёртка для видимого фокуса (клавиатурная навигация): при фокусе анимирует рамку/паддинг и авто-скроллит виджет в видимую область (keepVisibleAtEnd + keepVisibleAtStart).

---

## 9. `flutter_flow_model.dart` — базовая модель страницы/компонента

**Путь:** `/Users/usuario/DEVELOPMENT/mi_r_r_a_dev/lib/flutter_flow/flutter_flow_model.dart`
- **`abstract class FlutterFlowModel<W extends Widget>`** — базовый класс модели каждой страницы/компонента FlutterFlow. Содержит `initState`/`dispose` (абстрактные), ленивую инициализацию (`_init`/`_isInitialized`), доступ к `widget`/`context`, флаг `disposeOnWidgetDisposal` (true для страниц, false для компонентов), механизм `setOnUpdate`/`updatePage`/`onUpdate` (ре-билд родителя при изменении).
- **`createModel<T>(context, defaultBuilder)`** — берёт модель из Provider или создаёт новую.
- **`wrapWithModel<T>({model, child, updateCallback, updateOnChange})`** — оборачивает компонент в `Provider` и настраивает обновление родителя; выставляет `disposeOnWidgetDisposal=false` (модель компонента диспозится страницей).
- **`FlutterFlowDynamicModels<T>`** — управление коллекцией динамических дочерних моделей (списки): `getModel(key,index)`, `getValues`/`getValueAtIndex`/`getValueForKey`, авто-диспоуз неиспользуемых после кадра.

---

## 10. `revenue_cat_util.dart` — подписки RevenueCat / entitlement

**Путь:** `/Users/usuario/DEVELOPMENT/mi_r_r_a_dev/lib/flutter_flow/revenue_cat_util.dart`
**Назначение:** обёртка над `purchases_flutter`. Глобальные `_offerings`, `_customerInfo`, `_loggedInUid`, `_isConfigured`.

- **`initialize(appStoreKey, playStoreKey, {webKey, debugLogEnabled, loadDataAfterLaunch})`** — конфигурирует Purchases по платформе (iOS/Android/web), грузит offerings/customerInfo. Регистрирует `addCustomerInfoUpdateListener`: проверяет entitlement **`EntitlementMirra'`**; **если он неактивен → `FFAppState().isprouser = false`**. ⚠️ Grant pro здесь НЕ делается (чтобы вход в другой профиль на том же Apple ID не переносил pro на чужой аккаунт) — pro выдаётся per-account из БД.
- **`purchasePackage(String package)` → bool** — покупка пакета из текущего offering; на v9+ возвращает `PurchaseResult`. Отмена (`purchase_cancelled`) не логируется как ошибка.
- `activeEntitlementIds`, `loadOfferings()`, `loadCustomerInfo()`.
- **`isEntitled(entitlementId)` → bool?** — активен ли entitlement (false если RC не сконфигурирован; null при ошибке).
- **`login(String? uid)`** — идентификация в RC; для uid≠null: `Purchases.logIn(uid)` + `setAttributes({'supabase_uid': uid})` (для резолва юзера в webhook'ах бэкенда). Для null — `logOut()`. Пропускает при неизменившемся uid.
- **`restorePurchases()`** — восстановление покупок (на web не нужно).

**Гипотеза (критично для монетизации):** entitlement называется `EntitlementMirra`. Клиент только СНИМАЕТ pro при потере entitlement; выдача pro — на стороне бэкенда/БД. Значит рассинхрон «купил, но не pro» лечится бэкендом/webhook, а не клиентом.

---

## 11. `analytics_service.dart` — Firebase Analytics события

**Путь:** `/Users/usuario/DEVELOPMENT/mi_r_r_a_dev/lib/flutter_flow/analytics_service.dart`
Синглтон `AnalyticsService.instance` над `FirebaseAnalytics`. `observer` подключён к GoRouter (авто-трекинг экранов).

Явные события (имена в Firebase):
- Auth: `trackSignUp`, `trackLogin`, `anon_session_started`, `anon_converted`.
- Анализ: `analysis_started` (source: camera|gallery), `analysis_completed` (image_id, score, product_type), `analysis_failed` (reason).
- Карточка: `card_opened` (source: home|toprated|favorites|board|search), `ingredients_tab_opened`.
- Шеринг: `share_link_tapped`, `share_card_created` (format: story|square).
- Доски: `board_created`, `product_added_to_board`.
- Избранное: `favourite_added`, `favourite_removed`.
- Апгрейд/пейволл: `upgrade_prompt_shown` (trigger), `upgrade_prompt_tapped` (trigger).

Приватный `_log(name, [params])` → `logEvent`. **Полезно для аналитики продукта:** этот файл — реестр всех продуктовых событий и их параметров (в т.ч. `trigger` пейволла, `source` открытия карточки/анализа).

---

## 12. `custom_functions.dart` — кастомные функции

**Путь:** `/Users/usuario/DEVELOPMENT/mi_r_r_a_dev/lib/flutter_flow/custom_functions.dart`
Практически пустой (кроме импортов). Единственная функция:
- **`albumidsToList(List<ImagesAlbumsConnectionRow>?)` → List<String>?** — извлекает не-null `albumId` из списка связей изображение↔альбом.

---

## 13. `upload_data.dart` — выбор медиа и файлов

**Путь:** `/Users/usuario/DEVELOPMENT/mi_r_r_a_dev/lib/flutter_flow/upload_data.dart`
Утилиты выбора изображений/видео/файлов (image_picker, file_picker).
- `allowedFormats` = png, jpeg, mp4, gif.
- Типы: `SelectedFile` (storagePath, filePath, bytes, dimensions, blurHash, originalFilename), `MediaDimensions`, `enum MediaSource {photoGallery, videoGallery, camera}`.
- **`selectMediaWithSourceBottomSheet(...)`** — показывает bottom-sheet «Choose Source» (Галерея/Камера, англ. хардкод-строки) и вызывает `selectMedia`.
- **`selectMedia({...multiImage, includeDimensions, includeBlurHash})`** — берёт фото/видео из камеры/галереи; вычисляет размеры; формирует storagePath (`timestamp.ext`).
- `selectFile`/`selectFiles` (file_picker), `validateFileFormat`, `selectedFilesFromUploadedFiles`, `showUploadMessage`, `getSignatureStoragePath`.

**Нюанс:** строки bottom-sheet («Choose Source», «Gallery», «Camera») захардкожены на английском — не проходят через i18n.

---

## 14. Мелкие виджеты и value-типы

- **`flutter_flow_drop_down.dart`** — `FlutterFlowDropDown<T>` (Stateful): кастомный дропдаун с поиском/множественным выбором, стилизация (fillColor, border, elevation, hint/search hint). Работает через `FormFieldController<T>`.
- **`flutter_flow_icon_button.dart`** — `FlutterFlowIconButton` (Stateful): круглая/прямоугольная icon-кнопка с настройкой цвета/размера/border/hover, поддержка async onPressed.
- **`flutter_flow_toggle_icon.dart`** — `ToggleIcon` (Stateless): иконка-переключатель (onIcon/offIcon по `value`, колбэк `onPressed`). Типично для «избранное/лайк».
- **`flutter_flow_language_selector.dart`** — `FlutterFlowLanguageSelector` (Stateless) + приватный `_LanguagePickerDropdown`: дропдаун выбора языка с флагами (emoji_flag_converter), настройка размеров/цветов/скрытия флагов. Адаптирован из пакета `language_picker` (лицензия в шапке файла).
- **`flutter_flow_animations.dart`** — инфраструктура анимаций поверх `flutter_animate`: `enum AnimationTrigger {onPageLoad, onActionTrigger}`, `AnimationInfo` (триггер, effectsBuilder, loop/reverse, controller), `createAnimation`/`setupAnimations`, extension `animateOnPageLoad`/`animateOnActionTrigger`, кастомный `TiltEffect` (3D-наклон через Matrix4).
- **`form_field_controller.dart`** — `FormFieldController<T> extends ValueNotifier<T?>` (`reset`/`update`) и `FormListFieldController<T>` (безопасная копия начального списка для multiselect).
- **`lat_lng.dart`** — `LatLng(latitude, longitude)` с `serialize()`/`==`/`hashCode`.
- **`place.dart`** — `FFPlace` (latLng, name, address, city, state, country, zipCode).
- **`uploaded_file.dart`** — `FFUploadedFile` (name, bytes, height, width, blurHash, originalFilename) с `serialize()`/`deserialize()`.
- **`random_data_util.dart`** — генераторы тестовых данных: `randomInteger`, `randomDouble`, `randomString`, `randomDate`, `randomImageUrl` (picsum), `randomColor`.

---

## Сводка для гипотез (самое важное)

1. **Флаги гейтинга** (все в `app_state.dart`): онбординг кожи (`onboardingDone`, буфер `ob*`, `obStep`), онбординг косметички (`bagOnboardingDone`, `bagOnboardingActive`, `bagScanCount`, `pendingBagSlot`), домашний пайплайн (`homePipelineDoneUsers` per-user), PRO (`isprouser` — сессионный, из БД), лимиты (`freeScanLimit`, `analysesused`, `weekResetDate`), фидбэк-коллектор (`feedback*`), `showLinkTelegram`.
2. **Навигация новичка** целиком в корневом роуте `/` и `errorBuilder` (`nav.dart`): loading → splash; loggedIn → Home; иначе `onboardingDone ? Newblank : OnboardingQuiz`. `requireAuth`-роуты редиректят на `/Splash`.
3. **PRO/монетизация**: entitlement `EntitlementMirra`; клиент только снимает pro, выдаёт бэкенд per-account (защита от переноса подписки между профилями одного Apple ID).
4. **Уведомления**: push с `image_id` → карточка продукта (в foreground сразу навигирует); локальные напоминания рутины (weekly, payload `routine` → RoutineCalendar); токены в Supabase-таблице `device_tokens`.
5. **Тема**: `FlutterFlowTheme.of()` всегда возвращает светлую палитру — тёмная тема на уровне палитры не реализована, несмотря на `darkModeSet`/`setDarkModeSetting`.


---

# Компоненты (lib/components/)

Директория переиспользуемых виджетов приложения Mirra (сканер/анализ косметики). 53 файла (~10 292 строк). Многие компоненты — пары `xxx_widget.dart` + `xxx_model.dart` (по паттерну FlutterFlow: модель хранит контроллеры/фокусы/результаты бэкенд-вызовов, вызывается через `createModel`, освобождается в `dispose` через `_model.maybeDispose()`). Часть новых компонентов написана вручную (без модели): `home_pipeline`, `product_card_v2`, `ingredient_bubbles`, `score_breakdown`, `guest_prefs_sheet`, `link_telegram_sheet`, `feedback_collector`, `error_popup`, `profile_summary_card`.

Общие замечания по гипотезам:
- Тексты в основном берутся через `FFLocalizations.of(context).getText('<ключ>')` — локализация на 11 языков. Некоторые компоненты содержат **хардкод-строки** (RU/EN) — отмечено отдельно (это баги локализации / точки для гипотез).
- Гейтинг Pro в основном определяется флагом `FFAppState().isprouser` (передаётся снаружи в `product_card_v2` как `isPro`).
- Навигация — через `context.pushNamed`/`goNamed` с `routeName` страниц из `/index.dart`.

---

## navbar/ — нижняя навигация (главный компонент)

### `navbar/navbar_widget.dart` (305 строк)
Кастомный «плавающий» нижний навбар со стеклянным (frosted-glass) фоном и центральной FAB-кнопкой сканирования.

- **Параметры:** `activePage` (int? — id активной вкладки), `analysesused` (int? — **передаётся, но в build нигде не используется**; вероятно легаси), `onScrollToTop` (VoidCallback? — вызывается при тапе по иконке уже активной страницы).
- **Класс `_NavbarWidgetState`** (TickerProviderStateMixin): в `initState` регистрирует анимацию `containerOnPageLoadAnimation` — «покачивание» (Rotate+Move) FAB-кнопки, стартующее с задержкой ~3 сек после загрузки (привлечение внимания к скану).
- **`_buildTab({pageId, iconData, activeIconData, label, routeName})`:** строит вкладку. Активная вкладка красится в `theme.primary`, неактивная — `0xFF2C2C2E`. У активной иконки может быть отдельная «заполненная» версия (`activeIconData`). Тап: `HapticFeedback.lightImpact()`; если вкладка уже активна → `onScrollToTop?.call()`, иначе → `_goFade(routeName)`.
- **`_goFade(routeName)`:** `context.goNamed` с мгновенным (`duration: 0 ms`) fade-переходом — переключение вкладок без анимации.
- **Вкладки (слева направо):**
  1. pageId=2 — Home (`Icons.home`) → `HomeWidget.routeName`, метка `kndykt66` (Home).
  2. pageId=1 — Explore (`Icons.search`) → `TopratedWidget.routeName`, метка `f0lv5sbb` (Explore).
  3. центральный зазор (пустой Expanded под FAB).
  4. pageId=3 — Косметичка (`Icons.spa`) → `CosmeticBagWidget.routeName`, метка `cb_bag_title`.
  5. pageId=4 — Рутина/календарь (`Icons.calendar`) → `RoutineCalendarWidget.routeName`, метка `cb_routine_title`.
- **Центральная FAB (скан):** круглая, `theme.primary`, иконка `Icons.auto_awesome_rounded`. Тап → `context.pushNamed(TakeorUploadPageWidget.routeName)` с мгновенным fade. Это основная точка входа в сканирование.
- **Детали для гипотез:** фон — `BackdropFilter blur 18`, полупрозрачный (в тёмной теме `black 0.42`, в светлой `white 0.72`). Никакого гейтинга/чтения FFAppState внутри — навбар чисто навигационный.

### `navbar/navbar_model.dart` — пустая модель (только `initState`/`dispose`-заглушки).

---

## home_pipeline_widget.dart (205 строк) — онбординговый чек-лист на Home

`HomePipelineWidget` — карточка «попробуй все функции»: 3 шага, подсвечивающиеся по мере выполнения. **Скрывается навсегда**, как только пользователь один раз выполнил все три.

- **Состояние:** `_loading`, `_step1/2/3` (готовность шагов), `_dismissed` (пользователь уже завершал все 3).
- **`_load()` (initState → postFrame):** источник истины — данные пользователя из БД, а не локальные флаги (чтобы новый/анонимный пользователь не унаследовал «выполнено»):
  - `step1` = у пользователя (`UsersTable`, по `currentUserUid`) задан `skinType` (непустой) — т.е. пройден квиз кожи.
  - `step2` = `CosmeticBagService.instance.getSlots()` содержит **≥3 слота с `imageId != null`** (добавлено ≥3 продукта в косметичку).
  - `step3` = `RoutineService.instance.getEvents()` непусто (есть события рутины).
  - Все вызовы в `try/catch` без обработки (при ошибке шаги = false).
  - Если все 3 выполнены и uid непустой → добавляет uid в `FFAppState().homePipelineDoneUsers` (список), ставит `dismissed=true`. **Это персистентное per-user-id запоминание**: пайплайн остаётся скрытым, даже если потом удалить продукты/рутину.
- **`_go(routeName)`:** haptic → `pushNamed` → по возврату повторный `_load()` (обновить галочки).
- **build:** возвращает `SizedBox.shrink()` (скрыто) если `_loading` ИЛИ `_dismissed` ИЛИ все три готовы. Иначе — белая карточка с заголовком `hp_title` и тремя `_StepRow`.
- **Шаги (`_StepRow`) и куда ведут:**
  1. `hp_step1` → `OnboardingQuizWidget.routeName` (квиз кожи).
  2. `hp_step2` → `CosmeticBagWidget.routeName` (косметичка).
  3. `hp_step3` → `RoutineCalendarWidget.routeName` (рутина).
- **`_StepRow`:** кружок с номером/галочкой, при `done` — текст зачёркнут (`lineThrough`), серый; при не-done — стрелка `chevron_right`. Цвет = `theme.primary`.
- **Детали для гипотез:** фон карточки жёстко белый (`Colors.white`), текст чёрный — **не адаптируется к тёмной теме**. Порог косметички именно ≥3 продукта.

---

## product_card_v2/ — главная карточка результата анализа (883 строки)

### `product_card_v2/product_card_v2_widget.dart`
`ProductCardV2Widget` — «answer-first» карточка результата: начинается с вердикта («подходит ли мне?»), опирается на матрицу совместимости по типам кожи. Нет `_model`, все данные приходят параметрами; **сетевых вызовов при взаимодействии нет**.

- **Параметры:** `image` (`ImagesRow` — сам анализ), `skinCompatibility` (`List<ImageSkinCompatibilityRow>`), `topIngredients` (`List<ImageTopIngredientsRow>`), `ingredientIssues` (`List<ImageIngredientIssuesRow>`), `userSkinType` (String? — из онбординга, null = cold start), `userIsSensitive`, `userIsAcneProne` (флаги из онбординга), `isPro` (bool — виден ли Pro-слой).
- **Состояние:** `_selectedSkinType` (эфемерный контекст просмотра, стартует из профиля), `_proExpanded`, `_userTouchedMatrix` (после ручного тапа по матрице профиль не переопределяет выбор — **онбординг = дефолт cold start, тапы эфемерны и локальны, в профиль никогда не пишутся**).
- **`didUpdateWidget`:** если `userSkinType` пришёл асинхронно позже и пользователь ещё не трогал матрицу — принять его как контекст.
- **Цвета (brightness-aware):** `_goodColor`/`_warnColor`/`_badColor` имеют светлые варианты в тёмной теме. `_fitColor(score)`: ≥75 good, ≥60 warn, иначе bad.
- **`_statusColor(status)`:** working→good, borderline→warn, decorative/иначе→secondaryText.
- **`_visibleWarnings`:** из `ingredientIssues` берёт только с непустым `relevantFor` (пустой = информационное, только в Pro-слое). При cold start (нет типа) — показывает все. Иначе фильтр: `relevantFor` содержит 'all', выбранный тип, либо (при `userIsSensitive`) 'sensitive', либо (при `userIsAcneProne`) 'acne_prone'.

**Блоки build (по порядку):**
1. **`_buildVerdict`** — карточка с анимированным кольцом-«fit»:
   - Текст вердикта: у выбранной строки `row.verdict`, иначе `image.saQuickSummary`.
   - Число fit: `row.compatibilityScore` либо `image.saCompositeScore.round()` (0 по умолчанию).
   - Метка: `cardv2_for_you` (если строка выбрана) / `cardv2_formula` (общая оценка формулы).
   - `CircularPercentIndicator` перерисовывается при каждом тапе по матрице (`animateFromLastPercent`).
2. **`_buildMatrix`** — тапабельная матрица типов кожи (скрыта если `skinCompatibility` пуст). Строки сортируются по убыванию `compatibilityScore`. Тап по строке: эфемерно переключает `_selectedSkinType` (повторный тап по выбранной — сброс в null), ставит `_userTouchedMatrix=true`. Показывает название типа (`skin_<type>`), `LinearPercentIndicator` и число.
3. **`_buildActives`** («что реально работает») — только если `topIngredients` непуст. **Freemium-гейтинг:** free-пользователь видит первые 3 актива (`take(3)`), Pro — все. Скрытые не блюрятся, а полностью прячутся; вместо них ссылка `+N cardv2_more_in_pro` → тап `pushNamed(PaywallpageWidget.routeName)`. У каждого актива «светофор» (`_statusColor`), подпись: для `decorative` — `статус · cardv2_trace_position` (без концентрации), иначе `~<conc> — статус`. Плюс описание ингредиента, если есть.
4. **`IngredientBubblesWidget`** — пузырьковая визуализация (см. ниже), если есть активы.
5. **`_buildWarnings`** — если `_visibleWarnings` непуст. **Предупреждения безопасности НЕ пейволятся:** имя ингредиента и адресаты видны всем; только текстовое `description` показывается лишь в Pro (`showDescription = isPro && description непустой`). Иконка `warning_amber`, цвет по `severity=='high'` → bad, иначе warn. Адресаты: если 'all' → `cardv2_for_all`, иначе список меток типов.
6. **`_buildClaimAudit`** («обещания на упаковке») — из `image.saClaimAudit` (List of Map). Для каждого claim: метка `cardv2_claim_<key>`, вердикт `cardv2_verdict_<verdict>` цветом: supported→good, weak→warn, иначе→bad (по умолчанию 'unsupported').
7. **`_buildProLayer`** — только если `isPro`. Раскрывается по тапу (`_proExpanded`). Содержит:
   - **Композиция с 1%-линией:** `_inciList` (предпочитает `image.saInciList`, иначе client-split `image.ingredients` regex, не ломая «1,2-Hexanediol»). Разделитель на позиции `saOnePercentLinePos` с маркером `saOnePercentLineMarker`. Ингредиенты после линии — серым.
   - **Evidence vs MEC:** активы с `status!=null || mec!=null`, показывает `~conc · ≥mec% · статус`.
   - **Информационные issues** (`relevantFor` пуст) — с иконкой info.
   - **Честная уверенность (`saConfidence`):** уровень (`cardv2_conf_<level>`, дефолт 'medium'), `composite_range` (диапазон), список `reasons`.
- **Детали для гипотез:** ключевые числа фильтрации — free видит 3 актива; пороги fit 75/60; матрица никогда не меняет профиль; предупреждения безопасности всегда видны бесплатно, но их объяснение — только Pro.

*(Модели `_model.dart` у product_card_v2 нет.)*

---

## ingredient_bubbles/ingredient_bubbles_widget.dart (415 строк) — пузырьковая визуализация ингредиентов

`IngredientBubblesWidget` — анимированное «облако» пузырьков ингредиентов на CustomPaint, встроенное внутрь product_card_v2.

- **Параметры:** `ingredients` (`List<ImageTopIngredientsRow>`), `height` (по умолчанию 340; в product_card_v2 используется дефолт).
- **Цветовая палитра по dose-status (ХАРДКОД, отличается от product_card_v2!):** working=amber `FFB300`, borderline=steel `78909C`, decorative=muted `90A4AE`, unknown=grey `BDBDBD`.
- **`_statusLabel` — ХАРДКОД на русском:** working→«работает», borderline→«на грани MEC», decorative→«декоративный». **Это точка для гипотез — не локализовано.**
- **`_parseConc`:** парсит «~2%»/«2-5%»/«5%» в среднее число 0..100.
- **`_layout()` (в `didChangeDependencies` и `didUpdateWidget`):** берёт **до 18** ингредиентов. Радиус пузырька: базово по концентрации (клемп 16..52), working ×1.15. Раскладка по золотому углу (`goldenAngle`), sqrt-распределение (крупные — в центре). Позиции с фиксированным seed `Random(42)` — детерминированы.
- **Анимация:** `AnimationController` 60 сек `repeat()`, каждый пузырёк дрейфует по синусоиде.
- **`_onTap(local)`:** hit-test по расстоянию до пузырька; тап показывает/скрывает tooltip (`_tapped`).
- **`_BubblePainter`:** рисует свечение, полупрозрачный радиальный градиент, границу, блик, и подпись (первое слово имени) внутри пузырька если `radius >= 22`.
- **`_Tooltip`:** белая плашка с именем, точкой статуса, `_statusLabel` и `~conc%`. Позиционируется над пузырьком с защитой от выхода за границы.

---

## score_breakdown/score_breakdown_widget.dart (472 строки) — радар-диаграмма оценки

`ScoreBreakdownWidget` (StatelessWidget) — 5-осевой радар (radar chart) на CustomPaint, визуализирующий разбивку композитной оценки.

- **Параметры:** `scoringLog` (dynamic — JSON-Map с осями), `topIngredients`, `ingredientIssues`, `inciList` (List<String> в порядке позиций — для поиска issue), `onePercentLinePos` (int?).
- **build:** если `scoringLog==null` или не Map → `SizedBox.shrink()`.
- **Оси (5, по часовой с верха):** Safety (`dim_safety`), Efficacy (`dim_efficacy`), Stability (`dim_stability`), Non-Comedogenic (`dim_pore_safety`←`comedogenicity`), Experience (`dim_experience`←`user_experience`). Значения через `_axisScore(log[...])`.
- **Точки-ингредиенты:**
  - **Активы (на оси Efficacy):** позиция = `inciPosition`, цвет по `status` (working=зелёный `2E7D32` filled, borderline=`F9A825` filled, decorative=`9E9E9E` hollow), радиус растёт от `efficacyContribution`.
  - **Issues (на оси Safety):** позиция ищется по имени в `inciList`, размер/цвет по `severity=='high'`.
- **`_RadarPainter`:** сетка-кольца, оси, полигон оценки (синий `3B6FCC`), пунктирное кольцо 1%-линии (по `onePercentPos` и `totalInci`), точки, подписи осей со значениями.
- **`_RadarLegend`:** легенда (score / working / borderline / trace / issue / 1%-линия) с локализованными ключами `radar_*`.
- **Детали для гипотез:** цвета «working» здесь ЗЕЛЁНЫЙ, а в ingredient_bubbles — АМБЕР. Фон карточки жёстко светло-голубой `F5F8FF` — не адаптируется к тёмной теме. `_drawCentered` объявлен, но не используется (мёртвый код).

---

## guest_prefs_sheet/guest_prefs_sheet_widget.dart (234 строки) — bottom sheet первичной настройки

`GuestPrefsSheet` — bottom-sheet, показываемый сразу после анонимного входа, чтобы собрать страну и язык перед первым сканом.

- **Состояние:** `_lang` (дефолт 'en'), `_countryId`, `_saving`.
- **initState (postFrame):** если язык приложения есть в `kAppLanguages` — ставит его дефолтом дропдауна.
- **`_save()` (кнопка «Continue»):** **ключевая логика — анонимный пользователь создаётся ТОЛЬКО здесь, по явному тапу:**
  1. `AppStateNotifier.instance.updateNotifyOnAuthChange(false)`.
  2. `authManager.signInAnonymously(context)` — если null (ошибка), остаётся на sheet.
  3. `AnalyticsService.instance.trackAnonSessionStarted()` (unawaited).
  4. `setAppLanguage(context, _lang)`.
  5. `UsersTable().update`: пишет `language_code` и (если выбрана) `country_id` по `currentUserUid`.
  6. В `finally` — `Navigator.pop(true)`.
- **`_t(en, ru, es, [de])` — ХАРДКОД мультиязычных строк** (заголовки/кнопки) прямо в коде, т.к. локаль ещё не применена. Порядок: ru/es/de/en. **Точка для гипотез: строки этого sheet не в общей системе локализации.**
- **UI:** заголовок «Quick setup», дропдаун языка из `kAppLanguages` (флаг + nativeName), `CountryselectorWidget` (с передачей `_lang` для мгновенного обновления меток), кнопка Continue (спиннер при `_saving`).
- **Детали для гипотез:** фон жёстко белый; поддержка 'de' в `_t`, хотя fallback на en. Страна сохраняется только при выбранной; язык — всегда.

---

## countryselector/countryselector_widget.dart (216 строк)

`CountryselectorWidget` — дропдаун выбора страны с поиском (`FlutterFlowDropDown`), опционально пишет в БД.

- **Параметры:** `languageCode` (переопределяет локаль для меток стран — для preview до применения локали), набор стилевых override (`fillColor`/`textColor`/`iconColor`/`textSize`/`borderRadius`/`borderColor`/`borderWidth`/`elevation` — для светлого sheet), `onCountrySelected` (callback).
- **`_loadData()`:** параллельно грузит `CountriesTable` и (если uid непустой) `UsersTable` — возвращает `(список стран, текущий country_id пользователя)`.
- **build (FutureBuilder):** при ошибке — «Tap to retry» (повторная загрузка); при загрузке — спиннер.
- **`optionLabels`:** по языку — `nameRu`/`nameEs`/`nameEn` (**для остальных языков (de, fr, ...) — fallback на английский**).
- **`onChanged`:** ставит локальное значение, вызывает `onCountrySelected`; **если uid пустой (нет сессии) — запись в БД пропускается** (ответственность на вызывающем — сохранить после входа); иначе `UsersTable().update` `country_id`.
- **hintText/searchHintText:** при `languageCode==null` — из локализации, иначе из `kTranslationsMap` по коду с fallback на en/строку.

### `countryselector/countryselector_model.dart` — хранит `dropDownValue` (int?) и `dropDownValueController` (FormFieldController).

---

## link_telegram_sheet/link_telegram_sheet_widget.dart (243 строки)

`LinkTelegramSheet` — bottom-sheet для привязки Telegram-аккаунта. Пользователь вставляет код (или deep-link) от бота, он погашается через edge-функцию `link-telegram`.

- **`_botName` = `@Mirra_app_bot`** (хардкод). **`_BotNameChip`** — чип с именем бота, тап копирует в буфер (`Clipboard`), на 2 сек показывает галочку.
- **`_submit()`:** обильное `debugPrint`-логирование (диагностика). Если код пуст или уже отправляется — выход. Вызывает `LinkTelegramCall.call(token: currentJwtToken, code: code)`. Успех = `response.succeeded && LinkTelegramCall.ok(...)`; тогда `pop` + тост `lt_linked`. Иначе тост по `errorCode`: 'expired'→`lt_code_expired`, 'invalid_code'→`lt_invalid_code`, иначе `lt_could_not_link`.
- **UI:** заголовок `cm_link_telegram`, инструкция `lt_instructions`, чип бота, TextField для кода (submit по Enter), кнопка `lt_link_btn` (спиннер при `_submitting`).
- **Детали для гипотез:** фон белый; использует `currentJwtToken` — при пустом токене привязка не пройдёт (логируется).

---

## feedback_collector/ — сбор отзывов / App Store rating (3 файла)

### `feedback_collector/feedback_service.dart` (57 строк) — логика показа промпта
- **`shouldShowPrompt(state)`:** возвращает true если:
  - `feedbackCollectorEnabled` (иначе false),
  - платформа **iOS** (иначе false),
  - (после `_resetIfUserChanged`) не `feedbackReviewSubmitted`,
  - если `feedbackBannerDismissed` — показать только при смене версии приложения (`feedbackLastShownVersion != version`),
  - **новый пользователь** (`feedbackLastShownMs==0`) → показать сразу (после первого скана),
  - **вернувшийся** → cooldown **14 дней** от последнего показа.
- **`_resetIfUserChanged`:** при смене `currentUserUid` сбрасывает per-user флаги feedback (submitted/dismissed/lastShownMs/version).
- **`recordShown(state)`:** пишет текущее время и версию.
- **Детали для гипотез:** промпт только на iOS; порог 14 дней; сбрасывается при смене пользователя на устройстве.

### `feedback_collector/feedback_collector_widget.dart` (255 строк) — диалог
`FeedbackCollectorWidget` (Stateless) — диалог «нравится ли приложение?» с градиентным хедером, звездой ✨, заголовком `fc_title`/`fc_subtitle`.
- **Кнопка «Да» (`fc_btn_positive`):** `FirebaseAnalytics` event `feedback_positive`, ставит `feedbackReviewSubmitted=true`, версию; `InAppReview.requestReview()` (может быть проигнорирован iOS-квотами) + `openStoreListing(appStoreId: '6745415201')`; pop.
- **Кнопка «Нет» (`fc_btn_negative`):** event `feedback_negative`, `feedbackBannerDismissed=true`, версию; pop и открывает `NegativeFeedbackWidget` в модальном sheet.
- **`_dismiss`:** объявлен, но по факту dismiss делают кнопки.
- **Деталь:** appStoreId `6745415201` хардкод. Комментарии в коде на русском («Да, круто»/«Нет, не очень»).

### `feedback_collector/negative_feedback_widget.dart` (269 строк) — форма негативного отзыва
`NegativeFeedbackWidget` (Stateful) — bottom-sheet: поле комментария (обязательное, до 1000 симв., валидатор `fc_neg_validator`) + email (опционально). Отслеживает видимость клавиатуры (`flutter_keyboard_visibility`) — кнопка скрывается при открытой клавиатуре.
- **Submit:** валидация → email = введённый или `currentUserEmail` → `TelegrammessegeCall.call(messega, email)` → analytics `feedback_submitted` → pop. Тексты `fc_neg_*`.

---

## paywall_confirmation/paywall_confirmation_widget.dart (467 строк) — «Welcome to Pro»

`PaywallConfirmationWidget` — bottom-sheet-подтверждение успешной подписки Pro. Каскадные onPageLoad-анимации (fade элементов с нарастающими задержками).
- **Контент:** бейдж PRO, заголовок `mcrnylah` («Welcome to M!RRA Pro»), 4 фичи с иконками: `l13naqtt` (200 запросов аналитики/мес), `8slgbpit` (Save to collections), `nyi1gh42` (Share your finds), `nzvzb6kk` (High-rated formulas).
- **Кнопка `ccikm8kx` («Let's go!»):** просто `Navigator.pop(context)`. **Нет логики покупки — только празднование пост-факт.**
- **Деталь для гипотез:** «200 analytics requests per month» — жёстко в тексте (см. также реальный лимит Pro).

### `paywall_confirmation/paywall_confirmation_model.dart` — пустая модель.

---

## premium_features_list/premium_features_list_widget.dart (390 строк)

`PremiumFeaturesListWidget` — статический список из 8 премиум-фич (иконка в круге + текст, белый текст на `theme.primary`). Используется на пейволле.
- Ключи фич: `ic2_pro_unlimited`, `8xm0tarf` (Full scientific analysis), `inci_full_list`, `pm4r9x2w` (Keep scans private, иконка eyeSlash), `ic2_pro_howto`, `ic2_pro_skin`, `ic2_pro_actives`, `ic2_pro_notes`.
- Логики/навигации нет — чистый презентационный.

### `premium_features_list/premium_features_list_model.dart` — пустая модель.

---

## out_of_generations/out_of_generations_widget.dart (197 строк) — «лимит исчерпан»

`OutOfGenerationsWidget` — bottom-sheet при достижении лимита сканов.
- initState: `HapticFeedback.vibrate()` (вибрация при показе). Анимации fade заголовка/кнопки.
- Иконка `error_outline`, заголовок `1zkc5y9j` («Limit reached»), текст `1egcc9to`.
- **Кнопка `enziwu64` («Got it»):** `pushNamed(PaywallpageWidget.routeName)` затем `Navigator.pop`. Ведёт на пейволл.

### model — пустая.

---

## delete_confirmation/delete_confirmation_widget.dart (225 строк) — удаление аккаунта

`DeleteConfirmationWidget` — bottom-sheet подтверждения удаления аккаунта.
- Заголовок `4latue44`, текст `9fm4u5g5`.
- **Кнопка «Delete account» (`qh4oraql`):** вызывает `DeleteUserNEWBCNDCall.call(host: FFDevEnvironmentValues().backendhost, userId: currentUserUid, token: currentJwtToken)`. При успехе (`succeeded ?? true`):
  - `FFAppState().isprouser=false`, `analysesused=0`, `weekResetDate=null`;
  - `SharedPreferences`: удаляет `hint_upload_seen`, `pro_preview_used`;
  - `revenue_cat.login(null)` (сброс RevenueCat);
  - `prepareAuthEvent()` → `authManager.signOut()` → `clearRedirectLocation()`;
  - `pushNamedAuth(NewblankWidget.routeName)`.
  - При неудаче — AlertDialog «ups! / something went wrong!» (**хардкод EN, без локализации**).
- **Кнопка «Cancel» (`9lehmzbk`):** pop.
- **Детали для гипотез:** очищаются именно эти флаги/prefs — важно для сценариев повторного онбординга/пробного Pro.

### model — хранит `deleteuseranswer` (ApiCallResponse?).

---

## leave_review/leave_review_widget.dart (296 строк) — форма отзыва (в Telegram)

`LeaveReviewWidget` — bottom-sheet «Leave your review» (общая форма обратной связи, не App Store).
- Отслеживает клавиатуру (`flutter_keyboard_visibility`), кнопка скрывается при её появлении.
- Поле (autofocus, до 1000 симв.). Заголовок `9g2qcen7`, подзаголовок `is69hoea`, hint `etqk72qg`.
- **Кнопка «Send» (`0n0273ug`):** валидация формы → `TelegrammessegeCall.call(messega: текст, email: currentUserEmail)` → pop. Отправляет отзыв в Telegram через API.
- Тап по затемнённому фону — pop.

### `leave_review/leave_review_model.dart` — formKey + folderTitle контроллер/фокус/валидатор.

---

## new_album/new_album_widget.dart (277 строк) — создание доски/альбома

`NewAlbumWidget` — bottom-sheet создания новой «доски» (коллекции).
- Поле имени (autofocus, capitalization words). Заголовок `3k3xtikh`, подзаголовок `l4d5m49x`, hint `azcd4b5c`.
- **Кнопка «Create» (`h68noqox`):** валидация → `AlbumTable().insert({name, user: currentUserUid, cover: <depositphotos placeholder URL>})` → `AnalyticsService.instance.trackBoardCreated()` (unawaited) → pop.
- **Кнопка «Cancel» (`sw4zsxbk`):** pop.
- **Деталь:** обложка альбома по умолчанию — внешний placeholder-URL depositphotos (хардкод).

### `new_album/new_album_model.dart` — formKey + albumname контроллер; **валидатор: имя обязательно** (`5t47wlr7` "Title is required."). Хранит результат `album` (AlbumRow?).

---

## share_card_sheet_widget.dart (260 строк) — выбор формата шеринг-карточки

`ShareCardSheetWidget` — bottom-sheet генерации карточки продукта для шеринга.
- **Параметр:** `imageid` (int?).
- build: `FutureBuilder` грузит `ImagesTable` по id (спиннер при загрузке). Заголовок `a1bpjvs8` (**хардкод-русский в комментарии-ключе: «Выберите формат…»**).
- **Переключатель формата:** две кнопки — «Сториз» (`himmmtup`, `_model.isStory=true`) и «Квадрат» (`k2ruyzeg`, false). Активный чёрный `1A1A1D`, неактивный серый `AFAFB0`.
- Рендерит `custom_widgets.ShareCardWidget` с данными продукта: `productName`/`brand`/`imageUrl` (с дефолтами-плейсхолдерами), `saCompositeScore`/`saSafetyScore`/`saEfficacyScore` (дефолт 0), `isStory`, `skinTypeTags`.
- **Деталь:** `containerImagesRow!` — force-unwrap; при отсутствии строки может упасть (но выше проверка `hasData`, не пустоты списка — потенциальный edge-case).

### `share_card_sheet_model.dart` — хранит `isStory` (bool, дефолт true).

---

## profile_summary_card.dart (192 строки) — карточка «Твой профиль» в косметичке

`ProfileSummaryCard` (Stateless) — карточка сводки профиля кожи из онбординга (в косметичке).
- **Экспортирует `glowCardDecoration(theme)`** — общая «outline + glow» декорация (переиспользуется другими карточками косметички для единого вида).
- **Параметр:** `profileRow` (`UsersRow?`).
- `hasProfile` = `skinType` непустой. Тап по всей карточке → `OnboardingQuizWidget.routeName` (повторно открыть квиз).
- **`_ctaView`** (нет профиля): иконка + `home_profile_cta_title`/`home_profile_cta_sub` + стрелка (призыв пройти онбординг).
- **`_profileView`** (есть профиль): чипы — тип кожи (`_typeKeys`: dry/oily/combination/normal→`obq_type_*`), + `obq_flag_sensitive` (если `skinSensitivity==true`), + `obq_flag_acne` (если `acneProne==true`). Цели (`skinGoals`) через `_goalKeys` (hydration/barrier/anti_aging/pigmentation/acne/pores→`obq_goal_*`), с префиксом `obq_result_goals_prefix`. Заголовок `home_profile_title`, ссылка `home_profile_edit`.
- **Детали для гипотез:** источник профиля — колонки `UsersRow` (skinType, skinSensitivity, acneProne, skinGoals). Фон карточки белый (жёстко).

---

## error_popup/error_popup_widget.dart (374 строки) — универсальный error-диалог

`ErrorPopupWidget` (Stateless) — типизированный error-диалог.
- **enum `ErrorPopupType`:** `productNotFound`, `ingredientsNotFound`, `subscriptionSync`, `unsupported`, `generic`.
- **`show(context, type)`** (static) — показывает диалог.
- **`showIngredientInput(context)`** (static) → `Future<String?>` — показывает `_IngredientsInputDialog` (ручной ввод ингредиентов).
- **`_config(type)`:** для каждого типа — иконка/цвет/заголовок/текст (ключи `err_*`, у `unsupported` — `nnsq0kj5`/`48je50c9`). Кнопка ОК (`err_ok_btn`) → pop.
- **`_IngredientsInputDialog`** (Stateful): для случая «ингредиенты не распознаны». Раскрывающееся (`_expanded`) поле ручного ввода INCI (до 5 строк). При наличии текста — кнопка «Анализировать» (**хардкод RU!**) → `pop(текст)`; иначе кнопка «Закрыть»/OK → `pop(null)`. Hint «Water, Glycerin, Niacinamide...» (хардкод).
- **Детали для гипотез:** возвращаемая строка ингредиентов используется вызывающим для повторного анализа. «Анализировать»/«Закрыть» не локализованы.

---

## Скелетоны загрузки (shimmer/fade-плейсхолдеры)

Набор чисто презентационных компонентов с зацикленной fade-анимацией (`FadeEffect loop reverse`) для состояния загрузки. Логики/навигации/FFAppState нет. Все имеют пустые `_model`.

- **`album_list_loading_component/…_widget.dart` (1207 строк!):** сетка 2×N карточек-альбомов, каждая с внутренней сеткой 2×2 плейсхолдеров. **32 отдельные анимации** (`containerOnPageLoadAnimation1..32`) с волной задержек 0/100/200/300 мс. Огромный объём из-за развёрнутого копипаста FlutterFlow (не цикл).
- **`blank_album/…_widget.dart` (351):** `MasonryGridView` 8 плейсхолдеров (opacity 0.4) + по центру текст `1s4tdpvq` («Empty album...»). 8 анимаций.
- **`no_images/…_widget.dart` (337):** аналог blank_album без текста (только сетка masonry, 8 плейсхолдеров, borderRadius 16). 8 анимаций.
- **`loading_styles/…_widget.dart` (440):** горизонтальный скролл-ряд из 4 карточек-«стилей» (превью+подпись). 8 анимаций.
- **`loading_recent/…_widget.dart` (237):** сетка 3×2 (6 квадратов) — скелетон «недавних». 6 анимаций.
- **`gallery_loading_component/…_widget.dart` (193):** одна карточка с внутренней сеткой 2×2. 4 анимации.
- **`gallery_image_loading_component/…_widget.dart` (179):** сетка 2×2 плейсхолдеров (borderRadius 16). 4 анимации.
- **`empty_gallery_with_animation/…_widget.dart` (202):** сетка 2×2 (opacity 0.3) с fade-анимацией. 4 анимации.
- **`empty_gallery/…_widget.dart` (132):** сетка 2×2 (opacity 0.3) **без анимации** (статичный вариант).

---

## Прочие мелкие компоненты

- **`nounsorteditems_widget.dart` (79):** плашка «There are no products yet» (`gzohwfxg`), рамка + текст цветом `primary`. Пустая модель.
- **`light_dark_toggle/light_dark_toggle_widget.dart` (67):** переключатель тёмной/светлой темы (иконки dark_mode/light_mode + `Switch.adaptive`). **`switchValue` инициализируется `true`, но `onChanged` только меняет локальное состояние — реальной смены темы приложения НЕТ** (заглушка/декоративный). Точка для гипотез: тоггл не подключён к смене темы.

---

## analysis_loading/analysis_loading_widget.dart (335 строк) — полноэкранный лоадер анализа

`AnalysisLoadingWidget` — полноэкранный экран во время анализа продукта.
- **Ротация фактов:** 25 ключей `al_fact_1..25`, стартовый индекс случайный, `Timer.periodic(5 сек)` циклически меняет факт (`al_did_you_know` + сам факт с fade-переходом).
- **Шаги:** 3 ключа `al_step_1..3`. Прогресс читается из `FFAppState().Producanalysstate` (через `context.watch<FFAppState>()`): `isDone = currentStep > stepNum`, `isActive = currentStep == stepNum`. `_StepIcon` рисует галочку (done) / крутящийся спиннер (active) / пустой кружок.
- **Верх:** полноэкранное фото `FFAppState().uploudedimagepath` (55% высоты) с градиентом; поверх — `extractedBrand` + `extractedProductName` (из FFAppState), появляются через AnimatedSwitcher когда имя извлечено.
- **Детали для гипотез:** прогресс-стейт (`Producanalysstate`) и извлечённые имя/бренд продукта живут в FFAppState и обновляются во время бэкенд-анализа. Факты — 25 штук, ротация 5 сек.

### `analysis_loading/analysis_loading_model.dart` — хранит `factIndex` (int).

---

## Сводка моделей (`_model.dart`)

Пустые/заглушки: album_list_loading, blank_album, empty_gallery(+with_animation), gallery_loading, gallery_image_loading, loading_recent, loading_styles, navbar, no_images, nounsorteditems, out_of_generations, paywall_confirmation, premium_features_list.

С полями: analysis_loading (`factIndex`), countryselector (`dropDownValue`, controller), delete_confirmation (`deleteuseranswer`), leave_review (form + text controller/validator), new_album (form + validator + `album`), light_dark_toggle (`switchValue`), share_card_sheet (`isStory=true`).

---

## Ключевые точки для гипотез (сводно)

1. **home_pipeline** скрывается НАВСЕГДА per-user-id после первого выполнения всех 3 шагов (порог косметички ≥3 продукта); хранится в `FFAppState().homePipelineDoneUsers`.
2. **product_card_v2**: free видит 3 актива, остальное за пейволлом (полностью скрыто); тапы по матрице типов кожи эфемерны (в профиль не пишутся); предупреждения безопасности видны всем бесплатно, но их объяснение — только Pro.
3. **Несогласованность цветов статусов**: working = амбер в ingredient_bubbles, но зелёный в score_breakdown/product_card_v2.
4. **Локализация**: `ingredient_bubbles` (статусы), `error_popup` («Анализировать»/«Закрыть»/hint), `delete_confirmation` (AlertDialog «ups!»), `guest_prefs_sheet` (все строки), `share_card_sheet` — содержат хардкод-строки вне общей системы.
5. **feedback**: промпт App Store rating только iOS, cooldown 14 дней, сброс при смене пользователя; appStoreId `6745415201`.
6. **Анонимный пользователь создаётся только по тапу «Continue»** в guest_prefs_sheet (не при открытии приложения).
7. **light_dark_toggle** реально не переключает тему (заглушка).
8. **delete_confirmation** сбрасывает `isprouser`, `analysesused`, `weekResetDate`, prefs `hint_upload_seen`/`pro_preview_used`, RevenueCat.
9. Несколько карточек (home_pipeline, profile_summary, score_breakdown) имеют жёстко белый/светлый фон — не адаптируются к тёмной теме.


---

# Экраны (lib/pages/)

Документация по всем экранам директории `lib/pages/` приложения Mirra (27 файлов).
Идентификаторы кода — на английском, описание — на русском.

## Общие соглашения

- Каждый экран — пара `*_widget.dart` (StatefulWidget + приватный `_State`) и `*_model.dart`
  (`FlutterFlowModel`). Модель обычно хранит только контроллеры/фокусы/валидаторы и
  экземпляр `NavbarModel` (там, где есть нижняя навигация).
- Навигация: `context.pushNamed` / `context.goNamed` / `context.goNamedAuth` по
  `Widget.routeName`. Глобальный ключ — `appNavigatorKey` (для переходов, когда контекст
  виджета мог быть заменён).
- `requireAuth` задаётся в `lib/flutter_flow/nav/nav.dart` (см. таблицу ниже). Если
  `requireAuth: true` и пользователь не залогинен — редирект (гейт роутера). Важно:
  «анонимный» гость в Mirra **является** залогиненным (Supabase anonymous session), поэтому
  `requireAuth: true` НЕ блокирует гостя, только полностью неаутентифицированного.
- Флаги состояния — `FFAppState()` (persist). Ключевые для этого раздела:
  `isprouser`, `onboardingDone`, `bagOnboardingActive`, `bagOnboardingDone`,
  `pendingBagSlot`, `analysesused`, `weekResetDate`, буфер онбординга (`ob*`), `obPendingFlush`,
  `showLinkTelegram`, флаги `feedback*`.
- Локализация: `FFLocalizations.of(context).getText('<key>')`. Ключи с косметичкой/рутиной
  начинаются на `cb_`, с онбордингом — на `obq_`, карточки логина — `lfc_`, newblank — `nb_`.

### Таблица requireAuth (из nav.dart)

| Экран | routeName | routePath | requireAuth |
|---|---|---|---|
| NewblankWidget | `Newblank` | `/newblank` | false |
| LogInPageWidget | `LogInPage` | `/log-in` | false |
| CreateAccountPageWidget | `CreateAccountPage` | `/create-account` | false |
| ForgotPasswordWidget | `ForgotPassword` | `/forgot-password` | false |
| OnboardingProfileWidget | `Onboarding_Profile` | `/onboardingProfile` | false |
| OnboardingQuizWidget | `OnboardingQuiz` | `/onboardingQuiz` | false |
| CosmeticBagIntroWidget | `CosmeticBagIntro` | `/cosmeticBagIntro` | false |
| CompatibilityResultWidget | `CompatibilityResult` | `/compatibilityResult` | false |
| CosmeticBagWidget | `CosmeticBag` | `/cosmeticBag` | **true** |
| RoutineCalendarWidget | `RoutineCalendar` | `/routineCalendar` | **true** |
| ProfileWidget | `Profile` | `/profile` | **true** |
| EditProfileWidget | `EditProfile` | `/editProfile` | false |

---

## 1. Newblank — экран приветствия / входа для гостя

**Путь:** `lib/pages/newblank/newblank_widget.dart` (544 стр.), модель `newblank_model.dart` (пустая, только жизненный цикл).
**routeName:** `Newblank` · **routePath:** `/newblank` · **requireAuth:** false.

**Назначение:** первый welcome-экран для НЕ аутентифицированных пользователей.
`nav.dart` показывает `NewblankWidget()` как стартовую страницу, когда
`onboardingDone == true`, иначе `OnboardingQuizWidget()` (строки 96-98, 117-119 nav.dart).
Т.е. Newblank — это «после онбординга, но до создания сессии».

### Класс `NewblankWidget` / `_NewblankWidgetState`
- `initState`: только создаёт модель.
- **`_tryAnonymously()`** (обработчик главной CTA «nb_try_free»):
  1. Haptic feedback.
  2. Показывает модальный лист `GuestPrefsSheet` (bottom sheet, `isScrollControlled`,
     прозрачный фон). Возвращает `bool?`.
  3. Пользователь/сессия создаётся ВНУТРИ листа при нажатии «Continue» — сам лист
     через `GuestPrefsSheet.save()` создаёт анонимного пользователя и ставит язык.
  4. Если `saved != true` (тап мимо / отмена) — остаётся на странице, ничего не делает.
  5. При успехе: через `appNavigatorKey.currentContext` (глобальный ключ, т.к. виджет мог
     быть заменён после анонимного sign-in) переходит `goNamed(TakeorUploadPageWidget.routeName)`
     с fade-переходом.
- **Вторичная ссылка** «nb_signin_register» (внизу): переход `goNamed(LogInPageWidget.routeName)`
  через `appNavigatorKey`, fade. Ведёт к входу/регистрации.
- Вспомогательный виджет **`_HeroIcon`** — статичная иконка камеры с двумя кольцами свечения
  и бейджем «science». Анимации входа — через `flutter_animate` (fadeIn/scale/slideY).

Тексты: заголовок `nb_check_30s`, подзаголовок `nb_subtitle`. Гейтинга Pro нет.

---

## 2. LogInPage — вход и регистрация (табы)

**Путь:** `lib/pages/log_in_page/log_in_page_widget.dart` (798 стр.), модель (77 стр.), карточки `login_feature_cards.dart` (390 стр.).
**routeName:** `LogInPage` · **routePath:** `/log-in` · **requireAuth:** false.

**Назначение:** экран с двумя вкладками (TabBar, `TabController length: 2`): «Log in» и
«Create account». Внизу — автопрокручиваемая карусель из 3 анимированных feature-карточек
(скрывается при показе клавиатуры).

### `_LogInPageWidgetState` (TickerProviderStateMixin)
- `initState`: `_tabController`, подписка на видимость клавиатуры
  (`KeyboardVisibilityController`, только не-web) → `_isKeyboardVisible`. Создаёт 4 контроллера/фокуса
  (email/password login + email/password register). Регистрирует 2 анимации входа.
- **`_inputDecoration` / `_inputTextStyle` / `_visibilityIcon`** — общий стиль полей и иконка
  показа/скрытия пароля.
- **`_termsFooter`** — RichText «By continuing…» + ссылки: «Terms of use» → `launchURL(apple stdeula)`,
  «Privacy Policy» → `launchURL('https://mirra.up.railway.app/privacy.html')`.
- **`_appleButton({required isRegister})`** — «Continue with Apple» (только не-Android):
  `GoRouter.prepareAuthEvent()` → `authManager.signInWithApple(context)`. Если `user == null` — выход.
  - register → `AnalyticsService.trackSignUp(method: 'apple')`, `goNamedAuth(OnboardingProfileWidget)` (fade).
  - login → `AnalyticsService.trackLogin(method: 'apple')`, `goNamedAuth(HomeWidget)`.

**Форма Login (`_loginForm`, formKey `formKeyLogin`, autovalidate disabled):**
- Поля email/password (валидаторы из модели, у login-полей валидаторы фактически не заданы — `null`).
- Кнопка «Log in»: haptic → `prepareAuthEvent()` → `authManager.signInWithEmail(context, email, pass)`.
  Если `user == null` — выход (ошибку показывает authManager). Иначе `trackLogin()` +
  `goNamedAuth(HomeWidget.routeName)`.
- Apple-кнопка (iOS).
- Ссылка «Forgot password? Reset» → `pushNamed(ForgotPasswordWidget.routeName)`.

**Форма Register (`_registerForm`, formKey `formKeyRegister`):**
- Валидаторы в модели: email — не пусто + `RegExp(kTextValidatorEmailRegex)`; password — не пусто + длина ≥ 5.
- Кнопка «Create account»: сначала `formKeyRegister.validate()`, при провале — выход.
  Затем `prepareAuthEvent()` → `authManager.createAccountWithEmail(...)`. При успехе `trackSignUp()` +
  `goNamedAuth(OnboardingProfileWidget.routeName)` (fade).
- Apple-кнопка (iOS).

**Кнопка «назад» (AppBar):** если `context.canPop()` — `pop()`, иначе `goNamed(NewblankWidget)`.
Это специально, чтобы не «терять» накопленные сканы анонимного пользователя.
`PopScope(canPop: false)` — системный свайп-назад заблокирован.

### `login_feature_cards.dart` (переиспользуется и в CreateAccount)
Три анимированные карточки (`_cardDecoration` — светлый фон `#F5F8FF`):
- **`FeatureScoreCard`** — круговой индикатор `CircularPercentIndicator` percent 0.94, буква «A»,
  пульсирующее свечение (`AnimationController` 2000ms reverse). Тексты `lfc_score_label`, «94 / 100».
- **`FeatureScanCard`** — анимированный сканер: 3 пульсирующих кольца + бегущий луч (sin), иконка камеры.
  Тексты `lfc_scan_title`, `lfc_scan_subtitle`.
- **`FeatureIngredientsCard`** — 3 «пилюли» (Retinol / Hyaluronic Acid / Ceramide) с поочерёдным
  fade (цикл 3600ms). Заголовок `lfc_ingredients_title`.

---

## 3. CreateAccountPage — отдельный экран регистрации

**Путь:** `lib/pages/create_account_page/create_account_page_widget.dart` (793 стр.), модель (69 стр.).
**routeName:** `CreateAccountPage` · **routePath:** `/create-account` · **requireAuth:** false.

**Назначение:** отдельная страница «Create your profile» (без табов; используется, например,
из Profile для анонимного пользователя, желающего конвертироваться в аккаунт). Дублирует
регистрацию из LogInPage, но как самостоятельный экран. Та же карусель feature-карточек
(порядок: Ingredients, Scan, Score) и pinned terms-footer снизу.

### `_CreateAccountPageWidgetState` (TickerProviderStateMixin)
- `initState`: postFrame-задержка 600ms + haptic; подписка на клавиатуру; контроллеры email/password;
  2 анимации.
- Валидаторы в модели: email (не пусто + email-regex), password (не пусто + длина ≥ 5).
- **Кнопка «Create account»**: haptic → `formKey.validate()` (при провале выход) →
  `prepareAuthEvent()` → `authManager.createAccountWithEmail(context, email, pass)`.
  При `user == null` выход. Иначе `trackSignUp()` + `goNamedAuth(OnboardingProfileWidget.routeName)` (fade).
- **Apple-кнопка** (не-Android): `signInWithApple` → `trackSignUp(method: 'apple')` →
  `goNamedAuth(OnboardingProfileWidget)`.
- **Назад (AppBar):** `canPop()` ? `pop()` : `goNamed(NewblankWidget)` (сохранить сканы гостя).
- `_termsFooter` — как в LogInPage (Terms → apple EULA, Privacy → mirra railway).
- `PopScope(canPop: false)`.

---

## 4. ForgotPassword — сброс пароля

**Путь:** `lib/pages/forgot_password/forgot_password_widget.dart` (312 стр.), модель (35 стр.).
**routeName:** `ForgotPassword` · **routePath:** `/forgot-password` · **requireAuth:** false.

**Назначение:** одно поле email + кнопка «Send Reset Password Link».
- Валидатор email: не пусто (ключ `g9lwam7j`). Формат не проверяется.
- **Кнопка отправки**: haptic → `formKey.validate()` (при провале выход) → дополнительная проверка
  «email пустой» → SnackBar «Email required!». Затем `authManager.resetPassword(email, context)`.
  Далее ВСЕГДА показывает SnackBar «Success! Check your inbox…» (даже если email не существует —
  подтверждение об ошибке от authManager обрабатывается отдельно). Тексты кнопки/SnackBar
  частично захардкожены на английском.
- Назад — `context.safePop()`.

---

## 5. Onboarding_Profile — профиль после регистрации

**Путь:** `lib/pages/onboarding_profile/onboarding_profile_widget.dart` (697 стр.), модель (92 стр.).
**routeName:** `Onboarding_Profile` · **routePath:** `/onboardingProfile` · **requireAuth:** false.

**Назначение:** шаг сразу после успешной регистрации (email или Apple) — заполнение аватара,
имени, никнейма, языка и страны. Это НЕ квиз кожи (тот — OnboardingQuiz), а профиль пользователя.

### `_OnboardingProfileWidgetState` (TickerProviderStateMixin)
- `initState`: подписка на клавиатуру; контроллеры firstName/lastName/nickname.
  Сразу генерирует 3 случайных предложения никнейма (`user####`, `scan###`, `health##`).
  Слушатель `lastNameFocusNode`: когда first+last заполнены — перегенерирует предложения на основе
  имени/фамилии (`fn+ln[0]+##`, `fn[0]+ln+##`, `fn+####`).
- Список **`_avatarUrls`** — 8 предустановленных аватаров в Supabase Storage (avatars/imageN.png).

**Секции (карточки `_sectionCard`):**
- **`_buildAvatarSection`**: круг загрузки с бейджем камеры → `_pickAvatar()`, плюс сетка 8 пресетов.
  Выбор пресета пишет URL в `_model.profilePicture`.
- **`_pickAvatar()`**: `selectMediaWithSourceBottomSheet` (папка `user_profile_images`, max 1000x1000,
  quality 90) → `validateFileFormat` → `uploadSupabaseStorageFiles(bucketName: 'images')`. При успехе
  ставит `profilePicture = uploadedFileUrl`.
- **`_buildNameSection`**: 2 поля (firstName/lastName), TextCapitalization.words. Валидаторы обязательности
  из модели (`z80dp9kp`, `kpzghah7`).
- **`_buildUsernameSection`**: поле nickname (maxLength 20, счётчик скрыт), debounce 400ms, чипы-предложения
  (`_usernameChip`) — тап подставляет никнейм. Валидатор обязательности (`pkkj80zk`).
- **`_buildPrefsSection`**: `FlutterFlowLanguageSelector` (`onChanged` → `setAppLanguage(context, lang)`),
  компонент `CountryselectorWidget(textSize: 16)`.

**Кнопка «Continue» (`spc42q3x`, скрыта при клавиатуре):**
- haptic → `formKey.validate()` (обязательны имя/фамилия/никнейм) → `UsersTable().update({first_name,
  last_name, profile_image, nickname, onboarded: true})` по `id == currentUserUid` →
  `goNamed(TakeorUploadPageWidget.routeName)` (сразу к сканированию).
- `PopScope(canPop: false)`.

---

## 6. OnboardingQuiz — квиз типа кожи (профиль кожи)

**Путь:** `lib/pages/onboarding_quiz/onboarding_quiz_widget.dart` (1138 стр.),
модель `onboarding_quiz_model.dart` (18 стр., поля brands input), резолвер `skin_type_resolver.dart` (45 стр.).
**routeName:** `OnboardingQuiz` · **routePath:** `/onboardingQuiz` · **requireAuth:** false.

**Назначение:** это ПЕРВЫЙ экран приложения, когда `onboardingDone == false` (nav.dart). Пошаговый
опрос профиля кожи (spec: `docs/onboarding_spec.md`). Ответы **до логина** буферизуются в `FFAppState`
и флашатся в `users` после аутентификации (в HomeWidget). Если пользователь уже залогинен
(редактирование из настроек) — запись происходит сразу здесь.

### Шаги — enum `_Step`: welcome, type, determine, sensitivity, acne, goals, optional, result

Прогресс-бар (4 сегмента) активен на type/determine(1), sensitivity(2), acne(3), goals(4);
на welcome/optional/result скрыт.

**Данные-ответы (локальные поля):** `_skinType`, `_sensitive`, `_acneProne`, `_goals` (список, max 3 —
`_maxGoals`), `_ageRange`, `_budgetRange`, `_brands` (список). Плюс под-квиз «не знаю»: `_shine`/`_tight`/`_pores`
(`_typeViaDetermine`), `_detResult` вычисляется через `resolveSkinType`.

**Константы вариантов:**
- `_goalKeys` — 6 целей: hydration, barrier, anti_aging, pigmentation, acne, pores (ключи совпадают
  с backend `_VALID_SKIN_GOALS`).
- `_ageOptions` — 6 диапазонов (under_18 … 55_plus).
- `_budgetOptions` — 4 диапазона (under_15 … 80_plus).

### Методы
- **`_loadExistingProfile()`** (вызов из initState при `currentUserUid.isNotEmpty`): читает `UsersTable`,
  если `skinType` заполнен — префилл всех полей и (если был на welcome) сразу переход на `_Step.type`
  (пропуск value-sell для повторного входа, spec §5). Ошибки глушатся `catch (_)`.
- **Навигация `_back()`**: точная логика назад по шагам; из sensitivity назад — на determine, если
  `_typeViaDetermine`, иначе на type.
- **`_collectBrands()`**: список выбранных брендов + текст в поле, не подтверждённый Enter/выбором
  (защита от потери ввода).
- **`_addBrand`**: добавляет бренд (без дублей, case-insensitive), очищает поле, возвращает фокус.
- **`_brandSuggestions(query)`**: RPC Supabase `search_brands` (`p_query`, `p_limit: 8`), исключает
  уже выбранные. При ошибке — пустой список.
- **`_finish({required save, dest})`** — завершение:
  - `save == true` и `currentUserUid.isNotEmpty` (залогинен): `UsersTable().update({skin_type,
    skin_sensitivity, acne_prone, skin_goals, age_range, budget_range, trusted_brands, onboarded:true})` +
    `clearOnboardingBuffer()`.
  - `save == true` и НЕ залогинен: буфер в `FFAppState` (`obSkinType`, `obSensitive`, `obAcneProne`,
    `obGoals`, `obAgeRange`, `obBudgetRange`, `obTrustedBrands`, `obPendingFlush = true`).
  - `save == false` (скип): `clearOnboardingBuffer()` — приложение работает в режиме «все типы кожи».
  - Всегда: `onboardingDone = true`. Затем `goNamed(dest ?? (залогинен ? HomeWidget : PaywallpageWidget))`.
    ⚠️ Важно: незалогиненный после квиза попадает на **Paywall**, залогиненный — на Home.
- **`_confirmSkip()`**: кастомный диалог подтверждения (`obq_skip_confirm_*`); при «да» → `_finish(save:false)`.

### Шаги-виджеты
- **welcome** (`_buildWelcome`): value-sell; footer — кнопка «Start» → type; ссылка «Skip» → `_confirmSkip`.
- **type** (`_buildType`): 4 карточки типа (dry/oily/combination/normal) — тап сразу ведёт на sensitivity
  и сбрасывает `_typeViaDetermine=false`. Плюс «не знаю» → determine.
- **determine** (`_buildDetermine`): под-квиз из 3 ChoiceChip-рядов (shine/tight/pores). Как только все три
  выбраны — карточка результата `_detResult` с кнопками «Подтвердить» (→ sensitivity, `_typeViaDetermine=true`)
  и «Изменить» (→ type).
- **sensitivity** / **acne** (`_buildSensitivity`/`_buildAcne`): по 2 карточки да/нет, тап ведёт дальше.
- **goals** (`_buildGoals`): чипы целей, лимит 3 — при попытке добавить 4-ю SnackBar `obq_goals_max`.
  Footer: «Next» (disabled если `_goals` пусто) → optional; «Пропустить» (`obq_goals_none`) очищает и → optional.
- **optional** (`_buildOptional`): возраст (pills), бюджет (pills), бренды (`_buildBrandsInput` —
  чипы + `RawAutocomplete` с БД-подсказками). Footer: «Готово» → result; «Пропустить всё» очищает
  age/budget/brands → result.
- **result** (`_buildResult`): сводка профиля. Footer: главная — `_finish(save:true,
  dest: TakeorUploadPageWidget.routeName)` (после сохранения сразу к сканированию!); ссылка «Изменить» → type.

### `skin_type_resolver.dart`
Чистая функция `resolveSkinType({shine, tight, pores})` (enum ShineLevel/TightLevel/PoreLevel).
Правила сверху вниз, первый матч (27 комбинаций → один из dry/oily/combination/normal):
1. shine=all ИЛИ pores=wide → oily
2. shine=tzone ИЛИ pores=tzone → combination
3. tight=strong → dry
4. tight=some И shine=none И pores=none → dry
5. иначе → normal

---

## 7. CosmeticBagIntro — онбординг-игра «собери 3 продукта»

**Путь:** `lib/pages/cosmetic_bag_intro/cosmetic_bag_intro_widget.dart` (381 стр.), модель (12 стр., пустая).
**routeName:** `CosmeticBagIntro` · **routePath:** `/cosmeticBagIntro` · **requireAuth:** false.

**Назначение:** игровой онбординг-флоу — 3 плейсхолдера (`kBagOnboardingSlots == 3`, slot_index 0..2),
которые предлагают отсканировать 3 продукта, затем показать их совместимость. Также содержит
**статический** метод-хук, вызываемый из экрана сканирования.

### Статический `handleScanSuccess(context, imageId, {required mounted})` → `Future<bool>`
Ключевая логика роутинга после успешного скана. Возвращает `true`, если перехватила навигацию
(вызывающий пропускает свой обычный переход к карточке товара), `false` — если онбординг уже завершён.
1. `imageId == null` → false.
2. **Персистентная косметичка, «новый скан в слот»**: если `FFAppState().pendingBagSlot != -1`:
   сбрасывает `pendingBagSlot = -1`; если было `kNewBagSlotPending` — `addEmptySlot()` + `assignSlot(idx, imageId)`,
   иначе `assignSlot(pending, imageId)`; затем `goNamed(CosmeticBagWidget)` (fade) → true.
3. Если НЕ (`bagOnboardingActive` активен) ИЛИ `bagOnboardingDone` — возвращает false (обычные юзеры сканируют нормально).
4. Иначе (в игре): `CosmeticBagService.onScanCompleted(imageId)` возвращает число заполненных.
   Если `>= 3` — ставит `bagOnboardingDone=true`, `bagOnboardingActive=false`. Переход:
   готово → `CompatibilityResultWidget`, иначе → сам `CosmeticBagIntro` (fade). → true.
   Навигация через `mounted ? context : appNavigatorKey.currentContext`.

### `_CosmeticBagIntroWidgetState`
- `_load()`: `ensureSlots()` + подгрузка `ImagesRow` по imageId слотов.
- `_filledCount`: сколько из 3 базовых плейсхолдеров заполнено.
- **`_startScan()`**: `showAddChoice` (из bag_add_helpers) → либо `pickUserProduct` + `_addExisting(img.id)`,
  либо `pushNamed(TakeorUploadPageWidget)` с fade (после возврата — `_load`).
- **`_addExisting(imageId)`**: `onScanCompleted` (без реального скана — из существующих продуктов). Если
  `>= 3` → `bagOnboardingDone/Active` + `goNamed(CompatibilityResultWidget)`, иначе `_load`.
- **`_seeTogether()`**: `pushNamed(CompatibilityResultWidget)`.
- **`_skip()`**: `bagOnboardingDone=true`, `bagOnboardingActive=false` → `goNamed(HomeWidget)`.
- UI: заголовок `cb_intro_title`, счётчик `filled/3`, список из 3 `_SlotCard` (пустой запускает `_startScan`),
  нижняя кнопка: если все 3 заполнены — «See together» (`_seeTogether`), иначе «Scan» (`_startScan`).
- `_SlotCard` — карточка слота (фото продукта или номер 1/2/3, галочка/плюс).

---

## 8. CompatibilityResult — анализ совместимости косметички (косметолог-стиль)

**Путь:** `lib/pages/compatibility_result/compatibility_result_widget.dart` (719 стр.), модель (12 стр., пустая).
**routeName:** `CompatibilityResult` · **routePath:** `/compatibilityResult` · **requireAuth:** false.

**Назначение:** анализ рутины по продуктам косметички: AM/PM-рутина, конфликты, пробелы, советы,
персонализировано под профиль кожи. **Гейтинг:** score + summary + первый конфликт — бесплатно;
полная рутина/остальные конфликты — Pro-апселл. Для FREE анализ ограничен первыми 3 продуктами.

### `_CompatibilityResultWidgetState`
Состояние: `_loading`, `_error`, `_errorMsg`, `_capped` (free-юзер имеет >3 продуктов → анализ только 3),
`_data` (карта результата). Геттеры: `_score`, `_summary`, `_conflicts()`, `_am()`, `_pm()`, `_gaps()`, `_tips()`.

- **`_loadCachedOrAnalyze()`** (из initState postFrame): читает `cosmetic_bag.last_result`. Если кэш есть
  и его `analyzed_image_ids` совпадает с ожидаемым набором (для FREE — первые 3 из заполненных, для Pro — все) —
  показывает кэш мгновенно. Иначе (нет кэша / косметичка изменилась) → `_analyze()`.
- **`_skinProfile()`**: собирает из `FFAppState` — `skin_type` (obSkinType), `goals` (obGoals),
  `sensitive` (obSensitive), `acne_prone` (obAcneProne), `age_range` (obAgeRange); удаляет null/пустые.
- **`_analyze()`**: `isPro = FFAppState().isprouser`. Берёт слоты (`getSlots`), `allIds` заполненных;
  `ids = isPro ? allIds : allIds.take(3)`. Если `ids.length < 2` → ошибка `cb_compat_need_more`.
  Вызов бэкенда **`AnalyzeCompatibilityCall.call(token: currentJwtToken, imageIds, languageCode, userId,
  skinProfile)`**. При `!succeeded` — throw. Если `map['score'] == null` → ошибка `cb_compat_no_inci`
  (нет распознанного состава). Пишет `map['analyzed_image_ids'] = ids`, кэширует (`_cache`), ставит
  `_capped = !isPro && allIds.length > 3`. Ошибки → `FirebaseCrashlytics.recordError` + `_fail(cb_compat_error)`.
- **`_cache(map)`**: `SupaFlow.client.from('cosmetic_bag').upsert({user_id, last_compatibility_score,
  last_result, last_analyzed_at}, onConflict: 'user_id')`.
- **`_openPaywall()`**: `pushNamed(PaywallpageWidget)`.
- **`_addToCalendar()`**: `RoutineService.generateFromRoutine(am, pm)` → возвращает число созданных событий.
  SnackBar `cb_calendar_added` / `cb_calendar_none`. Если `created > 0` → `pushNamed(RoutineCalendarWidget)`.

### UI и Pro-гейтинг
- AppBar: close → `pop()`, refresh → `_analyze` (перезапуск).
- Body: `_LoadingView` / `_ErrorView(onRetry: _analyze)` / список.
- Свободная часть: `_ScoreRing` (кольцо, score/10), summary, `_CappedHint` (если `_capped` — апселл Pro,
  `cb_compat_capped`), первый конфликт (`_ConflictTile`).
- **`_proSections`**: кнопка «Добавить в календарь» (если есть am/pm), секции AM (`_RoutineStep`), PM,
  остальные конфликты (`restConflicts` = conflicts[1..]), пробелы (`_GapTile`), советы (буллеты).
  Примечание: в коде эти секции рендерятся всем, кто получил данные — фактический гейт на глубину
  анализа реализован через ограничение `ids.take(3)` и `_capped`-хинт (полноту рутины для >3 продуктов
  видит только Pro).
- `_ConflictTile` цвет по severity: high `#D9534F`, low серый, иначе `#E07A5F`.

---

## 9. CosmeticBag — постоянная косметичка

**Путь:** `lib/pages/cosmetic_bag/cosmetic_bag_widget.dart` (502 стр.), helpers `bag_add_helpers.dart` (161 стр.), модель (18 стр., navbar).
**routeName:** `CosmeticBag` · **routePath:** `/cosmeticBag` · **requireAuth:** **true**. Navbar activePage 3.

**Назначение:** постоянные слоты продуктов пользователя с кэшированным score совместимости.
**Гейтинг Pro:** свободно/анонимно — максимум 3 продукта; добавление 4-го требует Pro.

### `_CosmeticBagWidgetState`
Состояние: `_slots`, `_images`, `_cachedScore`, `_profileRow`, `_calendarIds` (id продуктов с напоминанием
в рутине), `_compatStale` (косметичка изменилась с последнего анализа), `_loading`.
- `_baseFilled`: сколько из 3 базовых плейсхолдеров (slot_index 0..2) заполнено.
- `_filledCount`: всего заполненных слотов.
- **Автоперезагрузка при возврате на таб**: в initState через postFrame подписывается на
  `GoRouter.routerDelegate` (`_onRouteChanged`); когда роут снова становится `/cosmeticBag` — `_load()`
  (чтобы новые сканы появлялись без pull-to-refresh).
- **`_load()`**: `ensureSlots()`; подгружает `ImagesRow`; читает `cosmetic_bag` (last_result,
  last_compatibility_score), `users` (профиль), события рутины (`_calendarIds`). Вычисляет `_compatStale`:
  сравнивает ожидаемый набор (Pro — все заполненные, free — первые 3) с `analyzed_image_ids` из last_result.
- **`_onSlotTap(slot)`**: если слот пуст → `_addToSlot`. Если заполнен → `showSlotActions` (bottom sheet):
  - replace → `pickUserProduct` → `assignSlot(slotIndex, img.id)` (бесплатно).
  - newScan → `pendingBagSlot = slotIndex` → `pushNamed(TakeorUploadPageWidget)`.
  - remove → `removeFromSlot(slotIndex)`.
- **`_addNewSlot()`** («+»-плитка): **гейт Pro** — если НЕ Pro и `_filledCount >= 3` →
  `pushNamed(PaywallpageWidget)` и выход. Иначе `showAddChoice`: fromProducts → `pickUserProduct`,
  затем `addEmptySlot()` + `assignSlot`; newScan → `pendingBagSlot = kNewBagSlotPending` →
  `pushNamed(TakeorUploadPageWidget)` (слот создаётся при успехе скана).
- **`_addToSlot(slot)`**: `showAddChoice` (fromProducts/newScan) — заполнение существующего пустого слота.

### UI
- ListView + RefreshIndicator (`onRefresh: _load`). Сверху `ProfileSummaryCard(profileRow)`.
- **`_ScoreHeader`**: кэшированный score (или «—»), тап → `pushNamed(CompatibilityResultWidget)` (после
  возврата `_load`). Если `stale` — оранжевый бейдж `cb_compat_stale` + иконка refresh, иначе «открыть анализ».
- Сетка 2 колонки: заполненные слоты — `_BagTile` (фото + название; бейдж «не в календаре рутины»
  `cb_not_in_calendar`, если у продукта нет напоминания, а у других есть); пустые — `_AddSlotTile`.
  Хвостовая «+»-плитка (`_addNewSlot`) появляется только когда `_baseFilled >= 3`.

### `bag_add_helpers.dart` (общие для intro и bag)
- enum **`AddChoice`** {fromProducts, newScan}, **`SlotAction`** {replace, newScan, remove}.
- **`showAddChoice(context)`** — bottom sheet: «из продуктов» / «новый скан».
- **`showSlotActions(context)`** — bottom sheet: заменить / новый скан / удалить (danger).
- **`pickUserProduct(context)`** — лист выбора из отсканированных продуктов пользователя
  (`ImagesTable`, фильтр `user == currentUserUid`, order desc, limit 50). Возвращает `ImagesRow?`.

---

## 10. RoutineCalendar — календарь ухода (Pro-рутина)

**Путь:** `lib/pages/routine_calendar/routine_calendar_widget.dart` (682 стр.), модель (18 стр., navbar).
**routeName:** `RoutineCalendar` · **routePath:** `/routineCalendar` · **requireAuth:** **true**. Navbar activePage 4.

**Назначение (из докстринга):** Pro-рутина — слайдер дней недели (по умолчанию сегодня), показывающий
что наносить утром/вечером, подкреплено локальными напоминаниями на устройстве.

### `_RoutineCalendarWidgetState`
Состояние: `_events` (`RoutineEventsRow`), `_images`, `_loading`, `_selectedDay` (1=Пн..7=Вс, по умолчанию
`DateTime.now().weekday`). `_weekdayLabels` — Пн..Вс или Mon..Sun по языку.
- **`_syncDigests()`**: `RoutineService.syncDigests(amTitle/amBody/pmTitle/pmBody)` — тексты пушей из
  локализации (`cb_push_am_title` и т.д.).
- **`_load()`**: `_syncDigests()` → `RoutineService.getEvents()` → подгрузка `ImagesRow` по imageId событий.
- **`_partTime(part)`**: единое время части дня (из самого раннего продукта) или null.
- **`_editPartTime(part)`**: haptic → `_pickTimeCupertino` (нативный Apple-пикер, 24h) → `setPartTime(part, h, m)` → `_load`.
- **`_forDay(part)`**: события, где `weekdays.contains(_selectedDay)` и `partOfDay == part`, сортировка по времени.
- **`_delete(e)`**: `deleteEvent(e)` → `_load`.
- **`_addFlow()`**: haptic → загружает сканы (limit 50) → показывает `_AddReminderSheet` → при результате
  `RoutineService.addEvent(imageId, title, weekdays, hour, minute)` → `_load`.

### UI
- AppBar `cb_routine_title`. FAB «cb_routine_add» → `_addFlow`.
- Body: `_DaySelector` (7 дней, выбор), две секции `_DaySection` (AM/PM) — иконка, заголовок, чип времени
  части дня (тап → `_editPartTime`), список событий (фото, название, удалить) или пусто `cb_routine_day_empty`.
- **`_AddReminderSheet`** (StatefulWidget): выбор продукта (горизонтальный список сканов; выбор ставит title
  из имени/бренда), выбор дней (`_DayChip`, по умолчанию ВСЕ 7; кнопки «все»/«снять все»), время
  (`_pickTimeCupertino`, по умолчанию 21:00). Кнопка «Сохранить» активна если title не пуст и есть хотя бы
  один день; возвращает `_RoutineDraft(imageId, title, weekdays, time)`.
- **`_pickTimeCupertino`** — `showCupertinoModalPopup` с `CupertinoDatePicker` (mode.time, 24h),
  кнопки Cancel/Done.

---

## 11. Profile — экран настроек/профиля

**Путь:** `lib/pages/profile/profile_widget.dart` (1287 стр.), модель (22 стр., navbar).
**routeName:** `Profile` · **routePath:** `/profile` · **requireAuth:** **true**. Navbar activePage **0**
(Profile больше не таб навбара — не подсвечивается).

**Назначение:** экран профиля/настроек. Через `FutureBuilder<List<UsersRow>>` грузит запись пользователя
(для гостя — dummy id `0000…`). Разные состояния: анонимный / зарегистрированный. Спиннер при загрузке,
Retry при ошибке.

### Ключевые блоки и обработчики
- **Dev-бейдж** и dev-инструменты видны только при `FFDevEnvironmentValues.isNonProd`.
- **Хедер**: аноним → `_AnonHeader` (иконка, `prof_not_signed_in`, `prof_signin_subtitle`); иначе аватар +
  имя/фамилия + email.
- **«Try premium»** (`1g4dikoz`): `pushNamed(PaywallpageWidget)`.
- **«Edit Profile»** (только не-аноним): `pushNamed(EditProfileWidget)`.
- **«Link Telegram»** (только не-аноним И `FFAppState().showLinkTelegram`): bottom sheet `LinkTelegramSheet`.
- **«Share»** (не-web): `Share.share('https://apps.apple.com/us/app/...id6745415201')`.
- **«Leave a Review»**: bottom sheet `LeaveReviewWidget`.
- **«App language»**: `pushNamed(LangsWidget)`.
- **«Your Region»**: `pushNamed(CountriesWidget)`.

### Dev-кнопки (только non-prod)
- «Сбросить онбординг»: `isprouser=false`, `onboardingDone=false` → SnackBar → `goNamed(OnboardingQuizWidget)`.
- «Показать feedback prompt»: сбрасывает флаги `feedbackLastShownMs=0`, `feedbackLastShownVersion=''`,
  `feedbackBannerDismissed=false`, `feedbackReviewSubmitted=false`, `feedbackCollectorEnabled=true`,
  `feedbackPendingScan=true`.
- «Сбросить pro preview»: `SharedPreferences.remove('pro_preview_used')`.

### Нижние действия
- **Анонимный:** «Create account» → `pushNamed(CreateAccountPageWidget)` (fade); «Sign in» →
  `pushNamed(LogInPageWidget)` (fade); «End session» — сбрасывает `isprouser=false`, `onboardingDone=false`,
  `analysesused=0`, `weekResetDate=null`, `SharedPreferences.remove('hint_upload_seen'/'pro_preview_used')`,
  `revenue_cat.login(null)`, `prepareAuthEvent()`, `authManager.signOut()`, `clearRedirectLocation()` →
  `goNamed(OnboardingQuizWidget)`.
- **Зарегистрированный:** «Log out» — тот же сброс, что и End session → `goNamed(OnboardingQuizWidget)`;
  «Delete account» → bottom sheet `DeleteConfirmationWidget`.
- Navbar внизу: `activePage: 0`, `analysesused: monthlyAnalysesUsed`, кнопка scroll-to-top.

---

## 12. EditProfile — редактирование имени/аватара

**Путь:** `lib/pages/edit_profile/edit_profile_widget.dart` (1140 стр.), модель (35 стр.).
**routeName:** `EditProfile` · **routePath:** `/editProfile` · **requireAuth:** false (по факту нужен user).

**Назначение:** редактирование аватара, имени и фамилии. `FutureBuilder<List<UsersRow>>` по `currentUserUid`
(спиннер/Retry с `FirebaseCrashlytics.recordError` при ошибке). `context.watch<FFAppState>()`.

### Особенности
- `initState`: слушатель `firstNameFocusNode` пишет `first_name` в `UsersTable` при потере фокуса
  (автосохранение); слушатель `lastNameFocusNode` — `safeSetState`.
- **Аватар (тап по кругу)**: `selectMediaWithSourceBottomSheet` (папка `user_profile_images`, 1000x1000, q90) →
  `validateFileFormat` → `uploadSupabaseStorageFiles(bucketName: 'images')`. При успехе — если
  `uploadedFileUrl != ''`, пишет `profile_image: FFAppState().uploadedimageurl` в `UsersTable`.
  ⚠️ Показ круга завязан на `FFAppState().userProfilePicture` и `editProfileUsersRow?.profileImage`.
- **«Avatar ideas»**: 8 пресетов (те же URL avatars/imageN.png) — каждый тап пишет `profile_image` в
  `UsersTable` (по `id == currentUserUid`) + `safeSetState`.
- **Поля first_name / last_name**: TextCapitalization.words; контроллеры инициализируются из строки БД.
  `last_name` при `onFieldSubmitted` пишется в БД.
- **«Save Changes»** (`bwi4v4ib`): `formKey.validate()` (валидаторы фактически null) →
  `UsersTable().update({first_name, last_name})` → SnackBar «Profile changes saved!».
- Назад (AppBar) — `pushNamed(ProfileWidget.routeName)` (не pop!).
- В AppBar есть невидимая share-кнопка (заглушка `print`).

---

## Сводка по флоу и гейтингу (важно для гипотез)

1. **Стартовый флоу нового пользователя:** `OnboardingQuiz` (если `onboardingDone==false`) → на result
   `_finish(save:true, dest: TakeorUploadPage)` буферит `ob*` в FFAppState (не залогинен) → но незалогиненный
   при завершении без dest уходит на **Paywall**, залогиненный — на Home. Буфер флашится в `users` в HomeWidget
   через `obPendingFlush`. После онбординга стартовая страница — `Newblank` (welcome для гостя) →
   `GuestPrefsSheet` создаёт анонимную сессию → `TakeorUploadPage`.

2. **Регистрация:** LogInPage/CreateAccountPage → `OnboardingProfileWidget` (имя/аватар/язык/страна,
   `onboarded:true`) → `TakeorUploadPage`. Onboarding_Profile ≠ OnboardingQuiz (профиль пользователя vs профиль кожи).

3. **Косметичка-онбординг (игра):** `CosmeticBagIntro` требует собрать 3 продукта (`kBagOnboardingSlots=3`).
   Ключ маршрутизации — статический `CosmeticBagIntro.handleScanSuccess`, читает `bagOnboardingActive/Done`
   и `pendingBagSlot`/`kNewBagSlotPending`. Собрал 3 → `CompatibilityResult`.

4. **Гейтинг Pro косметички:** free/аноним — максимум **3 продукта**; 4-й → Paywall (`_addNewSlot`).
   Совместимость (`CompatibilityResult`) для free считается только по первым 3 продуктам (`ids.take(3)`),
   при >3 показывается `_CappedHint` (апселл). Требуется минимум 2 продукта для анализа.

5. **Гейтинг Pro рутины:** `CosmeticBag` и `RoutineCalendar` — `requireAuth: true` (но аноним = залогинен,
   поэтому доступны гостю). Календарь наполняется из `CompatibilityResult._addToCalendar` (Pro-рутина am/pm →
   локальные напоминания через `RoutineService`).

6. **Сброс/логаут (Profile):** и «Log out», и гостевой «End session» одинаково сбрасывают
   `isprouser/onboardingDone/analysesused/weekResetDate` + чистят SharedPreferences и RevenueCat, затем
   `goNamed(OnboardingQuizWidget)` — т.е. после логаута пользователь снова проходит квиз кожи.


---

# Главный экран и флоу сканирования (lib/home, lib/itemcard2, lib/item_card)

Документация по ключевому флоу приложения Mirra: главный экран → сканирование продукта (камера/галерея) → бэкенд-пайплайн анализа состава → карточка результата. Идентификаторы кода — на английском, описания — на русском.

Всего задокументировано **18 .dart файлов** в трёх директориях:
- `lib/home/` (6 файлов): `home/` (widget+model), `startanalys/` (widget+model), `takeor_upload_page/` (widget+model)
- `lib/itemcard2/` (2 файла): основная карточка результата скана
- `lib/item_card/` (10 файлов): старые/вспомогательные виджеты карточки (5 подпапок × widget+model)

---

## Общая карта флоу и глобальное состояние

### Ключевые FFAppState-флаги (читаются/пишутся в этом флоу)
| Флаг | Тип | Смысл |
|------|-----|-------|
| `analysisloading` | bool | Идёт ли пайплайн скана (полноэкранный оверлей на TakeorUploadPage) |
| `Producanalysstate` | int (0..3) | Стадия пайплайна: 0=idle, 1=extract, 2=product found, 3=scientific analysis |
| `uploadedimageurl`, `uploudedimagepath` | String | URL загруженного фото в Supabase Storage |
| `extractedProductName`, `extractedBrand` | String | Распознанные бэкендом имя продукта и бренд (показываются в лоадере) |
| `isprouser` | bool | Pro-подписка. Источник правды — `users.subscription_plan == 'premium'` (см. Home.initState) |
| `analysesused` | int | Сколько сканов использовано (локальный гейт лимита) |
| `freeScanLimit` | int | Лимит бесплатных сканов (из `/quota` или `app_config.free_scan_limit`, дефолт зашит) |
| `weekResetDate` | DateTime? | Начало 7-дневного окна квоты. Момент сброса = `weekResetDate + 7 дней` |
| `countrycode` (nameEn), `countrycodeiso` (ISO code) | String | Страна пользователя — влияет на поиск ингредиентов и цены |
| `feedbackPendingScan` | bool | Флаг «после скана показать промпт обратной связи» (ставится при успехе скана, читается в Itemcard2) |
| `spamlist` | List<int> | Скрытые (spam) image id |
| `showLinkTelegram` | bool | Из `app_config.show_link_telegram` |
| `userProfilePicture` | String | Аватар |
| `obPendingFlush`, `obSkinType`, `obSensitive`, `obAcneProne`, `obGoals`, `obAgeRange`, `obBudgetRange`, `obTrustedBrands` | onboarding-буфер | Долив профиля онбординга при первом входе на Home |

### Стадии бэкенд-пайплайна (API-вызовы из `api_calls.dart`)
1. `ExtractproductinfoNEWBCNDCopyCall` — извлечь имя/бренд/язык/image id из фото. Статические парсеры: `.name()`, `.brand()`, `.iamgeID()` (sic, опечатка в имени), `.langcode()`, `.quotaUsed()`, `.resetTime()`.
2. `SearchingredientsNEWBCNDCall` — найти состав по имени/бренду/стране. Парсеры: `.limit()`, `.resettime()`.
3. `ScientificanalysisNEWBCNDCall` — научный анализ состава → композитный score. Может вернуть **202** (анализ отложен, ингредиенты ещё исследуются).
4. `ResearchAndAnalyzeCall` — фоновый (unawaited) дозапуск research при 202.
5. `SetProductIngredientsCall` — ручной ввод состава пользователем при 404.
6. `GetScanQuotaCall` — чтение квоты с `/quota` (парсеры `.quotaUsed()`, `.quotaLimit()`, `.resetAt()`).
7. `TelegrammessegeCall` — техническое сообщение в Telegram при ошибках.

---

## lib/home/home/home_widget.dart (1231 строк)

**routeName:** `'Home'` · **routePath:** `/home` · **navbar activePage:** 2

### Назначение
Главный экран после входа: приветствие, кнопка/карточка «Обновить до PRO», блок пайплайна (`HomePipelineWidget`), бар квоты сканов, фильтр-чипы по категориям продукта, masonry-сетка «My Products» (сохранённые сканы пользователя).

### Константы верхнего уровня
- `_kHomeCategoryTypes` (Map<String, List<String>>) — маппинг ключа чипа → значения `product_type` (включая legacy). Категории: serum, toner, moisturizer(+treatment), mask, cleanser(+exfoliant), sunscreen, eye_cream(+eye_care), lip_balm(balm+lip_balm), makeup (14 типов косметики).
- `_kHomeFilterChips` — порядок чипов: `all`, serum, toner, moisturizer, mask, cleanser, sunscreen, eye_cream, lip_balm, makeup.

### Класс `HomeWidget` / `_HomeWidgetState` (TickerProviderStateMixin)
Поля состояния: `_model`, `_keyboardVisibilitySubscription`, `_isKeyboardVisible`, `_goRouter`, `_lastLocation`, `_autoScrollTicker`, `_tickerLastElapsed`.

**Методы:**
- `_startAutoScroll()` / `_stopAutoScroll()` / `_toggleAutoScroll()` — автопрокрутка сетки со скоростью ~114 px/сек через `createTicker`; при достижении конца `jumpTo(0)`. (Тумблер `_model.autoScrollActive`.)
- `_refreshQuota()` — читает `GetScanQuotaCall` с сервера `/quota` (там уже применён скользящий 7-дневный сброс). Пишет `FFAppState().analysesused`, `freeScanLimit`, `weekResetDate` (= reset_at − 7 дней). Комментарий: чтение `users.monthly_analyses_used` напрямую даёт устаревший счётчик.
- `_onRouteChanged()` — слушатель GoRouter: при возврате на `/home` (переход с другого пути на Home) вызывает `_refreshImages()` + `_refreshQuota()`. Так удалённые/изменённые товары исчезают.
- `_flushOnboardingProfile()` — если `obPendingFlush` и есть uid: пишет в `UsersTable` поля профиля из onboarding-буфера (skin_type, skin_sensitivity, acne_prone, skin_goals, age_range, budget_range, trusted_brands, onboarded=true), затем `clearOnboardingBuffer()`.
- **initState** (PostFrameCallback):
  - Подписка на GoRouter route changes.
  - `_flushOnboardingProfile()`.
  - Чтение `app_config` (ключи `free_scan_limit`, `show_link_telegram`) → пишет `freeScanLimit`, `showLinkTelegram`.
  - Запрос `usersanswer` (UsersTable по uid). Если пусто и uid пуст → `pushNamed(LogInPageWidget.routeName)`. Если uid есть, но строки нет — НЕ бросать на логин (защита от пинг-понга).
  - Аватар: `profileImage` → `userProfilePicture`.
  - Страна: `countrieshome` (CountriesTable), пишет `countrycode`/`countrycodeiso`.
  - **Pro-гейтинг:** `FFAppState().isprouser = subscriptionPlan == 'premium'` — строго из БД. Явный комментарий: раньше был fallback на RevenueCat.isEntitled — убран, т.к. подписка Apple привязана к устройству, а не к аккаунту (выдавал pro любому профилю на устройстве с активной подпиской).
  - `spamlist` из `user.spamImages`.
  - `_loadPriceMap(images)` при непустом countrycodeiso.
  - `_refreshQuota()`.
- `_fetchImages()` — `ImagesTable().queryRows` (колонки: id, image_url, product_name, brand, sa_composite_score, sa_best_for_tags, sa_scoring_log, created_at, product_type), фильтр `user==uid`, order created_at desc, **timeout 20 сек** (иначе вечный спиннер без Retry).
- `_refreshImages()` — сбрасывает priceMap, переустанавливает `imagesFuture`, дозагружает цены.
- `_loadPriceMap(images)` — из `ProductPricesTable` по country_code + список product_name_key. Ключ `priceMap`: `'productNameKey|brandKey'`.
- `_availableChips(images)` — показывает только те чипы, для которых есть товары в наличии (по product_type). `all` всегда есть.
- `_chipLabel(catKey)` — локализованная метка `cat_<key>`.

**build:** Stack из FutureBuilder(imagesFuture) + Navbar.
- При ошибке (и нет `loadedImages`) — иконка ошибки + Retry. При загрузке — спиннер. Иначе `loadedImages` кэшируется и показывается при рефреше (не бланчит в спиннер).
- Верх: если НЕ pro → кнопка «Update to PRO» (`fjrdil62`) с иконкой короны → `pushNamed(PaywallpageWidget.routeName)`.
- «Hello, {firstName}» + аватар → onTap `pushNamed(ProfileWidget.routeName)`.
- `HomePipelineWidget` (внешний компонент).
- `_HomeQuotaBar` (см. ниже) с isPro/scansUsed(analysesused)/weekResetDate/freeScanLimit.
- Заголовок «My Products» (`cnejp0mk`) — только если есть товары.
- Фильтр-чипы (горизонтальный скролл), выбор пишет `_model.selectedCategory`.
- Вложенный FutureBuilder → фильтрует по категории → `MasonryGridView` (2 колонки). Пустое состояние:
  - категория `all` и пусто → онбординг-empty-state (`home_empty_title/subtitle/add`) с кнопкой → `pushNamed(TakeorUploadPageWidget.routeName)`.
  - иначе → текст `xtop_empty`.
- **Тайл товара:** `InkWell` onTap → (если canPop → pop) → `pushNamed(Itemcard2Widget.routeName, {imageid})`. Внутри `ImagedetailedMainWidget` (imageUrl, brand, name, score=saCompositeScore, stars=0, tags=saBestForTags, hasSpf=saHasSpf, imageID, avgPrice/priceCurrencyCode из priceMap).
- Navbar скрывается при видимой клавиатуре. `onScrollToTop` анимирует scrollController к 0.

### Класс `_HomeQuotaBar` (StatelessWidget)
Бар квоты под блоком скана. Если `isPro` → «home_pro_unlimited» с ∞. Иначе: `remaining = (weekLimit − scansUsed).clamp`, прогресс-бар (красный при исчерпании), метка `home_scans_left` ({remaining}/{limit}) + метка сброса `_resetLabel` (`home_resets_today`/`_tomorrow`/`_days` с {n}). Сброс = `weekResetDate + 7 дней`.

---

## lib/home/home/home_model.dart (48 строк)
`HomeModel`. Поля: `searchActive`, `autoScrollActive`; `usersanswer` (List<UsersRow>), `countrieshome` (List<CountriesRow>), `navbarModel`; `imagesFuture` (кэш future, чтобы FutureBuilder не рефетчил на каждый rebuild), `loadedImages` (последний успешный список), `selectedCategory='all'`, `priceMap` (Map ключ→ProductPricesRow), `scrollController`.

---

## lib/home/takeor_upload_page/takeor_upload_page_widget.dart (1789 строк) — ЭКРАН СКАНИРОВАНИЯ, ГЛАВНЫЙ ПАЙПЛАЙН

**routeName:** `'TakeorUploadPage'` · **routePath:** `/takeorUploadPage` · **navbar activePage:** 5

### Назначение
Экран с анимированной иллюстрацией сканера, подсказкой по фото, двумя кнопками (камера / галерея). Обе кнопки запускают одинаковый 3-стадийный бэкенд-пайплайн. При работе пайплайна — полноэкранный `AnalysisLoadingWidget`.

### Класс `TakeorUploadPageWidget` / `_TakeorUploadPageWidgetState` (TickerProviderStateMixin)
Поля: `_model`, `scaffoldKey`, `_hintExpanded`, `animationsMap`.

**initState (PostFrameCallback):**
- Сбрасывает `analysisloading=false`, `Producanalysstate=0`, `uploadedimageurl=''`.
- Загружает `_model.useranalyspage` (UsersTable по uid) и `_model.countriesRaw` (CountriesTable по countryId пользователя).
- Анимация вращения иконки (loop).
- `_loadHintState()`.

### Пошаговый пайплайн скана (общий для камеры и галереи)
Стадии одинаковые; различие — источник фото и поля модели (`*_Camera` vs `*_Gallary`, имена перепутаны местами — см. ниже).

**Предварительные гейты (в onPressed кнопок `_buildCameraButton`/`_buildGalleryButton`):**
1. Локальный лимит: `if (appState.analysesused >= appState.freeScanLimit) → _showLimitOut(context); return;`
2. `_ensureCountrySet()` — если нет сессии → `signInAnonymously`; если у пользователя нет `countryId` → показать `GuestPrefsSheet` (bottom sheet выбора страны), затем перечитать user/country и записать `countrycode`/`countrycodeiso`.

**Выбор и загрузка фото:**
3. `selectMedia(storageFolderPath:'users_images', ...)` — камера без mediaSource, галерея с `MediaSource.photoGallery`. Оба `multiImage:false`. Ошибка → `FirebaseCrashlytics.recordError`, return. Отмена/невалидный формат → return.
4. `validateFileFormat` для каждого файла.
5. Флаг `isDataUploading_*=true`; создаётся `FFUploadedFile`; `uploadSupabaseStorageFiles(bucketName:'images')`. Ошибка → Crashlytics, return. finally сбрасывает флаг.
6. Проверка совпадения количества файлов/URL; при успехе пишет `uploadedLocalFile_*` и `uploadedFileUrl_*`.

**Стадия 1 — extract product info:**
7. Аналитика `trackAnalysisStarted(source: 'camera'/'gallery')`.
8. `analysisloading=true`, очистка `extractedProductName/Brand`.
9. `uploadedimageurl`/`uploudedimagepath` = URL; `Producanalysstate=1`.
10. `ExtractproductinfoNEWBCNDCopyCall.call(host, imageUrl, userId, languageCode, country=countrycode, token)`.
11. Если `succeeded`: `Producanalysstate=2`, пишет `extractedProductName`/`extractedBrand` из ответа.
    - **Ошибка extract:** если **429** → pro: `ErrorPopupWidget.show(subscriptionSync)`; не-pro: bottom-sheet `LimitOutWidget(limit=quotaUsed||20, date=resetTime, isPro:false)`. Иначе → `TelegrammessegeCall` + `ErrorPopupWidget.show(productNotFound)` + удаление image по iamgeID из `ImagesTable`. Всегда сброс `uploadedimageurl/analysisloading/Producanalysstate` и return.

**Стадия 2 — search ingredients:**
12. `SearchingredientsNEWBCNDCall.call(host, imageId, productName, brand, country=code из countriesRaw, token)`.
13. Ветвление по `statusCode`:
    - **200** → стадия 3 (научный анализ).
    - **400** → `productNotFound` + удаление image.
    - **429** → лимит (pro: subscriptionSync; не-pro: `LimitOutWidget(limit=.limit(), date=.resettime())`) + удаление image.
    - **500** → Crashlytics.log + `pushNamed(HomeWidget.routeName)` + удаление image + `ErrorPopupWidget.show(generic)`.
    - **422** → `ErrorPopupWidget.show(unsupported)` + удаление image.
    - **404** → `_handleIngredientsNotFound(imageId, languageCode)` — ручной ввод состава (см. ниже).
    - иначе → `TelegrammessegeCall` + `productNotFound` + удаление image.

**Стадия 3 — scientific analysis:**
14. `Producanalysstate=3`; `ScientificanalysisNEWBCNDCall.call(host, imageId, userId, languageCode, token)`.
15. Если `succeeded`:
    - Если **statusCode 202** (анализ отложен) → `_showPendingResearchDialog(context)` (диалог «ждите») + фоновый `unawaited(ResearchAndAnalyzeCall.call(...))`.
    - `feedbackPendingScan=true`.
    - `CosmeticBagIntroWidget.handleScanSuccess(context, imageId, mounted)` — если вернул true (перехватил навигацию, показал интро косметички), сброс стейта и return.
    - Если НЕ mounted → навигация через `appNavigatorKey.currentContext.pushNamed(Itemcard2Widget.routeName, {imageid})`.
    - Иначе → `context.pushNamed(Itemcard2Widget.routeName, {imageid})`. **← ОСНОВНАЯ ТОЧКА ПЕРЕХОДА К РЕЗУЛЬТАТУ.**
    - После возврата: сброс `uploadedimageurl/analysisloading/Producanalysstate`.
    - Если НЕ succeeded: 422 → `unsupported`; иначе `TelegrammessegeCall` + `productNotFound`; удаление image.

### Особенности/баг-риски пайплайна
- **Перепутаны имена полей модели:** в камерной ветке результат scientific пишется в `_model.scientificanalysresultgalary`, а search — в `_model.analyseImageProductNameCamera`; в галерейной ветке — `scientificanalysresultcamara` и `analyseImageProductName`. То есть суффиксы Camera/Gallary местами инвертированы (унаследовано от FlutterFlow, работает, но сбивает с толку).
- Галерейный пайплайн вынесен в отдельный метод `_runGalleryAnalysisFromModel(context)` (много debugPrint `[gallery]`), камерный — инлайн в onPressed кнопки.
- При каждой ветке ошибки удаляется созданная запись image (кроме 429 на extract — там image ещё не создан, комментарий «quota check ran before image creation»).

### Ключевые методы
- `_showPendingResearchDialog(context)` — модальный Dialog «анализ в процессе» (локализация `tu_title`/`tu_body`/`tu_button`), иконка песочных часов.
- `_ensureCountrySet()` — см. выше (анонимный вход + GuestPrefsSheet).
- `_handleIngredientsNotFound({imageId, languageCode})` — при 404: `ErrorPopupWidget.showIngredientInput` (пользователь вводит состав вручную). Пусто → удалить image, выход. Иначе `SetProductIngredientsCall.call` → повторный `ScientificanalysisNEWBCNDCall` → та же логика 202/успех/навигация к Itemcard2, иначе ошибка + удаление.
- `_loadHintState()` — SharedPreferences `hint_upload_seen`: при первом заходе раскрывает подсказку (`_hintExpanded=true`).
- `_resetDateString()` — строка даты сброса из `weekResetDate + 7 дней`.
- `_showLimitOut(context)` — bottom-sheet `LimitOutWidget(limit=analysesused, date=_resetDateString, isPro:false)`.
- `_buildCameraButton` / `_buildGalleryButton` — кнопки с полным пайплайном в onPressed. Текст: `xirptk6c` «Take a photo», `pznd0mgm` «Choose from gallery».

**build:** Stack: иллюстрация `_ScannerIllustration` (когда НЕ loading), нижняя зона (`_HintCard` + 2 кнопки), полноэкранный `AnalysisLoadingWidget` (когда loading), Navbar внизу (activePage 5, analysesused).

### Вложенные приватные виджеты
- `_ScannerIllustration` (Stateful, SingleTicker) — анимированный сканер: радиальное свечение, 3 пульсирующих кольца, центральный градиентный круг с иконкой камеры, движущийся луч сканирования (sin).
- `_HintCard` (Stateless) — сворачиваемая карточка подсказок по фото (`c793vezr` «Photo tips», tips `byujsu2p`/`dcho9j17`/`be3z130n`, картинка `assets/images/image_(6).jpg`). Collapsed/expanded режимы.

---

## lib/home/takeor_upload_page/takeor_upload_page_model.dart (54 строки)
`TakeorUploadPageModel`. Поля: `useranalyspage` (UsersRow), `countriesRaw` (CountriesRow); по камере: `checkifallowedCamera`, `isDataUploading_uploadImageSupabaseCamera`, `uploadedLocalFile_*`, `uploadedFileUrl_*`, `extractedproductcamera`, `analyseImageProductNameCamera`, `scientificanalysresultgalary`; по галерее: аналогичные `*Gallary`, `extractedproductGalary`, `analyseImageProductName`, `scientificanalysresultcamara`; `navbarModel`. (Суффиксы Camera/Gallary частично инвертированы — см. выше.)

---

## lib/home/startanalys/startanalys_widget.dart (273 строки) — ВСПОМОГАТЕЛЬНЫЙ КОМПОНЕНТ
**Без routeName** (компонент «New Component Gen»). Карточка-баннер «AI Analysis / Scan a Product» с градиентом и кнопкой «Start».

⚠️ **Важно:** кнопка «Start» (`zyx01ncu`) имеет `onPressed: () { print('Button pressed ...'); }` — **заглушка, ничего не делает** (не навигирует). Похоже, компонент не подключён к активному флоу либо частично deprecated.

- `_resetLabel(context, resetStart)` — метка сброса квоты (аналог Home).
- `_QuotaStatusBar` (вложенный Stateless) — бар квоты на градиентном фоне: pro → `ic2_pro_unlimited` с ∞; иначе прогресс + `home_scans_left` + resetLabel.

## lib/home/startanalys/startanalys_model.dart (11 строк)
`StartanalysModel` — пустой boilerplate (initState/dispose no-op).

---

## lib/itemcard2/itemcard2_widget.dart (2088 строк) — КАРТОЧКА РЕЗУЛЬТАТА СКАНА

**routeName:** `'itemcard2'` · **routePath:** `/itemcard2` · Параметр: `imageid` (int?, query param).

### Назначение
Главная карточка результата анализа продукта: полноэкранное фото, бренд/название, композитный score (% распознанных ингредиентов), fit-card v2 (совместимость с типом кожи), SPF-блок, средняя цена, список ингредиентов INCI с подсветкой, разбор score, «How to use». Плюс FAB (SpeedDial) с действиями, баннер сохранения для анонимов, поллинг отложенного анализа.

### Класс `Itemcard2Widget` / `_Itemcard2WidgetState` (TickerProviderStateMixin)
Поля: `_model`, `scaffoldKey`, `_pendingPollingTimer`, `animationsMap`.

**initState (PostFrameCallback):**
- Аналитика `trackCardOpened(imageId, source:'direct')`.
- `_loadAnalysis()` — грузит основную строку + аналитические таблицы.
- **Цена:** из `ProductPricesTable` по `product_name_key`+`brand_key`+`country_code`(countrycodeiso), limit 1 → `_model.priceRow`.
- **Профиль кожи** (для fit-card): из UsersTable — `userSkinType`, `userIsSensitive` (skinSensitivity || skinType=='sensitive'), `userIsAcneProne` (skinType=='acne_prone' || goals содержит 'acne'). В try/catch — колонки могут отсутствовать до v2-миграции (cold start).
- `loading=false`.
- **Retry отложенного анализа:** если `saCompositeScore == null` и есть imageid → повторный `ScientificanalysisNEWBCNDCall`. Если вернул 200 → перезагрузка. Иначе (всё ещё 202) → `_startPendingPolling()`.
- **Промпт обратной связи:** если `feedbackPendingScan` и `FeedbackService.shouldShowPrompt` → сбросить флаг, `recordShown`, лог `feedback_prompt_shown`, задержка 3 сек → диалог `FeedbackCollectorWidget`.

**Методы:**
- `_loadAnalysis()` — грузит `imageraw` (ImagesTable), `skinCompabilityRaw` (ImageSkinCompatibilityTable), `topIngredientsRaw` (ImageTopIngredientsTable), `ingredientIssuesRaw` (ImageIngredientIssuesTable) — все по `image_id`.
- `_startPendingPolling()` — Timer.periodic каждые **6 сек**: перечитывает image; когда `saCompositeScore > 0` → отменить таймер, `_loadAnalysis`, setState. Отменяется в dispose.
- `_currencySymbol(code)` / `_formatPrice(price, code)` — форматирование цены (13 валют: ARS/CAD/CLP/CNY/COP/EUR/GBP/JPY/KRW/MXN/PEN/RUB/USD).
- `_buildPendingPlaceholder(context)` — плейсхолдер отложенного анализа: анимация колбы `_FlaskResearchAnimation` + `analysis_pending_title`/`analysis_pending_body`.

**build:** FutureBuilder(querySingleRow по imageid).
- Ошибка → иконка + Retry. Нет данных → спиннер. Строка null → текст `item_not_found`.
- Scaffold с `extendBodyBehindAppBar`, FAB `SpeedDial` (см. ниже) и телом (Stack).

### FAB SpeedDial — действия над карточкой (гейтинг по владельцу/pro)
Иконка `tune`. Дочерние (с локализацией `fab_*`):
- **Print label** (`fab_print`) → `pushNamed(ShareproductWidget.routeName, {imageid})`.
- **Share link** (`fab_share`) → `trackShareLinkTapped`, `Share.share('https://mirra.up.railway.app/product/{imageid}')`.
- **Add to album** (`fab_add_to_album`) → грузит `AlbumTable` по user; если 0 альбомов → `NewAlbumWidget`, иначе `AlbumslistWidget(imageID, albums)`.
- **Add/Remove favourite** — только владелец (`user==currentUserUid`), видимость по `favourite`. Пишет `favourite` в ImagesTable, аналитика, snackbar.
- **Hide from public** (`fab_hide`, владелец, не скрыт): **если pro** → пишет `hided:true` + `MakeprivateWidget`; **если НЕ pro** → `HidenavailabilityWidget(imageid:0)` (гейт — предложение подписки, товар НЕ скрывается).
- **Make public** (`fab_show`, владелец, скрыт) → `hided:false` + `MakepublicWidget`.
- **Mark as spam** (`fab_spam`, НЕ владелец) → `MarkasspamWidget`; при подтверждении snackbar + `safePop()`.
- **Copy product** (`fab_copy`, НЕ владелец): если аноним/пустой uid → `_LoginRequiredSheet` (гейт логина); иначе `CopyitemWidget(imageid)`.
- **Delete** (`fab_delete`, владелец) → `DeleteitemWidget(imageid)`.

### Тело карточки (когда НЕ loading)
- **Шапка (градиент primary→#A7B6CC):** полноэкранное фото (`OctoImage` с BlurHash-плейсхолдером, `ResizeImage width:1080` — защита от OOM), топ-градиент для читаемости статусбара. Бренд (SelectableText) + название. **Score-бейдж** (только если `saCompositeScore != null`): иконка колбы + процент = `round(saIngredientsRecognized / saIngredientsTotal * 100)`. Ниже — теги `saBestForTags` (Wrap чипов).
- **Гейтинг отложенного анализа:** если `saCompositeScore == null` → `_buildPendingPlaceholder` (колба + «ждите»). Иначе показываются все аналитические секции:
  - `ProductCardV2Widget` — fit-card v2 (image, skinCompatibility, topIngredients, ingredientIssues, userSkinType/IsSensitive/IsAcneProne, **isPro: true** — хардкод). Комментарий: тапы по матрице типов кожи эфемерны, в профиль не пишутся.
  - **SPF-блок** (все пользователи, только если `saHasSpf`): парсит `saScoringLog['spf_info']` → filter_type (mineral/chemical/combined), broad_spectrum, список фильтров. Локализация `ic2_uv_protection`/`ic2_filter_*`/`ic2_broad_spectrum`/`ic2_filters`. Строки через `_SpfLegendRow`.
  - **Средняя цена** (скрыто пока `priceRow?.avgPrice == null`): avg + диапазон min–max + код валюты.
  - `IngridientsWidget` — состав INCI с подсветкой top/issue ингредиентов.
  - `ScoreBreakdownWidget` — разбор score; INCI-список берётся из `saInciList` или клиентский split (regex `,(?!\s*\d)|\n`, сохраняет «1,2-Hexanediol»), плюс `saOnePercentLinePos`.
  - **How to use** (`sdd57mig`) — `saHowToUse`.
  - Нижний спейсер: 80px для анонима (под sticky-баннер), иначе 40px.
- Оверлей loading (крутящаяся иконка).
- **Баннер анонима:** если `currentUserIsAnonymous` → `_AnonSaveBanner` внизу (sticky).
- Фиксированная кнопка «назад» (top-left) → `context.safePop()`.

### Вложенные приватные виджеты/шиты/баннеры
- `_AnonSaveBanner` (Stateless) — sticky-баннер для анонима: «Save to history» (`ic2_save_to_history`) + CTA «Sign in / create» (`ic2_signin_create`). onTap → `_AnonSaveSheet`.
- `_AnonSaveSheet` (Stateless) — bottom-sheet: заголовок `ic2_save_title`/`ic2_save_body`; кнопки → `pushNamed(CreateAccountPageWidget.routeName)` (`cm_create_account`), `pushNamed(LogInPageWidget.routeName)` (`ic2_sign_in`), «Not now» (`ic2_not_now`).
- `_KeyFactRow` (Stateless) — строка «факта» с эмодзи ✅/⚠️ (isWarning), name + detail. (В прочитанном билде используется опосредованно.)
- `_LoginRequiredSheet` (Stateless) — гейт логина для copy (аноним): `copy_login_title/body/btn/cancel` → `pushNamed(LogInPageWidget.routeName)`.
- `_FlaskResearchAnimation` + `_FlaskPainter` (CustomPainter) — анимированная колба Эрленмейера (жидкость двумя волнами, пузырьки, искры) для плейсхолдера отложенного анализа.
- `_SpfLegendRow` (Stateless) — строка SPF-легенды (иконка + label:value через RichText).

### Обработка ошибок/пустых данных
- Нет строки image → `item_not_found`. Ошибка future → Retry. `saCompositeScore == null` → плейсхолдер + retry/поллинг научного анализа. Цена/SPF-блоки скрываются при отсутствии данных.

---

## lib/itemcard2/itemcard2_model.dart (49 строк)
`Itemcard2Model`. Поля: `loading=true`, `optiondropdownopen`; `imageraw` (ImagesRow), `skinCompabilityRaw`, `topIngredientsRaw`, `ingredientIssuesRaw`; `ingridientsModel`; `albums` (AlbumRow); `priceRow` (ProductPricesRow); профиль кожи `userSkinType`, `userIsSensitive`, `userIsAcneProne` (дефолтный контекст fit-card, тапы матрицы не пишутся в профиль).

---

## lib/item_card/ (10 файлов) — вспомогательные виджеты карточки

Все модели (`deleteitem_model`, `imagedetailed_main_model`, `imagedetailed_top_raited_model`, `ingridients_model`, `markasspam_model`) — тривиальный FlutterFlow boilerplate (~11 строк: `onUpdate`/`initState`/`maybeDispose`, поле `unfocusNode` в старых). Ниже — только виджеты.

### lib/item_card/imagedetailed_main/imagedetailed_main_widget.dart (429 строк)
`ImagedetailedMainWidget` (Stateful) — **тайл товара в сетке Home**. Пропсы: imageUrl, brand, name, score, tags, imageID, stars, avgPrice, priceCurrencyCode, hasSpf. Фото `OctoImage` (ResizeImage width:720, BlurHash-плейсхолдер, защита от OOM), градиент, `_ScoreBadge` (top-left), SPF-бейдж (bottom-left если hasSpf), ценник `~ {price}` (bottom-right если avgPrice). Бренд/название, звёзды (по `stars`).
- `_scoreColor(score)` — цветовая шкала (>=75 тёмно-зелёный ... <35 красный).
- `_formatCardPrice(price, code)` — 13 валют.
- `_ScoreBadge` (Stateless) — бейдж: буква-грейд A–F (по порогам 75/65/55/45/35) в `CircularPercentIndicator` + «{score}/100». Если score null → иконка колбы + «···» (анализ ещё идёт).

### lib/item_card/imagedetailed_top_raited/imagedetailed_top_raited_widget.dart (322 строки)
`ImagedetailedTopRaitedWidget` — почти копия main-тайла, для экрана топ-рейтингов. Отличия: нет `stars`/`hasSpf`. Тот же `_ScoreBadge` (грейд A–F, «/100», «···» при null), `_formatCardPrice`.

### lib/item_card/ingridients/ingridients_widget.dart (201 строка)
`IngridientsWidget` (Stateful) — блок состава INCI внутри Itemcard2. Пропсы: `ingridients` (строка), `topIngredients`, `issueIngredients`. Токенизирует состав по запятой, подсвечивает: зелёным (`_greenBg/_greenText`, «Active») ингредиенты из topIngredients, красным (`_redBg/_redText`, «Issues») из issueIngredients. Заголовок `11yiut5a` «Ingredients (INCI)». Легенда (`_LegendDot`) показывается только при наличии подсветок. Пустой состав → «-».

### lib/item_card/deleteitem/deleteitem_widget.dart (181 строка)
`DeleteitemWidget` (Stateful, props imageid) — диалог подтверждения удаления. Заголовок `ww2bynjy`, подзаголовок `ejy0zcsp`. Кнопка удаления (`y814btsy`) → `ImagesTable().delete(id==imageid)` → `context.go(HomeWidget.routePath)`. Отмена (`ood20cri`) → `Navigator.pop`.

### lib/item_card/markasspam/markasspam_widget.dart (203 строки)
`MarkasspamWidget` (Stateful, props imageid) — диалог «пометить как спам». Заголовок `tost89il`, текст `0whnywol`. Cancel (`h4qorptg`) → pop. Hide (`899uf23u`) → `FFAppState().addToSpamlist(imageid)` + `UsersTable().update(spam_images: spamlist)` по uid → `Navigator.pop(context, true)` (возвращает true — Itemcard2 показывает snackbar и делает safePop).


---

# Прочие модули (paywall, topratings, boards, search, settings, limits, auth, custom_code, main)

Документация по оставшимся директориям `lib/`. Идентификаторы кода — на английском, описания — на русском.
Всего задокументировано 56 `.dart`-файлов.

## Сквозные понятия (важно для гипотез)

- **Флаг Pro:** `FFAppState().isprouser` (bool). Устанавливается в `true` только внутри paywall после успешной покупки и подтверждения entitlement. Именно он гейтит Pro-функции в UI.
- **RevenueCat (RC):** ключ приложения `appl_nlqWcEvNVGNUCbMcdEcsbKbwNrV` (инициализация в `main.dart`). Entitlement — `EntitlementMirra`. Offering — `defaultmirra`. Пакеты — `$rc_weekly` (недельный) и `$rc_annual` (годовой). App User ID в RC привязывается к Supabase UID (`currentUserUid`) + атрибут `supabase_uid` для сопоставления вебхуков на бэкенде.
- **Локализация:** `FFLocalizations.of(context).getText('<key>')`, языки — `kAppLanguages` / `kSupportedLanguages`. Многие экраны хардкодят строки switch по `languageCode` (ru/es/en) вместо ключей — например `search`, фильтры `toprated`.
- **Supabase-таблицы** используются напрямую через `*Table().queryRows/update/delete`; бэкенд-вызовы — через `*Call.call(...)` из `api_calls.dart`.

---

## `lib/main.dart` — точка входа и роутинг

`void main()` (async) — последовательность инициализации:
1. `WidgetsFlutterBinding.ensureInitialized()`, включение path-URL стратегии.
2. `FFDevEnvironmentValues().initialize()` — загрузка env (в т.ч. `backendhost`).
3. **Supabase стартует параллельно** с Firebase: `SupaFlow.initialize()` запускается как future, затем `await initFirebase()`, и позже `await supaFuture`.
4. `FlutterError.onError` — все ошибки framework уходят в Crashlytics. Осознанно вызывается `recordError()` вместо `recordFlutterFatalError()` (иначе рекурсия → stack overflow). Ряд ошибок помечается **non-fatal**: фоновый refresh токена GoTrue (`_autoRefreshTokenTick`, `GoTrueClient`), падения google_fonts, сетевые ошибки Postgrest/`ClientException`/`SocketException`/`TimeoutException`.
5. `PlatformDispatcher.instance.onError` — платформенные/async ошибки → Crashlytics (fatal).
6. `actions.lockOrientation()` — фиксация портретной ориентации.
7. `FFLocalizations.initialize()`, инициализация `FFAppState().initializePersistedState()`.
8. `runApp(ChangeNotifierProvider(create: appState, child: MyApp()))`.
9. В `addPostFrameCallback`: `fetchRemoteConfig()` и `revenue_cat.initialize(...)` (с RC-ключом, `loadDataAfterLaunch: true`).

`MyApp` / `_MyAppState`:
- Хранит `_locale` (из `FFLocalizations.getStoredLocale()`), `_themeMode` (по умолчанию `ThemeMode.system`; тема захардкожена в light, `useMaterial3: false`).
- `_router = createRouter(...)` (GoRouter из `flutter_flow/nav`).
- **Auth stream:** `miRRADevSupabaseUserStream()` слушается — при каждом изменении `_appStateNotifier.update(user)`; при `loggedIn` вызывает `NotificationService.instance.onUserLogin()` и ставит Crashlytics userId; при logout — очищает userId.
- **Push-уведомления:** `NotificationService.instance.init(onTap:)` — тап по пушу: `route=='routine'` → `/routineCalendar`; иначе если есть `image_id` → `/itemcard2?imageid=$imageId`.
- **Deep links (`_initDeepLinks`):** через `app_links`. Обрабатывает Universal Links вида `.../product/{id}`: `getInitialLink()` (запуск из терминированного состояния) и `uriLinkStream` (в фоне/работе). `_handleDeepLink`: если path = `product/{id}` и id парсится → `_router.go('/itemcard2?imageid=$id')`.
- `setLocale(language)` — меняет локаль и сохраняет через `FFLocalizations.storeLocale`.
- `build` — `MaterialApp.router` с делегатами локализации и fallback-делегатами.

## `lib/index.dart`
Реэкспорт страниц/виджетов (barrel-файл): create_account, log_in, onboarding (profile/quiz), boards, home, profile, imagesby_album, forgot_password, edit_profile, toprated, **paywallpage**, langs, takeor_upload, countries, newblank, cosmetic_bag(_intro), compatibility_result, routine_calendar, itemcard2, shareproduct, search.

---

## `lib/paywall/` — покупки и подписка

### `paywall/paywallpage/paywallpage_widget.dart`
Главный экран пейволла. `routeName='Paywallpage'`, `routePath='/paywallpage'`.
- `initState`: в postFrame выставляет `FFAppState().subscriptionmonth = false` (**по умолчанию годовой план**). Если офферинги ещё не загружены (`revenue_cat.offerings?.current?.weekly/annual == null`) — ставит `_offeringsLoading=true` и `revenue_cat.loadOfferings()`.
- `_offeringsReady` — оба пакета (weekly и annual) доступны.
- UI: анимированный фон `AnimatedPaywallBg`, кнопка закрытия (`context.pop()` или fallback на Home), заголовок «UPGRADE TO PRO», список фич `PremiumFeaturesListWidget`. Пока офферинги грузятся/не готовы — спиннер вместо карточек тарифов.
- **Две карточки тарифов**, выбор хранится в `FFAppState().subscriptionmonth` (true=weekly, false=annual). Цена «в месяц» считается на клиенте: weekly → `price*52/12`; annual → `price/12`. У годового бейдж и метка «TWO MONTHS FREE».
- **Логика покупки (кнопка Continue), одинакова для обоих тарифов:**
  1. `subscriptionmonth = true/false`.
  2. `rCUserID = actions.rcEnsureLogin(context, currentUserUid)`.
  3. `rCPayment = actions.rcPurchasePackage(context, 'defaultmirra', '$rc_weekly'|'$rc_annual', currentUserUid)`.
  4. Если результат `MessegefrompaymentStruct.hasOk()==true`: `rcRefreshEntitlement(context, 'EntitlementMirra')`. Если entitlement активен →
     - `FFAppState().isprouser = true`;
     - бэкенд-вызов `SubscriptionupgradeNEWBCNDCall.call(host: backendhost, durationDays: 7|365, userId: currentUserUid)`;
     - уведомление в Telegram `TelegrammessegeCall.call(...)` (form `Monthpayment` / `subscription year`).
  5. Если `!ok` — SnackBar: при `cancelled` ключ `pu7x1ck3`, иначе `pe2n5jf8`.
- **Restore Purchases:** `rcEnsureLogin` → `revenue_cat.restorePurchases()` → `revenue_cat.isEntitled('EntitlementMirra')`. Если entitlement нет — `loadOfferings()`. SnackBar об успехе (`rs4p1dq2`) / неудаче (`rf9m3wk5`). **Замечание:** при успешном restore `isprouser` в этом обработчике НЕ выставляется явно (в отличие от покупки).
- Ссылки: Privacy Policy (`mirra.up.railway.app/privacy.html`), Terms of use (стандартный Apple EULA).

### `paywall/paywallpage/paywallpage_model.dart`
Хранит выходы действий: `rCUserID/2/3`, `rCPayment/2` (dynamic), `rcRefreshEntitlement/2` (bool), `subscriptionmonth`/`yearsubscription` (ApiCallResponse), модель `premiumFeaturesListModel`.

### `paywall/upgrade/upgrade_widget.dart`
Мелкая кнопка-виджет «Update a Pro» (иконка `auto_awesome`). По тапу — `HapticFeedback.lightImpact()` + `context.pushNamed(PaywallpageWidget.routeName)`. Модель `upgrade_model.dart` — пустая заглушка.

---

## `lib/limits/` — лимит бесплатного тарифа

### `limits/limit_out/limit_out_widget.dart`
Диалоговый виджет «Limit reached». Параметры: `limit` (int, сколько использовано), `date` (String, дата сброса), `isPro` (bool).
- Текст: «You've used **{limit}** ... **{date}**» (склеивается из ключей `5vf31bag` + `9iwfkse3`).
- Если `isPro==true` — кнопка «Got it»: `Navigator.pop` + `pushNamed(HomeWidget)`.
- Если `isPro==false` — кнопка «Upgrade to Pro»: `Navigator.pop` + `pushNamed(PaywallpageWidget)`.
- **Важно:** сам счётчик/пороги лимита и логика сброса тут НЕ реализованы — виджет только показывает переданные значения. Значения лимита/даты приходят снаружи (с бэкенда `/quota`, ср. коммит «сброс лимита сканов берём из /quota»). Здесь только отображение и развилка Pro/не-Pro. Модель — пустая заглушка.

---

## `lib/auth/` — аутентификация (Supabase)

### `auth/auth_manager.dart`
Абстрактный `AuthManager` (signOut, deleteUser, updateEmail, resetPassword, sendEmailVerification, refreshUser) + миксины для провайдеров (Email, Anonymous, Apple, Google, Jwt, Phone, Facebook, Microsoft, Github). Реально используются Email/Anonymous/Apple.

### `auth/base_auth_user_provider.dart`
`AuthUserInfo` (uid/email/displayName/photoUrl/phoneNumber) и абстрактный `BaseAuthUser` (loggedIn, emailVerified, delete/update/refresh). Глобальные `currentUser` и `loggedIn`.

### `auth/supabase_auth/auth_util.dart`
Геттеры текущего пользователя: `currentUserEmail`, `currentUserUid`, `currentUserDisplayName`, `currentUserPhoto`, `currentPhoneNumber`, `currentJwtToken`, `currentUserEmailVerified`, `currentUserIsAnonymous`. `_authManager` (singleton `SupabaseAuthManager`). `jwtTokenStream` — broadcast-стрим access-токена из `onAuthStateChange`.

### `auth/supabase_auth/supabase_auth_manager.dart` — ключевая логика входа/анонимности
- `signOut()` → `SupaFlow.client.auth.signOut()`.
- `deleteUser` — только через `currentUser?.delete()` (но `delete()` в провайдере бросает `UnsupportedError` — реальное удаление аккаунта тут НЕ поддержано).
- `updateEmail` / `updatePassword` / `resetPassword` — через Supabase Auth, ошибки показываются SnackBar.
- **Анонимные сессии и «claim» сканов:**
  - `signInWithEmail`: если текущая сессия анонимна — запоминает `anonUid` до входа; после успешного входа вызывает `_claimAnonScans(anonUid)`.
  - `signInWithApple`: то же самое (запоминает anonUid, после входа `_claimAnonScans`).
  - `createAccountWithEmail`: если уже анонимный пользователь — `_linkEmailToAnonymousAccount` (обновляет UserAttributes email+password, **UUID не меняется, все сканы сохраняются**), иначе обычное создание.
  - `signInAnonymously()` → `SupaFlow.client.auth.signInAnonymously()`, обновляет `currentUser` и `AppStateNotifier`.
  - `_claimAnonScans(anonUid)` → Supabase RPC `claim_anonymous_scans` с `anon_uid`. **Best-effort:** ошибки не блокируют вход (debugPrint).
  - `_isCurrentUserAnonymous()` — по `MiRRADevSupabaseUser.isAnonymous`.
- `_signInOrCreateAccount` — общий помощник: оборачивает функцию входа, обновляет `currentUser`+`AppStateNotifier`. Особая обработка «User already registered».

### `auth/supabase_auth/supabase_user_provider.dart`
`MiRRADevSupabaseUser extends BaseAuthUser`: `loggedIn`(user!=null), `isAnonymous`, `authUserInfo`, `updateEmail/updatePassword` через Supabase. `delete()` и `sendEmailVerification()` → `UnsupportedError`. `emailVerified` — по `emailConfirmedAt`, при null триггерит `refreshUser()`. `miRRADevSupabaseUserStream()` — стрим с debounce на `tokenRefreshed` (1с) и стартовым null.

### `auth/supabase_auth/email_auth.dart`
`emailSignInFunc(email,password)` → `signInWithPassword`. `emailCreateAccountFunc` → `signUp`; возвращает null если `lastSignInAt==null` (не подтверждён email).

### `auth/supabase_auth/apple_auth.dart`
`appleSignInFunc()`: на web — OAuth-flow; на нативе — nonce (raw+sha256), `SignInWithApple.getAppleIDCredential` (scopes email+fullName), `signInWithIdToken(provider: apple, idToken, nonce)`.

**Что сбрасывается при logout:** сам `signOut()` только очищает сессию Supabase. Далее auth-stream в `main.dart` при `!loggedIn` очищает Crashlytics userId. `FFAppState().isprouser` **напрямую в коде logout не сбрасывается** — управляется entitlement/бэкендом. RC-логаут выполняется отдельным action `rcLogOutToAnonymous` (см. ниже), в просмотренном коде logout он не вызывается автоматически.

---

## `lib/custom_code/` — кастомные actions и widgets

### Actions (RevenueCat-обёртки над `purchases_flutter`)
`actions/index.dart` реэкспортирует все.

- **`lock_orientation.dart`** — `lockOrientation()`: фиксирует `portraitUp`.
- **`rc_get_app_user_id.dart`** — `rcGetAppUserId()`: `Purchases.appUserID` (для анонима это `RCAnonymousID:...`).
- **`rc_ensure_login.dart`** — `rcEnsureLogin(context, appUserId)`: если `appUserId` пуст (пейволл до создания аккаунта) — просто вернуть текущий RC id. Иначе, если текущий id != appUserId → `Purchases.logIn(appUserId)`, затем `Purchases.setAttributes({'supabase_uid': appUserId})`. Ошибки не пробрасываются (не блокируют покупку).
- **`rc_is_entitlement_active.dart`** — `rcIsEntitlementActive(context, entitlementId, appUserId?, loginIfUserId)`: опционально `logIn`, затем `getCustomerInfo()` и проверка `entitlements.active.containsKey(entitlementId)`. При ошибке → false.
- **`rc_refresh_entitlement.dart`** — `rcRefreshEntitlement(context, entitlementId)`: `invalidateCustomerInfoCache()` + `getCustomerInfo()` + проверка активности. Используется сразу после покупки.
- **`rc_purchase_package.dart`** — `rcPurchasePackage(context, offeringId, packageId, appUserId)`: логин (если id непустой) + `setAttributes`, `getOfferings()`, поиск offering и package, `purchasePackage(pkg)`. Возвращает `{ok:true, appUserId, activeEntitlements:[...]}` или при ошибке `{ok:false, cancelled:bool, code, message}` (`cancelled` определяется по `PurchasesErrorCode.purchaseCancelledError`).
- **`rc_log_out_to_anonymous.dart`** — `rcLogOutToAnonymous(context)`: `Purchases.logOut()` (SDK создаёт нового анонима), возвращает новый appUserID.

### Widgets
`widgets/index.dart` реэкспортирует AnimatedPaywallBg, ScoreCard, ShareCardWidget.

- **`animated_paywall_bg.dart`** — `AnimatedPaywallBg(width,height)`: анимированный фон пейволла. Тёмный градиент + 3 размытых «glow orbs» (пульсация по sin) + 25 плавающих частиц (`_ParticlePainter`). 10-секундный repeat-контроллер.
- **`score_card.dart`** — `ScoreCard(width,height,score,skinType)`: **пустая заглушка** (`build` возвращает `Container()`); не используется по факту.
- **`share_card_widget.dart`** — `ShareCardWidget(...)`: генерация и шаринг картинки-карточки продукта. Ключевое:
  - Локализация через `kTranslationsMap['sc_<key>']` по `lang`.
  - Формы: `_StoryCard` (9:16) и `_SquareCard` (1:1), выбор по `isStory`.
  - Оценка → цвет (`_scoreColor`, пороги 75/65/55/45/35) и буква A–F (`_scoreGrade`).
  - `_rightPanel`: бренд, имя, бейдж-оценка, мини-бары по осям (efficacy/safety/stability/experience/pore_safety), ингредиенты с подсветкой: `topIngredients` — зелёным, `issueIngredients` — красным (`_ingredientRichText`).
  - `_TagsSection`: хэштеги (#mirra + бренд + best-for теги), копирование в буфер.
  - `_captureAndShare()`: `RepaintBoundary.toImage(pixelRatio:3.0)` → PNG → `Share.shareXFiles(...)`; аналитика `AnalyticsService.instance.trackShareCardCreated(imageId, format)`.

---

## `lib/search/` — расширенный поиск продуктов

### `search/search_widget.dart`
`routeName='Search'`, `routePath='/search'`. Полностью кастомный (не FlutterFlow-стиль).
- **Словарь фасетов** `_kFacetGroups` (зеркалит бэкенд `search_facets.py`): form, goal, active, composition_flags, time_of_day, price_band. Режимы сортировки `_kSortModes`: fit/formula/price_asc/price_desc. Локализация лейблов — inline-мапы (`_groupLabel`, `_valueLabel`, `_sortLabel`).
- `_loadProfile()` — грузит профиль текущего юзера из `UsersTable` (для fit-scoring).
- `_parsePhrase()` — NL-парсинг: `ParseSearchPhraseCall.call(token, phrase, lang)`. Ответ добавляет распознанные фасеты в `activeFacets`, показывает `unparsed`, ставит `sortMode`, затем автоматически `_search()`.
- `_search({loadMore})` — `SearchProductsCall.call(token, facets: buildFacetsBody(), sort, profile: buildProfile(), cursor, limit:20)`. Пагинация по `cursor`/`has_more`. `narrowestFacet` — подсказка «убери фильтр X» при пустой выдаче.
- `_toggleFacet`, `_clearAll`. Результаты рендерятся `ImagedetailedMainWidget`, тап → `Itemcard2Widget` с `imageid`.

### `search/search_model.dart`
Поля: `phraseController/FocusNode`, `activeFacets` (Map<String,Set>), `sortMode`, флаги `isParsing/isSearching`, `results`, `totalCount`, `nextCursor`, `hasMore`, `narrowestFacet`, `hasSearched`, `userProfile` (UsersRow). `buildProfile()` — skin_type/goals/sensitivity/acne_prone. `buildFacetsBody()`, `hasAnyFacet`.

---

## `lib/settings/`

### `settings/langs/langs_widget.dart`
`routeName='Langs'`, `routePath='/langs'`. Список `kAppLanguages`. По тапу: `setAppLanguage(context, lang.code)` (меняет локаль приложения) + если пользователь залогинен — `UsersTable().update({'language_code': lang.code})`, затем `safePop`. Выбранный язык подсвечивается по `FFLocalizations.of(context).languageCode`.

### `settings/countries/countries_widget.dart`
`routeName='Countries'`, `routePath='/countries'`. FutureBuilder по `UsersRow` (текущий регион) + FutureBuilder по `CountriesTable` (список). По тапу: `UsersTable().update({'country_id': ...})` + `safePop`. Имя страны локализуется по `languageCode` (nameRu/nameEs/nameEn) + флаг-emoji. Регион влияет на показ локальных ритейлеров и цен (см. `toprated` — `product_prices` по `country_code`).

Модели `langs_model.dart` / `countries_model.dart` — заглушки с полем `langcode`.

---

## `lib/topratings/` — топ-рейтинг продуктов

### `topratings/toprated/toprated_widget.dart` — главный экран рейтинга
`routeName='Toprated'`, `routePath='/Toprated'`. Вкладка навбара `activePage:1`, `PopScope(canPop:false)`.
- `initState` (postFrame): грузит `UsersRow` (профиль, аватар → `FFAppState().userProfilePicture`), проверяет наличие пользователя (иначе → `LogInPageWidget`). Затем **единожды** грузит топ-картинки: `ImagesTable` где `user != currentUserUid`, `sa_composite_score >= 70.0`, `language_code == текущий`, сортировка по score desc, limit 50. При наличии `FFAppState().countrycodeiso` — `_loadPriceMap`.
- `_loadPriceMap(images)` — тянет цены из `ProductPricesTable` по `country_code` + `product_name_key IN [...]`, ключ мапы `product_name_key|brand_key`.
- **Фильтрация клиентская (`_filteredImages`):** исключает `FFAppState().spamlist`, дедуп по `brand|productName`, фильтр по категории (`_kCategoryTypes` мапит категорию → product_type). `_availableChips` — только категории, реально присутствующие в данных.
- **Bottom-sheet фильтров (`_showFilterSheet`):** фасеты `_kSheetFacets` (form/goal/active/composition_flags) + сортировка `_kSortOptions`. Применение → `_applyFilters` → серверный `SearchProductsCall.call(facets, sort, limit:50)`. Если фильтров нет — показывается локальный `MasonryGridView` топа; если есть — серверная выдача списком.
- Карточки: `ImagedetailedTopRaitedWidget` (с ценой из priceMap) для сетки, `ImagedetailedMainWidget` для отфильтрованного списка. Тап → `Itemcard2Widget`.

### `topratings/toprated/toprated_model.dart`
`userrow`, `usersanswer2` (UsersRow), `allImages` (ImagesRow), `selectedCategory='all'`, `priceMap`, скролл-контроллеры, `navbarModel`.

### `topratings/topratedproductspage/` — `TopratedproductspageWidget`
Статичный презентационный блок-баннер (иконка кубка, «Highest Safety Ratings»/«Products with the best ingredients...»). Модель — стандартная.

### Диалоги/поповеры topratings (компоненты, показываются через showModalBottomSheet/Dialog):
- **`copyitem/copyitem_widget.dart`** — `CopyitemWidget(imageid)`: подтверждение копирования чужого продукта себе. Кнопка Copy: `CopyproductNEWBCNDCall.call(host, sourceImageId, targetUserId: currentUserUid, token)`, извлекает `new_image_id` (`CopyproductNEWBCNDCall.newimageid(...)`), навигация в `Itemcard2Widget` с новым id. При ошибке — SnackBar. Есть `_isLoading` (блокировка кнопки).
- **`hidenavailability/hidenavailability_widget.dart`** — `HidenavailabilityWidget(imageid)`: **гейт Pro**. Сообщает «функция скрытия только для PRO», кнопка «Go PRO» → `PaywallpageWidget`.
- **`makeprivate/makeprivate_widget.dart`** — `MakeprivateWidget(imageid)`: инфо-поповер «Product hidden» (продукт скрыт от других), кнопка Ok. Само действие скрытия здесь НЕ выполняется — только уведомление.
- **`makepublic/makepublic_widget.dart`** и **`makepubluc/makepubluc_widget.dart`** — почти идентичные инфо-поповеры «Product visible to other users» (ключи `553khwzz`/`g7bez9em`/`dv0imp11`). `makepubluc` — **опечатка в имени, дублирующий виджет** (принимает `imageid`, `makepublic` — без параметров). Кандидаты на дедупликацию.
- **`emptytopfindings/emptytopfindings_widget.dart`** — `EmptytopfindingsWidget`: заглушка пустого состояния (текст «Here you'll see products with...»).

Модели этих компонентов (`*_model.dart`) — стандартные заглушки `FlutterFlowModel` без значимых полей.

---

## `lib/boards/` — доски/альбомы (избранное)

### `boards/boards/boards_widget.dart` — экран досок
`routeName='Boards'`, `routePath='/boards'`. Навбар `activePage:3`.
- В `initState` грузит `_connectionsFuture` (ImagesAlbumsConnection по user) и `_albumsFuture` (AlbumTable по user, сортировка created_at). `_refresh()` перезагружает оба future.
- Кнопка «New board» → bottom-sheet `NewAlbumWidget`, после закрытия `_refresh()`.
- Если альбомов нет → `NewboardemptyWidget(onBoardCreated: _refresh)`. Иначе `GridView` (2 колонки) из `_AlbumCard`.
- `_AlbumCard` → грузит до 4 картинок альбома (`AlbumImagesTable` по album_id+owner_id), рисует превью-коллаж (`_AlbumPreview`, сетка 2×2). Тап → `ImagesbyAlbumWidget` с `albumid`.

### `boards/imagesby_album/imagesby_album_widget.dart` — содержимое альбома
`routeName='imagesbyAlbum'`, `routePath='/imagesbyAlbum'`. Параметр `albumid`.
- `_albumFuture` (AlbumTable по id), `_imagesFuture` (`_loadImages`: сначала connections по album_id+user, затем `ImagesTable` по `id IN ids`).
- AppBar: назад + иконка edit → bottom-sheet `EditAlbumWidget(albumRef)`, после — `_refresh`.
- Пусто → иконка + текст `iba_empty`. Иначе `MasonryGridView` из `ImagedetailedMainWidget`, тап → `Itemcard2Widget`.

### `boards/edit_album/edit_album_widget.dart` — редактирование/удаление доски
`EditAlbumWidget(albumRef)` (bottom-sheet). Поле названия (Form + validator), сохранение: `AlbumTable().update({'name':...})`. Удаление `_confirmDeleteAlbum()`: AlertDialog-подтверждение (предупреждает, что продукты в доске тоже удалятся) → `AlbumTable().delete(id==albumRef)` → двойной pop. Кнопка Delete — цвет tertiary.

### `boards/albumslist/albumslist_widget.dart` — «добавить в доски» (мультивыбор)
`AlbumslistWidget(imageID, albums)` (bottom-sheet). В `initState` грузит уже добавленные альбомы (`ImagesAlbumsConnectionTable` по image_id) → предвыбор `albumsselected2` (через `functions.albumidsToList`). Тоггл чекбоксов с haptic. Кнопка Apply: `LinkitemtoalbumsCall.call(token, imageId, albumIdsList: albumsselected2)`, аналитика `trackProductAddedToBoard(imageId)`, `HapticFeedback.vibrate()`, pop.

### `boards/newboardempty/newboardempty_widget.dart` — пустое состояние досок
`NewboardemptyWidget(onBoardCreated)`: иллюстрация + «Your collections» + кнопка «Create collection» → bottom-sheet `NewAlbumWidget`, после закрытия `onBoardCreated?.call()`.

### Модели boards:
- `albumslist_model.dart` — список `albumsselected2` (+ хелперы add/remove/insert/update), `albumsalreadyadded2`.
- `edit_album_model.dart` — `formKey`, контроллер/фокус названия, валидатор.
- `boards_model.dart` / `imagesby_album_model.dart` / `newboardempty_model.dart` — стандартные (в boards_model только `navbarModel`).

---

## `lib/actions/actions.dart`
Два **пустых** action-блока: `se(context)` и `accountSetup(context)` — заглушки без реализации (тела пустые). Кандидаты на удаление, если нигде не вызываются осмысленно.
