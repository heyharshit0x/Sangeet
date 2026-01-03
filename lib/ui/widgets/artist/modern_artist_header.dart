import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sangeet/models/thumbnail.dart';
import 'package:sangeet/services/color_extractor_service.dart';

class ModernArtistHeader extends StatefulWidget {
  final String artistName;
  final String thumbnailUrl;
  final String? description;
  final bool isBookmarked;
  final VoidCallback onBookmarkTap;
  final VoidCallback onShareTap;
  final double scrollOffset;

  const ModernArtistHeader({
    super.key,
    required this.artistName,
    required this.thumbnailUrl,
    this.description,
    required this.isBookmarked,
    required this.onBookmarkTap,
    required this.onShareTap,
    this.scrollOffset = 0,
  });

  @override
  State<ModernArtistHeader> createState() => _ModernArtistHeaderState();
}

class _ModernArtistHeaderState extends State<ModernArtistHeader> {
  final _colorExtractor = ColorExtractorService();
  List<Color>? _extractedColors;

  @override
  void initState() {
    super.initState();
    _extractColors();
  }

  Future<void> _extractColors() async {
    final colors = await _colorExtractor.extractColors(
      Thumbnail(widget.thumbnailUrl).extraHigh,
    );
    if (mounted) {
      setState(() => _extractedColors = colors);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _extractedColors ??
        [
          Theme.of(context).colorScheme.primary,
          Theme.of(context).colorScheme.secondary,
        ];

    // Calculate header shrink based on scroll
    final shrinkOffset = (widget.scrollOffset / 200).clamp(0.0, 1.0);
    final headerHeight = 280 - (shrinkOffset * 100);

    return SizedBox(
      height: headerHeight,
      child: Stack(
        children: [
          // Background gradient with artist image
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    gradientColors[0].withValues(alpha: 0.6),
                    gradientColors.length > 1
                        ? gradientColors[1].withValues(alpha: 0.3)
                        : gradientColors[0].withValues(alpha: 0.3),
                    Theme.of(context).canvasColor,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Blurred artist image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 1 - shrinkOffset,
              child: SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: Thumbnail(widget.thumbnailUrl).extraHigh,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Theme.of(context)
                                    .canvasColor
                                    .withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Artist Image
                  Container(
                    width: 100 - (shrinkOffset * 30),
                    height: 100 - (shrinkOffset * 30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors[0].withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: Thumbnail(widget.thumbnailUrl).high,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Artist Name
                  Text(
                    widget.artistName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 28 - (shrinkOffset * 8),
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ActionButton(
                        icon: widget.isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        onTap: widget.onBookmarkTap,
                        color: widget.isBookmarked ? Colors.amber : null,
                      ),
                      const SizedBox(width: 16),
                      _ActionButton(
                        icon: Icons.share,
                        onTap: widget.onShareTap,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.1),
          ),
        ),
        child: Icon(
          icon,
          color: color ?? Theme.of(context).iconTheme.color,
          size: 20,
        ),
      ),
    );
  }
}
