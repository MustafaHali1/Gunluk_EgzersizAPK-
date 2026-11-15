// lib/ozellikler/rutinler/sunum/rutin_kontrolcusu.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';
import '../alan/rutin_deposu.dart';
import '../veri/rutin_dao.dart';
import '../veri/rutin_deposu_uygulamasi.dart';

// Tüm rutinlerin akışını sağlayan Riverpod sağlayıcısı.
final tumRutinlerAkisSaglayici = StreamProvider<List<RutinlerData>>((ref) {
  final depo = ref.watch(rutinDeposuSaglayici);
  return depo.tumRutinleriIzle();
});

// Belirli bir rutinin egzersiz detaylarını getiren sağlayıcı.
final rutinEgzersizleriSaglayici =
    FutureProvider.family<List<RutinEgzersizDetayi>, int>((ref, rutinId) {
  final depo = ref.watch(rutinDeposuSaglayici);
  return depo.rutinEgzersizleriniGetir(rutinId);
});

// Rutin oluşturma, güncelleme, sıralama, aktif rutin seçimi ve silme işlemlerini yöneten kontrolcü.
class RutinKontrolcusu extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  RutinDeposu get _depo => ref.read(rutinDeposuSaglayici);

  Future<bool> rutinKaydet({
    int? rutinId,
    required String ad,
    required List<int> seciliGunler,
    required bool aktifMi,
    required List<int> egzersizIdListesi,
  }) async {
    state = const AsyncLoading();
    try {
      final siraliGunler = [...seciliGunler]..sort();
      final gunMetni = siraliGunler.join(',');

      if (rutinId == null) {
        await _depo.rutinOlustur(
          ad: ad,
          haftaninGunleri: gunMetni,
          aktifMi: aktifMi,
          egzersizIdListesi: egzersizIdListesi,
        );
      } else {
        await _depo.rutinGuncelle(
          rutinId: rutinId,
          ad: ad,
          haftaninGunleri: gunMetni,
          aktifMi: aktifMi,
          egzersizIdListesi: egzersizIdListesi,
        );
        ref.invalidate(rutinEgzersizleriSaglayici(rutinId));
      }
      state = const AsyncData(null);
      return true;
    } catch (hata, iz) {
      state = AsyncError(hata, iz);
      return false;
    }
  }

  Future<bool> aktifRutiniBelirle(int rutinId) async {
    state = const AsyncLoading();
    try {
      await _depo.aktifRutiniBelirle(rutinId);
      state = const AsyncData(null);
      return true;
    } catch (hata, iz) {
      state = AsyncError(hata, iz);
      return false;
    }
  }

  Future<bool> rutinSil(int rutinId) async {
    state = const AsyncLoading();
    try {
      await _depo.rutinSil(rutinId);
      state = const AsyncData(null);
      return true;
    } catch (hata, iz) {
      state = AsyncError(hata, iz);
      return false;
    }
  }
}

// RutinKontrolcusu sağlayıcısı.
final rutinKontrolcusuSaglayici =
    NotifierProvider<RutinKontrolcusu, AsyncValue<void>>(
  RutinKontrolcusu.new,
);
