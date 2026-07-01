import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/military_colors.dart';
import '../../../core/models/tv_device.dart';
import '../../../core/services/tv_provider.dart';

class ColorButtons extends StatelessWidget {
  const ColorButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TvProvider>(
      builder: (context, provider, _) {
        return Row(
          children: [
            _colorButton(
              color: const Color(0xFFEF4444),
              label: 'R',
              onPressed: () => provider.sendCommand(RemoteCommand.red),
            ),
            const SizedBox(width: 8),
            _colorButton(
              color: const Color(0xFF22C55E),
              label: 'G',
              onPressed: () => provider.sendCommand(RemoteCommand.green),
            ),
            const SizedBox(width: 8),
            _colorButton(
              color: const Color(0xFFFBBF24),
              label: 'Y',
              onPressed: () => provider.sendCommand(RemoteCommand.yellow),
            ),
            const SizedBox(width: 8),
            _colorButton(
              color: const Color(0xFF3B82F6),
              label: 'B',
              onPressed: () => provider.sendCommand(RemoteCommand.blue),
            ),
          ],
        );
      },
    );
  }

  Widget _colorButton({
    required Color color,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withOpacity(0.4),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
