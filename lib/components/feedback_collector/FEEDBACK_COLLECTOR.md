# Feedback Collector

## Что это

Система сбора отзывов от пользователей. Показывает диалог с вопросом "нравится ли приложение?" и ведёт по одной из двух веток:

- **Позитивная** → нативный iOS-диалог App Store Review (`in_app_review`)
- **Негативная** → bottom sheet с текстовым полем → отправка в Telegram через бота

---

## Файлы

| Файл | Назначение |
|------|-----------|
| `feedback_service.dart` | Логика показа: когда и как часто |
| `feedback_collector_widget.dart` | Диалог с двумя кнопками |
| `negative_feedback_widget.dart` | Bottom sheet для негативного фидбека |
| `lib/backend/supabase/database/tables/feedback.dart` | Supabase-таблица `feedback` (лайки/дизлайки на карточках) — отдельная система, не связана |

---

## Условия показа (`FeedbackService.shouldShowPrompt`)

Все условия должны выполняться одновременно:

1. **Feature flag включён** — `FFAppState().feedbackCollectorEnabled == true` (по умолчанию `false`)
2. **Пользователь ещё не оставил отзыв** — `feedbackReviewSubmitted == false`
3. **iOS only** — на Android не показывается
4. **Баннер не закрыт** — если закрыт (`feedbackBannerDismissed == true`), проверяется версия: если сменилась — сбрасывается и показывается снова
5. **14 дней с первого запуска** (или с последнего показа) — считается от `feedbackFirstLaunchMs`

---

## Где вызывается

**`home_widget.dart:174`** — при открытии главного экрана:
```dart
FeedbackService.recordFirstLaunchIfNeeded();
```
Фиксирует первый запуск (точка отсчёта 14-дневного таймера). Идемпотентно.

**`itemcard2_widget.dart:110`** — при открытии карточки продукта:
```dart
if (await FeedbackService.shouldShowPrompt()) {
  await FeedbackService.recordShown();
  showDialog(...FeedbackCollectorWidget());
}
```
Диалог показывается поверх карточки продукта.

---

## Пользовательские сценарии

```
Открыл карточку продукта
        ↓
  [shouldShowPrompt?]
        ↓ да
  ✨ Диалог: "Нравится MiRRA?"
        ↓
  ┌─────────────────────────────┐
  │  ⭐ Да, круто               │   → requestReview() (нативный iOS)
  │                             │     feedbackReviewSubmitted = true
  │                             │     больше никогда не показывается
  ├─────────────────────────────┤
  │  Нет, не очень              │   → NegativeFeedbackWidget (bottom sheet)
  │                             │     feedbackBannerDismissed = true
  │                             │     через текстовое поле → Telegram
  └─────────────────────────────┘
```

---

## AppState поля (персистентные, SharedPreferences)

| Поле | Тип | По умолчанию | Описание |
|------|-----|-------------|----------|
| `feedbackCollectorEnabled` | `bool` | `false` | Feature flag — включает систему |
| `feedbackReviewSubmitted` | `bool` | `false` | Пользователь нажал "Да" и увидел App Store диалог |
| `feedbackBannerDismissed` | `bool` | `false` | Пользователь нажал "Нет" или закрыл диалог |
| `feedbackLastShownVersion` | `String` | `''` | Версия приложения при последнем показе |
| `feedbackFirstLaunchMs` | `int` | `0` | Timestamp первого запуска (мс) |
| `feedbackLastShownMs` | `int` | `0` | Timestamp последнего показа (мс) |

---

## Как включить

Feature flag выключен по умолчанию. Чтобы включить:

```dart
FFAppState().feedbackCollectorEnabled = true;
```

---

## Firebase Analytics события

| Событие | Когда |
|---------|-------|
| `feedback_positive` | Нажата кнопка "Да, нравится" |
| `feedback_negative` | Нажата кнопка "Нет, не очень" |
| `feedback_submitted` | Отправлен текстовый фидбек (негативный путь) |

---

## Примечания

- `NegativeFeedbackWidget` отправляет текст через `TelegrammessegeCall` — тот же Telegram-бот, что используется в backend
- Email в форме необязателен; если не заполнен — используется `currentUserEmail` авторизованного пользователя
- Таблица `feedback` в Supabase — система лайков/дизлайков на карточках продуктов, не связана с этим компонентом
