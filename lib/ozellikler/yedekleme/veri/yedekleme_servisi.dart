// lib/ozellikler/yedekleme/veri/yedekleme_servisi.dart

import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../cekirdek/hatalar/merkezi_kaydedici.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';
import '../../../cekirdek/yardimcilar/tarih_yardimcisi.dart';

// Veritabanını JSON olarak dışa aktarma, şema doğrulamalı içe aktarma ve sıfırlama servisi.
class YedeklemeServisi {
  static const int desteklenenSemaSurumu = 1;

  final UygulamaVeritabani _veritabani;

  const YedeklemeServisi(this._veritabani);

  // Tüm veritabanı tablolarını JSON metnine dönüştürür.
  Future<String> verileriJsonMetnineDonustur() async {
    final egzersizListesi = await _veritabani
        .select(_veritabani.egzersizler)
        .get();
    final rutinListesi = await _veritabani.select(_veritabani.rutinler).get();
    final rutinEgzersizListesi = await _veritabani
        .select(_veritabani.rutinEgzersizleri)
        .get();
    final antrenmanListesi = await _veritabani
        .select(_veritabani.antrenmanKayitlari)
        .get();
    final egzersizKayitListesi = await _veritabani
        .select(_veritabani.egzersizKayitlari)
        .get();
    final hatirlaticiListesi = await _veritabani
        .select(_veritabani.hatirlaticilar)
        .get();

    final veriHaritasi = <String, dynamic>{
      'semaSurumu': desteklenenSemaSurumu,
      'olusturulmaTarihi': DateTime.now().toIso8601String(),
      'egzersizler': egzersizListesi.map((e) => e.toJson()).toList(),
      'rutinler': rutinListesi.map((e) => e.toJson()).toList(),
      'rutin_egzersizleri': rutinEgzersizListesi
          .map((e) => e.toJson())
          .toList(),
      'antrenman_kayitlari': antrenmanListesi.map((e) => e.toJson()).toList(),
      'egzersiz_kayitlari': egzersizKayitListesi
          .map((e) => e.toJson())
          .toList(),
      'hatirlaticilar': hatirlaticiListesi.map((e) => e.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(veriHaritasi);
  }

  // Verileri geçici bir JSON dosyasına yazar ve share_plus ile paylaşır.
  Future<void> yedegiDosyaOlarakPaylas() async {
    try {
      final jsonMetni = await verileriJsonMetnineDonustur();
      final geciciKlasor = await getTemporaryDirectory();
      final tarih = TarihYardimcisi.bugununTarihi();
      final dosya = File(
        '${geciciKlasor.path}/gunluk_egzersiz_yedek_$tarih.json',
      );
      await dosya.writeAsString(jsonMetni, encoding: utf8);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(dosya.path)],
          subject: 'Günlük Egzersiz Veri Yedeği ($tarih)',
        ),
      );
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Yedek dosyası paylaşılırken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Yedek dosyası dışa aktarılamadı.');
    }
  }

  // Kullanıcının cihazından bir JSON yedek dosyası seçmesini sağlar ve içeriğini okur.
  Future<String?> yedekDosyasiSecVeOku() async {
    try {
      final dosyalar = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (dosyalar.isEmpty) return null;

      final dosyaYolu = dosyalar.first.path;
      if (dosyaYolu == null) {
        throw const UygulamaHatasi('Seçilen dosyanın yolu okunamadı.');
      }
      return await File(dosyaYolu).readAsString(encoding: utf8);
    } on UygulamaHatasi {
      rethrow;
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Yedek dosyası okunurken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Seçilen yedek dosyası okunamadı.');
    }
  }

  // JSON metnini doğrular (şema sürümü ve bütünlük kontrolü) ve veritabanına geri yükler.
  Future<void> jsonMetnindenGeriYukle(String jsonMetni) async {
    final Map<String, dynamic> kokHarita;
    try {
      final cozumlenen = jsonDecode(jsonMetni);
      if (cozumlenen is! Map<String, dynamic>) {
        throw const FormatException('Kök JSON nesnesi geçersiz.');
      }
      kokHarita = cozumlenen;
    } catch (hata) {
      throw const UygulamaHatasi(
        'Yedek dosyası bozuk veya geçerli bir JSON formatında değil.',
      );
    }

    final semaSurumu = kokHarita['semaSurumu'];
    if (semaSurumu is! int) {
      throw const UygulamaHatasi(
        'Yedek dosyasında şema sürümü (semaSurumu) bilgisi bulunamadı.',
      );
    }
    if (semaSurumu != desteklenenSemaSurumu) {
      throw UygulamaHatasi(
        'Desteklenmeyen yedek şema sürümü: $semaSurumu (Beklenen: $desteklenenSemaSurumu).',
      );
    }

    const zorunluAlanlar = [
      'egzersizler',
      'rutinler',
      'rutin_egzersizleri',
      'antrenman_kayitlari',
      'egzersiz_kayitlari',
      'hatirlaticilar',
    ];

    for (final alan in zorunluAlanlar) {
      if (kokHarita[alan] is! List) {
        throw UygulamaHatasi(
          'Yedek dosyası eksik veya bozuk: "$alan" tablosu bulunamadı.',
        );
      }
    }

    try {
      final egzersizlerVerisi = (kokHarita['egzersizler'] as List)
          .map((e) => EgzersizlerData.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      final rutinlerVerisi = (kokHarita['rutinler'] as List)
          .map((e) => RutinlerData.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      final rutinEgzersizleriVerisi = (kokHarita['rutin_egzersizleri'] as List)
          .map(
            (e) => RutinEgzersizleriData.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
      final antrenmanKayitlariVerisi =
          (kokHarita['antrenman_kayitlari'] as List)
              .map(
                (e) => AntrenmanKayitlariData.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList();
      final egzersizKayitlariVerisi = (kokHarita['egzersiz_kayitlari'] as List)
          .map(
            (e) => EgzersizKayitlariData.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
      final hatirlaticilarVerisi = (kokHarita['hatirlaticilar'] as List)
          .map(
            (e) => HatirlaticilarData.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();

      await _veritabani.transaction(() async {
        await _veritabani.delete(_veritabani.egzersizKayitlari).go();
        await _veritabani.delete(_veritabani.antrenmanKayitlari).go();
        await _veritabani.delete(_veritabani.rutinEgzersizleri).go();
        await _veritabani.delete(_veritabani.rutinler).go();
        await _veritabani.delete(_veritabani.egzersizler).go();
        await _veritabani.delete(_veritabani.hatirlaticilar).go();

        for (final oge in egzersizlerVerisi) {
          await _veritabani.into(_veritabani.egzersizler).insert(oge);
        }
        for (final oge in rutinlerVerisi) {
          await _veritabani.into(_veritabani.rutinler).insert(oge);
        }
        for (final oge in rutinEgzersizleriVerisi) {
          await _veritabani.into(_veritabani.rutinEgzersizleri).insert(oge);
        }
        for (final oge in antrenmanKayitlariVerisi) {
          await _veritabani.into(_veritabani.antrenmanKayitlari).insert(oge);
        }
        for (final oge in egzersizKayitlariVerisi) {
          await _veritabani.into(_veritabani.egzersizKayitlari).insert(oge);
        }
        for (final oge in hatirlaticilarVerisi) {
          await _veritabani.into(_veritabani.hatirlaticilar).insert(oge);
        }
      });
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Yedek verileri veritabanına aktarılırken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi(
        'Yedek dosyasındaki kayıtlar bozuk olduğu için içe aktarılamadı.',
      );
    }
  }

  // Tüm egzersiz, rutin ve antrenman geçmişini siler; hatırlatıcıları varsayılana döndürür.
  Future<void> tumVerileriSil() async {
    try {
      await _veritabani.transaction(() async {
        await _veritabani.delete(_veritabani.egzersizKayitlari).go();
        await _veritabani.delete(_veritabani.antrenmanKayitlari).go();
        await _veritabani.delete(_veritabani.rutinEgzersizleri).go();
        await _veritabani.delete(_veritabani.rutinler).go();
        await _veritabani.delete(_veritabani.egzersizler).go();
        await _veritabani.delete(_veritabani.hatirlaticilar).go();

        await _veritabani.into(_veritabani.hatirlaticilar).insert(
          HatirlaticilarCompanion.insert(
            etiket: 'sabah',
            saat: 8,
            dakika: 30,
            haftaninGunleri: const Value('1,2,3,4,5,6,7'),
            etkinMi: const Value(true),
          ),
        );
        await _veritabani.into(_veritabani.hatirlaticilar).insert(
          HatirlaticilarCompanion.insert(
            etiket: 'aksam',
            saat: 20,
            dakika: 0,
            haftaninGunleri: const Value('1,2,3,4,5,6,7'),
            etkinMi: const Value(true),
          ),
        );
      });
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz(
        'Tüm veriler silinirken hata oluştu',
        hata: hata,
        yiginIzi: iz,
      );
      throw const UygulamaHatasi('Veriler silinirken bir hata oluştu.');
    }
  }
}

// YedeklemeServisi sağlayıcısı.
final yedeklemeServisiSaglayici = Provider<YedeklemeServisi>((ref) {
  final veritabani = ref.watch(veritabaniSaglayici);
  return YedeklemeServisi(veritabani);
});
