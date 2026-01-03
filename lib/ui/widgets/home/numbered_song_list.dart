import 'dart:ui';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/ui/player/player_controller.dart';
import '/ui/widgets/image_widget.dart';
import '/ui/widgets/songinfo_bottom_sheet.dart';

class NumberedSongList extends StatelessWidget {
  final String title;
  final List<MediaItem> songs;

  const NumberedSongList({
    super.key,
    required this.title,
    required this.songs,
  });

  @override
  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();
    final displaySongs = songs.take(10).toList();

    if (displaySongs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displaySongs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final song = displaySongs[index];
              return _PremiumSongItem(
                index: index,
                song: song,
                playerController: playerController,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PremiumSongItem extends StatefulWidget {
  final int index;
  final MediaItem song;
  final PlayerController playerController;

  const _PremiumSongItem({
    required this.index,
    required this.song,
    required this.playerController,
  });

  @override
  State<_PremiumSongItem> createState() => __PremiumSongItemState();
}

class __PremiumSongItemState extends State<_PremiumSongItem> {
  bool _isPressed = false;

  Color _getMedalColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFD700); // Gold
      case 1:
        return const Color(0xFFC0C0C0); // Silver
      case 2:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.transparent;
    }
  }

  IconData _getMedalIcon(int index) {
    switch (index) {
      case 0:
        return Icons.emoji_events; // Trophy for gold
      case 1:
        return Icons.emoji_events_outlined;
      case 2:
        return Icons.emoji_events_outlined;
      default:
        return Icons.music_note;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTop3 = widget.index < 3;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.playerController.pushSongToQueue(widget.song);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      onLongPress: () {
        setState(() => _isPressed = false);
        showModalBottomSheet(
          constraints: const BoxConstraints(maxWidth: 500),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(10.0),
            ),
          ),
          isScrollControlled: true,
          context:
              widget.playerController.homeScaffoldkey.currentState!.context,
          barrierColor: Colors.transparent.withAlpha(100),
          builder: (context) => SongInfoBottomSheet(widget.song),
        ).whenComplete(() => Get.delete<SongInfoController>());
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: isTop3
                ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
                : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                gradient: isTop3
                    ? LinearGradient(
                        colors: [
                          _getMedalColor(widget.index).withValues(alpha: 0.2),
                          _getMedalColor(widget.index).withValues(alpha: 0.05),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                color: isTop3
                    ? null
                    : (_isPressed
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.05)
                        : Colors.transparent),
                borderRadius: BorderRadius.circular(14),
                border: isTop3
                    ? Border.all(
                        width: 1.5,
                        color: _getMedalColor(widget.index).withValues(alpha: 0.4),
                      )
                    : null,
                boxShadow: isTop3
                    ? [
                        BoxShadow(
                          color: _getMedalColor(widget.index).withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Number or Medal Icon
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: isTop3
                        ? Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getMedalColor(widget.index),
                                  _getMedalColor(widget.index).withValues(alpha: 0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: _getMedalColor(widget.index)
                                      .withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              _getMedalIcon(widget.index),
                              color: Colors.white,
                              size: 24,
                            ),
                          )
                        : Center(
                            child: Text(
                              '${widget.index + 1}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withValues(alpha: 0.6),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ),
                  const SizedBox(width: 14),
                  // Thumbnail with shadow
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ImageWidget(
                        song: widget.song,
                        size: 60,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Song info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.song.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.song.artist ?? '',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                        ?.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Play button
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.15),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.play_circle_filled,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      onPressed: () {
                        widget.playerController.pushSongToQueue(widget.song);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
