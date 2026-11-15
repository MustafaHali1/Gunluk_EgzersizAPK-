// lib/ozellikler/bugun/veri/antrenman_deposu_uygulamasi.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/hatalar/merkezi_kaydedici.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';
import '../alan/antrenman_deposu.dart';
import 'antrenman_dao.dart';

// AntrenmanDeposu arayüzünün Drift DAO kullanan somut uygulaması.
class AntrenmanDeposuUygulamasi implements AntrenmanDeposu {
  final AntrenmanDao _dao;

  const AntrenmanDeposuUygulamasi(this._dao);

  @override
  Future<GunlukAntrenmanDetayi?> gunlukAntrenmanDetayiGetir(
    String tarih,
  ) async {
    try {
      return await _dao.gunlukAntrenmanDetayiGetir(tarih);
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Günlük antrenman detayı getirilirken hata oluştu ($tarih)',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Günlük antrenman bilgisi alınamadı.');
    }
  }

  @override
  Future<GunlukAntrenmanDetayi> gunlukAntrenmanOlusturVeyaGetir({
    required String tarih,
    required int haftaninGunu,
  }) async {
    try {
      return await _dao.gunlukAntrenmanOlusturVeyaGetir(
        tarih: tarih,
        haftaninGunu: haftaninGunu,
      );
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Günlük antrenman oluşturulurken/getirilirken hata oluştu ($tarih)',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Bugünün egzersiz listesi hazırlanamadı.');
    }
  }

  @override
  Future<void> egzersizDurumunuGuncelle({
    required int egzersizKaydiId,
    required String durum,
    String? notMetni,
  }) async {
    try {
      await _dao.egzersizKaydiDurumunuGuncelle(
        egzersizKaydiId: egzersizKaydiId,
        durum: durum,
        notMetni: notMetni,
      );
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Egzersiz durumu güncellenirken hata oluştu (id: $egzersizKaydiId)',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Hareket durumu güncellenemedi.');
    }
  }

  @override
  Future<int> gunlukHizliEgzersizEkle({
    required int antrenmanKaydiId,
    required int egzersizId,
    required String egzersizAdiKopyasi,
    String? notMetni,
  }) async {
    try {
      return await _dao.gunlukHizliEgzersizEkle(
        antrenmanKaydiId: antrenmanKaydiId,
        egzersizId: egzersizId,
        egzersizAdiKopyasi: egzersizAdiKopyasi,
        notMetni: notMetni,
      );
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Hızlı egzersiz eklenirken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Hızlı egzersiz bugüne eklenemedi.');
    }
  }

  @override
  Future<void> gununTumHareketleriniYapildiIsaretle({
    required String tarih,
    required int haftaninGunu,
  }) async {
    try {
      await _dao.gununTumHareketleriniYapildiIsaretle(
        tarih: tarih,
        haftaninGunu: haftaninGunu,
      );
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Günün tüm hareketleri yapıldı işaretlenirken hata oluştu ($tarih)',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Hareketler tamamlandı olarak işaretlenemedi.');
    }
  }

  @override
  Future<List<GunlukAntrenmanDetayi>> tarihAraligindakiAntrenmanlariGetir({
    required String baslangicTarihi,
    required String bitisTarihi,
  }) async {
    try {
      return await _dao.tarihAraligindakiAntrenmanlariGetir(
        baslangicTarihi: baslangicTarihi,
        bitisTarihi: bitisTarihi,
      );
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Tarih aralığındaki antrenmanlar getirilirken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Geçmiş antrenman kayıtları alınamadı.');
    }
  }
}

// AntrenmanDeposu sağlayan Riverpod sağlayıcısı.
final antrenmanDeposuSaglayici = Provider<AntrenmanDeposu>((ref) {
  final veritabani = ref.watch(veritabaniSaglayici);
  return AntrenmanDeposuUygulamasi(veritabani.antrenmanDao);
});
