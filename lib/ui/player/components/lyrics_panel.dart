import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../player_controller.dart';
import 'lyrics_widget.dart';

/// Dedicated lyrics panel for the player
/// Displays synced/plain lyrics in the right side of the player
class LyricsPanel extends StatefulWidget {
  const LyricsPanel({super.key});

  @override
  State<LyricsPanel> createState() => _LyricsPanelState();
}

class _LyricsPanelState extends State<LyricsPanel> {
  final playerController = Get.find<PlayerController>();

  @override
  void initState() {
    super.initState();
    // Listen for song changes and auto-load lyrics
    ever(playerController.currentSong, (song) {
      if (song != null) {
        // Wait a bit for lyrics to be reset, then load
        Future.delayed(const Duration(milliseconds: 100), () {
          if (playerController.lyrics["synced"].isEmpty &&
              playerController.lyrics['plainLyrics'].isEmpty) {
            playerController.loadLyricsForDesktop();
          }
        });
      }
    });

    // Load lyrics for current song if available
    if (playerController.currentSong.value != null) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (playerController.lyrics["synced"].isEmpty &&
            playerController.lyrics['plainLyrics'].isEmpty) {
          playerController.loadLyricsForDesktop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter:
              ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Reduced for performance
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10, // Reduced for performance
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                // Lyrics mode toggle header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lyrics',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Row(
                        children: [
                          // Refresh button
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 20),
                            onPressed: () {
                              // Force reload lyrics
                              playerController.lyrics.value = {
                                "synced": "",
                                "plainLyrics": ""
                              };
                              playerController.loadLyricsForDesktop();
                            },
                            tooltip: 'Refresh lyrics',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          // Lyrics mode toggle
                          Obx(() => playerController.lyrics['synced'] != null &&
                                  playerController.lyrics['synced'] != 'NA' &&
                                  playerController.lyrics['synced']
                                      .toString()
                                      .isNotEmpty
                              ? InkWell(
                                  onTap: () {
                                    playerController.lyricsMode.value =
                                        playerController.lyricsMode.value == 0
                                            ? 1
                                            : 0;
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          playerController.lyricsMode.value == 0
                                              ? Icons.sync
                                              : Icons.text_fields,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          playerController.lyricsMode.value == 0
                                              ? 'Synced'
                                              : 'Plain',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink()),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Lyrics content with vignette effect
                Expanded(
                  child: Stack(
                    children: [
                      // Lyrics widget
                      Obx(() {
                        // Check if lyrics are loading
                        if (playerController.isLyricsLoading.isTrue) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        // Check if lyrics exist
                        final hasPlainLyrics =
                            playerController.lyrics['plainLyrics'] != null &&
                                playerController.lyrics['plainLyrics'] !=
                                    'NA' &&
                                playerController.lyrics['plainLyrics']
                                    .toString()
                                    .isNotEmpty;

                        final hasSyncedLyrics =
                            playerController.lyrics['synced'] != null &&
                                playerController.lyrics['synced'] != 'NA' &&
                                playerController.lyrics['synced']
                                    .toString()
                                    .isNotEmpty;

                        // Auto-switch to plain lyrics if synced not available
                        if (!hasSyncedLyrics &&
                            hasPlainLyrics &&
                            playerController.lyricsMode.value == 0) {
                          Future.microtask(
                              () => playerController.lyricsMode.value = 1);
                        }

                        if (!hasPlainLyrics) {
                          // Fallback UI when no lyrics available
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.music_note_outlined,
                                  size: 48,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Lyrics not available',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withValues(alpha: 0.5),
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'for this song',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withValues(alpha: 0.4),
                                      ),
                                ),
                              ],
                            ),
                          );
                        }

                        // Display lyrics
                        return LyricsWidget(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        );
                      }),

                      // Vignette effect - top gradient
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 60,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Theme.of(context)
                                      .cardColor
                                      .withValues(alpha: 0.4),
                                  Theme.of(context)
                                      .cardColor
                                      .withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Vignette effect - bottom gradient
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 60,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Theme.of(context)
                                      .cardColor
                                      .withValues(alpha: 0.4),
                                  Theme.of(context)
                                      .cardColor
                                      .withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
