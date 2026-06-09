import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF3158F6);
  static const secondary = Color(0xFF852DEB);
  static const bg = Color(0xFFF6F7FB);
  static const text = Color(0xFF111827);
  static const muted = Color(0xFF7B8190);
  static const card = Colors.white;
}

BoxDecoration cardDecoration({double radius = 18}) => BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 18, offset: const Offset(0, 8))],
    );

LinearGradient appGradient() => const LinearGradient(colors: [AppColors.primary, AppColors.secondary]);