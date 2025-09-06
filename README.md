# DevHub GPT — Block 1 (Auth + Router + Dashboard MVP)

Quick start
- Requirements: Flutter stable, Dart 3.3+, Firebase project configured (web)
- Install deps: `flutter pub get`
- Run (web): `flutter run -d chrome`
  - Firebase увімкнено за замовчуванням (без `--dart-define`)
- Tests: `flutter test`
- Lints/format: `flutter analyze`, `dart format .`

Architecture
- Feature-first + Clean Architecture: `presentation - domain - data`
- State: Riverpod; Navigation: go_router; Auth: Firebase Auth (web)
- Репозиторій/юзкейси, чітке розмежування шарів, провайдери у presentation

Implemented in Block 1
- Auth flow: login/register/sign-out, поточний користувач
- Router: редіректи за auth-станом (splash/auth > dashboard, guest > login)
- Dashboard (MVP): дані користувача + Sign out
- Tests: юніт та віджет-тести, включно з редіректами

Firebase
- Конфіг: `lib/firebase_options.dart` (web). Для інших платформ — `flutterfire configure`.
- Email/Password увімкнено у Firebase Console; додайте `localhost` у Authorized domains.

Project map
- Див. кінець `AGENTS.md` — секція “Project Map”.
