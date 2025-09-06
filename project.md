# ТЕХНІЧНЕ ЗАВДАННЯ ДЛЯ AI-РЕАЛІЗАЦІЇ
## DevHub - Персональний центр продуктивності розробника

### Метадані проекту
- **Платформа**: Flutter Desktop (Windows/macOS/Linux)
- **Архітектурний паттерн**: Clean Architecture з Feature-First підходом
- **State Management**: Riverpod 2.5+
- **Локальне сховище**: SQLite через Drift + Hive для кешування
- **Дизайн система**: Material 3 з кастомною темою

---

## ЗАГАЛЬНІ АРХІТЕКТУРНІ ВИМОГИ

### Візуальна стилістика додатку
Весь додаток повинен дотримуватися єдиного дизайну:

**Кольорова схема:**
- Primary: Deep Purple (#6750A4) 
- Secondary: Teal (#00897B)
- Surface: адаптивні відтінки сірого
- Error: Material Red (#BA1A1A)
- Success: Green (#4CAF50)
- Warning: Orange (#FF9800)
- Темна тема: обов'язкова з OLED-friendly чорним фоном (#000000)

**Типографіка:**
- Заголовки H1: Inter Bold 32px
- Заголовки H2: Inter SemiBold 24px
- Заголовки H3: Inter Medium 18px
- Основний текст: Inter Regular 14px
- Малий текст: Inter Regular 12px
- Код: JetBrains Mono 14px

**Компоненти UI:**
- Карточки з легкою тінню (elevation: 2) та rounded corners (borderRadius: 12px)
- Кнопки з ripple ефектом та hover станами (scale: 1.02 on hover)
- Плавні анімації переходів (duration: 300ms, curve: easeInOutCubic)
- Glassmorphism ефекти для модальних вікон (blur: 10px, opacity: 0.8)
- Gradient акценти для важливих елементів (linear gradient від primary до secondary)
- Spacing: використовувати кратні 4px (4, 8, 12, 16, 24, 32, 48)

### Шарова архітектура
Кожен функціональний модуль повинен складатися з трьох шарів:

```
features/
└── module_name/
    ├── presentation/
    │   ├── screens/
    │   ├── widgets/
    │   └── providers/
    ├── domain/
    │   ├── entities/
    │   ├── repositories/
    │   └── use_cases/
    └── data/
        ├── repositories/
        ├── data_sources/
        └── models/
```

### Загальні технічні принципи
- Використовувати `Result<T>` або `Either<L,R>` паттерн для error handling
- Всі асинхронні операції через FutureProvider або StreamProvider
- Immutable state з використанням freezed пакету
- Dependency injection через Riverpod providers
- Локалізація ready (навіть якщо тільки англійська)

---

## БЛОК 1: БАЗОВА ІНФРАСТРУКТУРА ТА АУТЕНТИФІКАЦІЯ

### 1.1 Ініціалізація проекту та конфігурація

#### Структура проекту
Створити наступну структуру директорій:
```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart      # Всі кольори додатку
│   │   ├── app_dimensions.dart  # Spacing, радіуси, розміри
│   │   └── app_strings.dart     # Текстові константи
│   ├── theme/
│   │   ├── app_theme.dart       # ThemeData для light/dark
│   │   └── text_styles.dart     # Всі текстові стилі
│   ├── router/
│   │   ├── app_router.dart      # GoRouter конфігурація
│   │   └── route_guards.dart    # Auth guards
│   ├── utils/
│   │   ├── result.dart          # Result<T> implementation
│   │   └── extensions.dart      # Dart extensions
│   └── errors/
│       └── app_exceptions.dart  # Custom exceptions
├── features/
│   └── [модулі будуть тут]
└── main.dart
```

#### Конфігурація теми
Створити тему використовуючи Material 3:
- Light theme: білий background з легкими тінями
- Dark theme: чистий чорний (#000000) background
- Використовувати ColorScheme.fromSeed() з seedColor: #6750A4
- Всі карточки повинні мати: borderRadius: 12, elevation: 2 (light) / 0 (dark)
- Кнопки: height: 48px, borderRadius: 24px, з ripple ефектом
- TextField: outlined стиль з borderRadius: 8px

#### Router конфігурація
GoRouter налаштування:
- Використати ShellRoute для основного layout з sidebar
- Nested routes для кожного модуля
- Redirect logic для неавторизованих користувачів
- Transition animations: SlideTransition для горизонтальної навігації
- Deep linking підтримка для desktop (наприклад: devhub://tasks/123)

#### База даних
Drift конфігурація:
```sql
-- Основні таблиці (концептуально):
users (id, email, name, avatar_url, created_at, settings_json)
tasks (id, title, description, status, priority, project_id, due_date, created_at, updated_at)
notes (id, title, content, tags, created_at, updated_at, is_deleted)
time_logs (id, task_id, start_time, end_time, description)
projects (id, name, color, icon, created_at)
tags (id, name, color)
```

### 1.2 Модуль аутентифікації

#### Domain Layer
**Entities:**
```dart
User entity повинен містити:
- id: String
- email: String
- name: String
- avatarUrl: String?
- createdAt: DateTime
- settings: UserSettings
- isEmailVerified: bool
```

**Repository Interface:**
```dart
AuthRepository методи:
- Future<Result<User>> signInWithEmail(String email, String password)
- Future<Result<User>> signUpWithEmail(String email, String password, String name)
- Future<Result<void>> signOut()
- Stream<User?> watchAuthState()
- Future<Result<void>> resetPassword(String email)
- Future<Result<User>> updateProfile(Map<String, dynamic> data)
```

**Use Cases:**
Створити окремий use case для кожної операції:
- SignInUseCase: валідація email/password, виклик repository, збереження токена
- SignUpUseCase: валідація даних, створення користувача, автоматичний sign in
- SignOutUseCase: очистка локальних даних, виклик repository
- GetCurrentUserUseCase: отримання користувача з кешу або API

#### Data Layer
**Local Implementation:**
- Використовувати Hive для зберігання User об'єкта
- flutter_secure_storage для токенів
- Mock AuthService для тестування без backend:
  - Hardcoded users для тестування
  - Симуляція network delay (Future.delayed)
  - Збереження в локальній базі

**Models:**
```dart
UserModel extends User:
- fromJson factory constructor
- toJson method
- copyWith method
- Використати json_serializable
```

#### Presentation Layer
**Providers:**
```dart
authStateProvider: StreamProvider для стану аутентифікації
currentUserProvider: Provider для поточного користувача
authControllerProvider: StateNotifierProvider для auth операцій
```

**Screens:**

**1. Splash Screen:**
- Gradient background: linear від #6750A4 до #00897B
- Анімований логотип: scale від 0.5 до 1.0 + fade in (1 секунда)
- Circular progress indicator знизу (indeterminate)
- Перевірка auth стану та redirect

**2. Login Screen:**
```
Макет:
┌─────────────────────────────────────┐
│                                     │
│         [Animated Logo]             │ <- Pulse animation
│         DevHub                      │ <- Fade in текст
│                                     │
│   ┌─────────────────────────┐      │
│   │ 📧 Email                │      │ <- Outlined TextField
│   └─────────────────────────┘      │
│                                     │
│   ┌─────────────────────────┐      │
│   │ 🔒 Password             │      │ <- Password visibility toggle
│   └─────────────────────────┘      │
│                                     │
│   [✓] Remember me  Forgot?         │
│                                     │
│   ┌─────────────────────────┐      │
│   │      SIGN IN            │      │ <- Gradient button
│   └─────────────────────────┘      │
│                                     │
│   ──── Or continue with ────       │
│                                     │
│   [G] Google  [GH] GitHub          │ <- Icon buttons
│                                     │
│   New here? Create Account         │ <- TextButton
└─────────────────────────────────────┘
```

Анімації:
- TextField focus: border color animation + elevation
- Button press: scale 0.95 + ripple
- Error shake: TextField трясеться при помилці
- Loading: button text замінюється на CircularProgressIndicator

**3. Register Screen:**
- Multi-step форма (3 кроки)
- Step 1: Email & Password
- Step 2: Name & Avatar
- Step 3: Preferences (theme, notifications)
- Stepper widget з анімованими переходами
- Валідація на кожному кроці

### 1.3 Dashboard та Navigation Shell

#### Shell Layout
```
┌────────────────────────────────────────┐
│ ┌──────┬─────────────────────────────┐ │
│ │      │  Top Bar                    │ │
│ │  S   ├─────────────────────────────┤ │
│ │  i   │                             │ │
│ │  d   │                             │ │
│ │  e   │      Main Content           │ │
│ │  b   │       (Router Outlet)       │ │
│ │  a   │                             │ │
│ │  r   │                             │ │
│ └──────┴─────────────────────────────┘ │
└────────────────────────────────────────┘
```

**Sidebar специфікація:**
- Width: 280px (expanded), 80px (collapsed)
- Background: surface color з легким gradient
- Items:
  - Dashboard (home icon)
  - Tasks (check_circle icon)  
  - Notes (description icon)
  - Timer (timer icon)
  - GitHub (github icon)
  - AI Assistant (psychology icon)
  - Settings (settings icon)
- Active item: primary color background з opacity 0.1, bold text
- Hover: scale 1.02 + elevation
- Анімація collapse: width animation 300ms

**Top Bar:**
- Height: 64px
- Search bar по центру (width: 400px)
- User avatar справа з dropdown меню
- Notifications icon з badge
- Theme toggle icon

---

## БЛОК 2: CORE ФУНКЦІОНАЛЬНІСТЬ

### 2.1 Task Management Module

#### Domain Layer
**Task Entity структура:**
```
Task:
- id: String (UUID)
- title: String (max 200 chars)
- description: String (Markdown)
- status: TaskStatus enum
- priority: Priority enum  
- tags: List<String>
- projectId: String?
- subtasks: List<Subtask>
- attachments: List<Attachment>
- dueDate: DateTime?
- reminder: DateTime?
- estimatedTime: Duration?
- actualTime: Duration
- assignedTo: List<String> (user IDs)
- createdBy: String
- createdAt: DateTime
- updatedAt: DateTime
- completedAt: DateTime?
- isArchived: bool
- isDeleted: bool
- customFields: Map<String, dynamic>
```

**Repository методи:**
```
TaskRepository:
- Stream<List<Task>> watchTasks({Filter? filter, Sort? sort})
- Future<Result<Task>> createTask(TaskInput input)
- Future<Result<Task>> updateTask(String id, TaskUpdate update)
- Future<Result<void>> deleteTask(String id)
- Future<Result<void>> bulkUpdate(List<String> ids, TaskUpdate update)
- Stream<List<Task>> searchTasks(String query)
- Future<Result<TaskStatistics>> getStatistics()
```

#### Data Layer
**Drift таблиці:**
```sql
tasks - основна таблиця
subtasks - підзадачі з parent_id
task_tags - many-to-many
task_attachments - файли
task_history - історія змін
```

**Синхронізація логіка:**
- Кожна зміна зберігається локально з sync_status flag
- Background service перевіряє несинхронізовані зміни кожні 30 секунд
- При конфлікті: показати діалог користувачу або auto-merge по timestamp
- Офлайн операції зберігаються в queue (Hive box)

#### Presentation Layer

**1. Kanban Board View:**
```
Layout:
┌─────────────────────────────────────────────┐
│ [+ New Task] [Filter ▼] [Sort ▼] [View ▼]  │
├─────────────────────────────────────────────┤
│ TODO (4)    IN PROGRESS (2)   DONE (8)  +  │
├──────────────────────────────────────────── │
│ ┌─────────┐ ┌─────────┐    ┌─────────┐    │
│ │ Task    │ │ Task    │    │ Task    │    │
│ │ Card    │ │ Card    │    │ Card    │    │
│ └─────────┘ └─────────┘    └─────────┘    │
│ ┌─────────┐                 ┌─────────┐    │
│ │ Task    │                 │ Task    │    │
│ │ Card    │                 │ Card    │    │
│ └─────────┘                 └─────────┘    │
│ [+ Add]     [+ Add]         [+ Add]        │
└─────────────────────────────────────────────┘
```

**Task Card дизайн:**
```
┌─────────────────────────┐
│█ Task Title             │ <- Priority color stripe (4px)
│                         │
│ 📅 Due: Tomorrow        │ <- Red if overdue
│ ⏱️ Est: 2h | Act: 1.5h  │
│                         │
│ [Tag1] [Tag2]          │ <- Colored chips
│                         │
│ 3/5 subtasks ████░     │ <- Progress bar
│                         │
│ [👤] [📎2] [💬3]       │ <- Assignee, attachments, comments
└─────────────────────────┘
```

Анімації:
- Drag start: scale 1.05 + shadow увеличивается
- Drag over column: column підсвічується
- Drop: smooth transition до нової позиції
- Card hover: elevation + show quick actions (edit, delete)

**2. List View:**
```
Table layout:
┌──┬────────────────┬────────┬──────────┬─────┬──────┐
│☐ │ Title          │ Status │ Priority │ Due │ ⋮    │
├──┼────────────────┼────────┼──────────┼─────┼──────┤
│☐ │ Fix bug #123   │ 🔄     │ 🔴 High  │ Today│ ⋮   │
│☑ │ Update docs    │ ✅     │ 🟡 Med   │ 12/5│ ⋮    │
└──┴────────────────┴────────┴──────────┴─────┴──────┘
```

Features:
- Inline editing при клікі на поле
- Multi-select з checkbox для bulk operations
- Grouping by: status, priority, project, assignee, date
- Sorting: всі поля повинні бути sortable
- Keyboard navigation (arrow keys + Enter для edit)

**3. Calendar View:**
```
Month view з drag&drop:
┌─────────────────────────────────────────┐
│ ◀ December 2024 ▶  [Month][Week][Day]   │
├─────┬─────┬─────┬─────┬─────┬─────┬─────┤
│ Sun │ Mon │ Tue │ Wed │ Thu │ Fri │ Sat │
├─────┼─────┼─────┼─────┼─────┼─────┼─────┤
│     │  1  │  2  │  3  │  4  │  5  │  6  │
│     │ •2  │ •1  │     │ •3  │     │     │
├─────┼─────┼─────┼─────┼─────┼─────┼─────┤
│  7  │  8  │  9  │ ... │     │     │     │
└─────┴─────┴─────┴─────┴─────┴─────┴─────┘
```

Task dots кольори по priority, hover показує preview

**4. Task Detail Modal:**
Sliding panel з правої сторони (width: 600px):
- Breadcrumb navigation зверху
- Editable title (click to edit)
- Rich text editor для description (Markdown)
- Subtasks як checklist
- Attachments з preview для зображень
- Activity timeline знизу
- Smooth slide-in animation

### 2.2 Notes Module

#### Domain Layer
**Note Entity:**
```
Note:
- id: String
- title: String
- content: String (Markdown)
- tags: List<String>
- folderId: String?
- isPinned: bool
- isFavorite: bool
- isArchived: bool
- isEncrypted: bool
- password: String? (encrypted)
- sharedWith: List<String> (user IDs)
- permissions: Map<String, Permission>
- version: int
- lastEditedBy: String
- createdAt: DateTime
- updatedAt: DateTime
- deletedAt: DateTime?
```

#### Presentation Layer

**1. Notes List View:**
```
┌────────────────────────────────────┐
│ 📝 Notes  [+ New] [Search____]     │
├──────┬─────────────────────────────┤
│      │ 📌 Pinned                   │
│ F    │ ┌──────┐ ┌──────┐         │
│ o    │ │Note 1│ │Note 2│         │
│ l    │ └──────┘ └──────┘         │
│ d    │                             │
│ e    │ Recent Notes               │
│ r    │ ┌────────────────────┐     │
│ s    │ │ Note Title         │     │
│      │ │ Preview text...    │     │
│      │ │ 2 hours ago       │     │
│      │ └────────────────────┘     │
└──────┴─────────────────────────────┘
```

**2. Note Editor:**
```
┌─────────────────────────────────────┐
│ [Back] Note Title         [Share][⋮]│
├─────────────────────────────────────┤
│ [B][I][U] [H1][H2][H3] ["][<>][Link]│ <- Toolbar
├─────────────────────────────────────┤
│                                     │
│  # Heading                          │
│  Content with **bold** text        │
│                                     │
│  ```javascript                     │
│  const code = "highlighted";       │
│  ```                                │
│                                     │
│  - [ ] Checkbox item               │
│                                     │
├─────────────────────────────────────┤
│ [Tag1] [Tag2] [+]    Last saved: now│
└─────────────────────────────────────┘
```

Features:
- Live preview toggle
- Syntax highlighting для 20+ мов
- Drag&drop для зображень
- Auto-save кожні 5 секунд
- Version history з diff view
- Export в MD, PDF, HTML

### 2.3 Time Tracking Module

#### Domain Layer
**TimeLog Entity:**
```
TimeLog:
- id: String
- taskId: String?
- projectId: String?
- startTime: DateTime
- endTime: DateTime?
- duration: Duration
- description: String
- tags: List<String>
- billable: bool
- rate: double?
```

#### Presentation Layer

**1. Pomodoro Timer:**
```
┌─────────────────────┐
│    25:00           │ <- Large timer display
│   ╔═══════╗        │
│   ║ ▶️/⏸️  ║        │ <- Play/Pause button
│   ╚═══════╝        │
│                    │
│ ○ ○ ○ ● Session 4  │ <- Session dots
│                    │
│ Current: Task name │
│ [Skip] [Settings]  │
└─────────────────────┘
```

Floating widget опція:
- Always on top
- Draggable
- Semi-transparent
- Minimal mode (тільки timer)

**2. Time Analytics Dashboard:**
```
┌──────────────────────────────────────┐
│ This Week: 32h 15m    ↑ 15% vs last │
├──────────────────────────────────────┤
│         Daily Activity               │
│ ████████████░░░░░ Mon 8h            │
│ ██████████████░░░ Tue 9h            │
│ ████████░░░░░░░░░ Wed 5h            │
├──────────────────────────────────────┤
│     Projects          Time           │
│ ┌──────────────────────────┐        │
│ │ 🟣 Project A      12h    │        │
│ │ 🔵 Project B      8h     │        │
│ │ 🟢 Project C      6h     │        │
│ └──────────────────────────┘        │
└──────────────────────────────────────┘
```

Charts використовувати fl_chart:
- Line chart для тренду
- Pie chart для розподілу по проектах
- Bar chart для денної активності

---

## БЛОК 3: ІНТЕГРАЦІЇ ТА AI

### 3.1 GitHub Integration Module

#### Data Layer
**API Integration:**
Використовувати GitHub REST API v3 через Dio:
- Interceptor для auth token
- Retry logic при 429 (rate limit)
- Cache responses в Hive на 5 хвилин
- Error handling для network issues

#### Presentation Layer

**1. Repository List:**
```
┌─────────────────────────────────────┐
│ My Repositories  [Refresh] [Filter] │
├─────────────────────────────────────┤
│ ┌───────────────────────────────┐  │
│ │ 📁 repo-name         ⭐ 125   │  │
│ │ JavaScript · Updated 2h ago   │  │
│ │ Main branch: 3 ahead          │  │
│ └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

**2. Activity Feed:**
```
┌─────────────────────────────────────┐
│ GitHub Activity                     │
├─────────────────────────────────────┤
│ 🟢 Pushed to main in project-x      │
│    2 hours ago                      │
│                                     │
│ 🔵 Opened PR #23: Fix bug          │
│    5 hours ago                      │
│                                     │
│ 🟣 Merged PR #22                    │
│    Yesterday                        │
└─────────────────────────────────────┘
```

Використати timeline widget з анімаціями

### 3.2 AI Assistant Module

#### Domain Layer
**AI Service Interface:**
```
AIService методи:
- Future<String> reviewCode(String code, String language)
- Future<String> generateDocs(String code)
- Future<String> improveText(String text, TextType type)
- Future<String> explainError(String error, String context)
- Stream<String> chatStream(String message, List<Message> history)
```

#### Data Layer
**Implementation:**
- Mock AI service для тестування (hardcoded responses)
- Response caching в Hive на 1 годину
- Token counting для rate limiting
- Streaming responses через Stream

#### Presentation Layer

**1. AI Chat Interface:**
```
┌─────────────────────────────────────┐
│ AI Assistant             [Clear][⚙️]│
├─────────────────────────────────────┤
│ ┌───────────────────────────────┐  │
│ │ 👤 How to optimize this?      │  │
│ └───────────────────────────────┘  │
│ ┌───────────────────────────────┐  │
│ │ 🤖 Here are suggestions:      │  │
│ │ 1. Use memoization...         │  │
│ │ 2. Implement caching...       │  │
│ └───────────────────────────────┘  │
│                                     │
│ [Type message...          ] [Send] │
└─────────────────────────────────────┘
```

Features:
- Typing animation для AI responses
- Code blocks з syntax highlighting
- Copy button для кожної відповіді
- Markdown rendering
- Loading shimmer effect

**2. Code Review Panel:**
Floating panel при виділенні коду:
```
┌──────────────────────┐
│ AI Code Review      │
│ ┌──────────────────┐│
│ │ 💡 Suggestion    ││
│ │ Consider using  ││
│ │ const here...   ││
│ └──────────────────┘│
│ [Apply] [Dismiss]   │
└──────────────────────┘
```

### 3.3 Settings Module

#### Presentation Layer

**Settings Screen:**
```
┌──────────────────────────────────────┐
│ ⚙️ Settings                     [X] │
├────────┬─────────────────────────────┤
│        │ 👤 Profile                  │
│ General│ ┌─────────────────────┐    │
│ Theme  │ │ Change Avatar       │    │
│ Sync   │ │ Name: [_________]   │    │
│ Keys   │ │ Email: user@mail    │    │
│ About  │ └─────────────────────┘    │
│        │                             │
│        │ [Save Changes]              │
└────────┴─────────────────────────────┘
```

Кожна секція має свій набір налаштувань:
- Theme: color picker для accent, toggle для dark mode
- Sync: intervals, conflict resolution
- Keys: API keys з маскуванням
- About: версія, licenses, credits

---

## БЛОК 4: DESKTOP-СПЕЦИФІЧНА ФУНКЦІОНАЛЬНІСТЬ

### 4.1 System Integration

#### Window Management
Використовуючи window_manager:
- Minimum window size: 1024x768
- Remember window position/size
- Custom title bar з native controls
- Frameless window option

#### System Tray
Використовуючи tray_manager:
```
Tray Menu:
- Show/Hide DevHub
- Quick Timer Start/Stop
- New Task
- New Note
- ─────────
- Preferences
- Quit
```

Icon повинен змінюватися:
- Normal: стандартна іконка
- Timer active: анімована іконка
- Has notifications: червона точка

#### Keyboard Shortcuts
Global shortcuts через hotkey_manager:
```
Ctrl/Cmd + N: New Task
Ctrl/Cmd + Shift + N: New Note
Ctrl/Cmd + Space: Quick Search
Ctrl/Cmd + T: Toggle Timer
Ctrl/Cmd + K: Command Palette
Ctrl/Cmd + ,: Settings
```

### 4.2 Command Palette

Spotlight-style command palette:
```
┌──────────────────────────────┐
│ 🔍 Type a command...         │
├──────────────────────────────┤
│ > New Task                   │
│ > New Note                   │
│ > Search: [query]           │
│ > Go to: Tasks              │
│ > Toggle Theme              │
│ > Start Timer               │
└──────────────────────────────┘
```

Features:
- Fuzzy search
- Recent commands
- Keyboard navigation
- Live preview при hover
- Smooth fade in/out

---

## БЛОК 5: СИНХРОНІЗАЦІЯ ТА ОФЛАЙН РОБОТА

### 5.1 Офлайн стратегія

#### Queue System
Створити OfflineQueue в Hive:
```
OfflineOperation:
- id: String
- type: OperationType (CREATE, UPDATE, DELETE)
- entity: String (task, note, etc)
- data: Map<String, dynamic>
- timestamp: DateTime
- retryCount: int
- error: String?
```

#### Sync Process
1. При старті: перевірити offline queue
2. Кожні 30 секунд: спробувати синхронізувати
3. При network change: immediate sync
4. Manual sync button в UI

#### Conflict Resolution
При конфлікті показати діалог:
```
┌────────────────────────────┐
│ ⚠️ Sync Conflict           │
├────────────────────────────┤
│ Task "Fix bug" був змінений│
│ на іншому пристрої         │
│                            │
│ Your version  | Server     │
│ Modified: 2h  | 1h ago     │
│                            │
│ [Keep Mine] [Keep Server]  │
│ [Merge Changes]            │
└────────────────────────────┘
```

### 5.2 Data Backup

#### Auto Backup
- Щоденний backup в JSON
- Зберігати останні 7 backups
- Location: app_data/backups/

#### Manual Export/Import
Export dialog:
```
┌────────────────────────────┐
│ 📥 Export Data             │
├────────────────────────────┤
│ Select data to export:    │
│ ☑ Tasks (245)             │
│ ☑ Notes (89)              │
│ ☑ Time logs (1,234)       │
│ ☐ Settings                │
│                            │
│ Format: [JSON ▼]          │
│                            │
│ [Export] [Cancel]         │
└────────────────────────────┘
```

---

## ТЕХНІЧНІ ВИМОГИ ДО РЕАЛІЗАЦІЇ

### Performance Requirements
- App startup: < 2 секунди
- Page navigation: < 100ms
- Search results: < 500ms
- Animations: stable 60 FPS
- Memory usage: < 500MB
- Database operations: < 50ms

### Code Quality Standards
- Використовувати const constructors скрізь де можливо
- Dispose controllers та subscriptions
- Lazy loading для великих списків
- Image caching з cached_network_image
- Debounce для search та auto-save
- Error boundaries для crash prevention

### Testing Requirements
- Unit tests для всіх use cases
- Widget tests для critical UI flows
- Integration tests для sync logic
- Golden tests для важливих screens

### Accessibility
- Всі interactive elements мають semantics labels
- Keyboard navigation для всіх функцій
- Screen reader підтримка
- High contrast mode підтримка
- Minimum touch target: 48x48

### Security
- Encrypt sensitive data в local storage
- Sanitize user input для prevent injection
- Validate всі API responses
- Rate limiting для API calls
- Secure storage для tokens/passwords

---

## ФІНАЛЬНІ ІНСТРУКЦІЇ ДЛЯ AI

При реалізації кожного модуля:

1. **Завжди починай з domain layer**: створи entities та repository interfaces
2. **Потім data layer**: імплементуй repositories з mock data
3. **Нарешті presentation**: створи UI з анімаціями

4. **Дотримуйся єдиного стилю**:
   - Всі карточки: borderRadius 12px, elevation 2
   - Всі кнопки: height 48px, borderRadius 24px
   - Spacing: тільки 4, 8, 12, 16, 24, 32px
   - Анімації: 300ms з easeInOutCubic

5. **State management**:
   - Використовуй Riverpod для всього
   - AsyncValue для async операцій
   - StateNotifier для складного стану
   - Сonsumer widgets для UI

6. **Error handling**:
   - Ніколи не кидай exceptions в UI
   - Використовуй Result<T> паттерн
   - Показуй user-friendly error messages
   - Log errors для debugging

7. **Офлайн-first**:
   - Спочатку зберігай локально
   - Потім синхронізуй
   - Показуй sync status в UI
   - Handle network failures gracefully

Цей план забезпечує повну консистентність додатку та детальні інструкції для точної реалізації кожного компонента.