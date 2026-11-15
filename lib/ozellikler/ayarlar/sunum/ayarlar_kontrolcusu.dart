// lib/ozellikler/ayarlar/sunum/ayarlar_kontrolcusu.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/ayarlar/uygulama_tercihleri_servisi.dart';
import '../../../cekirdek/bildirimler/bildirim_servisi.dart';
import '../../../cekirdek/hatalar/merkezi_kaydedici.dart';
import '../../../cekirdek/sabitler/uygulama_sabitleri.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';
import '../../../cekirdek/yardimcilar/tarih_yardimcisi.dart';
import '../../../cekirdek/yonlendirme/uygulama_rotasi.dart';
import '../../bugun/alan/antrenman_deposu.dart';
import '../../bugun/sunum/bugun_kontrolcusu.dart';
import '../../bugun/veri/antrenman_deposu_uygulamasi.dart';
import '../alan/hatirlatici_deposu.dart';
import '../veri/hatirlatici_deposu_uygulamasi.dart';

// Veritabanındaki sabah ve akşam hatırlatıcılarını canlı izleyen sağlayıcı.
final hatirlaticilarAkisSaglayici = StreamProvider<List<HatirlaticilarData>>((
  ref,
) {
  final depo = ref.watch(hatirlaticiDeposuSaglayici);
  return depo.hatirlaticilariIzle();
});

// Bildirim izninin verilmiş olup olmadığını kontrol eden sağlayıcı.
final bildirimIzinDurumuSaglayici = FutureProvider<bool>((ref) async {
  final servis = ref.watch(bildirimServisiSaglayici);
  return servis.izinDurumunuKontrolEt();
});

// Bildirim saatleri, izin isteme ve saat dilimi eşitlemesini yöneten kontrolcü.
class AyarlarKontrolcusu extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  HatirlaticiDeposu get _hatirlaticiDeposu =>
      ref.read(hatirlaticiDeposuSaglayici);
  AntrenmanDeposu get _antrenmanDeposu => ref.read(antrenmanDeposuSaglayici);
  BildirimServisi get _bildirimServisi => ref.read(bildirimServisiSaglayici);
  UygulamaTercihleriServisi get _tercihlerServisi =>
      ref.read(uygulamaTercihleriServisiSaglayici);

  // Uygulama açılışında bildirim servisini başlatır, saat dilimi veya yaz saati değişmişse
  // hatırlatıcıları yeniden kurar ve açılış bildirimi varsa işler.
  Future<void> uygulamaAcilisindaBildirimleriEsitle() async {
    try {
      await _bildirimServisi.baslat(
        bildirimTiklandiginda: (yanit) {
          _bildirimYanitiniIsle(yanit);
        },
      );

      final acilisYaniti = await _bildirimServisi.acilisBildirimYanitiniGetir();
      if (acilisYaniti != null) {
        await _bildirimYanitiniIsle(acilisYaniti);
      }

      final saatDilimiKimligi = await _bildirimServisi.guncelSaatDiliminiGetir();
      final yazSaatiFarki = DateTime.now().timeZoneOffset.inMinutes;
      final guncelAnahtar = '$saatDilimiKimligi|$yazSaatiFarki';
      final kayitliAnahtar = await _tercihlerServisi.sonSaatDiliminiGetir();

      final hatirlaticilar = await _hatirlaticiDeposu.hatirlaticilariGetir();
      await _bildirimServisi.hatirlaticilariYenidenKur(hatirlaticilar);

      if (kayitliAnahtar != guncelAnahtar) {
        await _tercihlerServisi.sonSaatDiliminiKaydet(guncelAnahtar);
        MerkeziKaydedici.bilgiYaz(
          'Saat dilimi/yaz saati kaydedildi ve bildirimler eşitlendi: $guncelAnahtar',
        );
      }
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Açılışta bildirim eşitlemesi sırasında hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
    }
  }

  // Bildirime veya "Yaptım" aksiyon butonuna tıklandığında çalışır.
  Future<void> _bildirimYanitiniIsle(NotificationResponse yanit) async {
    try {
      if (yanit.actionId == BildirimServisi.aksiyonYaptimId) {
        final simdi = DateTime.now();
        await _antrenmanDeposu.gununTumHareketleriniYapildiIsaretle(
          tarih: TarihYardimcisi.tarihiFormatla(simdi),
          haftaninGunu: simdi.weekday,
        );
        ref.invalidate(bugunKontrolcusuSaglayici);
      }

      final rota = ref.read(uygulamaRotasiSaglayici);
      rota.go(UygulamaSabitleri.rotaBugun);
      ref.invalidate(bugunKontrolcusuSaglayici);
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Bildirim yanıtı işlenirken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
    }
  }

  // Sabah veya akşam hatırlatıcısını günceller ve bildirim zamanlamalarını yeniden kurar.
  Future<bool> hatirlaticiKaydet({
    required String etiket,
    required int saat,
    required int dakika,
    required List<int> seciliGunler,
    required bool etkinMi,
  }) async {
    state = const AsyncLoading();
    try {
      final siraliGunler = [...seciliGunler]..sort();
      await _hatirlaticiDeposu.hatirlaticiGuncelle(
        etiket: etiket,
        saat: saat,
        dakika: dakika,
        haftaninGunleri: siraliGunler.join(','),
        etkinMi: etkinMi,
      );

      final guncelListe = await _hatirlaticiDeposu.hatirlaticilariGetir();
      await _bildirimServisi.hatirlaticilariYenidenKur(guncelListe);

      state = const AsyncData(null);
      return true;
    } catch (hata, iz) {
      state = AsyncError(hata, iz);
      return false;
    }
  }

  // Kullanıcıdan bildirim izni ister ve izin verilirse hatırlatıcıları kurar.
  Future<bool> bildirimIzniIste() async {
    final verildiMi = await _bildirimServisi.izinIste();
    ref.invalidate(bildirimIzinDurumuSaglayici);
    if (verildiMi) {
      final liste = await _hatirlaticiDeposu.hatirlaticilariGetir();
      await _bildirimServisi.hatirlaticilariYenidenKur(liste);
    }
    return verildiMi;
  }

  // Anlık test bildirimi gönderir.
  Future<bool> testBildirimiGonder() async {
    try {
      await _bildirimServisi.testBildirimiGonder();
      return true;
    } catch (hata, iz) {
      state = AsyncError(hata, iz);
      return false;
    }
  }
}

// AyarlarKontrolcusu sağlayıcısı.
final ayarlarKontrolcusuSaglayici =
    NotifierProvider<AyarlarKontrolcusu, AsyncValue<void>>(
      AyarlarKontrolcusu.new,
    );
