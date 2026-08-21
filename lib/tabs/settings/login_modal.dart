import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:lego_app/util.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

class LoginModal extends HookWidget {
  const LoginModal({super.key, required this.login});
  final Future<dynamic> Function(String, String) login;

  @override
  Widget build(BuildContext context) {
    final username = useTextEditingController();
    final password = useTextEditingController();
    final loading = useState(false);

    Future<void> submit() async {
      if (loading.value) return;
      if (username.text.isEmpty || password.text.isEmpty) {
        showSnack(context, 'Please enter username and password');
        return;
      }
      try {
        loading.value = true;
        final res = await login(username.text, password.text);
        if (context.mounted) {
          context.pop(res);
        }
      } catch (e) {
        if (context.mounted) {
          showSnack(context, 'Login failed: $e');
        }
      } finally {
        loading.value = false;
      }
    }

    return M3EDialog(
      title: 'Rebrickable Login',
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sign in to your Rebrickable account to synchronize your LEGO collection and sets.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            M3ETextField(
              controller: username,
              label: 'Username',
              leading: const Icon(Icons.person_outline_rounded),
            ),
            const SizedBox(height: 14),
            M3ETextField(
              controller: password,
              label: 'Password',
              obscureText: true,
              leading: const Icon(Icons.lock_outline_rounded),
            ),
          ],
        ),
      ),
      actions: [
        M3EButton.text(
          onPressed: () => context.pop(),
          child: const Text('Cancel'),
        ),
        M3EButton.filled(
          onPressed: loading.value ? () {} : submit,
          child: loading.value
              ? const SizedBox.square(
                  dimension: 16,
                  child: M3EProgressIndicator.circular(),
                )
              : const Text('Sign In'),
        ),
      ],
    );
  }
}
