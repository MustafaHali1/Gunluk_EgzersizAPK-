// lib/cekirdek/bildirimler/bildirim_servisi.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
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
      final rutinId = BildirimServisi.payloaddanRutinIdCoz(yanit.payload);
      await veritabani.antrenmanDao.gununTumHareketleriniYapildiIsaretle(
        tarih: TarihYardimcisi.tarihiFormatla(simdi),
        haftaninGunu: simdi.weekday,
        rutinId: rutinId,
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

// Android ve iOS rutine bağlı uyandırma alarmı / hatırlatıcı bildirimlerini yöneten servis.
class BildirimServisi {
  static const String varsayilanKanalTabani = 'gunluk_rutin_alarm_kanali';
  static const String kanalAdi = 'Rutin Uyandırma Alarmı';
  static const String kanalAciklamasi =
      'Rutin vakti geldiğinde seçilen müzik veya alarm sesiyle hatırlatan bildirimler';
  static const String aksiyonBaslaId = 'aksiyon_rutine_basla';
  static const String aksiyonYaptimId = 'aksiyon_yaptim';
  static const String iosKategoriId = 'rutin_hatirlatici_kategori';
  static const String sistemAlarmSesiUri =
      'content://settings/system/alarm_alert';
  static const MethodChannel _alarmKanali = MethodChannel(
    'com.mustafahali.gunlukegzersiz/alarm',
  );

  final FlutterLocalNotificationsPlugin _eklenti =
      FlutterLocalNotificationsPlugin();
  bool _baslatildiMi = false;
  void Function(NotificationResponse)? _onTepkiVerildiginde;

  static int? payloaddanRutinIdCoz(String? payload) {
    if (payload == null || !payload.startsWith('/rutin/')) return null;
    final uri = Uri.tryParse(payload);
    if (uri != null && uri.pathSegments.length >= 2) {
      return int.tryParse(uri.pathSegments[1]);
    }
    return int.tryParse(payload.replaceFirst('/rutin/', ''));
  }

  static int? payloaddanTetiklenmeMilisCoz(String? payload) {
    if (payload == null || !payload.startsWith('/rutin/')) return null;
    final uri = Uri.tryParse(payload);
    final tetik = uri?.queryParameters['tetik'];
    return tetik != null ? int.tryParse(tetik) : null;
  }

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
                'Rutini Aç',
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

      if (Platform.isAndroid) {
        _alarmKanali.setMethodCallHandler((cagri) async {
          if (cagri.method == 'rutinAc') {
            int? rutinId;
            int? tetik;
            if (cagri.arguments is Map) {
              final args = cagri.arguments as Map;
              rutinId = (args['rutinId'] as num?)?.toInt();
              tetik = (args['tetiklenmeMilis'] as num?)?.toInt();
            } else {
              rutinId = (cagri.arguments as num?)?.toInt();
            }
            if (rutinId != null && rutinId > 0) {
              final tetikSorgu = tetik != null ? '?tetik=$tetik' : '';
              _onTepkiVerildiginde?.call(
                NotificationResponse(
                  notificationResponseType:
                      NotificationResponseType.selectedNotification,
                  payload: '/rutin/$rutinId$tetikSorgu',
                ),
              );
            }
          }
        });
      }

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
      if (Platform.isAndroid) {
        final acilisBilgisi = await _alarmKanali
            .invokeMethod<Map<Object?, Object?>?>('acilisRutinBilgisiGetir');
        final acilisRutinId = (acilisBilgisi?['rutinId'] as num?)?.toInt();
        final tetik = (acilisBilgisi?['tetiklenmeMilis'] as num?)?.toInt();
        if (acilisRutinId != null && acilisRutinId > 0) {
          final tetikSorgu = tetik != null ? '?tetik=$tetik' : '';
          return NotificationResponse(
            notificationResponseType:
                NotificationResponseType.selectedNotification,
            payload: '/rutin/$acilisRutinId$tetikSorgu',
          );
        }
      }
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
      if (Platform.isAndroid) {
        await _alarmKanali.invokeMethod('tumAlarmlariIptalEt');
      }
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Alarmlar iptal edilirken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
    }
  }

  // Seçili alarm müziği ile anlık uyandırma alarmı testi gönderir.
  Future<void> testBildirimiGonder({
    String? ozelMuzikYolu,
    String? rutinAdi,
    int? rutinId,
  }) async {
    try {
      if (Platform.isAndroid) {
        await _alarmKanali.invokeMethod('simdiTestAlarmiCal', {
          'rutinId': rutinId ?? 0,
          'rutinAdi': rutinAdi ?? 'Rutin',
          'muzikYolu': ozelMuzikYolu,
        });
        return;
      }
      await _eklenti.show(
        id: 999,
        title: '⏰ ${rutinAdi ?? 'Rutin'} Alarmı Çalıyor!',
        body: 'Dokunarak rutinin içini açın ve görevleri işaretleyin.',
        notificationDetails: _alarmDetaylariniOlustur(
          ozelMuzikYolu: ozelMuzikYolu,
        ),
        payload: rutinId != null ? '/rutin/$rutinId' : '/bugun',
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

  // Varsayılan erteleme süresini (dakika) Android yerel alarm yöneticisine kaydeder.
  Future<void> varsayilanErtelemeDakikasiKaydet(int dakika) async {
    if (!Platform.isAndroid) return;
    try {
      await _alarmKanali.invokeMethod('varsayilanErtelemeKaydet', dakika);
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Varsayılan erteleme süresi kaydedilirken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
    }
  }

  // Her rutinin kendi alarm saati ve müziğine göre tüm alarmları yeniden kurar.
  Future<void> rutinAlarmlariniYenidenKur(List<RutinlerData> rutinler) async {
    try {
      await _saatDiliminiYapilandir();
      await _eklenti.cancelAll();

      if (Platform.isAndroid) {
        final alarmlar = <Map<String, dynamic>>[];
        for (final r in rutinler) {
          final saatler = TarihYardimcisi.alarmSaatleriniCoz(
            alarmSaatleriMetni: r.alarmSaatleri,
            varsayilanSaat: r.alarmSaati,
            varsayilanDakika: r.alarmDakikasi,
          );
          for (var i = 0; i < saatler.length; i++) {
            final (saat, dakika) = saatler[i];
            alarmlar.add(<String, dynamic>{
              'alarmId': (r.id * 100) + i,
              'rutinId': r.id,
              'rutinAdi': r.ad,
              'saat': saat,
              'dakika': dakika,
              'alarmAcikMi': true,
              'sadeceTarih': r.sadeceTarih,
              'haftaninGunleri': r.haftaninGunleri,
              'muzikYolu': r.alarmMuzikYolu,
            });
          }
        }
        await _alarmKanali.invokeMethod('tumAlarmlariKur', alarmlar);
        MerkeziKaydedici.bilgiYaz('Yerel Android rutin alarmları kuruldu.');
        return;
      }

      for (final rutin in rutinler) {
        if (!rutin.alarmAcikMi) continue;

        final detaylar = _alarmDetaylariniOlustur(
          ozelMuzikYolu: rutin.alarmMuzikYolu,
        );
        final tabanId = 1000 + (rutin.id * 10);
        final baslik = '⏰ ${rutin.ad}';
        const icerik =
            'Rutin vakti geldi! Dokunarak görevleri Yaptım / Yapmadım işaretleyin.';
        final payload = '/rutin/${rutin.id}';

        if (rutin.sadeceTarih != null) {
          final tarih = TarihYardimcisi.metindenTarihe(rutin.sadeceTarih!);
          final hedef = tz.TZDateTime(
            tz.local,
            tarih.year,
            tarih.month,
            tarih.day,
            rutin.alarmSaati,
            rutin.alarmDakikasi,
          );
          if (hedef.isAfter(tz.TZDateTime.now(tz.local))) {
            await _eklenti.zonedSchedule(
              id: tabanId,
              title: baslik,
              body: icerik,
              scheduledDate: hedef,
              notificationDetails: detaylar,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              payload: payload,
            );
          }
          continue;
        }

        final gunler = rutin.haftaninGunleri
            .split(',')
            .map((e) => int.tryParse(e.trim()))
            .whereType<int>()
            .toSet();

        for (final gun in gunler) {
          final planlananZaman = _sonrakiGunVeSaatHesapla(
            haftaninGunu: gun,
            saat: rutin.alarmSaati,
            dakika: rutin.alarmDakikasi,
          );

          await _eklenti.zonedSchedule(
            id: tabanId + gun,
            title: baslik,
            body: icerik,
            scheduledDate: planlananZaman,
            notificationDetails: detaylar,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            payload: payload,
          );
        }
      }
      MerkeziKaydedici.bilgiYaz('Rutin alarmları yeniden kuruldu.');
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Rutin alarmları kurulurken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
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
          'Rutini Aç',
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
