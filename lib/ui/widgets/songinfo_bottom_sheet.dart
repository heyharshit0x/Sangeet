import 'dart:ui';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '/ui/widgets/lyrics_dialog.dart';

import '../../services/downloader.dart';
import '../screens/Playlist/playlist_screen_controller.dart';
import '../screens/Settings/settings_screen_controller.dart';
import '/utils/helper.dart';
import '/services/piped_service.dart';
import '/ui/widgets/sleep_timer_bottom_sheet.dart';
import '/ui/player/player_controller.dart';
import '../screens/Library/library_controller.dart';
import '/ui/widgets/add_to_playlist.dart';
import '/ui/widgets/snackbar.dart';
import '../../models/media_Item_builder.dart';
import '../../models/playlist.dart';
import '../navigator.dart';
import 'song_download_btn.dart';
import 'image_widget.dart';
import 'song_info_dialog.dart';

class SongInfoBottomSheet extends StatelessWidget {
  const SongInfoBottomSheet(this.song,
      {super.key,
      this.playlist,
      this.calledFromPlayer = false,
      this.calledFromQueue = false});
  final MediaItem song;
  final Playlist? playlist;
  final bool calledFromPlayer;
  final bool calledFromQueue;

  @override
  Widget build(BuildContext context) {
    final songInfoController =
        Get.put(SongInfoController(song, calledFromPlayer));
    final playerController = Get.find<PlayerController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDark
                    ? Colors.black.withValues(alpha: 0.95)
                    : Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.95),
                isDark
                    ? Colors.black.withValues(alpha: 0.85)
                    : Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.85),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: Get.mediaQuery.padding.bottom),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Song header with glassmorphic card
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.15),
                                Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withValues(alpha: 0.08),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.15)
                                  : Colors.black.withValues(alpha: 0.1),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Album art with shadow
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: ImageWidget(
                                    song: song,
                                    size: 60,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      song.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      song.artist!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
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
                              const SizedBox(width: 8),
                              Row(
                                children: [
                                  calledFromPlayer
                                      ? _GlassIconButton(
                                          icon: PhosphorIconsRegular.info,
                                          onPressed: () => showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (context) =>
                                                SongInfoDialog(
                                              song: song,
                                            ),
                                          ),
                                        )
                                      : Obx(() => _GlassIconButton(
                                            icon: songInfoController
                                                    .isCurrentSongFav.isFalse
                                                ? PhosphorIconsRegular.heart
                                                : PhosphorIconsFill.heart,
                                            onPressed:
                                                songInfoController.toggleFav,
                                            color: songInfoController
                                                    .isCurrentSongFav.isTrue
                                                ? Colors.red
                                                : null,
                                          )),
                                  const SizedBox(width: 8),
                                  SongDownloadButton(
                                    song_: song,
                                    isDownloadingDoneCallback:
                                        songInfoController.setDownloadStatus,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Menu items
                  _buildMenuItem(
                    context,
                    icon: PhosphorIconsRegular.broadcast,
                    title: "startRadio".tr,
                    onTap: () {
                      Navigator.of(context).pop();
                      playerController.startRadio(song);
                    },
                  ),
                  (calledFromPlayer || calledFromQueue)
                      ? const SizedBox.shrink()
                      : _buildMenuItem(
                          context,
                          icon: PhosphorIconsRegular.skipForward,
                          title: "playNext".tr,
                          onTap: () {
                            Navigator.of(context).pop();
                            playerController.playNext(song);
                            ScaffoldMessenger.of(context).showSnackBar(snackbar(
                                context, "${"playnextMsg".tr} ${song.title}",
                                size: SanckBarSize.BIG));
                          },
                        ),
                  _buildMenuItem(
                    context,
                    icon: PhosphorIconsRegular.playlist,
                    title: "addToPlaylist".tr,
                    onTap: () {
                      Navigator.of(context).pop();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => AddToPlaylist([song]),
                      ).whenComplete(
                          () => Get.delete<AddToPlaylistController>());
                    },
                  ),
                  (calledFromPlayer || calledFromQueue)
                      ? const SizedBox.shrink()
                      : _buildMenuItem(
                          context,
                          icon: PhosphorIconsRegular.queue,
                          title: "enqueueSong".tr,
                          onTap: () {
                            playerController.enqueueSong(song).whenComplete(() {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                  snackbar(context, "songEnqueueAlert".tr,
                                      size: SanckBarSize.MEDIUM));
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                  song.extras!['album'] != null
                      ? _buildMenuItem(
                          context,
                          icon: PhosphorIconsRegular.disc,
                          title: "goToAlbum".tr,
                          onTap: () {
                            Navigator.of(context).pop();
                            if (calledFromPlayer) {
                              playerController.playerPanelController.close();
                            }
                            if (calledFromQueue) {
                              playerController.playerPanelController.close();
                            }
                            Get.toNamed(ScreenNavigationSetup.albumScreen,
                                id: ScreenNavigationSetup.id,
                                arguments: (null, song.extras!['album']['id']));
                          },
                        )
                      : const SizedBox.shrink(),
                  Obx(
                    () {
                      if (playerController.currentSong.value?.id == song.id) {
                        return _buildMenuItem(
                          context,
                          icon: PhosphorIconsRegular.textAlignLeft,
                          title: "Show Lyrics",
                          onTap: () {
                            Navigator.of(context).pop();
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const LyricsDialog(),
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  ...artistWidgetList(song, context),
                  (playlist != null &&
                              !playlist!.isCloudPlaylist &&
                              !(playlist!.playlistId == "LIBRP")) ||
                          (playlist != null && playlist!.isPipedPlaylist)
                      ? _buildMenuItem(
                          context,
                          icon: PhosphorIconsRegular.trash,
                          title: playlist!.title == "Library Songs"
                              ? "removeFromLib".tr
                              : "removeFromPlaylist".tr,
                          onTap: () {
                            Navigator.of(context).pop();
                            songInfoController
                                .removeSongFromPlaylist(song, playlist!)
                                .whenComplete(() =>
                                    ScaffoldMessenger.of(Get.context!)
                                        .showSnackBar(snackbar(Get.context!,
                                            "Removed from ${playlist!.title}",
                                            size: SanckBarSize.MEDIUM)));
                          },
                        )
                      : const SizedBox.shrink(),
                  (calledFromQueue)
                      ? _buildMenuItem(context,
                          icon: PhosphorIconsRegular.trash,
                          title: "removeFromQueue".tr, onTap: () {
                          Navigator.of(context).pop();
                          if (playerController.currentSong.value!.id ==
                              song.id) {
                            ScaffoldMessenger.of(context).showSnackBar(snackbar(
                                context, "songRemovedfromQueueCurrSong".tr,
                                size: SanckBarSize.BIG));
                          } else {
                            playerController.removeFromQueue(song);
                            ScaffoldMessenger.of(context).showSnackBar(snackbar(
                                context, "songRemovedfromQueue".tr,
                                size: SanckBarSize.MEDIUM));
                          }
                        })
                      : const SizedBox.shrink(),
                  Obx(
                    () => (songInfoController.isDownloaded.isTrue &&
                            (playlist?.playlistId != "SongDownloads" &&
                                playlist?.playlistId != "SongsCache"))
                        ? _buildMenuItem(
                            context,
                            icon: PhosphorIconsRegular.trash,
                            title: "deleteDownloadData".tr,
                            onTap: () {
                              Navigator.of(context).pop();
                              final box = Hive.box("SongDownloads");
                              Get.find<LibrarySongsController>()
                                  .removeSong(song, true,
                                      url: box.get(song.id)['url'])
                                  .then((value) async {
                                box.delete(song.id).then((value) {
                                  if (playlist != null) {
                                    Get.find<PlaylistScreenController>(
                                            tag: Key(playlist!.playlistId)
                                                .hashCode
                                                .toString())
                                        .checkDownloadStatus();
                                  }
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        snackbar(context,
                                            "deleteDownloadedDataAlert".tr,
                                            size: SanckBarSize.BIG));
                                  }
                                });
                              });
                            },
                          )
                        : const SizedBox.shrink(),
                  ),
                  // Open in section
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.open_with,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withValues(alpha: 0.7),
                          size: 22,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            "openIn".tr,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        _GlassIconButton(
                          icon: PhosphorIconsRegular.youtubeLogo,
                          onPressed: () {
                            launchUrl(Uri.parse(
                                "https://youtube.com/watch?v=${song.id}"));
                          },
                        ),
                        const SizedBox(width: 8),
                        _GlassIconButton(
                          icon: PhosphorIconsRegular.playCircle,
                          onPressed: () {
                            launchUrl(Uri.parse(
                                "https://music.youtube.com/watch?v=${song.id}"));
                          },
                        ),
                      ],
                    ),
                  ),
                  if (calledFromPlayer)
                    _buildMenuItem(
                      context,
                      icon: PhosphorIconsRegular.timer,
                      title: "sleepTimer".tr,
                      onTap: () {
                        Navigator.of(context).pop();
                        showModalBottomSheet(
                          constraints: const BoxConstraints(maxWidth: 500),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10.0)),
                          ),
                          isScrollControlled: true,
                          context: playerController
                              .homeScaffoldkey.currentState!.context,
                          barrierColor: Colors.transparent.withAlpha(100),
                          builder: (context) => const SleepTimerBottomSheet(),
                        );
                      },
                    ),
                  _buildMenuItem(
                    context,
                    icon: PhosphorIconsRegular.shareNetwork,
                    title: "shareSong".tr,
                    onTap: () =>
                        Share.share("https://youtube.com/watch?v=${song.id}"),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withValues(alpha: 0.7),
                size: 22,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> artistWidgetList(MediaItem song, BuildContext context) {
    final artistList = [];
    final artists = song.extras!['artists'];
    if (artists != null) {
      for (dynamic each in artists) {
        if (each.containsKey("id") && each['id'] != null) artistList.add(each);
      }
    }
    return artistList.isNotEmpty
        ? artistList
            .map((e) => _buildMenuItem(
                  context,
                  icon: PhosphorIconsRegular.user,
                  title: "${"viewArtist".tr} (${e['name']})",
                  onTap: () async {
                    Navigator.of(context).pop();
                    if (calledFromPlayer) {
                      Get.find<PlayerController>()
                          .playerPanelController
                          .close();
                    }
                    if (calledFromQueue) {
                      final playerController = Get.find<PlayerController>();
                      playerController.playerPanelController.close();
                    }
                    await Get.toNamed(ScreenNavigationSetup.artistScreen,
                        id: ScreenNavigationSetup.id,
                        preventDuplicates: true,
                        arguments: [true, e['id']]);
                  },
                ))
            .toList()
        : [const SizedBox.shrink()];
  }
}

class _GlassIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  const _GlassIconButton({
    required this.icon,
    required this.onPressed,
    this.color,
  });

  @override
  State<_GlassIconButton> createState() => __GlassIconButtonState();
}

class __GlassIconButtonState extends State<_GlassIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.color?.withValues(alpha: 0.2) ??
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.color?.withValues(alpha: 0.3) ??
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(
            widget.icon,
            size: 20,
            color: widget.color ?? Theme.of(context).iconTheme.color,
          ),
        ),
      ),
    );
  }
}

class SongInfoController extends GetxController
    with RemoveSongFromPlaylistMixin {
  final isCurrentSongFav = false.obs;
  final MediaItem song;
  final bool calledFromPlayer;
  List artistList = [].obs;
  final isDownloaded = false.obs;
  SongInfoController(this.song, this.calledFromPlayer) {
    _setInitStatus(song);
  }
  _setInitStatus(MediaItem song) async {
    isDownloaded.value = Hive.box("SongDownloads").containsKey(song.id);
    isCurrentSongFav.value =
        (await Hive.openBox("LIBFAV")).containsKey(song.id);
    final artists = song.extras!['artists'];
    if (artists != null) {
      for (dynamic each in artists) {
        if (each.containsKey("id") && each['id'] != null) artistList.add(each);
      }
    }
  }

  void setDownloadStatus(bool isDownloaded_) {
    if (isDownloaded_) {
      Future.delayed(const Duration(milliseconds: 100),
          () => isDownloaded.value = isDownloaded_);
    }
  }

  Future<void> toggleFav() async {
    if (calledFromPlayer) {
      final cntrl = Get.find<PlayerController>();
      if (cntrl.currentSong.value == song) {
        cntrl.toggleFavourite();
        isCurrentSongFav.value = !isCurrentSongFav.value;
        return;
      }
    }
    final box = await Hive.openBox("LIBFAV");
    isCurrentSongFav.isFalse
        ? box.put(song.id, MediaItemBuilder.toJson(song))
        : box.delete(song.id);
    isCurrentSongFav.value = !isCurrentSongFav.value;
    if (Get.find<SettingsScreenController>()
            .autoDownloadFavoriteSongEnabled
            .isTrue &&
        isCurrentSongFav.isTrue) {
      Get.find<Downloader>().download(song);
    }
  }
}

mixin RemoveSongFromPlaylistMixin {
  Future<void> removeSongFromPlaylist(MediaItem item, Playlist playlist) async {
    final box = await Hive.openBox(playlist.playlistId);
    //Library songs case
    if (playlist.playlistId == "SongsCache") {
      if (!box.containsKey(item.id)) {
        Hive.box("SongDownloads").delete(item.id);
        Get.find<LibrarySongsController>().removeSong(item, true);
      } else {
        Get.find<LibrarySongsController>().removeSong(item, false);
        box.delete(item.id);
      }
    } else if (playlist.playlistId == "SongDownloads") {
      box.delete(item.id);
      Get.find<LibrarySongsController>().removeSong(item, true);
    } else if (!playlist.isPipedPlaylist) {
      //Other playlist song case
      final index =
          box.values.toList().indexWhere((ele) => ele['videoId'] == item.id);
      await box.deleteAt(index);
    }

    // this try catch block is to handle the case when song is removed from libsongs sections
    try {
      final plstCntroller = Get.find<PlaylistScreenController>(
          tag: Key(playlist.playlistId).hashCode.toString());
      if (playlist.isPipedPlaylist) {
        final res = await Get.find<PipedServices>()
            .getPlaylistSongs(playlist.playlistId);
        final songIndex = res.indexWhere((element) => element.id == item.id);
        if (songIndex != -1) {
          final res = await Get.find<PipedServices>()
              .removeFromPlaylist(playlist.playlistId, songIndex);
          if (res.code == 1) {
            plstCntroller.addNRemoveItemsinList(item, action: 'remove');
          }
        }
        return;
      }

      try {
        plstCntroller.addNRemoveItemsinList(item, action: 'remove');
        // ignore: empty_catches
      } catch (e) {}
    } catch (e) {
      printERROR("Some Error in removeSongFromPlaylist (might irrelavant): $e");
    }

    if (playlist.playlistId == "SongDownloads" ||
        playlist.playlistId == "SongsCache") {
      return;
    }
    box.close();
  }
}
