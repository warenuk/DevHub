# GitHub OAuth Client ID — коротка інструкція

Нижче — мінімальні кроки, щоб отримати Client ID для Device Flow і підключити його в цьому проєкті.

## 1) Створити GitHub OAuth App
- Перейдіть: https://github.com/settings/developers → OAuth Apps → New OAuth App
- Заповніть форму (значення для вашого випадку):
  - Application name: DevHub GPT (або назва вашого застосунку)
  - Homepage URL: https://example.com (можна будь-який валідний URL або ваш домен; для локальної розробки допустимо http://localhost)
  - Authorization callback URL: https://example.com/callback (для Device Flow не використовується, але поле обовʼязкове — поставте будь-який валідний URL)
  - Application description: опціонально
- Після створення ви отримаєте публічний Client ID (Client secret для Device Flow у клієнті не потрібен).

Примітка: якщо працюєте під організацією з SSO, у налаштуваннях організації може знадобитись дозволити доступ вашому OAuth App.

## 2) Які права потрібні
- Device Flow запитує скоупи під час старту. У проєкті ми запитуємо: `repo read:user`.
  - Дозволяє читати приватні/публічні репозиторії і профіль користувача.

## 3) Як підставити Client ID в застосунок
- Варіант A (рекомендовано): через параметр збірки/запуску
  - Debug (web/desktop/mobile):
    - `flutter run -d chrome --dart-define=GITHUB_CLIENT_ID=<ВАШ_CLIENT_ID>`
  - Release:
    - `flutter build apk --dart-define=GITHUB_CLIENT_ID=<ВАШ_CLIENT_ID>`
- Варіант B (жорстко в коді — не рекомендується):
  - Відкрийте `lib/shared/constants/github_oauth_config.dart` і замініть `defaultValue: ''` на ваш Client ID.

## 4) Використання в застосунку
- Відкрийте Settings → розділ “GitHub Sign-In” → натисніть “Sign in with GitHub”.
- Зʼявиться `user_code` та `verification_uri` — перейдіть за посиланням і введіть код.
- Поверніться в застосунок і натисніть “I authorized, continue” — токен збережеться автоматично.
- У разі потреби токен можна видалити (кнопка “Delete GitHub Token” в Settings) або Sign out у блоці GitHub.

## 5) Важливі зауваження
- Web: запити до `github.com/login/*` можуть блокуватися CORS — на web у такому разі використовуйте ручне збереження PAT у полі “GitHub Token” на сторінці Settings, або запускайте Device Flow на desktop/mobile.
- Організації: якщо репозиторії в організації, переконайтесь, що SSO дозволено для вашого OAuth App/токена.

