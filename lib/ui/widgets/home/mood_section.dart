import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'mood_card.dart';

class MoodSection extends StatelessWidget {
  final List<dynamic> content;

  const MoodSection({
    super.key,
    required this.content,
  });

  List<Map<String, dynamic>> _getMoodData() {
    // Define mood categories with their properties
    return [
      {
        'name': 'Chill',
        'icon': Icons.spa_outlined,
        'colors': [const Color(0xFF1DB954), const Color(0xFF1ED760)],
        'keywords': ['chill', 'relax', 'calm', 'peaceful'],
      },
      {
        'name': 'Focus',
        'icon': Icons.lightbulb_outline,
        'colors': [const Color(0xFF8E44AD), const Color(0xFF9B59B6)],
        'keywords': ['focus', 'study', 'concentration', 'work'],
      },
      {
        'name': 'Workout',
        'icon': Icons.favorite_outline,
        'colors': [const Color(0xFFE91E63), const Color(0xFFF06292)],
        'keywords': ['workout', 'gym', 'fitness', 'exercise'],
      },
      {
        'name': 'Party',
        'icon': Icons.celebration_outlined,
        'colors': [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
        'keywords': ['party', 'dance', 'celebration', 'fun'],
      },
    ];
  }

  void _onMoodTap(String moodName) {
    // Navigate to search with mood query
    Get.toNamed('/searchScreen', arguments: moodName.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final moods = _getMoodData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Browse by Mood',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: moods.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final mood = moods[index];
              return MoodCard(
                moodName: mood['name'],
                icon: mood['icon'],
                gradientColors: mood['colors'],
                onTap: () => _onMoodTap(mood['name']),
              );
            },
          ),
        ),
      ],
    );
  }
}
