import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lego_app/api.dart';
import 'package:lego_app/providers/settings.dart';
import 'package:lego_app/tabs/settings/login_modal.dart';
import 'package:lego_app/util.dart';
import 'package:yaru/yaru.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  final double _width = 200.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userTokenAsync = ref.watch(userTokenProvider);
    final rebrickableAPIKey = ref.watch(rebrickableApiKeyProvider);

    final apiKeyTextController = useTextEditingController();

    useEffect(() {
      apiKeyTextController.text = rebrickableAPIKey.value ?? '';
      return null;
    }, [rebrickableAPIKey]);

    const contentWidth = 700.0;
    final tiles = [
      YaruTile(
        title: const Text('Rebrickable Synchronization'),
        subtitle: const Text('Login and Synchronize your collection with Rebrickable'),
        trailing: userTokenAsync.when(
          data: (token) => token == null
              ? ElevatedButton(
                  onPressed: () async {
                    final token = await showDialog<String>(
                      context: context,
                      builder: (_) {
                        return LoginModal(
                          login: (String username, String password) async {
                            if (username.isEmpty || password.isEmpty) {
                              throw 'Please enter both username and password';
                            }

                            return await userApi.tokenCreate(
                              apiKey: rebrickableAPIKey.value ?? '',
                              username: username,
                              password: password,
                            );
                          },
                        );
                      },
                    );
                    if (token != null) {
                      await ref.read(userTokenProvider.notifier).set(token);
                    }
                  },
                  child: const Text('Authenticate'),
                )
              : YaruSplitButton(
                  menuWidth: _width,
                  onPressed: () {
                    // Sync action
                  },
                  items: [
                    PopupMenuItem(
                      child: const Text('Clear Token'),
                      onTap: () async {
                        await ref.read(userTokenProvider.notifier).clear();
                      },
                    ),
                  ],
                  child: const Text('Sync'),
                ),
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => const Icon(Icons.error),
        ),
      ),
      YaruTile(
        title: const Text('Rebrickable API Key'),
        subtitle: const Text('Your Rebrickable API Key for accessing the API'),
        trailing: Expanded(
          child: TextFormField(
            controller: apiKeyTextController,
            decoration: const InputDecoration(hintText: 'Enter your Rebrickable API Key'),
            obscureText: true,
            onFieldSubmitted: (value) async {
              await ref.read(rebrickableApiKeyProvider.notifier).set(value);
            },
          ),
        ),
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: YaruBorderContainer(
                width: contentWidth,
                margin: const EdgeInsets.all(kYaruPagePadding),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: tiles.length,
                  itemBuilder: (context, index) =>
                      Padding(padding: const EdgeInsets.all(5.0), child: tiles.elementAt(index)),
                  separatorBuilder: (context, index) =>
                      index != tiles.length - 1 ? const Divider() : const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

class SplitButtonPage extends StatefulWidget {
  const SplitButtonPage({super.key});

  @override
  State<SplitButtonPage> createState() => _SplitButtonPageState();
}

class _SplitButtonPageState extends State<SplitButtonPage> {
  double _width = 200.0;

  @override
  Widget build(BuildContext context) {
    const contentWidth = 500.0;
    const spacing = 16.0;
    final items = List.generate(10, (index) {
      final text =
          '${index.isEven ? 'Super long action name' : 'action'} ${index + 1}';
      return PopupMenuItem(
        child: Text(text, overflow: TextOverflow.ellipsis),
        onTap: () => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(text))),
      );
    });

    final tiles = [
      YaruTile(
        title: const Text('YaruSplitButton()'),
        subtitle: const Text('Regular version'),
        trailing: YaruSplitButton(
          menuWidth: _width,
          onPressed: () => ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Main Action'))),
          items: items,
          child: const Text('Main Action'),
        ),
      ),
      YaruTile(
        title: const Text('YaruSplitButton'),
        subtitle: const Text('.filled()'),
        trailing: YaruSplitButton.filled(
          menuWidth: _width,
          onPressed: () => ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Main Action'))),
          items: items,
          child: const Text('Main Action'),
        ),
      ),
      YaruTile(
        title: const Text('YaruSplitButton'),
        subtitle: const Text('outlined()'),
        trailing: YaruSplitButton.outlined(
          menuWidth: _width,
          onPressed: () => ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Main Action'))),
          items: items,
          child: const Text('Main Action'),
        ),
      ),
      YaruTile(
        title: const Text('YaruSplitButton'),
        subtitle: const Text('items: null, onOptionPressed: null'),
        trailing: YaruSplitButton(
          menuWidth: _width,
          child: const Text('Main Action'),
          onPressed: () => ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Main Action'))),
        ),
      ),
      YaruTile(
        title: const Text('YaruSplitButton'),
        subtitle: const Text('onPressed: null'),
        trailing: YaruSplitButton(
          menuWidth: _width,
          items: items,
          child: const Text('Main Action'),
        ),
      ),
      YaruTile(
        title: const Text('YaruSplitButton'),
        subtitle: const Text(
          'items: null, onOptionPressed: null, onPressed: null',
        ),
        trailing: YaruSplitButton(
          menuWidth: _width,
          child: const Text('Main Action'),
        ),
      ),
    ];

    final rows = [
      Row(
        children: [
          const Text('Normal alignment'),
          const SizedBox(width: spacing),
          YaruSplitButton.outlined(
            onPressed: () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Main Action'))),
            items: items.sublist(0, 3),
            child: const Text('Main Action'),
          ),
        ],
      ),
      Row(
        children: [
          const Text('Normal alignment with width'),
          const SizedBox(width: spacing),
          YaruSplitButton.outlined(
            menuWidth: _width,
            onPressed: () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Main Action'))),
            items: items.sublist(0, 3),
            child: const Text('Main Action'),
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Space between alignment'),
          const SizedBox(width: spacing),
          YaruSplitButton.outlined(
            onPressed: () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Main Action'))),
            items: items.sublist(0, 3),
            child: const Text('Main Action'),
          ),
          const Text('Trailing'),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Center alignment'),
          const SizedBox(width: spacing),
          YaruSplitButton.outlined(
            onPressed: () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Main Action'))),
            items: items.sublist(0, 3),
            child: const Text('Main Action'),
          ),
        ],
      ),
    ];

    final row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Menu width: ${_width.toInt()}'),
        Expanded(
          child: Slider(
            min: 100,
            max: 500,
            value: _width,
            onChanged: (v) => setState(() => _width = v),
          ),
        ),
      ],
    );

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: contentWidth, child: row),
          const SizedBox(height: spacing),
          const Text('Yaru Tiles'),
          Flexible(
            child: YaruBorderContainer(
              width: contentWidth,
              margin: const EdgeInsets.all(kYaruPagePadding),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: tiles.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: tiles.elementAt(index),
                ),
                separatorBuilder: (context, index) => index != tiles.length - 1
                    ? const Divider()
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          const SizedBox(height: spacing),
          const Text('Normal rows'),
          Flexible(
            child: YaruBorderContainer(
              width: contentWidth,
              margin: const EdgeInsets.all(kYaruPagePadding),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: rows.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: rows.elementAt(index),
                ),
                separatorBuilder: (context, index) => index != rows.length - 1
                    ? const Divider()
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/
