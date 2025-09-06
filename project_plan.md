# План реалізації: MVP Автентифікація, Роутинг і Дашборд
## Дата створення: 2025-09-06
## Статус: Очікує схвалення

## Результати дослідження
### Проаналізовані файли
- `lib/core/router/router_provider.dart` — `GoRouter` з `redirect`, `ShellRoute`, `GoRouterRefresh`.
- `lib/features/auth/presentation/providers/auth_providers.dart` — провайдери `authRepositoryProvider`, `authStateProvider`, `currentUserProvider`, `AuthController`.
- `lib/features/auth/presentation/pages/splash_page.dart` — splash-екран.
- `lib/features/auth/presentation/pages/login_page.dart`, `register_page.dart` — UI екрани.
- `lib/features/dashboard/presentation/pages/dashboard_page.dart` — простий дашборд.
- `lib/features/shell/presentation/main_shell.dart` — оболонка для захищених маршрутів.
- `lib/features/auth/domain/*` — сутність `User`, репозиторій, use cases (sign in/up/out/reset/get current).
- `lib/features/auth/data/*` — `AuthRepositoryImpl`, `AuthLocalDataSource` (in-memory), `AuthRemoteDataSource` (Firebase/Mock), `UserModel`.
- `lib/main.dart` — `MaterialApp.router`, ініціалізація Firebase за прапорцем `kUseFirebase`.
- Тести: `test/widget/router_redirect_test.dart`, `test/widget/features/auth/presentation/login_page_test.dart`, `test/widget/dashboard_page_test.dart`, `test/unit/features/auth/...`.

### Виявлені залежності
- Навігація: `go_router` з `redirect` та `ShellRoute`.
- Стан: `flutter_riverpod` (потоки для auth state, `StateNotifier` для дій).
- Автентифікація: `FirebaseAuthRemoteDataSource` або `MockAuthRemoteDataSource` (керується `kUseFirebase`).
- Моделювання/утиліти: `dartz`, `equatable`, `json_serializable`, `freezed_annotation` (частково), Material 3 тема.

### Ризики
- Кодування коментарів у деяких файлах має артефакти (encoding) — не впливає на роботу, але варто виправити пізніше.
- Поведінка back-навігації та deep-link сценарії потребує перевірки на всіх станах (loading/error/authenticated/unauthenticated).
- `AuthLocalDataSource` наразі in-memory — для продакшену потрібне безпечне зберігання (наприклад, `flutter_secure_storage`/Hive).

## Детальний план виконання

### Етап 1: Підготовка [~15 хв]
- [ ] 1.1 Узгодити режим автентифікації: Firebase (`kUseFirebase=true`) чи Mock (`false`).
- [ ] 1.2 Перевірити маршрути: `/splash`, `/auth/login`, `/auth/register`, `/dashboard` (наявність та відповідність до редіректів).
- [ ] 1.3 `flutter pub get` і локальна перевірка запуску.

Статус: Pending

### Етап 2: Роутинг і редіректи [~25 хв]
- [ ] 2.1 Підтвердити, що `GoRouterRefresh` підписаний на `authStateProvider` і тригерить `notifyListeners()`.
- [ ] 2.2 Верифікувати логіку `redirect` для станів: loading → `/splash`, error → `/auth/login`, unauthenticated → `/auth/login`, authenticated → `/dashboard` (+ root/splash/auth*).
- [ ] 2.3 Перевірити edge cases: переходи між екранами під час зміни auth state, прямі переходи на захищені маршрути, back-навігацію.

Статус: Pending

### Етап 3: Презентаційний шар [~30 хв]
- [ ] 3.1 Перевірити валідацію полів Login/Register (мін. довжина пароля, формат email) з `validators.dart`.
- [ ] 3.2 Грамотно відображати помилки з `AuthController` (статус `AsyncValue.error`).
- [ ] 3.3 UX-поліш: дизабл кнопок під час `loading`, індикатори, лінки на Register/Login між собою.

Статус: Pending

### Етап 4: Дані та безпека [~40 хв]
- [ ] 4.1 Узгодити зберігання користувача локально: замінити in-memory на `flutter_secure_storage`/Hive (мінімальна інтеграція для MVP).
- [ ] 4.2 Обробка помилок: повертати доменні `Failure` з чіткими повідомленнями (Server/Cache/Network).
- [ ] 4.3 Оновити `AuthRepositoryImpl` для використання безпечного кешу (за необхідності).

Статус: Pending

### Етап 5: Тестування [~35 хв]
- [ ] 5.1 Unit: розширити тести use cases (sign up, sign out, reset, get current).
- [ ] 5.2 Unit: репозиторій (error paths, updateProfile, resetPassword).
- [ ] 5.3 Widget: редіректи (authenticated/unauthenticated/loading/error), Login/Register UI стани.
- [ ] 5.4 Запуск: `flutter test` і стабілізація.

Статус: Pending

### Етап 6: Фінальна перевірка [~15 хв]
- [ ] 6.1 `dart format .`
- [ ] 6.2 `flutter analyze` (виправити всі зауваження лінтера).
- [ ] 6.3 Оновити `README.md` щодо конфігурації `USE_FIREBASE` і сценаріїв запуску.
- [ ] 6.4 Зафіксувати зміни комітом у стилі Conventional Commits (приклад: `feat(auth): polish auth routing and tests`).

Статус: Pending

## Команда для старту
Після схвалення плану, дайте команду: "Виконуй план".
