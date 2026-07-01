import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/military_colors.dart';
import '../../core/services/tv_provider.dart';

class KeyboardScreen extends StatefulWidget {
  const KeyboardScreen({super.key});

  @override
  State<KeyboardScreen> createState() => _KeyboardScreenState();
}

class _KeyboardScreenState extends State<KeyboardScreen> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MilitaryColors.bgPrimary,
      appBar: AppBar(
        title: const Text(
          'KEYBOARD',
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Campo de texto
            Container(
              decoration: BoxDecoration(
                color: MilitaryColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: MilitaryColors.accent.withOpacity(0.3),
                ),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                style: const TextStyle(
                  color: MilitaryColors.textPrimary,
                  fontSize: 16,
                ),
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Escribe aquí para enviar al TV...',
                  hintStyle: TextStyle(color: MilitaryColors.textMuted),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final text = _textController.text;
                      if (text.isNotEmpty) {
                        context.read<TvProvider>().sendText(text);
                        _textController.clear();
                      }
                    },
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('ENVIAR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MilitaryColors.accent,
                      foregroundColor: MilitaryColors.bgPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _textController.clear(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MilitaryColors.bgCard,
                    foregroundColor: MilitaryColors.textMuted,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: MilitaryColors.accent.withOpacity(0.2)),
                    ),
                  ),
                  child: const Icon(Icons.clear_rounded, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Teclas rápidas
            const Text(
              'QUICK KEYS',
              style: TextStyle(
                color: MilitaryColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _quickKey('Enter', () => context.read<TvProvider>().sendText('\n')),
                _quickKey('Tab', () => context.read<TvProvider>().sendText('\t')),
                _quickKey('Space', () => context.read<TvProvider>().sendText(' ')),
                _quickKey('Backspace', () => context.read<TvProvider>().sendText('\b')),
                _quickKey('Esc', () => context.read<TvProvider>().sendText('\x1B')),
                _quickKey('Delete', () => context.read<TvProvider>().sendText('\x7F')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickKey(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: MilitaryColors.bgCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: MilitaryColors.accent.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: MilitaryColors.accent,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
