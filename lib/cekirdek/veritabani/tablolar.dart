// lib/cekirdek/veritabani/tablolar.dart

import 'package:drift/drift.dart';

// Egzersiz tanımlarını tutan tablo (hard delete yapılmaz, arsivlendiMi kullanılır).
class Egzersizler extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get ad => text().withLength(min: 1, max: 120)();
  TextColumn get aciklama => text().withDefault(const Constant(''))();
  // 'sureli' (timed) veya 'tekrarli' (reps)
  TextColumn get tur => text().withLength(min: 1, max: 20)();
  IntColumn get sureSaniye => integer().nullable()();
  IntColumn get setSayisi => integer().nullable()();
  IntColumn get tekrarSayisi => integer().nullable()();
  TextColumn get kategori => text().withDefault(const Constant('Genel'))();
  BoolColumn get arsivlendiMi => boolean().withDefault(const Constant(false))();
}

// Kullanıcının oluşturduğu haftalık rutinleri tutan tablo.
class Rutinler extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get ad => text().withLength(min: 1, max: 120)();
  // Virgülle ayrılmış haftanın günleri (1=Pzt ... 7=Paz, örn: "1,2,3,4,5")
  TextColumn get haftaninGunleri => text().withDefault(const Constant('1,2,3,4,5,6,7'))();
  BoolColumn get aktifMi => boolean().withDefault(const Constant(false))();
}

// Bir rutinin içindeki egzersizleri ve sıralamasını tutan ara tablo.
class RutinEgzersizleri extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get rutinId =>
      integer().references(Rutinler, #id, onDelete: KeyAction.cascade)();
  IntColumn get egzersizId =>
      integer().references(Egzersizler, #id, onDelete: KeyAction.restrict)();
  IntColumn get siraIndeksi => integer()();
}

// Gün başına tek kayıt tutan günlük antrenman kaydı tablosu.
class AntrenmanKayitlari extends Table {
  IntColumn get id => integer().autoIncrement()();
  // YYYY-MM-DD formatında benzersiz gün bilgisi
  TextColumn get tarih => text().unique()();
  IntColumn get rutinId =>
      integer().nullable().references(Rutinler, #id, onDelete: KeyAction.setNull)();
}

// Günlük antrenman içindeki her bir hareketin durumunu ve ad kopyasını tutan tablo.
class EgzersizKayitlari extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get antrenmanKaydiId => integer().references(
    AntrenmanKayitlari,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get egzersizId =>
      integer().references(Egzersizler, #id, onDelete: KeyAction.restrict)();
  // Eski raporların bozulmaması için o anki egzersiz adı kopyası
  TextColumn get egzersizAdiKopyasi => text()();
  // 'yapildi' (done), 'atlandi' (skipped), 'bekliyor' (pending)
  TextColumn get durum => text().withDefault(const Constant('bekliyor'))();
  TextColumn get notMetni => text().nullable()();
}

// Sabah ve akşam bildirim hatırlatıcı ayarlarını tutan tablo.
class Hatirlaticilar extends Table {
  IntColumn get id => integer().autoIncrement()();
  // 'sabah' (morning) veya 'aksam' (evening)
  TextColumn get etiket => text().unique()();
  IntColumn get saat => integer()();
  IntColumn get dakika => integer()();
  // Virgülle ayrılmış haftanın günleri ("1,2,3,4,5,6,7")
  TextColumn get haftaninGunleri => text().withDefault(const Constant('1,2,3,4,5,6,7'))();
  BoolColumn get etkinMi => boolean().withDefault(const Constant(true))();
}
