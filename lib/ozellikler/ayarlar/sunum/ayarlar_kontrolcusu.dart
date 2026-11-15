// lib/ozellikler/ayarlar/sunum/ayarlar_kontrolcusu.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/ayarlar/uygulama_tercihleri_servisi.dart';
import '../../../cekirdek/bildirimler/bildirim_servisi.dart';
import '../../../cekirdek/hatalar/merkezi_kaydedici.dart';
import '../../../cekirdek/sabitler/uygulama_sabitleri.dart';
import '../../../cekirdek/yardimcilar/tarih_yardimcisi.dart';
import '../../../cekirdek/yonlendirme/uygulama_rotasi.dart';
import '../../bugun/alan/antrenman_deposu.dart';
import '../../bugun/sunum/bugun_kontrolcusu.dart';
import '../../bugun/veri/antrenman_deposu_uygulamasi.dart';
import '../../rutinler/alan/rutin_deposu.dart';
import '../../rutinler/veri/rutin_deposu_uygulamasi.dart';

// Bildirim izninin verilmiş olup olmadığını kontrol eden sağlayıcı.
final bildirimIzinDurumuSaglayici = FutureProvider<bool>((ref) async {
  final servis = ref.watch(bildirimServisiSaglayici);
  return servis.izinDurumunuKontrolEt();
});

// Bildirim servisi eşitlemesini ve bildirim tıklama yönlendirmelerini yöneten kontrolcü.
class AyarlarKontrolcusu extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  RutinDeposu get _rutinDeposu => ref.read(rutinDeposuSaglayici);
  AntrenmanDeposu get _antrenmanDeposu => ref.read(antrenmanDeposuSaglayici);
  BildirimServisi get _bildirimServisi => ref.read(bildirimServisiSaglayici);
  UygulamaTercihleriServisi get _tercihlerServisi =>
      ref.read(uygulamaTercihleriServisiSaglayici);

  // Uygulama açılışında bildirim servisini başlatır ve tüm rutin alarmlarını eşitler.
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

      final rutinler = await _rutinDeposu.tumRutinleriGetir();
      await _bildirimServisi.rutinAlarmlariniYenidenKur(rutinler);

      if (kayitliAnahtar != guncelAnahtar) {
        await _tercihlerServisi.sonSaatDiliminiKaydet(guncelAnahtar);
      }
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Açılışta bildirim eşitlemesi sırasında hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
    }
  }

  // Bildirime veya "Hepsini Yaptım" aksiyon butonuna tıklandığında çalışır.
  Future<void> _bildirimYanitiniIsle(NotificationResponse yanit) async {
    try {
      final rutinId = BildirimServisi.payloaddanRutinIdCoz(yanit.payload);

      if (yanit.actionId == BildirimServisi.aksiyonYaptimId) {
        final simdi = DateTime.now();
        await _antrenmanDeposu.gununTumHareketleriniYapildiIsaretle(
          tarih: TarihYardimcisi.tarihiFormatla(simdi),
          haftaninGunu: simdi.weekday,
          rutinId: rutinId,
        );
        ref.invalidate(bugunKontrolcusuSaglayici);
      }

      final rota = ref.read(uygulamaRotasiSaglayici);
      if (rutinId != null) {
        rota.go('/rutin/$rutinId');
      } else {
        rota.go(UygulamaSabitleri.rotaBugun);
      }
      ref.invalidate(bugunKontrolcusuSaglayici);
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Bildirim yanıtı işlenirken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
    }
  }

  // Kullanıcıdan bildirim izni ister ve izin verilirse alarmları kurar.
  Future<bool> bildirimIzniIste() async {
    final verildiMi = await _bildirimServisi.izinIste();
    ref.invalidate(bildirimIzinDurumuSaglayici);
    if (verildiMi) {
      final rutinler = await _rutinDeposu.tumRutinleriGetir();
      await _bildirimServisi.rutinAlarmlariniYenidenKur(rutinler);
    }
    return verildiMi;
  }
}

// AyarlarKontrolcusu sağlayıcısı.
final ayarlarKontrolcusuSaglayici =
    NotifierProvider<AyarlarKontrolcusu, AsyncValue<void>>(
      AyarlarKontrolcusu.new,
    );
