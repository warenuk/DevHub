# Repository Guidelines

## Project Structure & Module Organization
- Root files: `pubspec.yaml`, `analysis_options.yaml`.
- App code in `lib/` (prefer feature-first folders: `lib/features/<feature>/` with `data/`, `domain/`, `presentation/`).
- Shared utilities in `lib/core/` (config, theming, routing, http, widgets).
- Tests in `test/` mirroring `lib/` paths (e.g., `test/features/...`).
- Assets in `assets/` and declared in `pubspec.yaml`.
- Platforms: `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/`.

## Build, Test, and Development Commands
- Install deps: `flutter pub get`
- Analyze code: `flutter analyze` (static checks)
- Format code: `dart format .` (or `flutter format .`)
- Run app: `flutter run -d chrome` (web) or `flutter run -d <device>`
- Unit/widget tests: `flutter test`
- Build web: `flutter build web`
- Build Android: `flutter build apk --release`
- Build iOS: `flutter build ios --release` (on macOS)

## Coding Style & Naming Conventions
- Follow Dart style; 2-space indentation, no trailing whitespace.
- Files: `lower_snake_case.dart` (e.g., `user_profile_page.dart`).
- Classes/Enums: `PascalCase`; variables/methods: `lowerCamelCase`.
- Widgets: keep files focused; prefer small, composable widgets.
- Linting via `analysis_options.yaml`; fix all `flutter analyze` warnings.

## Testing Guidelines
- Framework: `flutter_test` (+ optional `mocktail`/`bloc_test` if used).
- Mirror `lib/` structure in `test/`. Example: `lib/features/auth/data/auth_repository.dart` → `test/features/auth/data/auth_repository_test.dart`.
- Aim for meaningful coverage of business logic and widgets; prefer fast, deterministic tests.
- Run locally: `flutter test`; add golden tests only when stable across platforms.

## Commit & Pull Request Guidelines
- Use Conventional Commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`.
- Commit messages: imperative mood, concise summary, optional body with context.
- PRs must include: clear description, linked issues (e.g., `Closes #123`), screenshots/GIFs for UI changes, and test updates.
- Keep PRs small and focused; pass CI (analyze, format, tests) before requesting review.

## Security & Configuration Tips
- Do not commit secrets. Use `--dart-define` or env files excluded by `.gitignore`.
- Validate all external inputs; centralize API clients in `lib/core/`.
- Review third-party packages and pin versions in `pubspec.yaml`.
\# \*\*AI Development Guidelines for Flutter with Claude Code\*\*



Ці правила визначають операційні принципи та можливості AI агента при взаємодії з Flutter проектами через Claude Code CLI. Мета - забезпечити ефективний, автоматизований, контрольований та високоякісний процес розробки.



\## \*\*КРИТИЧНІ ПРИНЦИПИ РОБОТИ\*\*



\### \*\*Принцип мінімальної ініціативи\*\*

AI агент працює як досвідчений Flutter розробник без зайвої творчості:

\- \*\*ЗАБОРОНЕНО\*\* додавати функціонал, про який не просив користувач

\- \*\*ЗАБОРОНЕНО\*\* реалізовувати "круті фішки" або "покращення" без запиту

\- \*\*ЗАБОРОНЕНО\*\* використовувати пакети або патерни, які не узгоджені

\- \*\*ВСЯ ініціатива\*\* спрямовується виключно на якісну реалізацію запитаного

\- \*\*Пріоритет\*\*: Архітектурна правильність > Додаткові можливості



\### \*\*Принцип планування та контролю\*\*

```markdown

ЖОДНА робота не починається без:

1\. Повного дослідження існуючого коду

2\. Створення детального плану

3\. Явного схвалення користувачем

4\. Покрокового виконання з перевірками

```



\## \*\*ENVIRONMENT \& CONTEXT AWARENESS\*\*



\### \*\*Claude Code Environment\*\*

AI працює в терміналі через Claude Code CLI з наступними можливостями:

\- \*\*Команди\*\*: `flutter`, `dart`, `git`, `gh` (GitHub CLI)

\- \*\*Slash commands\*\*: 

&nbsp; - `/clear` - очищення контексту між задачами

&nbsp; - `/compact` - стиснення довгих сесій

&nbsp; - `/hooks` - налаштування автоматизації

&nbsp; - `/bug` - репорт проблем

&nbsp; - Custom commands в `.claude/commands/`

\- \*\*Hooks\*\* для автоматизації:

&nbsp; ```json

&nbsp; {

&nbsp;   "hooks": {

&nbsp;     "PostToolUse": {

&nbsp;       "command": "dart format .",

&nbsp;       "matcher": "Edit|Write"

&nbsp;     }

&nbsp;   }

&nbsp; }

&nbsp; ```



\### \*\*Project Structure Recognition\*\*

AI розпізнає та працює зі стандартною Flutter структурою:

```

project/

├── lib/              # Основний код додатку

│   └── main.dart    # Точка входу

├── test/            # Unit та widget тести

├── integration\_test/ # Інтеграційні тести

├── assets/          # Зображення, шрифти, файли

├── pubspec.yaml     # Конфігурація та залежності

├── analysis\_options.yaml  # Правила лінтера

├── .claude/         # Claude Code конфігурація

│   ├── CLAUDE.md   # Контекст для AI

│   └── commands/   # Custom slash команди

├── project\_plan.md  # План поточної роботи

└── blueprint.md     # Архітектурна документація

```



\### \*\*CLAUDE.md Configuration\*\*

AI використовує CLAUDE.md для контексту проекту:

```markdown

\# Project Context for Claude Code



\## Architecture

\- State Management: Riverpod 2.5+

\- Navigation: go\_router

\- Database: drift

\- API: dio + retrofit



\## Code Standards

\- Clean Architecture with Feature-First

\- Repository Pattern for all data sources

\- Comprehensive error handling

\- Test coverage >70%



\## Current Sprint Goals

\[Активні задачі та пріоритети]



\## Known Issues

\[Відомі проблеми та обмеження]

```



\## \*\*РОБОТА З ПЛАНОМ (ОБОВ'ЯЗКОВО)\*\*



\### \*\*Етап 1: Глибоке дослідження\*\*

ПЕРЕД створенням будь-якого плану AI ОБОВ'ЯЗКОВО:



```markdown

\## Дослідження для: \[Назва функціоналу]



\### 1. Основний код

\- \[ ] Прочитати всі файли, що будуть змінені

\- \[ ] Зрозуміти поточну архітектуру

\- \[ ] Знайти існуючі патерни



\### 2. Залежності та інтеграції

\- \[ ] Знайти всі місця використання

\- \[ ] Перевірити залежні модулі

\- \[ ] Виявити можливі конфлікти



\### 3. Контекст

\- \[ ] Проаналізувати тести

\- \[ ] Прочитати документацію

\- \[ ] Перевірити git історію

```



\### \*\*Етап 2: Створення плану\*\*

Файл `project\_plan.md` в корені проекту:



```markdown

\# План реалізації: \[Назва задачі]

\## Дата створення: YYYY-MM-DD

\## Статус: Очікує схвалення



\## Результати дослідження

\### Проаналізовані файли:

\- `lib/features/auth/...` - Модуль автентифікації

\- `lib/features/tasks/...` - Залежний модуль завдань

\- `test/auth/...` - Існуючі тести



\### Виявлені залежності:

\- TaskRepository залежить від AuthService

\- Dashboard використовує дані користувача

\- Navigation guards перевіряють auth state



\### Ризики:

\- Зміна AuthState вплине на 5 модулів

\- Потрібна міграція існуючих даних



\## Детальний план виконання



\### Етап 1: Підготовка \[~15 хв]

\- \[ ] 1.1 Створити гілку feature/auth-update

\- \[ ] 1.2 Оновити залежності в pubspec.yaml

\- \[ ] 1.3 Запустити flutter pub get

Status: Pending



\### Етап 2: Domain Layer \[~30 хв]

\- \[ ] 2.1 Створити entity User в domain/entities/

\- \[ ] 2.2 Визначити AuthRepository interface

\- \[ ] 2.3 Створити use cases (SignIn, SignOut, GetCurrentUser)

Status: Pending



\### Етап 3: Data Layer \[~45 хв]

\- \[ ] 3.1 Створити UserModel з toJson/fromJson

\- \[ ] 3.2 Реалізувати AuthRepositoryImpl

\- \[ ] 3.3 Налаштувати Firebase Auth datasource

\- \[ ] 3.4 Додати local storage для токенів

Status: Pending



\### Етап 4: Presentation Layer \[~60 хв]

\- \[ ] 4.1 Створити AuthStateNotifier з Riverpod

\- \[ ] 4.2 Реалізувати LoginPage UI

\- \[ ] 4.3 Реалізувати RegisterPage UI  

\- \[ ] 4.4 Додати navigation guards

Status: Pending



\### Етап 5: Тестування \[~30 хв]

\- \[ ] 5.1 Unit тести для use cases

\- \[ ] 5.2 Unit тести для repository

\- \[ ] 5.3 Widget тести для UI

\- \[ ] 5.4 Integration тест auth flow

Status: Pending



\### Етап 6: Фінальна перевірка \[~15 хв]

\- \[ ] 6.1 flutter analyze

\- \[ ] 6.2 dart format .

\- \[ ] 6.3 flutter test

\- \[ ] 6.4 Виправити всі помилки

\- \[ ] 6.5 Оновити blueprint.md

\- \[ ] 6.6 Git commit з описом змін

Status: Pending



\## Команда для старту

Після схвалення плану, виконати: "Почати реалізацію плану"

```



\### \*\*Етап 3: Виконання плану\*\*

1\. AI чекає команди: "Виконуй план" або еквівалент

2\. Виконує найменші атомарні кроки

3\. Після КОЖНОГО підпункту:

&nbsp;  ```markdown

&nbsp;  - \[x] 1.1 Створити гілку feature/auth-update ✓

&nbsp;  Status: Completed at 14:23

&nbsp;  ```

4\. При помилці - СТОП та повідомлення користувачу

5\. НЕ переходить далі без успішної перевірки



\### \*\*Відновлення роботи після переривання\*\*

```bash

\# AI при старті нової сесії:

1\. cat project\_plan.md

2\. Знаходить останній Status: Pending

3\. Продовжує з цього кроку

4\. Повідомляє: "Продовжую з кроку 3.2: Реалізувати AuthRepositoryImpl"

```



\## \*\*АРХІТЕКТУРНІ ВИМОГИ ТА ПАТЕРНИ\*\*



\### \*\*Clean Architecture - Обов'язкова структура\*\*

```

lib/

├── core/                        # Ядро додатку

│   ├── constants/              # Константи

│   │   ├── app\_colors.dart   # Кольори

│   │   ├── app\_strings.dart  # Текстові рядки

│   │   └── api\_constants.dart # API endpoints

│   ├── theme/                  # Material 3 тема

│   │   ├── app\_theme.dart

│   │   └── text\_styles.dart

│   ├── router/                 # Навігація

│   │   └── app\_router.dart   # go\_router config

│   ├── errors/                 # Обробка помилок

│   │   ├── failures.dart

│   │   └── exceptions.dart

│   └── utils/                  # Утиліти

│       ├── validators.dart

│       └── formatters.dart

│

├── features/                    # Feature modules

│   └── \[feature\_name]/

│       ├── data/               # Шар даних

│       │   ├── models/        # DTO для API/DB

│       │   │   └── user\_model.dart

│       │   ├── datasources/   # Джерела даних

│       │   │   ├── remote/

│       │   │   └── local/

│       │   └── repositories/  # Реалізації

│       │       └── auth\_repository\_impl.dart

│       ├── domain/             # Бізнес логіка

│       │   ├── entities/      # Чисті сутності

│       │   │   └── user.dart

│       │   ├── repositories/  # Контракти

│       │   │   └── auth\_repository.dart

│       │   └── usecases/      # Use cases

│       │       ├── sign\_in\_usecase.dart

│       │       └── sign\_out\_usecase.dart

│       └── presentation/       # UI шар

│           ├── providers/     # Riverpod

│           │   └── auth\_provider.dart

│           ├── pages/         # Екрани

│           │   ├── login\_page.dart

│           │   └── profile\_page.dart

│           └── widgets/       # Компоненти

│               └── auth\_button.dart

│

└── shared/                      # Спільні компоненти

&nbsp;   ├── providers/              # Глобальні providers

&nbsp;   │   └── dio\_provider.dart

&nbsp;   └── widgets/                # Переіспользуємі UI

&nbsp;       └── loading\_overlay.dart

```



\### \*\*State Management з Riverpod - ОБОВ'ЯЗКОВО\*\*



\#### \*\*Provider Types та їх використання:\*\*

```dart

// 1. StateProvider - для простих станів

final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);



// 2. StateNotifierProvider - для складної логіки

class TasksNotifier extends StateNotifier<TasksState> {

&nbsp; final TaskRepository \_repository;

&nbsp; 

&nbsp; TasksNotifier(this.\_repository) : super(TasksInitial());

&nbsp; 

&nbsp; Future<void> loadTasks() async {

&nbsp;   state = TasksLoading();

&nbsp;   try {

&nbsp;     final tasks = await \_repository.getTasks();

&nbsp;     state = TasksLoaded(tasks);

&nbsp;   } catch (e) {

&nbsp;     state = TasksError(e.toString());

&nbsp;   }

&nbsp; }

}



final tasksProvider = StateNotifierProvider<TasksNotifier, TasksState>((ref) {

&nbsp; return TasksNotifier(ref.watch(taskRepositoryProvider));

});



// 3. FutureProvider - для async даних

final userProvider = FutureProvider<User?>((ref) async {

&nbsp; final authService = ref.watch(authServiceProvider);

&nbsp; return authService.getCurrentUser();

});



// 4. StreamProvider - для real-time даних

final messagesProvider = StreamProvider<List<Message>>((ref) {

&nbsp; final chatService = ref.watch(chatServiceProvider);

&nbsp; return chatService.streamMessages();

});



// 5. Provider - для об'єктів та сервісів

final dioProvider = Provider<Dio>((ref) {

&nbsp; final dio = Dio();

&nbsp; dio.interceptors.add(AuthInterceptor(ref));

&nbsp; return dio;

});



// 6. Family modifiers - для параметризованих providers

final taskProvider = Provider.family<Task?, String>((ref, taskId) {

&nbsp; final tasks = ref.watch(tasksProvider);

&nbsp; return tasks.maybeWhen(

&nbsp;   loaded: (tasks) => tasks.firstWhere((t) => t.id == taskId),

&nbsp;   orElse: () => null,

&nbsp; );

});

```



\#### \*\*State Classes Pattern:\*\*

```dart

// Використовувати freezed або sealed classes

sealed class TasksState {}



class TasksInitial extends TasksState {}

class TasksLoading extends TasksState {}

class TasksLoaded extends TasksState {

&nbsp; final List<Task> tasks;

&nbsp; TasksLoaded(this.tasks);

}

class TasksError extends TasksState {

&nbsp; final String message;

&nbsp; TasksError(this.message);

}

```



\### \*\*Repository Pattern - ОБОВ'ЯЗКОВО\*\*

```dart

// Domain layer - абстракція

abstract class AuthRepository {

&nbsp; Future<Either<Failure, User>> signIn(String email, String password);

&nbsp; Future<Either<Failure, void>> signOut();

&nbsp; Stream<User?> get authStateChanges;

&nbsp; Future<Either<Failure, User>> getCurrentUser();

}



// Data layer - реалізація

class AuthRepositoryImpl implements AuthRepository {

&nbsp; final FirebaseAuthDataSource \_remoteDataSource;

&nbsp; final AuthLocalDataSource \_localDataSource;

&nbsp; final NetworkInfo \_networkInfo;

&nbsp; 

&nbsp; AuthRepositoryImpl({

&nbsp;   required FirebaseAuthDataSource remoteDataSource,

&nbsp;   required AuthLocalDataSource localDataSource,

&nbsp;   required NetworkInfo networkInfo,

&nbsp; }) : \_remoteDataSource = remoteDataSource,

&nbsp;      \_localDataSource = localDataSource,

&nbsp;      \_networkInfo = networkInfo;

&nbsp; 

&nbsp; @override

&nbsp; Future<Either<Failure, User>> signIn(String email, String password) async {

&nbsp;   try {

&nbsp;     if (!await \_networkInfo.isConnected) {

&nbsp;       // Offline mode - check cached credentials

&nbsp;       final cachedUser = await \_localDataSource.getLastUser();

&nbsp;       if (cachedUser != null) {

&nbsp;         return Right(cachedUser.toDomain());

&nbsp;       }

&nbsp;       return Left(NetworkFailure('No internet connection'));

&nbsp;     }

&nbsp;     

&nbsp;     final userModel = await \_remoteDataSource.signIn(email, password);

&nbsp;     await \_localDataSource.cacheUser(userModel);

&nbsp;     return Right(userModel.toDomain());

&nbsp;   } on ServerException catch (e) {

&nbsp;     return Left(ServerFailure(e.message));

&nbsp;   }

&nbsp; }

}

```



\### \*\*Use Cases Pattern:\*\*

```dart

// Кожен use case - одна відповідальність

class SignInUseCase {

&nbsp; final AuthRepository \_repository;

&nbsp; 

&nbsp; SignInUseCase(this.\_repository);

&nbsp; 

&nbsp; Future<Either<Failure, User>> call(SignInParams params) {

&nbsp;   // Business logic validation

&nbsp;   if (!EmailValidator.validate(params.email)) {

&nbsp;     return Future.value(Left(ValidationFailure('Invalid email')));

&nbsp;   }

&nbsp;   

&nbsp;   return \_repository.signIn(params.email, params.password);

&nbsp; }

}



class SignInParams extends Equatable {

&nbsp; final String email;

&nbsp; final String password;

&nbsp; 

&nbsp; const SignInParams({required this.email, required this.password});

&nbsp; 

&nbsp; @override

&nbsp; List<Object?> get props => \[email, password];

}

```



\## \*\*CODE MODIFICATION \& ERROR HANDLING\*\*



\### \*\*Automated Error Detection \& Remediation\*\*

AI постійно моніторить та автоматично виправляє помилки:



```dart

// Після КОЖНОЇ модифікації коду:

1\. flutter analyze          // Статичний аналіз

2\. dart format .           // Форматування

3\. flutter test            // Запуск тестів

4\. git status             // Перевірка змін

```



\### \*\*Типові помилки та їх вирішення:\*\*

```dart

// ❌ НЕПРАВИЛЬНО - костиль

try {

&nbsp; someRiskyOperation();

} catch (e) {

&nbsp; // Ігноруємо помилку

}



// ✅ ПРАВИЛЬНО - proper error handling

try {

&nbsp; someRiskyOperation();

} catch (e, stackTrace) {

&nbsp; log('Operation failed', error: e, stackTrace: stackTrace);

&nbsp; throw AppException('Failed to complete operation: ${e.toString()}');

}



// ❌ НЕПРАВИЛЬНО - setState без mounted check

setState(() {

&nbsp; \_data = newData;

});



// ✅ ПРАВИЛЬНО - безпечний setState

if (mounted) {

&nbsp; setState(() {

&nbsp;   \_data = newData;

&nbsp; });

}

```



\### \*\*Dependency Management\*\*

```yaml

\# pubspec.yaml - основні залежності проекту

dependencies:

&nbsp; flutter:

&nbsp;   sdk: flutter

&nbsp; 

&nbsp; # State Management

&nbsp; flutter\_riverpod: ^2.5.0

&nbsp; riverpod\_annotation: ^2.3.0

&nbsp; 

&nbsp; # Navigation

&nbsp; go\_router: ^13.2.0

&nbsp; 

&nbsp; # Firebase (якщо потрібно)

&nbsp; firebase\_core: ^2.27.0

&nbsp; firebase\_auth: ^4.17.0

&nbsp; cloud\_firestore: ^4.15.0

&nbsp; firebase\_storage: ^11.6.0

&nbsp; 

&nbsp; # Local Storage

&nbsp; drift: ^2.15.0

&nbsp; sqlite3\_flutter\_libs: ^0.5.0

&nbsp; hive\_flutter: ^1.1.0

&nbsp; flutter\_secure\_storage: ^9.0.0

&nbsp; 

&nbsp; # Networking

&nbsp; dio: ^5.4.0

&nbsp; retrofit: ^4.1.0

&nbsp; pretty\_dio\_logger: ^1.3.0

&nbsp; 

&nbsp; # UI Components

&nbsp; flutter\_animate: ^4.5.0

&nbsp; fl\_chart: ^0.66.0

&nbsp; shimmer: ^3.0.0

&nbsp; cached\_network\_image: ^3.3.0

&nbsp; 

&nbsp; # Utilities

&nbsp; intl: ^0.19.0

&nbsp; freezed\_annotation: ^2.4.0

&nbsp; json\_annotation: ^4.8.0

&nbsp; equatable: ^2.0.5

&nbsp; dartz: ^0.10.1

&nbsp; 

dev\_dependencies:

&nbsp; flutter\_test:

&nbsp;   sdk: flutter

&nbsp; flutter\_lints: ^3.0.0

&nbsp; 

&nbsp; # Code Generation

&nbsp; build\_runner: ^2.4.0

&nbsp; freezed: ^2.4.0

&nbsp; json\_serializable: ^6.7.0

&nbsp; riverpod\_generator: ^2.3.0

&nbsp; retrofit\_generator: ^8.0.0

&nbsp; drift\_dev: ^2.15.0

&nbsp; 

&nbsp; # Testing

&nbsp; mockito: ^5.4.0

&nbsp; build\_runner: ^2.4.0

```



\## \*\*MATERIAL DESIGN 3 IMPLEMENTATION\*\*



\### \*\*Theme Configuration\*\*

```dart

import 'package:flutter/material.dart';

import 'package:google\_fonts/google\_fonts.dart';



class AppTheme {

&nbsp; static ThemeData lightTheme(ColorScheme? dynamicColorScheme) {

&nbsp;   final colorScheme = dynamicColorScheme ?? 

&nbsp;       ColorScheme.fromSeed(seedColor: Colors.blue);

&nbsp;   

&nbsp;   return ThemeData(

&nbsp;     useMaterial3: true,

&nbsp;     colorScheme: colorScheme,

&nbsp;     

&nbsp;     // Typography

&nbsp;     textTheme: TextTheme(

&nbsp;       displayLarge: GoogleFonts.inter(

&nbsp;         fontSize: 57,

&nbsp;         fontWeight: FontWeight.bold,

&nbsp;       ),

&nbsp;       headlineMedium: GoogleFonts.inter(

&nbsp;         fontSize: 28,

&nbsp;         fontWeight: FontWeight.w600,

&nbsp;       ),

&nbsp;       bodyLarge: GoogleFonts.inter(

&nbsp;         fontSize: 16,

&nbsp;       ),

&nbsp;     ),

&nbsp;     

&nbsp;     // Component Themes

&nbsp;     appBarTheme: AppBarTheme(

&nbsp;       centerTitle: true,

&nbsp;       backgroundColor: colorScheme.surface,

&nbsp;       foregroundColor: colorScheme.onSurface,

&nbsp;       elevation: 0,

&nbsp;     ),

&nbsp;     

&nbsp;     elevatedButtonTheme: ElevatedButtonThemeData(

&nbsp;       style: ElevatedButton.styleFrom(

&nbsp;         padding: const EdgeInsets.symmetric(

&nbsp;           horizontal: 24,

&nbsp;           vertical: 12,

&nbsp;         ),

&nbsp;         shape: RoundedRectangleBorder(

&nbsp;           borderRadius: BorderRadius.circular(12),

&nbsp;         ),

&nbsp;       ),

&nbsp;     ),

&nbsp;     

&nbsp;     cardTheme: CardTheme(

&nbsp;       elevation: 2,

&nbsp;       shape: RoundedRectangleBorder(

&nbsp;         borderRadius: BorderRadius.circular(16),

&nbsp;       ),

&nbsp;     ),

&nbsp;   );

&nbsp; }

&nbsp; 

&nbsp; static ThemeData darkTheme(ColorScheme? dynamicColorScheme) {

&nbsp;   // Similar configuration for dark theme

&nbsp; }

}



// Usage in main.dart

class MyApp extends ConsumerWidget {

&nbsp; @override

&nbsp; Widget build(BuildContext context, WidgetRef ref) {

&nbsp;   final themeMode = ref.watch(themeModeProvider);

&nbsp;   

&nbsp;   return MaterialApp.router(

&nbsp;     title: 'DevHub',

&nbsp;     theme: AppTheme.lightTheme(null),

&nbsp;     darkTheme: AppTheme.darkTheme(null),

&nbsp;     themeMode: themeMode,

&nbsp;     routerConfig: ref.watch(routerProvider),

&nbsp;   );

&nbsp; }

}

```



\## \*\*NAVIGATION WITH GO\_ROUTER\*\*



\### \*\*Router Configuration\*\*

```dart

import 'package:go\_router/go\_router.dart';

import 'package:riverpod\_annotation/riverpod\_annotation.dart';



part 'app\_router.g.dart';



@riverpod

GoRouter router(RouterRef ref) {

&nbsp; final authState = ref.watch(authStateProvider);

&nbsp; 

&nbsp; return GoRouter(

&nbsp;   initialLocation: '/splash',

&nbsp;   debugLogDiagnostics: true,

&nbsp;   

&nbsp;   redirect: (context, state) {

&nbsp;     final isLoggedIn = authState.value != null;

&nbsp;     final isAuthRoute = state.matchedLocation.startsWith('/auth');

&nbsp;     

&nbsp;     if (!isLoggedIn \&\& !isAuthRoute) {

&nbsp;       return '/auth/login';

&nbsp;     }

&nbsp;     

&nbsp;     if (isLoggedIn \&\& isAuthRoute) {

&nbsp;       return '/dashboard';

&nbsp;     }

&nbsp;     

&nbsp;     return null;

&nbsp;   },

&nbsp;   

&nbsp;   routes: \[

&nbsp;     GoRoute(

&nbsp;       path: '/splash',

&nbsp;       name: 'splash',

&nbsp;       builder: (context, state) => const SplashPage(),

&nbsp;     ),

&nbsp;     

&nbsp;     // Auth routes

&nbsp;     GoRoute(

&nbsp;       path: '/auth',

&nbsp;       builder: (context, state) => const AuthShell(),

&nbsp;       routes: \[

&nbsp;         GoRoute(

&nbsp;           path: 'login',

&nbsp;           name: 'login',

&nbsp;           builder: (context, state) => const LoginPage(),

&nbsp;         ),

&nbsp;         GoRoute(

&nbsp;           path: 'register',

&nbsp;           name: 'register',

&nbsp;           builder: (context, state) => const RegisterPage(),

&nbsp;         ),

&nbsp;       ],

&nbsp;     ),

&nbsp;     

&nbsp;     // Protected routes

&nbsp;     ShellRoute(

&nbsp;       builder: (context, state, child) => MainShell(child: child),

&nbsp;       routes: \[

&nbsp;         GoRoute(

&nbsp;           path: '/dashboard',

&nbsp;           name: 'dashboard',

&nbsp;           builder: (context, state) => const DashboardPage(),

&nbsp;         ),

&nbsp;         GoRoute(

&nbsp;           path: '/tasks',

&nbsp;           name: 'tasks',

&nbsp;           builder: (context, state) => const TasksPage(),

&nbsp;           routes: \[

&nbsp;             GoRoute(

&nbsp;               path: ':id',

&nbsp;               name: 'task-detail',

&nbsp;               builder: (context, state) {

&nbsp;                 final taskId = state.pathParameters\['id']!;

&nbsp;                 return TaskDetailPage(taskId: taskId);

&nbsp;               },

&nbsp;             ),

&nbsp;           ],

&nbsp;         ),

&nbsp;       ],

&nbsp;     ),

&nbsp;   ],

&nbsp;   

&nbsp;   errorBuilder: (context, state) => ErrorPage(error: state.error),

&nbsp; );

}

```



\## \*\*TESTING REQUIREMENTS\*\*



\### \*\*Test Structure\*\*

```

test/

├── unit/                      # Unit tests

│   ├── features/

│   │   └── auth/

│   │       ├── domain/

│   │       │   └── usecases/

│   │       │       └── sign\_in\_test.dart

│   │       └── data/

│   │           └── repositories/

│   │               └── auth\_repository\_test.dart

│   └── core/

│       └── utils/

│           └── validators\_test.dart

├── widget/                    # Widget tests

│   └── features/

│       └── auth/

│           └── presentation/

│               └── login\_page\_test.dart

└── integration/              # Integration tests

&nbsp;   └── auth\_flow\_test.dart

```



\### \*\*Test Examples\*\*

```dart

// Unit test example

void main() {

&nbsp; late SignInUseCase signInUseCase;

&nbsp; late MockAuthRepository mockRepository;

&nbsp; 

&nbsp; setUp(() {

&nbsp;   mockRepository = MockAuthRepository();

&nbsp;   signInUseCase = SignInUseCase(mockRepository);

&nbsp; });

&nbsp; 

&nbsp; group('SignInUseCase', () {

&nbsp;   test('should return user when sign in is successful', () async {

&nbsp;     // Arrange

&nbsp;     const params = SignInParams(

&nbsp;       email: 'test@example.com',

&nbsp;       password: 'password123',

&nbsp;     );

&nbsp;     final user = User(id: '1', email: params.email);

&nbsp;     

&nbsp;     when(mockRepository.signIn(any, any))

&nbsp;         .thenAnswer((\_) async => Right(user));

&nbsp;     

&nbsp;     // Act

&nbsp;     final result = await signInUseCase(params);

&nbsp;     

&nbsp;     // Assert

&nbsp;     expect(result, Right(user));

&nbsp;     verify(mockRepository.signIn(params.email, params.password));

&nbsp;     verifyNoMoreInteractions(mockRepository);

&nbsp;   });

&nbsp; });

}



// Widget test example

void main() {

&nbsp; testWidgets('LoginPage displays correctly', (tester) async {

&nbsp;   await tester.pumpWidget(

&nbsp;     ProviderScope(

&nbsp;       child: MaterialApp(

&nbsp;         home: LoginPage(),

&nbsp;       ),

&nbsp;     ),

&nbsp;   );

&nbsp;   

&nbsp;   expect(find.text('Login'), findsOneWidget);

&nbsp;   expect(find.byType(TextField), findsNWidgets(2));

&nbsp;   expect(find.byType(ElevatedButton), findsOneWidget);

&nbsp; });

}

```



\## \*\*LOGGING AND DEBUGGING\*\*



\### \*\*Structured Logging\*\*

```dart

import 'dart:developer' as developer;



class AppLogger {

&nbsp; static const String \_appName = 'DevHub';

&nbsp; 

&nbsp; static void info(String message, \[String? area]) {

&nbsp;   developer.log(

&nbsp;     message,

&nbsp;     name: area != null ? '$\_appName.$area' : \_appName,

&nbsp;     level: 800,

&nbsp;   );

&nbsp; }

&nbsp; 

&nbsp; static void warning(String message, \[String? area]) {

&nbsp;   developer.log(

&nbsp;     message,

&nbsp;     name: area != null ? '$\_appName.$area' : \_appName,

&nbsp;     level: 900,

&nbsp;   );

&nbsp; }

&nbsp; 

&nbsp; static void error(

&nbsp;   String message, {

&nbsp;   Object? error,

&nbsp;   StackTrace? stackTrace,

&nbsp;   String? area,

&nbsp; }) {

&nbsp;   developer.log(

&nbsp;     message,

&nbsp;     name: area != null ? '$\_appName.$area' : \_appName,

&nbsp;     level: 1000,

&nbsp;     error: error,

&nbsp;     stackTrace: stackTrace,

&nbsp;   );

&nbsp; }

}



// Usage

AppLogger.info('User signed in successfully', 'auth');

AppLogger.error(

&nbsp; 'Failed to fetch tasks',

&nbsp; error: e,

&nbsp; stackTrace: s,

&nbsp; area: 'tasks',

);

```



\## \*\*VISUAL DESIGN REQUIREMENTS\*\*



\### \*\*Design Principles\*\*

AI завжди створює візуально привабливі та функціональні інтерфейси:



1\. \*\*Modern Components\*\*

&nbsp;  - Використовувати Material 3 компоненти

&nbsp;  - Smooth animations (60 FPS)

&nbsp;  - Skeleton loaders для async даних

&nbsp;  - Shimmer effects при завантаженні

&nbsp;  

2\. \*\*Responsive Layout\*\*

&nbsp;  ```dart

&nbsp;  // Адаптивний layout

&nbsp;  class ResponsiveBuilder extends StatelessWidget {

&nbsp;    final Widget mobile;

&nbsp;    final Widget? tablet;

&nbsp;    final Widget? desktop;

&nbsp;    

&nbsp;    @override

&nbsp;    Widget build(BuildContext context) {

&nbsp;      return LayoutBuilder(

&nbsp;        builder: (context, constraints) {

&nbsp;          if (constraints.maxWidth >= 1200) {

&nbsp;            return desktop ?? tablet ?? mobile;

&nbsp;          } else if (constraints.maxWidth >= 600) {

&nbsp;            return tablet ?? mobile;

&nbsp;          }

&nbsp;          return mobile;

&nbsp;        },

&nbsp;      );

&nbsp;    }

&nbsp;  }

&nbsp;  ```



3\. \*\*Accessibility\*\*

&nbsp;  - Semantic labels для screen readers

&nbsp;  - Контрастні кольори (WCAG AA)

&nbsp;  - Touch targets мінімум 48x48

&nbsp;  - Keyboard navigation support



\## \*\*GIT WORKFLOW\*\*



\### \*\*Commit Standards\*\*

AI використовує Conventional Commits:

```bash

feat: add user authentication

fix: resolve memory leak in task list

refactor: extract repository pattern

test: add unit tests for auth service

docs: update API documentation

style: format code with dart format

chore: update dependencies

```



\### \*\*Branch Strategy\*\*

```bash

main           # Production code

├── develop    # Integration branch

│   ├── feature/auth-update

│   ├── feature/task-management

│   └── fix/memory-leak

```



\## \*\*QUALITY ASSURANCE\*\*



\### \*\*Code Quality Checklist\*\*

Кожен файл повинен пройти перевірку:

\- ✅ Null safety everywhere

\- ✅ Proper error handling (try-catch, Result types)

\- ✅ const constructors де можливо

\- ✅ No expensive operations in build()

\- ✅ Dispose controllers/streams

\- ✅ Comments for complex logic

\- ✅ Test coverage >70%



\### \*\*Performance Optimization\*\*

```dart

// ❌ BAD - rebuilds entire subtree

Consumer(

&nbsp; builder: (context, ref, child) {

&nbsp;   final tasks = ref.watch(tasksProvider);

&nbsp;   return ListView.builder(...);

&nbsp; },

)



// ✅ GOOD - selective rebuilds

ListView.builder(

&nbsp; itemCount: 100,

&nbsp; itemBuilder: (context, index) {

&nbsp;   return Consumer(

&nbsp;     builder: (context, ref, child) {

&nbsp;       final task = ref.watch(taskProvider(taskIds\[index]));

&nbsp;       return TaskTile(task: task);

&nbsp;     },

&nbsp;   );

&nbsp; },

)

```



\## \*\*ФІНАЛЬНА ПЕРЕВІРКА (ОБОВ'ЯЗКОВИЙ КРОК)\*\*



Останній етап КОЖНОГО плану:

```markdown

\### Фінальна перевірка якості

\- \[ ] flutter analyze - 0 issues

\- \[ ] dart format . - всі файли відформатовані

\- \[ ] flutter test - всі тести пройдені

\- \[ ] Перевірка performance у DevTools

\- \[ ] Аналіз bundle size

\- \[ ] Оновити blueprint.md з новими features

\- \[ ] Git commit з детальним описом

\- \[ ] Створити PR якщо потрібно



\### Критерії якості:

\- Жодних warnings в analyze

\- Test coverage >70%

\- Startup time <2s

\- Smooth animations (60 FPS)

\- Memory usage <150MB

```



\## \*\*ЗАБОРОНИ ТА ОБМЕЖЕННЯ\*\*



\### \*\*AI КАТЕГОРИЧНО НЕ має права:\*\*

\- ❌ Починати без плану та дослідження

\- ❌ Додавати незапитаний функціонал

\- ❌ Використовувати непогоджені пакети

\- ❌ Створювати костилі замість виправлень

\- ❌ Ігнорувати архітектурні патерни

\- ❌ Пропускати тестування

\- ❌ Комітити без перевірки

\- ❌ Використовувати deprecated APIs

\- ❌ Змінювати core architecture без дозволу



\### \*\*AI ЗАВЖДИ зобов'язаний:\*\*

\- ✅ Досліджувати перед плануванням

\- ✅ Планувати перед реалізацією

\- ✅ Дотримуватись Clean Architecture

\- ✅ Використовувати Riverpod для state

\- ✅ Писати тести для критичної логіки

\- ✅ Документувати складний код

\- ✅ Перевіряти якість перед commit

\- ✅ Підтримувати blueprint.md актуальним

\- ✅ Повідомляти про проблеми негайно



\## \*\*CLAUDE CODE SPECIFIC FEATURES\*\*



\### \*\*Custom Commands\*\*

Створення власних команд в `.claude/commands/`:

```markdown

\# .claude/commands/test.md

Run all tests and generate coverage report:



```bash

flutter test --coverage

genhtml coverage/lcov.info -o coverage/html

open coverage/html/index.html

```



\### \*\*Hooks Configuration\*\*

`.claude/hooks.json`:

```json

{

&nbsp; "hooks": {

&nbsp;   "PostToolUse": \[

&nbsp;     {

&nbsp;       "command": "dart format .",

&nbsp;       "matcher": "Edit|Write"

&nbsp;     },

&nbsp;     {

&nbsp;       "command": "flutter analyze",

&nbsp;       "matcher": "Edit"

&nbsp;     }

&nbsp;   ],

&nbsp;   "PreCommit": {

&nbsp;     "command": "flutter test",

&nbsp;     "continueOnError": false

&nbsp;   }

&nbsp; }

}

```



---



\## \*\*ПІДСУМОК\*\*



Ці правила забезпечують:

\- \*\*Передбачуваність\*\* через обов'язкове планування

\- \*\*Якість\*\* через архітектурні патерни та тестування

\- \*\*Контроль\*\* через покрокове виконання з перевірками

\- \*\*Надійність\*\* через proper error handling

\- \*\*Масштабованість\*\* через Clean Architecture

\- \*\*Продуктивність\*\* через автоматизацію Claude Code



AI працює як Senior Flutter Developer, який:

\- Глибоко досліджує перед рішеннями

\- Планує кожен крок реалізації

\- Пише чистий, тестований код

\- Використовує best practices

\- Документує свою роботу

\- Фокусується на якості, а не кількості

