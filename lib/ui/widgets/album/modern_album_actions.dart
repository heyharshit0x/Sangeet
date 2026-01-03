import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sangeet/ui/widgets/shared/gradient_action_button.dart';
import 'dart:ui';

class ModernAlbumActions extends StatelessWidget {
  final VoidCallback onPlayAll;
  final VoidCallback onShuffle;
  final VoidCallback onBookmark;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onEnqueue;
  final bool isBookmarked;
  final bool isDownloaded;
  final bool isDownloading;
  final int? downloadProgress;
  final int? totalSongs;
  final List<Color>? gradientColors;

  const ModernAlbumActions({
    super.key,
    required this.onPlayAll,
    required this.onShuffle,
    required this.onBookmark,
    required this.onDownload,
    required this.onShare,
    required this.onEnqueue,
    this.isBookmarked = false,
    this.isDownloaded = false,
    this.isDownloading = false,
    this.downloadProgress,
    this.totalSongs,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultGradient = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Primary Actions Row
          Row(
            children: [
              Expanded(
                flex: 3,
                child: GradientActionButton(
                  label: 'Play All',
                  icon: PhosphorIconsFill.play,
                  onPressed: onPlayAll,
                  gradientColors: gradientColors ?? defaultGradient,
                  size: GradientButtonSize.large,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GradientActionButton(
                  label: 'Shuffle',
                  icon: PhosphorIconsBold.shuffle,
                  onPressed: onShuffle,
                  gradientColors: gradientColors ?? defaultGradient,
                  size: GradientButtonSize.large,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Secondary Actions Row
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.02),
                      isDark
                          ? Colors.white.withValues(alpha: 0.02)
                          : Colors.black.withValues(alpha: 0.01),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Bookmark
                    _SecondaryActionButton(
                      icon: isBookmarked
                          ? PhosphorIconsFill.bookmark
                          : PhosphorIconsRegular.bookmark,
                      label: isBookmarked ? 'Saved' : 'Save',
                      onPressed: onBookmark,
                      color: isBookmarked ? Colors.amber : null,
                    ),

                    // Download
                    _SecondaryActionButton(
                      icon: isDownloaded
                          ? PhosphorIconsFill.checkCircle
                          : isDownloading
                              ? PhosphorIconsRegular.circleNotch
                              : PhosphorIconsRegular.downloadSimple,
                      label: isDownloaded
                          ? 'Downloaded'
                          : isDownloading
                              ? '${downloadProgress ?? 0}/${totalSongs ?? 0}'
                              : 'Download',
                      onPressed: isDownloaded ? null : onDownload,
                      isLoading: isDownloading,
                    ),

                    // Enqueue
                    _SecondaryActionButton(
                      icon: PhosphorIconsRegular.queue,
                      label: 'Queue',
                      onPressed: onEnqueue,
                    ),

                    // Share
                    _SecondaryActionButton(
                      icon: PhosphorIconsRegular.shareNetwork,
                      label: 'Share',
                      onPressed: onShare,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isLoading;

  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    icon,
                    color: color ?? Theme.of(context).iconTheme.color,
                    size: 24,
                  ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: color,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
