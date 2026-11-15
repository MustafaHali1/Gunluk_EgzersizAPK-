// lib/ozellikler/rutinler/sunum/rutin_kontrolcusu.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/bildirimler/bildirim_servisi.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';
import '../../bugun/sunum/bugun_kontrolcusu.dart';
import '../alan/rutin_deposu.dart';
import '../veri/rutin_dao.dart';
import '../veri/rutin_deposu_uygulamasi.dart';

// Tüm rutinlerin akışını sağlayan Riverpod sağlayıcısı.
final tumRutinlerAkisSaglayici = StreamProvider<List<RutinlerData>>((ref) {
  final depo = ref.watch(rutinDeposuSaglayici);
  return depo.tumRutinleriIzle();
});

// Belirli bir rutinin görev detaylarını getiren sağlayıcı.
final rutinEgzersizleriSaglayici =
    FutureProvider.family<List<RutinEgzersizDetayi>, int>((ref, rutinId) {
      final depo = ref.watch(rutinDeposuSaglayici);
      return depo.rutinEgzersizleriniGetir(rutinId);
    });

// Rutin oluşturma, güncelleme, sıralama, alarm kurma ve silme işlemlerini yöneten kontrolcü.
class RutinKontrolcusu extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  RutinDeposu get _depo => ref.read(rutinDeposuSaglayici);
  BildirimServisi get _bildirimServisi => ref.read(bildirimServisiSaglayici);

  Future<void> _alarmlariGuncelle() async {
    final tumRutinler = await _depo.tumRutinleriGetir();
    await _bildirimServisi.rutinAlarmlariniYenidenKur(tumRutinler);
  }

  Future<bool> rutinKaydet({
    int? rutinId,
    required String ad,
    required List<int> seciliGunler,
    required bool aktifMi,
    required List<int> egzersizIdListesi,
    String? sadeceTarih,
    bool alarmAcikMi = false,
    int alarmSaati = 9,
    int alarmDakikasi = 0,
    String? alarmMuzikYolu,
    String? alarmMuzikAdi,
  }) async {
    state = const AsyncLoading();
    try {
      final siraliGunler = [...seciliGunler]..sort();
      final gunMetni = siraliGunler.join(',');

      if (alarmAcikMi) {
        await _bildirimServisi.izinIste();
      }

      if (rutinId == null) {
        await _depo.rutinOlustur(
          ad: ad,
          haftaninGunleri: gunMetni,
          aktifMi: aktifMi,
          egzersizIdListesi: egzersizIdListesi,
          sadeceTarih: sadeceTarih,
          alarmAcikMi: alarmAcikMi,
          alarmSaati: alarmSaati,
          alarmDakikasi: alarmDakikasi,
          alarmMuzikYolu: alarmMuzikYolu,
          alarmMuzikAdi: alarmMuzikAdi,
        );
      } else {
        await _depo.rutinGuncelle(
          rutinId: rutinId,
          ad: ad,
          haftaninGunleri: gunMetni,
          aktifMi: aktifMi,
          egzersizIdListesi: egzersizIdListesi,
          sadeceTarih: sadeceTarih,
          alarmAcikMi: alarmAcikMi,
          alarmSaati: alarmSaati,
          alarmDakikasi: alarmDakikasi,
          alarmMuzikYolu: alarmMuzikYolu,
          alarmMuzikAdi: alarmMuzikAdi,
        );
        ref.invalidate(rutinEgzersizleriSaglayici(rutinId));
      }
      await _alarmlariGuncelle();
      ref.invalidate(bugunKontrolcusuSaglayici);
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
      ref.invalidate(bugunKontrolcusuSaglayici);
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
      await _alarmlariGuncelle();
      ref.invalidate(bugunKontrolcusuSaglayici);
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
