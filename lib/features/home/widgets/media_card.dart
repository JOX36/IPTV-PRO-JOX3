import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/deep_ocean_colors.dart';
import '../../../core/models/media_item.dart';
import '../../../core/services/app_provider.dart';
import 'package:provider/provider.dart';
import '../../player/player_screen.dart';

class MediaCard extends StatelessWidget {
  final MediaItem item;
  final Color accentColor;
  final bool isGrid;

  const MediaCard({
    super.key,
    required this.item,
    this.accentColor = DeepOceanColors.accent,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item.url != null) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => PlayerScreen(item: item),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      },
      onLongPress: () {
        // Toggle favorito
        context.read<AppProvider>().toggleFavorite(item);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<AppProvider>().isFavorite(item.id)
                  ? '❤️ Agregado a favoritos'
                  : '💔 Eliminado de favoritos',
            ),
            backgroundColor: DeepOceanColors.bgCard,
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: Container(
        width: isGrid ? null : 140,
        margin: isGrid ? EdgeInsets.zero : const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: DeepOceanColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: DeepOceanColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                    child: SizedBox(
                      width: double.infinity,
                      child: item.logo != null && item.logo!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: item.logo!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: DeepOceanColors.bgSurface,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: DeepOceanColors.accent,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (_, __, ___) => _placeholder(),
                            )
                          : _placeholder(),
                    ),
                  ),

                  // Badge LIVE
                  if (item.type == MediaType.live)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: DeepOceanColors.liveBadge,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                  // Rating badge (para películas)
                  if (item.rating != null && item.rating!.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, 
                              color: DeepOceanColors.favorite, size: 10),
                            const SizedBox(width: 2),
                            Text(
                              item.rating!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Favorito
                  Consumer<AppProvider>(
                    builder: (context, provider, _) {
                      if (provider.isFavorite(item.id)) {
                        return Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: DeepOceanColors.favorite,
                              size: 14,
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),

                  // Overlay de gradiente
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            DeepOceanColors.bgCard,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: DeepOceanColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.group != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.group!,
                      style: TextStyle(
                        color: accentColor.withOpacity(0.7),
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: DeepOceanColors.bgSurface,
      child: Center(
        child: Icon(
          item.type == MediaType.movie
              ? Icons.movie_rounded
              : item.type == MediaType.series
                  ? Icons.tv_rounded
                  : Icons.live_tv_rounded,
          color: accentColor.withOpacity(0.4),
          size: 32,
        ),
      ),
    );
  }
}
