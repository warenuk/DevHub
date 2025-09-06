# DevHub GPT � Block 1 (Auth + Router + Dashboard MVP)

Quick start
- Requirements: Flutter stable, Dart 3.3+, Firebase project configured (web)
- Install deps: `flutter pub get`
- Run (web): `flutter run -d chrome`
  - Firebase �������� �� ������������� (��� `--dart-define`)
- Tests: `flutter test`
- Lints/format: `flutter analyze`, `dart format .`

Architecture
- Feature-first + Clean Architecture: `presentation - domain - data`
- State: Riverpod; Navigation: go_router; Auth: Firebase Auth (web)
- ����������/�������, ����� ������������ ����, ���������� � presentation

Implemented in Block 1
- Auth flow: login/register/sign-out, �������� ����������
- Router: �������� �� auth-������ (splash/auth > dashboard, guest > login)
- Dashboard (MVP): ��� ����������� + Sign out
- Tests: ��� �� �����-�����, ������� � ����������

Firebase
- ������: `lib/firebase_options.dart` (web). ��� ����� �������� � `flutterfire configure`.
- Email/Password �������� � Firebase Console; ������� `localhost` � Authorized domains.

Project map
- ���. ����� `AGENTS.md` � ������ �Project Map�.
