import 'dart:ui';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/ui/player/player_controller.dart';
import '/ui/widgets/image_widget.dart';
import '/ui/widgets/songinfo_bottom_sheet.dart';

class QuickAccessGrid extends StatelessWidget {
  final List<MediaItem> songs;

  const QuickAccessGrid({
    super.key,
    required this.songs,
  });

  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();
    final displaySongs = songs.take(6).toList();

    if (displaySongs.isEmpty) {
      return const SizedBox.shrink();
    }

    // Staggered layout - left column offset down
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column (now aligned with right)
          Expanded(
            child: Column(
              children: [
                for (int i = 0; i < displaySongs.length; i += 2)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _StaggeredCard(
                      song: displaySongs[i],
                      playerController: playerController,
                      index: i,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Right column
          Expanded(
            child: Column(
              children: [
                for (int i = 1; i < displaySongs.length; i += 2)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _StaggeredCard(
                      song: displaySongs[i],
                      playerController: playerController,
                      index: i,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StaggeredCard extends StatefulWidget {
  final MediaItem song;
  final PlayerController playerController;
  final int index;

  const _StaggeredCard({
    required this.song,
    required this.playerController,
    required this.index,
  });

  @override
  State<_StaggeredCard> createState() => __StaggeredCardState();
}

class __StaggeredCardState extends State<_StaggeredCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
          ),
          isScrollControlled: true,
          context:
              widget.playerController.homeScaffoldkey.currentState!.context,
          barrierColor: Colors.transparent.withAlpha(100),
          builder: (context) => SongInfoBottomSheet(widget.song),
        ).whenComplete(() => Get.delete<SongInfoController>());
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  width: 1,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Album art with gradient overlay
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(14),
                          bottomLeft: Radius.circular(14),
                        ),
                        child: ImageWidget(
                          song: widget.song,
                          size: 70,
                        ),
                      ),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.3),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.song.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
