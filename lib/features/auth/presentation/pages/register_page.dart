import 'package:devhub_gpt/features/auth/presentation/providers/auth_providers.dart';
import 'package:devhub_gpt/shared/widgets/app_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () {
                        ref
                            .read(authControllerProvider.notifier)
                            .signUp(
                              _emailController.text,
                              _passwordController.text,
                              _nameController.text,
                            );
                      },
                child: state.isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: AppProgressIndicator(strokeWidth: 2, size: 20),
                      )
                    : const Text('Create account'),
              ),
            ),
            const SizedBox(height: 8),
            state.when(
              data: (_) => const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (e, _) =>
                  Text(e.toString(), style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
