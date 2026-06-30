import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/deep_ocean_colors.dart';
import '../../core/models/media_item.dart';
import '../../core/services/app_provider.dart';
import 'widgets/hero_banner.dart';
import 'widgets/category_section.dart';
import 'widgets/media_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadContent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.liveChannels.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: DeepOceanColors.accent),
                SizedBox(height: 16),
                Text('Cargando contenido...', 
                  style: TextStyle(color: DeepOceanColors.textSecondary)),
              ],
            ),
          );
        }

        if (provider.error != null && provider.liveChannels.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, 
                  color: DeepOceanColors.error, size: 48),
                const SizedBox(height: 16),
                Text(provider.error!, 
                  style: const TextStyle(color: DeepOceanColors.textSecondary)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => provider.loadContent(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar personalizado
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Colors.transparent,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: DeepOceanColors.accentGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'JOX3',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'TV PRO',
                    style: TextStyle(
                      color: DeepOceanColors.textPrimary,
                      fontWeight: FontWeight.w300,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              actions: [
                // Indicador de cuenta
                if (provider.activeAccount != null)
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: DeepOceanColors.bgCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: DeepOceanColors.accent.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.circle, 
                          color: DeepOceanColors.success, size: 8),
                        const SizedBox(width: 6),
                        Text(
                          provider.activeAccount!.name,
                          style: const TextStyle(
                            color: DeepOceanColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // Hero Banner (carrusel de destacados)
            if (provider.liveChannels.isNotEmpty)
              SliverToBoxAdapter(
                child: HeroBanner(
                  items: provider.liveChannels.take(5).toList(),
                ),
              ),

            // Secciones por categoría
            if (provider.liveChannels.isNotEmpty)
              SliverToBoxAdapter(
                child: CategorySection(
                  title: '📺 En Vivo',
                  items: provider.liveChannels,
                  accentColor: DeepOceanColors.accent,
                ),
              ),

            if (provider.movies.isNotEmpty)
              SliverToBoxAdapter(
                child: CategorySection(
                  title: '🎬 Películas',
                  items: provider.movies,
                  accentColor: DeepOceanColors.accentTeal,
                ),
              ),

            if (provider.series.isNotEmpty)
              SliverToBoxAdapter(
                child: CategorySection(
                  title: '📺 Series',
                  items: provider.series,
                  accentColor: DeepOceanColors.accentIndigo,
                ),
              ),

            // Categorías dinámicas
            ...provider.liveCategories.take(5).map((cat) {
              final catName = cat['category_name'] ?? 'Sin nombre';
              final catItems = provider.liveChannels
                  .where((ch) => ch.group == catName)
                  .toList();
              if (catItems.isEmpty) return const SliverToBoxAdapter(child: SizedBox());
              return SliverToBoxAdapter(
                child: CategorySection(
                  title: catName,
                  items: catItems,
                  accentColor: DeepOceanColors.getCategoryColor(catName),
                ),
              );
            }),

            // Espacio inferior
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ).animate().fadeIn(duration: 400.ms);
      },
    );
  }
}
