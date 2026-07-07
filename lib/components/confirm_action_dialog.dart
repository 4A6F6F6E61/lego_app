import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

class ConfirmActionDialog extends StatelessWidget {
  const ConfirmActionDialog({super.key, required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: .zero,
      title: YaruDialogTitleBar(
        leading: const Center(
          child: SizedBox.square(
            dimension: 25,
            child: YaruCircularProgressIndicator(strokeWidth: 3),
          ),
        ),
        title: Text(title),
        isClosable: false,
      ),
      content: Text(content),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
