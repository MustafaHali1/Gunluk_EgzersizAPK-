// lib/cekirdek/bildirimler/bildirim_servisi.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_veri;
import 'package:timezone/timezone.dart' as tz;
import '../hatalar/merkezi_kaydedici.dart';
import '../veritabani/uygulama_veritabani.dart';
import '../yardimcilar/tarih_yardimcisi.dart';

// Bildirim içindeki "Hepsini Yaptım" aksiyon butonuna arka planda tıklandığında çalışan işleyici.
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

// Android ve iOS uyandırma alarmı / hatırlatıcı bildirimlerini ve müzik seçimini yöneten servis.
class BildirimServisi {
  static const String varsayilanKanalTabani = 'gunluk_egzersiz_alarm_kanali';
  static const String kanalAdi = 'Egzersiz Uyandırma Alarmı';
  static const String kanalAciklamasi =
      'Rutin vakti geldiğinde çalar saat / müzik ile hatırlatan alarm bildirimleri';
  static const String aksiyonBaslaId = 'aksiyon_rutine_basla';
  static const String aksiyonYaptimId = 'aksiyon_yaptim';
  static const String iosKategoriId = 'egzersiz_hatirlatici_kategori';
  static const String sistemAlarmSesiUri =
      'content://settings/system/alarm_alert';

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
                aksiyonBaslaId,
                'Rutini Aç ve Başla',
                options: <DarwinNotificationActionOption>{
                  DarwinNotificationActionOption.foreground,
                },
              ),
              DarwinNotificationAction.plain(
                aksiyonYaptimId,
                'Hepsini Yaptım',
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
        await androidEklenti?.requestFullScreenIntentPermission();
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

  // Uygulama kapalıyken alarma/bildirime tıklanarak açıldıysa yanıtı döndürür.
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

  // Tüm kurulu alarmları ve çalan bildirimi iptal eder.
  Future<void> tumBildirimleriIptalEt() async {
    try {
      await _eklenti.cancelAll();
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Alarmlar iptal edilirken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
    }
  }

  // Seçili alarm müziği ile anlık uyandırma alarmı testi gönderir.
  Future<void> testBildirimiGonder({String? ozelMuzikYolu}) async {
    try {
      await _eklenti.show(
        id: 999,
        title: '⏰ Egzersiz Alarmı Çalıyor!',
        body: 'Rutininizi açıp hareketleri Yaptım / Yapmadım olarak işaretleyin.',
        notificationDetails: _alarmDetaylariniOlustur(
          ozelMuzikYolu: ozelMuzikYolu,
        ),
        payload: '/bugun',
      );
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Test alarmı gönderilirken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Test alarmı gönderilemedi.');
    }
  }

  // Sabah ve akşam hatırlatıcılarını seçilen alarm müziğiyle kurar.
  Future<void> hatirlaticilariYenidenKur(
    List<HatirlaticilarData> hatirlaticilar, {
    bool kullaniciAlarmIstiyorMu = true,
    String? ozelMuzikYolu,
  }) async {
    try {
      await _saatDiliminiYapilandir();
      await _eklenti.cancelAll();

      if (!kullaniciAlarmIstiyorMu) {
        MerkeziKaydedici.bilgiYaz(
          'Kullanıcı hatırlatıcı istemediği için tüm alarmlar kapalı tutuldu.',
        );
        return;
      }

      final detaylar = _alarmDetaylariniOlustur(ozelMuzikYolu: ozelMuzikYolu);

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
            ? '⏰ Sabah Egzersiz Alarmı!'
            : '⏰ Akşam Egzersiz Alarmı!';
        final icerik =
            'Egzersiz vakti geldi! Dokunarak rutininizi açın ve hareketleri Yaptım / Yapmadım işaretleyin.';

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
            notificationDetails: detaylar,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            payload: '/bugun',
          );
        }
      }
      MerkeziKaydedici.bilgiYaz('Egzersiz alarmları yeniden kuruldu.');
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Alarmlar kurulurken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Alarm saatleri kurulamadı.');
    }
  }

  // Uyandırma alarmı gibi sürekli çalan (FLAG_INSISTENT = 4) ve özel müzik destekleyen bildirim detayı.
  NotificationDetails _alarmDetaylariniOlustur({String? ozelMuzikYolu}) {
    final bool ozelDosyaVar =
        ozelMuzikYolu != null &&
        ozelMuzikYolu.trim().isNotEmpty &&
        File(ozelMuzikYolu).existsSync();

    final String sesUri = ozelDosyaVar
        ? Uri.file(ozelMuzikYolu).toString()
        : sistemAlarmSesiUri;

    final String kanalKimligi = ozelDosyaVar
        ? '${varsayilanKanalTabani}_${ozelMuzikYolu.hashCode.abs()}'
        : '${varsayilanKanalTabani}_sistem_alarm';

    final androidDetay = AndroidNotificationDetails(
      kanalKimligi,
      kanalAdi,
      channelDescription: kanalAciklamasi,
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      playSound: true,
      sound: UriAndroidNotificationSound(sesUri),
      audioAttributesUsage: AudioAttributesUsage.alarm,
      // FLAG_INSISTENT (4): Kullanıcı bildirime dokunana veya kapatana kadar müziği alarm gibi tekrarlar.
      additionalFlags: Int32List.fromList(<int>[4]),
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction(
          aksiyonBaslaId,
          'Rutini Aç ve Başla',
          showsUserInterface: true,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          aksiyonYaptimId,
          'Hepsini Yaptım',
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
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    return NotificationDetails(android: androidDetay, iOS: iosDetay);
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
