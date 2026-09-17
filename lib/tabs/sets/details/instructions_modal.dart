import 'dart:io';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lego_app/api/services/brickset_api.dart';
import 'package:lego_app/db/models/lego_set.dart';
import 'package:lego_app/services/instruction_pdf_service.dart';
import 'package:lego_app/util.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:open_filex/open_filex.dart';

class InstructionsModal extends HookWidget {
  final LegoSet set;
  final List<LegoInstruction> instructions;

  const InstructionsModal({
    super.key,
    required this.set,
    required this.instructions,
  });

  Future<void> _handleOpenPdf(
    BuildContext context,
    File file,
    LegoInstruction instruction,
  ) async {
    try {
      final result = await instructionPdfService.openPdfFile(file);
      if (result.type != ResultType.done && context.mounted) {
        if (result.type == ResultType.noAppToOpen) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No PDF reader app found on device.'),
              action: SnackBarAction(
                label: 'Open in Browser',
                onPressed: () => instructionPdfService.fallbackOpenInBrowser(instruction),
              ),
            ),
          );
        } else {
          showSnack(context, 'Could not open PDF: ${result.message}');
        }
      }
    } catch (e) {
      if (context.mounted) {
        showSnack(context, 'Error launching PDF viewer: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final downloadedUrls = useState<Set<String>>({});
    final downloadingUrl = useState<String?>(null);
    final progressMap = useState<Map<String, double>>({});
    final receivedBytesMap = useState<Map<String, int>>({});
    final totalBytesMap = useState<Map<String, int>>({});
    final isDisposed = useRef<bool>(false);

    // Check which instructions are already downloaded
    useEffect(() {
      Future<void> checkDownloaded() async {
        final downloaded = <String>{};
        for (final instruction in instructions) {
          if (await instructionPdfService.isInstructionDownloaded(set.setNum, instruction)) {
            downloaded.add(instruction.url);
          }
        }
        if (!isDisposed.value) {
          downloadedUrls.value = downloaded;
        }
      }

      checkDownloaded();
      return () {
        isDisposed.value = true;
      };
    }, const []);

    Future<void> openOrDownload(LegoInstruction instruction) async {
      if (downloadingUrl.value != null) return;

      final isDownloaded = downloadedUrls.value.contains(instruction.url);
      if (isDownloaded) {
        final file = await instructionPdfService.getLocalInstructionFile(set.setNum, instruction);
        if (context.mounted) {
          await _handleOpenPdf(context, file, instruction);
        }
        return;
      }

      downloadingUrl.value = instruction.url;
      progressMap.value = {...progressMap.value, instruction.url: 0.0};

      try {
        final file = await instructionPdfService.downloadInstruction(
          setNum: set.setNum,
          instruction: instruction,
          isCancelled: () => isDisposed.value,
          onProgress: (p, received, total) {
            if (!isDisposed.value) {
              progressMap.value = {...progressMap.value, instruction.url: p};
              receivedBytesMap.value = {...receivedBytesMap.value, instruction.url: received};
              totalBytesMap.value = {...totalBytesMap.value, instruction.url: total};
            }
          },
        );

        if (!isDisposed.value) {
          downloadedUrls.value = {...downloadedUrls.value, instruction.url};
          downloadingUrl.value = null;
        }

        if (context.mounted) {
          await _handleOpenPdf(context, file, instruction);
        }
      } catch (e) {
        if (!isDisposed.value) {
          downloadingUrl.value = null;
          if (context.mounted) {
            showSnack(context, 'Error downloading instructions: $e');
          }
        }
      }
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 24,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Building Instructions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${set.setNum} • ${instructions.length} booklets available',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Instruction Booklets List
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: instructions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final instruction = instructions[index];
                final isDownloaded = downloadedUrls.value.contains(instruction.url);
                final isDownloading = downloadingUrl.value == instruction.url;
                final progress = progressMap.value[instruction.url] ?? 0.0;
                final received = receivedBytesMap.value[instruction.url] ?? 0;
                final total = totalBytesMap.value[instruction.url] ?? 0;

                return M3ECard(
                  variant: M3ECardVariant.filled,
                  color: theme.colorScheme.surfaceContainerHigh,
                  border: BorderSide(
                    color: isDownloaded
                        ? theme.colorScheme.primary.withValues(alpha: 0.3)
                        : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  onPressed: isDownloading ? null : () => openOrDownload(instruction),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isDownloaded
                                    ? theme.colorScheme.primaryContainer
                                    : theme.colorScheme.secondaryContainer.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: isDownloading
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          value: progress > 0 ? progress : null,
                                        ),
                                      )
                                    : Icon(
                                        isDownloaded
                                            ? Icons.check_circle_rounded
                                            : Icons.picture_as_pdf_rounded,
                                        size: 22,
                                        color: isDownloaded
                                            ? theme.colorScheme.onPrimaryContainer
                                            : theme.colorScheme.onSecondaryContainer,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    instruction.description,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isDownloading
                                        ? (total > 0
                                            ? 'Downloading ${(progress * 100).toInt()}% • ${InstructionPdfService.formatBytes(received)} / ${InstructionPdfService.formatBytes(total)}'
                                            : 'Downloading...')
                                        : (isDownloaded
                                            ? 'Booklet ${index + 1} of ${instructions.length} • Saved on device'
                                            : 'Booklet ${index + 1} of ${instructions.length}'),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: isDownloading
                                          ? theme.colorScheme.primary
                                          : (isDownloaded
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.onSurfaceVariant),
                                      fontWeight: isDownloaded || isDownloading
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (!isDownloading)
                              Icon(
                                isDownloaded
                                    ? Icons.open_in_new_rounded
                                    : Icons.download_rounded,
                                size: 20,
                                color: isDownloaded
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                          ],
                        ),
                        if (isDownloading) ...[
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress > 0 ? progress : null,
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
