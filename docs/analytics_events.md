# Разметка событий Amplitude

Источник схемы — таблица маркетинга «Mirra Marketing - Events» (85 событий).
Отправляются 83; два не отправляются, потому что под них нет экрана — см.
«Что изменилось против таблицы». Всего в коде 101 событие: 83 из таблицы и 18,
живших до неё.

Заполненная таблица со статусами лежит рядом:
`Mirra Marketing - Events (внедрено).csv`.

Этот файл описывает, что реально отправляет приложение и где именно.

Все события идут через `AnalyticsService` (`lib/flutter_flow/analytics_service.dart`).
Имя события нигде не пишется строкой на месте вызова: у каждого есть метод, так
что переименование ломает сборку, а не данные.

## Настройка

Ключ проекта лежит в `assets/environment_values/environment*.json` рядом с
`backendhost`. Заполнен только прод — события с дев-сборок не нужны:

| Сборка | Файл | Ключ |
|---|---|---|
| prod | `environment.json` | заполнен |
| dev (`APP_ENV=dev`) | `environment.dev.json` | пусто — аналитика выключена |
| local (`APP_ENV=local`) | `environment.local.json` | пусто — аналитика выключена |

Пустой ключ = сервис выключён, каждый вызов становится no-op. Приложение при
этом работает как обычно.

Проект живёт в **европейском** дата-центре, поэтому в конфигурации SDK задан
`serverZone: ServerZone.eu`. По умолчанию SDK шлёт в США — и события молча не
долетают, без единой ошибки на клиенте.

`APP_ENV` по умолчанию `prod`, так что обычный `flutter run` или Xcode Run —
это прод-сборка с ключом. Дев-аналитики нет вовсе, поэтому проверять разметку
нужно именно прод-сборкой; следите, чтобы в `ios/Flutter/Generated.xcconfig` не
залежался дев-дефайн от прошлой сборки.

## Что изменилось против таблицы

| В таблице | В коде | Почему |
|---|---|---|
| `onbording_*` (14 шт.) | `onboarding_*` | Опечатка в таблице: переименованы 11, ещё два переехали в `care_frames_*`, одно не отправляется. Переименовать после выхода в прод — потерять связность данных, дешевле поправить сейчас. |
| `onbording_pregnancy` | `care_frames_pregnancy` | Вопрос про беременность живёт не в онбординге, а в «Рамках рутины» внутри Разбора косметички. |
| `onbording_routine_continue` | `care_frames_continue` | Там же. Свойства сохранены: `fragrance_free`, `steps_routine`. |
| `onbording_done` (`Age`, `Budget`) | `onboarding_done` | Возраст и бюджет не спрашиваются нигде — их не читает ни один расчёт. Вместо них отправляем реальные ответы анкеты: `skin_type`, `sensitive`, `acne_prone`, `goals_count`. |
| `onbording_scan` | — | На последнем шаге одна кнопка «Сохранить и сканировать». Два события на один тап — шум, поэтому осталось `onboarding_done`. |
| `end_session` | — | Кнопки «Завершить сессию» в проде нет: её намеренно убрали (см. комментарий в `profile_widget.dart`). Выход из аккаунта покрывает `account_exit`. |
| `premium_tap` `from (home/account)` | `premium_tap` `from` | Значения точнее, чем в таблице: `home`, `profile_try_premium`, `scan_limit`, `out_of_generations`, `card_hidden_ingredients`, `bag_add_from_card`, `bag_over_limit`. |
| `routine_push` `on/off`, `Time` | `routine_push` `state`, `time` | Свойства приведены к snake_case: смешанный регистр в Amplitude мешает строить графики. |
| `profile_settings_photo` | свойство `source` | Значения как в таблице: `gallery`, `camera`, `icon_name`. |

## Свойства, добавленные сверх таблицы

| Событие | Свойство | Зачем |
|---|---|---|
| `onboarding_skin` | `via` = `direct` / `determine` | Ветка «Не знаю» → «определим вместе» в таблице не описана, и без этого свойства прошедшие её пропадают из воронки. |
| `onboarding_important_continue` | `goals_count` | Целей можно выбрать до трёх; без счётчика это видно только разбором массива. |

## Идентичность пользователя

`user_id` в Amplitude — **не** Supabase-uuid, а UUID устройства из Keychain
(`lib/flutter_flow/device_identity.dart`). Причина: Amplitude не склеивает
двух разных `user_id`, а Supabase-uuid меняется при переустановке (сессия
лежит в SharedPreferences и стирается) и при входе через Apple (создаётся
новый аккаунт; регистрация по email uuid сохраняет). Keychain — единственное
хранилище, переживающее удаление приложения; `first_unlock` даёт идентичности
уехать в зашифрованный бэкап и переехать на новый телефон.

Цена: один девайс = один пользователь Amplitude. Тот же аккаунт на iPhone и
iPad — два пользователя, и объединить их нельзя. Сколько таких людей, видно по
`supabase_uid`: пользователи, делящие один uuid, и есть кросс-девайсные.

Supabase-uuid уходит свойствами: `supabase_uid` — текущий, `supabase_uids` —
накопительный список всех, какими человек был (переустановка, Apple-вход,
выход из аккаунта дают новые). Так в карточке пользователя видна вся его
история в базе.

**Удаление аккаунта.** Клиент шлёт `analytics_id` бэкенду, тот перед каскадом
читает `users.analytics_ids` — все устройства, какие приложение регистрировало
под этим uid через RPC `register_analytics_id` при каждом auth-событии, — и
после успешного `delete_user_cascade` вызывает Amplitude User Privacy API для
всех разом (EU-хост, пара `AMPLITUDE_API_KEY`/`AMPLITUDE_SECRET_KEY` в env
бэкенда; удаление исполняется до 30 дней). Так человек, ходивший с двух
устройств, вычищается целиком, а не только с того, с которого удалял. Клиент затем делает `reset()` и чеканит новую идентичность —
следующий аноним на устройстве не пришивается к истории удалённого. Без пары
ключей удаление аккаунта работает, но бэкенд пишет ERROR с id, который надо
удалить руками: молчаливый пропуск здесь — нарушение права на забвение.

## Свойства пользователя

Ставятся один раз при инициализации и приклеиваются ко **всем** последующим
событиям. Это не события: по ним фильтруют, а не считают.

| Свойство | Значения | Зачем |
|---|---|---|
| `install_source` | `app_store`, `testflight_or_xcode`, `simulator`, `unknown` | TestFlight шлёт события в тот же продовый проект, что и живые пользователи, а покупки там песочные — без этого свойства конверсия в оплату завышена на неизвестную величину. Один сегмент «только App Store» чистит сразу все графики. |
| `supabase_uid` | uuid | Текущая строка в базе. Ставится из auth-стрима при каждой смене сессии. |
| `supabase_uids` | список uuid | Все строки, какими человек был на этом устройстве. `preInsert` — без дублей. |
| `app_env` | `Production`, `Development`, `Local` | Страховка от залипшего дев-дефайна в `Generated.xcconfig` — той самой аварии, из-за которой дев уехал в стор в билде 108. Со свойством это видно в первый же день. |

Источник установки читается из `installerStore` пакета `package_info_plus`: на
iOS он определяется по имени файла чека. У сборки, поставленной из Xcode на
устройство, чек такой же песочный, как у TestFlight, — различить их нельзя,
поэтому значение и называется `testflight_or_xcode`. Граница, которая нужна на
практике, проходит между App Store и всем остальным, и она надёжна.

## Экраны

Переходы между экранами снимаются автоматически: `AmplitudeNavigatorObserver`
подключён в `nav.dart` и шлёт `[Amplitude] Screen Viewed` со свойством
`[Amplitude] Screen Name` (имя маршрута из go_router). Отдельных событий на
открытие экрана заводить не нужно.

Также включены `sessions`, `appLifecycles` и `deepLinks` — старт и конец сессии,
установка, обновление и открытие по диплинку приходят без нашего кода.

## Карта событий

### Онбординг — `pages/onboarding_quiz/onboarding_quiz_widget.dart`

| Событие | Свойства | Точка |
|---|---|---|
| `onboarding_go` | — | «Поехали» на welcome |
| `onboarding_skip` | — | «Пропустить» на welcome |
| `onboarding_close` | — | ✕ в шапке |
| `onboarding_skip_all` | — | «Да, пропустить» в подтверждении |
| `tap_back` | `from` — шаг | Стрелка назад |
| `onboarding_skin` | `type_skin`, `via` | Выбор типа кожи (прямой и через «определим вместе») |
| `onboarding_skin_new` | `type_new` | Вопрос про чувствительность |
| `onboarding_skin_eruption` | `type_eruption` | Вопрос про высыпания |
| `onboarding_important_continue` | `type_important`, `goals_count` | «Далее» на шаге целей |
| `onboarding_no_goal` | — | «Пока без конкретной цели» |
| `onboarding_done` | `skin_type`, `sensitive`, `acne_prone`, `goals_count` | «Сохранить и сканировать» |
| `onboarding_edit` | — | «Изменить» на экране результата |

### Рамки рутины — `pages/care_review/care_frames_sheet.dart`

| Событие | Свойства | Точка |
|---|---|---|
| `care_frames_pregnancy` | `type_pregnancy` | Выбор статуса |
| `care_frames_continue` | `fragrance_free`, `steps_routine` | «Сохранить» |

### Экран сканирования

| Событие | Свойства | Точка |
|---|---|---|
| `scan_photo_tap` | — | Центральная кнопка навбара (`components/navbar`) |
| `scan_photo_tips_open` / `_close` | — | «Подсказки для фото» |
| `scan_photo_take` | — | «Сделать фото» |
| `scan_photo_choose_gallery` | — | «Выбрать из галереи» |
| `quick_setup_continue` | `interface_language`, `your_region` | «Продолжить» в Быстрой настройке |
| `quick_setup_swipe` | — | Лист Быстрой настройки закрыт без «Продолжить» |
| `show_scan_product_not_recognized` | — | Показ окна «Продукт не распознан» |
| `scan_product_not_recognized_ok` | — | «Хорошо» в этом окне |
| `scan_ingredients_not_found` | — | Показ окна «Состав не найден» |
| `scan_photo_ingredients` | — | «Сфотографировать состав» |
| `scan_ingredients_manually` | `length`, `ingredients_count` | Состав введён вручную |

Окна ошибок живут в `components/error_popup` — единственная точка на всю
таксономию отказов, поэтому события стоят там, а не в двух зеркальных цепочках
сканера.

**Сам введённый состав в аналитику не уходит — намеренно.** Текст отправляется
на бэкенд (`ingredients` в `SetIngredients`) и хранится против записи скана,
читать его нужно оттуда. В Amplitude идут только `length` и
`ingredients_count`: свободный текст из буфера даёт неограниченную
кардинальность (по такому свойству не построить ни сегмент, ни воронку) и тащит
в аналитику вместе с `user_id` содержимое, которого мы не звали. Числа
отвечают на тот же вопрос — вставили полный INCI с этикетки или вбили пару слов
руками. `ingredients_count` считается по запятым, точкам с запятой и переносам
строк: из буфера прилетает по-разному.

### Главный экран

| Событие | Свойства | Точка |
|---|---|---|
| `home_tap` | — | Вкладка «Главная» |
| `account_tap` | — | Значок аккаунта в шапке |
| `add_product` | — | «Добавить продукт» в пустом состоянии |
| `premium_tap` | `from` | Любой вход в подписку (см. таблицу выше) |

### Настройки аккаунта — `pages/profile`

| Событие | Свойства | Точка |
|---|---|---|
| `share_tap` | — | «Поделиться» |
| `feedback_tap` | — | «Оставить отзыв» |
| `feedback_send` | — | «Отправить» в листе отзыва |
| `feedback_swipe` | — | Лист отзыва закрыт без отправки |
| `skin_profile` | — | «Профиль кожи» |
| `app_language` | `language` | Выбор языка (`settings/langs`) |
| `your_region` | `region` | Выбор региона (`settings/countries`) |
| `create_account` | `from` | «Создать аккаунт» |
| `log_in` | — | «Войти» |
| `create_profile_email_tap` | — | Фокус на поле email |
| `create_profile_password_tap` | — | Фокус на поле пароля |
| `create_profile_apple_id` | — | «Войти через Apple» |
| `profile_settings_photo` | `source` | Выбор фото профиля |
| `profile_settings_continue` | `interface_language` | «Далее» в настройках профиля |
| `profile_edit` | `from` | «Редактировать профиль» |
| `profile_edit_save` | — | «Сохранить изменения» |
| `link_telegram` | — | «Привязать телеграм» |
| `link_telegram_link` | — | «Привязать» в листе |
| `link_telegram_swipe` | — | Лист закрыт без привязки |
| `account_exit` | — | «Выйти из аккаунта» |
| `account_delete` | — | «Удалить аккаунт» |

`create_profile_email_tap` и `create_profile_password_tap` считаются по фокусу
поля, а не по тапу: в пароль попадают и кнопкой «дальше» с клавиатуры.

### Обзор (вкладка Explore) — `topratings/toprated`

| Событие | Свойства | Точка |
|---|---|---|
| `overview_tap` | — | Вкладка в навбаре |
| `overview_filter` | — | Значок фильтра |
| `overview_filter_reset` | — | «Сбросить» |
| `overview_filter_add` | `filter` — список `фасет:значение` | «Применить» |
| `overview_filter_swipe` | — | Лист фильтров закрыт без действия |
| `overview_product_tap` | — | Тап по продукту |

### Экран продукта — `itemcard2`, `components/product_card_v2`

| Событие | Свойства | Точка |
|---|---|---|
| `product_skin` | `skin_name` | Выбор типа кожи в сведениях (`all` — «для всех типов») |
| `product_settings` | — | Открытие меню действий |
| `product_setting_close` | — | Закрытие меню |
| `product_settings_copy` | — | «Скопировать» |
| `product_settings_spam` | — | «Спам» |
| `product_setting_add_bag` | — | «В косметичку» |
| `product_setting_share` | — | «Поделиться» |
| `product_setting_print` | — | «Напечатать» |

Имена `product_settings_*` и `product_setting_*` разнобойные — так в таблице
маркетинга, менять не стали.

### Косметичка — `pages/bag`, `pages/care_review`

| Событие | Свойства | Точка |
|---|---|---|
| `beauty_bag_tap` | — | Вкладка в навбаре |
| `beauty_bag_product_add` | — | Продукт выбран в листе добавления |
| `beauty_bag_product_delete` | — | Удаление из слота |
| `beauty_bag_check_fit` | — | «Проверить совместимость» |
| `beauty_bag_view_analysis` | — | «Открыть разбор» из косметички |
| `beauty_bag_notes` | — | Раскрытие «Замечаний» |
| `beauty_bag_add_calendar` | — | «Добавить в календарь» |

`beauty_bag_check_fit` и `beauty_bag_view_analysis` — одна кнопка в двух
состояниях: пока разбора нет, она «проверить», дальше — «открыть».

Вход в разбор из рутины — отдельное событие `routine_view_analysis`. Раньше оба
входа были одним `view_analysis` со свойством `from`; префикс события называет
экран, с которого нажали, поэтому свойство стало лишним.

### Рутина — `pages/routine`

| Событие | Свойства | Точка |
|---|---|---|
| `routine_day` | `day` — 1..7 | Выбор дня недели |
| `routine_push` | `state` = `on`/`off`, `time` = `am`/`pm` | Переключатель пуша |
| `routine_product` | `time` = `am`/`pm` | Тап по продукту |
| `routine_product_save` | `day` — выбранные дни | «Сохранить» |
| `routine_product_pause` | — | «Приостановить» (возобновление в таблице не описано) |
| `routine_view_analysis` | — | «Открыть разбор» из рутины |

### Просилка отзывов — `components/feedback_collector`

| Событие | Свойства | Точка |
|---|---|---|
| `popup_reviews_show` | — | Показ окна (из карточки продукта) |
| `popup_reviews_yes` | — | «Да» |
| `popup_reviews_no` | — | «Нет» |
| `popup_reviews_tap_comment` | — | Фокус на поле комментария |
| `popup_reviews_tap_email` | — | Фокус на поле email |
| `popup_reviews_tap_send` | — | «Отправить» |

## События вне таблицы маркетинга

Почти все существовали до неё и переведены с GA4 на Amplitude без
переименования. Исключение — `purchase_restore`: его в таблице нет, а кнопка
«Восстановить покупки» на пейволле есть, и без события не видно, работает ли она.

| Событие | Свойства |
|---|---|
| `purchase_restore` | `result`: `restored`, `nothing_to_restore`, `error` |
| `anon_session_started`, `anon_converted` | — |
| `analysis_started` | `source` |
| `analysis_completed` | `image_id`, `score`, `product_type` |
| `analysis_failed` | `reason` |
| `card_opened` | `image_id`, `source` |
| `ingredients_tab_opened` | `image_id` — объявлено, но нигде не вызывается ещё до этой задачи |
| `share_link_tapped`, `share_card_created` | `image_id`, `format` |
| `board_created`, `product_added_to_board` | `image_id` |
| `favourite_added`, `favourite_removed` | `image_id` |
| `upgrade_prompt_shown` | `trigger` |
| `paywall_offerings_loaded` | `ready`, `configured` |
| `purchase_started`, `purchase_completed` | `package` |
| `purchase_failed` | `package`, `code`, `cancelled` |
