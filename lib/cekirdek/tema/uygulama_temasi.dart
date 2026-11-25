// lib/cekirdek/tema/uygulama_temasi.dart

import 'package:flutter/material.dart';
import 'uygulama_renkleri.dart';

/// Açık ve koyu tema yapılandırmalarını sağlayan sınıf.
class UygulamaTemasi {
  UygulamaTemasi._();

  static ThemeData get acikTema {
    final renkSemasi = ColorScheme.light(
      primary: UygulamaRenkleri.acikBirincil,
      secondary: UygulamaRenkleri.acikIkincil,
      surface: UygulamaRenkleri.acikKart,
      error: UygulamaRenkleri.tehlike,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: UygulamaRenkleri.acikMetinBirincil,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: renkSemasi,
      scaffoldBackgroundColor: UygulamaRenkleri.acikArkaPlan,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: UygulamaRenkleri.acikBirincil,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: UygulamaRenkleri.acikKart,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: UygulamaRenkleri.acikKenarlik, width: 1),
        ),
      ),
      dividerColor: UygulamaRenkleri.acikKenarlik,
    );
  }

  static ThemeData get koyuTema {
    final renkSemasi = ColorScheme.dark(
      primary: UygulamaRenkleri.koyuBirincil,
      secondary: UygulamaRenkleri.koyuIkincil,
      surface: UygulamaRenkleri.koyuKart,
      error: UygulamaRenkleri.tehlikeKoyu,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: UygulamaRenkleri.koyuMetinBirincil,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: renkSemasi,
      scaffoldBackgroundColor: UygulamaRenkleri.koyuArkaPlan,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: UygulamaRenkleri.koyuKart,
        foregroundColor: UygulamaRenkleri.koyuMetinBirincil,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: UygulamaRenkleri.koyuKart,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: UygulamaRenkleri.koyuKenarlik, width: 1),
        ),
      ),
      dividerColor: UygulamaRenkleri.koyuKenarlik,
    );
  }
}
