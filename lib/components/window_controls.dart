import 'package:flutter/material.dart';
import 'package:nativeapi/nativeapi.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

class WindowControls extends StatelessWidget {
  const WindowControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        M3EIconButton(
          variant: M3EIconButtonVariant.standard,
          icon: const Icon(Icons.minimize_rounded, size: 18),
          onPressed: () => WindowManager.instance.getCurrent()?.minimize(),
        ),
        M3EIconButton(
          variant: M3EIconButtonVariant.standard,
          icon: const Icon(Icons.crop_square_rounded, size: 18),
          onPressed: () {
            final win = WindowManager.instance.getCurrent();
            if (win == null) return;
            if (win.isMaximized) {
              win.unmaximize();
            } else {
              win.maximize();
            }
          },
        ),
        M3EIconButton(
          variant: M3EIconButtonVariant.standard,
          icon: const Icon(Icons.close_rounded, size: 18),
          onPressed: () => Application.instance.quit(0),
        ),
      ],
    );
  }
}
