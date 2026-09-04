import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lego_app/router.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SemanticsBinding.instance.ensureSemantics();

  await Supabase.initialize(
    url: 'https://ugeaobcrrhwqmvlpwmpw.supabase.co',
    publishableKey: 'sb_publishable_XYC10qjxJD7ryTFMVUBLUQ_rr6_gPkd',
    postgrestOptions: const PostgrestClientOptions(schema: 'lego_app'),
  );

  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    await windowManager.ensureInitialized();
    await windowManager.setMinimumSize(const Size(360, 480));
    await windowManager.setSize(const Size(1280, 760));
    await windowManager.center();
    await windowManager.show();
  }

  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  static const seedColor = Color(0xFF0266C8); // Expressive Lego Cobalt Blue

  @override
  Widget build(BuildContext context) {
    final darkM3EThemeBase = M3EThemeData.dark(seedColor: seedColor);
    final darkM3ETheme = darkM3EThemeBase.copyWith(
      navigationRailTheme: darkM3EThemeBase.navigationRailTheme.copyWith(
        containerColor: Colors.transparent,
      ),
    );

    final lightM3EThemeBase = M3EThemeData.light(seedColor: seedColor);
    final lightM3ETheme = lightM3EThemeBase.copyWith(
      navigationRailTheme: lightM3EThemeBase.navigationRailTheme.copyWith(
        containerColor: Colors.transparent,
      ),
    );

    final baseDarkColor = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );
    final darkColorScheme = baseDarkColor.copyWith(
      surface: const Color(0xFF16181D),
      surfaceContainerHighest: const Color(0xFF21252D),
      surfaceContainerHigh: const Color(0xFF1D2027),
      surfaceContainer: const Color(0xFF1A1C22),
      surfaceContainerLow: const Color(0xFF17191E),
      surfaceContainerLowest: const Color(0xFF13151A),
    );

    final darkMaterialTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: darkColorScheme,
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
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1C22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: seedColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
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
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: seedColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
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
              viewPadding: existingMediaQuery.viewPadding.copyWith(
                bottom: 24.0,
              ),
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
              viewPadding: existingMediaQuery.viewPadding.copyWith(
                bottom: 24.0,
              ),
            ),
            child: responsiveChild,
          );
        }

        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          behavior: HitTestBehavior.translucent,
          child: M3ETheme(data: currentM3ETheme, child: responsiveChild),
        );
      },
    );
  }
}
