import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/military_colors.dart';
import '../../core/services/tv_provider.dart';

class AppsScreen extends StatelessWidget {
  const AppsScreen({super.key});

  // Apps comunes de Smart TV
  static const _commonApps = [
    {'name': 'Netflix', 'icon': '🎬', 'id': 'com.netflix.ninja'},
    {'name': 'YouTube', 'icon': '▶️', 'id': 'com.google.android.youtube.tv'},
    {'name': 'Prime Video', 'icon': '📦', 'id': 'com.amazon.amazonvideo.livingroom'},
    {'name': 'Disney+', 'icon': '🏰', 'id': 'com.disney.disneyplus'},
    {'name': 'HBO Max', 'icon': '🎭', 'id': 'com.hbo.hbonow'},
    {'name': 'Spotify', 'icon': '🎵', 'id': 'com.spotify.tv.android'},
    {'name': 'Twitch', 'icon': '🎮', 'id': 'tv.twitch.android.viewer'},
    {'name': 'Plex', 'icon': '📽️', 'id': 'com.plexapp.android'},
    {'name': 'Kodi', 'icon': '🖥️', 'id': 'org.xbmc.kodi'},
    {'name': 'Apple TV', 'icon': '🍎', 'id': 'com.apple.atve.androidtv.appletv'},
    {'name': 'TikTok', 'icon': '📱', 'id': 'com.zhiliaoapp.musically'},
    {'name': 'Crunchyroll', 'icon': '🍥', 'id': 'com.crunchyroll.crunchyroid'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MilitaryColors.bgPrimary,
      appBar: AppBar(
        title: const Text(
          'APPS',
          style: TextStyle(
            color: MilitaryColors.accent,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
          ),
        ),
        backgroundColor: MilitaryColors.bgSecondary,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, 
            color: MilitaryColors.accent),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.85,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _commonApps.length,
        itemBuilder: (context, index) {
          final app = _commonApps[index];
          return GestureDetector(
            onTap: () {
              context.read<TvProvider>().launchApp(app['id']!);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lanzando ${app['name']}...'),
                  backgroundColor: MilitaryColors.bgCard,
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: MilitaryColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: MilitaryColors.accent.withOpacity(0.15),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    app['icon']!,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    app['name']!,
                    style: const TextStyle(
                      color: MilitaryColors.textPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (30 * index).ms);
        },
      ),
    );
  }
}
