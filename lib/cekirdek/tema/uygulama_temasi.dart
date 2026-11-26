// lib/cekirdek/tema/uygulama_temasi.dart

import 'package:flutter/material.dart';
import 'uygulama_renkleri.dart';

/// Açık (Editorial Crisp) ve Koyu (Obsidian Titanium) tema yapılandırmalarını sağlayan merkezi sınıf.
class UygulamaTemasi {
  UygulamaTemasi._();

  static ThemeData get acikTema {
    const renkSemasi = ColorScheme.light(
      primary: UygulamaRenkleri.acikBirincil,
      secondary: UygulamaRenkleri.acikIkincil,
      surface: UygulamaRenkleri.acikKart,
      error: UygulamaRenkleri.tehlike,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: UygulamaRenkleri.acikMetinBirincil,
      onSurfaceVariant: UygulamaRenkleri.acikMetinIkincil,
      outline: UygulamaRenkleri.acikKenarlik,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: renkSemasi,
      scaffoldBackgroundColor: UygulamaRenkleri.acikArkaPlan,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: UygulamaRenkleri.acikKart,
        foregroundColor: UygulamaRenkleri.acikMetinBirincil,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: UygulamaRenkleri.acikKart,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: UygulamaRenkleri.acikKart,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      cardTheme: CardThemeData(
        color: UygulamaRenkleri.acikKart,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: UygulamaRenkleri.acikKenarlik, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: UygulamaRenkleri.acikYukseltilmis,
        labelStyle: const TextStyle(color: UygulamaRenkleri.acikMetinIkincil),
        hintStyle: const TextStyle(color: UygulamaRenkleri.acikMetinIkincil),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: UygulamaRenkleri.acikKenarlik),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: UygulamaRenkleri.acikBirincil, width: 1.8),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: UygulamaRenkleri.acikKart,
        surfaceTintColor: Colors.transparent,
        indicatorColor: UygulamaRenkleri.acikBirincil.withValues(alpha: 0.14),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: UygulamaRenkleri.acikBirincil);
          }
          return const IconThemeData(color: UygulamaRenkleri.acikMetinIkincil);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: UygulamaRenkleri.acikBirincil,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: UygulamaRenkleri.acikMetinIkincil,
          );
        }),
      ),
      dividerColor: UygulamaRenkleri.acikKenarlik,
    );
  }

  static ThemeData get koyuTema {
    const renkSemasi = ColorScheme.dark(
      primary: UygulamaRenkleri.koyuBirincil,
      secondary: UygulamaRenkleri.koyuIkincil,
      surface: UygulamaRenkleri.koyuKart,
      error: UygulamaRenkleri.tehlikeKoyu,
      onPrimary: Color(0xFF042F1E),
      onSecondary: Colors.black,
      onSurface: UygulamaRenkleri.koyuMetinBirincil,
      onSurfaceVariant: UygulamaRenkleri.koyuMetinIkincil,
      outline: UygulamaRenkleri.koyuKenarlik,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: renkSemasi,
      scaffoldBackgroundColor: UygulamaRenkleri.koyuArkaPlan,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: UygulamaRenkleri.koyuKart,
        foregroundColor: UygulamaRenkleri.koyuMetinBirincil,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: UygulamaRenkleri.koyuKart,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: UygulamaRenkleri.koyuKart,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      cardTheme: CardThemeData(
        color: UygulamaRenkleri.koyuKart,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: UygulamaRenkleri.koyuKenarlik, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: UygulamaRenkleri.koyuYukseltilmis,
        labelStyle: const TextStyle(color: UygulamaRenkleri.koyuMetinIkincil),
        hintStyle: const TextStyle(color: UygulamaRenkleri.koyuMetinIkincil),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: UygulamaRenkleri.koyuKenarlik),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: UygulamaRenkleri.koyuBirincil, width: 1.8),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: UygulamaRenkleri.koyuKart,
        surfaceTintColor: Colors.transparent,
        indicatorColor: UygulamaRenkleri.koyuBirincil.withValues(alpha: 0.16),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: UygulamaRenkleri.koyuBirincil);
          }
          return const IconThemeData(color: UygulamaRenkleri.koyuMetinIkincil);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: UygulamaRenkleri.koyuBirincil,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: UygulamaRenkleri.koyuMetinIkincil,
          );
        }),
      ),
      dividerColor: UygulamaRenkleri.koyuKenarlik,
    );
  }
}
