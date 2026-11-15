// lib/ozellikler/bugun/veri/antrenman_dao.dart

import 'package:drift/drift.dart';
import '../../../cekirdek/veritabani/tablolar.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';

part 'antrenman_dao.g.dart';

// Günlük takip ve içindeki görev kayıtlarını bir arada tutan veri sınıfı.
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

  // Belirli bir antrenman kaydına ait tüm görev kayıtlarını getirir.
  Future<List<EgzersizKayitlariData>> antrenmanEgzersizKayitlariniGetir(
    int antrenmanKaydiId,
  ) {
    return (select(egzersizKayitlari)
          ..where((t) => t.antrenmanKaydiId.equals(antrenmanKaydiId))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  // Belirli bir tarihin antrenman ve görev kayıtlarını bir arada getirir.
  Future<GunlukAntrenmanDetayi?> gunlukAntrenmanDetayiGetir(
    String tarih,
  ) async {
    final antrenman = await tariheGoreAntrenmanGetir(tarih);
    if (antrenman == null) return null;
    final gorevler = await antrenmanEgzersizKayitlariniGetir(antrenman.id);
    return GunlukAntrenmanDetayi(
      antrenmanKaydi: antrenman,
      egzersizKayitlari: gorevler,
    );
  }

  // Belirli bir rutin ve tarih için günlük görev kayıtlarını oluşturur veya eşitler.
  Future<List<EgzersizKayitlariData>> rutinIcinGunlukKayitlariGetirVeyaOlustur({
    required int rutinId,
    required String tarih,
  }) async {
    return transaction(() async {
      var antrenman = await tariheGoreAntrenmanGetir(tarih);
      antrenman ??= await into(antrenmanKayitlari).insertReturning(
        AntrenmanKayitlariCompanion.insert(
          tarih: tarih,
          rutinId: Value(rutinId),
        ),
      );

      final birlesikSorgu = select(rutinEgzersizleri).join([
        innerJoin(
          egzersizler,
          egzersizler.id.equalsExp(rutinEgzersizleri.egzersizId),
        ),
      ])
        ..where(rutinEgzersizleri.rutinId.equals(rutinId))
        ..where(egzersizler.arsivlendiMi.equals(false))
        ..orderBy([OrderingTerm.asc(rutinEgzersizleri.siraIndeksi)]);

      final rutinGorevSatirlari = await birlesikSorgu.get();
      final rutinGorevleri =
          rutinGorevSatirlari.map((s) => s.readTable(egzersizler)).toList();
      final aktifGorevIdleri = rutinGorevleri.map((g) => g.id).toSet();

      final mevcutKayitlar = await (select(egzersizKayitlari)
            ..where(
              (t) =>
                  t.antrenmanKaydiId.equals(antrenman!.id) &
                  t.rutinId.equals(rutinId),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .get();

      // Rutinden çıkarılmış ve hâlâ 'bekliyor' durumunda olan görevleri temizle
      for (final kayit in mevcutKayitlar) {
        if (kayit.durum == 'bekliyor' &&
            !aktifGorevIdleri.contains(kayit.egzersizId)) {
          await (delete(egzersizKayitlari)
                ..where((t) => t.id.equals(kayit.id)))
              .go();
        }
      }

      final kalanKayitlar = await (select(egzersizKayitlari)
            ..where(
              (t) =>
                  t.antrenmanKaydiId.equals(antrenman!.id) &
                  t.rutinId.equals(rutinId),
            ))
          .get();
      final mevcutGorevIdleri = kalanKayitlar.map((k) => k.egzersizId).toSet();

      for (final gorev in rutinGorevleri) {
        if (!mevcutGorevIdleri.contains(gorev.id)) {
          await into(egzersizKayitlari).insert(
            EgzersizKayitlariCompanion.insert(
              antrenmanKaydiId: antrenman.id,
              egzersizId: gorev.id,
              rutinId: Value(rutinId),
              egzersizAdiKopyasi: gorev.ad,
              durum: const Value('bekliyor'),
            ),
          );
        }
      }

      final guncelKayitlar = await (select(egzersizKayitlari)
            ..where(
              (t) =>
                  t.antrenmanKaydiId.equals(antrenman!.id) &
                  t.rutinId.equals(rutinId),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .get();
      return guncelKayitlar;
    });
  }

  // Belirli bir tarih için bugüne ait tüm planlı rutinlerin görev kayıtlarını hazırlar.
  Future<GunlukAntrenmanDetayi> gunlukAntrenmanOlusturVeyaGetir({
    required String tarih,
    required int haftaninGunu,
  }) async {
    return transaction(() async {
      var antrenman = await tariheGoreAntrenmanGetir(tarih);
      final tumRutinler = await select(rutinler).get();

      final bugununRutinleri = tumRutinler.where((r) {
        if (r.sadeceTarih != null) {
          return r.sadeceTarih == tarih;
        }
        final gunler = r.haftaninGunleri
            .split(',')
            .map((e) => int.tryParse(e.trim()))
            .whereType<int>()
            .toSet();
        return gunler.contains(haftaninGunu);
      }).toList();

      antrenman ??= await into(antrenmanKayitlari).insertReturning(
        AntrenmanKayitlariCompanion.insert(
          tarih: tarih,
          rutinId: Value(
            bugununRutinleri.isNotEmpty ? bugununRutinleri.first.id : null,
          ),
        ),
      );

      for (final rutin in bugununRutinleri) {
        await rutinIcinGunlukKayitlariGetirVeyaOlustur(
          rutinId: rutin.id,
          tarih: tarih,
        );
      }

      final olusanDetay = await gunlukAntrenmanDetayiGetir(tarih);
      return olusanDetay!;
    });
  }

  // Tek bir görev kaydının durumunu ('yapildi', 'atlandi', 'bekliyor') ve notunu günceller.
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

  // O güne tek seferlik hızlı görev kaydı ekler.
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

  // Belirli bir günün (veya belirli bir rutinin) tüm görevlerini 'yapildi' olarak işaretler.
  Future<void> gununTumHareketleriniYapildiIsaretle({
    required String tarih,
    required int haftaninGunu,
    int? rutinId,
  }) async {
    final detay = await gunlukAntrenmanOlusturVeyaGetir(
      tarih: tarih,
      haftaninGunu: haftaninGunu,
    );
    final sorgu = update(egzersizKayitlari)
      ..where((t) => t.antrenmanKaydiId.equals(detay.antrenmanKaydi.id));
    if (rutinId != null) {
      sorgu.where((t) => t.rutinId.equals(rutinId));
    }
    await sorgu.write(const EgzersizKayitlariCompanion(durum: Value('yapildi')));
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
