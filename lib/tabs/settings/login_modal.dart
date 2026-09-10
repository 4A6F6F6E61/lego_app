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

    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: M3ECard(
          variant: M3ECardVariant.elevated,
          borderRadius: BorderRadius.circular(24),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rebrickable Login',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  M3EIconButton(
                    variant: M3EIconButtonVariant.tonal,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Sign in to your Rebrickable account to synchronize your LEGO collection and sets.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: username,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                  filled: true,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: password,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                  filled: true,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  M3EButton.text(
                    onPressed: () => context.pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
