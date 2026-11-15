# CHANGELOG.md

Tüm önemli değişiklikler bu dosyada belgelenir.

## [1.0.0] - 2026-11-15
### Eklendi
- Veritabanı JSON yedekleme, şema sürümü (`semaSurumu`) doğrulamalı geri yükleme ve çift onaylı tüm verileri silme özelliği (`YedeklemeServisi`, `YedeklemeAyarKarti`) ile birim testleri eklendi.
- İlk açılışta bir kez gösterilen 3 adımlı tanıtım (`TanitimEkrani`), bildirim izni/saat seçimi ve hazır hareketlerden başlangıç rutini kurulumu eklendi.
- `flutter_launcher_icons` ve `flutter_native_splash` yapılandırmaları, widget testleri (`test/widget_test.dart`), GitHub Actions CI iş akışı (`.github/workflows/ci.yml`), mimari belgesi (`docs/ARCHITECTURE.md`) ve macOS/iOS derleme rehberini içeren `README.md` tamamlandı.

## [0.4.0] - 2026-11-15
### Eklendi
- Geçmiş ekranı (`GecmisEkrani`, `GecmisTakvimIzgarasi`) ve planlı olmayan günlerin seriyi bozmadığı seri hesaplayıcı (`SeriHesaplayici`) ile birim testleri eklendi.
- Doktor gösterimine uygun Rapor ekranı (`RaporEkrani`, `RaporOlusturucu`), 7/30 gün ve özel tarih aralığı filtresi, hareket/gün matris tablosu (`✅`, `❌`, `➖`), arşivlenmiş hareketler için `egzersizAdiKopyasi` koruması ve yatay A4 PDF dışa aktarma/paylaşma servisi (`PdfDisaAktarmaServisi`) eklendi.

## [0.3.0] - 2026-11-15
### Eklendi
- Egzersizler ekranı (`EgzersizlerEkrani`), egzersiz ekleme/düzenleme/arşivleme ve hazır örnek listeden tek dokunuşla hareket ekleme özelliği eklendi.
- Rutinler ekranı (`RutinlerEkrani`, `RutinFormEkrani`), sürükle-bırak hareket sıralama (`ReorderableListView`), gün seçimi ve aktif rutin belirleme eklendi.
- Bugün ekranı (`BugunEkrani`, `BugunKontrolcusu`), günlük ilerleme yüzdesi, geri alınabilir "Yaptım / Atladım" işaretlemesi, hareket başına not ekleme, `+ Hızlı Ekle` (`HizliEkleAltSayfasi`) ve gece yarısı otomatik gün geçişi eklendi.
- Ayarlar ekranı (`AyarlarEkrani`, `AyarlarKontrolcusu`, `UygulamaTercihleriServisi`), sabah/akşam hatırlatıcı saat ve gün seçimi, saat dilimi/yaz saati değişiminde otomatik yeniden kurulum, tema seçimi (Sistem/Açık/Koyu), pil optimizasyonu rehberi, gizlilik ve tıbbi uyarı notları eklendi.

## [0.2.0] - 2026-11-15
### Eklendi
- Veritabanı katmanı (`UygulamaVeritabani`), 6 tablo, 4 DAO ve 4 Depo (Repository) sınıfı ile bellek içi birim testleri eklendi.
- `BildirimServisi` (`flutter_local_notifications`, `timezone`, `flutter_timezone`) ile izin yönetimi, test bildirimi, sabah/akşam haftalık tekrarlı `zonedSchedule` ve arka planda veritabanını güvenli güncelleyen "Yaptım" bildirim aksiyonu eklendi.
- Android (`POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED`, Core Library Desugaring) ve iOS (`AppDelegate` bildirim delegesi ve kategori aksiyonu) yapılandırmaları tamamlandı.

## [0.1.0] - 2026-11-15
### Eklendi
- Flutter projesi (`com.mustafahali.gunlukegzersiz`) Android ve iOS platformları için oluşturuldu.
- Gerekli paketler (`flutter_riverpod`, `drift`, `go_router`, `flutter_local_notifications`, `pdf`, `printing`, `share_plus`, `shared_preferences` vb.) eklendi.
- Türkçe klasör mimarisi (`lib/cekirdek`, `lib/ozellikler`) ve katmanlı yapı kuruldu.
- Merkezi hata/log yönetici sınıfı (`MerkeziKaydedici`, `UygulamaHatasi`), sabitler (`UygulamaSabitleri`), tema (`UygulamaTemasi`) ve GoRouter alt gezinme iskeleti (`AnaIskeletEkrani`) eklendi.
- `.gitignore`, `PLAN.md`, `README.md` ve `docs/ARCHITECTURE.md` oluşturuldu.
