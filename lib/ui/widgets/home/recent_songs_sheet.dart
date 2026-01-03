import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audio_service/audio_service.dart';
import '/ui/player/player_controller.dart';
import '/ui/widgets/image_widget.dart';
import '/ui/widgets/songinfo_bottom_sheet.dart';
import '/ui/screens/Home/home_screen_controller.dart';

class RecentSongsScreen extends StatefulWidget {
  const RecentSongsScreen({super.key});

  @override
  State<RecentSongsScreen> createState() => _RecentSongsScreenState();
}

class _RecentSongsScreenState extends State<RecentSongsScreen> {
  String selectedFilter = 'All';
  late HomeScreenController homeController;

  @override
  void initState() {
    super.initState();
    homeController = Get.find<HomeScreenController>();
  }

  List<MediaItem> get filteredSongs {
    switch (selectedFilter) {
      case 'Today':
        return homeController.recentSongs.toList();
      case 'This Week':
        return homeController.recentSongs.toList();
      default:
        return homeController.recentSongs.toList();
    }
  }

  Map<String, List<MediaItem>> get groupedSongs {
    final Map<String, List<MediaItem>> grouped = {};

    if (filteredSongs.isNotEmpty) {
      grouped['Today'] = filteredSongs;
    }

    return grouped;
  }

  void deleteRecentSong(MediaItem song) {
    homeController.deleteRecentSong(song);
    setState(() {});
  }

  void clearAllRecents() {
    for (var song in homeController.recentSongs.toList()) {
      homeController.deleteRecentSong(song);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Listening History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: clearAllRecents,
            child: Text(
              'Clear',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final songs = filteredSongs;

        return Column(
          children: [
            // Filter tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildFilterChip('All', theme),
                  const SizedBox(width: 8),
                  _buildFilterChip('Today', theme),
                  const SizedBox(width: 8),
                  _buildFilterChip('This Week', theme),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Songs list
            Expanded(
              child: songs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No recent songs',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Songs you listen to will appear here',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: groupedSongs.length,
                      itemBuilder: (context, groupIndex) {
                        final dateKey = groupedSongs.keys.elementAt(groupIndex);
                        final groupSongs = groupedSongs[dateKey]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date header
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Text(
                                dateKey,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Songs in this date group
                            ...groupSongs.map((song) => InkWell(
                                  onTap: () {
                                    playerController.pushSongToQueue(song);
                                  },
                                  onLongPress: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) =>
                                          SongInfoBottomSheet(song),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        // Album art
                                        Hero(
                                          tag: 'recent_${song.id}',
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: ImageWidget(
                                                song: song, size: 56),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Song info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                song.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                song.artist ?? '',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme
                                                    .textTheme.bodyMedium
                                                    ?.copyWith(
                                                  color: theme.textTheme
                                                      .bodyMedium?.color
                                                      ?.withValues(alpha: 0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Three-dot menu
                                        IconButton(
                                          icon: const Icon(Icons.more_vert),
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (context) =>
                                                  SongInfoBottomSheet(song),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                          ],
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterChip(String label, ThemeData theme) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
