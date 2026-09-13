import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lego_app/api.dart';
import 'package:lego_app/components/confirm_action_dialog.dart';
import 'package:lego_app/db/db.dart';
import 'package:lego_app/providers/settings.dart';
import 'package:lego_app/tabs/settings/login_modal.dart';
import 'package:lego_app/util.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = useFuture(useMemoized(() => PackageInfo.fromPlatform()));
    final userTokenAsync = ref.watch(userTokenProvider);
    final rebrickableAPIKey = ref.watch(rebrickableApiKeyProvider);
    final bricksetAPIKey = ref.watch(bricksetApiKeyProvider);
    final sortOption = ref.watch(partSortProvider);
    final theme = Theme.of(context);

    final rbApiKeyTC = useTextEditingController();
    final bsApiKeyTC = useTextEditingController();

    final rbObscure = useState(true);
    final bsObscure = useState(true);
    final syncLoading = useState(false);

    useEffect(() {
      rbApiKeyTC.text = rebrickableAPIKey.value ?? '';
      bsApiKeyTC.text = bricksetAPIKey.value ?? '';
      return null;
    }, [rebrickableAPIKey.value, bricksetAPIKey.value]);

    Future<void> signOut() async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => const ConfirmActionDialog(
          title: 'Sign Out',
          content: 'Are you sure you want to sign out of your account?',
          confirmLabel: 'Sign Out',
          isDestructive: true,
        ),
      );

      if (confirm == true) {
        await supabase.auth.signOut();
        if (context.mounted) context.go('/auth');
      }
    }

    Future<void> startRebrickableSync(String token) async {
      final apiKey = await ref.read(rebrickableApiKeyProvider.future);
      if (apiKey == null || apiKey.isEmpty) {
        if (context.mounted) {
          showSnack(context, 'Please enter your Rebrickable API Key first.');
        }
        return;
      }
      syncLoading.value = true;
      if (context.mounted) {
        showSnack(
          context,
          'Synchronization started... this may take a moment to fetch sets and parts.',
        );
      }
      try {
        await syncRebrickable(apiKey: apiKey, userToken: token);
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => M3EDialog(
              title: 'Synchronization Complete',
              content: const Text('Your LEGO collection has been synchronized successfully.'),
              actions: [
                M3EButton.filled(
                  onPressed: () => ctx.pop(),
                  child: const Text('Great!'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          showSnack(context, 'Synchronization failed: $e');
        }
      } finally {
        syncLoading.value = false;
      }
    }

    final currentUser = supabase.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // User Session Card
              if (currentUser != null) ...[
                M3ECard(
                  variant: M3ECardVariant.filled,
                  color: theme.colorScheme.surfaceContainer,
                  border: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          radius: 24,
                          child: Text(
                            (currentUser.email?.isNotEmpty == true)
                                ? currentUser.email![0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentUser.email ?? 'Signed In',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Account Connected',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF10B981),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        M3EButton.outlined(
                          onPressed: signOut,
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Rebrickable Integration Card
              M3ECard(
                variant: M3ECardVariant.filled,
                color: theme.colorScheme.surfaceContainer,
                border: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0266C8).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.sync_rounded, color: Color(0xFF0266C8), size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rebrickable Integration',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Synchronize your sets, parts, and wanted lists',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          userTokenAsync.when(
                            data: (token) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: token != null
                                    ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                    : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                token != null ? 'Connected' : 'Not Linked',
                                style: TextStyle(
                                  color: token != null
                                      ? const Color(0xFF10B981)
                                      : theme.colorScheme.outline,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            loading: () => const SizedBox.shrink(),
                            error: (err, stack) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: rbApiKeyTC,
                        decoration: InputDecoration(
                          labelText: 'Rebrickable API Key',
                          prefixIcon: const Icon(Icons.key_rounded),
                          filled: true,
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  rbObscure.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  size: 18,
                                ),
                                onPressed: () => rbObscure.value = !rbObscure.value,
                              ),
                              IconButton(
                                icon: const Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 20),
                                onPressed: () async {
                                  await ref.read(rebrickableApiKeyProvider.notifier).set(rbApiKeyTC.text.trim());
                                  if (context.mounted) showSnack(context, 'Rebrickable API Key saved');
                                },
                              ),
                            ],
                          ),
                        ),
                        onFieldSubmitted: (val) async {
                          await ref.read(rebrickableApiKeyProvider.notifier).set(val.trim());
                          if (context.mounted) showSnack(context, 'Rebrickable API Key saved');
                        },
                        obscureText: rbObscure.value,
                      ),
                      const SizedBox(height: 16),
                      userTokenAsync.when(
                        data: (token) => token == null
                            ? M3EButton.tonal(
                                onPressed: () async {
                                  final apiKey = (await ref.read(rebrickableApiKeyProvider.future)) ?? '';
                                  if (apiKey.isEmpty) {
                                    if (context.mounted) {
                                      showSnack(context, 'Please enter your Rebrickable API Key first.');
                                    }
                                    return;
                                  }
                                  if (!context.mounted) return;
                                  final newToken = await showDialog<String>(
                                    context: context,
                                    builder: (_) => LoginModal(
                                      login: (String u, String p) async {
                                        return await userApi.tokenCreate(
                                          apiKey: apiKey,
                                          username: u,
                                          password: p,
                                        );
                                      },
                                    ),
                                  );
                                  if (newToken != null) {
                                    await ref.read(userTokenProvider.notifier).set(newToken);
                                  }
                                },
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.login_rounded, size: 16),
                                    SizedBox(width: 8),
                                    Text('Authenticate with Rebrickable'),
                                  ],
                                ),
                              )
                            : Row(
                                children: [
                                  M3EButton.filled(
                                    onPressed: syncLoading.value ? () {} : () => startRebrickableSync(token),
                                    child: syncLoading.value
                                        ? const SizedBox.square(
                                            dimension: 16,
                                            child: M3EProgressIndicator.circular(),
                                          )
                                        : const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.sync_rounded, size: 16),
                                              SizedBox(width: 8),
                                              Text('Sync Now'),
                                            ],
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  M3EButton.text(
                                    onPressed: () async {
                                      await ref.read(userTokenProvider.notifier).clear();
                                      if (context.mounted) showSnack(context, 'Token cleared');
                                    },
                                    child: const Text('Disconnect Account'),
                                  ),
                                ],
                              ),
                        loading: () => const M3EProgressIndicator.circular(),
                        error: (err, stack) => Text('Error: $err'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Brickset Integration Card
              M3ECard(
                variant: M3ECardVariant.filled,
                color: theme.colorScheme.surfaceContainer,
                border: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.menu_book_rounded, color: Color(0xFFF59E0B), size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Brickset Integration',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Required to view PDF building instructions directly in-app',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: bsApiKeyTC,
                        decoration: InputDecoration(
                          labelText: 'Brickset API Key',
                          prefixIcon: const Icon(Icons.vpn_key_outlined),
                          filled: true,
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  bsObscure.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  size: 18,
                                ),
                                onPressed: () => bsObscure.value = !bsObscure.value,
                              ),
                              IconButton(
                                icon: const Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 20),
                                onPressed: () async {
                                  await ref.read(bricksetApiKeyProvider.notifier).set(bsApiKeyTC.text.trim());
                                  if (context.mounted) showSnack(context, 'Brickset API Key saved');
                                },
                              ),
                            ],
                          ),
                        ),
                        onFieldSubmitted: (val) async {
                          await ref.read(bricksetApiKeyProvider.notifier).set(val.trim());
                          if (context.mounted) showSnack(context, 'Brickset API Key saved');
                        },
                        obscureText: bsObscure.value,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Display Preferences Card
              M3ECard(
                variant: M3ECardVariant.filled,
                color: theme.colorScheme.surfaceContainer,
                border: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.tune_rounded, size: 20, color: theme.colorScheme.primary),
                          const SizedBox(width: 10),
                          Text(
                            'Display Preferences',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Default Parts Sorting',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Choose how parts are grouped and ordered in set details',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 12),
                      M3ESegmentedButton<PartSortOption>(
                        segments: const [
                          M3ESegment(
                            value: PartSortOption.color,
                            label: 'Color',
                            icon: Icon(Icons.palette_outlined, size: 16),
                          ),
                          M3ESegment(
                            value: PartSortOption.type,
                            label: 'Type',
                            icon: Icon(Icons.category_outlined, size: 16),
                          ),
                        ],
                        selected: {sortOption},
                        onSelectionChanged: (val) {
                          if (val.isNotEmpty) {
                            ref.read(partSortProvider.notifier).set(val.first);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // About & App Information Card
              M3ECard(
                variant: M3ECardVariant.filled,
                color: theme.colorScheme.surfaceContainer,
                border: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'LEGO',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'LEGO Set & Parts Rebuilder Tracker',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Powered by Material 3 Expressive. LEGO® is a trademark of the LEGO Group of companies which does not sponsor, authorize or endorse this application.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                          fontSize: 11,
                        ),
                      ),
                      if (packageInfo.hasData) ...[
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Version',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            Text(
                              'v${packageInfo.data!.version}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
