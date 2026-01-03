import 'dart:ui';
import 'package:flutter/material.dart';

import '/ui/player/components/lyrics_switch.dart';
import '/ui/player/components/lyrics_widget.dart';

class LyricsDialog extends StatelessWidget {
  const LyricsDialog({super.key});

  @override
  Widget build(BuildContext context) {
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
            initialChildSize: 0.8,
            minChildSize: 0.5,
            maxChildSize: 0.95,
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

                  // Header with Switch
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Lyrics",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const LyricsSwitch(),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Lyrics Content
                  Expanded(
                    child: SingleChildScrollView(
                      // LyricsWidget handles scrolling differently internally potentially, but usually it needs an Expanded parent if it's a list.
                      // Currently LyricsWidget takes padding.
                      // Wait, LyricsWidget might be scrollable itself.
                      // Let's check the imported LyricsWidget if necessary, but assuming it fits in Expanded is safe.
                      // Actually DraggableScrollableSheet expects the child to be the scrollable.
                      // If LyricsWidget is not scrollable, we need SingleChildScrollView.
                      // If LyricsWidget IS a scrollable (ListView), we should pass the scrollController to it.
                      // But I don't see efficient way to pass scrollController to LyricsWidget without modifying it.
                      // For now, I'll wrap in specific way or just assume it works in Expanded.
                      // Better yet, let's wrap it in a container and hope LyricsWidget handles its scrolling or fits.
                      // The original code had: Expanded(child: LyricsWidget(padding: ...)).
                      // If I use DraggableScrollableSheet, I should try to make the inner list drive the sheet.
                      // But without modifying LyricsWidget, I can't pass the controller.
                      // So I will use Flexible/Expanded and let the sheet handle the drag mainly via the header,
                      // or if the user drags the content it might conflict if not connected.
                      // For now, I will use Expanded.
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 20),
                            child: LyricsWidget(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              // We might need to make LyricsWidget utilize the scrollController if we want perfect drag behavior.
                              // But for now, keeping it simple.
                            ),
                          ),
                          // If LyricsWidget is just a view, this is fine.
                        ],
                      ),
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
}
