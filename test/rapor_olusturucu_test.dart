// test/rapor_olusturucu_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:gunluk_egzersiz/cekirdek/veritabani/uygulama_veritabani.dart';
import 'package:gunluk_egzersiz/ozellikler/bugun/veri/antrenman_dao.dart';
import 'package:gunluk_egzersiz/ozellikler/rapor/alan/rapor_olusturucu.dart';
import 'package:gunluk_egzersiz/ozellikler/rapor/veri/pdf_disa_aktarma_servisi.dart';

void main() {
  test(
    'RaporOlusturucu boş gün, atlanan hareket, planlı olmayan gün ve arşivlenmiş hareketi doğru hesaplar',
    () async {
      // 2026-11-09 Pzt (1), 2026-11-10 Sal (2 - planlı değil), 2026-11-11 Çar (3 - boş ama planlı)
      final aktifHareket = const EgzersizlerData(
        id: 1,
        ad: 'Squat',
        aciklama: '',
        tur: 'tekrarli',
        sureSaniye: null,
        setSayisi: 3,
        tekrarSayisi: 15,
        kategori: 'Alt Vücut',
        arsivlendiMi: false,
      );

      // Hareket 2 arşivlenmiş (rutinEgzersizleri içinde yok), ama geçmiş kayıtta egzersizAdiKopyasi ile var
      final kayitlar = <GunlukAntrenmanDetayi>[
        const GunlukAntrenmanDetayi(
          antrenmanKaydi: AntrenmanKayitlariData(
            id: 1,
            tarih: '2026-11-09',
            rutinId: 1,
          ),
          egzersizKayitlari: [
            EgzersizKayitlariData(
              id: 10,
              antrenmanKaydiId: 1,
              egzersizId: 1,
              egzersizAdiKopyasi: 'Squat',
              durum: 'yapildi',
              notMetni: null,
            ),
            EgzersizKayitlariData(
              id: 11,
              antrenmanKaydiId: 1,
              egzersizId: 2,
              egzersizAdiKopyasi: 'Eski Arşivlenmiş Plank',
              durum: 'atlandi',
              notMetni: 'Bel ağrısı',
            ),
          ],
        ),
      ];

      final rapor = RaporOlusturucu.olustur(
        baslangic: DateTime(2026, 11, 9),
        bitis: DateTime(2026, 11, 11),
        antrenmanKayitlari: kayitlar,
        planliHaftaninGunleri: {1, 3}, // Pazartesi ve Çarşamba planlı; Salı planlı değil
        rutinEgzersizleri: [aktifHareket],
      );

      expect(rapor.gunler, ['2026-11-09', '2026-11-10', '2026-11-11']);
      expect(rapor.satirlar.length, 2);

      final squatSatiri = rapor.satirlar.firstWhere((s) => s.egzersizId == 1);
      // Pzt: yapıldı (✅), Sal: planlı değil (➖), Çar: planlı ama boş/işaretsiz (❌)
      expect(
        squatSatiri.gunlukDurumlar['2026-11-09'],
        RaporHucreDurumu.yapildi,
      );
      expect(
        squatSatiri.gunlukDurumlar['2026-11-10'],
        RaporHucreDurumu.planliDegil,
      );
      expect(
        squatSatiri.gunlukDurumlar['2026-11-11'],
        RaporHucreDurumu.yapilmadi,
      );
      expect(squatSatiri.tamamlanmaYuzdesi, 50); // 1/2 planlı gün yapıldı

      final arsivliSatir = rapor.satirlar.firstWhere((s) => s.egzersizId == 2);
      expect(arsivliSatir.egzersizAdi, 'Eski Arşivlenmiş Plank');
      expect(
        arsivliSatir.gunlukDurumlar['2026-11-09'],
        RaporHucreDurumu.yapilmadi,
      );
      expect(arsivliSatir.tamamlanmaYuzdesi, 0);

      // PDF bayt üretiminin çevrimdışı hatasız çalıştığını doğrula
      final pdfServisi = PdfDisaAktarmaServisi();
      final pdfBaytlari = await pdfServisi.pdfBaytlariniOlustur(rapor);
      expect(pdfBaytlari.isNotEmpty, true);
    },
  );
}
