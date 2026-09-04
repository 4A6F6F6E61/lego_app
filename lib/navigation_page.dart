
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

class NavigationPage extends ConsumerStatefulWidget {
  const NavigationPage({super.key, required this.navShell});

  final StatefulNavigationShell navShell;

  @override
  ConsumerState<NavigationPage> createState() => _NavigationPageState();
}

class _NavDestinationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavDestinationItem({required this.icon, required this.selectedIcon, required this.label});
}

class _NavigationPageState extends ConsumerState<NavigationPage> {
  static const _destinations = <_NavDestinationItem>[
    _NavDestinationItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    _NavDestinationItem(
      icon: Icons.view_in_ar_outlined,
      selectedIcon: Icons.view_in_ar_rounded,
      label: 'Sets',
    ),
    _NavDestinationItem(
      icon: Icons.tune_outlined,
      selectedIcon: Icons.tune_rounded,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navShell.currentIndex;
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;

          if (isWide) {
            return Row(
              children: [
                M3ENavigationRail(
                  selectedIndex: currentIndex,
                  onDestinationSelected: (index) => widget.navShell.goBranch(index),
                  sections: [
                    M3ENavigationRailSection(
                      destinations: [
                        for (final item in _destinations)
                          M3ENavigationRailDestination(
                            icon: Icon(item.icon),
                            selectedIcon: Icon(item.selectedIcon),
                            label: item.label,
                          ),
                      ],
                    ),
                  ],
                ),
                Expanded(child: widget.navShell),
              ],
            );
          }

          return Column(
            children: [
              Expanded(child: widget.navShell),
              M3ENavigationBar(
                selectedIndex: currentIndex,
                onDestinationSelected: (index) => widget.navShell.goBranch(index),
                destinations: [
                  for (final item in _destinations)
                    M3ENavigationBarDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon),
                      label: item.label,
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
