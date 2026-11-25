// lib/ozellikler/toplu_rutinler/veri/yerel_bildirim_servisi.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../cekirdek/hatalar/merkezi_kaydedici.dart';

final yerelBildirimServisiSaglayici = Provider<YerelBildirimServisi>((ref) {
  return YerelBildirimServisi();
});

/// Toplu rutinler için sabah motivasyonu (08:30) ve akşam seri kurtarma (20:30) alarmlarını kuran yerel servis.
class YerelBildirimServisi {
  final FlutterLocalNotificationsPlugin _eklenti = FlutterLocalNotificationsPlugin();
  bool _baslatildi = false;

  static const int sabahBildirimId = 99881;
  static const int aksamSeriBildirimId = 99882;

  Future<void> baslat() async {
    if (_baslatildi) return;

    try {
      const androidAyarlari = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosAyarlari = DarwinInitializationSettings();
      const baslatmaAyarlari = InitializationSettings(android: androidAyarlari, iOS: iosAyarlari);

      await _eklenti.initialize(settings: baslatmaAyarlari);
      _baslatildi = true;
    } catch (e, yiginIzi) {
      MerkeziKaydedici.hataYaz('Yerel bildirim servisi başlatma hatası', hata: e, yiginIzi: yiginIzi);
    }
  }

  /// Anlık bir bildirim basar (Yeni mesaj veya kanıt geldiğinde).
  Future<void> anlikBildirimGoster({
    required int id,
    required String baslik,
    required String icerik,
    String? payload,
  }) async {
    await baslat();

    const androidDetay = AndroidNotificationDetails(
      'toplu_rutinler_kanali',
      'Toplu Rutinler',
      channelDescription: 'Toplu rutin mesajları ve kanıt bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetay = DarwinNotificationDetails();
    const bildirimDetay = NotificationDetails(android: androidDetay, iOS: iosDetay);

    await _eklenti.show(
      id: id,
      title: baslik,
      body: icerik,
      notificationDetails: bildirimDetay,
      payload: payload,
    );
  }

  /// Sabah 08:30 ve akşam 20:30 günlük hatırlatıcılarını planlar.
  Future<void> gunlukHatirlaticilariKur({
    required String rutinAdi,
  }) async {
    await baslat();

    try {
      // 1. Sabah 08:30 Motivasyon Bildirimi
      final sabahZamani = _sonrakiSaatZamani(8, 30);
      await _eklenti.zonedSchedule(
        id: sabahBildirimId,
        title: '☀️ Günaydın! $rutinAdi',
        body: 'Günün ilk hareketini tamamla, ekibinle zirveye tırman!',
        scheduledDate: sabahZamani,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'toplu_rutinler_sabah',
            'Sabah Motivasyonu',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // 2. Akşam 20:30 Seri Kurtarma Bildirimi
      final aksamZamani = _sonrakiSaatZamani(20, 30);
      await _eklenti.zonedSchedule(
        id: aksamSeriBildirimId,
        title: '🔥 Serin Tehlikede!',
        body: 'Bugünkü $rutinAdi görevlerini henüz tamamlamadın. Serini kurtarmak için 1 fotoğraf yükle!',
        scheduledDate: aksamZamani,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'toplu_rutinler_seri',
            'Seri Kurtarma Uyarısı',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      MerkeziKaydedici.bilgiYaz('Günlük bildirim planlama hatası: $e');
    }
  }

  tz.TZDateTime _sonrakiSaatZamani(int saat, int dakika) {
    final simdi = tz.TZDateTime.now(tz.local);
    var planlanan = tz.TZDateTime(tz.local, simdi.year, simdi.month, simdi.day, saat, dakika);
    if (planlanan.isBefore(simdi)) {
      planlanan = planlanan.add(const Duration(days: 1));
    }
    return planlanan;
  }
}
