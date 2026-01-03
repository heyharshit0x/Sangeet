import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../navigator.dart';
import 'image_widget.dart';
import '../../models/playlist.dart';
import 'package:hive/hive.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/media_Item_builder.dart';

class ContentListItem extends StatelessWidget {
  const ContentListItem(
      {super.key, required this.content, this.isLibraryItem = false});

  ///content will be of Type class Album or Playlist
  final dynamic content;
  final bool isLibraryItem;

  @override
  Widget build(BuildContext context) {
    final isAlbum = content.runtimeType.toString() == "Album";
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        if (isAlbum) {
          Get.toNamed(ScreenNavigationSetup.albumScreen,
              id: ScreenNavigationSetup.id,
              arguments: (content, content.browseId));
          return;
        }
        Get.toNamed(ScreenNavigationSetup.playlistScreen,
            id: ScreenNavigationSetup.id,
            arguments: [content, content.playlistId]);
      },
      child: Container(
        width: 130,
        height: 180,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isAlbum
                ? ImageWidget(
                    size: 120,
                    album: content,
                  )
                : content.playlistId == 'LIBRP' ||
                        content.playlistId == 'LIBFAV' ||
                        content.playlistId == 'SongsCache' ||
                        content.playlistId == 'SongDownloads'
                    ? _buildSpecialPlaylistCard(context, content.playlistId)
                    : content.isCloudPlaylist &&
                            content.thumbnailUrl.isNotEmpty &&
                            content.thumbnailUrl != Playlist.thumbPlaceholderUrl
                        ? SizedBox.square(
                            dimension: 120,
                            child: Stack(
                              children: [
                                ImageWidget(
                                  size: 120,
                                  playlist: content,
                                ),
                                if (content.isPipedPlaylist)
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height: 18,
                                        width: 18,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                        child: Center(
                                            child: Text(
                                          "P",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(fontSize: 14),
                                        )),
                                      ),
                                    ),
                                  ),
                                if (!content.isCloudPlaylist)
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height: 18,
                                        width: 18,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                        child: Center(
                                            child: Text(
                                          "L",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(fontSize: 14),
                                        )),
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          )
                        : _buildUserPlaylistCard(context, content),
            const SizedBox(height: 5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    // overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    isAlbum
                        ? isLibraryItem
                            ? ""
                            : "${content.artists[0]['name'] ?? ""} | ${content.year ?? ""}"
                        : isLibraryItem
                            ? ""
                            : content.description ?? "",
                    maxLines: 1,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialPlaylistCard(BuildContext context, String playlistId) {
    // Define gradient colors and icons for each special playlist
    final Map<String, Map<String, dynamic>> playlistStyles = {
      'LIBRP': {
        'colors': [
          const Color(0xFF8E2DE2),
          const Color(0xFF4A00E0),
        ],
        'icon': Icons.history_rounded,
      },
      'LIBFAV': {
        'colors': [
          const Color(0xFFFF6B9D),
          const Color(0xFFC239B3),
        ],
        'icon': Icons.favorite_rounded,
      },
      'SongsCache': {
        'colors': [
          const Color(0xFF00C6FF),
          const Color(0xFF0072FF),
        ],
        'icon': Icons.flight_rounded,
      },
      'SongDownloads': {
        'colors': [
          const Color(0xFF11998E),
          const Color(0xFF38EF7D),
        ],
        'icon': Icons.download_rounded,
      },
    };

    final style = playlistStyles[playlistId]!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: style['colors'] as List<Color>,
        ),
        boxShadow: [
          BoxShadow(
            color: (style['colors'] as List<Color>)[0].withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative pattern overlay for depth
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Glassmorphic icon container
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.25),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                style['icon'] as IconData,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserPlaylistCard(BuildContext context, dynamic playlist) {
    return FutureBuilder<List<String>>(
      future: _fetchPlaylistAlbumArts(playlist.playlistId),
      builder: (context, snapshot) {
        // Show gradient fallback while loading or if too few songs
        if (!snapshot.hasData || snapshot.data!.length < 2) {
          return _buildGradientPlaceholder(context, playlist);
        }

        // Build 2x2 collage with album arts
        return _build2x2Collage(context, snapshot.data!, playlist);
      },
    );
  }

  /// Fetches first 4 album art URLs from playlist songs
  Future<List<String>> _fetchPlaylistAlbumArts(String playlistId) async {
    try {
      final songsBox = await Hive.openBox(playlistId);
      final List<String> artUris = [];

      // Get first 4 songs
      final songsCount = songsBox.length > 4 ? 4 : songsBox.length;
      for (int i = 0; i < songsCount; i++) {
        final songJson = songsBox.getAt(i);
        if (songJson != null) {
          final song = MediaItemBuilder.fromJson(songJson);
          if (song.artUri != null) {
            artUris.add(song.artUri.toString());
          }
        }
      }

      await songsBox.close();
      return artUris;
    } catch (e) {
      // Return empty list on error (will trigger gradient fallback)
      return [];
    }
  }

  /// Builds 2x2 grid collage of album arts
  Widget _build2x2Collage(
      BuildContext context, List<String> artUris, dynamic playlist) {
    return Container(
      height: 120,
      width: 120,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 2x2 Grid of album arts
          Column(
            children: [
              // Top row
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                        child: _buildCollageImage(
                            artUris.isNotEmpty ? artUris[0] : '')),
                    Expanded(
                        child: _buildCollageImage(
                            artUris.length > 1 ? artUris[1] : '')),
                  ],
                ),
              ),
              // Bottom row
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                        child: _buildCollageImage(
                            artUris.length > 2 ? artUris[2] : '')),
                    Expanded(
                        child: _buildCollageImage(
                            artUris.length > 3 ? artUris[3] : '')),
                  ],
                ),
              ),
            ],
          ),
          // Bottom gradient overlay for depth
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ),
          // Song count badge (if available)
          if (playlist.songCount != null && playlist.songCount!.isNotEmpty)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  playlist.songCount!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds individual image for collage cell
  Widget _buildCollageImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(color: Colors.grey[800]);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[800],
        child: Icon(Icons.music_note, color: Colors.grey[600], size: 20),
      ),
    );
  }

  /// Builds gradient fallback for playlists with < 2 songs
  Widget _buildGradientPlaceholder(BuildContext context, dynamic playlist) {
    // Curated gradient palettes for user playlists (matching SimplePlaylistDialog)
    final List<List<Color>> gradientPalettes = [
      [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)], // Purple
      [const Color(0xFFFF6B9D), const Color(0xFFC239B3)], // Pink
      [const Color(0xFF00C6FF), const Color(0xFF0072FF)], // Blue
      [const Color(0xFF11998E), const Color(0xFF38EF7D)], // Green
      [const Color(0xFFFF6B6B), const Color(0xFFFFE66D)], // Sunset
      [const Color(0xFF06B6D4), const Color(0xFF3B82F6)], // Sky
      [const Color(0xFFA855F7), const Color(0xFFEC4899)], // Cosmos
      [const Color(0xFFEF4444), const Color(0xFFF97316)], // Fire
    ];

    // Icon options (matching SimplePlaylistDialog)
    final List<IconData> playlistIcons = [
      Icons.queue_music_rounded,
      Icons.favorite_rounded,
      Icons.star_rounded,
      Icons.auto_awesome_rounded,
      Icons.whatshot_rounded,
      Icons.headphones_rounded,
      Icons.album_rounded,
      Icons.music_note_rounded,
    ];

    // Use stored indices or fallback to hash-based selection
    final int gradientIndex = playlist.colorIndex ??
        (playlist.playlistId.hashCode.abs() % gradientPalettes.length);
    final int iconIdx = playlist.iconIndex ?? 0;

    final gradientColors = gradientPalettes[gradientIndex];
    final selectedIcon = playlistIcons[iconIdx];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative overlay for depth
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Glassmorphic icon
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.25),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                selectedIcon,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          // Song count badge (if available)
          if (playlist.songCount != null && playlist.songCount!.isNotEmpty)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  playlist.songCount!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
