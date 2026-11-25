// lib/cekirdek/tema/uygulama_renkleri.dart

import 'package:flutter/material.dart';

/// Tüm uygulamadaki Açık ve Koyu mod renk standartlarını yöneten merkezi sınıf.
/// Ekranlar ve bileşenler doğrudan renk kodu yazmaz; bu sınıfı çağırır.
class UygulamaRenkleri {
  UygulamaRenkleri._();

  // ==========================================
  // SABİT RENK DEĞERLERİ (AÇIK MOD)
  // ==========================================
  static const Color acikBirincil = Color(0xFF0D9488); // Zümrüt Yeşili (Teal 600)
  static const Color acikIkincil = Color(0xFF0284C7); // Kobalt / Gök Mavisi (Sky 600)
  static const Color acikArkaPlan = Color(0xFFF8FAFC); // Slate 50 (Yumuşak beyaz)
  static const Color acikKart = Color(0xFFFFFFFF); // Saf Beyaz
  static const Color acikKenarlik = Color(0xFFE2E8F0); // Slate 200
  static const Color acikMetinBirincil = Color(0xFF0F172A); // Slate 900
  static const Color acikMetinIkincil = Color(0xFF64748B); // Slate 500

  // ==========================================
  // SABİT RENK DEĞERLERİ (KOYU MOD - GECE MAVİSİ)
  // ==========================================
  static const Color koyuBirincil = Color(0xFF14B8A6); // Açık Zümrüt (Teal 500)
  static const Color koyuIkincil = Color(0xFF38BDF8); // Parlak Gökyüzü (Sky 400)
  static const Color koyuArkaPlan = Color(0xFF0F172A); // Slate 900 (Koyu Kömür / Derin Gece)
  static const Color koyuKart = Color(0xFF1E293B); // Slate 800 (Katman derinliği)
  static const Color koyuKenarlik = Color(0xFF334155); // Slate 700
  static const Color koyuMetinBirincil = Color(0xFFF8FAFC); // Slate 50
  static const Color koyuMetinIkincil = Color(0xFF94A3B8); // Slate 400

  // ==========================================
  // SEMANTİK / DURUM RENKLERİ (HER İKİ MOD İÇİN)
  // ==========================================
  static const Color kupaAltin = Color(0xFFF59E0B); // Amber 500
  static const Color kupaAltinKoyu = Color(0xFFFBBF24); // Amber 400
  static const Color basari = Color(0xFF10B981); // Emerald 500
  static const Color basariKoyu = Color(0xFF34D399); // Emerald 400
  static const Color tehlike = Color(0xFFEF4444); // Red 500
  static const Color tehlikeKoyu = Color(0xFFF87171); // Red 400

  // ==========================================
  // SOHBET BALONLARI
  // ==========================================
  static const Color acikBenimBalon = Color(0xFFCCFBF1); // Teal 100
  static const Color acikBenimBalonMetin = Color(0xFF115E59); // Teal 800
  static const Color acikBaskasiBalon = Color(0xFFFFFFFF); // Beyaz
  static const Color acikBaskasiBalonMetin = Color(0xFF0F172A); // Slate 900

  static const Color koyuBenimBalon = Color(0xFF134E4A); // Teal 900
  static const Color koyuBenimBalonMetin = Color(0xFFCCFBF1); // Teal 100
  static const Color koyuBaskasiBalon = Color(0xFF1E293B); // Slate 800
  static const Color koyuBaskasiBalonMetin = Color(0xFFF8FAFC); // Slate 50

  // ==========================================
  // BAĞLAMSAL (CONTEXT-AWARE) DİNAMİK GETTERLAR
  // ==========================================
  static bool koyuMu(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color birincil(BuildContext context) =>
      koyuMu(context) ? koyuBirincil : acikBirincil;

  static Color ikincil(BuildContext context) =>
      koyuMu(context) ? koyuIkincil : acikIkincil;

  static Color arkaPlan(BuildContext context) =>
      koyuMu(context) ? koyuArkaPlan : acikArkaPlan;

  static Color kartZemini(BuildContext context) =>
      koyuMu(context) ? koyuKart : acikKart;

  static Color kenarlik(BuildContext context) =>
      koyuMu(context) ? koyuKenarlik : acikKenarlik;

  static Color metinBirincil(BuildContext context) =>
      koyuMu(context) ? koyuMetinBirincil : acikMetinBirincil;

  static Color metinIkincil(BuildContext context) =>
      koyuMu(context) ? koyuMetinIkincil : acikMetinIkincil;

  static Color kupa(BuildContext context) =>
      koyuMu(context) ? kupaAltinKoyu : kupaAltin;

  static Color basariRengi(BuildContext context) =>
      koyuMu(context) ? basariKoyu : basari;

  static Color tehlikeRengi(BuildContext context) =>
      koyuMu(context) ? tehlikeKoyu : tehlike;

  static Color benimBalonZemin(BuildContext context) =>
      koyuMu(context) ? koyuBenimBalon : acikBenimBalon;

  static Color benimBalonMetin(BuildContext context) =>
      koyuMu(context) ? koyuBenimBalonMetin : acikBenimBalonMetin;

  static Color baskasiBalonZemin(BuildContext context) =>
      koyuMu(context) ? koyuBaskasiBalon : acikBaskasiBalon;

  static Color baskasiBalonMetin(BuildContext context) =>
      koyuMu(context) ? koyuBaskasiBalonMetin : acikBaskasiBalonMetin;
}
