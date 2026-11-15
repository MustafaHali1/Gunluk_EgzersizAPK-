// lib/cekirdek/bildirimler/bildirim_servisi.dart

import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_veri;
import 'package:timezone/timezone.dart' as tz;
import '../hatalar/merkezi_kaydedici.dart';
import '../veritabani/uygulama_veritabani.dart';
import '../yardimcilar/tarih_yardimcisi.dart';

// Bildirim içindeki "Yaptım" aksiyon butonuna arka planda tıklandığında çalışan üst seviye işleyici.
// Arka plan izole alanında (isolate) güvenli erişim için kendi UygulamaVeritabani bağlantısını açar,
// bugünün hareketlerini 'yapildi' olarak işaretler ve bağlantıyı hemen kapatır.
@pragma('vm:entry-point')
Future<void> arkaPlanBildirimYanitiIsleyici(
  NotificationResponse yanit,
) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (yanit.actionId == BildirimServisi.aksiyonYaptimId) {
    final veritabani = UygulamaVeritabani();
    try {
      final simdi = DateTime.now();
      await veritabani.antrenmanDao.gununTumHareketleriniYapildiIsaretle(
        tarih: TarihYardimcisi.tarihiFormatla(simdi),
        haftaninGunu: simdi.weekday,
      );
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Arka plan bildirim aksiyonunda veritabanı güncellenemedi',
        hata: hata,
        yiginIzi: iz,
      );
    } finally {
      await veritabani.close();
    }
  }
}

// Android ve iOS bildirim işlemlerini, saat dilimi ayarlarını ve günlük tekrarları yöneten servis sınıfı.
class BildirimServisi {
  static const String kanalId = 'gunluk_egzersiz_hatirlatici_kanali';
  static const String kanalAdi = 'Günlük Egzersiz Hatırlatıcıları';
  static const String kanalAciklamasi =
      'Sabah ve akşam egzersiz rutin hatırlatıcı bildirimleri';
  static const String aksiyonYaptimId = 'aksiyon_yaptim';
  static const String iosKategoriId = 'egzersiz_hatirlatici_kategori';

  final FlutterLocalNotificationsPlugin _eklenti =
      FlutterLocalNotificationsPlugin();
  bool _baslatildiMi = false;
  void Function(NotificationResponse)? _onTepkiVerildiginde;

  // Bildirim servisini ve yerel saat dilimini başlatır.
  Future<void> baslat({
    void Function(NotificationResponse)? bildirimTiklandiginda,
  }) async {
    _onTepkiVerildiginde = bildirimTiklandiginda;
    if (_baslatildiMi) return;

    try {
      await _saatDiliminiYapilandir();

      const androidAyarlari = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      final iosAyarlari = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        notificationCategories: [
          DarwinNotificationCategory(
            iosKategoriId,
            actions: [
              DarwinNotificationAction.plain(
                aksiyonYaptimId,
                'Yaptım',
                options: <DarwinNotificationActionOption>{
                  DarwinNotificationActionOption.foreground,
                },
              ),
            ],
          ),
        ],
      );

      final baslangicAyarlari = InitializationSettings(
        android: androidAyarlari,
        iOS: iosAyarlari,
      );

      await _eklenti.initialize(
        settings: baslangicAyarlari,
        onDidReceiveNotificationResponse: (NotificationResponse yanit) {
          _onTepkiVerildiginde?.call(yanit);
        },
        onDidReceiveBackgroundNotificationResponse:
            arkaPlanBildirimYanitiIsleyici,
      );

      _baslatildiMi = true;
      MerkeziKaydedici.bilgiYaz('BildirimServisi başarıyla başlatıldı.');
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'BildirimServisi başlatılırken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
    }
  }

  // Cihazın güncel saat dilimini algılar ve timezone paketine tanımlar.
  Future<String> _saatDiliminiYapilandir() async {
    tz_veri.initializeTimeZones();
    try {
      final saatDilimiBilgisi = await FlutterTimezone.getLocalTimezone();
      final konumAdi = saatDilimiBilgisi.identifier;
      tz.setLocalLocation(tz.getLocation(konumAdi));
      return konumAdi;
    } catch (hata) {
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
      return 'Europe/Istanbul';
    }
  }

  // Cihazın mevcut saat dilimi kimliğini döndürür.
  Future<String> guncelSaatDiliminiGetir() async {
    return _saatDiliminiYapilandir();
  }

  // Kullanıcıdan bildirim ve tam zamanlı alarm izni ister.
  Future<bool> izinIste() async {
    try {
      if (Platform.isAndroid) {
        final androidEklenti = _eklenti
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        final bildirimIzni =
            await androidEklenti?.requestNotificationsPermission() ?? false;
        await androidEklenti?.requestExactAlarmsPermission();
        return bildirimIzni;
      } else if (Platform.isIOS) {
        final iosEklenti = _eklenti
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        final izin = await iosEklenti?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return izin ?? false;
      }
      return false;
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Bildirim izni istenirken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
      return false;
    }
  }

  // Bildirim izninin verilip verilmediğini kontrol eder.
  Future<bool> izinDurumunuKontrolEt() async {
    try {
      if (Platform.isAndroid) {
        final androidEklenti = _eklenti
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        return await androidEklenti?.areNotificationsEnabled() ?? false;
      } else if (Platform.isIOS) {
        final iosEklenti = _eklenti
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        final izinler = await iosEklenti?.checkPermissions();
        return izinler?.isEnabled ?? false;
      }
      return false;
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Bildirim izin durumu kontrol edilirken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
      return false;
    }
  }

  // Uygulama kapalıyken bildirime tıklanarak açıldıysa o bildirimin yanıtını döndürür.
  Future<NotificationResponse?> acilisBildirimYanitiniGetir() async {
    try {
      final detaylar = await _eklenti.getNotificationAppLaunchDetails();
      if (detaylar != null && detaylar.didNotificationLaunchApp) {
        return detaylar.notificationResponse;
      }
      return null;
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Açılış bildirimi kontrol edilirken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
      return null;
    }
  }

  // Anlık test bildirimi gönderir.
  Future<void> testBildirimiGonder() async {
    try {
      await _eklenti.show(
        id: 999,
        title: 'Günlük Egzersiz Test Bildirimi',
        body: 'Harika! Bildirimleriniz sorunsuz çalışıyor.',
        notificationDetails: _bildirimDetaylariniOlustur(),
        payload: '/bugun',
      );
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Test bildirimi gönderilirken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Test bildirimi gönderilemedi.');
    }
  }

  // Sabah ve akşam hatırlatıcı listesine göre haftalık tekrarlı bildirimleri baştan kurar.
  // iOS 64 bekleyen bildirim limitini aşmamak için DateTimeComponents.dayOfWeekAndTime kullanılır
  // (en fazla 7 sabah + 7 akşam = 14 bildirim kurulur).
  Future<void> hatirlaticilariYenidenKur(
    List<HatirlaticilarData> hatirlaticilar,
  ) async {
    try {
      await _saatDiliminiYapilandir();
      await _eklenti.cancelAll();

      for (final hatirlatici in hatirlaticilar) {
        if (!hatirlatici.etkinMi) continue;

        final gunler = hatirlatici.haftaninGunleri
            .split(',')
            .map((e) => int.tryParse(e.trim()))
            .whereType<int>()
            .toSet();

        final sabahMi = hatirlatici.etiket == 'sabah';
        final tabanId = sabahMi ? 100 : 200;
        final baslik = sabahMi
            ? 'Günaydın! Egzersiz Zamanı'
            : 'İyi Akşamlar! Günün Hareketlerini Tamamla';
        final icerik = sabahMi
            ? 'Bugünkü rutinin seni bekliyor. Hareketlerini yapıp işaretlemeyi unutma!'
            : 'Günü tamamlamadan önce egzersizlerini kontrol et.';

        for (final gun in gunler) {
          final planlananZaman = _sonrakiGunVeSaatHesapla(
            haftaninGunu: gun,
            saat: hatirlatici.saat,
            dakika: hatirlatici.dakika,
          );

          await _eklenti.zonedSchedule(
            id: tabanId + gun,
            title: baslik,
            body: icerik,
            scheduledDate: planlananZaman,
            notificationDetails: _bildirimDetaylariniOlustur(),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            payload: '/bugun',
          );
        }
      }
      MerkeziKaydedici.bilgiYaz('Hatırlatıcı bildirimleri yeniden kuruldu.');
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Hatırlatıcılar kurulurken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Bildirim saatleri kurulamadı.');
    }
  }

  NotificationDetails _bildirimDetaylariniOlustur() {
    const androidDetay = AndroidNotificationDetails(
      kanalId,
      kanalAdi,
      channelDescription: kanalAciklamasi,
      importance: Importance.max,
      priority: Priority.high,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          aksiyonYaptimId,
          'Yaptım',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    const iosDetay = DarwinNotificationDetails(
      categoryIdentifier: iosKategoriId,
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(android: androidDetay, iOS: iosDetay);
  }

  tz.TZDateTime _sonrakiGunVeSaatHesapla({
    required int haftaninGunu,
    required int saat,
    required int dakika,
  }) {
    final simdi = tz.TZDateTime.now(tz.local);
    var hedef = tz.TZDateTime(
      tz.local,
      simdi.year,
      simdi.month,
      simdi.day,
      saat,
      dakika,
    );

    while (hedef.weekday != haftaninGunu || hedef.isBefore(simdi)) {
      hedef = hedef.add(const Duration(days: 1));
    }
    return hedef;
  }
}

// BildirimServisi örneğini sağlayan Riverpod sağlayıcısı.
final bildirimServisiSaglayici = Provider<BildirimServisi>((ref) {
  return BildirimServisi();
});
