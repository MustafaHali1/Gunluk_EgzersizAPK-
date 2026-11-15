// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rutin_dao.dart';

// ignore_for_file: type=lint
mixin _$RutinDaoMixin on DatabaseAccessor<UygulamaVeritabani> {
  $RutinlerTable get rutinler => attachedDatabase.rutinler;
  $EgzersizlerTable get egzersizler => attachedDatabase.egzersizler;
  $RutinEgzersizleriTable get rutinEgzersizleri =>
      attachedDatabase.rutinEgzersizleri;
  RutinDaoManager get managers => RutinDaoManager(this);
}

class RutinDaoManager {
  final _$RutinDaoMixin _db;
  RutinDaoManager(this._db);
  $$RutinlerTableTableManager get rutinler =>
      $$RutinlerTableTableManager(_db.attachedDatabase, _db.rutinler);
  $$EgzersizlerTableTableManager get egzersizler =>
      $$EgzersizlerTableTableManager(_db.attachedDatabase, _db.egzersizler);
  $$RutinEgzersizleriTableTableManager get rutinEgzersizleri =>
      $$RutinEgzersizleriTableTableManager(
        _db.attachedDatabase,
        _db.rutinEgzersizleri,
      );
}
