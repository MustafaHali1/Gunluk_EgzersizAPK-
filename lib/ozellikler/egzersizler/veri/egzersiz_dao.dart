// lib/ozellikler/egzersizler/veri/egzersiz_dao.dart

import 'package:drift/drift.dart';
import '../../../cekirdek/veritabani/tablolar.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';

part 'egzersiz_dao.g.dart';

// Egzersizler tablosu için veritabanı erişim nesnesi (DAO).
@DriftAccessor(tables: [Egzersizler])
class EgzersizDao extends DatabaseAccessor<UygulamaVeritabani>
    with _$EgzersizDaoMixin {
  EgzersizDao(super.attachedDatabase);

  // Arşivlenmemiş aktif egzersizleri akış (Stream) olarak izler.
  Stream<List<EgzersizlerData>> aktifEgzersizleriIzle() {
    return (select(egzersizler)
          ..where((t) => t.arsivlendiMi.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.ad)]))
        .watch();
  }

  // Arşivlenmemiş aktif egzersizleri liste olarak getirir.
  Future<List<EgzersizlerData>> aktifEgzersizleriGetir() {
    return (select(egzersizler)
          ..where((t) => t.arsivlendiMi.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.ad)]))
        .get();
  }

  // Tüm egzersizleri (arşivlenenler dahil) getirir.
  Future<List<EgzersizlerData>> tumEgzersizleriGetir() {
    return select(egzersizler).get();
  }

  // ID'ye göre tek bir egzersiz getirir.
  Future<EgzersizlerData?> idIleEgzersizGetir(int id) {
    return (select(egzersizler)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  // Yeni egzersiz ekler ve eklenen kaydın ID'sini döndürür.
  Future<int> egzersizEkle(EgzersizlerCompanion yeniEgzersiz) {
    return into(egzersizler).insert(yeniEgzersiz);
  }

  // Mevcut egzersizi günceller.
  Future<bool> egzersizGuncelle(EgzersizlerCompanion guncelEgzersiz) {
    return update(egzersizler).replace(guncelEgzersiz);
  }

  // Egzersizi kalıcı silmek yerine arşivler (soft delete).
  Future<int> egzersizArsivle(int id, {bool arsivlendiMi = true}) {
    return (update(egzersizler)..where((t) => t.id.equals(id))).write(
      EgzersizlerCompanion(arsivlendiMi: Value(arsivlendiMi)),
    );
  }
}
