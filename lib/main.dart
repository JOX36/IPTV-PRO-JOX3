import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/tv_provider.dart';
import 'features/remote/remote_screen.dart';
import 'features/tv_connect/tv_connect_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0B0F0A),
  ));

  runApp(
    ChangeNotifierProvider(
      create: (_) => TvProvider()..init(),
      child: const TvRemoteApp(),
    ),
  );
}

class TvRemoteApp extends StatelessWidget {
  const TvRemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TV Remote PRO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.militaryTheme,
      home: const AppEntryPoint(),
    );
  }
}

class AppEntryPoint extends StatelessWidget {
  const AppEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TvProvider>(
      builder: (context, provider, _) {
        if (provider.activeDevice == null) {
          return const TvConnectScreen();
        }
        return const RemoteScreen();
      },
    );
  }
}
