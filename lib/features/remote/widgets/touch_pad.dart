import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/military_colors.dart';

class TouchPad extends StatefulWidget {
  final VoidCallback? onTap;
  final VoidCallback? onSwipeUp;
  final VoidCallback? onSwipeDown;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final double size;
  final bool showDirections;

  const TouchPad({
    super.key,
    this.onTap,
    this.onSwipeUp,
    this.onSwipeDown,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.size = 220,
    this.showDirections = false,
  });

  @override
  State<TouchPad> createState() => _TouchPadState();
}

class _TouchPadState extends State<TouchPad> {
  Offset? _startOffset;
  bool _isPressed = false;

  void _onPanStart(DragStartDetails details) {
    _startOffset = details.localPosition;
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() => _isPressed = false);
    if (_startOffset == null) return;

    final dx = details.velocity.pixelsPerSecond.dx;
    final dy = details.velocity.pixelsPerSecond.dy;

    if (dx.abs() < 50 && dy.abs() < 50) {
      // Tap
      widget.onTap?.call();
      HapticFeedback.mediumImpact();
    } else if (dx.abs() > dy.abs()) {
      // Horizontal swipe
      if (dx > 0) {
        widget.onSwipeRight?.call();
      } else {
        widget.onSwipeLeft?.call();
      }
      HapticFeedback.lightImpact();
    } else {
      // Vertical swipe
      if (dy > 0) {
        widget.onSwipeDown?.call();
      } else {
        widget.onSwipeUp?.call();
      }
      HapticFeedback.lightImpact();
    }

    _startOffset = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: MilitaryColors.bgCard,
        border: Border.all(
          color: _isPressed 
              ? MilitaryColors.accent.withOpacity(0.6)
              : MilitaryColors.accent.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: _isPressed ? MilitaryColors.glowShadow : null,
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        onPanStart: _onPanStart,
        onPanEnd: _onPanEnd,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Centro
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isPressed 
                    ? MilitaryColors.accent.withOpacity(0.3)
                    : MilitaryColors.accent.withOpacity(0.1),
                border: Border.all(
                  color: MilitaryColors.accent.withOpacity(0.4),
                ),
              ),
              child: const Center(
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: MilitaryColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),

            // Direcciones (si están habilitadas)
            if (widget.showDirections) ...[
              // Arriba
              Positioned(
                top: 15,
                child: _directionIcon(Icons.keyboard_arrow_up_rounded),
              ),
              // Abajo
              Positioned(
                bottom: 15,
                child: _directionIcon(Icons.keyboard_arrow_down_rounded),
              ),
              // Izquierda
              Positioned(
                left: 15,
                child: _directionIcon(Icons.keyboard_arrow_left_rounded),
              ),
              // Derecha
              Positioned(
                right: 15,
                child: _directionIcon(Icons.keyboard_arrow_right_rounded),
              ),
            ],

            // Efecto de scan (línea que se mueve)
            Positioned.fill(
              child: ClipOval(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 2000),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        MilitaryColors.accent.withOpacity(0.05),
                        Colors.transparent,
                        MilitaryColors.accent.withOpacity(0.02),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _directionIcon(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: MilitaryColors.bgSurface,
      ),
      child: Icon(
        icon,
        color: MilitaryColors.accent.withOpacity(0.5),
        size: 20,
      ),
    );
  }
}
