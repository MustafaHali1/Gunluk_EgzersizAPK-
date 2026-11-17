// lib/cekirdek/veritabani/uygulama_veritabani.dart

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../ozellikler/ayarlar/veri/hatirlatici_dao.dart';
import '../../ozellikler/bugun/veri/antrenman_dao.dart';
import '../../ozellikler/egzersizler/veri/egzersiz_dao.dart';
import '../../ozellikler/rutinler/veri/rutin_dao.dart';
import 'tablolar.dart';

part 'uygulama_veritabani.g.dart';

// Uygulamanın yerel SQLite veritabanı sınıfı ve şema göç (migration) yöneticisi.
@DriftDatabase(
  tables: [
    Egzersizler,
    Rutinler,
    RutinEgzersizleri,
    AntrenmanKayitlari,
    EgzersizKayitlari,
    Hatirlaticilar,
  ],
  daos: [
    EgzersizDao,
    RutinDao,
    AntrenmanDao,
    HatirlaticiDao,
  ],
)
class UygulamaVeritabani extends _$UygulamaVeritabani {
  UygulamaVeritabani([QueryExecutor? yurutucu])
    : super(yurutucu ?? _baglantiAc());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await into(hatirlaticilar).insert(
        HatirlaticilarCompanion.insert(
          etiket: 'sabah',
          saat: 8,
          dakika: 30,
          haftaninGunleri: const Value('1,2,3,4,5,6,7'),
          etkinMi: const Value(false),
        ),
      );
      await into(hatirlaticilar).insert(
        HatirlaticilarCompanion.insert(
          etiket: 'aksam',
          saat: 20,
          dakika: 0,
          haftaninGunleri: const Value('1,2,3,4,5,6,7'),
          etkinMi: const Value(false),
        ),
      );
    },
    onUpgrade: (Migrator m, int eskiSurum, int yeniSurum) async {
      if (eskiSurum < 2) {
        await m.addColumn(rutinler, rutinler.sadeceTarih);
        await m.addColumn(rutinler, rutinler.alarmAcikMi);
        await m.addColumn(rutinler, rutinler.alarmSaati);
        await m.addColumn(rutinler, rutinler.alarmDakikasi);
        await m.addColumn(rutinler, rutinler.alarmMuzikYolu);
        await m.addColumn(rutinler, rutinler.alarmMuzikAdi);
        await m.addColumn(egzersizKayitlari, egzersizKayitlari.rutinId);
      }
      if (eskiSurum < 3) {
        await m.addColumn(rutinler, rutinler.alarmSaatleri);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

LazyDatabase _baglantiAc() {
  return LazyDatabase(() async {
    final klasor = await getApplicationDocumentsDirectory();
    final dosya = File('${klasor.path}/gunluk_egzersiz.sqlite');
    return NativeDatabase.createInBackground(dosya);
  });
}

// Veritabanı örneğini sağlayan Riverpod sağlayıcısı.
final veritabaniSaglayici = Provider<UygulamaVeritabani>((ref) {
  final veritabani = UygulamaVeritabani();
  ref.onDispose(veritabani.close);
  return veritabani;
});
