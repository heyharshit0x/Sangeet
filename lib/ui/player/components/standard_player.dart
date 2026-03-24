import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/songinfo_bottom_sheet.dart';
import '../player_controller.dart';
import 'albumart_lyrics.dart';
import 'backgroud_image.dart';
import 'lyrics_panel.dart';
import 'player_control.dart';

/// Standard player widget
///
/// This widget is used to display the player in the standard mode
///
/// It contains the album art image, lyrics switch, album art with lyrics and player controls
/// and is used in the [Player] widget
class StandardPlayer extends StatelessWidget {
  const StandardPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final PlayerController playerController = Get.find<PlayerController>();

    double playerArtImageSize =
        size.width - 60; //((size.height < 750) ? 90 : 60);
    //playerArtImageSize = playerArtImageSize > 350 ? 350 : playerArtImageSize;
    final spaceAvailableForArtImage =
        size.height - (70 + Get.mediaQuery.padding.bottom + 330);
    playerArtImageSize = playerArtImageSize > spaceAvailableForArtImage
        ? spaceAvailableForArtImage
        : playerArtImageSize;
    return Stack(
      children: [
        /// Stack first child
        /// Album art image in background covering the whole screen
        BackgroudImage(
          key: Key("${playerController.currentSong.value?.id}_background"),
          cacheHeight: 200,
        ),

        /// Stack child
        /// Blur effect on background
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Stack(
            children: [
              /// opacity effect on background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .scaffoldBackgroundColor
                        .withValues(alpha: 0.8),
                  ),
                ),
              ),

              /// used to hide queue header when player is minimized
              /// gradient to used here
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 65 + Get.mediaQuery.padding.bottom + 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).cardColor,
                        Theme.of(context).cardColor,
                        Theme.of(context).cardColor.withValues(alpha: 0.85),
                        Theme.of(context).cardColor.withValues(alpha: 0),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: const [0, 0.15, 0.4, 1],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        /// Stack child
        /// Player content in landscape mode
        Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: (context.isLandscape)
              ? GetPlatform.isDesktop
                  ?
                  // Desktop landscape: Album art | Lyrics panel | Controls
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// Left: Album art
                        SizedBox(
                          width: size.width * .30,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              bottom: 90.0,
                              top: 40,
                            ),
                            child: Center(
                              child: AlbumArtNLyrics(
                                playerArtImageSize: size.width * .25,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 15),

                        /// Middle: Lyrics panel
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40, bottom: 90),
                            child: const LyricsPanel(),
                          ),
                        ),

                        const SizedBox(width: 15),

                        /// Right: Player controls
                        SizedBox(
                            width: size.width * .28,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 10.0,
                                  right: 10,
                                  bottom: Get.mediaQuery.padding.bottom),
                              child: const PlayerControlWidget(),
                            ))
                      ],
                    )
                  :
                  // Mobile landscape: Original layout
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// Album art with lyrics in .45  of width
                        SizedBox(
                          width: size.width * .45,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              bottom: 90.0,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Center(
                                child: AlbumArtNLyrics(
                                  playerArtImageSize: size.width * .29,
                                ),
                              ),
                            ),
                          ),
                        ),

                        /// Player controls in .48 of width
                        SizedBox(
                            width: size.width * .48,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 10.0,
                                  right: 10,
                                  bottom: Get.mediaQuery.padding.bottom),
                              child: const PlayerControlWidget(),
                            ))
                      ],
                    )
              :

              /// Player content in portrait mode
              GetPlatform.isDesktop
                  ?
                  // Desktop layout: Side-by-side album art and lyrics
                  Column(
                      children: [
                        /// Top padding - reduced for more lyrics space
                        const SizedBox(
                          height: 60,
                        ),

                        /// Main content area: Album art and Lyrics panel side by side
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Left side: Album Art
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: AlbumArtNLyrics(
                                      playerArtImageSize: size.width * 0.42,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                /// Right side: Lyrics Panel
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 25),
                                    child: const LyricsPanel(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        /// Contains the player controls - moved lower
                        Padding(
                          padding: EdgeInsets.only(
                              bottom: 20 + Get.mediaQuery.padding.bottom,
                              top: 15),
                          child: Container(
                              constraints: const BoxConstraints(maxWidth: 500),
                              child: const PlayerControlWidget()),
                        )
                      ],
                    )
                  :
                  // Mobile layout: Animated with lyrics toggle
                  Column(
                      children: [
                        /// Scrollable content area
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Obx(() {
                              final showLyrics =
                                  playerController.showMobileLyrics.value;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                                child: Column(
                                  children: [
                                    /// Top padding - adjusts based on lyrics visibility
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      curve: Curves.easeInOut,
                                      height: showLyrics
                                          ? 60
                                          : (size.height < 750 ? 110 : 140),
                                    ),

                                    /// Album art - moves up when lyrics shown
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 500),
                                            child: AlbumArtNLyrics(
                                                playerArtImageSize:
                                                    playerArtImageSize)),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    /// Lyrics toggle button
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(maxWidth: 500),
                                        child: InkWell(
                                          onTap: () {
                                            playerController
                                                    .showMobileLyrics.value =
                                                !playerController
                                                    .showMobileLyrics.value;
                                            // Load lyrics when showing for the first time
                                            if (playerController
                                                    .showMobileLyrics.value &&
                                                playerController
                                                    .lyrics["synced"].isEmpty &&
                                                playerController
                                                    .lyrics['plainLyrics']
                                                    .isEmpty) {
                                              playerController
                                                  .loadLyricsForDesktop();
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .cardColor
                                                  .withValues(alpha: 0.3),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Theme.of(context)
                                                    .dividerColor
                                                    .withValues(alpha: 0.2),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  showLyrics
                                                      ? Icons
                                                          .keyboard_arrow_up_rounded
                                                      : Icons
                                                          .keyboard_arrow_down_rounded,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  showLyrics
                                                      ? 'Hide Lyrics'
                                                      : 'Show Lyrics',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// Animated Lyrics Panel
                                    AnimatedSize(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      curve: Curves.easeInOut,
                                      child: showLyrics
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 16),
                                              child: AnimatedOpacity(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                opacity: showLyrics ? 1.0 : 0.0,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 20),
                                                  child: ConstrainedBox(
                                                    constraints:
                                                        const BoxConstraints(
                                                            maxWidth: 500),
                                                    child: SizedBox(
                                                      height:
                                                          400, // Fixed height for lyrics
                                                      child:
                                                          const LyricsPanel(),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ),

                                    /// Bottom padding for scroll
                                    const SizedBox(height: 100),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),

                        /// Fixed player controls at bottom
                        Padding(
                          padding: EdgeInsets.only(
                              bottom: 80 + Get.mediaQuery.padding.bottom),
                          child: Container(
                              constraints: const BoxConstraints(maxWidth: 500),
                              child: const PlayerControlWidget()),
                        )
                      ],
                    ),
        ),

        /// Stack child
        /// Contains [Minimize button], Playing from [Album name], [More button] for current song context
        /// This is not visible in mobile devices in landscape mode
        if (!(context.isLandscape && GetPlatform.isMobile))
          Padding(
            padding: EdgeInsets.only(
                top: Get.mediaQuery.padding.top + 20, left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Minimize button
                IconButton(
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 28,
                  ),
                  onPressed: playerController.playerPanelController.close,
                ),

                /// Playing from [Album name]
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 5, right: 5),
                    child: Obx(
                      () => Column(
                        children: [
                          Text(playerController.playinfrom.value.typeString,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                          Obx(
                            () => Text(
                              "\"${playerController.playinfrom.value.nameString}\"",
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                /// More button for current song context
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    size: 25,
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      constraints: const BoxConstraints(maxWidth: 500),
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(10.0)),
                      ),
                      isScrollControlled: true,
                      context: playerController
                          .homeScaffoldkey.currentState!.context,
                      barrierColor: Colors.transparent.withAlpha(100),
                      builder: (context) => SongInfoBottomSheet(
                        playerController.currentSong.value!,
                        calledFromPlayer: true,
                      ),
                    ).whenComplete(() => Get.delete<SongInfoController>());
                  },
                ),
              ],
            ),
          )
      ],
    );
  }
}
