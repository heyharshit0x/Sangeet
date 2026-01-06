import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sangeet/ui/player/player_controller.dart';
import 'package:sangeet/ui/widgets/songinfo_bottom_sheet.dart';

class ModernSongItem extends StatelessWidget {
  final MediaItem song;
  final int? index;

  const ModernSongItem({
    super.key,
    required this.song,
    this.index,
  });

  void _onTap() {
    Get.find<PlayerController>().pushSongToQueue(song);
  }

  void _onLongPress() {
    final playerController = Get.find<PlayerController>();
    showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: 500),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
      ),
      isScrollControlled: true,
      context: playerController.homeScaffoldkey.currentState!.context,
      barrierColor: Colors.transparent.withAlpha(100),
      builder: (context) => SongInfoBottomSheet(song),
    ).whenComplete(() => Get.delete<SongInfoController>());
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onLongPress: _onLongPress,
        child: InkWell(
          onTap: _onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                // Album Art - removed expensive BackdropFilter
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: song.artUri != null
                      ? CachedNetworkImage(
                          imageUrl: song.artUri.toString(),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          memCacheWidth: 120, // Optimize memory
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
                        song.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.artist ?? 'Unknown Artist',
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
                // Play icon
                IconButton(
                  icon: Icon(
                    PhosphorIconsFill.playCircle,
                    color: Theme.of(context).colorScheme.primary,
                    size: 40,
                  ),
                  onPressed: _onTap,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
