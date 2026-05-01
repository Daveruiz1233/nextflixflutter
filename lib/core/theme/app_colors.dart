import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF111118);
  static const Color card = Color(0xFF1A1A24);
  static const Color cardHover = Color(0xFF22222E);
  static const Color primary = Color(0xFFE50914);
  static const Color primaryHover = Color(0xFFF6121D);
  
  static const Color text = Color(0xFFE5E5E5);
  static const Color textMuted = Color(0xFF8A8A9A);
  static const Color textDim = Color(0xFF5A5A6A);

  static const Color glassBg = Color(0x0DFFFFFF); // rgba(255, 255, 255, 0.05)
  static const Color glassBorder = Color(0x1AFFFFFF); // rgba(255, 255, 255, 0.1)
  
  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFE5E5E5),
      Color(0xFF8A8A9A),
    ],
  );
}
