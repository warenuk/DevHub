import 'package:devhub_gpt/core/utils/validators.dart';
import 'package:devhub_gpt/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
                  icon:
                      Icon(_obscure ? Icons.visibility : Icons.visibility_off),
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
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign in'),
              ),
            ),
            const SizedBox(height: 8),
            state.when(
              data: (_) => const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (e, _) => Text(
                e.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/auth/register'),
              child: const Text('New here? Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
