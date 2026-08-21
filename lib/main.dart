import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lego_app/router.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
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
      appWindow.minSize = const Size(360, 480);
      appWindow.size = const Size(1280, 760);
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }
}

class App extends StatelessWidget {
  const App({super.key});

  static const seedColor = Color(0xFF0266C8); // Expressive Lego Cobalt Blue

  @override
  Widget build(BuildContext context) {
    final darkM3ETheme = M3EThemeData.dark(seedColor: seedColor);
    final lightM3ETheme = M3EThemeData.light(seedColor: seedColor);

    final darkMaterialTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: seedColor,
      scaffoldBackgroundColor: const Color(0xFF13151A),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      appBarTheme: const AppBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
    );

    final lightMaterialTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: seedColor,
      scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      appBarTheme: const AppBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
    );

    return MaterialApp.router(
      title: 'Lego Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: lightMaterialTheme,
      darkTheme: darkMaterialTheme,
      routerConfig: router,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final currentM3ETheme = isDark ? darkM3ETheme : lightM3ETheme;

        final existingMediaQuery = MediaQuery.of(context);
        Widget responsiveChild = child ?? const SizedBox();

        if (kIsWeb) {
          responsiveChild = MediaQuery(
            data: existingMediaQuery.copyWith(
              viewPadding: existingMediaQuery.viewPadding.copyWith(bottom: 24.0),
              padding: existingMediaQuery.padding.copyWith(bottom: 24.0),
              textScaler: const TextScaler.linear(0.9),
            ),
            child: responsiveChild,
          );
        } else if (defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.fuchsia) {
          responsiveChild = MediaQuery(
            data: existingMediaQuery.copyWith(
              viewPadding: existingMediaQuery.viewPadding.copyWith(bottom: 24.0),
            ),
            child: responsiveChild,
          );
        }

        return M3ETheme(
          data: currentM3ETheme,
          child: responsiveChild,
        );
      },
    );
  }
}
