import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/military_colors.dart';
import '../../core/models/tv_device.dart';
import '../../core/services/tv_provider.dart';
import 'widgets/touch_pad.dart';
import 'widgets/remote_button.dart';
import 'widgets/volume_channel_bar.dart';
import 'widgets/media_controls.dart';
import 'widgets/color_buttons.dart';
import '../tv_connect/tv_connect_screen.dart';
import '../keyboard/keyboard_screen.dart';
import '../apps/apps_screen.dart';
import '../settings/remote_settings_screen.dart';

class RemoteScreen extends StatefulWidget {
  const RemoteScreen({super.key});

  @override
  State<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends State<RemoteScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<TvProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: MilitaryColors.bgPrimary,
          body: SafeArea(
            child: Column(
              children: [
                // ── Header táctico ──
                _buildHeader(provider),

                // ── Contenido principal ──
                Expanded(
                  child: IndexedStack(
                    index: _selectedTab,
                    children: [
                      _buildMainRemote(provider),
                      _buildNavigationPad(provider),
                      _buildMediaRemote(provider),
                    ],
                  ),
                ),

                // ── Bottom nav táctico ──
                _buildBottomNav(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(TvProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: MilitaryColors.bgSecondary,
        border: Border(
          bottom: BorderSide(
            color: MilitaryColors.accent.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Indicador de conexión
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: provider.isConnected 
                  ? MilitaryColors.online 
                  : MilitaryColors.offline,
              shape: BoxShape.circle,
              boxShadow: provider.isConnected ? [
                BoxShadow(
                  color: MilitaryColors.online.withOpacity(0.5),
                  blurRadius: 8,
                ),
              ] : null,
            ),
          ),
          const SizedBox(width: 10),

          // Info del TV
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.activeDevice?.name ?? 'Sin conexión',
                  style: const TextStyle(
                    color: MilitaryColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '${provider.activeDevice?.brand ?? ""} • ${provider.activeDevice?.ip ?? "IR"}',
                  style: const TextStyle(
                    color: MilitaryColors.textMuted,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          // Volumen actual
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: MilitaryColors.bgCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: MilitaryColors.accent.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  provider.isMuted 
                      ? Icons.volume_off_rounded 
                      : Icons.volume_up_rounded,
                  color: provider.isMuted 
                      ? MilitaryColors.danger 
                      : MilitaryColors.accent,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '${provider.currentVolume}',
                  style: TextStyle(
                    color: provider.isMuted 
                        ? MilitaryColors.danger 
                        : MilitaryColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Botón desconectar
          IconButton(
            onPressed: () {
              provider.disconnect();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const TvConnectScreen()),
              );
            },
            icon: const Icon(
              Icons.power_settings_new_rounded,
              color: MilitaryColors.danger,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.3);
  }

  Widget _buildMainRemote(TvProvider provider) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Power + Source ──
          Row(
            children: [
              Expanded(
                child: RemoteButton(
                  icon: Icons.power_settings_new_rounded,
                  label: 'POWER',
                  color: MilitaryColors.danger,
                  onPressed: () => provider.sendCommand(RemoteCommand.power),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RemoteButton(
                  icon: Icons.input_rounded,
                  label: 'SOURCE',
                  color: MilitaryColors.accentAmber,
                  onPressed: () => provider.sendCommand(RemoteCommand.source),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RemoteButton(
                  icon: Icons.home_rounded,
                  label: 'HOME',
                  color: MilitaryColors.accent,
                  onPressed: () => provider.sendCommand(RemoteCommand.home),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 20),

          // ── Touchpad principal ──
          TouchPad(
            onTap: () => provider.sendCommand(RemoteCommand.ok),
            onSwipeUp: () => provider.sendCommand(RemoteCommand.up),
            onSwipeDown: () => provider.sendCommand(RemoteCommand.down),
            onSwipeLeft: () => provider.sendCommand(RemoteCommand.left),
            onSwipeRight: () => provider.sendCommand(RemoteCommand.right),
          ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.9, 0.9)),

          const SizedBox(height: 20),

          // ── Back + Menu ──
          Row(
            children: [
              Expanded(
                child: RemoteButton(
                  icon: Icons.arrow_back_rounded,
                  label: 'BACK',
                  onPressed: () => provider.sendCommand(RemoteCommand.back),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RemoteButton(
                  icon: Icons.menu_rounded,
                  label: 'MENU',
                  onPressed: () => provider.sendCommand(RemoteCommand.menu),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RemoteButton(
                  icon: Icons.close_rounded,
                  label: 'EXIT',
                  onPressed: () => provider.sendCommand(RemoteCommand.exit),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 20),

          // ── Volumen + Canal ──
          VolumeChannelBar(
            onVolumeUp: () => provider.sendCommand(RemoteCommand.volumeUp),
            onVolumeDown: () => provider.sendCommand(RemoteCommand.volumeDown),
            onMute: () => provider.sendCommand(RemoteCommand.mute),
            onChannelUp: () => provider.sendCommand(RemoteCommand.channelUp),
            onChannelDown: () => provider.sendCommand(RemoteCommand.channelDown),
            onChannelList: () => provider.sendCommand(RemoteCommand.channelList),
            isMuted: provider.isMuted,
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 20),

          // ── Botones de color ──
          const ColorButtons().animate().fadeIn(delay: 500.ms),

          const SizedBox(height: 20),

          // ── Accesos rápidos ──
          Row(
            children: [
              _quickAction(Icons.tv_rounded, 'TV', () => provider.sendCommand(RemoteCommand.tv)),
              _quickAction(Icons.apps_rounded, 'APPS', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AppsScreen()),
                );
              }),
              _quickAction(Icons.keyboard_rounded, 'KEY', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const KeyboardScreen()),
                );
              }),
              _quickAction(Icons.settings_rounded, 'SET', () {
                provider.sendCommand(RemoteCommand.settings);
              }),
              _quickAction(Icons.info_outline_rounded, 'INFO', () => provider.sendCommand(RemoteCommand.info)),
              _quickAction(Icons.closed_caption_rounded, 'SUB', () => provider.sendCommand(RemoteCommand.subtitle)),
            ],
          ).animate().fadeIn(delay: 600.ms),

          const SizedBox(height: 30),

          // ── Último comando ──
          if (provider.lastCommand.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: MilitaryColors.bgCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: MilitaryColors.accent.withOpacity(0.1),
                ),
              ),
              child: Text(
                'LAST: ${provider.lastCommand.toUpperCase()}',
                style: const TextStyle(
                  color: MilitaryColors.textMuted,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontFamily: 'monospace',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationPad(TvProvider provider) {
    return Center(
      child: TouchPad(
        size: 280,
        onTap: () => provider.sendCommand(RemoteCommand.ok),
        onSwipeUp: () => provider.sendCommand(RemoteCommand.up),
        onSwipeDown: () => provider.sendCommand(RemoteCommand.down),
        onSwipeLeft: () => provider.sendCommand(RemoteCommand.left),
        onSwipeRight: () => provider.sendCommand(RemoteCommand.right),
        showDirections: true,
      ),
    );
  }

  Widget _buildMediaRemote(TvProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          MediaControls(
            onPlay: () => provider.sendCommand(RemoteCommand.play),
            onPause: () => provider.sendCommand(RemoteCommand.pause),
            onStop: () => provider.sendCommand(RemoteCommand.stop),
            onPrevious: () => provider.sendCommand(RemoteCommand.previous),
            onNext: () => provider.sendCommand(RemoteCommand.next),
            onRewind: () => provider.sendCommand(RemoteCommand.rewind),
            onFastForward: () => provider.sendCommand(RemoteCommand.fastForward),
          ),
          const SizedBox(height: 24),
          // Num pad
          _buildNumPad(provider),
        ],
      ),
    );
  }

  Widget _buildNumPad(TvProvider provider) {
    final numbers = [
      RemoteCommand.num1, RemoteCommand.num2, RemoteCommand.num3,
      RemoteCommand.num4, RemoteCommand.num5, RemoteCommand.num6,
      RemoteCommand.num7, RemoteCommand.num8, RemoteCommand.num9,
      RemoteCommand.num0,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        ...numbers.take(9).map((cmd) => _numButton(
          '${cmd.name.substring(3)}',
          () => provider.sendCommand(cmd),
        )),
        const SizedBox(width: 60),
        _numButton('0', () => provider.sendCommand(RemoteCommand.num0)),
        const SizedBox(width: 60),
      ],
    );
  }

  Widget _numButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: 60,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: MilitaryColors.bgCard,
          foregroundColor: MilitaryColors.accent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: MilitaryColors.accent.withOpacity(0.2),
            ),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: MilitaryColors.bgCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: MilitaryColors.accent.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                Icon(icon, color: MilitaryColors.accent, size: 18),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: MilitaryColors.textMuted,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: MilitaryColors.bgSecondary,
        border: Border(
          top: BorderSide(
            color: MilitaryColors.accent.withOpacity(0.15),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(0, Icons.gamepad_rounded, 'REMOTE'),
          _navItem(1, Icons.touch_app_rounded, 'TOUCH'),
          _navItem(2, Icons.play_circle_rounded, 'MEDIA'),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive 
              ? MilitaryColors.accent.withOpacity(0.1) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isActive ? Border.all(
            color: MilitaryColors.accent.withOpacity(0.3),
          ) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive 
                  ? MilitaryColors.accent 
                  : MilitaryColors.textMuted,
              size: 18,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: MilitaryColors.accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
