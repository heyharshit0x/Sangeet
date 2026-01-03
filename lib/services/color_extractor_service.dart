import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ColorExtractorService {
  static final ColorExtractorService _instance =
      ColorExtractorService._internal();
  factory ColorExtractorService() => _instance;
  ColorExtractorService._internal();

  // Cache for extracted colors
  final Map<String, List<Color>> _colorCache = {};

  /// Extract dominant colors from an image URL
  Future<List<Color>> extractColors(String imageUrl) async {
    // Check cache first
    if (_colorCache.containsKey(imageUrl)) {
      return _colorCache[imageUrl]!;
    }

    try {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(imageUrl),
        size: const Size(200, 200),
        maximumColorCount: 20,
      );

      List<Color> colors = [];

      // Try to get vibrant colors first
      if (paletteGenerator.vibrantColor != null) {
        colors.add(paletteGenerator.vibrantColor!.color);
      }
      if (paletteGenerator.darkVibrantColor != null) {
        colors.add(paletteGenerator.darkVibrantColor!.color);
      }
      if (paletteGenerator.lightVibrantColor != null) {
        colors.add(paletteGenerator.lightVibrantColor!.color);
      }

      // Fallback to muted colors
      if (colors.isEmpty) {
        if (paletteGenerator.mutedColor != null) {
          colors.add(paletteGenerator.mutedColor!.color);
        }
        if (paletteGenerator.darkMutedColor != null) {
          colors.add(paletteGenerator.darkMutedColor!.color);
        }
      }

      // Fallback to dominant color
      if (colors.isEmpty && paletteGenerator.dominantColor != null) {
        colors.add(paletteGenerator.dominantColor!.color);
      }

      // If still no colors, use default gradient
      if (colors.isEmpty) {
        colors = _getDefaultGradient();
      }

      // Ensure we have at least 2 colors for gradient
      if (colors.length == 1) {
        colors.add(_darkenColor(colors[0], 0.2));
      }

      // Cache the result
      _colorCache[imageUrl] = colors;

      return colors;
    } catch (e) {
      // Return default gradient on error
      return _getDefaultGradient();
    }
  }

  /// Get a gradient pair from extracted colors
  List<Color> getGradientPair(List<Color> colors) {
    if (colors.length >= 2) {
      return [colors[0], colors[1]];
    } else if (colors.length == 1) {
      return [colors[0], _darkenColor(colors[0], 0.2)];
    }
    return _getDefaultGradient();
  }

  /// Get default gradient colors
  List<Color> _getDefaultGradient() {
    return [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF8B5CF6), // Purple
    ];
  }

  /// Darken a color by a percentage
  Color _darkenColor(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final darkened =
        hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darkened.toColor();
  }

  /// Get a color with adjusted opacity for overlays
  Color getOverlayColor(Color color, {double opacity = 0.7}) {
    return color.withValues(alpha: opacity);
  }

  /// Clear the color cache
  void clearCache() {
    _colorCache.clear();
  }

  /// Remove specific image from cache
  void removeCached(String imageUrl) {
    _colorCache.remove(imageUrl);
  }
}
