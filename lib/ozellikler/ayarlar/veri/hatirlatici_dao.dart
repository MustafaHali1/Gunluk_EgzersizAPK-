// lib/ozellikler/ayarlar/veri/hatirlatici_dao.dart

import 'package:drift/drift.dart';
import '../../../cekirdek/veritabani/tablolar.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';

part 'hatirlatici_dao.g.dart';

// Hatirlaticilar tablosu için veritabanı erişim nesnesi (DAO).
@DriftAccessor(tables: [Hatirlaticilar])
class HatirlaticiDao extends DatabaseAccessor<UygulamaVeritabani>
    with _$HatirlaticiDaoMixin {
  HatirlaticiDao(super.attachedDatabase);

  // Tüm hatırlatıcıları akış (Stream) olarak izler.
  Stream<List<HatirlaticilarData>> hatirlaticilariIzle() {
    return (select(hatirlaticilar)..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .watch();
  }

  // Tüm hatırlatıcıları liste olarak getirir.
  Future<List<HatirlaticilarData>> hatirlaticilariGetir() {
    return (select(hatirlaticilar)..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  // Etikete ('sabah' / 'aksam') göre hatırlatıcı getirir.
  Future<HatirlaticilarData?> etiketeGoreGetir(String etiket) {
    return (select(hatirlaticilar)..where((t) => t.etiket.equals(etiket)))
        .getSingleOrNull();
  }

  // Hatırlatıcı saat, dakika, günler ve etkinlik durumunu günceller.
  Future<int> hatirlaticiGuncelle({
    required String etiket,
    required int saat,
    required int dakika,
    required String haftaninGunleri,
    required bool etkinMi,
  }) {
    return (update(hatirlaticilar)..where((t) => t.etiket.equals(etiket)))
        .write(
          HatirlaticilarCompanion(
            saat: Value(saat),
            dakika: Value(dakika),
            haftaninGunleri: Value(haftaninGunleri),
            etkinMi: Value(etkinMi),
          ),
        );
  }
}
