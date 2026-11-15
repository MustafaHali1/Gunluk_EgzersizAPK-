// lib/cekirdek/ayarlar/uygulama_tercihleri_servisi.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Tema, saat dilimi ve tanıtım durumu gibi yerel tercihleri yöneten servis sınıfı.
class UygulamaTercihleriServisi {
  static const String _anahtarTemaModu = 'tercih_tema_modu';
  static const String _anahtarSonSaatDilimi = 'tercih_son_saat_dilimi';
  static const String _anahtarTanitimTamamlandi = 'tercih_tanitim_tamamlandi';

  Future<ThemeMode> temaModunuGetir() async {
    final tercihler = await SharedPreferences.getInstance();
    final deger = tercihler.getString(_anahtarTemaModu) ?? 'sistem';
    return _metindenTemaModuna(deger);
  }

  Future<void> temaModunuKaydet(ThemeMode mod) async {
    final tercihler = await SharedPreferences.getInstance();
    await tercihler.setString(_anahtarTemaModu, _temaModundanMetne(mod));
  }

  Future<String?> sonSaatDiliminiGetir() async {
    final tercihler = await SharedPreferences.getInstance();
    return tercihler.getString(_anahtarSonSaatDilimi);
  }

  Future<void> sonSaatDiliminiKaydet(String saatDilimiAnahtari) async {
    final tercihler = await SharedPreferences.getInstance();
    await tercihler.setString(_anahtarSonSaatDilimi, saatDilimiAnahtari);
  }

  Future<bool> tanitimTamamlandiMiGetir() async {
    final tercihler = await SharedPreferences.getInstance();
    return tercihler.getBool(_anahtarTanitimTamamlandi) ?? false;
  }

  Future<void> tanitimTamamlandiKaydet(bool deger) async {
    final tercihler = await SharedPreferences.getInstance();
    await tercihler.setBool(_anahtarTanitimTamamlandi, deger);
  }

  ThemeMode _metindenTemaModuna(String deger) {
    switch (deger) {
      case 'acik':
        return ThemeMode.light;
      case 'koyu':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _temaModundanMetne(ThemeMode mod) {
    switch (mod) {
      case ThemeMode.light:
        return 'acik';
      case ThemeMode.dark:
        return 'koyu';
      case ThemeMode.system:
        return 'sistem';
    }
  }
}

// UygulamaTercihleriServisi sağlayıcısı.
final uygulamaTercihleriServisiSaglayici = Provider<UygulamaTercihleriServisi>(
  (ref) => UygulamaTercihleriServisi(),
);

// Uygulamanın aktif tema modunu (Açık / Koyu / Sistem) yöneten kontrolcü.
class TemaModuKontrolcusu extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _baslangicTemasiniYukle();
    return ThemeMode.system;
  }

  Future<void> _baslangicTemasiniYukle() async {
    final servis = ref.read(uygulamaTercihleriServisiSaglayici);
    final kayitliMod = await servis.temaModunuGetir();
    if (state != kayitliMod) {
      state = kayitliMod;
    }
  }

  Future<void> temaModunuDegistir(ThemeMode yeniMod) async {
    state = yeniMod;
    final servis = ref.read(uygulamaTercihleriServisiSaglayici);
    await servis.temaModunuKaydet(yeniMod);
  }
}

// TemaModuKontrolcusu sağlayıcısı.
final temaModuKontrolcusuSaglayici =
    NotifierProvider<TemaModuKontrolcusu, ThemeMode>(TemaModuKontrolcusu.new);
