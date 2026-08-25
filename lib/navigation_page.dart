import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_3_expressive/components/navigation_bar/models/m3e_navigation_bar_destination.dart';
import 'package:material_3_expressive/components/navigation_rail/models/m3e_navigation_rail_destination.dart';
import 'package:material_3_expressive/components/navigation_rail/models/m3e_navigation_rail_section.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

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

  const _NavDestinationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentIndex = widget.navShell.currentIndex;

    final buttonColors = WindowButtonColors(
      iconNormal: colorScheme.onSurface,
      mouseOver: colorScheme.onSurface.withValues(alpha: 0.1),
      mouseDown: colorScheme.onSurface.withValues(alpha: 0.2),
      iconMouseOver: colorScheme.onSurface,
      iconMouseDown: colorScheme.onSurface,
    );

    final closeButtonColors = WindowButtonColors(
      iconNormal: colorScheme.onSurface,
      mouseOver: const Color(0xFFD32F2F),
      mouseDown: const Color(0xFFB71C1C),
      iconMouseOver: Colors.white,
      iconMouseDown: Colors.white,
    );

    final windowTitleBar = !kIsWeb && !Platform.isAndroid && !Platform.isIOS
        ? PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: MoveWindow(
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                toolbarHeight: 40,
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.extension_rounded, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'LEGO',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Tracker',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                actions: [
                  MinimizeWindowButton(colors: buttonColors),
                  MaximizeWindowButton(colors: buttonColors),
                  CloseWindowButton(colors: closeButtonColors),
                ],
              ),
            ),
          )
        : null;

    return Scaffold(
      appBar: windowTitleBar,
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
