import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/military_colors.dart';
import '../../core/models/tv_device.dart';
import '../../core/services/tv_provider.dart';
import '../remote/remote_screen.dart';

class TvConnectScreen extends StatefulWidget {
  const TvConnectScreen({super.key});

  @override
  State<TvConnectScreen> createState() => _TvConnectScreenState();
}

class _TvConnectScreenState extends State<TvConnectScreen> {
  final _ipController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedBrand = 'Samsung';
  bool _showForm = false;

  @override
  void dispose() {
    _ipController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _connectWifi() async {
    if (_ipController.text.isEmpty) return;

    final provider = context.read<TvProvider>();
    final device = TvDevice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.isNotEmpty 
          ? _nameController.text 
          : '$_selectedBrand TV',
      brand: _selectedBrand,
      ip: _ipController.text.trim(),
      connectionType: TvConnectionType.wifi,
    );

    await provider.saveDevice(device);
    final success = await provider.connectWifi(device);

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RemoteScreen()),
      );
    }
  }

  void _connectIr() {
    final provider = context.read<TvProvider>();
    final device = TvDevice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.isNotEmpty 
          ? _nameController.text 
          : '$_selectedBrand TV (IR)',
      brand: _selectedBrand,
      connectionType: TvConnectionType.ir,
    );

    provider.saveDevice(device);
    provider.connectIr(device);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RemoteScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MilitaryColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Logo
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: MilitaryColors.accentGradient,
                        boxShadow: MilitaryColors.glowShadow,
                      ),
                      child: const Icon(
                        Icons.settings_remote_rounded,
                        color: MilitaryColors.bgPrimary,
                        size: 40,
                      ),
                    ).animate().fadeIn().scale(delay: 100.ms),
                    const SizedBox(height: 16),
                    const Text(
                      'TV REMOTE',
                      style: TextStyle(
                        color: MilitaryColors.accent,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    const Text(
                      'PRO • MILITARY EDITION',
                      style: TextStyle(
                        color: MilitaryColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4,
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // Selector de marca
              const Text(
                'SELECT TARGET',
                style: TextStyle(
                  color: MilitaryColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                ),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 12),
              Row(
                children: [
                  _brandButton('Samsung', Icons.tv_rounded),
                  const SizedBox(width: 12),
                  _brandButton('LG', Icons.live_tv_rounded),
                ],
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 30),

              // Dispositivos guardados
              Consumer<TvProvider>(
                builder: (context, provider, _) {
                  if (provider.savedDevices.isEmpty) {
                    return const SizedBox();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SAVED DEVICES',
                        style: TextStyle(
                          color: MilitaryColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...provider.savedDevices.map((device) => _savedDeviceTile(device, provider)),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),

              // Formulario
              if (!_showForm) ...[
                // Botones de conexión
                _connectButton(
                  icon: Icons.wifi_rounded,
                  label: 'CONNECT VIA WIFI',
                  subtitle: 'Smart TV en la misma red',
                  onPressed: () => setState(() => _showForm = true),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 16),

                Consumer<TvProvider>(
                  builder: (context, provider, _) {
                    if (!provider.hasIrBlaster) return const SizedBox();
                    return _connectButton(
                      icon: Icons.sensors_rounded,
                      label: 'CONNECT VIA IR',
                      subtitle: 'Infrarrojo — sin WiFi',
                      color: MilitaryColors.accentAmber,
                      onPressed: () {
                        setState(() => _showForm = true);
                      },
                    ).animate().fadeIn(delay: 700.ms);
                  },
                ),
              ] else ...[
                // Formulario de conexión
                _buildForm().animate().fadeIn().slideY(begin: 0.1),
              ],

              const SizedBox(height: 40),

              // Info
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MilitaryColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: MilitaryColors.accent.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: MilitaryColors.accentCyan,
                        size: 20,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Para WiFi: TV y celular en la misma red\nPara IR: apunta al TV como control normal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: MilitaryColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _brandButton(String brand, IconData icon) {
    final isSelected = _selectedBrand == brand;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedBrand = brand),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected 
                ? MilitaryColors.accent.withOpacity(0.1) 
                : MilitaryColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? MilitaryColors.accent.withOpacity(0.5) 
                  : MilitaryColors.bgCard,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected 
                    ? MilitaryColors.accent 
                    : MilitaryColors.textMuted,
                size: 28,
              ),
              const SizedBox(height: 6),
              Text(
                brand.toUpperCase(),
                style: TextStyle(
                  color: isSelected 
                      ? MilitaryColors.accent 
                      : MilitaryColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _connectButton({
    required IconData icon,
    required String label,
    required String subtitle,
    Color? color,
    required VoidCallback onPressed,
  }) {
    final btnColor = color ?? MilitaryColors.accent;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MilitaryColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: btnColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [btnColor, btnColor.withOpacity(0.7)],
                ),
              ),
              child: Icon(icon, color: MilitaryColors.bgPrimary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: btnColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: MilitaryColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: btnColor.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _savedDeviceTile(TvDevice device, TvProvider provider) {
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
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: MilitaryColors.accentGradient,
          ),
          child: Icon(
            device.brand == 'Samsung' ? Icons.tv_rounded : Icons.live_tv_rounded,
            color: MilitaryColors.bgPrimary,
            size: 20,
          ),
        ),
        title: Text(
          device.name,
          style: const TextStyle(
            color: MilitaryColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          '${device.brand} • ${device.ip ?? "IR"}',
          style: const TextStyle(
            color: MilitaryColors.textMuted,
            fontSize: 11,
          ),
        ),
        trailing: IconButton(
          onPressed: () => provider.removeDevice(device),
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: MilitaryColors.danger,
            size: 18,
          ),
        ),
        onTap: () {
          if (device.connectionType == TvConnectionType.ir) {
            provider.connectIr(device);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const RemoteScreen()),
            );
          } else {
            provider.connectWifi(device).then((success) {
              if (success && mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const RemoteScreen()),
                );
              }
            });
          }
        },
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        // IP
        TextField(
          controller: _ipController,
          style: const TextStyle(color: MilitaryColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'IP DEL TV',
            labelStyle: const TextStyle(
              color: MilitaryColors.textMuted,
              letterSpacing: 1,
            ),
            hintText: '192.168.1.xxx',
            hintStyle: const TextStyle(color: MilitaryColors.textMuted),
            prefixIcon: const Icon(Icons.language_rounded, 
              color: MilitaryColors.accent),
            filled: true,
            fillColor: MilitaryColors.bgCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: MilitaryColors.accent, width: 1.5),
            ),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),

        // Nombre
        TextField(
          controller: _nameController,
          style: const TextStyle(color: MilitaryColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'NOMBRE (opcional)',
            labelStyle: const TextStyle(
              color: MilitaryColors.textMuted,
              letterSpacing: 1,
            ),
            hintText: 'Mi Samsung TV',
            hintStyle: const TextStyle(color: MilitaryColors.textMuted),
            prefixIcon: const Icon(Icons.label_outline_rounded, 
              color: MilitaryColors.accent),
            filled: true,
            fillColor: MilitaryColors.bgCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: MilitaryColors.accent, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Error
        Consumer<TvProvider>(
          builder: (context, provider, _) {
            if (provider.error != null) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MilitaryColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: MilitaryColors.danger.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                      color: MilitaryColors.danger, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        provider.error!,
                        style: const TextStyle(
                          color: MilitaryColors.danger,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),

        // Botones
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _connectWifi,
                icon: const Icon(Icons.wifi_rounded, size: 18),
                label: const Text('WIFI'),
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
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _connectIr,
                icon: const Icon(Icons.sensors_rounded, size: 18),
                label: const Text('IR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MilitaryColors.accentAmber,
                  foregroundColor: MilitaryColors.bgPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _showForm = false),
          child: const Text(
            'CANCELAR',
            style: TextStyle(
              color: MilitaryColors.textMuted,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }
}
