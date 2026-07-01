import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/military_colors.dart';

class MediaControls extends StatelessWidget {
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final VoidCallback? onStop;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onRewind;
  final VoidCallback? onFastForward;

  const MediaControls({
    super.key,
    this.onPlay,
    this.onPause,
    this.onStop,
    this.onPrevious,
    this.onNext,
    this.onRewind,
    this.onFastForward,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MilitaryColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MilitaryColors.accent.withOpacity(0.15),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'MEDIA CONTROL',
            style: TextStyle(
              color: MilitaryColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 20),

          // Progreso visual
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: MilitaryColors.bgSurface,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.35,
              child: Container(
                decoration: BoxDecoration(
                  gradient: MilitaryColors.accentGradient,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: MilitaryColors.accent.withOpacity(0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Controles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _mediaButton(Icons.fast_rewind_rounded, onRewind),
              _mediaButton(Icons.skip_previous_rounded, onPrevious),
              _playButton(onPlay, onPause),
              _mediaButton(Icons.skip_next_rounded, onNext),
              _mediaButton(Icons.fast_forward_rounded, onFastForward),
            ],
          ),

          const SizedBox(height: 12),

          // Stop
          _mediaButton(Icons.stop_rounded, onStop),
        ],
      ),
    );
  }

  Widget _mediaButton(IconData icon, VoidCallback? onPressed) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed?.call();
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: MilitaryColors.bgSurface,
          border: Border.all(
            color: MilitaryColors.accent.withOpacity(0.2),
          ),
        ),
        child: Icon(
          icon,
          color: MilitaryColors.accent.withOpacity(0.8),
          size: 22,
        ),
      ),
    );
  }

  Widget _playButton(VoidCallback? onPlay, VoidCallback? onPause) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onPlay?.call();
      },
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: MilitaryColors.accentGradient,
          boxShadow: MilitaryColors.glowShadow,
        ),
        child: const Icon(
          Icons.play_arrow_rounded,
          color: MilitaryColors.bgPrimary,
          size: 36,
        ),
      ),
    );
  }
}
