import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lego_app/providers/settings.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userTokenAsync = ref.watch(userTokenProvider);

    return userTokenAsync.when(
      data: (userToken) {
        if (userToken == null) {
          return const Center(child: Text('Not authenticated'));
        }
        return Center(
          child: ElevatedButton(onPressed: () async {}, child: const Text('Press Me')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
