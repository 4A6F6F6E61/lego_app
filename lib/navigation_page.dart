import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yaru/yaru.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key, required this.navShell});

  final StatefulNavigationShell navShell;

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class Tab {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  Tab({required this.icon, required this.selectedIcon, required this.label});
}

class _NavigationPageState extends State<NavigationPage> {
  final _tabs = <Tab>[
    Tab(icon: YaruIcons.home, selectedIcon: YaruIcons.home_filled, label: 'Home'),
    Tab(icon: YaruIcons.settings, selectedIcon: YaruIcons.settings_filled, label: 'Settings'),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: kIsWeb ? null : YaruWindowTitleBar(title: const Text('Lego App')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return Row(
              children: [
                NavigationRail(
                  destinations: [
                    for (final tab in _tabs)
                      NavigationRailDestination(
                        icon: Icon(tab.icon),
                        selectedIcon: Icon(
                          tab.selectedIcon,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        label: Text(tab.label),
                      ),
                  ],
                  selectedIndex: widget.navShell.currentIndex,
                  onDestinationSelected: (index) => widget.navShell.goBranch(index),
                  minExtendedWidth: 180,
                  extended: true,
                ),
                const VerticalDivider(width: 0.0),
                Expanded(child: widget.navShell),
              ],
            );
          } else {
            return Column(
              children: [
                Expanded(child: widget.navShell),
                const Divider(height: 0.0),
                NavigationBar(
                  destinations: [
                    for (final tab in _tabs)
                      NavigationDestination(
                        icon: Icon(tab.icon),
                        selectedIcon: Icon(
                          tab.selectedIcon,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        label: tab.label,
                      ),
                  ],
                  selectedIndex: widget.navShell.currentIndex,
                  onDestinationSelected: (index) => widget.navShell.goBranch(index),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
