import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lego_app/util.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends ConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _AuthPageContent();
  }
}

class _AuthPageContent extends HookWidget {
  const _AuthPageContent();

  @override
  Widget build(BuildContext context) {
    final isLogin = useState(true);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final obscurePassword = useState(true);
    final isLoading = useState(false);
    final theme = Theme.of(context);

    Future<void> submit() async {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        showSnack(context, 'Please enter both email and password');
        return;
      }

      isLoading.value = true;
      try {
        if (isLogin.value) {
          await Supabase.instance.client.auth.signInWithPassword(
            email: email,
            password: password,
          );
        } else {
          await Supabase.instance.client.auth.signUp(
            email: email,
            password: password,
          );
          if (context.mounted) {
            showSnack(context, 'Registration successful! Please check your email.');
          }
        }
      } on AuthException catch (e) {
        if (context.mounted) showSnack(context, e.message);
      } catch (e) {
        if (context.mounted) {
          showSnack(context, '${isLogin.value ? "Sign in" : "Registration"} failed: $e');
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: M3ECard(
              variant: M3ECardVariant.filled,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Icon & Title
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0266C8).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.extension_rounded,
                          size: 40,
                          color: Color(0xFF0266C8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'LEGO Tracker',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track sets, count parts, and rebuild your collection',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Auth Switcher
                    M3ESegmentedButton<bool>(
                      segments: const [
                        M3ESegment(
                          value: true,
                          label: 'Sign In',
                          icon: Icon(Icons.login_rounded, size: 16),
                        ),
                        M3ESegment(
                          value: false,
                          label: 'Create Account',
                          icon: Icon(Icons.person_add_outlined, size: 16),
                        ),
                      ],
                      selected: {isLogin.value},
                      onSelectionChanged: (val) {
                        if (val.isNotEmpty) isLogin.value = val.first;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Form Fields
                    M3ETextField(
                      controller: emailController,
                      label: 'Email Address',
                      leading: const Icon(Icons.mail_outline_rounded),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    M3ETextField(
                      controller: passwordController,
                      label: 'Password',
                      obscureText: obscurePassword.value,
                      leading: const Icon(Icons.lock_outline_rounded),
                      trailing: IconButton(
                        icon: Icon(
                          obscurePassword.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 18,
                        ),
                        onPressed: () => obscurePassword.value = !obscurePassword.value,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Action Button
                    SizedBox(
                      height: 48,
                      child: M3EButton.filled(
                        onPressed: isLoading.value ? () {} : submit,
                        child: isLoading.value
                            ? const SizedBox.square(
                                dimension: 20,
                                child: M3EProgressIndicator.circular(),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isLogin.value ? Icons.arrow_forward_rounded : Icons.check_rounded,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isLogin.value ? 'Sign In' : 'Create Account',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
