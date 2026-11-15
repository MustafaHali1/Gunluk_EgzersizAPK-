# Günlük Egzersiz — Egzersiz Hatırlatıcı ve Doktor Raporlama Uygulaması

**Günlük Egzersiz**, kullanıcıların kendi egzersizlerini tanımladığı, haftalık rutinler oluşturduğu, sabah ve akşam bildirimleriyle hatırlatıldığı, günlük hareketlerini işaretleyip geçmiş ve seri (streak) istatistiklerini takip ettiği, doktorlarına gösterebilecekleri **yatay A4 PDF raporları** üretebildiği ve verilerini JSON olarak yedekleyip geri yükleyebildiği **çevrimdışı öncelikli (offline-first)** bir mobil uygulamadır.

- **Uygulama Adı:** Günlük Egzersiz
- **Paket Kimliği (`applicationId` / `PRODUCT_BUNDLE_IDENTIFIER`):** `com.mustafahali.gunlukegzersiz`
- **Sürüm:** `1.0.0+5`
- **Hedef Platformlar:** Android ve iOS (tek kod tabanı)

---

## 1. Özellikler

1. **İlk Açılış Tanıtımı (Onboarding):** 3 adımlı tanıtım, bildirim izni isteme, sabah/akşam hatırlatma saatlerini seçme ve hazır hareket şablonlarından tek dokunuşla başlangıç rutini oluşturma (`shared_preferences` ile yalnızca ilk açılışta gösterilir).
2. **Egzersiz Yönetimi:** Süreli (saniye) veya tekrarlı (set × tekrar) egzersiz ekleme, kategori ve açıklama girme, düzenleme, hazır örnek listeden (Squat, Plank, Şınav, Lunge, Köprü vb.) seçme ve geçmiş raporları bozmamak için **arşivleme (`arsivlendiMi` / soft delete)**.
3. **Rutin Yönetimi:** Haftanın yapılacak günlerini seçme, egzersizleri sürükle-bırak (`ReorderableListView`) ile sıralama ve aktif rutini belirleme.
4. **Bugün Ekranı:** Günlük ilerleme yüzdesi, geri alınabilir **"Yaptım / Atladım"** işaretlemesi, hareket başına opsiyonel not ekleme, **`+ Hızlı Ekle`** ile o güne özel tek seferlik hareket ekleme ve gece yarısı (00:00) geçtiğinde uygulama açıkken bile otomatik yeni güne geçiş.
5. **Bildirimler:** Sabah ve akşam için ayrı saat ve gün seçimi, haftalık tekrarlı `zonedSchedule` (`DateTimeComponents.dayOfWeekAndTime` ile iOS 64 bekleyen bildirim limitine tam uyumlu), bildirim üzerinden **"Yaptım"** aksiyon butonu ile arka planda güvenli veritabanı güncellemesi ve saat dilimi / yaz saati değiştiğinde açılışta otomatik yeniden kurulum.
6. **Geçmiş ve Seri (Streak):** Aylık takvim görünümü, güne tıklayınca hareket ve not detayları, **planlı olmayan dinlenme günlerinin seriyi bozmadığı** mevcut ve en uzun seri sayacı.
7. **Doktor Raporu ve PDF Paylaşımı:** Son 7 gün, son 30 gün veya özel tarih aralığı için hareket × gün matrisi (`✅` yapıldı, `❌` yapılmadı/atlandı, `➖` planlı değil), hareket başına ve genel tamamlanma yüzdesi, `egzersizAdiKopyasi` (`exerciseNameSnapshot`) sayesinde eski raporların korunması ve yatay A4 PDF oluşturup paylaşma.
8. **Yedekleme ve Geri Yükleme:** Tüm veritabanını `semaSurumu` bilgisiyle JSON olarak dışa aktarma (`share_plus`), şema ve bütünlük doğrulamalı içe aktarma (`file_picker`) ve **çift onaylı** "Tüm Verileri Sil" sıfırlama özelliği.

---

## 2. Teknoloji Yığını

| Alan | Paket |
|---|---|
| Durum Yönetimi (State) | `flutter_riverpod` |
| Yerel Veritabanı (SQLite) | `drift`, `sqlite3_flutter_libs` |
| Yerel Bildirimler & Saat Dilimi | `flutter_local_notifications`, `timezone`, `flutter_timezone` |
| Sayfa Yönlendirme | `go_router` |
| PDF Üretimi ve Paylaşım | `pdf`, `printing`, `share_plus` |
| Dosya ve Tercih Yönetimi | `path_provider`, `file_picker`, `shared_preferences` |
| İkon ve Açılış Ekranı | `flutter_launcher_icons`, `flutter_native_splash` |

---

## 3. Windows / Android Kurulum ve Çalıştırma

```bash
# 1. Bağımlılıkları yükleyin
flutter pub get

# 2. Statik kod analizini çalıştırın
flutter analyze

# 3. Birim ve widget testlerini çalıştırın
flutter test

# 4. USB ile bağlı Android telefonda veya emülatörde çalıştırın
flutter run

# 5. Yayın (Release) APK / AppBundle üretin
flutter build apk --release
flutter build appbundle --release
```

> **Android İmzalama Notu:** Yayın imzası için `android/key.properties` ve `.jks` anahtar dosyanızı yerel olarak oluşturun. Güvenlik kuralları gereği `key.properties`, `*.jks` ve `*.keystore` dosyaları `.gitignore` içindedir ve asla Git deposuna eklenmez.

---

## 4. macOS Üzerinde iOS Derleme Adımları (Numaralı Rehber)

Geliştirme Windows ortamında yapılmıştır; iOS yapılandırmaları (`ios/Runner/AppDelegate.swift`, `ios/Runner/Info.plist`, `PRODUCT_BUNDLE_IDENTIFIER = com.mustafahali.gunlukegzersiz`) depoda hazırdır. Mac bilgisayarda iOS derlemesi almak için şu adımları sırasıyla uygulayın:

1. **Depoyu Mac bilgisayara klonlayın:**
   ```bash
   git clone https://github.com/MustafaHali1/Gunluk_EgzersizAPK-.git
   cd Gunluk_EgzersizAPK-
   ```
2. **Flutter paketlerini indirin:**
   ```bash
   flutter pub get
   ```
3. **CocoaPods bağımlılıklarını yükleyin:**
   ```bash
   cd ios
   pod install --repo-update
   cd ..
   ```
4. **Xcode ile projeyi açın ve imzalama (Signing) ayarlarını yapın:**
   ```bash
   open ios/Runner.xcworkspace
   ```
   - Sol panelden **Runner** projesini seçin.
   - **Signing & Capabilities** sekmesine gelin.
   - **Automatically manage signing** kutucuğunu işaretleyin ve kendi **Apple Developer Team** hesabınızı seçin.
   - Bundle Identifier değerinin `com.mustafahali.gunlukegzersiz` olduğunu doğrulayın.
5. **Fiziksel iPhone veya iOS Simülatöründe test edin:**
   ```bash
   flutter run -d ios
   ```
6. **App Store / TestFlight için IPA paketi üretin:**
   ```bash
   flutter build ipa --release
   ```
   Üretilen `build/ios/archive/Runner.xcarchive` paketini Xcode Organizer veya Transporter uygulaması ile TestFlight'a yükleyin.

### Fiziksel Mac Olmadan iOS Derlemesi Alma (Bulut Seçenekleri)
- **Codemagic:** GitHub deponuzu [Codemagic](https://codemagic.io/) hesabınıza bağlayarak ücretsiz macOS derleme dakikalarıyla doğrudan `.ipa` çıktısı alabilir ve TestFlight'a gönderebilirsiniz.
- **GitHub Actions (`macos-latest`):** `.github/workflows/ci.yml` içerisine `runs-on: macos-latest` kullanan bir iş (job) ekleyerek bulutta `flutter build ios --no-codesign` veya sertifikalarınızla imzalı `.ipa` derlemesi üretebilirsiniz.
