// lib/ozellikler/ayarlar/veri/hatirlatici_deposu_uygulamasi.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/hatalar/merkezi_kaydedici.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';
import '../alan/hatirlatici_deposu.dart';
import 'hatirlatici_dao.dart';

// HatirlaticiDeposu arayüzünün Drift DAO kullanan somut uygulaması.
class HatirlaticiDeposuUygulamasi implements HatirlaticiDeposu {
  final HatirlaticiDao _dao;

  const HatirlaticiDeposuUygulamasi(this._dao);

  @override
  Stream<List<HatirlaticilarData>> hatirlaticilariIzle() {
    return _dao.hatirlaticilariIzle().handleError((Object hata, StackTrace iz) {
      MerkeziKaydedici.hataYaz(
        'Hatırlatıcılar izlenirken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Hatırlatıcı ayarları yüklenemedi.');
    });
  }

  @override
  Future<List<HatirlaticilarData>> hatirlaticilariGetir() async {
    try {
      return await _dao.hatirlaticilariGetir();
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Hatırlatıcılar getirilirken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Hatırlatıcı saatleri alınamadı.');
    }
  }

  @override
  Future<HatirlaticilarData?> etiketeGoreGetir(String etiket) async {
    try {
      return await _dao.etiketeGoreGetir(etiket);
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Hatırlatıcı getirilirken hata oluştu ($etiket)',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Hatırlatıcı bilgisi alınamadı.');
    }
  }

  @override
  Future<void> hatirlaticiGuncelle({
    required String etiket,
    required int saat,
    required int dakika,
    required String haftaninGunleri,
    required bool etkinMi,
  }) async {
    try {
      await _dao.hatirlaticiGuncelle(
        etiket: etiket,
        saat: saat,
        dakika: dakika,
        haftaninGunleri: haftaninGunleri,
        etkinMi: etkinMi,
      );
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Hatırlatıcı güncellenirken hata oluştu ($etiket)',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Hatırlatıcı saati güncellenemedi.');
    }
  }
}

// HatirlaticiDeposu sağlayan Riverpod sağlayıcısı.
final hatirlaticiDeposuSaglayici = Provider<HatirlaticiDeposu>((ref) {
  final veritabani = ref.watch(veritabaniSaglayici);
  return HatirlaticiDeposuUygulamasi(veritabani.hatirlaticiDao);
});
