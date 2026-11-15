// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hatirlatici_dao.dart';

// ignore_for_file: type=lint
mixin _$HatirlaticiDaoMixin on DatabaseAccessor<UygulamaVeritabani> {
  $HatirlaticilarTable get hatirlaticilar => attachedDatabase.hatirlaticilar;
  HatirlaticiDaoManager get managers => HatirlaticiDaoManager(this);
}

class HatirlaticiDaoManager {
  final _$HatirlaticiDaoMixin _db;
  HatirlaticiDaoManager(this._db);
  $$HatirlaticilarTableTableManager get hatirlaticilar =>
      $$HatirlaticilarTableTableManager(
        _db.attachedDatabase,
        _db.hatirlaticilar,
      );
}
