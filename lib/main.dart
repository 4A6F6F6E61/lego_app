import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lego_app/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yaru/yaru.dart';

Future<void> main() async {
  if (!Platform.isAndroid && !Platform.isIOS) {
    await YaruWindowTitleBar.ensureInitialized();
  }

  WidgetsFlutterBinding.ensureInitialized();
  SemanticsBinding.instance.ensureSemantics();

  await Supabase.initialize(
    url: 'https://ugeaobcrrhwqmvlpwmpw.supabase.co',
    anonKey: 'sb_publishable_XYC10qjxJD7ryTFMVUBLUQ_rr6_gPkd',
  );

  runApp(const ProviderScope(child: App()));

  if (!Platform.isAndroid && !Platform.isIOS) {
    doWhenWindowReady(() {
      appWindow.minSize = Size(150, 100);
      appWindow.size = Size(1280, 720);
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    YaruVariant defaultVariant = YaruVariant.adwaitaRed;
    var darkTheme = defaultVariant.darkTheme;
    if (!kIsWeb && Platform.isLinux) {
      return YaruTheme(
        builder: (context, yaru, child) => _App(
          themeMode: .system,
          lightTheme: defaultVariant.theme,
          darkTheme: darkTheme,
          highContrastTheme: yaruHighContrastLight,
          highContrastDarkTheme: yaruHighContrastDark,
        ),
      );
    }
    const black = Color(0x00000000);

    if (Platform.isAndroid || Platform.isIOS) {
      darkTheme = darkTheme.copyWith(
        scaffoldBackgroundColor: black,
        appBarTheme: AppBarThemeData(backgroundColor: black),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: black,
        ),
      );
    }

    return _App(
      themeMode: .system,
      lightTheme: defaultVariant.theme,
      darkTheme: darkTheme,
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
    return MaterialApp.router(
      title: 'Lego App',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      themeMode: themeMode,
      darkTheme: darkTheme,
      highContrastTheme: highContrastDarkTheme,
      highContrastDarkTheme: highContrastDarkTheme,
      routerConfig: router,
      builder: (context, child) {
        // Add fake safe area padding on desktop platforms and web
        final existingMediaQuery = MediaQuery.of(context);
        if (kIsWeb) {
          return MediaQuery(
            data: existingMediaQuery.copyWith(
              viewPadding: existingMediaQuery.viewPadding.copyWith(
                bottom: 24.0,
              ),
              padding: existingMediaQuery.padding.copyWith(bottom: 24.0),
              textScaleFactor: 0.85,
            ),
            child: child ?? const SizedBox(),
          );
        }
        if (defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.fuchsia) {
          return MediaQuery(
            data: existingMediaQuery.copyWith(
              viewPadding: existingMediaQuery.viewPadding.copyWith(
                bottom: 34.0,
              ),
            ),
            child: child ?? const SizedBox(),
          );
        }
        return child ?? const SizedBox();
      },
    );
  }
}
