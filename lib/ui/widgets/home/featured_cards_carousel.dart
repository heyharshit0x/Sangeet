import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sangeet/ui/player/player_controller.dart';
import 'package:sangeet/ui/widgets/songinfo_bottom_sheet.dart';

class FeaturedCardsCarousel extends StatelessWidget {
  final List<MediaItem> songs;
  final String sectionTitle;

  const FeaturedCardsCarousel({
    super.key,
    required this.songs,
    this.sectionTitle = 'Curated & Trending',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header (without See All)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            sectionTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
          ),
        ),
        const SizedBox(height: 12),
        // Horizontal Scrollable Cards
        SizedBox(
          height: 180,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: songs.length > 3 ? 3 : songs.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _FeaturedCard(
                song: songs[index],
                index: index,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final MediaItem song;
  final int index;

  const _FeaturedCard({
    required this.song,
    required this.index,
  });

  void _onPlay() {
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

  // Varied colors for cards
  Color _getCardColor(BuildContext context, int index) {
    final colors = [
      Theme.of(context).colorScheme.primaryContainer,
      Theme.of(context).colorScheme.secondaryContainer,
      Theme.of(context).colorScheme.tertiaryContainer,
    ];
    return colors[index % colors.length];
  }

  Color _getTextColor(BuildContext context, int index) {
    final colors = [
      Theme.of(context).colorScheme.onPrimaryContainer,
      Theme.of(context).colorScheme.onSecondaryContainer,
      Theme.of(context).colorScheme.onTertiaryContainer,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _getCardColor(context, index);
    final textColor = _getTextColor(context, index);

    return GestureDetector(
      onLongPress: _onLongPress,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 280,
          height: 180,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              if (song.artUri != null)
                CachedNetworkImage(
                  imageUrl: song.artUri.toString(),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: cardColor,
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: cardColor,
                  ),
                ),
              // Blur layer
              if (song.artUri != null)
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              // Color overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cardColor.withValues(alpha: 0.7),
                      cardColor.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      index == 0 ? 'Discover Weekly' : song.title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: textColor,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                            color: Colors.black.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Subtitle
                    Text(
                      index == 0
                          ? 'The Original slow instrumental best playlists'
                          : song.artist ?? 'Featured track',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textColor.withValues(alpha: 0.9),
                        fontSize: 14,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                            color: Colors.black.withValues(alpha: 0.2),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Action Buttons (only Play and More)
                    Row(
                      children: [
                        // Play Button
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: IconButton(
                            icon: Icon(
                              Icons.play_arrow,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 24,
                            ),
                            onPressed: _onPlay,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // More Button
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: textColor.withValues(alpha: 0.2),
                          child: IconButton(
                            icon: Icon(
                              Icons.more_horiz,
                              size: 20,
                              color: textColor,
                            ),
                            onPressed: _onLongPress,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
