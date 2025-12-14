import 'package:flutter/material.dart';
import 'package:lego_app/tabs/home.dart';
import 'package:lego_app/tabs/settings.dart';
import 'package:yaru/yaru.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final _items = <Widget, (IconData, IconData, String)>{
    const Home(): (YaruIcons.home, YaruIcons.home_filled, 'Home'),
    const Settings(): (YaruIcons.settings, YaruIcons.settings_filled, 'Settings'),
  };
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: YaruWindowTitleBar(title: const Text('Yaru Example')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return Row(
              children: [
                NavigationRail(
                  destinations: [
                    for (final item in _items.entries)
                      NavigationRailDestination(
                        icon: Icon(item.value.$1),
                        selectedIcon: Icon(
                          item.value.$2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        label: Text(item.value.$3),
                      ),
                  ],
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                  extended: true,
                ),
                const VerticalDivider(width: 0.0),
                Expanded(child: Center(child: _items.entries.elementAt(_selectedIndex).key)),
              ],
            );
          } else {
            return Column(
              children: [
                Expanded(child: Center(child: _items.entries.elementAt(_selectedIndex).key)),
                const Divider(height: 0.0),
                NavigationBar(
                  destinations: [
                    for (final item in _items.entries)
                      NavigationDestination(
                        icon: Icon(item.value.$1),
                        selectedIcon: Icon(
                          item.value.$2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        label: item.value.$3,
                      ),
                  ],
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
