import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sangeet/models/playling_from.dart';
import 'package:sangeet/ui/widgets/playlist_album_scroll_behaviour.dart';
import 'package:share_plus/share_plus.dart';
import 'package:widget_marquee/widget_marquee.dart';

import '../../../services/downloader.dart';
import '../../player/player_controller.dart';
import '../../widgets/loader.dart';
import '../../widgets/snackbar.dart';
import '../../widgets/song_list_tile.dart';
import '../../widgets/songinfo_bottom_sheet.dart';
import '../../widgets/sort_widget.dart';
import '../../widgets/album/modern_album_header.dart';
import '../../widgets/album/modern_album_actions.dart';
import 'album_screen_controller.dart';

class AlbumScreen extends StatelessWidget {
  const AlbumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tag = key.hashCode.toString();
    final albumController = (Get.isRegistered<AlbumScreenController>(tag: tag))
        ? Get.find<AlbumScreenController>(tag: tag)
        : Get.put(AlbumScreenController(), tag: tag);
    final size = MediaQuery.of(context).size;
    final playerController = Get.find<PlayerController>();
    final landscape = size.width > size.height;
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          final scrollOffset = scrollInfo.metrics.pixels;

          if (landscape) {
            albumController.scrollOffset.value = 0;
          } else {
            albumController.scrollOffset.value = scrollOffset;
          }
          if (scrollOffset > 270 || (landscape && scrollOffset > 225)) {
            albumController.appBarTitleVisible.value = true;
          } else {
            albumController.appBarTitleVisible.value = false;
          }
          return true;
        },
        child: Stack(
          children: [
            // Modern Album Header with blurred background
            Obx(
              () => albumController.isContentFetched.isTrue
                  ? ModernAlbumHeader(
                      albumTitle: albumController.album.value.title,
                      albumDescription: albumController.album.value.description,
                      artists: albumController.album.value.artists
                              ?.map((e) => e['name'])
                              .join(", ") ??
                          "",
                      thumbnailUrl: albumController.album.value.thumbnailUrl,
                      scrollOffset: albumController.scrollOffset.value,
                      isLandscape: landscape,
                    )
                  : SizedBox(
                      height: size.width,
                      width: size.width,
                    ),
            ),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 10,
                      left: 10,
                      right: 10),
                  height: 80,
                  child: Center(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: IconButton(
                              tooltip: "back".tr,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.arrow_back_ios)),
                        ),
                        Expanded(
                          child: Obx(
                            () => Marquee(
                              delay: const Duration(milliseconds: 300),
                              duration: const Duration(seconds: 5),
                              id: "${albumController.album.value.title.hashCode.toString()}_appbar",
                              child: Text(
                                albumController.appBarTitleVisible.isTrue
                                    ? albumController.album.value.title
                                    : "",
                                maxLines: 1,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 800,
                      ),
                      child: Obx(
                        () => ScrollConfiguration(
                          behavior: PlaylistAlbumScrollBehaviour(),
                          child: ListView.builder(
                            padding: EdgeInsets.only(
                              top: albumController.isSearchingOn.isTrue
                                  ? 0
                                  : landscape
                                      ? 150
                                      : 200,
                              bottom: 200,
                            ),
                            itemCount: albumController.songList.isEmpty
                                ? 4
                                : albumController.songList.length + 3,
                            itemBuilder: (_, index) {
                              if (index == 0) {
                                // Modern Album Info Card
                                return AlbumInfoCard(
                                  albumTitle: albumController.album.value.title,
                                  albumDescription:
                                      albumController.album.value.description,
                                  artists: albumController.album.value.artists
                                          ?.map((e) => e['name'])
                                          .join(", ") ??
                                      "",
                                  thumbnailUrl:
                                      albumController.album.value.thumbnailUrl,
                                );
                              } else if (index == 1) {
                                // Modern Album Actions
                                return GetX<Downloader>(builder: (downloader) {
                                  final id =
                                      albumController.album.value.browseId;
                                  final isDownloading = downloader.playlistQueue
                                          .containsKey(id) &&
                                      downloader.currentPlaylistId.toString() ==
                                          id;
                                  final downloadProgress = downloader
                                      .playlistDownloadingProgress.value;

                                  return ModernAlbumActions(
                                    onPlayAll: () {
                                      playerController.playPlayListSong(
                                        List<MediaItem>.from(
                                            albumController.songList),
                                        0,
                                        playfrom: PlaylingFrom(
                                          name:
                                              albumController.album.value.title,
                                          type: PlaylingFromType.ALBUM,
                                        ),
                                      );
                                    },
                                    onShuffle: () {
                                      playerController.playPlayListSong(
                                        List<MediaItem>.from(
                                            albumController.songList)
                                          ..shuffle(),
                                        0,
                                        playfrom: PlaylingFrom(
                                          name:
                                              albumController.album.value.title,
                                          type: PlaylingFromType.ALBUM,
                                        ),
                                      );
                                    },
                                    onBookmark: () {
                                      final add = albumController
                                          .isAddedToLibrary.isFalse;
                                      albumController
                                          .addNremoveFromLibrary(
                                              albumController.album.value,
                                              add: add)
                                          .then((value) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackbar(
                                          context,
                                          value
                                              ? add
                                                  ? "albumBookmarkAddAlert".tr
                                                  : "albumBookmarkRemoveAlert"
                                                      .tr
                                              : "operationFailed".tr,
                                          size: SanckBarSize.MEDIUM,
                                        ));
                                      });
                                    },
                                    onDownload: () {
                                      if (albumController.isDownloaded.isTrue) {
                                        return;
                                      }
                                      downloader.downloadPlaylist(
                                        id,
                                        albumController.songList.toList(),
                                      );
                                    },
                                    onShare: () {
                                      Share.share(
                                          "https://youtube.com/playlist?list=${albumController.album.value.audioPlaylistId}");
                                    },
                                    onEnqueue: () {
                                      Get.find<PlayerController>()
                                          .enqueueSongList(
                                              albumController.songList.toList())
                                          .whenComplete(() {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackbar(
                                            context,
                                            "songEnqueueAlert".tr,
                                            size: SanckBarSize.MEDIUM,
                                          ));
                                        }
                                      });
                                    },
                                    isBookmarked:
                                        albumController.isAddedToLibrary.value,
                                    isDownloaded:
                                        albumController.isDownloaded.value,
                                    isDownloading: isDownloading,
                                    downloadProgress: downloadProgress,
                                    totalSongs: albumController.songList.length,
                                  );
                                });
                              } else if (index == 2) {
                                return SizedBox(
                                    height: albumController.isSearchingOn.isTrue
                                        ? 60
                                        : 40,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15.0, right: 10),
                                      child: Obx(
                                        () => SortWidget(
                                          tag: albumController
                                              .album.value.browseId,
                                          screenController: albumController,
                                          isSearchFeatureRequired: true,
                                          itemCountTitle:
                                              "${albumController.songList.length}",
                                          itemIcon: Icons.music_note,
                                          titleLeftPadding: 9,
                                          requiredSortTypes:
                                              buildSortTypeSet(false, true),
                                          onSort: albumController.onSort,
                                          onSearch: albumController.onSearch,
                                          onSearchClose:
                                              albumController.onSearchClose,
                                          onSearchStart:
                                              albumController.onSearchStart,
                                          startAdditionalOperation:
                                              albumController
                                                  .startAdditionalOperation,
                                          selectAll: albumController.selectAll,
                                          performAdditionalOperation:
                                              albumController
                                                  .performAdditionalOperation,
                                          cancelAdditionalOperation:
                                              albumController
                                                  .cancelAdditionalOperation,
                                        ),
                                      ),
                                    ));
                              } else if (albumController
                                      .isContentFetched.isFalse ||
                                  albumController.songList.isEmpty) {
                                return SizedBox(
                                  height: 300,
                                  child: Center(
                                    child:
                                        albumController.isContentFetched.isFalse
                                            ? const LoadingIndicator()
                                            : Text(
                                                "emptyPlaylist".tr,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall,
                                              ),
                                  ),
                                );
                              }

                              return Padding(
                                padding:
                                    const EdgeInsets.only(left: 20.0, right: 5),
                                child: SongListTile(
                                    onTap: () {
                                      playerController.playPlayListSong(
                                          List<MediaItem>.from(
                                              albumController.songList),
                                          index - 3,
                                          playfrom: PlaylingFrom(
                                              name: albumController
                                                  .album.value.title,
                                              type: PlaylingFromType.ALBUM));
                                    },
                                    song: albumController.songList[index - 3],
                                    isPlaylistOrAlbum: true,
                                    thumbReplacementWithIndex: true,
                                    index: index - 2),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTitleSubTitle(
      BuildContext context, AlbumScreenController albumController) {
    final title = albumController.album.value.title;
    final description = albumController.album.value.description;
    final artists =
        albumController.album.value.artists?.map((e) => e['name']).join(", ") ??
            "";
    return AnimatedBuilder(
      animation: albumController.animationController,
      builder: (context, child) {
        return SizedBox(
          height: albumController.heightAnimation.value,
          child: Transform.scale(
              scale: albumController.scaleAnimation.value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 25.0, bottom: 10, right: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Marquee(
              delay: const Duration(milliseconds: 300),
              duration: const Duration(seconds: 5),
              id: title.hashCode.toString(),
              child: Text(
                title.length > 50 ? title.substring(0, 50) : title,
                maxLines: 1,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontSize: 30),
              ),
            ),
            Text(
              description ?? "",
              maxLines: 1,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Marquee(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(seconds: 5),
                id: artists.hashCode.toString(),
                child: Text(
                  artists,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future openBottomSheet(BuildContext context, MediaItem song) {
    return showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: 500),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
      ),
      isScrollControlled: true,
      context: context,
      barrierColor: Colors.transparent.withAlpha(100),
      builder: (context) => SongInfoBottomSheet(song),
    ).whenComplete(() => Get.delete<SongInfoController>());
  }
}
