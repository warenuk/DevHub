# Sync Deep Plan (repos, commits, activity, notes)

> Версія: 2025-09-17

## 0. Цілі
- Drift-схема з **повним покриттям індексами** для `repos`, `commits`, `activity`, `notes`.
- **Міграції** зі збереженням даних + **тести міграцій** (in-memory).
- **ETag/If-None-Match** для HTTP-клієнтів (GitHub API), **обробка 304**.
- **Конфлікти** для двостороннього sync (LWW/merge).
- **Backpressure**: ліміт частоти, черги, джиттер.

## 1. Поточний стан (аудит)
- Є таблиці: `Repos(id, fullName, name, description, stargazersCount, forksCount, updatedAt, fetchedAt, tokenScope[PK part])`, `Commits(repoFullName, sha, ..., tokenScope UNIQUE)`, `Activity(...)`, `Notes(id PK, title, content, createdAt, updatedAt)`.
- `schemaVersion = 2`.
- Відсутні окремі індекси на поширені запити (repoFullName+date, fullName, tokenScope тощо).

## 2. Цільова схема (після міграцій)
### 2.1 Repos
- PK: (id, token_scope).
- Індекси: 
  - `idx_repos_token_scope` ON token_scope
  - `idx_repos_full_name` ON full_name
  - `idx_repos_updated_at` ON updated_at
- Колонки для кешу: `etag` TEXT NULL, `fetched_at` DATETIME NOT NULL.

### 2.2 Commits
- UNIQUE(repo_full_name, sha, token_scope) — вже є.
- Індекси: 
  - `idx_commits_repo_full_name` ON repo_full_name
  - `idx_commits_repo_date` ON (repo_full_name, date)
  - `idx_commits_token_scope` ON token_scope
- Кеш: `etag` на рівні *repo* (у таблиці `Repos`) + `fetched_at` на записах.

### 2.3 Activity
- Індекси: 
  - `idx_activity_repo_full_name` 
  - `idx_activity_date` 
  - `idx_activity_token_scope`
- Кеш: `etag` на фіді активності (на рівні repo або user feed).

### 2.4 Notes (двосторонній sync)
- PK: id.
- Поля: `updatedAt` — джерело істини для LWW.
- Індекси: 
  - `idx_notes_updated_at` ON updated_at
  - (опц.) `idx_notes_title`

### 2.5 ETags (опція)
- Окрема таблиця `Etags(resource_key TEXT PRIMARY KEY, etag TEXT, last_fetched DATETIME NOT NULL)`.
- `resource_key` приклади: `repos:<tokenScope>`, `commits:<fullName>:<tokenScope>`, `activity:<fullName>:<tokenScope>`.

## 3. Міграції
- Підвищити `schemaVersion` → **3**.
- `onUpgrade`: 
  1) Створити індекси (як вище).
  2) Додати колонки `etag`/`fetched_at` (де потрібно) або створити таблицю `Etags`.
  3) Заповнити `fetched_at` для існуючих рядків значенням `now()`.
- **Тести**: інстанціювати БД версії 2 → прогнати upgrade → перевірити існування індексів/колонок, цілісність даних, унікальні ключі.

## 4. HTTP кешування (ETag/304)
- У `github_repository_impl`/`github_client_provider`: 
  - При GET: якщо є `etag` у Drift → встановити `If-None-Match`.
  - Відповідь 200: зчитати `ETag`, оновити `Etags/Repos.etag`, перезаписати дані.
  - Відповідь **304**: не змінювати дані, лише оновити `last_fetched`.
- Локальний `fetched_at` у рядках використовується для TTL/aging політик.

## 5. Конфлікти (двосторонній sync для Notes)
- **Політика:** LWW за `updatedAt` (UTC).
- Якщо одночасні правки: 
  - Якщо різні вузли → перемагає більший `updatedAt`.
  - Якщо різниця < threshold (наприклад, 2s) і відмінності по тілу — зберегти **conflict copy**: `note_id` + `-conflict-<uuid>`, задокументувати у журналі.
  - (Опція) Спробувати 3-way merge по `content`.
- Логи конфліктів у таблиці `notes_conflicts` (id, baseId, localUpdatedAt, remoteUpdatedAt, resolvedAt, strategy).

## 6. Backpressure та черги
- **SyncQueue**: 
  - Кільцева черга/пріоритети (repos > commits > activity > notes).
  - Rate limit (per host/path), експонентний backoff, **джиттер**.
  - Сумісність з існуючим `retry_interceptor`.
- Метрики: середній час очікування, відсоток 304, кількість відкинутих запитів.
- Тести: штучні 429/secondary rate limit/timeout сценарії.

## 7. Тестування
- **Міграції:** in-memory Drift, prepopulated v2 → upgrade → asserts.
- **ETag:** мок відповіді 200 з `ETag` → повторний GET очікує 304.
- **Конфлікти:** сценарії одночасних правок та автоматичне розв'язання/копія.
- **Backpressure:** моделювання пульсаційного навантаження, перевірка порядку та лімітів.

## 8. Розклад етапів (мапа до plan.yaml)
- S1.1 — цей документ.
- S2.1 — індекси. S2.2 — ETag-колонки/таблиця.
- S3.1 — onUpgrade + schemaVersion=3. S3.2 — тести міграцій.
- S4.1 — клієнт ETag/304. S4.2 — інтеграційні тести ETag.
- S5.1 — LWW/merge. S5.2 — тести конфліктів.
- S6.1 — SyncQueue. S6.2 — тести backpressure.

## 9. Критерії приймання
- Всі індекси створені, schemaVersion=3, тести міграцій зелені.
- ETag працює: 2-й запит повертає 304 і не перезаписує БД.
- Конфлікти у Notes розв'язуються LWW або формують conflict copy.
- Backpressure гарантує відсутність перевищення лімітів і стабільний час відгуку.
