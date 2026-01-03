import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/services/piped_service.dart';
import '../screens/Library/library_controller.dart';
import '/ui/widgets/snackbar.dart';
import '/ui/widgets/modified_text_field.dart';
import '../../models/playlist.dart';

class CreateNRenamePlaylistPopup extends StatefulWidget {
  const CreateNRenamePlaylistPopup(
      {super.key,
      this.isCreateNadd = false,
      this.songItems,
      this.renamePlaylist = false,
      this.playlist});
  final bool isCreateNadd;
  final bool renamePlaylist;
  final List<MediaItem>? songItems;
  final Playlist? playlist;

  @override
  State<CreateNRenamePlaylistPopup> createState() =>
      _CreateNRenamePlaylistPopupState();
}

class _CreateNRenamePlaylistPopupState
    extends State<CreateNRenamePlaylistPopup> {
  int selectedIconIndex = 0;
  int selectedColorIndex = 0;
  String _previewText = "";

  // Icon options
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

  // Color gradients
  final List<List<Color>> colorGradients = [
    [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)], // Purple
    [const Color(0xFFFF6B9D), const Color(0xFFC239B3)], // Pink
    [const Color(0xFF00C6FF), const Color(0xFF0072FF)], // Blue
    [const Color(0xFF11998E), const Color(0xFF38EF7D)], // Green
    [const Color(0xFFFF6B6B), const Color(0xFFFFE66D)], // Sunset
    [const Color(0xFF06B6D4), const Color(0xFF3B82F6)], // Sky
    [const Color(0xFFA855F7), const Color(0xFFEC4899)], // Violet
    [const Color(0xFFEF4444), const Color(0xFFF97316)], // Fire
  ];

  @override
  void initState() {
    super.initState();
    // Listen to text changes for preview
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<LibraryPlaylistsController>();
      controller.textInputController.addListener(() {
        if (mounted) {
          setState(() {
            _previewText = controller.textInputController.text;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final librPlstCntrller = Get.find<LibraryPlaylistsController>();
    librPlstCntrller.changeCreationMode("local");
    if (!widget.renamePlaylist) {
      librPlstCntrller.textInputController.text = "";
      // Initialize preview text for rename mode
      _previewText = widget.playlist?.title ?? "";
    } else {
      librPlstCntrller.textInputController.text = widget.playlist!.title;
      _previewText = widget.playlist!.title;
    }
    final isPipedLinked = Get.find<PipedServices>().isLoggedIn;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.3),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                _buildDragHandle(context),

                // Header
                _buildHeader(context),

                // Text input
                _buildGlassmorphicInput(context, librPlstCntrller),

                // Piped/Local mode selector (only for create, not rename)
                if (isPipedLinked && !widget.renamePlaylist)
                  _buildModeSelector(context, librPlstCntrller),

                // Icon picker (only for create, not rename)
                if (!widget.renamePlaylist) _buildIconPicker(context),

                // Color palette (only for create, not rename)
                if (!widget.renamePlaylist) _buildColorPalette(context),

                // Preview card (only for create, not rename)
                if (!widget.renamePlaylist)
                  _buildPreviewCard(context, librPlstCntrller),

                // Buttons
                _buildButtons(context, librPlstCntrller, isPipedLinked),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[600] : Colors.grey[400],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.renamePlaylist
                ? "renamePlaylist".tr
                : "CreateNewPlaylist".tr,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassmorphicInput(
      BuildContext context, LibraryPlaylistsController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ModifiedTextField(
        controller: controller.textInputController,
        autofocus: !widget.renamePlaylist,
        textCapitalization: TextCapitalization.sentences,
        cursorColor: Theme.of(context).textTheme.bodyLarge?.color,
        decoration: InputDecoration(
          hintText: "Playlist name...",
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintStyle: TextStyle(
            color:
                Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector(
      BuildContext context, LibraryPlaylistsController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _buildModeOption(
                context,
                "Piped",
                "piped",
                controller.playlistCreationMode.value == "piped",
                () => controller.changeCreationMode("piped"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModeOption(
                context,
                "Local",
                "local",
                controller.playlistCreationMode.value == "local",
                () => controller.changeCreationMode("local"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeOption(BuildContext context, String label, String value,
      bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorGradients[selectedColorIndex][0].withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? colorGradients[selectedColorIndex][0]
                : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[700]!
                    : Colors.grey[300]!),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? colorGradients[selectedColorIndex][0]
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconPicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            "Choose Icon",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: playlistIcons.length,
            itemBuilder: (context, index) {
              final isSelected = selectedIconIndex == index;
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return GestureDetector(
                onTap: () => setState(() => selectedIconIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: 56,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: colorGradients[selectedColorIndex],
                          )
                        : null,
                    color: isSelected
                        ? null
                        : (isDark ? Colors.grey[800] : Colors.grey[200]),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? null
                        : Border.all(
                            color:
                                isDark ? Colors.grey[700]! : Colors.grey[300]!,
                          ),
                  ),
                  child: Icon(
                    playlistIcons[index],
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.grey[300] : Colors.grey[700]),
                    size: 28,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorPalette(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text(
            "Choose Color",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: colorGradients.length,
            itemBuilder: (context, index) {
              final isSelected = selectedColorIndex == index;
              return GestureDetector(
                onTap: () => setState(() => selectedColorIndex = index),
                child: Container(
                  width: 50,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: colorGradients[index],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: colorGradients[index][0].withValues(alpha: 0.5),
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
      ],
    );
  }

  Widget _buildPreviewCard(
      BuildContext context, LibraryPlaylistsController controller) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Preview",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Preview thumbnail
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colorGradients[selectedColorIndex],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  playlistIcons[selectedIconIndex],
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              // Preview text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _previewText.isEmpty ? "My Playlist" : _previewText,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "0 songs",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context,
      LibraryPlaylistsController controller, bool isPipedLinked) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Cancel button
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text("cancel".tr),
            ),
          ),
          const SizedBox(width: 12),
          // Create/Rename button
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colorGradients[selectedColorIndex],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: colorGradients[selectedColorIndex][0]
                            .withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _handleCreate(context, controller),
                    child: Text(
                      widget.isCreateNadd
                          ? "createnAdd".tr
                          : widget.renamePlaylist
                              ? "rename".tr
                              : "create".tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Obx(() => (controller.creationInProgress.isTrue &&
                        isPipedLinked)
                    ? Positioned(
                        right: 12,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCreate(
      BuildContext context, LibraryPlaylistsController controller) async {
    if (widget.renamePlaylist) {
      controller.renamePlaylist(widget.playlist!).then((value) {
        if (value) {
          if (!context.mounted) return;
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(snackbar(
              context, "playlistRenameAlert".tr,
              size: SanckBarSize.MEDIUM));
        }
      });
    } else {
      controller
          .createNewPlaylist(
              createPlaylistNaddSong: widget.isCreateNadd,
              songItems: widget.songItems)
          .then((value) {
        if (!context.mounted) return;
        if (value) {
          ScaffoldMessenger.of(context).showSnackBar(snackbar(
              context,
              widget.isCreateNadd
                  ? "playlistCreatednsongAddedAlert".tr
                  : "playlistCreatedAlert".tr,
              size: SanckBarSize.MEDIUM));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(snackbar(
              context, "errorOccuredAlert".tr,
              size: SanckBarSize.MEDIUM));
        }
        Navigator.of(context).pop();
      });
    }
  }
}
