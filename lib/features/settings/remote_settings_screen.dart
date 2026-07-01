import 'package:flutter/material.dart';
import '../../core/theme/military_colors.dart';

class RemoteSettingsScreen extends StatelessWidget {
  const RemoteSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MilitaryColors.bgPrimary,
      appBar: AppBar(
        title: const Text(
          'SETTINGS',
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _settingTile(
            icon: Icons.vibration_rounded,
            title: 'Vibración',
            subtitle: 'Vibrar al presionar botones',
            trailing: Switch(
              value: true,
              onChanged: (v) {},
              activeColor: MilitaryColors.accent,
            ),
          ),
          _settingTile(
            icon: Icons.dark_mode_rounded,
            title: 'Tema',
            subtitle: 'Military Dark',
            trailing: const Text(
              'ACTIVO',
              style: TextStyle(
                color: MilitaryColors.accent,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
          _settingTile(
            icon: Icons.info_outline_rounded,
            title: 'Versión',
            subtitle: '1.0.0 — Military Edition',
          ),
          _settingTile(
            icon: Icons.code_rounded,
            title: 'Build',
            subtitle: 'Flutter + Dart',
          ),
        ],
      ),
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: MilitaryColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MilitaryColors.accent.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: MilitaryColors.accent, size: 20),
        title: Text(
          title,
          style: const TextStyle(
            color: MilitaryColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(
                  color: MilitaryColors.textMuted,
                  fontSize: 11,
                ),
              )
            : null,
        trailing: trailing,
      ),
    );
  }
}
