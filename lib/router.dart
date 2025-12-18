import 'package:go_router/go_router.dart';
import 'package:lego_app/auth_notifier.dart';
import 'package:lego_app/auth_page.dart';
import 'package:lego_app/navigation_page.dart';
import 'package:lego_app/tabs/home_page.dart';
import 'package:lego_app/tabs/settings/settings_page.dart';

final router = GoRouter(
  initialLocation: '/auth',
  refreshListenable: authNotifier,
  redirect: (context, state) {
    final isLoggedIn = authNotifier.isLoggedIn;
    final isAuthRoute = state.uri.path == '/auth';

    if (!isLoggedIn && !isAuthRoute) {
      return '/auth';
    }
    if (isLoggedIn && isAuthRoute) {
      return '/home';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: "/auth",
      builder: (_, _) {
        return const AuthPage();
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
