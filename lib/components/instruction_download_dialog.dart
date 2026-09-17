import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lego_app/api/services/brickset_api.dart';
import 'package:lego_app/db/models/lego_set.dart';
import 'package:lego_app/services/instruction_pdf_service.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

class InstructionDownloadDialog extends HookWidget {
  final LegoSet set;
  final LegoInstruction instruction;

  const InstructionDownloadDialog({
    super.key,
    required this.set,
    required this.instruction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = useState<double>(0.0);
    final receivedBytes = useState<int>(0);
    final totalBytes = useState<int>(0);
    final isCancelled = useRef<bool>(false);
    final errorMessage = useState<String?>(null);

    useEffect(() {
      Future<void> startDownload() async {
        try {
          final file = await instructionPdfService.downloadInstruction(
            setNum: set.setNum,
            instruction: instruction,
            isCancelled: () => isCancelled.value,
            onProgress: (p, received, total) {
              if (context.mounted && !isCancelled.value) {
                progress.value = p;
                receivedBytes.value = received;
                totalBytes.value = total;
              }
            },
          );
          if (context.mounted && !isCancelled.value) {
            Navigator.of(context).pop(file);
          }
        } catch (e) {
          if (context.mounted && !isCancelled.value) {
            errorMessage.value = e.toString();
          }
        }
      }

      startDownload();
      return () {
        isCancelled.value = true;
      };
    }, const []);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: M3ECard(
          variant: M3ECardVariant.elevated,
          borderRadius: BorderRadius.circular(24),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.picture_as_pdf_rounded,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Downloading Instructions',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          set.setNum,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                instruction.description,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              if (errorMessage.value != null) ...[
                Text(
                  'Error: ${errorMessage.value}',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: M3EButton.text(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: const Text('Close'),
                  ),
                ),
              ] else ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.value > 0 ? progress.value : null,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      progress.value > 0
                          ? '${(progress.value * 100).toInt()}%'
                          : 'Starting download...',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      totalBytes.value > 0
                          ? '${InstructionPdfService.formatBytes(receivedBytes.value)} / ${InstructionPdfService.formatBytes(totalBytes.value)}'
                          : (receivedBytes.value > 0
                              ? InstructionPdfService.formatBytes(receivedBytes.value)
                              : ''),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: M3EButton.text(
                    onPressed: () {
                      isCancelled.value = true;
                      Navigator.of(context).pop(null);
                    },
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
