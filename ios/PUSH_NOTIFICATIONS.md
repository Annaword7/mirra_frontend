# Push Notifications — iOS Setup

## Архитектура

```
App (FCM token) → Supabase device_tokens → Python push_service.py → Firebase Admin SDK → FCM → APNs → устройство
```

Маркетинговые пуши — вручную через Firebase Console.  
Транзакционные — через `push_service.py` в Python backend.

---

## Что настроено

### Flutter
- `firebase_messaging` + `flutter_local_notifications` в `pubspec.yaml`
- `NotificationService` в `lib/flutter_flow/notification_service.dart`:
  - Ждёт APNs токен (`_waitForApnsToken`) перед вызовом `getToken()`
  - Подписывается на `onAuthStateChange` — сохраняет токен при любом auth событии
  - Показывает foreground уведомления через `flutter_local_notifications`
- Токен сохраняется в Supabase таблицу `device_tokens` с `user_id`, `platform`, `is_active`

### iOS (Xcode)
- **Capability**: Push Notifications добавлена в Signing & Capabilities
- **Entitlements**: `aps-environment: production` (для TestFlight и App Store)
- **AppDelegate.swift**:
  - `FirebaseApp.configure()` — вызывается первым
  - `UNUserNotificationCenter.current().delegate = self`
  - `Messaging.messaging().delegate = self`
  - `application.registerForRemoteNotifications()`
  - `userNotificationCenter(_:willPresent:)` — показывает баннеры в foreground

### Firebase
- Cloud Messaging API (V1): Enabled
- APNs Authentication Key (.p8): загружен с правильным Key ID и Team ID
- iOS app Bundle ID: `mirra.app`

### Python Backend
- `firebase-admin` в `requirements.txt`
- `mirra/push_service.py`: `send_push_to_user(supabase_client, user_id, title, body, data)`
- `FCM_SERVICE_ACCOUNT_JSON` в Railway environment variables

### Supabase
- Таблица `device_tokens`: `user_id`, `token`, `platform`, `is_active`
- Таблица `notification_log`: логирование отправок

---

## Важные нюансы

**Debug vs Production APNs:**
- Debug сборка (Xcode Run) → development APNs → токен не работает с Firebase Console
- TestFlight/App Store → production APNs → всё работает

**Токен сохраняется только для авторизованных пользователей.**  
Если пользователь не залогинен — `device_tokens` останется пустым.

**Тестирование:**
1. Установить из TestFlight
2. Залогиниться в приложении
3. Проверить `device_tokens` в Supabase — должна появиться строка
4. Firebase Console → Cloud Messaging → Send test message → вставить токен

---

## Как отправить транзакционный пуш (Python)

```python
from mirra.push_service import send_push_to_user

send_push_to_user(
    supabase_client=supabase_client,
    user_id="<uuid>",
    title="Анализ готов",
    body="Ваш продукт проверен",
    data={"image_id": "123"},
)
```
