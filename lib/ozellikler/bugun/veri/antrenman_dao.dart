// lib/ozellikler/bugun/veri/antrenman_dao.dart

import 'package:drift/drift.dart';
import '../../../cekirdek/veritabani/tablolar.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';

part 'antrenman_dao.g.dart';

// Günlük antrenman ve içindeki hareket kayıtlarını bir arada tutan veri sınıfı.
class GunlukAntrenmanDetayi {
  final AntrenmanKayitlariData antrenmanKaydi;
  final List<EgzersizKayitlariData> egzersizKayitlari;

  const GunlukAntrenmanDetayi({
    required this.antrenmanKaydi,
    required this.egzersizKayitlari,
  });
}

// AntrenmanKayitlari ve EgzersizKayitlari tabloları için veritabanı erişim nesnesi (DAO).
@DriftAccessor(
  tables: [
    AntrenmanKayitlari,
    EgzersizKayitlari,
    Rutinler,
    RutinEgzersizleri,
    Egzersizler,
  ],
)
class AntrenmanDao extends DatabaseAccessor<UygulamaVeritabani>
    with _$AntrenmanDaoMixin {
  AntrenmanDao(super.attachedDatabase);

  // Belirli bir tarihin antrenman kaydını getirir.
  Future<AntrenmanKayitlariData?> tariheGoreAntrenmanGetir(String tarih) {
    return (select(antrenmanKayitlari)..where((t) => t.tarih.equals(tarih)))
        .getSingleOrNull();
  }

  // Belirli bir antrenman kaydına ait tüm egzersiz kayıtlarını getirir.
  Future<List<EgzersizKayitlariData>> antrenmanEgzersizKayitlariniGetir(
    int antrenmanKaydiId,
  ) {
    return (select(egzersizKayitlari)
          ..where((t) => t.antrenmanKaydiId.equals(antrenmanKaydiId))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  // Belirli bir tarihin antrenman ve hareket kayıtlarını bir arada getirir.
  Future<GunlukAntrenmanDetayi?> gunlukAntrenmanDetayiGetir(
    String tarih,
  ) async {
    final antrenman = await tariheGoreAntrenmanGetir(tarih);
    if (antrenman == null) return null;
    final hareketler = await antrenmanEgzersizKayitlariniGetir(antrenman.id);
    return GunlukAntrenmanDetayi(
      antrenmanKaydi: antrenman,
      egzersizKayitlari: hareketler,
    );
  }

  // Belirli bir tarih için antrenman kaydı yoksa oluşturur, aktif rutin değiştiyse eşitler.
  Future<GunlukAntrenmanDetayi> gunlukAntrenmanOlusturVeyaGetir({
    required String tarih,
    required int haftaninGunu,
  }) async {
    return transaction(() async {
      final mevcut = await gunlukAntrenmanDetayiGetir(tarih);

      final aktifRutin = await (select(rutinler)
            ..where((t) => t.aktifMi.equals(true))
            ..limit(1))
          .getSingleOrNull();

      int? kullanilacakRutinId;
      List<EgzersizlerData> rutinHareketleri = [];

      if (aktifRutin != null) {
        final gunler = aktifRutin.haftaninGunleri
            .split(',')
            .map((e) => int.tryParse(e.trim()))
            .whereType<int>()
            .toSet();

        if (gunler.contains(haftaninGunu)) {
          kullanilacakRutinId = aktifRutin.id;
          final birlesikSorgu = select(rutinEgzersizleri).join([
            innerJoin(
              egzersizler,
              egzersizler.id.equalsExp(rutinEgzersizleri.egzersizId),
            ),
          ])
            ..where(rutinEgzersizleri.rutinId.equals(aktifRutin.id))
            ..where(egzersizler.arsivlendiMi.equals(false))
            ..orderBy([OrderingTerm.asc(rutinEgzersizleri.siraIndeksi)]);

          final satirlar = await birlesikSorgu.get();
          rutinHareketleri =
              satirlar.map((s) => s.readTable(egzersizler)).toList();
        }
      }

      if (mevcut != null) {
        final antrenmanId = mevcut.antrenmanKaydi.id;
        final rutinDegistiMi =
            kullanilacakRutinId != null &&
            mevcut.antrenmanKaydi.rutinId != kullanilacakRutinId;

        if (rutinDegistiMi) {
          await (update(antrenmanKayitlari)
                ..where((t) => t.id.equals(antrenmanId)))
              .write(
                AntrenmanKayitlariCompanion(
                  rutinId: Value(kullanilacakRutinId),
                ),
              );
          // Eski rutinden kalan ve henüz işaretlenmemiş ('bekliyor') kayıtları temizle
          await (delete(egzersizKayitlari)
                ..where(
                  (t) =>
                      t.antrenmanKaydiId.equals(antrenmanId) &
                      t.durum.equals('bekliyor'),
                ))
              .go();
        }

        if (kullanilacakRutinId != null) {
          final guncelKayitlar = await antrenmanEgzersizKayitlariniGetir(
            antrenmanId,
          );
          final mevcutEgzersizIdleri = guncelKayitlar
              .map((k) => k.egzersizId)
              .toSet();

          for (final hareket in rutinHareketleri) {
            if (!mevcutEgzersizIdleri.contains(hareket.id)) {
              await into(egzersizKayitlari).insert(
                EgzersizKayitlariCompanion.insert(
                  antrenmanKaydiId: antrenmanId,
                  egzersizId: hareket.id,
                  egzersizAdiKopyasi: hareket.ad,
                  durum: const Value('bekliyor'),
                ),
              );
            }
          }
        }

        final guncelDetay = await gunlukAntrenmanDetayiGetir(tarih);
        return guncelDetay!;
      }

      final antrenmanId = await into(antrenmanKayitlari).insert(
        AntrenmanKayitlariCompanion.insert(
          tarih: tarih,
          rutinId: Value(kullanilacakRutinId),
        ),
      );

      for (final hareket in rutinHareketleri) {
        await into(egzersizKayitlari).insert(
          EgzersizKayitlariCompanion.insert(
            antrenmanKaydiId: antrenmanId,
            egzersizId: hareket.id,
            egzersizAdiKopyasi: hareket.ad,
            durum: const Value('bekliyor'),
          ),
        );
      }

      final olusanDetay = await gunlukAntrenmanDetayiGetir(tarih);
      return olusanDetay!;
    });
  }

  // Tek bir egzersiz kaydının durumunu ('yapildi', 'atlandi', 'bekliyor') ve notunu günceller.
  Future<int> egzersizKaydiDurumunuGuncelle({
    required int egzersizKaydiId,
    required String durum,
    String? notMetni,
  }) {
    return (update(egzersizKayitlari)
          ..where((t) => t.id.equals(egzersizKaydiId)))
        .write(
          EgzersizKayitlariCompanion(
            durum: Value(durum),
            notMetni: notMetni != null ? Value(notMetni) : const Value.absent(),
          ),
        );
  }

  // O güne tek seferlik hızlı egzersiz kaydı ekler.
  Future<int> gunlukHizliEgzersizEkle({
    required int antrenmanKaydiId,
    required int egzersizId,
    required String egzersizAdiKopyasi,
    String? notMetni,
  }) {
    return into(egzersizKayitlari).insert(
      EgzersizKayitlariCompanion.insert(
        antrenmanKaydiId: antrenmanKaydiId,
        egzersizId: egzersizId,
        egzersizAdiKopyasi: egzersizAdiKopyasi,
        durum: const Value('bekliyor'),
        notMetni: Value(notMetni),
      ),
    );
  }

  // Belirli bir günün tüm bekleyen hareketlerini 'yapildi' olarak işaretler (bildirim aksiyonu için).
  Future<void> gununTumHareketleriniYapildiIsaretle({
    required String tarih,
    required int haftaninGunu,
  }) async {
    final detay = await gunlukAntrenmanOlusturVeyaGetir(
      tarih: tarih,
      haftaninGunu: haftaninGunu,
    );
    await (update(egzersizKayitlari)
          ..where((t) => t.antrenmanKaydiId.equals(detay.antrenmanKaydi.id)))
        .write(const EgzersizKayitlariCompanion(durum: Value('yapildi')));
  }

  // Tarih aralığındaki tüm antrenman detaylarını getirir (Rapor ve Geçmiş için).
  Future<List<GunlukAntrenmanDetayi>> tarihAraligindakiAntrenmanlariGetir({
    required String baslangicTarihi,
    required String bitisTarihi,
  }) async {
    final antrenmanlar = await (select(antrenmanKayitlari)
          ..where(
            (t) =>
                t.tarih.isBiggerOrEqualValue(baslangicTarihi) &
                t.tarih.isSmallerOrEqualValue(bitisTarihi),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.tarih)]))
        .get();

    final sonuc = <GunlukAntrenmanDetayi>[];
    for (final ant in antrenmanlar) {
      final hareketler = await antrenmanEgzersizKayitlariniGetir(ant.id);
      sonuc.add(
        GunlukAntrenmanDetayi(
          antrenmanKaydi: ant,
          egzersizKayitlari: hareketler,
        ),
      );
    }
    return sonuc;
  }
}
