import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/Library/library_controller.dart';
import '../../models/playlist.dart';

/// Playlist dialog with premium UI and working text input!
class SimplePlaylistDialog extends StatefulWidget {
  final bool renamePlaylist;
  final Playlist? playlist;

  const SimplePlaylistDialog({
    super.key,
    this.renamePlaylist = false,
    this.playlist,
  });

  @override
  State<SimplePlaylistDialog> createState() => _SimplePlaylistDialogState();
}

class _SimplePlaylistDialogState extends State<SimplePlaylistDialog> {
  late TextEditingController _textController;
  int selectedIconIndex = 0;
  int selectedColorIndex = 0;

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

  final List<List<Color>> colorGradients = [
    [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],
    [const Color(0xFFFF6B9D), const Color(0xFFC239B3)],
    [const Color(0xFF00C6FF), const Color(0xFF0072FF)],
    [const Color(0xFF11998E), const Color(0xFF38EF7D)],
    [const Color(0xFFFF6B6B), const Color(0xFFFFE66D)],
    [const Color(0xFF06B6D4), const Color(0xFF3B82F6)],
    [const Color(0xFFA855F7), const Color(0xFFEC4899)],
    [const Color(0xFFEF4444), const Color(0xFFF97316)],
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.renamePlaylist ? widget.playlist?.title ?? '' : '',
    );
    _textController.addListener(() => setState(() {}));

    // Note: Icon and color editing for existing playlists will be added in future update
    // if (widget.renamePlaylist && widget.playlist != null) {
    //   selectedIconIndex = widget.playlist!.iconIndex ?? 0;
    //   selectedColorIndex = widget.playlist!.colorIndex ?? 0;
    // }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ClipRRect(
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
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

                    // Title
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
                      child: Row(
                        children: [
                          Text(
                            widget.renamePlaylist
                                ? 'Edit Playlist'
                                : 'createNewPlaylist'.tr,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Scrollable content
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          // Text input
                          TextField(
                            controller: _textController,
                            autofocus: true,
                            textCapitalization: TextCapitalization.sentences,
                            style: theme.textTheme.bodyLarge,
                            decoration: InputDecoration(
                              hintText: 'Playlist name...',
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.disabledColor,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      theme.dividerColor.withValues(alpha: 0.1),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: theme.primaryColor,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.black.withValues(alpha: 0.02),
                            ),
                          ),

                          // Icon & Color pickers - Only for create mode
                          if (!widget.renamePlaylist) ...[
                            const SizedBox(height: 24),

                            // Icons
                            Text(
                              'Choose Icon',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 60,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: playlistIcons.length,
                                itemBuilder: (context, index) {
                                  final isSelected = selectedIconIndex == index;
                                  return GestureDetector(
                                    onTap: () => setState(
                                        () => selectedIconIndex = index),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      margin: const EdgeInsets.only(right: 12),
                                      width: 56,
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? LinearGradient(
                                                colors: colorGradients[
                                                    selectedColorIndex])
                                            : null,
                                        color: isSelected
                                            ? null
                                            : (isDark
                                                ? Colors.white
                                                    .withValues(alpha: 0.1)
                                                : Colors.black
                                                    .withValues(alpha: 0.05)),
                                        borderRadius: BorderRadius.circular(16),
                                        border: isSelected
                                            ? null
                                            : Border.all(
                                                color: isDark
                                                    ? Colors.white
                                                        .withValues(alpha: 0.1)
                                                    : Colors.black.withValues(
                                                        alpha: 0.1)),
                                      ),
                                      child: Icon(
                                        playlistIcons[index],
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark
                                                ? Colors.grey[400]
                                                : Colors.grey[600]),
                                        size: 28,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Colors
                            Text(
                              'Choose Color',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 56,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: colorGradients.length,
                                itemBuilder: (context, index) {
                                  final isSelected =
                                      selectedColorIndex == index;
                                  return GestureDetector(
                                    onTap: () => setState(
                                        () => selectedColorIndex = index),
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 12),
                                      width: 56,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            colors: colorGradients[index]),
                                        borderRadius: BorderRadius.circular(16),
                                        border: isSelected
                                            ? Border.all(
                                                color: Colors.white, width: 3)
                                            : null,
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: colorGradients[index]
                                                          [0]
                                                      .withValues(alpha: 0.5),
                                                  blurRadius: 8,
                                                  spreadRadius: 2,
                                                ),
                                              ]
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Preview
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.cardColor.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      theme.dividerColor.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: colorGradients[
                                              selectedColorIndex]),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              colorGradients[selectedColorIndex]
                                                      [0]
                                                  .withValues(alpha: 0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      playlistIcons[selectedIconIndex],
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _textController.text.isEmpty
                                              ? 'My Playlist'
                                              : _textController.text,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text('0 songs',
                                            style: theme.textTheme.bodySmall),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 30),

                          // Buttons
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    'cancel'.tr,
                                    style: TextStyle(
                                      color: theme.textTheme.bodyLarge?.color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                  decoration: widget.renamePlaylist
                                      ? BoxDecoration(
                                          color: theme.primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        )
                                      : BoxDecoration(
                                          gradient: LinearGradient(
                                              colors: colorGradients[
                                                  selectedColorIndex]),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                              BoxShadow(
                                                color: widget.renamePlaylist
                                                    ? theme.primaryColor
                                                        .withValues(alpha: 0.4)
                                                    : colorGradients[
                                                            selectedColorIndex][0]
                                                        .withValues(alpha: 0.4),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              )
                                            ]),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: () async {
                                      final controller = Get.find<
                                          LibraryPlaylistsController>();

                                      if (widget.renamePlaylist) {
                                        controller.textInputController.text =
                                            _textController.text;
                                        await controller
                                            .renamePlaylist(widget.playlist!);
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                      } else {
                                        controller.textInputController.text =
                                            _textController.text;
                                        await controller.createNewPlaylist(
                                          iconIndex: selectedIconIndex,
                                          colorIndex: selectedColorIndex,
                                        );
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                      }
                                    },
                                    child: Text(
                                      widget.renamePlaylist
                                          ? 'Save Changes'
                                          : 'create'.tr,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
      ),
    );
  }
}
