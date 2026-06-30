import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/deep_ocean_colors.dart';
import '../../../core/models/media_item.dart';
import 'media_card.dart';

class CategorySection extends StatelessWidget {
  final String title;
  final List<MediaItem> items;
  final Color accentColor;

  const CategorySection({
    super.key,
    required this.title,
    required this.items,
    this.accentColor = DeepOceanColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de sección
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: DeepOceanColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // TODO: Ver todos
                  },
                  child: Row(
                    children: [
                      Text(
                        'Ver todo',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, 
                        color: accentColor, size: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Lista horizontal de cards
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length > 20 ? 20 : items.length,
              itemBuilder: (context, index) {
                return MediaCard(
                  item: items[index],
                  accentColor: accentColor,
                )
                    .animate()
                    .fadeIn(delay: (50 * index).ms, duration: 300.ms)
                    .slideX(begin: 0.1, delay: (50 * index).ms);
              },
            ),
          ),
        ],
      ),
    );
  }
}
