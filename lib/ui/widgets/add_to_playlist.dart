import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../services/piped_service.dart';
import '/models/media_Item_builder.dart';
import '/ui/widgets/simple_playlist_dialog.dart';
import '../../models/playlist.dart';
import 'snackbar.dart';

class AddToPlaylist extends StatelessWidget {
  const AddToPlaylist(this.songItems, {super.key});
  final List<MediaItem> songItems;

  @override
  Widget build(BuildContext context) {
    final addToPlaylistController = Get.put(AddToPlaylistController());
    // Initialize with current songs
    addToPlaylistController.setSongsToAdd(songItems);
    final isPipedLinked = Get.find<PipedServices>().isLoggedIn;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDark
                    ? Colors.black.withValues(alpha: 0.9)
                    : theme.colorScheme.surface.withValues(alpha: 0.9),
                isDark
                    ? Colors.black.withValues(alpha: 0.8)
                    : theme.colorScheme.surface.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.iconTheme.color!.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "addToPlaylist".tr,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        if (isPipedLinked)
                          Obx(() => Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface
                                      .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: theme.dividerColor
                                        .withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _buildTypeButton(context, "Piped".tr,
                                        "piped", addToPlaylistController),
                                    _buildTypeButton(context, "local".tr,
                                        "local", addToPlaylistController),
                                  ],
                                ),
                              )),
                      ],
                    ),
                  ),

                  // Create New Playlist and List
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        // Create New Playlist Button
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            // Keep using showDialog for now as SimplePlaylistDialog logic
                            // might depend on being a dialog, or convert it later
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) =>
                                  const SimplePlaylistDialog(),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.primaryColor,
                                  theme.primaryColor.withValues(alpha: 0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      theme.primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add,
                                      color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  "CreateNewPlaylist".tr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (isPipedLinked) const SizedBox(height: 8),

                        // Playlist List
                        Obx(() {
                          if (addToPlaylistController
                                  .additionInProgress.isTrue &&
                              isPipedLinked) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (addToPlaylistController.playlists.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Icon(Icons.playlist_remove,
                                        size: 48, color: theme.disabledColor),
                                    const SizedBox(height: 12),
                                    Text(
                                      "noLibPlaylist".tr,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.disabledColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: addToPlaylistController.playlists.length,
                            itemBuilder: (context, index) {
                              final playlist =
                                  addToPlaylistController.playlists[index];
                              return _buildPlaylistCard(
                                context,
                                playlist,
                                addToPlaylistController,
                                isDark,
                              );
                            },
                          );
                        }),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(BuildContext context, String label, String value,
      AddToPlaylistController controller) {
    return Obx(() {
      final isSelected = controller.playlistType.value == value;
      return GestureDetector(
        onTap: () => controller.changePlaylistType(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPlaylistCard(
    BuildContext context,
    Playlist playlist,
    AddToPlaylistController controller,
    bool isDark,
  ) {
    // Gradient palettes (matching ContentListItem)
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

    final int gradientIndex = playlist.colorIndex ??
        (playlist.playlistId.hashCode.abs() % gradientPalettes.length);
    final int iconIdx = playlist.iconIndex ?? 0;
    final gradientColors = gradientPalettes[gradientIndex];
    final selectedIcon = playlistIcons[iconIdx];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          final songExists =
              controller.songExistsInPlaylist[playlist.playlistId] ?? false;

          if (songExists) {
            // Remove songs from playlist
            controller
                .removeSongsFromPlaylist(
                    songItems, playlist.playlistId, context)
                .then((result) {
              if (!context.mounted) return;

              final removed = result['removed'] as int;
              final success = result['success'] as bool;

              String message;
              if (success && removed > 0) {
                message = removed == 1
                    ? "Song removed from playlist"
                    : "$removed songs removed from playlist";
              } else {
                message = "errorOccuredAlert".tr;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                  snackbar(context, message, size: SanckBarSize.MEDIUM));
              Navigator.of(context).pop();
            });
          } else {
            // Add songs to playlist
            controller
                .addSongsToPlaylist(songItems, playlist.playlistId, context)
                .then((result) {
              if (!context.mounted) return;

              final added = result['added'] as int;
              final skipped = result['skipped'] as int;
              final success = result['success'] as bool;

              String message;
              if (!success && added == 0) {
                message = "errorOccuredAlert".tr;
              } else if (added > 0 && skipped == 0) {
                message = "songAddedToPlaylistAlert".tr;
              } else if (added > 0 && skipped > 0) {
                message = "$added added, $skipped already in playlist";
              } else if (skipped > 0) {
                message = "songAlreadyExists".tr;
              } else {
                message = "errorOccuredAlert".tr;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                  snackbar(context, message, size: SanckBarSize.MEDIUM));
              Navigator.of(context).pop();
            });
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(4), // Inner padding
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Gradient Icon Container
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    selectedIcon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Playlist info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      playlist.isPipedPlaylist
                          ? "Piped Playlist"
                          : "Local Playlist",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ),

              // Action Icon - Show checkmark if song exists, otherwise add icon
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Obx(() {
                  final songExists =
                      controller.songExistsInPlaylist[playlist.playlistId] ??
                          false;

                  return Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: songExists
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.transparent,
                      border: Border.all(
                        color: songExists
                            ? Colors.green
                            : Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      songExists ? Icons.check_rounded : Icons.add_rounded,
                      color: songExists
                          ? Colors.green
                          : Theme.of(context).primaryColor,
                      size: 20,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddToPlaylistController extends GetxController {
  final RxList<Playlist> playlists = RxList();
  final playlistType = "local".obs;
  final additionInProgress = false.obs;
  final RxMap<String, bool> songExistsInPlaylist = RxMap();
  List<Playlist> localPlaylists = [];
  List<Playlist> pipedPlaylists = [];
  List<MediaItem> currentSongs = [];

  AddToPlaylistController() {
    _getAllPlaylist();
  }

  Future<void> _getAllPlaylist() async {
    final plstsBox = await Hive.openBox("LibraryPlaylists");
    playlists.value = plstsBox.values
        .map((e) {
          if (!e["isCloudPlaylist"]) return Playlist.fromJson(e);
        })
        .whereType<Playlist>()
        .toList();
    localPlaylists = playlists.toList();
    final res = await Get.find<PipedServices>().getAllPlaylists();
    if (res.code == 1) {
      pipedPlaylists = res.response
          .map((item) => Playlist(
                title: item['name'],
                playlistId: item['id'],
                description: "Piped Playlist",
                thumbnailUrl: item['thumbnail'],
                isPipedPlaylist: true,
              ))
          .whereType<Playlist>()
          .toList();
    }
    await _checkSongExistence();
  }

  Future<void> refreshPlaylists() async {
    await _getAllPlaylist();
  }

  void setSongsToAdd(List<MediaItem> songs) {
    currentSongs = songs;
    _checkSongExistence();
  }

  Future<void> _checkSongExistence() async {
    if (currentSongs.isEmpty) return;

    songExistsInPlaylist.clear();

    for (final playlist in playlists) {
      if (playlist.isPipedPlaylist) {
        // Can't check piped playlists easily
        songExistsInPlaylist[playlist.playlistId] = false;
      } else {
        try {
          final plstBox = await Hive.openBox(playlist.playlistId);
          final playlistSongIds = plstBox.values
              .map((item) => item['videoId'])
              .whereType<String>()
              .toList();

          // Check if ANY of the current songs exist in this playlist
          final hasAnySong =
              currentSongs.any((song) => playlistSongIds.contains(song.id));
          songExistsInPlaylist[playlist.playlistId] = hasAnySong;

          await plstBox.close();
        } catch (e) {
          songExistsInPlaylist[playlist.playlistId] = false;
        }
      }
    }
  }

  void changePlaylistType(val) {
    playlistType.value = val;
    playlists.value = val == "piped" ? pipedPlaylists : localPlaylists;
    _checkSongExistence();
  }

  Future<Map<String, dynamic>> addSongsToPlaylist(
      List<MediaItem> songs, String playlistId, BuildContext context) async {
    additionInProgress.value = true;
    int addedCount = 0;
    int skippedCount = 0;

    if (playlistType.value == "local") {
      final plstBox = await Hive.openBox(playlistId);
      final playlistSongIds = plstBox.values
          .map((item) => item['videoId'])
          .whereType<String>()
          .toList();

      for (MediaItem element in songs) {
        if (!playlistSongIds.contains(element.id)) {
          await plstBox.add(MediaItemBuilder.toJson(element));
          addedCount++;
        } else {
          skippedCount++;
        }
      }
      await plstBox.close();
    } else {
      final videosId = songs.map((e) => e.id).toList();
      final res =
          await Get.find<PipedServices>().addToPlaylist(playlistId, videosId);
      additionInProgress.value = false;
      return {
        'success': res.code == 1,
        'added': res.code == 1 ? songs.length : 0,
        'skipped': 0,
      };
    }

    additionInProgress.value = false;
    await _checkSongExistence();

    return {
      'success': addedCount > 0,
      'added': addedCount,
      'skipped': skippedCount,
    };
  }

  Future<Map<String, dynamic>> removeSongsFromPlaylist(
      List<MediaItem> songs, String playlistId, BuildContext context) async {
    additionInProgress.value = true;
    int removedCount = 0;

    if (playlistType.value == "local") {
      final plstBox = await Hive.openBox(playlistId);
      final keysToDelete = <dynamic>[];

      // Find all keys that match the song IDs
      for (var key in plstBox.keys) {
        final item = plstBox.get(key);
        if (item != null && item is Map) {
          final videoId = item['videoId'];
          if (songs.any((song) => song.id == videoId)) {
            keysToDelete.add(key);
          }
        }
      }

      // Delete all matching songs
      for (var key in keysToDelete) {
        await plstBox.delete(key);
        removedCount++;
      }

      await plstBox.close();
    } else {
      // Piped playlists - would need API support for removal
      additionInProgress.value = false;
      return {
        'success': false,
        'removed': 0,
      };
    }

    additionInProgress.value = false;
    await _checkSongExistence();

    return {
      'success': removedCount > 0,
      'removed': removedCount,
    };
  }

  // Future<bool> addSongToPlaylist(
  //     MediaItem song, String playlistId, BuildContext context) async {
  //   if (playlistType.value == "local") {
  //     final plstBox = await Hive.openBox(playlistId);
  //     if (!plstBox.containsKey(song.id)) {
  //       plstBox.put(song.id, MediaItemBuilder.toJson(song));
  //       plstBox.close();
  //       return true;
  //     } else {
  //       plstBox.close();
  //       return false;
  //     }
  //   } else {
  //     additionInProgress.value = true;

  //     final res =
  //         await Get.find<PipedServices>().addToPlaylist(playlistId, song.id);
  //     additionInProgress.value = false;
  //     return (res.code == 1);
  //   }
  // }
}
