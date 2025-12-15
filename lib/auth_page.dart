import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:lego_app/api.dart';
import 'package:lego_app/settings.dart';
import 'package:lego_app/util.dart';
import 'package:yaru/widgets.dart';

class AuthPage extends HookWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final username = useTextEditingController();
    final password = useTextEditingController();
    Future<void> login() async {
      if (username.text.isEmpty || password.text.isEmpty) {
        showSnack(context, 'Please enter both username and password');
        return;
      }
      try {
        final token = await userApi.tokenCreate(username.text, password.text);
        await Settings.setUserToken(token);
        if (context.mounted) {
          context.go('/home');
        }
      } catch (e) {
        if (context.mounted) {
          showSnack(context, 'Login failed: $e');
        }
        return;
      }
    }

    return Scaffold(
      appBar: YaruWindowTitleBar(title: const Text('Authentication')),
      body: Center(
        child: SimpleDialog(
          title: const Text('Rebrickable Login'),
          contentPadding: .all(24),
          constraints: const BoxConstraints(minWidth: 500),
          children: [
            TextField(
              controller: username,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: password,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: login, child: const Text('Login')),
          ],
        ),
      ),
    );
  }
}
