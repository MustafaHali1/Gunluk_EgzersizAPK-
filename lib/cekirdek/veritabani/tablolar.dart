// lib/cekirdek/veritabani/tablolar.dart

import 'package:drift/drift.dart';

// Görev / egzersiz tanımlarını tutan tablo (hard delete yapılmaz, arsivlendiMi kullanılır).
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

// Kullanıcının oluşturduğu günlük veya haftalık rutinleri ve rutine özel alarm ayarlarını tutan tablo.
class Rutinler extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get ad => text().withLength(min: 1, max: 120)();
  // Virgülle ayrılmış haftanın günleri (1=Pzt ... 7=Paz, örn: "1,2,3,4,5")
  TextColumn get haftaninGunleri =>
      text().withDefault(const Constant('1,2,3,4,5,6,7'))();
  BoolColumn get aktifMi => boolean().withDefault(const Constant(false))();
  // Doluysa (YYYY-MM-DD) sadece o gün için geçerli tek seferlik rutindir.
  TextColumn get sadeceTarih => text().nullable()();
  // Rutine bağlı müzikli alarm ayarları
  BoolColumn get alarmAcikMi => boolean().withDefault(const Constant(false))();
  IntColumn get alarmSaati => integer().withDefault(const Constant(9))();
  IntColumn get alarmDakikasi => integer().withDefault(const Constant(0))();
  // Günde birden çok alarm için "09:00,14:30,21:00" formatında saat listesi
  TextColumn get alarmSaatleri => text().withDefault(const Constant(''))();
  TextColumn get alarmMuzikYolu => text().nullable()();
  TextColumn get alarmMuzikAdi => text().nullable()();
}

// Bir rutinin içindeki görevleri ve sıralamasını tutan ara tablo.
class RutinEgzersizleri extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get rutinId =>
      integer().references(Rutinler, #id, onDelete: KeyAction.cascade)();
  IntColumn get egzersizId =>
      integer().references(Egzersizler, #id, onDelete: KeyAction.restrict)();
  IntColumn get siraIndeksi => integer()();
}

// Gün başına tek kayıt tutan günlük takip kaydı tablosu.
class AntrenmanKayitlari extends Table {
  IntColumn get id => integer().autoIncrement()();
  // YYYY-MM-DD formatında benzersiz gün bilgisi
  TextColumn get tarih => text().unique()();
  IntColumn get rutinId => integer().nullable().references(
    Rutinler,
    #id,
    onDelete: KeyAction.setNull,
  )();
}

// Günlük takip içindeki her bir görevin durumunu, bağlı rutini ve ad kopyasını tutan tablo.
class EgzersizKayitlari extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get antrenmanKaydiId => integer().references(
    AntrenmanKayitlari,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get egzersizId =>
      integer().references(Egzersizler, #id, onDelete: KeyAction.restrict)();
  IntColumn get rutinId => integer().nullable().references(
    Rutinler,
    #id,
    onDelete: KeyAction.setNull,
  )();
  // Eski raporların bozulmaması için o anki görev adı kopyası
  TextColumn get egzersizAdiKopyasi => text()();
  // 'yapildi', 'atlandi' (yapılmadı), 'bekliyor'
  TextColumn get durum => text().withDefault(const Constant('bekliyor'))();
  TextColumn get notMetni => text().nullable()();
}

// Sabah ve akşam bildirim hatırlatıcı ayarlarını tutan tablo.
class Hatirlaticilar extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get etiket => text().unique()();
  IntColumn get saat => integer()();
  IntColumn get dakika => integer()();
  TextColumn get haftaninGunleri =>
      text().withDefault(const Constant('1,2,3,4,5,6,7'))();
  BoolColumn get etkinMi => boolean().withDefault(const Constant(true))();
}
