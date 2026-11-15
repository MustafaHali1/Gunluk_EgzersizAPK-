// lib/ozellikler/yedekleme/sunum/yedekleme_kontrolcusu.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/bildirimler/bildirim_servisi.dart';
import '../../ayarlar/alan/hatirlatici_deposu.dart';
import '../../ayarlar/sunum/ayarlar_kontrolcusu.dart';
import '../../ayarlar/veri/hatirlatici_deposu_uygulamasi.dart';
import '../../bugun/sunum/bugun_kontrolcusu.dart';
import '../../egzersizler/sunum/egzersiz_kontrolcusu.dart';
import '../../gecmis/sunum/gecmis_kontrolcusu.dart';
import '../../rapor/sunum/rapor_kontrolcusu.dart';
import '../../rutinler/sunum/rutin_kontrolcusu.dart';
import '../veri/yedekleme_servisi.dart';

// Yedekleme, geri yükleme ve tüm verileri silme işlemlerini yöneten kontrolcü.
class YedeklemeKontrolcusu extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  YedeklemeServisi get _yedeklemeServisi => ref.read(yedeklemeServisiSaglayici);
  HatirlaticiDeposu get _hatirlaticiDeposu =>
      ref.read(hatirlaticiDeposuSaglayici);
  BildirimServisi get _bildirimServisi => ref.read(bildirimServisiSaglayici);

  void _tumSaglayicilariYenile() {
    ref.invalidate(aktifEgzersizlerAkisSaglayici);
    ref.invalidate(egzersizKontrolcusuSaglayici);
    ref.invalidate(tumRutinlerAkisSaglayici);
    ref.invalidate(bugunKontrolcusuSaglayici);
    ref.invalidate(gecmisKontrolcusuSaglayici);
    ref.invalidate(raporKontrolcusuSaglayici);
    ref.invalidate(hatirlaticilarAkisSaglayici);
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

  // Onaylanan JSON metnini veritabanına yükler ve bildirimleri günceller.
  Future<String?> yedektenGeriYukle(String jsonMetni) async {
    state = const AsyncLoading();
    try {
      await _yedeklemeServisi.jsonMetnindenGeriYukle(jsonMetni);
      _tumSaglayicilariYenile();
      final hatirlaticilar = await _hatirlaticiDeposu.hatirlaticilariGetir();
      await _bildirimServisi.hatirlaticilariYenidenKur(hatirlaticilar);
      state = const AsyncData(null);
      return null;
    } catch (hata, iz) {
      state = AsyncError(hata, iz);
      return hata.toString();
    }
  }

  // Çift onay sonrası tüm verileri siler ve hatırlatıcıları sıfırlar.
  Future<String?> tumVerileriSil() async {
    state = const AsyncLoading();
    try {
      await _yedeklemeServisi.tumVerileriSil();
      _tumSaglayicilariYenile();
      final hatirlaticilar = await _hatirlaticiDeposu.hatirlaticilariGetir();
      await _bildirimServisi.hatirlaticilariYenidenKur(hatirlaticilar);
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
