// lib/ozellikler/rutinler/veri/rutin_deposu_uygulamasi.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/hatalar/merkezi_kaydedici.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';
import '../alan/rutin_deposu.dart';
import 'rutin_dao.dart';

// RutinDeposu arayüzünün Drift DAO kullanan somut uygulaması.
class RutinDeposuUygulamasi implements RutinDeposu {
  final RutinDao _dao;

  const RutinDeposuUygulamasi(this._dao);

  @override
  Stream<List<RutinlerData>> tumRutinleriIzle() {
    return _dao.tumRutinleriIzle().handleError((Object hata, StackTrace iz) {
      MerkeziKaydedici.hataYaz(
        'Rutinler izlenirken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Rutin listesi yüklenemedi.');
    });
  }

  @override
  Future<List<RutinlerData>> tumRutinleriGetir() async {
    try {
      return await _dao.tumRutinleriGetir();
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Rutinler getirilirken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Rutinler alınırken bir hata oluştu.');
    }
  }

  @override
  Future<RutinlerData?> aktifRutiniGetir() async {
    try {
      return await _dao.aktifRutiniGetir();
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Aktif rutin getirilirken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Aktif rutin bilgisi alınamadı.');
    }
  }

  @override
  Stream<RutinlerData?> aktifRutiniIzle() {
    return _dao.aktifRutiniIzle().handleError((Object hata, StackTrace iz) {
      MerkeziKaydedici.hataYaz(
        'Aktif rutin izlenirken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Aktif rutin izlenemedi.');
    });
  }

  @override
  Future<int> rutinOlustur({
    required String ad,
    required String haftaninGunleri,
    required bool aktifMi,
    required List<int> egzersizIdListesi,
  }) async {
    try {
      return await _dao.rutinOlusturVeEgzersizleriKaydet(
        ad: ad.trim(),
        haftaninGunleri: haftaninGunleri,
        aktifMi: aktifMi,
        egzersizIdListesi: egzersizIdListesi,
      );
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Rutin oluşturulurken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Rutin kaydedilemedi.');
    }
  }

  @override
  Future<void> rutinGuncelle({
    required int rutinId,
    required String ad,
    required String haftaninGunleri,
    required bool aktifMi,
    required List<int> egzersizIdListesi,
  }) async {
    try {
      await _dao.rutinVeEgzersizleriGuncelle(
        rutinId: rutinId,
        ad: ad.trim(),
        haftaninGunleri: haftaninGunleri,
        aktifMi: aktifMi,
        egzersizIdListesi: egzersizIdListesi,
      );
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Rutin güncellenirken hata oluştu (id: $rutinId)',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Rutin güncellenemedi.');
    }
  }

  @override
  Future<void> aktifRutiniBelirle(int rutinId) async {
    try {
      await _dao.aktifRutiniBelirle(rutinId);
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Aktif rutin belirlenirken hata oluştu (id: $rutinId)',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Aktif rutin değiştirilemedi.');
    }
  }

  @override
  Future<void> rutinSil(int rutinId) async {
    try {
      await _dao.rutinSil(rutinId);
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Rutin silinirken hata oluştu (id: $rutinId)',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Rutin silinemedi.');
    }
  }

  @override
  Future<List<RutinEgzersizDetayi>> rutinEgzersizleriniGetir(
    int rutinId, {
    bool arsivlenmisleriDahilEt = false,
  }) async {
    try {
      return await _dao.rutinEgzersizleriniGetir(
        rutinId,
        arsivlenmisleriDahilEt: arsivlenmisleriDahilEt,
      );
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Rutin egzersizleri getirilirken hata oluştu (id: $rutinId)',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Rutin hareketleri yüklenemedi.');
    }
  }
}

// RutinDeposu sağlayan Riverpod sağlayıcısı.
final rutinDeposuSaglayici = Provider<RutinDeposu>((ref) {
  final veritabani = ref.watch(veritabaniSaglayici);
  return RutinDeposuUygulamasi(veritabani.rutinDao);
});
