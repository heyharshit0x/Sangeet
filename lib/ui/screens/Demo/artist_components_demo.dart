import 'package:flutter/material.dart';
import 'package:sangeet/ui/widgets/artist/modern_artist_header.dart';
import 'package:sangeet/ui/widgets/artist/modern_artist_tabs.dart';
import 'package:sangeet/ui/widgets/artist/artist_about_section.dart';
import 'package:sangeet/services/color_extractor_service.dart';

/// Demo screen to test modern artist components
/// Navigate to this screen to preview the new artist UI
class ArtistComponentsDemo extends StatefulWidget {
  const ArtistComponentsDemo({super.key});

  @override
  State<ArtistComponentsDemo> createState() => _ArtistComponentsDemoState();
}

class _ArtistComponentsDemoState extends State<ArtistComponentsDemo> {
  final ScrollController _scrollController = ScrollController();
  final _colorExtractor = ColorExtractorService();

  double _scrollOffset = 0;
  List<Color>? _extractedColors;
  bool _isBookmarked = false;
  int _selectedTabIndex = 0;

  // Demo data
  final String _artistName = "The Weeknd";
  final String _thumbnailUrl =
      "https://i.scdn.co/image/ab6761610000e5eb214f3cf1cbe7139c1e26ffbb";
  final String _description =
      "Abel Makkonen Tesfaye, known professionally as The Weeknd, is a Canadian singer, songwriter, and record producer. He is noted for his unconventional music production, artistic reinventions, and his signature use of the falsetto register.";

  final List<String> _tabs = ['About', 'Songs', 'Videos', 'Albums', 'Singles'];

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
        title: const Text('Artist Components Demo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Modern Artist Header
          ModernArtistHeader(
            artistName: _artistName,
            thumbnailUrl: _thumbnailUrl,
            description: _description,
            isBookmarked: _isBookmarked,
            onBookmarkTap: () {
              setState(() => _isBookmarked = !_isBookmarked);
              _showSnackbar(_isBookmarked ? 'Bookmarked' : 'Removed bookmark');
            },
            onShareTap: () => _showSnackbar('Share artist'),
            scrollOffset: _scrollOffset,
          ),

          // Modern Tabs
          ModernArtistTabs(
            tabs: _tabs,
            selectedIndex: _selectedTabIndex,
            onTabSelected: (index) {
              setState(() => _selectedTabIndex = index);
            },
            gradientColors: _extractedColors,
          ),

          // Tab Content
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                if (_selectedTabIndex == 0)
                  // About Section
                  ArtistAboutSection(
                    description: _description,
                    gradientColors: _extractedColors,
                  )
                else
                  // Content Grid Preview
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_tabs[_selectedTabIndex]} Preview',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'This would display ${_tabs[_selectedTabIndex].toLowerCase()} using the ArtistContentGrid component.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withValues(alpha: 0.7),
                                  ),
                        ),
                        const SizedBox(height: 24),

                        // Demo grid items
                        if (_selectedTabIndex == 1)
                          ..._buildDemoSongs()
                        else
                          ..._buildDemoGrid(),
                      ],
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
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'This is a demo screen showcasing the new modern artist components:\n\n'
                            '• ModernArtistHeader - Gradient hero section\n'
                            '• ModernArtistTabs - Glassmorphic tab selector\n'
                            '• ArtistAboutSection - Bio display\n'
                            '• ArtistContentGrid - Content display\n\n'
                            'Scroll to see the header shrink effect!',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSnackbar('Start artist radio'),
        icon: const Icon(Icons.sensors),
        label: const Text('Radio'),
      ),
    );
  }

  List<Widget> _buildDemoSongs() {
    return List.generate(
      5,
      (index) => _DemoSongTile(
        index: index + 1,
        title: 'Song ${index + 1}',
        artist: _artistName,
      ),
    );
  }

  List<Widget> _buildDemoGrid() {
    return [
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 4,
        itemBuilder: (context, index) => _DemoGridItem(
          title: '${_tabs[_selectedTabIndex]} ${index + 1}',
        ),
      ),
    ];
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
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

class _DemoGridItem extends StatelessWidget {
  final String title;

  const _DemoGridItem({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.album,
                size: 60,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
