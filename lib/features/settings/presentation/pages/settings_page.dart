import 'package:devhub_gpt/features/auth/presentation/providers/auth_providers.dart';
import 'package:devhub_gpt/features/github/presentation/providers/github_auth_notifier.dart';
import 'package:devhub_gpt/features/github/presentation/providers/github_providers.dart';
import 'package:devhub_gpt/shared/providers/github_client_provider.dart';
import 'package:devhub_gpt/shared/providers/secure_storage_provider.dart';
import 'package:devhub_gpt/shared/widgets/app_progress_indicator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:devhub_gpt/features/auth/presentation/providers/auth_providers.dart';
import 'package:devhub_gpt/features/github/presentation/providers/github_auth_notifier.dart';
import 'package:devhub_gpt/features/github/presentation/providers/github_providers.dart';
import 'package:devhub_gpt/shared/network/token_store.dart';
import 'package:devhub_gpt/shared/providers/github_client_provider.dart';
import 'package:devhub_gpt/shared/providers/secure_storage_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _githubCtrl = TextEditingController();
  final _aiCtrl = TextEditingController();
  bool _loading = false;
  DateTime? _githubExpiry;

  @override
  void dispose() {
    _githubCtrl.dispose();
    _aiCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final store = ref.read(tokenStoreProvider);
    final payload = await store.readPayload();
    _githubCtrl.text = payload?.token ?? '';
    _githubExpiry = payload?.expiresAt;
    ref.read(githubRememberSessionProvider.notifier).state =
        payload?.rememberMe ?? false;

    final storage = ref.read(secureStorageProvider);
    _aiCtrl.text = (await storage.read(key: 'ai_key')) ?? '';
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final store = ref.read(tokenStoreProvider);
    final remember = ref.read(githubRememberSessionProvider);
    final trimmedToken = _githubCtrl.text.trim();
    if (trimmedToken.isEmpty) {
      await store.clear();
      _githubExpiry = null;
    } else {
      await store.write(trimmedToken, rememberMe: remember);
      final refreshed = await store.readPayload();
      _githubExpiry = refreshed?.expiresAt;
    }

    final storage = ref.read(secureStorageProvider);
    await storage.write(key: 'ai_key', value: _aiCtrl.text.trim());
    if (!mounted) return;
    // Invalidate token-dependent providers so UI refreshes without app reload
    ref.invalidate(githubTokenProvider);
    ref.invalidate(githubAuthHeaderProvider);
    ref.invalidate(reposProvider);
    // Bump session version to refresh watching providers
    ref.read(githubSessionVersionProvider.notifier).state++;
    setState(() => _loading = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved')));
  }

  Future<void> _deleteGithubToken() async {
    setState(() => _loading = true);
    final store = ref.read(tokenStoreProvider);
    await store.clear();
    ref.read(githubRememberSessionProvider.notifier).state = false;
    _githubCtrl.text = '';
    _githubExpiry = null;
    if (!mounted) return;
    // Invalidate token-dependent providers so UI refreshes without app reload
    ref.invalidate(githubTokenProvider);
    ref.invalidate(githubAuthHeaderProvider);
    ref.invalidate(reposProvider);
    // Bump session version to refresh watching providers
    ref.read(githubSessionVersionProvider.notifier).state++;
    setState(() => _loading = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('GitHub token removed')));
  }

  @override
  void initState() {
    super.initState();
    // ignore: discarded_futures
    _load();
    // Раніше слухали стан GitHub-автентифікації та форсили інвалідацію,
    // але тепер усі залежні провайдери напряму слухають токен —
    // додаткові listen тут не потрібні (і не заважатимуть побудові).
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays >= 1) {
      return '${duration.inDays} дн.';
    }
    if (duration.inHours >= 1) {
      return '${duration.inHours} год.';
    }
    return '${duration.inMinutes} хв.';
  }

  @override
  Widget build(BuildContext context) {
    final githubAuthState = ref.watch(githubAuthNotifierProvider);
    final appAuth = ref.watch(authControllerProvider);
    final remember = ref.watch(githubRememberSessionProvider);
    final tokenStore = ref.watch(tokenStoreProvider);
    final ttlPreview = tokenStore.defaultTtl(rememberMe: remember);
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final expiryFormat = DateFormat.yMMMd(localeTag).add_Hm();
    final expiryText = _githubExpiry != null
        ? 'Поточний токен діє до ${expiryFormat.format(_githubExpiry!)}'
        : 'Сеанс GitHub ще не збережено.';
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: AppProgressIndicator(size: 32))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Keys',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _githubCtrl,
                  decoration: const InputDecoration(labelText: 'GitHub Token'),
                ),
                const SizedBox(height: 8),
                Text(expiryText, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _deleteGithubToken,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete GitHub Token'),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _aiCtrl,
                  decoration: const InputDecoration(labelText: 'AI Key'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save Changes'),
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'GitHub Sign-In',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SwitchListTile.adaptive(
                  value: remember,
                  title: const Text('Памʼятати GitHub сеанс'),
                  subtitle: Text(
                    'Термін зберігання ~${_formatDuration(ttlPreview)}. '
                    'Перезапишіть токен або увійдіть знову, щоб застосувати.',
                  ),
                  onChanged: (value) {
                    ref.read(githubRememberSessionProvider.notifier).state =
                        value;
                    setState(() {});
                  },
                ),
                const SizedBox(height: 12),
                _GithubSignInBlock(state: githubAuthState),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'App Account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (appAuth.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: const AppProgressIndicator(
                            strokeWidth: 2,
                            size: 20,
                          ),
                        ),
                      ),
                    ElevatedButton.icon(
                      onPressed: () =>
                          ref.read(authControllerProvider.notifier).signOut(),
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign out'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _GithubSignInBlock extends ConsumerWidget {
  const _GithubSignInBlock({required this.state});
  final GithubAuthState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rememberSession = ref.watch(githubRememberSessionProvider);
    if (state is GithubAuthAuthorized) {
      return Row(
        children: [
          const Icon(Icons.verified, color: Colors.green),
          const SizedBox(width: 8),
          const Expanded(child: Text('Signed in to GitHub')),
          TextButton(
            onPressed: () =>
                ref.read(githubAuthNotifierProvider.notifier).signOut(),
            child: const Text('Sign out'),
          ),
        ],
      );
    }

    if (state is GithubAuthRequestingCode) {
      return const ListTile(
        leading: const AppProgressIndicator(size: 20),
        title: Text('Requesting device code...'),
      );
    }

    if (state is GithubAuthRedirecting) {
      return const ListTile(
        leading: AppProgressIndicator(size: 20),
        title: Text('Відкриваємо GitHub у новій вкладці...'),
        subtitle:
            Text('Якщо вікно не зʼявилось, дозвольте pop-up для цього сайту.'),
      );
    }

    if (state is GithubAuthCodeReady) {
      final s = state as GithubAuthCodeReady;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User code: ${s.userCode}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text('Open: ${s.verificationUri}'),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: () =>
                    ref.read(githubAuthNotifierProvider.notifier).pollOnce(),
                child: const Text('I authorized, continue'),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () =>
                    ref.read(githubAuthNotifierProvider.notifier).start(),
                child: const Text('Generate new code'),
              ),
            ],
          ),
        ],
      );
    }

    if (state is GithubAuthPolling) {
      return const ListTile(
        leading: const AppProgressIndicator(size: 20),
        title: Text('Waiting for authorization...'),
      );
    }

    if (state is GithubAuthError) {
      return Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(child: Text((state as GithubAuthError).message)),
          TextButton(
            onPressed: () {
              final notifier = ref.read(githubAuthNotifierProvider.notifier);
              if (kIsWeb) {
                notifier.signInWeb(rememberSession: rememberSession);
              } else {
                notifier.start();
              }
            },
            child: const Text('Try again'),
          ),
        ],
      );
    }

    // Default action: on Web use Firebase popup; on others use device flow
    return ElevatedButton.icon(
      onPressed: () {
        final notifier = ref.read(githubAuthNotifierProvider.notifier);
        if (kIsWeb && kUseFirebase) {
          notifier.signInWeb();
        } else {
          notifier.start();
        }
      },
      icon: const Icon(Icons.login),
      label: const Text('Sign in with GitHub'),
    );
  }
}
