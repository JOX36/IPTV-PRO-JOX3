import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/deep_ocean_colors.dart';
import '../../core/services/app_provider.dart';
import '../home/widgets/media_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DeepOceanColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                style: const TextStyle(color: DeepOceanColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Buscar canales, películas, series...',
                  hintStyle: const TextStyle(color: DeepOceanColors.textMuted),
                  prefixIcon: const Icon(Icons.search_rounded,
                    color: DeepOceanColors.accent),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            context.read<AppProvider>().search('');
                          },
                          icon: const Icon(Icons.clear,
                            color: DeepOceanColors.textMuted),
                        )
                      : null,
                  filled: true,
                  fillColor: DeepOceanColors.bgCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: DeepOceanColors.accent, width: 1.5),
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                  if (value.length >= 2) {
                    context.read<AppProvider>().search(value);
                  }
                },
              ),
            ),

            // Resultados
            Expanded(
              child: Consumer<AppProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: DeepOceanColors.accent),
                    );
                  }

                  if (_searchController.text.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_rounded,
                            color: DeepOceanColors.accent.withOpacity(0.3),
                            size: 64),
                          const SizedBox(height: 16),
                          const Text(
                            'Busca tu contenido favorito',
                            style: TextStyle(
                              color: DeepOceanColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn();
                  }

                  if (provider.searchResults.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded,
                            color: DeepOceanColors.textMuted.withOpacity(0.5),
                            size: 64),
                          const SizedBox(height: 16),
                          Text(
                            'Sin resultados para "${_searchController.text}"',
                            style: const TextStyle(
                              color: DeepOceanColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 160,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: provider.searchResults.length,
                    itemBuilder: (context, index) {
                      return MediaCard(
                        item: provider.searchResults[index],
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
