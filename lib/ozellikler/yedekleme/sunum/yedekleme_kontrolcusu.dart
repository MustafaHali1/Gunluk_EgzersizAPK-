// lib/ozellikler/yedekleme/sunum/yedekleme_kontrolcusu.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/bildirimler/bildirim_servisi.dart';
import '../../bugun/sunum/bugun_kontrolcusu.dart';
import '../../egzersizler/sunum/egzersiz_kontrolcusu.dart';
import '../../gecmis/sunum/gecmis_kontrolcusu.dart';
import '../../rapor/sunum/rapor_kontrolcusu.dart';
import '../../rutinler/alan/rutin_deposu.dart';
import '../../rutinler/sunum/rutin_kontrolcusu.dart';
import '../../rutinler/veri/rutin_deposu_uygulamasi.dart';
import '../veri/yedekleme_servisi.dart';

// Yedekleme, geri yükleme ve tüm verileri silme işlemlerini yöneten kontrolcü.
class YedeklemeKontrolcusu extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  YedeklemeServisi get _yedeklemeServisi => ref.read(yedeklemeServisiSaglayici);
  RutinDeposu get _rutinDeposu => ref.read(rutinDeposuSaglayici);
  BildirimServisi get _bildirimServisi => ref.read(bildirimServisiSaglayici);

  void _tumSaglayicilariYenile() {
    ref.invalidate(aktifEgzersizlerAkisSaglayici);
    ref.invalidate(egzersizKontrolcusuSaglayici);
    ref.invalidate(tumRutinlerAkisSaglayici);
    ref.invalidate(bugunKontrolcusuSaglayici);
    ref.invalidate(gecmisKontrolcusuSaglayici);
    ref.invalidate(raporKontrolcusuSaglayici);
  }

  // Tüm veritabanını JSON olarak dışa aktarır ve paylaşır.
  Future<String?> verileriDisaAktar() async {
    state = const AsyncLoading();
    try {
      await _yedeklemeServisi.yedegiDosyaOlarakPaylas();
      state = const AsyncData(null);
      return null;
    } catch (hata, iz) {
      state = AsyncError(hata, iz);
      return hata.toString();
    }
  }

  // Kullanıcının seçeceği JSON dosyasını okur.
  Future<String?> yedekDosyasiSec() async {
    return _yedeklemeServisi.yedekDosyasiSecVeOku();
  }

  // Onaylanan JSON metnini veritabanına yükler ve rutin alarmlarını günceller.
  Future<String?> yedektenGeriYukle(String jsonMetni) async {
    state = const AsyncLoading();
    try {
      await _yedeklemeServisi.jsonMetnindenGeriYukle(jsonMetni);
      _tumSaglayicilariYenile();
      final rutinler = await _rutinDeposu.tumRutinleriGetir();
      await _bildirimServisi.rutinAlarmlariniYenidenKur(rutinler);
      state = const AsyncData(null);
      return null;
    } catch (hata, iz) {
      state = AsyncError(hata, iz);
      return hata.toString();
    }
  }

  // Çift onay sonrası tüm verileri siler ve alarmları sıfırlar.
  Future<String?> tumVerileriSil() async {
    state = const AsyncLoading();
    try {
      await _yedeklemeServisi.tumVerileriSil();
      _tumSaglayicilariYenile();
      await _bildirimServisi.tumBildirimleriIptalEt();
      state = const AsyncData(null);
      return null;
    } catch (hata, iz) {
      state = AsyncError(hata, iz);
      return hata.toString();
    }
  }
}

// YedeklemeKontrolcusu sağlayıcısı.
final yedeklemeKontrolcusuSaglayici =
    NotifierProvider<YedeklemeKontrolcusu, AsyncValue<void>>(
      YedeklemeKontrolcusu.new,
    );
