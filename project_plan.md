# План реалізації: Дашборд + Нотатки (Core, Clean Architecture)

Дата: 2025-09-06
Статус: Очікує схвалення

## Мета
Зробити повноцінний дашборд і функціонал нотаток (Notes) відповідно до архітектурних вимог: Clean Architecture, feature-first, Riverpod для стану, маршрути GoRouter, покриття тестами. Дашборд має відображати шорткати та превʼю даних (якщо екран/дані готові), або акуратні заглушки (якщо ще не реалізовано).

## Обсяг роботи (Scope)
- Дашборд: каркас, секції, навігація у всі основні розділи, превʼю останніх нотаток, останніх комітів (mock), станів empty/loading/error, адаптивний layout.
- Нотатки (Notes): повний цикл CRUD (локально, in-memory на цьому етапі), чисті сутності, репозиторій, use cases, контролери (Riverpod), UI (лист/форма), маршрути, тести.
- Інтеграція: додати/уточнити маршрути, кнопки з дашборда, узгодити редіректи.
- Якість: `flutter analyze` без попереджень, `flutter test` зелено, структура файлів іменована та розкладена згідно вимог.

Невходить (Non-goals на цей етап)
- Зовнішні API (GitHub/AI) — відкладено до стабілізації основи.
- Кеш Hive/Drift — відкладено (залишаємо in-memory для швидкої ітерації та чистих тестів).
- Вкладки Settings окрім Keys — відкладено.

## Архітектура та структура
- Feature-first:
  - `lib/features/notes/{domain,data,presentation}`
  - `lib/features/dashboard/presentation/pages/dashboard_page.dart`
  - `lib/core/router/router_provider.dart` — маршрути/редіректи
- Clean Architecture шарування для Notes:
  - Domain: `entities/note.dart`, `repositories/notes_repository.dart`, `usecases/{list,create,update,delete}_note_usecase.dart`.
  - Data: `InMemoryNotesRepository` (пізніше можна підмінити на Hive/Drift, інтерфейс не змінюється).
  - Presentation: `NotesController` (StateNotifier + AsyncValue<List<Note>>), провайдери, UI сторінки (List + Dialog/Edit).
- State: Riverpod 2.x (Provider/StateNotifierProvider/FutureProvider де доречно).
- Навігація: GoRouter, ShellRoute для захищеної частини, іменовані шляхи.

## Дашборд — вимоги до UI/UX
- Секції:
  - Quick actions: Sign out (вже є), додати кнопки шорткатів до розділів: Notes, Commits (mock), GitHub Repos, Assistant, Settings.
  - Preview блоки:
    - Notes: останні 3 нотатки (з `NotesController`), стан empty/loading/error з відповідними повідомленнями.
    - Commits: останні 3 коміти (mock), аналогічні стани.
  - Адаптивність: Wrap/Grid для кнопок, картки з відступами 16 px, Material 3 стилі (використати Theme), доступність (семантика, контрасти).
- Навігація:
  - Кнопки: `/notes`, `/commits`, `/github/repos`, `/assistant`, `/settings`.
  - Back/Up: повернення через GoRouter, без зациклення редіректів (редіректи вже налаштовані).
- Плейсхолдери (fallback): якщо функціонал ще не реалізований — показувати card з текстом “Coming soon” та неактивними кнопками.

## Notes — вимоги до реалізації
- Domain:
  - Entity `Note { id, title, content, createdAt, updatedAt }` (immutable, copyWith).
  - Repo контракт `NotesRepository` з методами: `listNotes, createNote, updateNote, deleteNote`.
  - Use Cases: окремі класи для кожної операції (SRP), без UI-залежностей.
- Data:
  - `InMemoryNotesRepository` як перший крок (список у памʼяті, генерація id, оновлення updatedAt, детерміновані відповіді).
  - Легка заміна на Hive/Drift без змін у Presentation.
- Presentation:
  - `NotesController` (StateNotifier<AsyncValue<List<Note>>>) із методами: `add(title, content)`, `update(note)`, `remove(id)` і приватним `_refresh()`.
  - Провайдери: `notesRepositoryProvider`, `notesControllerProvider`.
  - UI:
    - `NotesPage`: AppBar, FAB “+”, список нотаток (ListView.separated), empty state, dialog для створення/редагування (дві TextField + Save/Cancel), видалення по кнопці корзини.
  - Валідація: title не порожній, trimming, обмеження довжини (UI рівень).

## Маршрути та інтеграція
- Додати/перевірити маршрути:
  - `/notes` → `NotesPage`.
  - `/commits` → `CommitsPage` (mock preview).
  - Вже додані: `/github/repos`, `/assistant`, `/settings`.
- З дашборда:
  - Buttons: `btnNotes`, `btnCommits`, `btnGithubRepos`, `btnAssistant`, `btnSettings` (ValueKey для тестів).
  - Preview-секції: заголовки + вміст (Notes, Commits) з відповідними провайдерами.

## Тестування (обовʼязково)
- Unit (Notes):
  - Репозиторій in-memory: створення/оновлення/видалення/список (перевірка updatedAt, порядку).
  - Use cases: коректна делегація на репозиторій, валідація.
- Widget:
  - NotesPage: рендер порожнього стану, додавання нотатки через діалог, редагування, видалення.
  - Dashboard: наявність шорткатів, рендер превʼю нотаток/комітів, переходи на `/notes`, `/commits`.
  - Repos→Activity (коли підвʼяжемо): tap елемента списку запускає навігацію.
- Routing:
  - Перевірка, що нові маршрути доступні в ShellRoute та не ламають редіректи auth.

## Definition of Done
- Весь описаний вище функціонал реалізований згідно архітектури.
- Всі нові файли мають коректні імпорти, іменування, стиль.
- `flutter analyze` — без попереджень; `flutter test` — зелено; ручний “клік‑тест” основних шляхів.
- Дашборд: відображає шорткати та превʼю двох блоків (Notes, Commits) з коректними станами.

## Ризики та обмеження
- In-memory дані зникають між сесіями — це прийнятно на етапі Core; пізніше замінимо на Hive/Drift.
- Веб: модальні діалоги для редагування — ок, але за потреби можна замінити на окремий маршрут/bottom sheet.

## План робіт (деталізація)
1. Дашборд
   - [ ] Вирівняти секції: Quick actions, Block shortcuts, Notes preview, Commits preview
   - [ ] Стани preview: loading/empty/error (шаблонні віджети)
   - [ ] Адаптивний Wrap/Grid для кнопок
   - [ ] Ключі для тестів (ValueKey)
2. Notes (Domain/Data)
   - [ ] Створити `Note` entity, `NotesRepository`, use cases (list/create/update/delete)
   - [ ] Реалізувати `InMemoryNotesRepository` (id, updatedAt, порядок)
   - [ ] Unit‑тести domain/data
3. Notes (Presentation/UI)
   - [ ] Провайдери: repo/controller
   - [ ] `NotesPage` (+ діалоги add/edit), delete
   - [ ] Widget‑тести: порожній стан, add, edit, delete
4. Інтеграція навігації
   - [ ] Додати/перевірити маршрути `/notes`, `/commits`
   - [ ] Кнопки на дашборді ведуть на відповідні екрани
   - [ ] (Після) Repos→Activity tap + тест
5. Якість
   - [ ] `dart format .`, `flutter analyze`, `flutter test`
   - [ ] Оновити README/плани при потребі

## Таймлайн
- День 1: Notes Domain/Data + тести; Dashboard секції/шорткати (без превʼю)
- День 2: Notes UI + тести; Dashboard превʼю Notes/Commits; навігація Repos→Activity + тест
- День 3: Поліровка, документація, стабілізація тестів

Після схвалення починаю реалізацію за цим планом, без відхилень від архітектури та з повним покриттям тестами.

