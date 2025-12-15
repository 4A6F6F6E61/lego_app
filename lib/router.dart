import 'package:go_router/go_router.dart';
import 'package:lego_app/auth_page.dart';
import 'package:lego_app/navigation_page.dart';
import 'package:lego_app/settings.dart';
import 'package:lego_app/tabs/home_page.dart';
import 'package:lego_app/tabs/settings_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: "/",
      redirect: (_, state) async {
        if (Settings.userToken == null) {
          return "/auth";
        }
        if (state.fullPath == '/') {
          return '/home';
        }
        return null;
      },
    ),
    GoRoute(
      path: "/auth",
      builder: (_, _) {
        return AuthPage();
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (_, _, navigationShell) {
        return NavigationPage(navShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/home",
              builder: (_, _) {
                // Return your home page here
                return HomePage();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/settings",
              builder: (_, _) {
                // Return your settings page here
                return SettingsPage();
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
