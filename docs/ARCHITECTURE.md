# Mimari Belgesi (docs/ARCHITECTURE.md)

## 1. Katmanlı Mimari ve Tek Yönlü Veri Akışı

Uygulama, sorumlulukların net biçimde ayrıldığı katmanlı bir mimari izler. Hiçbir ekran (UI) doğrudan veritabanına (`Drift`), DAO sınıflarına veya platform servislerine erişmez.

```
Ekran (Screen / Widget)
   ↓  (Riverpod watch / read)
Kontrolcü (Notifier / AsyncNotifier)
   ├─→ Depo (Soyut Arayüz → Somut Uygulama)
   │      ↓
   │   DAO (Drift DatabaseAccessor)
   │      ↓
   │   UygulamaVeritabani (SQLite)
   │
   └─→ Servisler (BildirimServisi, PdfDisaAktarmaServisi, YedeklemeServisi, UygulamaTercihleriServisi)
```

## 2. Klasör Yapısı

```
lib/
  cekirdek/
    ayarlar/        # UygulamaTercihleriServisi (SharedPreferences, TemaModuKontrolcusu)
    bildirimler/    # BildirimServisi ve arkaPlanBildirimYanitiIsleyici
    hatalar/        # MerkeziKaydedici ve UygulamaHatasi
    sabitler/       # UygulamaSabitleri, UygulamaRenkleri, UygulamaBoyutlari, UygulamaMetinleri
    tema/           # UygulamaTemasi (Material 3 açık ve koyu tema)
    veritabani/     # tablolar.dart, uygulama_veritabani.dart
    yardimcilar/    # TarihYardimcisi
    yonlendirme/    # uygulama_rotasi.dart, ana_iskelet_ekrani.dart
  ozellikler/
    tanitim/        # 3 adımlı ilk açılış tanıtımı ve başlangıç rutini kurulumu
    bugun/          # Günlük antrenman kontrol listesi, hızlı ekle, gece yarısı gün geçişi
    egzersizler/    # Egzersiz ekleme, düzenleme, hazır şablonlar ve arşivleme (soft delete)
    rutinler/       # Rutin oluşturma, sürükle-bırak sıralama, aktif rutin seçimi
    gecmis/         # Aylık takvim görünümü ve SeriHesaplayici (streak)
    rapor/          # RaporOlusturucu (hareket × gün matrisi) ve PdfDisaAktarmaServisi
    ayarlar/        # Hatırlatıcı saat/gün seçimi, izin durumu, tema ve pil rehberi
    yedekleme/      # YedeklemeServisi (JSON dışa/içe aktarma, çift onaylı sıfırlama)
```

## 3. Veritabanı Şeması ve Göç (Migration) Stratejisi

- `schemaVersion`: `1`
- Yabancı anahtarlar (`PRAGMA foreign_keys = ON`) her bağlantıda etkinleştirilir.
- Tablolar:
  1. `Egzersizler`: `id`, `ad`, `aciklama`, `tur` (`sureli`/`tekrarli`), `sureSaniye`, `setSayisi`, `tekrarSayisi`, `kategori`, `arsivlendiMi`
  2. `Rutinler`: `id`, `ad`, `haftaninGunleri` (`1,2,3...`), `aktifMi`
  3. `RutinEgzersizleri`: `id`, `rutinId`, `egzersizId`, `siraIndeksi`
  4. `AntrenmanKayitlari`: `id`, `tarih` (`YYYY-MM-DD`, benzersiz `UNIQUE`), `rutinId`
  5. `EgzersizKayitlari`: `id`, `antrenmanKaydiId`, `egzersizId`, `egzersizAdiKopyasi`, `durum` (`yapildi`/`atlandi`/`bekliyor`), `notMetni`
  6. `Hatirlaticilar`: `id`, `etiket` (`sabah`/`aksam`), `saat`, `dakika`, `haftaninGunleri`, `etkinMi`
- **Geçmiş Koruması:** Bir egzersiz silindiğinde veritabanından silinmez (`arsivlendiMi = true` yapılır) ve günlük kayıtlarda o günkü adı `egzersizAdiKopyasi` (`exerciseNameSnapshot`) sütununda saklanır. Böylece eski raporlar ve geçmiş takvimi hiçbir zaman bozulmaz.

## 4. Arka Plan Bildirim İşleyicisi ve Güvenli Veritabanı Erişimi

`lib/cekirdek/bildirimler/bildirim_servisi.dart` içindeki `@pragma('vm:entry-point') arkaPlanBildirimYanitiIsleyici` fonksiyonu, uygulama kapalıyken bildirim üzerindeki **"Yaptım"** butonuna basıldığında ayrı bir Dart izole alanında (isolate) çalışır. Bu izole alanda güvenli erişim için kendi `UygulamaVeritabani()` bağlantısını açar, `gununTumHareketleriniYapildiIsaretle` işlemini bir `transaction` içinde tamamlar ve `finally` bloğunda bağlantıyı hemen kapatır (`await veritabani.close()`).
