import 'package:flutter/material.dart';

/// 🎖️ Military Tactical — Sistema de diseño futurista militar
class MilitaryColors {
  MilitaryColors._();

  // ── Fondos (capas tácticas) ──
  static const Color bgPrimary    = Color(0xFF0B0F0A);  // Negro militar profundo
  static const Color bgSecondary  = Color(0xFF141B12);  // Verde bosque oscuro
  static const Color bgCard       = Color(0xFF1A2318);  // Card militar
  static const Color bgSurface    = Color(0xFF0F1510);  // Superficie intermedia
  static const Color bgElevated   = Color(0xFF1E2A1B);  // Elevado

  // ── Acentos militares ──
  static const Color accent       = Color(0xFF4ADE80);  // Verde láser (principal)
  static const Color accentDark   = Color(0xFF16A34A);  // Verde militar
  static const Color accentOlive  = Color(0xFF6B8E23);  // Oliva
  static const Color accentAmber  = Color(0xFFFBBF24);  // Ámbar táctico
  static const Color accentRed    = Color(0xFFEF4444);  // Rojo alerta
  static const Color accentCyan   = Color(0xFF22D3EE);  // Cian HUD

  // ── Texto ──
  static const Color textPrimary   = Color(0xFFF0FDF4);  // Blanco militar
  static const Color textSecondary = Color(0xFF86EFAC);  // Verde claro
  static const Color textMuted     = Color(0xFF4ADE80);  // Verde apagado
  static const Color textDark      = Color(0xFF1A2318);  // Texto oscuro

  // ── Estados ──
  static const Color online   = Color(0xFF4ADE80);
  static const Color offline  = Color(0xFF6B7280);
  static const Color warning  = Color(0xFFFBBF24);
  static const Color danger   = Color(0xFFEF4444);

  // ── Gradientes ──
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF4ADE80), Color(0xFF16A34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A2318), Color(0xFF141B12)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient hudGradient = LinearGradient(
    colors: [Color(0xFF22D3EE), Color(0xFF4ADE80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Sombras y efectos ──
  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: accent.withOpacity(0.25),
      blurRadius: 20,
      spreadRadius: -5,
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.5),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get hudShadow => [
    BoxShadow(
      color: accentCyan.withOpacity(0.3),
      blurRadius: 12,
      spreadRadius: -3,
    ),
  ];
}
