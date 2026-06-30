import 'package:flutter/material.dart';

/// 🌊 Deep Ocean Premium — Paleta de 12 colores
/// Diseñada para IPTV PRO JOX3
class DeepOceanColors {
  DeepOceanColors._();

  // ── Fondos (capas de profundidad oceánica) ──
  static const Color bgPrimary    = Color(0xFF0A0E1A); // Negro azulado profundo
  static const Color bgSecondary  = Color(0xFF111827); // Azul marino oscuro
  static const Color bgCard       = Color(0xFF1A2332); // Cards flotantes
  static const Color bgSurface    = Color(0xFF0F1923); // Superficie intermedia

  // ── Sistema de acentos (5 colores de marca) ──
  static const Color accent       = Color(0xFF00D4FF); // Cian eléctrico
  static const Color accentDark   = Color(0xFF0077B6); // Azul océano profundo
  static const Color accentTeal   = Color(0xFF00BFA6); // Turquesa
  static const Color accentIndigo = Color(0xFF6366F1); // Índigo
  static const Color accentGlow   = Color(0xFF00FFE0); // Aguamarina brillante
  static const Color accentWarm   = Color(0xFFF59E0B); // Ámbar dorado

  // ── Tipografía ──
  static const Color textPrimary   = Color(0xFFF0F4F8); // Blanco azulado
  static const Color textSecondary = Color(0xFF94A3B8); // Gris azulado
  static const Color textMuted     = Color(0xFF64748B); // Gris apagado

  // ── Estados ──
  static const Color liveBadge    = Color(0xFFFF1744); // Rojo LIVE
  static const Color favorite     = Color(0xFFFFD740); // Amarillo favorito
  static const Color success      = Color(0xFF10B981); // Verde éxito
  static const Color warning      = Color(0xFFF59E0B); // Ámbar advertencia
  static const Color error        = Color(0xFFEF4444); // Rojo error

  // ── Gradientes de marca ──
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentDark, accentIndigo],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glowGradient = LinearGradient(
    colors: [accentGlow, accent, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [accentWarm, Color(0xFFFF6B35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [bgCard, bgSurface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Sombras y efectos ──
  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: accent.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: -5,
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // ── Colores de categorías (géneros) ──
  static const Map<String, Color> categoryColors = {
    'ACCION':     Color(0xFFFF5252),
    'TERROR':     Color(0xFFD500F9),
    'COMEDIA':    Color(0xFFFFD740),
    'DRAMA':      Color(0xFF448AFF),
    'ANIMA':      Color(0xFFFF80AB),
    'INFANTIL':   Color(0xFFFF80AB),
    'SCI-FI':     Color(0xFF00D4FF),
    'ROMANCE':    Color(0xFFFF4FD8),
    'DOCUMENTAL': Color(0xFF69F0AE),
    'DEPORT':     Color(0xFFFFAB40),
    'NAVIDAD':    Color(0xFF4CAF50),
    'PREMIUM':    Color(0xFF6366F1),
    'MUSICA':     Color(0xFFE040FB),
    'NOTICIA':    Color(0xFF90A4AE),
    'RETRO':      Color(0xFFFF9E80),
  };

  /// Obtener color de categoría por nombre
  static Color getCategoryColor(String category) {
    final upper = category.toUpperCase();
    for (final entry in categoryColors.entries) {
      if (upper.contains(entry.key)) return entry.value;
    }
    // Fallback: rotar entre colores de marca
    const brandColors = [accent, accentDark, accentIndigo];
    return brandColors[upper.hashCode.abs() % brandColors.length];
  }
}
