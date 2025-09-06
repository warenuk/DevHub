# Core MVP Plan — Notes + Commits

## Goal
Deliver functional, test-covered core screens and navigation without external APIs: Notes (CRUD, in-memory) and Commits (mock read-only).

## Scope
- Notes: entity, repository (in-memory), use cases, provider/controller, UI pages (list + add/edit/delete), tests.
- Commits: entity, mock repository, provider, UI list, tests.
- Routing: add `/notes`, `/commits`; dashboard quick links.
- Quality: `flutter analyze` clean, tests green.

## Steps
1) Notes Feature
- Entities/Contracts: `Note`, `NotesRepository`.
- Use cases: list/create/update/delete.
- Data: `InMemoryNotesRepository`.
- Presentation: `NotesController` (StateNotifier), `NotesPage` with list + add/edit/delete dialogs.

2) Commits Feature
- Entities/Contracts: `Commit`, `CommitsRepository`.
- Data: `MockCommitsRepository`.
- Presentation: `CommitsPage` list.

3) Integration
- Router: add routes; dashboard buttons.
- Tests: unit (notes), widget (notes add, pages render), dashboard buttons render, commits render.

## Out of scope
- External APIs, offline persistence, assistant features, settings tabs.

