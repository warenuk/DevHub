# План реалізації: GitHub інтеграція комітів (repos, activity, commits)
## Дата створення: 2025-09-07
## Статус: Очікує схвалення

## Результати дослідження
### Проаналізовані файли:
- `lib/shared/providers/dio_provider.dart` — базовий HTTP‑клієнт (Dio)
- `lib/shared/providers/secure_storage_provider.dart` — сховище ключів (FlutterSecureStorage)
- `lib/features/github/domain/{entities,repositories}` — Repo/PR/Activity контракти
- `lib/features/github/data/repositories/github_repository_impl.dart` — наразі mock
- `lib/features/github/presentation/{providers,pages}` — Repositories/Activity UI + провайдери
- `lib/features/commits/domain/{entities,repositories}` — сутність CommitInfo + контракт
- `lib/features/commits/data/repositories/mock_commits_repository.dart` — mock коміти
- `lib/features/commits/presentation/{providers,pages}` — провайдери/сторінка комітів
- `lib/features/settings/presentation/pages/settings_page.dart` — введення GitHub/AI ключів
- `lib/core/router/router_provider.dart` — маршрути `/github/*`, `/commits`
- `KEYS_GUIDE.md` — інструкції по токенам, наприкінці — тестовий PAT (не використовується напряму)

### Виявлені залежності:
- HTTP: `dio` з логером; токен зберігається у `FlutterSecureStorage`
- State: Riverpod (`Provider`, `FutureProvider`) для DI та async станів
- Навігація: `go_router` — маршрути для репо/активності/комітів уже зареєстровані
- Тести: наявні widget тести для сторінок і базова перевірка Settings/Repos

### Ризики:
- Token leakage: реальний PAT присутній у `KEYS_GUIDE.md` (потрібно видалити з історії у наступному PR)
- Rate limiting GitHub API без заголовка `User-Agent`/`Accept`
- Web оточення: `flutter_secure_storage` на web зберігає у localStorage — потрібен fallback через `--dart-define` для CI

## Детальний план виконання

### Етап 1: Підготовка [~20 хв]
- [ ] 1.1 Додати `github_client_provider.dart` (baseUrl, headers, User‑Agent, Accept)
- [ ] 1.2 Додати провайдер `githubAuthHeaderProvider` (читає токен зі сховища; fallback з `String.fromEnvironment('GITHUB_TOKEN')`)
- [ ] 1.3 Оновити `analysis_options.yaml` за потреби (deny print, allow logger)
Status: Pending

### Етап 2: Data Layer [~50 хв]
- [ ] 2.1 Створити `GithubRemoteDataSource` (Dio) з методами:
      - GET `/user` (для login/name)
      - GET `/user/repos` (пагінація, query фільтр по name)
      - GET `/repos/{owner}/{repo}/events` (activity)
      - GET `/repos/{owner}/{repo}/commits` (останні коміти)
- [ ] 2.2 Замапити JSON -> доменні сутності `Repo`, `ActivityEvent`, `CommitInfo`
- [ ] 2.3 Замінити `GithubRepositoryImpl` на реальну імплементацію (через DS)
- [ ] 2.4 Додати `GithubCommitsRepository` (implements `CommitsRepository`) для списку останніх комітів
Status: Pending

### Етап 3: Domain/Use Cases [~30 хв]
- [ ] 3.1 Додати use case `ListUserReposUseCase(query,page)`
- [ ] 3.2 Додати use case `GetRepoActivityUseCase(owner,repo)`
- [ ] 3.3 Додати use case `ListRepoCommitsUseCase(owner,repo)` та `ListRecentCommitsUseCase()`
Status: Pending

### Етап 4: Presentation [~45 хв]
- [ ] 4.1 Оновити `github_providers.dart` для роботи з реальним репозиторієм
- [ ] 4.2 Додати провайдери `repoCommitsProvider(owner,name)` та `currentGithubUserProvider`
- [ ] 4.3 Оновити `RepositoriesPage`: пошук по name -> параметр `query`, refresh, empty/error
- [ ] 4.4 Оновити `CommitsPage`: показ комітів вибраного репо (параметр) + “Recent” агрегатор (по top‑N оновлених репо)
- [ ] 4.5 Дашборд: використовувати `recentCommitsProvider` з GitHub репозиторію
Status: Pending

### Етап 5: Обробка помилок та логування [~20 хв]
- [ ] 5.1 Мапінг HTTP помилок у `Failure`: 401 -> AuthFailure (попросити ввести токен), 403 -> RateLimitFailure, інші -> Server/NetworkFailure
- [ ] 5.2 `AppLogger`: лог ключових запитів/збоїв без витоків токену
- [ ] 5.3 UX: повідомлення і CTA на `SettingsPage` при 401
Status: Pending

### Етап 6: Тести [~60 хв]
- [ ] 6.1 Unit: JSON -> Entity мапінг (fixtures)
- [ ] 6.2 Unit: Repo/DS з моканим API‑клієнтом (Mockito)
- [ ] 6.3 Widget: `RepositoriesPage`/`CommitsPage` з фейковими провайдерами (loading/empty/error/success)
- [ ] 6.4 Інтеграційний: smoke‑прохід GitHub флоу з інʼєктованим токеном через `--dart-define`
Status: Pending

### Етап 7: Фінальна перевірка [~20 хв]
- [ ] 7.1 `flutter analyze` без попереджень
- [ ] 7.2 `dart format .`
- [ ] 7.3 `flutter test` (локально + CI)
- [ ] 7.4 Оновити `KEYS_GUIDE.md` (прибрати реальний PAT, додати інструкції), README
- [ ] 7.5 Conventional Commit: `feat(github): real API for repos/activity/commits`
Status: Pending

## Команда для старту
Після схвалення плану: "Виконуй план GitHub інтеграції".

