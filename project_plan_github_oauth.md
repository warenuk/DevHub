# План реалізації: GitHub OAuth Device Flow (повна інтеграція)
## Дата створення: 2025-09-07
## Статус: В роботі

## Результати дослідження
- Поточний стан GitHub фічі:
  - Repo/Activity/Commits працюють через `Dio` + token bearer; токен зараз береться з SecureStorage (Settings) з fallback на `--dart-define` у тестах.
  - Відсутній механізм автентифікації користувача до GitHub (отримання токена), токен вводиться руками.
  - UI: `SettingsPage` має інпут/видалення токена.
  - Навігація: маршрути для `/github/*` існують; окремого екрана логіну GitHub немає.

- Вимоги до OAuth Device Flow:
  - Не зберігати `client_secret` у клієнті (Device Flow його не потребує).
  - Працювати на desktop/mobile без бекенда.
  - Ризик для web: CORS до `https://github.com/login/device/code` і `https://github.com/login/oauth/access_token` може блокувати запити з браузера. Рішення: показати попередження і залишити ручне введення токена на web, або використовувати проксі/бекенд (поза цим планом).

## Виявлені залежності
- HTTP: `Dio` (вже є). Потрібні ендпоїнти:
  - POST `https://github.com/login/device/code`
  - POST `https://github.com/login/oauth/access_token`
- Зберігання: `FlutterSecureStorage` (вже є) для токена.
- State: Riverpod (`StateNotifier`, `FutureProvider`) для керування флоу.
- UI: кнопка “Sign in with GitHub”, екран/діалог інструкцій, індикатор очікування (polling).

## Ризики
- Web CORS: device flow може бути заблоковано. План: на web показати банер “використайте ручне збереження токена в Settings”.
- Rate limit / 403 SSO для організацій — показати чіткі повідомлення.
- Безпека: не логувати токен, очищати на sign-out.

## Детальний план виконання

### Етап 1: Підготовка [~20 хв]
- [ ] 1.1 Додати конфіг `GithubOAuthConfig` (clientId, scope; без secret).
- [ ] 1.2 Додати `github_oauth_client_provider` (окремий `Dio` з baseUrl `https://github.com`).
- [ ] 1.3 Уточнити репо-запит на `/user/repos`: параметри `affiliation=owner,collaborator,organization_member`, `visibility=all`.
Status: Pending

### Етап 2: Domain Layer [~30 хв]
- [ ] 2.1 Entities:
  - `GithubDeviceCode` (device_code, user_code, verification_uri, expires_in, interval)
  - `GithubAuthToken` (access_token, token_type, scope)
- [ ] 2.2 Repository контракт `GithubAuthRepository`:
  - `Future<Either<Failure, GithubDeviceCode>> startDeviceFlow(String clientId, {String scope})`
  - `Future<Either<Failure, GithubAuthToken>> pollForToken(String clientId, String deviceCode, {int interval})`
  - `Future<void> saveToken(String token)` / `Future<String?> readToken()` / `Future<void> deleteToken()`
- [ ] 2.3 Use cases:
  - `StartGithubDeviceFlowUseCase`
  - `PollGithubTokenUseCase`
  - `SaveGithubTokenUseCase` / `DeleteGithubTokenUseCase` / `ReadGithubTokenUseCase`
Status: Pending

### Етап 3: Data Layer [~45 хв]
- [ ] 3.1 DataSource `GithubOAuthRemoteDataSource` (Dio github.com):
  - POST `/login/device/code` (headers: `Accept: application/json`)
  - POST `/login/oauth/access_token` (headers: `Accept: application/json`)
- [ ] 3.2 Local `GithubTokenLocalDataSource` на `FlutterSecureStorage` (ключ `github_token`).
- [ ] 3.3 Реалізація `GithubAuthRepositoryImpl` (error mapping: 400/403 -> Validation/Auth/RateLimit Failure).
Status: Pending

### Етап 4: Presentation Layer [~60 хв]
- [ ] 4.1 State: `GithubAuthNotifier` (Device Flow):
  - Стани: idle, requesting_code, code_ready(user_code, verification_uri), polling, authorized, error.
  - Дії: `start()`, `poll()`, `cancel()`, `signOut()`.
- [ ] 4.2 Providers:
  - `githubAuthNotifierProvider` (StateNotifierProvider)
  - `githubCurrentTokenProvider` (FutureProvider<String?>)
- [ ] 4.3 UI:
  - На Settings додати блок “GitHub Sign-In”: кнопка “Sign in with GitHub”, показ `user_code` і `verification_uri`, кнопка “I authorized, continue”.
  - Кнопка “Sign out” (видалити токен).
  - На web – повідомлення про можливе обмеження та CTA зберегти токен вручну.
- [ ] 4.4 Інтеграція з існуючим кодом: провайдер `githubTokenProvider` використовує локально збережений токен.
Status: Pending

### Етап 5: Тести [~60 хв]
- [ ] 5.1 Unit: мапінг JSON DeviceCode/AuthToken.
- [ ] 5.2 Unit: репозиторій з моканим DataSource (успіх, pending_authorization, slow_down, expired_token).
- [ ] 5.3 Widget: флоу в Settings (render code, continue, success) з фейковим репозиторієм.
- [ ] 5.4 Smoke (платформозалежний): на mobile/desktop — інтеграційний тест (за фічою, опц.).
Status: Pending

### Етап 6: Фінальна перевірка [~20 хв]
- [ ] 6.1 `flutter analyze` без помилок
- [ ] 6.2 `dart format .`
- [ ] 6.3 `flutter test`
- [ ] 6.4 Оновлення README/KEYS_GUIDE (Device Flow інструкції)
- [ ] 6.5 Conventional Commit: `feat(auth): GitHub OAuth device flow`
Status: Pending

## UX специфіка
- Після натискання “Sign in with GitHub” показати user code і лінк (копіювання у буфер, кнопка “Open github.com/activate”).
- Під час polling показати таймер/спінер, дати змогу скасувати.
- Після авторизації — банер успіху і автоматичне збереження токена.
- При 401 у GitHub запитах — банер із CTA “Sign in with GitHub”.

## Команда для старту
“Виконуй план GitHub OAuth Device Flow”.

