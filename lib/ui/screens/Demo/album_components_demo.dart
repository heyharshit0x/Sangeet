import 'package:flutter/material.dart';
import 'package:sangeet/ui/widgets/album/modern_album_header.dart';
import 'package:sangeet/ui/widgets/album/modern_album_actions.dart';
import 'package:sangeet/services/color_extractor_service.dart';

/// Demo screen to test modern album components
/// Navigate to this screen to preview the new album UI
class AlbumComponentsDemo extends StatefulWidget {
  const AlbumComponentsDemo({super.key});

  @override
  State<AlbumComponentsDemo> createState() => _AlbumComponentsDemoState();
}

class _AlbumComponentsDemoState extends State<AlbumComponentsDemo> {
  final ScrollController _scrollController = ScrollController();
  final _colorExtractor = ColorExtractorService();

  double _scrollOffset = 0;
  List<Color>? _extractedColors;
  bool _isBookmarked = false;
  bool _isDownloaded = false;
  bool _isDownloading = false;
  int _downloadProgress = 0;

  // Demo data
  final String _albumTitle = "After Hours";
  final String _albumDescription = "Album • 2020";
  final String _artists = "The Weeknd";
  final String _thumbnailUrl =
      "https://i.scdn.co/image/ab67616d0000b2738863bc11d2aa12b54f5aeb36";
  final int _totalSongs = 14;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _extractColors();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  Future<void> _extractColors() async {
    final colors = await _colorExtractor.extractColors(_thumbnailUrl);
    if (mounted) {
      setState(() => _extractedColors = colors);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Album Components Demo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Header
          ModernAlbumHeader(
            albumTitle: _albumTitle,
            albumDescription: _albumDescription,
            artists: _artists,
            thumbnailUrl: _thumbnailUrl,
            scrollOffset: _scrollOffset,
            isLandscape: false,
          ),

          // Scrollable Content
          ListView(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 200, bottom: 100),
            children: [
              // Album Info Card
              AlbumInfoCard(
                albumTitle: _albumTitle,
                albumDescription: _albumDescription,
                artists: _artists,
                thumbnailUrl: _thumbnailUrl,
                gradientColors: _extractedColors,
              ),

              const SizedBox(height: 16),

              // Modern Actions
              ModernAlbumActions(
                onPlayAll: () => _showSnackbar('Play All'),
                onShuffle: () => _showSnackbar('Shuffle'),
                onBookmark: () {
                  setState(() => _isBookmarked = !_isBookmarked);
                  _showSnackbar(
                      _isBookmarked ? 'Bookmarked' : 'Removed bookmark');
                },
                onDownload: () {
                  setState(() {
                    _isDownloading = true;
                    _downloadProgress = 0;
                  });
                  _simulateDownload();
                },
                onShare: () => _showSnackbar('Share'),
                onEnqueue: () => _showSnackbar('Added to queue'),
                isBookmarked: _isBookmarked,
                isDownloaded: _isDownloaded,
                isDownloading: _isDownloading,
                downloadProgress: _downloadProgress,
                totalSongs: _totalSongs,
                gradientColors: _extractedColors,
              ),

              const SizedBox(height: 24),

              // Demo Song List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Song List Preview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 12),

              // Sample songs
              ...List.generate(
                5,
                (index) => _DemoSongTile(
                  index: index + 1,
                  title: 'Song ${index + 1}',
                  artist: _artists,
                ),
              ),

              const SizedBox(height: 40),

              // Info Card
              Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📝 Demo Information',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'This is a demo screen showcasing the new modern album components:\n\n'
                          '• ModernAlbumHeader - Blurred background with parallax\n'
                          '• AlbumInfoCard - Glassmorphic info display\n'
                          '• ModernAlbumActions - Modern action buttons\n\n'
                          'Scroll to see the parallax effect!',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _simulateDownload() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted || !_isDownloading) return;

      setState(() {
        _downloadProgress++;
        if (_downloadProgress >= _totalSongs) {
          _isDownloading = false;
          _isDownloaded = true;
          _showSnackbar('Download complete!');
        } else {
          _simulateDownload();
        }
      });
    });
  }
}

class _DemoSongTile extends StatelessWidget {
  final int index;
  final String title;
  final String artist;

  const _DemoSongTile({
    required this.index,
    required this.title,
    required this.artist,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.black.withValues(alpha: 0.01),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      artist,
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
              IconButton(
                icon: const Icon(Icons.more_vert, size: 20),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
