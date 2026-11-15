# Mimari Belgesi (docs/ARCHITECTURE.md)

## Katmanlı Mimari Kuralları
Uygulama tek sorumluluk ilkesine (Single Responsibility) ve katmanlı mimariye sıkı sıkıya bağlıdır:

`Ekran (Screen) → Kontrolcü (Riverpod Notifier) → Depo (Repository Arayüz + Uygulama) → DAO (Drift) → Veritabanı (SQLite)`

1. **Sunum Katmanı (`sunum/`):**
   - `*_ekrani.dart`: Yalnızca kullanıcı arayüzü (UI) bileşenlerini içerir. Veritabanı, bildirim, PDF veya istatistik hesabı içermez.
   - `*_kontrolcusu.dart`: Riverpod `Notifier` / `AsyncNotifier` sınıflarıdır. Ekran ile depo/servisler arasındaki akışı yönetir ve hataları yakalayıp kullanıcıya Türkçe mesaj sunar.
2. **Alan Katmanı (`alan/`):**
   - İş modelleri ve soyut depo (`abstract class *_deposu.dart`) arayüzlerini barındırır.
3. **Veri Katmanı (`veri/`):**
   - `*_dao.dart`: Drift veritabanı sorgularını içerir.
   - `*_deposu_uygulamasi.dart`: Soyut depo arayüzlerini uygular, DAO'yu çağırır ve hataları `UygulamaHatasi` olarak sarmalar.
4. **Çekirdek (`lib/cekirdek/`):**
   - `veritabani/`: Drift tablo tanımları, veritabanı sınıfı ve şema göç (migration) stratejisi.
   - `bildirimler/`: Platform farklarını soyutlayan `BildirimServisi`.
   - `hatalar/`: `MerkeziKaydedici` ve `UygulamaHatasi`.
   - `sabitler/`, `tema/`, `yonlendirme/`, `yardimcilar/`.
