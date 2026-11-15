// lib/ozellikler/tanitim/sunum/tanitim_kontrolcusu.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/ayarlar/uygulama_tercihleri_servisi.dart';
import '../../../cekirdek/hatalar/merkezi_kaydedici.dart';

// Tanıtım (onboarding) ekranının tamamlanıp tamamlanmadığını tutan durum kontrolcüsü.
class TanitimDurumuKontrolcusu extends Notifier<bool> {
  final bool baslangicDegeri;

  TanitimDurumuKontrolcusu([this.baslangicDegeri = true]);

  @override
  bool build() => baslangicDegeri;

  void tamamlandiOlarakIsaretle() {
    state = true;
  }
}

// Tanıtım tamamlanma durumunu sağlayan Riverpod sağlayıcısı.
final tanitimDurumuSaglayici =
    NotifierProvider<TanitimDurumuKontrolcusu, bool>(
      TanitimDurumuKontrolcusu.new,
    );

// İlk açılış tanıtım ekranının tamamlanmasını yöneten kontrolcü.
class TanitimKontrolcusu extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  UygulamaTercihleriServisi get _tercihlerServisi =>
      ref.read(uygulamaTercihleriServisiSaglayici);

  Future<bool> tanitimiTamamla() async {
    state = const AsyncLoading();
    try {
      await _tercihlerServisi.tanitimTamamlandiKaydet(true);
      ref.read(tanitimDurumuSaglayici.notifier).tamamlandiOlarakIsaretle();
      state = const AsyncData(null);
      return true;
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Tanıtım tamamlanırken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
      state = AsyncError(hata, iz);
      return false;
    }
  }
}

// TanitimKontrolcusu sağlayıcısı.
final tanitimKontrolcusuSaglayici =
    NotifierProvider<TanitimKontrolcusu, AsyncValue<void>>(
      TanitimKontrolcusu.new,
    );
