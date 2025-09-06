# План реалізації: Блок 2 — Навігація та редіректи
Дата створення: 2025-09-06
Статус: Очікує схвалення

## Результати дослідження
### Проаналізовані файли
- `lib/core/router/router_provider.dart` — конфігурація `GoRouter`, `redirect`, `ShellRoute`.
- `lib/features/auth/presentation/providers/auth_providers.dart` — `authStateProvider`, `currentUserProvider`, контролер.
- `lib/features/auth/presentation/pages/splash_page.dart` — сплеш екран (стан завантаження).
- `lib/features/auth/presentation/pages/login_page.dart` — сторінка логіну.
- `lib/features/auth/presentation/pages/register_page.dart` — сторінка реєстрації.
- `lib/features/dashboard/presentation/pages/dashboard_page.dart` — ціль захищеного маршруту.
- `lib/features/shell/presentation/main_shell.dart` — оболонка захищених маршрутів.
- `lib/main.dart` — ініціалізація `MaterialApp.router` з `routerProvider`.
- Тести: `test/widget/router_redirect_test.dart`, `test/widget/features/auth/presentation/login_page_test.dart`, `test/widget/dashboard_page_test.dart`.

### Виявлені залежності
- Навігація: `go_router` з використанням `redirect` та `ShellRoute`.
- Стан: `flutter_riverpod` (`StreamProvider<User?>` для auth стану).
- Джерела auth: `AuthRepository` з `FirebaseAuthRemoteDataSource` або `MockAuthRemoteDataSource` (через `kUseFirebase`).
- Віджет-екрани: Splash/Login/Register/Dashboard.
- Тести вже покривають ключові сценарії редіректів.

### Ризики
- Петлі редіректів при неправильних умовах (особливо для `/splash` та `/auth/*`).
- Переадресація під час async-змін auth стану (блимання між екранами).
- Неправильне визначення `isAuthRoute` (має бути перевірка `startsWith('/auth')`).
- Робота back-навігації після редіректів (очікувана поведінка: повернення не на захищений маршрут).
- Сумісність із deep-link: небажано перекривати дозволені маршрути при валідному стані.

## Детальний план виконання

### Етап 1: Підготовка [~15 хв]
- [ ] 1.1 Узгодити матрицю редіректів:
  - loading → якщо не на `/splash`, редірект на `/splash`.
  - unauthenticated → будь-яка не-`/auth/*` локація → `/auth/login`.
  - authenticated → якщо на `/`, `/splash` або `/auth/*` → `/dashboard`.
  - інакше → `null` (без змін).
- [ ] 1.2 Перевірити наявність маршрутів: `/splash`, `/auth/login`, `/auth/register`, `/dashboard`.
- [ ] 1.3 Перевірити оновлення стану через `refreshListenable` (листенер на `authStateProvider`).

Статус: Pending

### Етап 2: Реалізація в `router_provider.dart` [~25 хв]
- [ ] 2.1 Додати/перевірити `GoRouterRefresh` (слухає `authStateProvider` та викликає `notifyListeners()`).
- [ ] 2.2 Встановити `initialLocation: '/splash'`, `debugLogDiagnostics: true`.
- [ ] 2.3 Реалізувати `redirect`:
  - Визначити `isAuthRoute`, `isSplash` та `isRoot`.
  - `authAsync.when(loading: ...)` → якщо не `isSplash`, повернути `'/splash'`.
  - `authAsync.when(error: ...)` → якщо не `isAuthRoute`, повернути `'/auth/login'`.
  - `authAsync.when(data: user)` →
    - якщо `user == null` і не `isAuthRoute` → `'/auth/login'`.
    - якщо `user != null` і (`isAuthRoute` або `isSplash` або `isRoot`) → `'/dashboard'`.
    - інакше → `null`.
- [ ] 2.4 Переконатися, що відсутні петлі (повертати `null`, коли позиція вже цільова).
- [ ] 2.5 Залишити існуючу конфігурацію `ShellRoute` для захищених маршрутів.

Статус: Pending

### Етап 3: Тестування редіректів [~30 хв]
- [ ] 3.1 Перевірити сценарії:
  - Authenticated користувач на `/auth/login` → редірект на `/dashboard`.
  - Unauthenticated користувач на `/dashboard` → редірект на `/auth/login`.
  - Початок з `/` або будь-де під час loading → редірект на `/splash`.
  - Стан error → редірект на `/auth/login` для будь-якого не-`/auth/*`.
- [ ] 3.2 У віджет-тестах використовувати `ProviderScope(overrides: ...)`/моки для моделювання станів `authStateProvider`.
- [ ] 3.3 Переконатися у відсутності нескінченних редіректів (перевірити, що `redirect` повертає `null` у стабільних станах).

Статус: Pending

### Етап 4: Верифікація якості [~15 хв]
- [ ] 4.1 `dart format .`
- [ ] 4.2 `flutter analyze` (усунути попередження у тестах: порядок імпортів, невикористані імпорти).
- [ ] 4.3 `flutter test` (має пройти успішно).

Статус: Pending

### Етап 5: Документація [~10 хв]
- [ ] 5.1 Оновити цей `project_plan.md` зі статусами після виконання.
- [ ] 5.2 За потреби додати короткий розділ у `README.md` про правила редіректів.

Статус: Pending

### Етап 6: Коміт [~5 хв]
- [ ] 6.1 Коміт за Conventional Commits: `feat(router): implement auth redirects (Block 2)`.

Статус: Pending

## Команда для старту
Після схвалення плану, виконати: "Виконуй план: Блок 2 — Навігаціяg та редіректи".
