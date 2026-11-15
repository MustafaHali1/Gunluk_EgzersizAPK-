// lib/cekirdek/tema/uygulama_temasi.dart

import 'package:flutter/material.dart';

// Açık ve koyu tema yapılandırmalarını sağlayan sınıf.
class UygulamaTemasi {
  UygulamaTemasi._();

  static const Color anaRenk = Color(0xFF0D9488);
  static const Color ikincilRenk = Color(0xFF0284C7);

  static ThemeData get acikTema {
    final renkSemasi = ColorScheme.fromSeed(
      seedColor: anaRenk,
      secondary: ikincilRenk,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: renkSemasi,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: renkSemasi.surface,
        foregroundColor: renkSemasi.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData get koyuTema {
    final renkSemasi = ColorScheme.fromSeed(
      seedColor: anaRenk,
      secondary: ikincilRenk,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: renkSemasi,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: renkSemasi.surface,
        foregroundColor: renkSemasi.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
