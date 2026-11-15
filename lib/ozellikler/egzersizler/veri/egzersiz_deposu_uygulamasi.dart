// lib/ozellikler/egzersizler/veri/egzersiz_deposu_uygulamasi.dart

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/hatalar/merkezi_kaydedici.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';
import '../alan/egzersiz_deposu.dart';
import 'egzersiz_dao.dart';

// EgzersizDeposu arayüzünün Drift DAO kullanan somut uygulaması.
class EgzersizDeposuUygulamasi implements EgzersizDeposu {
  final EgzersizDao _dao;

  const EgzersizDeposuUygulamasi(this._dao);

  @override
  Stream<List<EgzersizlerData>> aktifEgzersizleriIzle() {
    return _dao.aktifEgzersizleriIzle().handleError((Object hata, StackTrace iz) {
      MerkeziKaydedici.hataYaz(
        'Aktif egzersizler izlenirken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Egzersiz listesi yüklenemedi.');
    });
  }

  @override
  Future<List<EgzersizlerData>> aktifEgzersizleriGetir() async {
    try {
      return await _dao.aktifEgzersizleriGetir();
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Aktif egzersizler getirilirken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Egzersizler alınırken bir hata oluştu.');
    }
  }

  @override
  Future<List<EgzersizlerData>> tumEgzersizleriGetir() async {
    try {
      return await _dao.tumEgzersizleriGetir();
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Tüm egzersizler getirilirken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Egzersiz geçmişi alınırken hata oluştu.');
    }
  }

  @override
  Future<EgzersizlerData?> idIleEgzersizGetir(int id) async {
    try {
      return await _dao.idIleEgzersizGetir(id);
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Egzersiz detayı getirilirken hata oluştu (id: $id)',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Egzersiz bilgisi bulunamadı.');
    }
  }

  @override
  Future<int> egzersizEkle({
    required String ad,
    required String aciklama,
    required String tur,
    int? sureSaniye,
    int? setSayisi,
    int? tekrarSayisi,
    required String kategori,
  }) async {
    try {
      return await _dao.egzersizEkle(
        EgzersizlerCompanion.insert(
          ad: ad.trim(),
          aciklama: Value(aciklama.trim()),
          tur: tur,
          sureSaniye: Value(sureSaniye),
          setSayisi: Value(setSayisi),
          tekrarSayisi: Value(tekrarSayisi),
          kategori: Value(kategori.trim()),
        ),
      );
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Egzersiz eklenirken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Egzersiz kaydedilemedi.');
    }
  }

  @override
  Future<bool> egzersizGuncelle({
    required int id,
    required String ad,
    required String aciklama,
    required String tur,
    int? sureSaniye,
    int? setSayisi,
    int? tekrarSayisi,
    required String kategori,
    bool arsivlendiMi = false,
  }) async {
    try {
      return await _dao.egzersizGuncelle(
        EgzersizlerCompanion(
          id: Value(id),
          ad: Value(ad.trim()),
          aciklama: Value(aciklama.trim()),
          tur: Value(tur),
          sureSaniye: Value(sureSaniye),
          setSayisi: Value(setSayisi),
          tekrarSayisi: Value(tekrarSayisi),
          kategori: Value(kategori.trim()),
          arsivlendiMi: Value(arsivlendiMi),
        ),
      );
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Egzersiz güncellenirken hata oluştu (id: $id)',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Egzersiz güncellenemedi.');
    }
  }

  @override
  Future<void> egzersizArsivle(int id, {bool arsivlendiMi = true}) async {
    try {
      await _dao.egzersizArsivle(id, arsivlendiMi: arsivlendiMi);
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Egzersiz arşivlenirken hata oluştu (id: $id)',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Egzersiz arşivleme işlemi başarısız oldu.');
    }
  }
}

// EgzersizDeposu sağlayan Riverpod sağlayıcısı.
final egzersizDeposuSaglayici = Provider<EgzersizDeposu>((ref) {
  final veritabani = ref.watch(veritabaniSaglayici);
  return EgzersizDeposuUygulamasi(veritabani.egzersizDao);
});
