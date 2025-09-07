import 'package:devhub_gpt/features/github/presentation/providers/github_auth_notifier.dart';
import 'package:devhub_gpt/features/github/presentation/providers/github_providers.dart';
import 'package:devhub_gpt/shared/providers/secure_storage_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _githubCtrl = TextEditingController();
  final _aiCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _githubCtrl.dispose();
    _aiCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final storage = ref.read(secureStorageProvider);
    _githubCtrl.text = (await storage.read(key: 'github_token')) ?? '';
    _aiCtrl.text = (await storage.read(key: 'ai_key')) ?? '';
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: 'github_token', value: _githubCtrl.text.trim());
    await storage.write(key: 'ai_key', value: _aiCtrl.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Saved')));
  }

  Future<void> _deleteGithubToken() async {
    setState(() => _loading = true);
    final storage = ref.read(secureStorageProvider);
    await storage.delete(key: 'github_token');
    _githubCtrl.text = '';
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('GitHub token removed')));
  }

  @override
  void initState() {
    super.initState();
    // ignore: discarded_futures
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final githubAuthState = ref.watch(githubAuthNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
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
                const SizedBox(height: 12),
                _GithubSignInBlock(state: githubAuthState),
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
        leading: CircularProgressIndicator(),
        title: Text('Requesting device code...'),
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
        leading: CircularProgressIndicator(),
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
            onPressed: () =>
                ref.read(githubAuthNotifierProvider.notifier).start(),
            child: const Text('Try again'),
          ),
        ],
      );
    }

    // Default action: on Web use Firebase popup; on others use device flow
    return ElevatedButton.icon(
      onPressed: () {
        final notifier = ref.read(githubAuthNotifierProvider.notifier);
        if (kIsWeb) {
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
