// lib/ozellikler/rapor/veri/pdf_disa_aktarma_servisi.dart

import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../cekirdek/hatalar/merkezi_kaydedici.dart';
import '../../../cekirdek/sabitler/uygulama_sabitleri.dart';
import '../../../cekirdek/yardimcilar/tarih_yardimcisi.dart';
import '../alan/rapor_olusturucu.dart';

// RaporTablosu verisini yatay A4 PDF belgesine dönüştüren ve paylaşan servis sınıfı.
class PdfDisaAktarmaServisi {
  // Çevrimdışı (offline) gömülü PDF Helvetica yazı tipinde desteklenmeyen Türkçe karakterleri
  // güvenli karşılıklarına dönüştürerek PDF oluşturmanın çevrimdışı hata vermesini önler.
  String _pdfMetniTemizle(String metin) {
    return metin
        .replaceAll('ğ', 'g')
        .replaceAll('Ğ', 'G')
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'I')
        .replaceAll('ş', 's')
        .replaceAll('Ş', 'S');
  }

  String _kisaTarihBasligi(String tarihMetni) {
    final parcalar = tarihMetni.split('-');
    if (parcalar.length != 3) return tarihMetni;
    return '${parcalar[2]}/${parcalar[1]}';
  }

  String _hucrePdfKodu(RaporHucreDurumu durum) {
    switch (durum) {
      case RaporHucreDurumu.yapildi:
        return 'OK';
      case RaporHucreDurumu.yapilmadi:
        return 'X';
      case RaporHucreDurumu.planliDegil:
        return '-';
    }
  }

  // RaporTablosu nesnesinden yatay (landscape) PDF bayt dizisi üretir.
  Future<Uint8List> pdfBaytlariniOlustur(RaporTablosu tablo) async {
    final belge = pw.Document();
    final olusturmaTarihi = TarihYardimcisi.tarihiFormatla(DateTime.now());

    // Çok fazla sütun varsa (örn. 30 gün) sayfaya sığması için 15'er günlük parçalara böl
    const maksimumGunSutunu = 15;
    final gunBloklari = <List<String>>[];
    for (var i = 0; i < tablo.gunler.length; i += maksimumGunSutunu) {
      final son = (i + maksimumGunSutunu < tablo.gunler.length)
          ? i + maksimumGunSutunu
          : tablo.gunler.length;
      gunBloklari.add(tablo.gunler.sublist(i, son));
    }
    if (gunBloklari.isEmpty) {
      gunBloklari.add(const []);
    }

    belge.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        header: (baglam) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  _pdfMetniTemizle('Günlük Egzersiz Takip Raporu'),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  _pdfMetniTemizle('Oluşturma Tarihi: $olusturmaTarihi'),
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              _pdfMetniTemizle(
                'Tarih Aralığı: ${tablo.baslangicTarihi} — ${tablo.bitisTarihi}   |   '
                'Genel Tamamlanma: %${tablo.genelTamamlanmaYuzdesi}   |   '
                'En Uzun Seri: ${tablo.enUzunSeri} Gün',
              ),
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              _pdfMetniTemizle(
                'Semboller: [OK] Yapıldı   [X] Yapılmadı / Atlandı   [-] Planlı Değil',
              ),
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.Divider(),
          ],
        ),
        footer: (baglam) => pw.Column(
          children: [
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  _pdfMetniTemizle(UygulamaMetinleri.tibbiUyariNotu),
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.Text(
                  'Sayfa ${baglam.pageNumber} / ${baglam.pagesCount}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ],
            ),
          ],
        ),
        build: (baglam) {
          if (tablo.satirlar.isEmpty) {
            return [
              pw.Padding(
                padding: const pw.EdgeInsets.all(20),
                child: pw.Text(
                  _pdfMetniTemizle(
                    'Seçilen tarih aralığında kayıtlı hareket bulunmamaktadır.',
                  ),
                ),
              ),
            ];
          }

          return gunBloklari.map((blokGunleri) {
            final basliklar = <String>[
              _pdfMetniTemizle('Hareket Adı'),
              ...blokGunleri.map(_kisaTarihBasligi),
              '%',
            ];

            final veriler = tablo.satirlar.map((satir) {
              return <String>[
                _pdfMetniTemizle(satir.egzersizAdi),
                ...blokGunleri.map(
                  (g) => _hucrePdfKodu(
                    satir.gunlukDurumlar[g] ?? RaporHucreDurumu.planliDegil,
                  ),
                ),
                '%${satir.tamamlanmaYuzdesi}',
              ];
            }).toList();

            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 16),
              child: pw.TableHelper.fromTextArray(
                headers: basliklar,
                data: veriler,
                headerStyle: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.teal700,
                ),
                cellStyle: const pw.TextStyle(fontSize: 8),
                cellAlignment: pw.Alignment.center,
                cellAlignments: {0: pw.Alignment.centerLeft},
              ),
            );
          }).toList();
        },
      ),
    );

    return belge.save();
  }

  // Raporu PDF olarak oluşturur ve sistem paylaşım penceresini açar.
  Future<void> raporuPdfOlarakPaylas(RaporTablosu tablo) async {
    try {
      final baytlar = await pdfBaytlariniOlustur(tablo);
      final dosyaAdi =
          'egzersiz_raporu_${tablo.baslangicTarihi}_${tablo.bitisTarihi}.pdf';
      await Printing.sharePdf(bytes: baytlar, filename: dosyaAdi);
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'PDF raporu paylaşılırken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('PDF raporu oluşturulamadı veya paylaşılamadı.');
    }
  }
}

// PdfDisaAktarmaServisi sağlayıcısı.
final pdfDisaAktarmaServisiSaglayici = Provider<PdfDisaAktarmaServisi>(
  (ref) => PdfDisaAktarmaServisi(),
);
