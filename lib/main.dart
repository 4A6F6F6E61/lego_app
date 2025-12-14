import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/material.dart';
import 'package:lego_app/navigation_page.dart';
import 'package:yaru/yaru.dart';

Future<void> main() async {
  await YaruWindowTitleBar.ensureInitialized();

  WidgetsFlutterBinding.ensureInitialized();
  SemanticsBinding.instance.ensureSemantics();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    YaruVariant defaultVariant = YaruVariant.adwaitaRed;
    if (!kIsWeb && Platform.isLinux) {
      return YaruTheme(
        builder: (context, yaru, child) => _App(
          themeMode: .system,
          lightTheme: defaultVariant.theme,
          darkTheme: defaultVariant.darkTheme,
          highContrastTheme: yaruHighContrastLight,
          highContrastDarkTheme: yaruHighContrastDark,
        ),
      );
    }

    return _App(
      themeMode: .system,
      lightTheme: defaultVariant.theme,
      darkTheme: defaultVariant.darkTheme,
      highContrastTheme: yaruHighContrastLight,
      highContrastDarkTheme: yaruHighContrastDark,
    );
  }
}

class _App extends StatelessWidget {
  const _App({
    required this.themeMode,
    required this.lightTheme,
    required this.darkTheme,
    required this.highContrastTheme,
    required this.highContrastDarkTheme,
  });

  final ThemeData? lightTheme;
  final ThemeData? darkTheme;
  final ThemeData? highContrastTheme;
  final ThemeData? highContrastDarkTheme;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yaru',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      themeMode: themeMode,
      darkTheme: darkTheme,
      highContrastTheme: highContrastDarkTheme,
      highContrastDarkTheme: highContrastDarkTheme,
      home: NavigationPage(),
    );
  }
}
