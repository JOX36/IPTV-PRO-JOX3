import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/deep_ocean_colors.dart';
import '../../core/services/app_provider.dart';
import '../home/widgets/media_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DeepOceanColors.bgPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: DeepOceanColors.favorite,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Mis Favoritos',
                    style: TextStyle(
                      color: DeepOceanColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Consumer<AppProvider>(
                    builder: (context, provider, _) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: DeepOceanColors.favorite.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${provider.favorites.length}',
                          style: const TextStyle(
                            color: DeepOceanColors.favorite,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Lista de favoritos
            Expanded(
              child: Consumer<AppProvider>(
                builder: (context, provider, _) {
                  if (provider.favorites.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite_border_rounded,
                            color: DeepOceanColors.favorite.withOpacity(0.3),
                            size: 64),
                          const SizedBox(height: 16),
                          const Text(
                            'No tienes favoritos aún',
                            style: TextStyle(
                              color: DeepOceanColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Mantén presionado un canal o película\npara agregarlo a favoritos',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: DeepOceanColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn();
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 160,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: provider.favorites.length,
                    itemBuilder: (context, index) {
                      return MediaCard(
                        item: provider.favorites[index],
                        isGrid: true,
                      ).animate().fadeIn(delay: (30 * index).ms);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
