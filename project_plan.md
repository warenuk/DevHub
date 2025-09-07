# ���� ���������: ������������ ���������� �� ����������
## ���� ���������: 2025-09-06
## ������: � �����

## ���������� ����������
### ������������ �����:
- lib/main.dart � MaterialApp.router, ��� Firebase (����� `kUseFirebase`), Riverpod `ProviderScope`.
- lib/core/router/router_provider.dart � GoRouter, ShellRoute, �������� �� auth-������, refresh ����� `ChangeNotifier` + `ref.listen`.
- lib/core/theme/app_theme.dart � Material 3 ����, card/appBar/button/text ������������.
- lib/core/{constants,errors,utils} � `api_constants.dart`, `app_strings.dart`, `app_colors.dart`; `failures.dart`, `exceptions.dart`; `validators.dart`, `formatters.dart`.
- lib/shared/providers � `dio_provider.dart`, `secure_storage_provider.dart`.
- features/auth � Clean Architecture: domain (entities, repositories, usecases), data (remote/local datasources, repo impl), presentation (providers, pages, widgets).
- features/notes � ������ ������� Clean Architecture (in-memory ����������, use cases, StateNotifier controller, �������).
- features/{dashboard,assistant,github,commits,settings,shell} � �������������� ��� � �������� ���������.
- test/ � unit � widget �����: use cases, repository, router redirects/deeplinks, pages (login, notes, dashboard ����).
- pubspec.yaml � ��������� (Riverpod, GoRouter, Dio, Freezed, JSON Serializable, Drift/Hive, Firebase).

### ������� ���������:
- `auth_providers.dart` �������� `kUseFirebase` (toggle ����������) �� ����� ���������� (Firebase/Mock + SecureStorage).
- `router_provider.dart` �������� �� `authStateProvider` � �������� ����������.
- `dashboard_page.dart` ���� `currentUserProvider` �� ���� ���������.
- `notes` ������ �� in-memory ����������; �� ������� �����/��.

### ������:
- ³����� ������������� ��������� ����/������� (����� ������).
- ���� ��������� �������� ������ ���������� ��� ��������� (���������� �����).

## ��������� ���� ���������

### ���� 1: ϳ�������� [~10 ��]
- [x] 1.1 ���������� ������������� (���������, ����, ���������)
- [x] 1.2 ��������� `flutter analyze` � ����� ��������
- [x] 1.3 �������� ����� ���������� (���������, ���� M3 ������������)

### ���� 2: Core ������������� [~15 ��]
- [x] 2.1 ������ `AppLogger` (������������� ���������) � `lib/core/utils/app_logger.dart`
- [x] 2.2 ����������� ��������� � `AuthRepositoryImpl` ��� ������� �������
- [x] 2.3 ��������� `CardThemeData` -> `CardTheme` � ��� (M3)

### ���� 3: �������� �� �������� [~10 ��]
- [x] 3.1 ��������� �������� ��� ��� ������ (guest/auth) �� e2e ��������
- [x] 3.2 �������� �������� splash/error (�� ������� ������ ������ error page)

### ���� 4: ����������� ��� [~20 ��]
- [x] 4.1 ��������� DI ���������� (consistency: `Provider`, `StateNotifierProvider`)
- [ ] 4.2 ����������� ������ �� ������� ���������� ������������ ������� ����������
- [ ] 4.3 ����������� ��������� ���������� (���������, ������� -> Failures)

### ���� 5: ����� [~15 ��]
- [ ] 5.1 ������ ������ ����� ��� ��������� (smoke, ����������)
- [x] 5.2 �����������/��������� router redirect/deeplink �����
- [x] 5.3 ��������� ������ ���� �����

### ���� 6: Գ������ �������� [~10 ��]
- [x] 6.1 flutter analyze
- [x] 6.2 dart format .
- [x] 6.3 flutter test
- [x] 6.4 ������� ���� ���������

## ������� ��� ������
���� ���������� �� ������ ����� ������� ����.

## Notes � Persistence & Dashboard Integration (2025-09-06)
- [x] ��������������: Hive DS + Repo (CRUD, ����������)
- [x] DI: override InMemory > Hive � main.dart
- [x] �������: ������ Notes ������ ������� � 3 ���������; tap > /notes
- [x] Use cases: �������� title (create/update)
- [x] ���������: try/catch, AsyncValue.error �� ��������
- [x] �����: unit ��� HiveRepo, widget ��� ����� Notes
- [x] �����/������������/������ ����� �����
