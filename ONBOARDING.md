# Onboarding

## Флаг `onboardingDone`

Хранится в `SharedPreferences` под ключом `ff_onboardingDone` (тип `bool`, default `false`).
Доступ: `FFAppState().onboardingDone` — геттер/сеттер в [`lib/app_state.dart`](lib/app_state.dart).

| Значение | Смысл |
|---|---|
| `false` | Пользователь не прошёл онбординг → показывать карусель |
| `true` | Онбординг завершён → пропустить при запуске |

---

## Сценарии запуска

### 1. Свежая установка (не залогинен, `onboardingDone == false`)

```
Запуск приложения
  → nav.dart / → OnboardingCarouselWidget   ← флаг false, не залогинен
  → (после последнего слайда) PaywallpageWidget
  → NewblankWidget (Splash)  ← вход / регистрация
```

### 2. Вернувшийся пользователь (не залогинен, `onboardingDone == true`)

```
Запуск приложения
  → nav.dart / → NewblankWidget   ← флаг true
```

### 3. Пользователь залогинен (токен сохранился в keychain)

```
Запуск приложения
  → nav.dart / → HomeWidget   ← loggedIn == true, флаг не проверяется
```

---

## Потоки регистрации (новый пользователь)

Все методы регистрации ведут на `OnboardingProfileWidget` → `OnboardingCarouselWidget`.

### Email

```
NewblankWidget → LogInPage (вкладка Register)
  → createAccountWithEmail()
  → OnboardingProfileWidget
  → OnboardingCarouselWidget  ← onboardingDone = true на последнем слайде
  → PaywallpageWidget
```

### Apple / Google

```
NewblankWidget → LogInPage
  → signInWithApple() / signInWithGoogle()
  → OnboardingProfileWidget
  → OnboardingCarouselWidget  ← onboardingDone = true на последнем слайде
  → PaywallpageWidget
```

### Через инструкции

```
NewblankWidget → OnboardingInstructionsWidget (3 слайда)
  → CreateAccountPageWidget
  → OnboardingProfileWidget
  → OnboardingCarouselWidget
  → PaywallpageWidget
```

---

## Поток входа (существующий пользователь)

Онбординг **не показывается**.

```
NewblankWidget → LogInPage (вкладка Login)
  → signIn()
  → HomeWidget   ← сразу, без проверки onboardingDone
```

---

## Logout / End session

Оба действия сбрасывают флаг и отправляют на карусель.

```
ProfileWidget → "Log out" / "End session"
  → onboardingDone = false
  → signOut()
  → OnboardingCarouselWidget
  → PaywallpageWidget → NewblankWidget
```

Расположение в коде: [`lib/pages/profile/profile_widget.dart`](lib/pages/profile/profile_widget.dart) — два обработчика (анонимная сессия и авторизованный пользователь).

---

## Карусель (`OnboardingCarouselWidget`)

Файл: [`lib/pages/onboarding_carousel/onboarding_carousel_widget.dart`](lib/pages/onboarding_carousel/onboarding_carousel_widget.dart)  
Маршрут: `/onboardingCarousel`

5 слайдов. Слайды 0, 3, 4 — кастомные анимированные виджеты; слайды 1–2 — видео (зациклены, без звука). Весь текст локализован (ru / en / es).

| # | Тип | Виджет / Файл | Заголовок (en) |
|---|---|---|---|
| 0 | Кастомный | `OnboardingAnalysisBody` | Get a full ingredient analysis |
| 1 | Видео | `onboarding_1.mp4` | Scan cosmetic products |
| 2 | Видео | `onboarding_3.mp4` | Come back anytime |
| 3 | Кастомный | `OnboardingTopCardsBody` | Community top products |
| 4 | Кастомный | `OnboardingShareBody` | Share your discoveries fast |

Кнопка: «Continue» на слайдах 0–3, «Get started» на слайде 4.  
При нажатии «Get started»: `onboardingDone = true` → `PaywallpageWidget`.

**Skip:** в верхнем левом углу — едва заметная надпись (opacity 28%), ведёт напрямую на `PaywallpageWidget` с установкой `onboardingDone = true`.

Навигация назад заблокирована (`canPop: false`).

### Слайд 0 — Анализ (`OnboardingAnalysisBody`)

Файл: [`lib/pages/onboarding_analysis/onboarding_analysis_widget.dart`](lib/pages/onboarding_analysis/onboarding_analysis_widget.dart)

Анимированная демонстрация анализа состава: 4 ингредиента вращаются по орбите, поочерёдно раскрываются панели с INCI-свойствами. Использует `_AnalysisMixin` — логика и билд-методы общие между `OnboardingAnalysisWidget` (standalone page) и `OnboardingAnalysisBody` (embeddable). Весь текст локализован.

### Слайд 3 — Топ карточки (`OnboardingTopCardsBody`)

Файл: [`lib/pages/onboarding_top_cards/onboarding_top_cards_body.dart`](lib/pages/onboarding_top_cards/onboarding_top_cards_body.dart)

Горизонтальная авто-прокрутка карточек продуктов (Ticker, 44 px/s) с эффектом наклона. Данные загружаются из таблицы Supabase `onboarding_cards` (управляется из Supabase, без релиза). Фото через `CachedNetworkImage` из `image_url`. Сессионный кэш (`_sessionCards`) — запрос делается один раз за запуск.

**Предзагрузка:** `prefetchOnboardingCards()` вызывается в `initState` карусели (слайд 0), чтобы к слайду 3 данные и изображения уже были в кэше.

#### Таблица `onboarding_cards`

| Колонка | Тип | Описание |
|---|---|---|
| `sort_order` | int | Порядок отображения |
| `name` | text | Название продукта |
| `brand` | text | Бренд |
| `score` | int | Скор (0–100) |
| `accent_color` | text | Hex-цвет акцента (`#5DBBAA`) |
| `gradient_start/end` | text | Hex-цвета фонового градиента |
| `category_ru/en/es` | text | Категория на трёх языках |
| `image_url` | text | Public URL фото (Supabase Storage) |
| `ingredient_1/2` | text | 1–2 ключевых ингредиента |
| `is_active` | bool | Скрыть/показать карточку |

Миграция из `images` — топ-10 по `sa_composite_score` с дедупликацией по `product_name`.

### Слайд 4 — Шеринг (`OnboardingShareBody`)

Файл: [`lib/pages/onboarding_share/onboarding_share_body.dart`](lib/pages/onboarding_share/onboarding_share_body.dart)

Макет share-карточки MiRRA с floating-анимацией + ряд иконок соцсетей (Photos, Instagram, WhatsApp, Pinterest, X). Карточка воспроизводит реальный формат экспорта: левая тёмная панель с фото, правая белая с брендом, скором, барами Safety/Efficacy и тегами.

---

## Профиль пользователя (`OnboardingProfileWidget`)

Файл: [`lib/pages/onboarding_profile/onboarding_profile_widget.dart`](lib/pages/onboarding_profile/onboarding_profile_widget.dart)  
Маршрут: `/onboardingProfile`

Собирает: имя, фамилия, аватар, страна, язык интерфейса.  
Сохраняет запись в таблицу `users` Supabase.  
После сохранения → `OnboardingCarouselWidget`.

---

## Роутинг — точки входа

Файл: [`lib/flutter_flow/nav/nav.dart`](lib/flutter_flow/nav/nav.dart)

```dart
// Начальный маршрут '/'
builder: (context, _) => appStateNotifier.loggedIn
    ? HomeWidget()
    : (FFAppState().onboardingDone ? NewblankWidget() : OnboardingCarouselWidget()),
```

```dart
// Редирект при requireAuth == true (не залогинен)
if (requireAuth && !appStateNotifier.loggedIn) → '/Splash' (NewblankWidget)
```

---

## Ручной просмотр онбординга (из профиля)

В [`lib/pages/profile/profile_widget.dart:706`](lib/pages/profile/profile_widget.dart#L706) есть кнопка для повторного просмотра:

```dart
FFAppState().onboardingDone = false;
context.goNamed(OnboardingCarouselWidget.routeName);
```
