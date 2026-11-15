// lib/ozellikler/tanitim/sunum/tanitim_kontrolcusu.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/ayarlar/uygulama_tercihleri_servisi.dart';
import '../../../cekirdek/bildirimler/bildirim_servisi.dart';
import '../../../cekirdek/hatalar/merkezi_kaydedici.dart';
import '../../ayarlar/alan/hatirlatici_deposu.dart';
import '../../ayarlar/sunum/ayarlar_kontrolcusu.dart';
import '../../ayarlar/veri/hatirlatici_deposu_uygulamasi.dart';
import '../../bugun/sunum/bugun_kontrolcusu.dart';
import '../../egzersizler/alan/egzersiz_deposu.dart';
import '../../egzersizler/alan/hazir_egzersiz_sablonu.dart';
import '../../egzersizler/sunum/egzersiz_kontrolcusu.dart';
import '../../egzersizler/veri/egzersiz_deposu_uygulamasi.dart';
import '../../rutinler/alan/rutin_deposu.dart';
import '../../rutinler/sunum/rutin_kontrolcusu.dart';
import '../../rutinler/veri/rutin_deposu_uygulamasi.dart';

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

// İlk açılış tanıtım adımlarını, izin istemeyi ve başlangıç rutini kurulumunu yöneten kontrolcü.
class TanitimKontrolcusu extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  EgzersizDeposu get _egzersizDeposu => ref.read(egzersizDeposuSaglayici);
  RutinDeposu get _rutinDeposu => ref.read(rutinDeposuSaglayici);
  HatirlaticiDeposu get _hatirlaticiDeposu =>
      ref.read(hatirlaticiDeposuSaglayici);
  BildirimServisi get _bildirimServisi => ref.read(bildirimServisiSaglayici);
  UygulamaTercihleriServisi get _tercihlerServisi =>
      ref.read(uygulamaTercihleriServisiSaglayici);

  Future<bool> bildirimIzniIste() async {
    final sonuc = await _bildirimServisi.izinIste();
    ref.invalidate(bildirimIzinDurumuSaglayici);
    return sonuc;
  }

  Future<bool> tanitimiTamamla({
    required TimeOfDay sabahSaati,
    required TimeOfDay aksamSaati,
    required List<HazirEgzersizSablonu> secilenSablonlar,
  }) async {
    state = const AsyncLoading();
    try {
      await _hatirlaticiDeposu.hatirlaticiGuncelle(
        etiket: 'sabah',
        saat: sabahSaati.hour,
        dakika: sabahSaati.minute,
        haftaninGunleri: '1,2,3,4,5,6,7',
        etkinMi: true,
      );
      await _hatirlaticiDeposu.hatirlaticiGuncelle(
        etiket: 'aksam',
        saat: aksamSaati.hour,
        dakika: aksamSaati.minute,
        haftaninGunleri: '1,2,3,4,5,6,7',
        etkinMi: true,
      );

      final hatirlaticilar = await _hatirlaticiDeposu.hatirlaticilariGetir();
      await _bildirimServisi.hatirlaticilariYenidenKur(hatirlaticilar);

      if (secilenSablonlar.isNotEmpty) {
        final eklenenIdler = <int>[];
        for (final sablon in secilenSablonlar) {
          final id = await _egzersizDeposu.egzersizEkle(
            ad: sablon.ad,
            aciklama: sablon.aciklama,
            tur: sablon.tur,
            sureSaniye: sablon.sureSaniye,
            setSayisi: sablon.setSayisi,
            tekrarSayisi: sablon.tekrarSayisi,
            kategori: sablon.kategori,
          );
          eklenenIdler.add(id);
        }

        await _rutinDeposu.rutinOlustur(
          ad: 'Başlangıç Rutinim',
          haftaninGunleri: '1,2,3,4,5,6,7',
          aktifMi: true,
          egzersizIdListesi: eklenenIdler,
        );
      }

      await _tercihlerServisi.tanitimTamamlandiKaydet(true);
      ref.read(tanitimDurumuSaglayici.notifier).tamamlandiOlarakIsaretle();

      ref.invalidate(aktifEgzersizlerAkisSaglayici);
      ref.invalidate(tumRutinlerAkisSaglayici);
      ref.invalidate(bugunKontrolcusuSaglayici);
      ref.invalidate(hatirlaticilarAkisSaglayici);

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
