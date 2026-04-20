# Push Notifications — Стратегия и типы

## Инфраструктура

```
App (FCM token) → Supabase device_tokens
                                ↓
                    Python push_service.py
                                ↓
                    Firebase Admin SDK → FCM → APNs → устройство
```

**Маркетинговые пуши** — Firebase Console (вручную, без кода).  
**Транзакционные и реактивационные** — `mirra/push_service.py` в Python backend.

---

## Типы пушей

### 1. Маркетинговые (Firebase Console)

Широкая аудитория или сегменты. Не требуют разработки.

| Пуш | Когда |
|-----|-------|
| Новая функция / обновление | При релизе |
| Акция / скидка на подписку | По необходимости |
| Контентный (топ ингредиентов, советы) | По желанию |

### 2. Транзакционные (Python `push_service.py`)

Triggered by конкретное событие для конкретного пользователя.

| Пуш | Триггер | Приоритет |
|-----|---------|-----------|
| Подписка истекает через 3 дня | cron по `subscription_end_date` | Высокий |
| Добро пожаловать после регистрации | on_signup event | Средний |

### 3. Реактивационные (Python + cron)

Автоматические, по поведению пользователя.

| Пуш | Триггер | Приоритет |
|-----|---------|-----------|
| Не заходил 7 дней | `last_active < now - 7d` | Средний |
| Не заходил 30 дней | `last_active < now - 30d` | Низкий |

---

## Что НЕ отправляем

- Пуш после каждого анализа продукта — слишком много шума, решили убрать.

---

## Как отправить транзакционный пуш (Python)

```python
from mirra.push_service import send_push_to_user

send_push_to_user(
    supabase_client=supabase_client,
    user_id="<uuid>",
    title="Подписка истекает",
    body="Осталось 3 дня. Продлить?",
    data={"screen": "subscription"},
)
```

## Ссылки

- Техническая документация: [ios/PUSH_NOTIFICATIONS.md](../ios/PUSH_NOTIFICATIONS.md)
- Реализация Flutter: [lib/flutter_flow/notification_service.dart](../lib/flutter_flow/notification_service.dart)
- Python backend: [mirra/push_service.py](../../mirra_backend-main/mirra/push_service.py)
