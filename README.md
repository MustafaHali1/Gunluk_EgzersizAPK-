# Günlük Egzersiz

Kullanıcının kendi egzersizlerini tanımladığı, haftalık rutin oluşturduğu, sabah ve akşam bildirimleriyle hatırlatıldığı, günlük hareket takibi yaptığı ve doktoruna gösterebileceği PDF rapor üretebildiği çevrimdışı (offline-first) mobil uygulama.

## Temel Bilgiler
- **Uygulama Adı:** Günlük Egzersiz
- **Paket Kimliği (Application ID / Bundle ID):** `com.mustafahali.gunlukegzersiz`
- **Sürüm:** `0.1.0+1`
- **Veri Saklama:** Yalnızca cihaz içi yerel SQLite (`drift`). Sunucu (backend) yoktur.

## Geliştirme Ortamında Çalıştırma
```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Mac Üzerinde iOS Derleme Adımları (Ön Bilgi)
1. Depoyu Mac bilgisayara klonlayın: `git clone https://github.com/MustafaHali1/Gunluk_EgzersizAPK-.git`
2. Proje klasörüne girin ve paketleri indirin: `flutter pub get`
3. `ios/` klasöründe CocoaPods bağımlılıklarını kurun: `cd ios && pod install && cd ..`
4. `ios/Runner.xcworkspace` dosyasını Xcode ile açıp Signing & Capabilities altından Apple geliştirici hesabınızı seçin.
5. `flutter build ipa` veya Xcode üzerinden Archive alarak derleyin. (Detaylı iOS adımları Adım 11'de genişletilecektir.)
