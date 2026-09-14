import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lego_app/util.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

/// Opens the fullscreen interactive image viewer dialog.
Future<void> openImageViewer(
  BuildContext context, {
  required String imageUrl,
  String? title,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Image Viewer',
    barrierColor: Colors.black.withValues(alpha: 0.92),
    transitionDuration: const Duration(milliseconds: 200),
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(opacity: anim1, child: child);
    },
    pageBuilder: (context, anim1, anim2) => ImageViewerDialog(
      imageUrl: imageUrl,
      title: title,
    ),
  );
}

class ImageViewerDialog extends StatefulWidget {
  final String imageUrl;
  final String? title;

  const ImageViewerDialog({
    super.key,
    required this.imageUrl,
    this.title,
  });

  @override
  State<ImageViewerDialog> createState() => _ImageViewerDialogState();
}

class _ImageViewerDialogState extends State<ImageViewerDialog>
    with SingleTickerProviderStateMixin {
  late final TransformationController _transformationController;
  late final FocusNode _focusNode;
  TapDownDetails? _doubleTapDetails;
  AnimationController? _animationController;
  Animation<Matrix4>? _zoomAnimation;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _focusNode = FocusNode();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(() {
        if (_zoomAnimation != null) {
          _transformationController.value = _zoomAnimation!.value;
        }
      });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _animationController?.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final targetMatrix = Matrix4.identity();

    if (currentScale <= 1.05) {
      final position = _doubleTapDetails?.localPosition ?? Offset.zero;
      targetMatrix
        ..translateByDouble(-position.dx * 1.5, -position.dy * 1.5, 0.0, 1.0)
        ..scaleByDouble(2.5, 2.5, 1.0, 1.0);
    } else {
      targetMatrix.setIdentity();
    }

    _zoomAnimation = Matrix4Tween(
      begin: _transformationController.value,
      end: targetMatrix,
    ).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController!.forward(from: 0);
  }

  void _resetZoom() {
    _zoomAnimation = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity(),
    ).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController!.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Interactive Zoomable Image Area
            Positioned.fill(
              child: GestureDetector(
                onDoubleTapDown: (d) => _doubleTapDetails = d,
                onDoubleTap: _handleDoubleTap,
                child: Center(
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    clipBehavior: Clip.none,
                    minScale: 0.5,
                    maxScale: 6.0,
                    child: CachedNetworkImage(
                      imageUrl: proxiedImageUrl(widget.imageUrl),
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: SizedBox.square(
                          dimension: 36,
                          child: M3EProgressIndicator.circular(),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.broken_image_rounded,
                              size: 64,
                              color: Colors.white54,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Unable to load image',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Top Header Overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        if (widget.title != null)
                          Expanded(
                            child: Text(
                              widget.title!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        else
                          const Spacer(),
                        IconButton(
                          tooltip: 'Reset Zoom',
                          icon: const Icon(
                            Icons.restart_alt_rounded,
                            color: Colors.white,
                          ),
                          onPressed: _resetZoom,
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          tooltip: 'Close',
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
