import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sangeet/models/thumbnail.dart';
import 'package:sangeet/services/color_extractor_service.dart';
import 'package:widget_marquee/widget_marquee.dart';

class ModernAlbumHeader extends StatefulWidget {
  final String albumTitle;
  final String? albumDescription;
  final String? artists;
  final String thumbnailUrl;
  final double scrollOffset;
  final bool isLandscape;

  const ModernAlbumHeader({
    super.key,
    required this.albumTitle,
    this.albumDescription,
    this.artists,
    required this.thumbnailUrl,
    required this.scrollOffset,
    this.isLandscape = false,
  });

  @override
  State<ModernAlbumHeader> createState() => _ModernAlbumHeaderState();
}

class _ModernAlbumHeaderState extends State<ModernAlbumHeader> {
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
    final size = MediaQuery.of(context).size;

    // Calculate opacity based on scroll
    final opacityValue =
        (1 - widget.scrollOffset / (size.width - 100)).clamp(0.0, 1.0);

    // Get gradient colors
    final gradientColors = _extractedColors ??
        [
          Theme.of(context).colorScheme.primary,
          Theme.of(context).colorScheme.secondary,
        ];

    return Positioned(
      top: widget.isLandscape ? 0 : -0.25 * widget.scrollOffset,
      right: widget.isLandscape ? 0 : null,
      left: widget.isLandscape ? null : 0,
      child: Opacity(
        opacity: opacityValue,
        child: Stack(
          children: [
            // Blurred background image
            Container(
              width: widget.isLandscape ? null : size.width,
              height: widget.isLandscape ? size.height : size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    gradientColors[0].withValues(alpha: 0.3),
                    gradientColors.length > 1
                        ? gradientColors[1].withValues(alpha: 0.1)
                        : gradientColors[0].withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                  child: CachedNetworkImage(
                    imageUrl: Thumbnail(widget.thumbnailUrl).extraHigh,
                    fit:
                        widget.isLandscape ? BoxFit.fitHeight : BoxFit.fitWidth,
                    width: widget.isLandscape ? null : size.width,
                    height: widget.isLandscape ? size.height : null,
                  ),
                ),
              ),
            ),

            // Gradient overlay
            Container(
              width: widget.isLandscape ? null : size.width,
              height: widget.isLandscape ? size.height : size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Theme.of(context).canvasColor.withValues(alpha: 0.7),
                    Theme.of(context).canvasColor,
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),

            // Blur effect overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AlbumInfoCard extends StatelessWidget {
  final String albumTitle;
  final String? albumDescription;
  final String? artists;
  final String thumbnailUrl;
  final List<Color>? gradientColors;

  const AlbumInfoCard({
    super.key,
    required this.albumTitle,
    this.albumDescription,
    this.artists,
    required this.thumbnailUrl,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Album Art
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (gradientColors?[0] ?? Colors.black)
                      .withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: Thumbnail(thumbnailUrl).extraHigh,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Album Info in Glassmorphic Card
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(20),
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
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Album Title
                    Marquee(
                      delay: const Duration(milliseconds: 300),
                      duration: const Duration(seconds: 5),
                      id: albumTitle.hashCode.toString(),
                      child: Text(
                        albumTitle,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),

                    if (albumDescription != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        albumDescription!,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withValues(alpha: 0.7),
                            ),
                      ),
                    ],

                    if (artists != null) ...[
                      const SizedBox(height: 12),
                      Marquee(
                        delay: const Duration(milliseconds: 300),
                        duration: const Duration(seconds: 5),
                        id: artists.hashCode.toString(),
                        child: Text(
                          artists!,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ],
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
