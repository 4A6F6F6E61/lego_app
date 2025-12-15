import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:lego_app/api/services/users_api.dart';
import 'package:lego_app/settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          final response = await userApi.getSetCollection();
          dev.log('Set Collection Count: ${response.count}');
        },
        child: const Text('Press Me'),
      ),
    );
  }
}
