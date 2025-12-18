import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lego_app/util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yaru/widgets.dart';

class AuthPage extends ConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _AuthPageContent(ref: ref);
  }
}

class _AuthPageContent extends HookWidget {
  const _AuthPageContent({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final flowLogin = useState(true);
    final username = useTextEditingController();
    final password = useTextEditingController();
    final isLoading = useState(false);

    Future<void> login() async {
      if (username.text.isEmpty || password.text.isEmpty) {
        showSnack(context, 'Please enter both email and password');
        return;
      }
      isLoading.value = true;
      try {
        await Supabase.instance.client.auth.signInWithPassword(
          email: username.text,
          password: password.text,
        );
      } on AuthException catch (e) {
        if (context.mounted) showSnack(context, e.message);
      } catch (e) {
        if (context.mounted) showSnack(context, 'Login failed: $e');
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> register() async {
      if (username.text.isEmpty || password.text.isEmpty) {
        showSnack(context, 'Please enter both email and password');
        return;
      }
      isLoading.value = true;
      try {
        await Supabase.instance.client.auth.signUp(email: username.text, password: password.text);
        if (context.mounted)
          showSnack(context, 'Registration successful! Please check your email.');
      } on AuthException catch (e) {
        if (context.mounted) showSnack(context, e.message);
      } catch (e) {
        if (context.mounted) showSnack(context, 'Registration failed: $e');
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: YaruWindowTitleBar(title: const Text('Authentication')),
      body: Center(
        child: SimpleDialog(
          title: Text(flowLogin.value ? 'Login' : 'Register'),
          contentPadding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(minWidth: 500),
          children: [
            TextField(
              controller: username,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: password,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            if (isLoading.value)
              const Center(child: CircularProgressIndicator())
            else ...[
              if (flowLogin.value)
                ElevatedButton(onPressed: login, child: const Text('Login'))
              else
                ElevatedButton(onPressed: register, child: const Text('Register')),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => flowLogin.value = !flowLogin.value,
                child: Text(
                  flowLogin.value ? 'Need an account? Register' : 'Have an account? Login',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
