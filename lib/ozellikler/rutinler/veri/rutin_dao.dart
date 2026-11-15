// lib/ozellikler/rutinler/veri/rutin_dao.dart

import 'package:drift/drift.dart';
import '../../../cekirdek/veritabani/tablolar.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';

part 'rutin_dao.g.dart';

// Bir rutinin içindeki görev ve sıra bilgisini birleştiren yardımcı veri sınıfı.
class RutinEgzersizDetayi {
  final RutinEgzersizleriData rutinBaglantisi;
  final EgzersizlerData egzersiz;

  const RutinEgzersizDetayi({
    required this.rutinBaglantisi,
    required this.egzersiz,
  });
}

// Rutinler ve RutinEgzersizleri tabloları için veritabanı erişim nesnesi (DAO).
@DriftAccessor(tables: [Rutinler, RutinEgzersizleri, Egzersizler])
class RutinDao extends DatabaseAccessor<UygulamaVeritabani>
    with _$RutinDaoMixin {
  RutinDao(super.attachedDatabase);

  // Tüm rutinleri izler.
  Stream<List<RutinlerData>> tumRutinleriIzle() {
    return (select(rutinler)..orderBy([
          (t) => OrderingTerm.desc(t.alarmAcikMi),
          (t) => OrderingTerm.asc(t.alarmSaati),
          (t) => OrderingTerm.asc(t.alarmDakikasi),
          (t) => OrderingTerm.asc(t.id),
        ]))
        .watch();
  }

  // Tüm rutinleri getirir.
  Future<List<RutinlerData>> tumRutinleriGetir() {
    return (select(rutinler)..orderBy([
          (t) => OrderingTerm.desc(t.alarmAcikMi),
          (t) => OrderingTerm.asc(t.alarmSaati),
          (t) => OrderingTerm.asc(t.alarmDakikasi),
          (t) => OrderingTerm.asc(t.id),
        ]))
        .get();
  }

  // Kimliğine göre tek bir rutini getirir.
  Future<RutinlerData?> idIleRutinGetir(int id) {
    return (select(rutinler)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  // Aktif olan rutini getirir.
  Future<RutinlerData?> aktifRutiniGetir() {
    return (select(rutinler)
          ..where((t) => t.aktifMi.equals(true))
          ..limit(1))
        .getSingleOrNull();
  }

  // Aktif olan rutini akış (Stream) olarak izler.
  Stream<RutinlerData?> aktifRutiniIzle() {
    return (select(rutinler)
          ..where((t) => t.aktifMi.equals(true))
          ..limit(1))
        .watchSingleOrNull();
  }

  // Yeni rutin oluşturur ve seçili görevlerini sırasıyla kaydeder.
  Future<int> rutinOlusturVeEgzersizleriKaydet({
    required String ad,
    required String haftaninGunleri,
    required bool aktifMi,
    required List<int> egzersizIdListesi,
    String? sadeceTarih,
    bool alarmAcikMi = false,
    int alarmSaati = 9,
    int alarmDakikasi = 0,
    String? alarmMuzikYolu,
    String? alarmMuzikAdi,
  }) async {
    return transaction(() async {
      if (aktifMi) {
        await update(rutinler).write(
          const RutinlerCompanion(aktifMi: Value(false)),
        );
      }

      final rutinId = await into(rutinler).insert(
        RutinlerCompanion.insert(
          ad: ad,
          haftaninGunleri: Value(haftaninGunleri),
          aktifMi: Value(aktifMi),
          sadeceTarih: Value(sadeceTarih),
          alarmAcikMi: Value(alarmAcikMi),
          alarmSaati: Value(alarmSaati),
          alarmDakikasi: Value(alarmDakikasi),
          alarmMuzikYolu: Value(alarmMuzikYolu),
          alarmMuzikAdi: Value(alarmMuzikAdi),
        ),
      );

      for (var i = 0; i < egzersizIdListesi.length; i++) {
        await into(rutinEgzersizleri).insert(
          RutinEgzersizleriCompanion.insert(
            rutinId: rutinId,
            egzersizId: egzersizIdListesi[i],
            siraIndeksi: i,
          ),
        );
      }
      return rutinId;
    });
  }

  // Mevcut rutini ve görev sıralamasını günceller.
  Future<void> rutinVeEgzersizleriGuncelle({
    required int rutinId,
    required String ad,
    required String haftaninGunleri,
    required bool aktifMi,
    required List<int> egzersizIdListesi,
    String? sadeceTarih,
    bool alarmAcikMi = false,
    int alarmSaati = 9,
    int alarmDakikasi = 0,
    String? alarmMuzikYolu,
    String? alarmMuzikAdi,
  }) async {
    await transaction(() async {
      if (aktifMi) {
        await update(rutinler).write(
          const RutinlerCompanion(aktifMi: Value(false)),
        );
      }

      await (update(rutinler)..where((t) => t.id.equals(rutinId))).write(
        RutinlerCompanion(
          ad: Value(ad),
          haftaninGunleri: Value(haftaninGunleri),
          aktifMi: Value(aktifMi),
          sadeceTarih: Value(sadeceTarih),
          alarmAcikMi: Value(alarmAcikMi),
          alarmSaati: Value(alarmSaati),
          alarmDakikasi: Value(alarmDakikasi),
          alarmMuzikYolu: Value(alarmMuzikYolu),
          alarmMuzikAdi: Value(alarmMuzikAdi),
        ),
      );

      await (delete(rutinEgzersizleri)
            ..where((t) => t.rutinId.equals(rutinId)))
          .go();

      for (var i = 0; i < egzersizIdListesi.length; i++) {
        await into(rutinEgzersizleri).insert(
          RutinEgzersizleriCompanion.insert(
            rutinId: rutinId,
            egzersizId: egzersizIdListesi[i],
            siraIndeksi: i,
          ),
        );
      }
    });
  }

  // Belirtilen rutini aktif rutin olarak ayarlar (diğerlerini pasif yapar).
  Future<void> aktifRutiniBelirle(int rutinId) async {
    await transaction(() async {
      await update(rutinler).write(
        const RutinlerCompanion(aktifMi: Value(false)),
      );
      await (update(rutinler)..where((t) => t.id.equals(rutinId))).write(
        const RutinlerCompanion(aktifMi: Value(true)),
      );
    });
  }

  // Rutini siler.
  Future<int> rutinSil(int rutinId) {
    return (delete(rutinler)..where((t) => t.id.equals(rutinId))).go();
  }

  // Bir rutine ait görevleri sıralı olarak (arşivlenmemiş olanları) getirir.
  Future<List<RutinEgzersizDetayi>> rutinEgzersizleriniGetir(
    int rutinId, {
    bool arsivlenmisleriDahilEt = false,
  }) async {
    final sorgu = select(rutinEgzersizleri).join([
      innerJoin(
        egzersizler,
        egzersizler.id.equalsExp(rutinEgzersizleri.egzersizId),
      ),
    ])..where(rutinEgzersizleri.rutinId.equals(rutinId));

    if (!arsivlenmisleriDahilEt) {
      sorgu.where(egzersizler.arsivlendiMi.equals(false));
    }

    sorgu.orderBy([OrderingTerm.asc(rutinEgzersizleri.siraIndeksi)]);

    final satirlar = await sorgu.get();
    return satirlar
        .map(
          (satir) => RutinEgzersizDetayi(
            rutinBaglantisi: satir.readTable(rutinEgzersizleri),
            egzersiz: satir.readTable(egzersizler),
          ),
        )
        .toList();
  }
}
