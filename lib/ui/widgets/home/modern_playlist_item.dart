import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sangeet/ui/player/player_controller.dart';
import 'package:sangeet/models/playlist.dart';
import 'package:sangeet/models/album.dart';
import 'package:sangeet/ui/widgets/songinfo_bottom_sheet.dart';

class ModernPlaylistItem extends StatelessWidget {
  final dynamic content;

  const ModernPlaylistItem({
    super.key,
    required this.content,
  });

  String _getTitle() {
    if (content is Playlist) {
      return (content as Playlist).title;
    } else if (content is Album) {
      return (content as Album).title;
    } else if (content is MediaItem) {
      return (content as MediaItem).title;
    }
    return '';
  }

  String _getSubtitle() {
    if (content is Playlist) {
      final playlist = content as Playlist;
      return playlist.description ?? 'Playlist';
    } else if (content is Album) {
      final album = content as Album;
      final artistName = album.artists?[0]['name'] ?? '';
      return 'By $artistName • ${album.year ?? ""}';
    } else if (content is MediaItem) {
      final song = content as MediaItem;
      return song.artist ?? '';
    }
    return '';
  }

  String? _getImageUrl() {
    if (content is Playlist) {
      return (content as Playlist).thumbnailUrl;
    } else if (content is Album) {
      return (content as Album).thumbnailUrl;
    } else if (content is MediaItem) {
      return (content as MediaItem).artUri?.toString();
    }
    return null;
  }

  void _onPlay() {
    // Navigation to detail screens will load songs
    // For now, just navigate to the detail screen
    if (content is Playlist) {
      Get.toNamed('/playlistScreen',
          arguments: [content, (content as Playlist).playlistId]);
    } else if (content is Album) {
      Get.toNamed('/albumScreen',
          arguments: (content, (content as Album).browseId));
    } else if (content is MediaItem) {
      Get.find<PlayerController>().pushSongToQueue(content as MediaItem);
    }
  }

  void _onTap() {
    // Navigate to detail screen based on content type
    if (content is Playlist) {
      // Navigate to playlist detail
      Get.toNamed('/playlistScreen',
          arguments: [content, (content as Playlist).playlistId]);
    } else if (content is Album) {
      // Navigate to album detail
      Get.toNamed('/albumScreen',
          arguments: (content, (content as Album).browseId));
    }
  }

  void _onLongPress() {
    if (content is MediaItem) {
      // Show song options for songs
      final playerController = Get.find<PlayerController>();
      showModalBottomSheet(
        constraints: const BoxConstraints(maxWidth: 500),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
        ),
        isScrollControlled: true,
        context: playerController.homeScaffoldkey.currentState!.context,
        barrierColor: Colors.transparent.withAlpha(100),
        builder: (context) => SongInfoBottomSheet(content as MediaItem),
      ).whenComplete(() => Get.delete<SongInfoController>());
    } else if (content is Playlist || content is Album) {
      // For playlists/albums, just show a message or navigate
      _onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getImageUrl();

    return GestureDetector(
      onLongPress: _onLongPress,
      child: InkWell(
        onTap: _onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              // Album Art
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 60,
                          height: 60,
                          color: Theme.of(context).colorScheme.secondary,
                          child: const Icon(Icons.music_note),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 60,
                          height: 60,
                          color: Theme.of(context).colorScheme.secondary,
                          child: const Icon(Icons.music_note),
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: Theme.of(context).colorScheme.secondary,
                        child: const Icon(Icons.music_note),
                      ),
              ),
              const SizedBox(width: 12),
              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getTitle(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getSubtitle(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Play Button
              IconButton(
                icon: Icon(
                  Icons.play_arrow,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                onPressed: _onPlay,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
