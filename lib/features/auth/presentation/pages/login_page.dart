import 'package:devhub_gpt/core/router/app_routes.dart';
import 'package:devhub_gpt/core/utils/validators.dart';
import 'package:devhub_gpt/features/auth/presentation/providers/auth_providers.dart';
import 'package:devhub_gpt/features/github/presentation/providers/github_auth_notifier.dart';
import 'package:devhub_gpt/features/github/presentation/providers/github_providers.dart';
import 'package:devhub_gpt/shared/widgets/app_progress_indicator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _touched = false;

  bool get _isEmailValid => Validators.isValidEmail(_emailController.text);
  bool get _isPasswordValid => _passwordController.text.trim().length >= 6;
  bool get _formValid => _isEmailValid && _isPasswordValid;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    void markTouchedAndUpdate() {
      if (!_touched) _touched = true;
      if (mounted) setState(() {});
    }

    _emailController.addListener(markTouchedAndUpdate);
    _passwordController.addListener(markTouchedAndUpdate);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final rememberSession = ref.watch(githubRememberSessionProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText:
                    _touched && !_isEmailValid ? 'Enter a valid email' : null,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
                errorText:
                    _touched && !_isPasswordValid ? 'Min length is 6' : null,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.isLoading || !_formValid
                    ? null
                    : () {
                        ref.read(authControllerProvider.notifier).signIn(
                              _emailController.text.trim(),
                              _passwordController.text,
                            );
                      },
                child: state.isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: const AppProgressIndicator(
                          strokeWidth: 2,
                          size: 20,
                        ),
                      )
                    : const Text('Sign in'),
              ),
            ),
            const SizedBox(height: 8),
            state.when(
              data: (_) => const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (e, _) =>
                  Text(e.toString(), style: const TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => const RegisterRoute().go(context),
              child: const Text('New here? Create Account'),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            if (kIsWeb)
              CheckboxListTile(
                value: rememberSession,
                onChanged: (value) => ref
                    .read(githubRememberSessionProvider.notifier)
                    .state = value ?? false,
                title: const Text('Пам’ятати GitHub сеанс (7 днів)'),
                subtitle: const Text(
                  'Без відмітки токен буде збережений лише на годину.',
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Continue with GitHub'),
                onPressed: () {
                  final notifier =
                      ref.read(githubAuthNotifierProvider.notifier);
                  if (kIsWeb) {
                    notifier.signInWeb(
                      rememberSession: rememberSession,
                    );
                  } else {
                    notifier.start();
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            _GithubAuthStateView(state: githubState),
          ],
        ),
      ),
    );
  }
}

class _GithubAuthStateView extends ConsumerWidget {
  const _GithubAuthStateView({required this.state});

  final GithubAuthState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state is GithubAuthRequestingCode) {
      return const ListTile(
        contentPadding: EdgeInsets.zero,
        leading: AppProgressIndicator(size: 20),
        title: Text('Requesting device code...'),
      );
    }

    if (state is GithubAuthPolling) {
      return const ListTile(
        contentPadding: EdgeInsets.zero,
        leading: AppProgressIndicator(size: 20),
        title: Text('Waiting for authorization...'),
      );
    }

    if (state is GithubAuthCodeReady) {
      final s = state as GithubAuthCodeReady;
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Authorize DevHub in your browser',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SelectableText('User code: ${s.userCode}'),
              const SizedBox(height: 8),
              SelectableText('Open: ${s.verificationUri}'),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => ref
                        .read(githubAuthNotifierProvider.notifier)
                        .pollOnce(),
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
          ),
        ),
      );
    }

    if (state is GithubAuthError) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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

    if (state is GithubAuthAuthorized) {
      return const ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.verified, color: Colors.green),
        title: Text('GitHub account connected'),
      );
    }

    return const SizedBox.shrink();
  }
}
