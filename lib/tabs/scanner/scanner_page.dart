import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lego_app/api/services/brickognize_api.dart';
import 'package:lego_app/components/image_viewer.dart';
import 'package:lego_app/db/models/lego_set.dart';
import 'package:lego_app/db/models/set_part.dart';
import 'package:lego_app/providers/db_providers.dart';
import 'package:lego_app/providers/rebrickable_providers.dart';
import 'package:lego_app/util.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class ScannerPage extends HookConsumerWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isScanning = useState<bool>(false);
    final errorMessage = useState<String?>(null);
    final imageBytes = useState<Uint8List?>(null);
    final imageName = useState<String?>(null);
    final predictionResult = useState<BrickognizePredictionResult?>(null);
    final selectedCandidateIndex = useState<int>(0);

    final colorsAsync = ref.watch(colorsProvider);

    Future<void> runPrediction(Uint8List bytes, String filename) async {
      isScanning.value = true;
      errorMessage.value = null;
      selectedCandidateIndex.value = 0;

      try {
        final result = await brickognizeApi.predict(
          imageBytes: bytes,
          filename: filename,
          predictColor: true,
          topK: 10,
          minSimilarity: 0.2,
        );
        predictionResult.value = result;
        if (result.items.isEmpty) {
          errorMessage.value =
              'Brickognize could not recognize a LEGO piece in this image. Try taking a photo against a plain, contrasting background.';
        }
      } catch (e) {
        errorMessage.value = 'Failed to identify piece: $e';
      } finally {
        isScanning.value = false;
      }
    }

    Future<void> pickAndScan(ImageSource source) async {
      try {
        final picker = ImagePicker();
        final picked = await picker.pickImage(
          source: source,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85,
        );

        if (picked != null) {
          final bytes = await picked.readAsBytes();
          imageBytes.value = bytes;
          imageName.value = picked.name;
          await runPrediction(bytes, picked.name);
        }
      } catch (e) {
        errorMessage.value = 'Error capturing image: $e';
      }
    }

    final currentItem = (predictionResult.value != null &&
            predictionResult.value!.items.isNotEmpty &&
            selectedCandidateIndex.value < predictionResult.value!.items.length)
        ? predictionResult.value!.items[selectedCandidateIndex.value]
        : null;

    final detectedColor = (predictionResult.value != null &&
            predictionResult.value!.colors.isNotEmpty)
        ? predictionResult.value!.colors.first
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Brickognize Scanner'),
        actions: [
          if (imageBytes.value != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Clear & New Scan',
              onPressed: () {
                imageBytes.value = null;
                imageName.value = null;
                predictionResult.value = null;
                errorMessage.value = null;
                selectedCandidateIndex.value = 0;
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Banner / Intro Card
          M3ECard(
            variant: M3ECardVariant.filled,
            color: theme.colorScheme.surfaceContainer,
            border: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0266C8).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.center_focus_strong_rounded,
                      color: Color(0xFF0266C8),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LEGO Piece Recognition',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Powered by Brickognize AI. Photograph a loose piece to identify it and see which of your sets need it.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Image Input Actions or Preview
          if (imageBytes.value == null) ...[
            M3ECard(
              variant: M3ECardVariant.filled,
              color: theme.colorScheme.surfaceContainer,
              border: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_enhance_outlined,
                        size: 44,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ready to Scan a Brick',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Take a clear photo with the brick centered against a neutral or plain background for highest accuracy.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 22),
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        M3EButton.filled(
                          onPressed: isScanning.value
                              ? null
                              : () => pickAndScan(ImageSource.camera),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.photo_camera_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('Take Photo'),
                            ],
                          ),
                        ),
                        M3EButton.tonal(
                          onPressed: isScanning.value
                              ? null
                              : () => pickAndScan(ImageSource.gallery),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.photo_library_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('Pick Image'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Photo Preview Bar
            M3ECard(
              variant: M3ECardVariant.filled,
              color: theme.colorScheme.surfaceContainer,
              border: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        imageBytes.value!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            imageName.value ?? 'Captured Image',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isScanning.value
                                ? 'Analyzing with Brickognize AI...'
                                : 'Image scanned successfully',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isScanning.value
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline,
                              fontWeight: isScanning.value
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        M3EIconButton(
                          variant: M3EIconButtonVariant.tonal,
                          icon: const Icon(Icons.photo_camera_rounded, size: 18),
                          tooltip: 'Take New Photo',
                          onPressed: isScanning.value
                              ? null
                              : () => pickAndScan(ImageSource.camera),
                        ),
                        M3EIconButton(
                          variant: M3EIconButtonVariant.tonal,
                          icon: const Icon(Icons.photo_library_rounded, size: 18),
                          tooltip: 'Pick New Image',
                          onPressed: isScanning.value
                              ? null
                              : () => pickAndScan(ImageSource.gallery),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),

          // Loading State
          if (isScanning.value) ...[
            M3ECard(
              variant: M3ECardVariant.filled,
              color: theme.colorScheme.surfaceContainer,
              border: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const SizedBox.square(
                      dimension: 36,
                      child: M3EProgressIndicator.circular(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Identifying piece with Brickognize...',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Matching against hundreds of thousands of LEGO parts...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],

          // Error State
          if (errorMessage.value != null) ...[
            M3ECard(
              variant: M3ECardVariant.filled,
              color: Colors.redAccent.withValues(alpha: 0.12),
              border: BorderSide(
                color: Colors.redAccent.withValues(alpha: 0.4),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.redAccent,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scan Notice',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            errorMessage.value!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (imageBytes.value != null && !isScanning.value)
                      M3EButton.text(
                        onPressed: () => runPrediction(
                          imageBytes.value!,
                          imageName.value ?? 'piece.jpg',
                        ),
                        child: const Text('Retry'),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],

          // Result Section
          if (currentItem != null) ...[
            // Candidate Selector Chips (if multiple candidates available)
            if (predictionResult.value!.items.length > 1) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'AI Predictions',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  Text(
                    '${predictionResult.value!.items.length} candidates',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: predictionResult.value!.items.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = predictionResult.value!.items[index];
                    final isSelected = index == selectedCandidateIndex.value;
                    final matchPercent = (item.score * 100).toInt();

                    if (isSelected) {
                      return M3EButton.filled(
                        onPressed: () {
                          selectedCandidateIndex.value = index;
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 16),
                            const SizedBox(width: 6),
                            Text('#${item.id} ${item.name} ($matchPercent%)'),
                          ],
                        ),
                      );
                    } else {
                      return M3EButton.tonal(
                        onPressed: () {
                          selectedCandidateIndex.value = index;
                        },
                        child: Text('#${item.id} ${item.name} ($matchPercent%)'),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Active Candidate Detail Card
            _CandidateDetailCard(
              item: currentItem,
              detectedColor: detectedColor,
            ),
            const SizedBox(height: 24),

            // Sets in DB Matching This Piece
            _MatchingSetsSection(
              partNum: currentItem.id,
              partName: currentItem.name,
              colorsMap: colorsAsync.value ?? {},
            ),
          ],
        ],
      ),
    );
  }
}

class _CandidateDetailCard extends StatelessWidget {
  final BrickognizeItem item;
  final BrickognizeColor? detectedColor;

  const _CandidateDetailCard({
    required this.item,
    this.detectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matchPercent = (item.score * 100).toInt();
    final scoreColor = item.score >= 0.7
        ? const Color(0xFF10B981)
        : item.score >= 0.4
            ? const Color(0xFFF59E0B)
            : const Color(0xFF94A3B8);

    return M3ECard(
      variant: M3ECardVariant.filled,
      color: theme.colorScheme.surfaceContainer,
      border: BorderSide(
        color: scoreColor.withValues(alpha: 0.6),
        width: 1.5,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                Container(
                  width: 90,
                  height: 90,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: item.imgUrl.isNotEmpty
                      ? GestureDetector(
                          onTap: () => openImageViewer(
                            context,
                            imageUrl: item.imgUrl,
                            title: item.name,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: proxiedImageUrl(item.imgUrl),
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: SizedBox.square(
                                dimension: 20,
                                child: M3EProgressIndicator.circular(),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.extension_outlined,
                              color: Colors.grey,
                              size: 32,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.extension_outlined,
                          color: Colors.grey,
                          size: 32,
                        ),
                ),
                const SizedBox(width: 16),

                // Name & Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: scoreColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$matchPercent% match',
                              style: TextStyle(
                                color: scoreColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                          if (item.category != null &&
                              item.category!.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.category!,
                                style: TextStyle(
                                  color: theme.colorScheme.outline,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Part #${item.id}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (detectedColor != null) ...[
              const Divider(height: 20),
              Row(
                children: [
                  const Icon(
                    Icons.palette_outlined,
                    size: 18,
                    color: Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Predicted Color:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    detectedColor!.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(detectedColor!.score * 100).toInt()}% confidence',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],

            // BrickLink external links if available
            if (item.externalSites.isNotEmpty) ...[
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (final site in item.externalSites)
                    M3EButton.text(
                      onPressed: () {
                        if (site.url.isNotEmpty) {
                          launchUrl(
                            Uri.parse(site.url),
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.open_in_new_rounded, size: 14),
                          const SizedBox(width: 6),
                          Text('View on ${site.name}'),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MatchingSetsSection extends ConsumerWidget {
  final String partNum;
  final String partName;
  final Map<int, dynamic> colorsMap;

  const _MatchingSetsSection({
    required this.partNum,
    required this.partName,
    required this.colorsMap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final matchesAsync = ref.watch(matchingSetsForPartProvider(partNum));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.collections_bookmark_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Sets in Your Collection with This Piece',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        matchesAsync.when(
          data: (matches) {
            if (matches.isEmpty) {
              return M3ECard(
                variant: M3ECardVariant.filled,
                color: theme.colorScheme.surfaceContainer,
                border: BorderSide(
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 40,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No Sets in Your Database Contain Part #$partNum',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'None of the sets currently synced to your account use this part number.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Found in ${matches.length} ${matches.length == 1 ? 'set' : 'sets'} in your collection:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: matches.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    return _MatchCard(
                      match: match,
                      colorsMap: colorsMap,
                    );
                  },
                ),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: SizedBox.square(
                dimension: 28,
                child: M3EProgressIndicator.circular(),
              ),
            ),
          ),
          error: (err, stack) => M3ECard(
            variant: M3ECardVariant.filled,
            color: Colors.redAccent.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error searching collection: $err',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MatchCard extends ConsumerWidget {
  final PartSetMatch match;
  final Map<int, dynamic> colorsMap;

  const _MatchCard({
    required this.match,
    required this.colorsMap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final set = match.set;

    final (statusLabel, statusColor) = switch (set.status) {
      LegoSetStatus.built => ('Built', const Color(0xFF10B981)),
      LegoSetStatus.currentlyBuilding => (
          'Building',
          const Color(0xFFF59E0B),
        ),
      LegoSetStatus.backlog => ('Backlog', const Color(0xFF3B82F6)),
    };

    return M3ECard(
      variant: M3ECardVariant.filled,
      color: theme.colorScheme.surfaceContainer,
      border: BorderSide(
        color: statusColor.withValues(alpha: 0.5),
        width: 1.2,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Set Header
            Row(
              children: [
                // Set Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 54,
                    height: 54,
                    color: Colors.white,
                    child: set.imgUrl != null
                        ? CachedNetworkImage(
                            imageUrl: proxiedImageUrl(set.imgUrl!),
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: SizedBox.square(
                                dimension: 16,
                                child: M3EProgressIndicator.circular(),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.extension_outlined,
                              color: Colors.grey,
                              size: 24,
                            ),
                          )
                        : const Icon(
                            Icons.extension_outlined,
                            color: Colors.grey,
                            size: 24,
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // Set Name & #
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '#${set.setNum}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (set.year != null) ...[
                            const SizedBox(width: 4),
                            Text(
                              '• ${set.year}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        set.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Go to Set Details
                M3EIconButton(
                  variant: M3EIconButtonVariant.tonal,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  tooltip: 'Open Set Details',
                  onPressed: () => context.go('/sets/details/${set.id}'),
                ),
              ],
            ),
            const Divider(height: 18),

            // Piece Variants Breakdown for this Set
            for (final part in match.parts) ...[
              _PartVariantRow(
                part: part,
                colorsMap: colorsMap,
                setId: set.id,
              ),
              if (part != match.parts.last) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _PartVariantRow extends ConsumerWidget {
  final SetPart part;
  final Map<int, dynamic> colorsMap;
  final String setId;

  const _PartVariantRow({
    required this.part,
    required this.colorsMap,
    required this.setId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorInfo = colorsMap[part.colorId];
    Color? colorDot;
    String colorName = 'Color #${part.colorId}';

    if (colorInfo != null) {
      colorName = colorInfo.name as String;
      final rgb = colorInfo.rgb as String;
      colorDot = Color(int.parse('FF$rgb', radix: 16));
    }

    final double progress = part.quantityNeeded > 0
        ? (part.quantityFound / part.quantityNeeded).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Color circle
          if (colorDot != null)
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: colorDot,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
            ),
          const SizedBox(width: 8),

          // Color Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  colorName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Text(
                      '${part.quantityFound} of ${part.quantityNeeded} found',
                      style: TextStyle(
                        fontSize: 12,
                        color: getProgressColor(progress),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (part.isSpare) ...[
                      const SizedBox(width: 6),
                      Text(
                        '(Spare)',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Quick Increment / Decrement
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              M3EIconButton(
                variant: M3EIconButtonVariant.outlined,
                icon: const Icon(Icons.remove_rounded, size: 14),
                tooltip: 'Decrease found count',
                onPressed: part.quantityFound > 0
                    ? () {
                        ref
                            .read(setPartsNotifierProvider(setId).notifier)
                            .updateQuantity(part.id, part.quantityFound - 1);
                        ref.invalidate(matchingSetsForPartProvider(part.partNum));
                      }
                    : null,
              ),
              const SizedBox(width: 6),
              M3EIconButton(
                variant: M3EIconButtonVariant.tonal,
                icon: const Icon(Icons.add_rounded, size: 14),
                tooltip: 'Increase found count',
                onPressed: !part.isFinished
                    ? () {
                        ref
                            .read(setPartsNotifierProvider(setId).notifier)
                            .updateQuantity(part.id, part.quantityFound + 1);
                        ref.invalidate(matchingSetsForPartProvider(part.partNum));
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
