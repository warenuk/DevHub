# План реалізації: Архітектурне узгодження та завершення
## Дата створення: 2025-09-06
## Статус: В роботі

## Результати дослідження
### Проаналізовані файли:
- lib/main.dart — MaterialApp.router, ініт Firebase (через `kUseFirebase`), Riverpod `ProviderScope`.
- lib/core/router/router_provider.dart — GoRouter, ShellRoute, редіректи за auth-станом, refresh через `ChangeNotifier` + `ref.listen`.
- lib/core/theme/app_theme.dart — Material 3 теми, card/appBar/button/text налаштування.
- lib/core/{constants,errors,utils} — `api_constants.dart`, `app_strings.dart`, `app_colors.dart`; `failures.dart`, `exceptions.dart`; `validators.dart`, `formatters.dart`.
- lib/shared/providers — `dio_provider.dart`, `secure_storage_provider.dart`.
- features/auth — Clean Architecture: domain (entities, repositories, usecases), data (remote/local datasources, repo impl), presentation (providers, pages, widgets).
- features/notes — повний приклад Clean Architecture (in-memory репозиторій, use cases, StateNotifier controller, сторінка).
- features/{dashboard,assistant,github,commits,settings,shell} — презентаційний шар з окремими сторінками.
- test/ — unit і widget тести: use cases, repository, router redirects/deeplinks, pages (login, notes, dashboard тощо).
- pubspec.yaml — залежності (Riverpod, GoRouter, Dio, Freezed, JSON Serializable, Drift/Hive, Firebase).

### Виявлені залежності:
- `auth_providers.dart` експортує `kUseFirebase` (toggle середовища) та збирає репозиторій (Firebase/Mock + SecureStorage).
- `router_provider.dart` залежить від `authStateProvider` і управляє редіректами.
- `dashboard_page.dart` читає `currentUserProvider` та керує навігацією.
- `notes` працює із in-memory репозиторієм; не потребує мережі/БД.

### Ризики:
- Відсутнє централізоване логування подій/помилок (легко додати).
- Дрібні неточності темізації можуть прослизати без компіляції (виправлено нижче).

## Детальний план виконання

### Етап 1: Підготовка [~10 хв]
- [x] 1.1 Репозиторій проаналізовано (структура, шари, залежності)
- [x] 1.2 Перевірено `flutter analyze` і тести локально
- [x] 1.3 Уточнено точки покращення (логування, дрібні M3 налаштування)

### Етап 2: Core удосконалення [~15 хв]
- [x] 2.1 Додати `AppLogger` (структуроване логування) в `lib/core/utils/app_logger.dart`
- [x] 2.2 Інтегрувати логування у `AuthRepositoryImpl` при обробці помилок
- [x] 2.3 Виправити `CardThemeData` -> `CardTheme` у темі (M3)

### Етап 3: Навігація та охоронці [~10 хв]
- [x] 3.1 Перевірити редіректи для всіх шляхів (guest/auth) на e2e сценаріях
- [x] 3.2 Уточнити поведінку splash/error (за потреби додати окрему error page)

### Етап 4: Узгодженість фіч [~20 хв]
- [x] 4.1 Перевірити DI провайдери (consistency: `Provider`, `StateNotifierProvider`)
- [ ] 4.2 Переглянути віджети на предмет повторного використання спільних компонентів
- [ ] 4.3 Зафіксувати контракти репозиторіїв (докстрінги, винятки -> Failures)

### Етап 5: Тести [~15 хв]
- [ ] 5.1 Додати точкові тести для логування (smoke, неінвазивно)
- [x] 5.2 Переглянути/доповнити router redirect/deeplink кейси
- [x] 5.3 Запустити повний набір тестів

### Етап 6: Фінальна перевірка [~10 хв]
- [x] 6.1 flutter analyze
- [x] 6.2 dart format .
- [x] 6.3 flutter test
- [x] 6.4 Оновити план статусами

## Команда для старту
План виконується по кроках згідно статусів вище.

## Notes — Persistence & Dashboard Integration (2025-09-06)
- [x] Персистентність: Hive DS + Repo (CRUD, сортування)
- [x] DI: override InMemory > Hive у main.dart
- [x] Дашборд: панель Notes показує кількість і 3 заголовки; tap > /notes
- [x] Use cases: валідація title (create/update)
- [x] Контролер: try/catch, AsyncValue.error на помилках
- [x] Тести: unit для HiveRepo, widget для панелі Notes
- [x] Аналіз/форматування/повний прогін тестів
