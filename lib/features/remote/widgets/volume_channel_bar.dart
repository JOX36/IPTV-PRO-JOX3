import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/military_colors.dart';

class VolumeChannelBar extends StatelessWidget {
  final VoidCallback onVolumeUp;
  final VoidCallback onVolumeDown;
  final VoidCallback onMute;
  final VoidCallback onChannelUp;
  final VoidCallback onChannelDown;
  final VoidCallback onChannelList;
  final bool isMuted;

  const VolumeChannelBar({
    super.key,
    required this.onVolumeUp,
    required this.onVolumeDown,
    required this.onMute,
    required this.onChannelUp,
    required this.onChannelDown,
    required this.onChannelList,
    this.isMuted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MilitaryColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MilitaryColors.accent.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          // Volumen
          Expanded(
            child: Column(
              children: [
                const Text(
                  'VOL',
                  style: TextStyle(
                    color: MilitaryColors.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _roundButton(
                      icon: Icons.remove_rounded,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onVolumeDown();
                      },
                    ),
                    const SizedBox(width: 8),
                    _muteButton(isMuted, () {
                      HapticFeedback.lightImpact();
                      onMute();
                    }),
                    const SizedBox(width: 8),
                    _roundButton(
                      icon: Icons.add_rounded,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onVolumeUp();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Separador
          Container(
            width: 1,
            height: 50,
            color: MilitaryColors.accent.withOpacity(0.15),
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),

          // Canal
          Expanded(
            child: Column(
              children: [
                const Text(
                  'CH',
                  style: TextStyle(
                    color: MilitaryColors.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _roundButton(
                      icon: Icons.keyboard_arrow_up_rounded,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onChannelUp();
                      },
                    ),
                    const SizedBox(width: 8),
                    _listButton(() {
                      HapticFeedback.lightImpact();
                      onChannelList();
                    }),
                    const SizedBox(width: 8),
                    _roundButton(
                      icon: Icons.keyboard_arrow_down_rounded,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onChannelDown();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundButton({required IconData icon, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: MilitaryColors.bgSurface,
          border: Border.all(
            color: MilitaryColors.accent.withOpacity(0.25),
          ),
        ),
        child: Icon(
          icon,
          color: MilitaryColors.accent,
          size: 22,
        ),
      ),
    );
  }

  Widget _muteButton(bool isMuted, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isMuted 
              ? MilitaryColors.danger.withOpacity(0.2) 
              : MilitaryColors.bgSurface,
          border: Border.all(
            color: isMuted 
                ? MilitaryColors.danger.withOpacity(0.5) 
                : MilitaryColors.accent.withOpacity(0.25),
          ),
        ),
        child: Icon(
          isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          color: isMuted ? MilitaryColors.danger : MilitaryColors.accent,
          size: 20,
        ),
      ),
    );
  }

  Widget _listButton(VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: MilitaryColors.bgSurface,
          border: Border.all(
            color: MilitaryColors.accent.withOpacity(0.25),
          ),
        ),
        child: const Icon(
          Icons.list_rounded,
          color: MilitaryColors.accent,
          size: 18,
        ),
      ),
    );
  }
}
