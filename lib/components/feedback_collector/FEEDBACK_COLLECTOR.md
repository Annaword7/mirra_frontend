# Feedback Collector

## Что это

Система сбора отзывов от пользователей. Показывает диалог с вопросом «нравится ли приложение?» и ведёт по одной из двух веток:

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

Не путать с `lib/components/leave_review/` — это «Оставить отзыв» из профиля, который пользователь открывает сам. Общего с просилкой только транспорт (`SendAppMessageCall`).

---

## Условия показа

Проверок две группы: сначала в карточке продукта, потом в `FeedbackService.shouldShowPrompt()`.

### В карточке продукта (`itemcard2_widget.dart`)

1. **Мягкий пейволл имеет приоритет.** Если у пользователя это первый собственный разбор и он не Pro — показывается пейволл, а функция делает `return`. Просилка в этот заход не появляется вовсе и сохраняет свой флаг до следующего скана.
2. **`feedbackPendingScan == true`** — флаг ставится при каждом успешном скане в `takeor_upload_page_widget.dart` и гасится при показе. Просилка привязана к свежему скану, а не к любому открытию карточки.

### В `FeedbackService.shouldShowPrompt(state)`

Все условия должны выполняться одновременно:

1. **iOS only** — на Android не показывается
2. **Тот же пользователь** — при смене `currentUserUid` на устройстве все счётчики сбрасываются, новый человек получает просилку с нуля
3. **Отзыв ещё не оставлен** — `feedbackReviewSubmitted == false`, иначе не показывается никогда
4. **Баннер не закрыт** — если закрыт (`feedbackBannerDismissed == true`), проверяется версия приложения: сменилась — флаг сбрасывается и просилка возвращается
5. **Частота:**
   - первый раз (`feedbackLastShownMs == 0`) → нужно **2 успешных скана**
   - дальше → **14 дней** от последнего показа (`feedbackLastShownMs`)

Порог именно 2, а не 1: первый разбор всегда забирает мягкий пейволл, так что второй скан — самая ранняя точка, где просилку вообще можно показать.

---

## Где вызывается

**`itemcard2_widget.dart`** — в `initState`, в постфрейм-колбэке, после загрузки разбора:

```dart
if (feedbackState.feedbackPendingScan &&
    await FeedbackService.shouldShowPrompt(feedbackState)) {
  feedbackState.feedbackPendingScan = false;
  await FeedbackService.recordShown(feedbackState);
  await Future.delayed(const Duration(seconds: 3));
  if (context.mounted) {
    unawaited(AnalyticsService.instance.trackPopupReviewsShow());
    await showDialog(...FeedbackCollectorWidget());
  }
}
```

Три секунды — чтобы человек успел увидеть разбор до вопроса.

⚠️ `recordShown` вызывается **до** задержки, то есть 14-дневный кулдаун стартует, даже если за эти три секунды пользователь ушёл с карточки и окна не увидел. Событие `popup_reviews_show` при этом не отправляется — оно внутри проверки `context.mounted`, поэтому аналитика показов честная, а кулдаун — нет.

---

## Пользовательские сценарии

```
Успешный скан → открылась карточка продукта
        ↓
  [первый разбор и не Pro?] ── да ──→ мягкий пейволл, просилка ждёт следующего скана
        ↓ нет
  [feedbackPendingScan и shouldShowPrompt?]
        ↓ да
  пауза 3 секунды
        ↓
  ✨ Диалог: «Нравится MiRRA?»
        ↓
  ┌─────────────────────────────┐
  │  ⭐ Да, круто               │   → requestReview() + openStoreListing()
  │                             │     feedbackReviewSubmitted = true
  │                             │     больше никогда не показывается
  ├─────────────────────────────┤
  │  Нет, не очень              │   → NegativeFeedbackWidget (bottom sheet)
  │                             │     feedbackBannerDismissed = true
  │                             │     через текстовое поле → Telegram
  └─────────────────────────────┘
```

---

## AppState поля

| Поле | Тип | По умолчанию | Персистентное | Описание |
|------|-----|-------------|---------------|----------|
| `feedbackPendingScan` | `bool` | `false` | **нет, только сессия** | Был свежий успешный скан |
| `feedbackReviewSubmitted` | `bool` | `false` | да | Нажал «Да» и увидел App Store диалог |
| `feedbackBannerDismissed` | `bool` | `false` | да | Нажал «Нет» или закрыл диалог |
| `feedbackLastShownVersion` | `String` | `''` | да | Версия приложения при последнем показе |
| `feedbackLastShownMs` | `int` | `0` | да | Timestamp последнего показа (мс) |
| `feedbackUserId` | `String` | `''` | да | Чьи это счётчики — для сброса при смене пользователя |
| `successfulScans` | `int` | `0` | да | Счётчик успешных сканов, общий с другими фичами |

---

## Удалённого выключателя нет

Раньше систему включал ключ `feedbackCollectorEnabled` из Supabase-таблицы `app_config`. Снят в 2.5.1: просилка должна срабатывать по той же локальной логике, что и мягкий пейволл, а зависимость от сетевого запроса при старте была единственным условием, которое могло отвалиться молча. Строка в `app_config` больше ни на что не влияет, её можно удалить.

---

## События Amplitude

| Событие | Когда |
|---------|-------|
| `popup_reviews_show` | Диалог реально появился на экране |
| `popup_reviews_yes` | Нажата кнопка «Да, круто» |
| `popup_reviews_no` | Нажата кнопка «Нет, не очень» |
| `popup_reviews_tap_comment` | Фокус на поле комментария в негативной ветке |
| `popup_reviews_tap_email` | Фокус на поле email |
| `popup_reviews_tap_send` | Нажата кнопка отправки |

Полная карта разметки — `docs/analytics_events.md`.

---

## Примечания

- `NegativeFeedbackWidget` отправляет текст через `SendAppMessageCall` с `form: 'negative feedback'` — по этому полю письма из просилки отличаются от «Оставить отзыв» из профиля
- Email в форме необязателен; если не заполнен — используется `currentUserEmail` авторизованного пользователя
- Таблица `feedback` в Supabase — система лайков/дизлайков на карточках продуктов, не связана с этим компонентом
