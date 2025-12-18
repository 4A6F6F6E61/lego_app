import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:lego_app/util.dart';
import 'package:yaru/yaru.dart';

class LoginModal extends HookWidget {
  const LoginModal({super.key, required this.login});
  final Future<dynamic> Function(String, String) login;

  @override
  Widget build(BuildContext context) {
    final username = useTextEditingController();
    final password = useTextEditingController();
    return AlertDialog(
      actions: [
        OutlinedButton(
          onPressed: () async {
            try {
              final res = await login(username.text, password.text);
              if (context.mounted) {
                context.pop(res);
              }
            } catch (e) {
              if (context.mounted) {
                showSnack(context, 'Login failed: $e');
              }
            }
          },
          child: Text('Login', style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
      ],
      titlePadding: EdgeInsets.zero,
      title: YaruDialogTitleBar(
        leading: const Center(
          child: SizedBox.square(
            dimension: 25,
            child: YaruCircularProgressIndicator(strokeWidth: 3),
          ),
        ),
        title: const Text('Rebrickable Login'),
        isClosable: true,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: username,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          SizedBox(height: 18),
          TextField(
            controller: password,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
        ],
      ),
    );
  }
}
