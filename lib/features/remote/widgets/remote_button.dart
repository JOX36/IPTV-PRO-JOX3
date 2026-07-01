import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/military_colors.dart';

class RemoteButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onPressed;
  final double size;
  final bool isCircular;

  const RemoteButton({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    this.onPressed,
    this.size = 48,
    this.isCircular = false,
  });

  @override
  State<RemoteButton> createState() => _RemoteButtonState();
}

class _RemoteButtonState extends State<RemoteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? MilitaryColors.accent;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: _isPressed 
                ? buttonColor.withOpacity(0.2)
                : MilitaryColors.bgCard,
            borderRadius: BorderRadius.circular(widget.isCircular ? 26 : 12),
            border: Border.all(
              color: _isPressed 
                  ? buttonColor.withOpacity(0.6)
                  : buttonColor.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: _isPressed ? [
              BoxShadow(
                color: buttonColor.withOpacity(0.3),
                blurRadius: 12,
              ),
            ] : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: _isPressed 
                    ? buttonColor 
                    : buttonColor.withOpacity(0.8),
                size: widget.size * 0.45,
              ),
              const SizedBox(height: 2),
              Text(
                widget.label,
                style: TextStyle(
                  color: _isPressed 
                      ? buttonColor 
                      : buttonColor.withOpacity(0.6),
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget? child;
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
