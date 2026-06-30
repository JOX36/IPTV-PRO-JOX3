import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/app_provider.dart';
import 'features/home/home_screen.dart';
import 'features/search/search_screen.dart';
import 'features/favorites/favorites_screen.dart';
import 'features/settings/accounts_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A0E1A),
  ));
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider()..loadSavedData(),
      child: const IPTVProApp(),
    ),
  );
}

class IPTVProApp extends StatelessWidget {
  const IPTVProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IPTV PRO JOX3',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppEntryPoint(),
    );
  }
}

class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    SearchScreen(),
    FavoritesScreen(),
    AccountsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        // Si no hay cuenta activa, mostrar pantalla de login
        if (provider.activeAccount == null && !provider.isLoading) {
          return const AccountsScreen(isSetup: true);
        }

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.home_rounded, 'Inicio'),
                    _buildNavItem(1, Icons.search_rounded, 'Buscar'),
                    _buildNavItem(2, Icons.favorite_rounded, 'Favoritos'),
                    _buildNavItem(3, Icons.settings_rounded, 'Ajustes'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive 
              ? const Color(0xFF00D4FF).withOpacity(0.1) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive 
                  ? const Color(0xFF00D4FF) 
                  : const Color(0xFF64748B),
              size: 24,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF00D4FF),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
