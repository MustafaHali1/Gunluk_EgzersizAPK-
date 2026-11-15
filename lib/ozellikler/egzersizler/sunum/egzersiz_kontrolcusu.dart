// lib/ozellikler/egzersizler/sunum/egzersiz_kontrolcusu.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';
import '../alan/egzersiz_deposu.dart';
import '../alan/hazir_egzersiz_sablonu.dart';
import '../veri/egzersiz_deposu_uygulamasi.dart';

// Aktif egzersizlerin akışını sağlayan Riverpod sağlayıcısı.
final aktifEgzersizlerAkisSaglayici =
    StreamProvider<List<EgzersizlerData>>((ref) {
  final depo = ref.watch(egzersizDeposuSaglayici);
  return depo.aktifEgzersizleriIzle();
});

// Egzersiz ekleme, düzenleme, hazır şablondan ekleme ve arşivleme işlemlerini yöneten kontrolcü.
class EgzersizKontrolcusu extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  EgzersizDeposu get _depo => ref.read(egzersizDeposuSaglayici);

  Future<bool> egzersizKaydet({
    int? id,
    required String ad,
    required String aciklama,
    required String tur,
    int? sureSaniye,
    int? setSayisi,
    int? tekrarSayisi,
    required String kategori,
  }) async {
    state = const AsyncLoading();
    try {
      if (id == null) {
        await _depo.egzersizEkle(
          ad: ad,
          aciklama: aciklama,
          tur: tur,
          sureSaniye: sureSaniye,
          setSayisi: setSayisi,
          tekrarSayisi: tekrarSayisi,
          kategori: kategori,
        );
      } else {
        await _depo.egzersizGuncelle(
          id: id,
          ad: ad,
          aciklama: aciklama,
          tur: tur,
          sureSaniye: sureSaniye,
          setSayisi: setSayisi,
          tekrarSayisi: tekrarSayisi,
          kategori: kategori,
        );
      }
      state = const AsyncData(null);
      return true;
    } catch (hata, iz) {
      state = AsyncError(hata, iz);
      return false;
    }
  }

  Future<bool> sablondanEgzersizEkle(HazirEgzersizSablonu sablon) async {
    return egzersizKaydet(
      ad: sablon.ad,
      aciklama: sablon.aciklama,
      tur: sablon.tur,
      sureSaniye: sablon.sureSaniye,
      setSayisi: sablon.setSayisi,
      tekrarSayisi: sablon.tekrarSayisi,
      kategori: sablon.kategori,
    );
  }

  Future<bool> egzersizArsivle(int id) async {
    state = const AsyncLoading();
    try {
      await _depo.egzersizArsivle(id);
      state = const AsyncData(null);
      return true;
    } catch (hata, iz) {
      state = AsyncError(hata, iz);
      return false;
    }
  }
}

// EgzersizKontrolcusu sağlayıcısı.
final egzersizKontrolcusuSaglayici =
    NotifierProvider<EgzersizKontrolcusu, AsyncValue<void>>(
  EgzersizKontrolcusu.new,
);
