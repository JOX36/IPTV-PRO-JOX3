import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/deep_ocean_colors.dart';
import '../../../core/models/media_item.dart';
import '../../player/player_screen.dart';

class HeroBanner extends StatefulWidget {
  final List<MediaItem> items;

  const HeroBanner({super.key, required this.items});

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return _HeroCard(
                item: item,
                isActive: _currentPage == index,
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Indicadores de página
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.items.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                gradient: _currentPage == index 
                    ? DeepOceanColors.accentGradient 
                    : null,
                color: _currentPage == index 
                    ? null 
                    : DeepOceanColors.bgCard,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final MediaItem item;
  final bool isActive;

  const _HeroCard({required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isActive ? 1.0 : 0.92,
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
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
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive ? DeepOceanColors.glowShadow : DeepOceanColors.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Imagen de fondo
                if (item.logo != null && item.logo!.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: item.logo!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: DeepOceanColors.bgCard,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: DeepOceanColors.accent,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: DeepOceanColors.bgCard,
                      child: const Icon(
                        Icons.tv_rounded,
                        color: DeepOceanColors.accent,
                        size: 48,
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: const BoxDecoration(
                      gradient: DeepOceanColors.cardGradient,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.tv_rounded,
                        color: DeepOceanColors.accent,
                        size: 48,
                      ),
                    ),
                  ),

                // Gradiente inferior
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),

                // Badge LIVE
                if (item.type == MediaType.live)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: DeepOceanColors.liveBadge,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: DeepOceanColors.liveBadge.withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 1,
                        ),
                      ),
                    ).animate().shake(delay: 2000.ms, hz: 2),
                  ),

                // Info del canal
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.group != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: DeepOceanColors.getCategoryColor(item.group!)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: DeepOceanColors.getCategoryColor(item.group!)
                                  .withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            item.group!,
                            style: TextStyle(
                              color: DeepOceanColors.getCategoryColor(item.group!),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Botón de play
                if (isActive)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: DeepOceanColors.accentGradient,
                        shape: BoxShape.circle,
                        boxShadow: DeepOceanColors.glowShadow,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ).animate().scale(delay: 200.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
