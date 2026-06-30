import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/deep_ocean_colors.dart';
import '../../core/services/app_provider.dart';

class AccountsScreen extends StatefulWidget {
  final bool isSetup;
  
  const AccountsScreen({super.key, this.isSetup = false});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _serverController = TextEditingController();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _m3uController = TextEditingController();
  bool _isXtream = true;
  bool _showForm = false;

  @override
  void dispose() {
    _nameController.dispose();
    _serverController.dispose();
    _userController.dispose();
    _passController.dispose();
    _m3uController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AppProvider>();
    bool success;

    if (_isXtream) {
      success = await provider.addXtreamAccount(
        _nameController.text.trim(),
        _serverController.text.trim(),
        _userController.text.trim(),
        _passController.text.trim(),
      );
    } else {
      success = await provider.addM3uAccount(
        _nameController.text.trim(),
        _m3uController.text.trim(),
      );
    }

    if (success && mounted) {
      if (widget.isSetup) {
        // La app recargará automáticamente con el Consumer
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DeepOceanColors.bgPrimary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: DeepOceanColors.accentGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: DeepOceanColors.glowShadow,
                  ),
                  child: const Text(
                    'JOX3 TV PRO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ).animate().fadeIn().scale(delay: 100.ms),

                const SizedBox(height: 8),
                const Text(
                  'Deep Ocean Edition',
                  style: TextStyle(
                    color: DeepOceanColors.accentTeal,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 3,
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 40),

                if (!_showForm) ...[
                  // Botones de tipo de conexión
                  _buildConnectionTypeCard(
                    icon: Icons.dns_rounded,
                    title: 'Xtream Codes',
                    subtitle: 'Servidor + Usuario + Contraseña',
                    isSelected: _isXtream,
                    onTap: () => setState(() {
                      _isXtream = true;
                      _showForm = true;
                    }),
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                  
                  const SizedBox(height: 16),
                  
                  _buildConnectionTypeCard(
                    icon: Icons.link_rounded,
                    title: 'Lista M3U',
                    subtitle: 'URL de lista M3U/M3U8',
                    isSelected: !_isXtream,
                    onTap: () => setState(() {
                      _isXtream = false;
                      _showForm = true;
                    }),
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),

                  // Cuentas guardadas
                  Consumer<AppProvider>(
                    builder: (context, provider, _) {
                      if (provider.accounts.isEmpty) {
                        return const SizedBox();
                      }
                      return Column(
                        children: [
                          const SizedBox(height: 32),
                          const Divider(color: DeepOceanColors.bgCard),
                          const SizedBox(height: 16),
                          const Text(
                            'CUENTAS GUARDADAS',
                            style: TextStyle(
                              color: DeepOceanColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...provider.accounts.map((account) => _buildAccountTile(account)),
                        ],
                      );
                    },
                  ),
                ] else ...[
                  // Formulario
                  _buildForm().animate().fadeIn().slideY(begin: 0.1),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionTypeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: DeepOceanColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? DeepOceanColors.accent.withOpacity(0.5) 
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: DeepOceanColors.accentGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: DeepOceanColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: DeepOceanColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
              color: DeepOceanColors.textMuted, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botón atrás
          TextButton.icon(
            onPressed: () => setState(() => _showForm = false),
            icon: const Icon(Icons.arrow_back, color: DeepOceanColors.accent),
            label: const Text('Volver',
              style: TextStyle(color: DeepOceanColors.accent)),
          ),
          const SizedBox(height: 8),

          // Nombre
          _buildTextField(
            controller: _nameController,
            label: 'Nombre de la cuenta',
            icon: Icons.label_outline,
            hint: 'Ej: Mi IPTV',
          ),
          const SizedBox(height: 16),

          if (_isXtream) ...[
            // Servidor
            _buildTextField(
              controller: _serverController,
              label: 'Servidor',
              icon: Icons.dns_outlined,
              hint: 'http://servidor.com:8080',
            ),
            const SizedBox(height: 16),

            // Usuario
            _buildTextField(
              controller: _userController,
              label: 'Usuario',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),

            // Contraseña
            _buildTextField(
              controller: _passController,
              label: 'Contraseña',
              icon: Icons.lock_outline,
              isPassword: true,
            ),
          ] else ...[
            // URL M3U
            _buildTextField(
              controller: _m3uController,
              label: 'URL M3U',
              icon: Icons.link,
              hint: 'http://servidor.com/lista.m3u',
            ),
          ],

          const SizedBox(height: 24),

          // Error
          Consumer<AppProvider>(
            builder: (context, provider, _) {
              if (provider.error != null) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DeepOceanColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: DeepOceanColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                        color: DeepOceanColors.error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          provider.error!,
                          style: const TextStyle(
                            color: DeepOceanColors.error,
                            fontSize: 13,
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

          // Botón conectar
          Consumer<AppProvider>(
            builder: (context, provider, _) {
              return SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : _connect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DeepOceanColors.accent,
                    foregroundColor: DeepOceanColors.bgPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: DeepOceanColors.bgPrimary,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.power_settings_new, size: 22),
                            SizedBox(width: 10),
                            Text(
                              'CONECTAR',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: DeepOceanColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: DeepOceanColors.textSecondary),
        hintText: hint,
        hintStyle: const TextStyle(color: DeepOceanColors.textMuted),
        prefixIcon: Icon(icon, color: DeepOceanColors.accent.withOpacity(0.6)),
        filled: true,
        fillColor: DeepOceanColors.bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DeepOceanColors.accent, width: 1.5),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Este campo es requerido';
        }
        return null;
      },
    );
  }

  Widget _buildAccountTile(dynamic account) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: DeepOceanColors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: DeepOceanColors.accentGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 20),
        ),
        title: Text(
          account.name,
          style: const TextStyle(
            color: DeepOceanColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          account.type.name == 'xtream' ? 'Xtream Codes' : 'M3U',
          style: const TextStyle(
            color: DeepOceanColors.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios,
          color: DeepOceanColors.textMuted, size: 14),
        onTap: () {
          context.read<AppProvider>().switchAccount(account);
        },
      ),
    );
  }
}
