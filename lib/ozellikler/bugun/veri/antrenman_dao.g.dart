// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'antrenman_dao.dart';

// ignore_for_file: type=lint
mixin _$AntrenmanDaoMixin on DatabaseAccessor<UygulamaVeritabani> {
  $RutinlerTable get rutinler => attachedDatabase.rutinler;
  $AntrenmanKayitlariTable get antrenmanKayitlari =>
      attachedDatabase.antrenmanKayitlari;
  $EgzersizlerTable get egzersizler => attachedDatabase.egzersizler;
  $EgzersizKayitlariTable get egzersizKayitlari =>
      attachedDatabase.egzersizKayitlari;
  $RutinEgzersizleriTable get rutinEgzersizleri =>
      attachedDatabase.rutinEgzersizleri;
  AntrenmanDaoManager get managers => AntrenmanDaoManager(this);
}

class AntrenmanDaoManager {
  final _$AntrenmanDaoMixin _db;
  AntrenmanDaoManager(this._db);
  $$RutinlerTableTableManager get rutinler =>
      $$RutinlerTableTableManager(_db.attachedDatabase, _db.rutinler);
  $$AntrenmanKayitlariTableTableManager get antrenmanKayitlari =>
      $$AntrenmanKayitlariTableTableManager(
        _db.attachedDatabase,
        _db.antrenmanKayitlari,
      );
  $$EgzersizlerTableTableManager get egzersizler =>
      $$EgzersizlerTableTableManager(_db.attachedDatabase, _db.egzersizler);
  $$EgzersizKayitlariTableTableManager get egzersizKayitlari =>
      $$EgzersizKayitlariTableTableManager(
        _db.attachedDatabase,
        _db.egzersizKayitlari,
      );
  $$RutinEgzersizleriTableTableManager get rutinEgzersizleri =>
      $$RutinEgzersizleriTableTableManager(
        _db.attachedDatabase,
        _db.rutinEgzersizleri,
      );
}
