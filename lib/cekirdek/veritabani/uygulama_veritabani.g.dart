// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'uygulama_veritabani.dart';

// ignore_for_file: type=lint
class $EgzersizlerTable extends Egzersizler
    with TableInfo<$EgzersizlerTable, EgzersizlerData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EgzersizlerTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _adMeta = const VerificationMeta('ad');
  @override
  late final GeneratedColumn<String> ad = GeneratedColumn<String>(
    'ad',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aciklamaMeta = const VerificationMeta(
    'aciklama',
  );
  @override
  late final GeneratedColumn<String> aciklama = GeneratedColumn<String>(
    'aciklama',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _turMeta = const VerificationMeta('tur');
  @override
  late final GeneratedColumn<String> tur = GeneratedColumn<String>(
    'tur',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sureSaniyeMeta = const VerificationMeta(
    'sureSaniye',
  );
  @override
  late final GeneratedColumn<int> sureSaniye = GeneratedColumn<int>(
    'sure_saniye',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _setSayisiMeta = const VerificationMeta(
    'setSayisi',
  );
  @override
  late final GeneratedColumn<int> setSayisi = GeneratedColumn<int>(
    'set_sayisi',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tekrarSayisiMeta = const VerificationMeta(
    'tekrarSayisi',
  );
  @override
  late final GeneratedColumn<int> tekrarSayisi = GeneratedColumn<int>(
    'tekrar_sayisi',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kategoriMeta = const VerificationMeta(
    'kategori',
  );
  @override
  late final GeneratedColumn<String> kategori = GeneratedColumn<String>(
    'kategori',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Genel'),
  );
  static const VerificationMeta _arsivlendiMiMeta = const VerificationMeta(
    'arsivlendiMi',
  );
  @override
  late final GeneratedColumn<bool> arsivlendiMi = GeneratedColumn<bool>(
    'arsivlendi_mi',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("arsivlendi_mi" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ad,
    aciklama,
    tur,
    sureSaniye,
    setSayisi,
    tekrarSayisi,
    kategori,
    arsivlendiMi,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'egzersizler';
  @override
  VerificationContext validateIntegrity(
    Insertable<EgzersizlerData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ad')) {
      context.handle(_adMeta, ad.isAcceptableOrUnknown(data['ad']!, _adMeta));
    } else if (isInserting) {
      context.missing(_adMeta);
    }
    if (data.containsKey('aciklama')) {
      context.handle(
        _aciklamaMeta,
        aciklama.isAcceptableOrUnknown(data['aciklama']!, _aciklamaMeta),
      );
    }
    if (data.containsKey('tur')) {
      context.handle(
        _turMeta,
        tur.isAcceptableOrUnknown(data['tur']!, _turMeta),
      );
    } else if (isInserting) {
      context.missing(_turMeta);
    }
    if (data.containsKey('sure_saniye')) {
      context.handle(
        _sureSaniyeMeta,
        sureSaniye.isAcceptableOrUnknown(data['sure_saniye']!, _sureSaniyeMeta),
      );
    }
    if (data.containsKey('set_sayisi')) {
      context.handle(
        _setSayisiMeta,
        setSayisi.isAcceptableOrUnknown(data['set_sayisi']!, _setSayisiMeta),
      );
    }
    if (data.containsKey('tekrar_sayisi')) {
      context.handle(
        _tekrarSayisiMeta,
        tekrarSayisi.isAcceptableOrUnknown(
          data['tekrar_sayisi']!,
          _tekrarSayisiMeta,
        ),
      );
    }
    if (data.containsKey('kategori')) {
      context.handle(
        _kategoriMeta,
        kategori.isAcceptableOrUnknown(data['kategori']!, _kategoriMeta),
      );
    }
    if (data.containsKey('arsivlendi_mi')) {
      context.handle(
        _arsivlendiMiMeta,
        arsivlendiMi.isAcceptableOrUnknown(
          data['arsivlendi_mi']!,
          _arsivlendiMiMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EgzersizlerData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EgzersizlerData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ad: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ad'],
      )!,
      aciklama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aciklama'],
      )!,
      tur: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tur'],
      )!,
      sureSaniye: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sure_saniye'],
      ),
      setSayisi: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_sayisi'],
      ),
      tekrarSayisi: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tekrar_sayisi'],
      ),
      kategori: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kategori'],
      )!,
      arsivlendiMi: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}arsivlendi_mi'],
      )!,
    );
  }

  @override
  $EgzersizlerTable createAlias(String alias) {
    return $EgzersizlerTable(attachedDatabase, alias);
  }
}

class EgzersizlerData extends DataClass implements Insertable<EgzersizlerData> {
  final int id;
  final String ad;
  final String aciklama;
  final String tur;
  final int? sureSaniye;
  final int? setSayisi;
  final int? tekrarSayisi;
  final String kategori;
  final bool arsivlendiMi;
  const EgzersizlerData({
    required this.id,
    required this.ad,
    required this.aciklama,
    required this.tur,
    this.sureSaniye,
    this.setSayisi,
    this.tekrarSayisi,
    required this.kategori,
    required this.arsivlendiMi,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ad'] = Variable<String>(ad);
    map['aciklama'] = Variable<String>(aciklama);
    map['tur'] = Variable<String>(tur);
    if (!nullToAbsent || sureSaniye != null) {
      map['sure_saniye'] = Variable<int>(sureSaniye);
    }
    if (!nullToAbsent || setSayisi != null) {
      map['set_sayisi'] = Variable<int>(setSayisi);
    }
    if (!nullToAbsent || tekrarSayisi != null) {
      map['tekrar_sayisi'] = Variable<int>(tekrarSayisi);
    }
    map['kategori'] = Variable<String>(kategori);
    map['arsivlendi_mi'] = Variable<bool>(arsivlendiMi);
    return map;
  }

  EgzersizlerCompanion toCompanion(bool nullToAbsent) {
    return EgzersizlerCompanion(
      id: Value(id),
      ad: Value(ad),
      aciklama: Value(aciklama),
      tur: Value(tur),
      sureSaniye: sureSaniye == null && nullToAbsent
          ? const Value.absent()
          : Value(sureSaniye),
      setSayisi: setSayisi == null && nullToAbsent
          ? const Value.absent()
          : Value(setSayisi),
      tekrarSayisi: tekrarSayisi == null && nullToAbsent
          ? const Value.absent()
          : Value(tekrarSayisi),
      kategori: Value(kategori),
      arsivlendiMi: Value(arsivlendiMi),
    );
  }

  factory EgzersizlerData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EgzersizlerData(
      id: serializer.fromJson<int>(json['id']),
      ad: serializer.fromJson<String>(json['ad']),
      aciklama: serializer.fromJson<String>(json['aciklama']),
      tur: serializer.fromJson<String>(json['tur']),
      sureSaniye: serializer.fromJson<int?>(json['sureSaniye']),
      setSayisi: serializer.fromJson<int?>(json['setSayisi']),
      tekrarSayisi: serializer.fromJson<int?>(json['tekrarSayisi']),
      kategori: serializer.fromJson<String>(json['kategori']),
      arsivlendiMi: serializer.fromJson<bool>(json['arsivlendiMi']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ad': serializer.toJson<String>(ad),
      'aciklama': serializer.toJson<String>(aciklama),
      'tur': serializer.toJson<String>(tur),
      'sureSaniye': serializer.toJson<int?>(sureSaniye),
      'setSayisi': serializer.toJson<int?>(setSayisi),
      'tekrarSayisi': serializer.toJson<int?>(tekrarSayisi),
      'kategori': serializer.toJson<String>(kategori),
      'arsivlendiMi': serializer.toJson<bool>(arsivlendiMi),
    };
  }

  EgzersizlerData copyWith({
    int? id,
    String? ad,
    String? aciklama,
    String? tur,
    Value<int?> sureSaniye = const Value.absent(),
    Value<int?> setSayisi = const Value.absent(),
    Value<int?> tekrarSayisi = const Value.absent(),
    String? kategori,
    bool? arsivlendiMi,
  }) => EgzersizlerData(
    id: id ?? this.id,
    ad: ad ?? this.ad,
    aciklama: aciklama ?? this.aciklama,
    tur: tur ?? this.tur,
    sureSaniye: sureSaniye.present ? sureSaniye.value : this.sureSaniye,
    setSayisi: setSayisi.present ? setSayisi.value : this.setSayisi,
    tekrarSayisi: tekrarSayisi.present ? tekrarSayisi.value : this.tekrarSayisi,
    kategori: kategori ?? this.kategori,
    arsivlendiMi: arsivlendiMi ?? this.arsivlendiMi,
  );
  EgzersizlerData copyWithCompanion(EgzersizlerCompanion data) {
    return EgzersizlerData(
      id: data.id.present ? data.id.value : this.id,
      ad: data.ad.present ? data.ad.value : this.ad,
      aciklama: data.aciklama.present ? data.aciklama.value : this.aciklama,
      tur: data.tur.present ? data.tur.value : this.tur,
      sureSaniye: data.sureSaniye.present
          ? data.sureSaniye.value
          : this.sureSaniye,
      setSayisi: data.setSayisi.present ? data.setSayisi.value : this.setSayisi,
      tekrarSayisi: data.tekrarSayisi.present
          ? data.tekrarSayisi.value
          : this.tekrarSayisi,
      kategori: data.kategori.present ? data.kategori.value : this.kategori,
      arsivlendiMi: data.arsivlendiMi.present
          ? data.arsivlendiMi.value
          : this.arsivlendiMi,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EgzersizlerData(')
          ..write('id: $id, ')
          ..write('ad: $ad, ')
          ..write('aciklama: $aciklama, ')
          ..write('tur: $tur, ')
          ..write('sureSaniye: $sureSaniye, ')
          ..write('setSayisi: $setSayisi, ')
          ..write('tekrarSayisi: $tekrarSayisi, ')
          ..write('kategori: $kategori, ')
          ..write('arsivlendiMi: $arsivlendiMi')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ad,
    aciklama,
    tur,
    sureSaniye,
    setSayisi,
    tekrarSayisi,
    kategori,
    arsivlendiMi,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EgzersizlerData &&
          other.id == this.id &&
          other.ad == this.ad &&
          other.aciklama == this.aciklama &&
          other.tur == this.tur &&
          other.sureSaniye == this.sureSaniye &&
          other.setSayisi == this.setSayisi &&
          other.tekrarSayisi == this.tekrarSayisi &&
          other.kategori == this.kategori &&
          other.arsivlendiMi == this.arsivlendiMi);
}

class EgzersizlerCompanion extends UpdateCompanion<EgzersizlerData> {
  final Value<int> id;
  final Value<String> ad;
  final Value<String> aciklama;
  final Value<String> tur;
  final Value<int?> sureSaniye;
  final Value<int?> setSayisi;
  final Value<int?> tekrarSayisi;
  final Value<String> kategori;
  final Value<bool> arsivlendiMi;
  const EgzersizlerCompanion({
    this.id = const Value.absent(),
    this.ad = const Value.absent(),
    this.aciklama = const Value.absent(),
    this.tur = const Value.absent(),
    this.sureSaniye = const Value.absent(),
    this.setSayisi = const Value.absent(),
    this.tekrarSayisi = const Value.absent(),
    this.kategori = const Value.absent(),
    this.arsivlendiMi = const Value.absent(),
  });
  EgzersizlerCompanion.insert({
    this.id = const Value.absent(),
    required String ad,
    this.aciklama = const Value.absent(),
    required String tur,
    this.sureSaniye = const Value.absent(),
    this.setSayisi = const Value.absent(),
    this.tekrarSayisi = const Value.absent(),
    this.kategori = const Value.absent(),
    this.arsivlendiMi = const Value.absent(),
  }) : ad = Value(ad),
       tur = Value(tur);
  static Insertable<EgzersizlerData> custom({
    Expression<int>? id,
    Expression<String>? ad,
    Expression<String>? aciklama,
    Expression<String>? tur,
    Expression<int>? sureSaniye,
    Expression<int>? setSayisi,
    Expression<int>? tekrarSayisi,
    Expression<String>? kategori,
    Expression<bool>? arsivlendiMi,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ad != null) 'ad': ad,
      if (aciklama != null) 'aciklama': aciklama,
      if (tur != null) 'tur': tur,
      if (sureSaniye != null) 'sure_saniye': sureSaniye,
      if (setSayisi != null) 'set_sayisi': setSayisi,
      if (tekrarSayisi != null) 'tekrar_sayisi': tekrarSayisi,
      if (kategori != null) 'kategori': kategori,
      if (arsivlendiMi != null) 'arsivlendi_mi': arsivlendiMi,
    });
  }

  EgzersizlerCompanion copyWith({
    Value<int>? id,
    Value<String>? ad,
    Value<String>? aciklama,
    Value<String>? tur,
    Value<int?>? sureSaniye,
    Value<int?>? setSayisi,
    Value<int?>? tekrarSayisi,
    Value<String>? kategori,
    Value<bool>? arsivlendiMi,
  }) {
    return EgzersizlerCompanion(
      id: id ?? this.id,
      ad: ad ?? this.ad,
      aciklama: aciklama ?? this.aciklama,
      tur: tur ?? this.tur,
      sureSaniye: sureSaniye ?? this.sureSaniye,
      setSayisi: setSayisi ?? this.setSayisi,
      tekrarSayisi: tekrarSayisi ?? this.tekrarSayisi,
      kategori: kategori ?? this.kategori,
      arsivlendiMi: arsivlendiMi ?? this.arsivlendiMi,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ad.present) {
      map['ad'] = Variable<String>(ad.value);
    }
    if (aciklama.present) {
      map['aciklama'] = Variable<String>(aciklama.value);
    }
    if (tur.present) {
      map['tur'] = Variable<String>(tur.value);
    }
    if (sureSaniye.present) {
      map['sure_saniye'] = Variable<int>(sureSaniye.value);
    }
    if (setSayisi.present) {
      map['set_sayisi'] = Variable<int>(setSayisi.value);
    }
    if (tekrarSayisi.present) {
      map['tekrar_sayisi'] = Variable<int>(tekrarSayisi.value);
    }
    if (kategori.present) {
      map['kategori'] = Variable<String>(kategori.value);
    }
    if (arsivlendiMi.present) {
      map['arsivlendi_mi'] = Variable<bool>(arsivlendiMi.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EgzersizlerCompanion(')
          ..write('id: $id, ')
          ..write('ad: $ad, ')
          ..write('aciklama: $aciklama, ')
          ..write('tur: $tur, ')
          ..write('sureSaniye: $sureSaniye, ')
          ..write('setSayisi: $setSayisi, ')
          ..write('tekrarSayisi: $tekrarSayisi, ')
          ..write('kategori: $kategori, ')
          ..write('arsivlendiMi: $arsivlendiMi')
          ..write(')'))
        .toString();
  }
}

class $RutinlerTable extends Rutinler
    with TableInfo<$RutinlerTable, RutinlerData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RutinlerTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _adMeta = const VerificationMeta('ad');
  @override
  late final GeneratedColumn<String> ad = GeneratedColumn<String>(
    'ad',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _haftaninGunleriMeta = const VerificationMeta(
    'haftaninGunleri',
  );
  @override
  late final GeneratedColumn<String> haftaninGunleri = GeneratedColumn<String>(
    'haftanin_gunleri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('1,2,3,4,5,6,7'),
  );
  static const VerificationMeta _aktifMiMeta = const VerificationMeta(
    'aktifMi',
  );
  @override
  late final GeneratedColumn<bool> aktifMi = GeneratedColumn<bool>(
    'aktif_mi',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("aktif_mi" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sadeceTarihMeta = const VerificationMeta(
    'sadeceTarih',
  );
  @override
  late final GeneratedColumn<String> sadeceTarih = GeneratedColumn<String>(
    'sadece_tarih',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alarmAcikMiMeta = const VerificationMeta(
    'alarmAcikMi',
  );
  @override
  late final GeneratedColumn<bool> alarmAcikMi = GeneratedColumn<bool>(
    'alarm_acik_mi',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("alarm_acik_mi" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _alarmSaatiMeta = const VerificationMeta(
    'alarmSaati',
  );
  @override
  late final GeneratedColumn<int> alarmSaati = GeneratedColumn<int>(
    'alarm_saati',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(9),
  );
  static const VerificationMeta _alarmDakikasiMeta = const VerificationMeta(
    'alarmDakikasi',
  );
  @override
  late final GeneratedColumn<int> alarmDakikasi = GeneratedColumn<int>(
    'alarm_dakikasi',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _alarmMuzikYoluMeta = const VerificationMeta(
    'alarmMuzikYolu',
  );
  @override
  late final GeneratedColumn<String> alarmMuzikYolu = GeneratedColumn<String>(
    'alarm_muzik_yolu',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alarmMuzikAdiMeta = const VerificationMeta(
    'alarmMuzikAdi',
  );
  @override
  late final GeneratedColumn<String> alarmMuzikAdi = GeneratedColumn<String>(
    'alarm_muzik_adi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ad,
    haftaninGunleri,
    aktifMi,
    sadeceTarih,
    alarmAcikMi,
    alarmSaati,
    alarmDakikasi,
    alarmMuzikYolu,
    alarmMuzikAdi,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rutinler';
  @override
  VerificationContext validateIntegrity(
    Insertable<RutinlerData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ad')) {
      context.handle(_adMeta, ad.isAcceptableOrUnknown(data['ad']!, _adMeta));
    } else if (isInserting) {
      context.missing(_adMeta);
    }
    if (data.containsKey('haftanin_gunleri')) {
      context.handle(
        _haftaninGunleriMeta,
        haftaninGunleri.isAcceptableOrUnknown(
          data['haftanin_gunleri']!,
          _haftaninGunleriMeta,
        ),
      );
    }
    if (data.containsKey('aktif_mi')) {
      context.handle(
        _aktifMiMeta,
        aktifMi.isAcceptableOrUnknown(data['aktif_mi']!, _aktifMiMeta),
      );
    }
    if (data.containsKey('sadece_tarih')) {
      context.handle(
        _sadeceTarihMeta,
        sadeceTarih.isAcceptableOrUnknown(
          data['sadece_tarih']!,
          _sadeceTarihMeta,
        ),
      );
    }
    if (data.containsKey('alarm_acik_mi')) {
      context.handle(
        _alarmAcikMiMeta,
        alarmAcikMi.isAcceptableOrUnknown(
          data['alarm_acik_mi']!,
          _alarmAcikMiMeta,
        ),
      );
    }
    if (data.containsKey('alarm_saati')) {
      context.handle(
        _alarmSaatiMeta,
        alarmSaati.isAcceptableOrUnknown(data['alarm_saati']!, _alarmSaatiMeta),
      );
    }
    if (data.containsKey('alarm_dakikasi')) {
      context.handle(
        _alarmDakikasiMeta,
        alarmDakikasi.isAcceptableOrUnknown(
          data['alarm_dakikasi']!,
          _alarmDakikasiMeta,
        ),
      );
    }
    if (data.containsKey('alarm_muzik_yolu')) {
      context.handle(
        _alarmMuzikYoluMeta,
        alarmMuzikYolu.isAcceptableOrUnknown(
          data['alarm_muzik_yolu']!,
          _alarmMuzikYoluMeta,
        ),
      );
    }
    if (data.containsKey('alarm_muzik_adi')) {
      context.handle(
        _alarmMuzikAdiMeta,
        alarmMuzikAdi.isAcceptableOrUnknown(
          data['alarm_muzik_adi']!,
          _alarmMuzikAdiMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RutinlerData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RutinlerData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ad: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ad'],
      )!,
      haftaninGunleri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}haftanin_gunleri'],
      )!,
      aktifMi: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}aktif_mi'],
      )!,
      sadeceTarih: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sadece_tarih'],
      ),
      alarmAcikMi: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}alarm_acik_mi'],
      )!,
      alarmSaati: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}alarm_saati'],
      )!,
      alarmDakikasi: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}alarm_dakikasi'],
      )!,
      alarmMuzikYolu: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alarm_muzik_yolu'],
      ),
      alarmMuzikAdi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alarm_muzik_adi'],
      ),
    );
  }

  @override
  $RutinlerTable createAlias(String alias) {
    return $RutinlerTable(attachedDatabase, alias);
  }
}

class RutinlerData extends DataClass implements Insertable<RutinlerData> {
  final int id;
  final String ad;
  final String haftaninGunleri;
  final bool aktifMi;
  final String? sadeceTarih;
  final bool alarmAcikMi;
  final int alarmSaati;
  final int alarmDakikasi;
  final String? alarmMuzikYolu;
  final String? alarmMuzikAdi;
  const RutinlerData({
    required this.id,
    required this.ad,
    required this.haftaninGunleri,
    required this.aktifMi,
    this.sadeceTarih,
    required this.alarmAcikMi,
    required this.alarmSaati,
    required this.alarmDakikasi,
    this.alarmMuzikYolu,
    this.alarmMuzikAdi,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ad'] = Variable<String>(ad);
    map['haftanin_gunleri'] = Variable<String>(haftaninGunleri);
    map['aktif_mi'] = Variable<bool>(aktifMi);
    if (!nullToAbsent || sadeceTarih != null) {
      map['sadece_tarih'] = Variable<String>(sadeceTarih);
    }
    map['alarm_acik_mi'] = Variable<bool>(alarmAcikMi);
    map['alarm_saati'] = Variable<int>(alarmSaati);
    map['alarm_dakikasi'] = Variable<int>(alarmDakikasi);
    if (!nullToAbsent || alarmMuzikYolu != null) {
      map['alarm_muzik_yolu'] = Variable<String>(alarmMuzikYolu);
    }
    if (!nullToAbsent || alarmMuzikAdi != null) {
      map['alarm_muzik_adi'] = Variable<String>(alarmMuzikAdi);
    }
    return map;
  }

  RutinlerCompanion toCompanion(bool nullToAbsent) {
    return RutinlerCompanion(
      id: Value(id),
      ad: Value(ad),
      haftaninGunleri: Value(haftaninGunleri),
      aktifMi: Value(aktifMi),
      sadeceTarih: sadeceTarih == null && nullToAbsent
          ? const Value.absent()
          : Value(sadeceTarih),
      alarmAcikMi: Value(alarmAcikMi),
      alarmSaati: Value(alarmSaati),
      alarmDakikasi: Value(alarmDakikasi),
      alarmMuzikYolu: alarmMuzikYolu == null && nullToAbsent
          ? const Value.absent()
          : Value(alarmMuzikYolu),
      alarmMuzikAdi: alarmMuzikAdi == null && nullToAbsent
          ? const Value.absent()
          : Value(alarmMuzikAdi),
    );
  }

  factory RutinlerData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RutinlerData(
      id: serializer.fromJson<int>(json['id']),
      ad: serializer.fromJson<String>(json['ad']),
      haftaninGunleri: serializer.fromJson<String>(json['haftaninGunleri']),
      aktifMi: serializer.fromJson<bool>(json['aktifMi']),
      sadeceTarih: serializer.fromJson<String?>(json['sadeceTarih']),
      alarmAcikMi: serializer.fromJson<bool>(json['alarmAcikMi']),
      alarmSaati: serializer.fromJson<int>(json['alarmSaati']),
      alarmDakikasi: serializer.fromJson<int>(json['alarmDakikasi']),
      alarmMuzikYolu: serializer.fromJson<String?>(json['alarmMuzikYolu']),
      alarmMuzikAdi: serializer.fromJson<String?>(json['alarmMuzikAdi']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ad': serializer.toJson<String>(ad),
      'haftaninGunleri': serializer.toJson<String>(haftaninGunleri),
      'aktifMi': serializer.toJson<bool>(aktifMi),
      'sadeceTarih': serializer.toJson<String?>(sadeceTarih),
      'alarmAcikMi': serializer.toJson<bool>(alarmAcikMi),
      'alarmSaati': serializer.toJson<int>(alarmSaati),
      'alarmDakikasi': serializer.toJson<int>(alarmDakikasi),
      'alarmMuzikYolu': serializer.toJson<String?>(alarmMuzikYolu),
      'alarmMuzikAdi': serializer.toJson<String?>(alarmMuzikAdi),
    };
  }

  RutinlerData copyWith({
    int? id,
    String? ad,
    String? haftaninGunleri,
    bool? aktifMi,
    Value<String?> sadeceTarih = const Value.absent(),
    bool? alarmAcikMi,
    int? alarmSaati,
    int? alarmDakikasi,
    Value<String?> alarmMuzikYolu = const Value.absent(),
    Value<String?> alarmMuzikAdi = const Value.absent(),
  }) => RutinlerData(
    id: id ?? this.id,
    ad: ad ?? this.ad,
    haftaninGunleri: haftaninGunleri ?? this.haftaninGunleri,
    aktifMi: aktifMi ?? this.aktifMi,
    sadeceTarih: sadeceTarih.present ? sadeceTarih.value : this.sadeceTarih,
    alarmAcikMi: alarmAcikMi ?? this.alarmAcikMi,
    alarmSaati: alarmSaati ?? this.alarmSaati,
    alarmDakikasi: alarmDakikasi ?? this.alarmDakikasi,
    alarmMuzikYolu: alarmMuzikYolu.present
        ? alarmMuzikYolu.value
        : this.alarmMuzikYolu,
    alarmMuzikAdi: alarmMuzikAdi.present
        ? alarmMuzikAdi.value
        : this.alarmMuzikAdi,
  );
  RutinlerData copyWithCompanion(RutinlerCompanion data) {
    return RutinlerData(
      id: data.id.present ? data.id.value : this.id,
      ad: data.ad.present ? data.ad.value : this.ad,
      haftaninGunleri: data.haftaninGunleri.present
          ? data.haftaninGunleri.value
          : this.haftaninGunleri,
      aktifMi: data.aktifMi.present ? data.aktifMi.value : this.aktifMi,
      sadeceTarih: data.sadeceTarih.present
          ? data.sadeceTarih.value
          : this.sadeceTarih,
      alarmAcikMi: data.alarmAcikMi.present
          ? data.alarmAcikMi.value
          : this.alarmAcikMi,
      alarmSaati: data.alarmSaati.present
          ? data.alarmSaati.value
          : this.alarmSaati,
      alarmDakikasi: data.alarmDakikasi.present
          ? data.alarmDakikasi.value
          : this.alarmDakikasi,
      alarmMuzikYolu: data.alarmMuzikYolu.present
          ? data.alarmMuzikYolu.value
          : this.alarmMuzikYolu,
      alarmMuzikAdi: data.alarmMuzikAdi.present
          ? data.alarmMuzikAdi.value
          : this.alarmMuzikAdi,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RutinlerData(')
          ..write('id: $id, ')
          ..write('ad: $ad, ')
          ..write('haftaninGunleri: $haftaninGunleri, ')
          ..write('aktifMi: $aktifMi, ')
          ..write('sadeceTarih: $sadeceTarih, ')
          ..write('alarmAcikMi: $alarmAcikMi, ')
          ..write('alarmSaati: $alarmSaati, ')
          ..write('alarmDakikasi: $alarmDakikasi, ')
          ..write('alarmMuzikYolu: $alarmMuzikYolu, ')
          ..write('alarmMuzikAdi: $alarmMuzikAdi')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ad,
    haftaninGunleri,
    aktifMi,
    sadeceTarih,
    alarmAcikMi,
    alarmSaati,
    alarmDakikasi,
    alarmMuzikYolu,
    alarmMuzikAdi,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RutinlerData &&
          other.id == this.id &&
          other.ad == this.ad &&
          other.haftaninGunleri == this.haftaninGunleri &&
          other.aktifMi == this.aktifMi &&
          other.sadeceTarih == this.sadeceTarih &&
          other.alarmAcikMi == this.alarmAcikMi &&
          other.alarmSaati == this.alarmSaati &&
          other.alarmDakikasi == this.alarmDakikasi &&
          other.alarmMuzikYolu == this.alarmMuzikYolu &&
          other.alarmMuzikAdi == this.alarmMuzikAdi);
}

class RutinlerCompanion extends UpdateCompanion<RutinlerData> {
  final Value<int> id;
  final Value<String> ad;
  final Value<String> haftaninGunleri;
  final Value<bool> aktifMi;
  final Value<String?> sadeceTarih;
  final Value<bool> alarmAcikMi;
  final Value<int> alarmSaati;
  final Value<int> alarmDakikasi;
  final Value<String?> alarmMuzikYolu;
  final Value<String?> alarmMuzikAdi;
  const RutinlerCompanion({
    this.id = const Value.absent(),
    this.ad = const Value.absent(),
    this.haftaninGunleri = const Value.absent(),
    this.aktifMi = const Value.absent(),
    this.sadeceTarih = const Value.absent(),
    this.alarmAcikMi = const Value.absent(),
    this.alarmSaati = const Value.absent(),
    this.alarmDakikasi = const Value.absent(),
    this.alarmMuzikYolu = const Value.absent(),
    this.alarmMuzikAdi = const Value.absent(),
  });
  RutinlerCompanion.insert({
    this.id = const Value.absent(),
    required String ad,
    this.haftaninGunleri = const Value.absent(),
    this.aktifMi = const Value.absent(),
    this.sadeceTarih = const Value.absent(),
    this.alarmAcikMi = const Value.absent(),
    this.alarmSaati = const Value.absent(),
    this.alarmDakikasi = const Value.absent(),
    this.alarmMuzikYolu = const Value.absent(),
    this.alarmMuzikAdi = const Value.absent(),
  }) : ad = Value(ad);
  static Insertable<RutinlerData> custom({
    Expression<int>? id,
    Expression<String>? ad,
    Expression<String>? haftaninGunleri,
    Expression<bool>? aktifMi,
    Expression<String>? sadeceTarih,
    Expression<bool>? alarmAcikMi,
    Expression<int>? alarmSaati,
    Expression<int>? alarmDakikasi,
    Expression<String>? alarmMuzikYolu,
    Expression<String>? alarmMuzikAdi,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ad != null) 'ad': ad,
      if (haftaninGunleri != null) 'haftanin_gunleri': haftaninGunleri,
      if (aktifMi != null) 'aktif_mi': aktifMi,
      if (sadeceTarih != null) 'sadece_tarih': sadeceTarih,
      if (alarmAcikMi != null) 'alarm_acik_mi': alarmAcikMi,
      if (alarmSaati != null) 'alarm_saati': alarmSaati,
      if (alarmDakikasi != null) 'alarm_dakikasi': alarmDakikasi,
      if (alarmMuzikYolu != null) 'alarm_muzik_yolu': alarmMuzikYolu,
      if (alarmMuzikAdi != null) 'alarm_muzik_adi': alarmMuzikAdi,
    });
  }

  RutinlerCompanion copyWith({
    Value<int>? id,
    Value<String>? ad,
    Value<String>? haftaninGunleri,
    Value<bool>? aktifMi,
    Value<String?>? sadeceTarih,
    Value<bool>? alarmAcikMi,
    Value<int>? alarmSaati,
    Value<int>? alarmDakikasi,
    Value<String?>? alarmMuzikYolu,
    Value<String?>? alarmMuzikAdi,
  }) {
    return RutinlerCompanion(
      id: id ?? this.id,
      ad: ad ?? this.ad,
      haftaninGunleri: haftaninGunleri ?? this.haftaninGunleri,
      aktifMi: aktifMi ?? this.aktifMi,
      sadeceTarih: sadeceTarih ?? this.sadeceTarih,
      alarmAcikMi: alarmAcikMi ?? this.alarmAcikMi,
      alarmSaati: alarmSaati ?? this.alarmSaati,
      alarmDakikasi: alarmDakikasi ?? this.alarmDakikasi,
      alarmMuzikYolu: alarmMuzikYolu ?? this.alarmMuzikYolu,
      alarmMuzikAdi: alarmMuzikAdi ?? this.alarmMuzikAdi,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ad.present) {
      map['ad'] = Variable<String>(ad.value);
    }
    if (haftaninGunleri.present) {
      map['haftanin_gunleri'] = Variable<String>(haftaninGunleri.value);
    }
    if (aktifMi.present) {
      map['aktif_mi'] = Variable<bool>(aktifMi.value);
    }
    if (sadeceTarih.present) {
      map['sadece_tarih'] = Variable<String>(sadeceTarih.value);
    }
    if (alarmAcikMi.present) {
      map['alarm_acik_mi'] = Variable<bool>(alarmAcikMi.value);
    }
    if (alarmSaati.present) {
      map['alarm_saati'] = Variable<int>(alarmSaati.value);
    }
    if (alarmDakikasi.present) {
      map['alarm_dakikasi'] = Variable<int>(alarmDakikasi.value);
    }
    if (alarmMuzikYolu.present) {
      map['alarm_muzik_yolu'] = Variable<String>(alarmMuzikYolu.value);
    }
    if (alarmMuzikAdi.present) {
      map['alarm_muzik_adi'] = Variable<String>(alarmMuzikAdi.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RutinlerCompanion(')
          ..write('id: $id, ')
          ..write('ad: $ad, ')
          ..write('haftaninGunleri: $haftaninGunleri, ')
          ..write('aktifMi: $aktifMi, ')
          ..write('sadeceTarih: $sadeceTarih, ')
          ..write('alarmAcikMi: $alarmAcikMi, ')
          ..write('alarmSaati: $alarmSaati, ')
          ..write('alarmDakikasi: $alarmDakikasi, ')
          ..write('alarmMuzikYolu: $alarmMuzikYolu, ')
          ..write('alarmMuzikAdi: $alarmMuzikAdi')
          ..write(')'))
        .toString();
  }
}

class $RutinEgzersizleriTable extends RutinEgzersizleri
    with TableInfo<$RutinEgzersizleriTable, RutinEgzersizleriData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RutinEgzersizleriTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _rutinIdMeta = const VerificationMeta(
    'rutinId',
  );
  @override
  late final GeneratedColumn<int> rutinId = GeneratedColumn<int>(
    'rutin_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rutinler (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _egzersizIdMeta = const VerificationMeta(
    'egzersizId',
  );
  @override
  late final GeneratedColumn<int> egzersizId = GeneratedColumn<int>(
    'egzersiz_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES egzersizler (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _siraIndeksiMeta = const VerificationMeta(
    'siraIndeksi',
  );
  @override
  late final GeneratedColumn<int> siraIndeksi = GeneratedColumn<int>(
    'sira_indeksi',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, rutinId, egzersizId, siraIndeksi];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rutin_egzersizleri';
  @override
  VerificationContext validateIntegrity(
    Insertable<RutinEgzersizleriData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('rutin_id')) {
      context.handle(
        _rutinIdMeta,
        rutinId.isAcceptableOrUnknown(data['rutin_id']!, _rutinIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rutinIdMeta);
    }
    if (data.containsKey('egzersiz_id')) {
      context.handle(
        _egzersizIdMeta,
        egzersizId.isAcceptableOrUnknown(data['egzersiz_id']!, _egzersizIdMeta),
      );
    } else if (isInserting) {
      context.missing(_egzersizIdMeta);
    }
    if (data.containsKey('sira_indeksi')) {
      context.handle(
        _siraIndeksiMeta,
        siraIndeksi.isAcceptableOrUnknown(
          data['sira_indeksi']!,
          _siraIndeksiMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_siraIndeksiMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RutinEgzersizleriData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RutinEgzersizleriData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rutinId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rutin_id'],
      )!,
      egzersizId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}egzersiz_id'],
      )!,
      siraIndeksi: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sira_indeksi'],
      )!,
    );
  }

  @override
  $RutinEgzersizleriTable createAlias(String alias) {
    return $RutinEgzersizleriTable(attachedDatabase, alias);
  }
}

class RutinEgzersizleriData extends DataClass
    implements Insertable<RutinEgzersizleriData> {
  final int id;
  final int rutinId;
  final int egzersizId;
  final int siraIndeksi;
  const RutinEgzersizleriData({
    required this.id,
    required this.rutinId,
    required this.egzersizId,
    required this.siraIndeksi,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['rutin_id'] = Variable<int>(rutinId);
    map['egzersiz_id'] = Variable<int>(egzersizId);
    map['sira_indeksi'] = Variable<int>(siraIndeksi);
    return map;
  }

  RutinEgzersizleriCompanion toCompanion(bool nullToAbsent) {
    return RutinEgzersizleriCompanion(
      id: Value(id),
      rutinId: Value(rutinId),
      egzersizId: Value(egzersizId),
      siraIndeksi: Value(siraIndeksi),
    );
  }

  factory RutinEgzersizleriData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RutinEgzersizleriData(
      id: serializer.fromJson<int>(json['id']),
      rutinId: serializer.fromJson<int>(json['rutinId']),
      egzersizId: serializer.fromJson<int>(json['egzersizId']),
      siraIndeksi: serializer.fromJson<int>(json['siraIndeksi']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rutinId': serializer.toJson<int>(rutinId),
      'egzersizId': serializer.toJson<int>(egzersizId),
      'siraIndeksi': serializer.toJson<int>(siraIndeksi),
    };
  }

  RutinEgzersizleriData copyWith({
    int? id,
    int? rutinId,
    int? egzersizId,
    int? siraIndeksi,
  }) => RutinEgzersizleriData(
    id: id ?? this.id,
    rutinId: rutinId ?? this.rutinId,
    egzersizId: egzersizId ?? this.egzersizId,
    siraIndeksi: siraIndeksi ?? this.siraIndeksi,
  );
  RutinEgzersizleriData copyWithCompanion(RutinEgzersizleriCompanion data) {
    return RutinEgzersizleriData(
      id: data.id.present ? data.id.value : this.id,
      rutinId: data.rutinId.present ? data.rutinId.value : this.rutinId,
      egzersizId: data.egzersizId.present
          ? data.egzersizId.value
          : this.egzersizId,
      siraIndeksi: data.siraIndeksi.present
          ? data.siraIndeksi.value
          : this.siraIndeksi,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RutinEgzersizleriData(')
          ..write('id: $id, ')
          ..write('rutinId: $rutinId, ')
          ..write('egzersizId: $egzersizId, ')
          ..write('siraIndeksi: $siraIndeksi')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, rutinId, egzersizId, siraIndeksi);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RutinEgzersizleriData &&
          other.id == this.id &&
          other.rutinId == this.rutinId &&
          other.egzersizId == this.egzersizId &&
          other.siraIndeksi == this.siraIndeksi);
}

class RutinEgzersizleriCompanion
    extends UpdateCompanion<RutinEgzersizleriData> {
  final Value<int> id;
  final Value<int> rutinId;
  final Value<int> egzersizId;
  final Value<int> siraIndeksi;
  const RutinEgzersizleriCompanion({
    this.id = const Value.absent(),
    this.rutinId = const Value.absent(),
    this.egzersizId = const Value.absent(),
    this.siraIndeksi = const Value.absent(),
  });
  RutinEgzersizleriCompanion.insert({
    this.id = const Value.absent(),
    required int rutinId,
    required int egzersizId,
    required int siraIndeksi,
  }) : rutinId = Value(rutinId),
       egzersizId = Value(egzersizId),
       siraIndeksi = Value(siraIndeksi);
  static Insertable<RutinEgzersizleriData> custom({
    Expression<int>? id,
    Expression<int>? rutinId,
    Expression<int>? egzersizId,
    Expression<int>? siraIndeksi,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rutinId != null) 'rutin_id': rutinId,
      if (egzersizId != null) 'egzersiz_id': egzersizId,
      if (siraIndeksi != null) 'sira_indeksi': siraIndeksi,
    });
  }

  RutinEgzersizleriCompanion copyWith({
    Value<int>? id,
    Value<int>? rutinId,
    Value<int>? egzersizId,
    Value<int>? siraIndeksi,
  }) {
    return RutinEgzersizleriCompanion(
      id: id ?? this.id,
      rutinId: rutinId ?? this.rutinId,
      egzersizId: egzersizId ?? this.egzersizId,
      siraIndeksi: siraIndeksi ?? this.siraIndeksi,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rutinId.present) {
      map['rutin_id'] = Variable<int>(rutinId.value);
    }
    if (egzersizId.present) {
      map['egzersiz_id'] = Variable<int>(egzersizId.value);
    }
    if (siraIndeksi.present) {
      map['sira_indeksi'] = Variable<int>(siraIndeksi.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RutinEgzersizleriCompanion(')
          ..write('id: $id, ')
          ..write('rutinId: $rutinId, ')
          ..write('egzersizId: $egzersizId, ')
          ..write('siraIndeksi: $siraIndeksi')
          ..write(')'))
        .toString();
  }
}

class $AntrenmanKayitlariTable extends AntrenmanKayitlari
    with TableInfo<$AntrenmanKayitlariTable, AntrenmanKayitlariData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AntrenmanKayitlariTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tarihMeta = const VerificationMeta('tarih');
  @override
  late final GeneratedColumn<String> tarih = GeneratedColumn<String>(
    'tarih',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _rutinIdMeta = const VerificationMeta(
    'rutinId',
  );
  @override
  late final GeneratedColumn<int> rutinId = GeneratedColumn<int>(
    'rutin_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rutinler (id) ON DELETE SET NULL',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, tarih, rutinId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'antrenman_kayitlari';
  @override
  VerificationContext validateIntegrity(
    Insertable<AntrenmanKayitlariData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tarih')) {
      context.handle(
        _tarihMeta,
        tarih.isAcceptableOrUnknown(data['tarih']!, _tarihMeta),
      );
    } else if (isInserting) {
      context.missing(_tarihMeta);
    }
    if (data.containsKey('rutin_id')) {
      context.handle(
        _rutinIdMeta,
        rutinId.isAcceptableOrUnknown(data['rutin_id']!, _rutinIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AntrenmanKayitlariData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AntrenmanKayitlariData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tarih: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tarih'],
      )!,
      rutinId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rutin_id'],
      ),
    );
  }

  @override
  $AntrenmanKayitlariTable createAlias(String alias) {
    return $AntrenmanKayitlariTable(attachedDatabase, alias);
  }
}

class AntrenmanKayitlariData extends DataClass
    implements Insertable<AntrenmanKayitlariData> {
  final int id;
  final String tarih;
  final int? rutinId;
  const AntrenmanKayitlariData({
    required this.id,
    required this.tarih,
    this.rutinId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tarih'] = Variable<String>(tarih);
    if (!nullToAbsent || rutinId != null) {
      map['rutin_id'] = Variable<int>(rutinId);
    }
    return map;
  }

  AntrenmanKayitlariCompanion toCompanion(bool nullToAbsent) {
    return AntrenmanKayitlariCompanion(
      id: Value(id),
      tarih: Value(tarih),
      rutinId: rutinId == null && nullToAbsent
          ? const Value.absent()
          : Value(rutinId),
    );
  }

  factory AntrenmanKayitlariData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AntrenmanKayitlariData(
      id: serializer.fromJson<int>(json['id']),
      tarih: serializer.fromJson<String>(json['tarih']),
      rutinId: serializer.fromJson<int?>(json['rutinId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tarih': serializer.toJson<String>(tarih),
      'rutinId': serializer.toJson<int?>(rutinId),
    };
  }

  AntrenmanKayitlariData copyWith({
    int? id,
    String? tarih,
    Value<int?> rutinId = const Value.absent(),
  }) => AntrenmanKayitlariData(
    id: id ?? this.id,
    tarih: tarih ?? this.tarih,
    rutinId: rutinId.present ? rutinId.value : this.rutinId,
  );
  AntrenmanKayitlariData copyWithCompanion(AntrenmanKayitlariCompanion data) {
    return AntrenmanKayitlariData(
      id: data.id.present ? data.id.value : this.id,
      tarih: data.tarih.present ? data.tarih.value : this.tarih,
      rutinId: data.rutinId.present ? data.rutinId.value : this.rutinId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AntrenmanKayitlariData(')
          ..write('id: $id, ')
          ..write('tarih: $tarih, ')
          ..write('rutinId: $rutinId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tarih, rutinId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AntrenmanKayitlariData &&
          other.id == this.id &&
          other.tarih == this.tarih &&
          other.rutinId == this.rutinId);
}

class AntrenmanKayitlariCompanion
    extends UpdateCompanion<AntrenmanKayitlariData> {
  final Value<int> id;
  final Value<String> tarih;
  final Value<int?> rutinId;
  const AntrenmanKayitlariCompanion({
    this.id = const Value.absent(),
    this.tarih = const Value.absent(),
    this.rutinId = const Value.absent(),
  });
  AntrenmanKayitlariCompanion.insert({
    this.id = const Value.absent(),
    required String tarih,
    this.rutinId = const Value.absent(),
  }) : tarih = Value(tarih);
  static Insertable<AntrenmanKayitlariData> custom({
    Expression<int>? id,
    Expression<String>? tarih,
    Expression<int>? rutinId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tarih != null) 'tarih': tarih,
      if (rutinId != null) 'rutin_id': rutinId,
    });
  }

  AntrenmanKayitlariCompanion copyWith({
    Value<int>? id,
    Value<String>? tarih,
    Value<int?>? rutinId,
  }) {
    return AntrenmanKayitlariCompanion(
      id: id ?? this.id,
      tarih: tarih ?? this.tarih,
      rutinId: rutinId ?? this.rutinId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tarih.present) {
      map['tarih'] = Variable<String>(tarih.value);
    }
    if (rutinId.present) {
      map['rutin_id'] = Variable<int>(rutinId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AntrenmanKayitlariCompanion(')
          ..write('id: $id, ')
          ..write('tarih: $tarih, ')
          ..write('rutinId: $rutinId')
          ..write(')'))
        .toString();
  }
}

class $EgzersizKayitlariTable extends EgzersizKayitlari
    with TableInfo<$EgzersizKayitlariTable, EgzersizKayitlariData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EgzersizKayitlariTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _antrenmanKaydiIdMeta = const VerificationMeta(
    'antrenmanKaydiId',
  );
  @override
  late final GeneratedColumn<int> antrenmanKaydiId = GeneratedColumn<int>(
    'antrenman_kaydi_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES antrenman_kayitlari (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _egzersizIdMeta = const VerificationMeta(
    'egzersizId',
  );
  @override
  late final GeneratedColumn<int> egzersizId = GeneratedColumn<int>(
    'egzersiz_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES egzersizler (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _rutinIdMeta = const VerificationMeta(
    'rutinId',
  );
  @override
  late final GeneratedColumn<int> rutinId = GeneratedColumn<int>(
    'rutin_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rutinler (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _egzersizAdiKopyasiMeta =
      const VerificationMeta('egzersizAdiKopyasi');
  @override
  late final GeneratedColumn<String> egzersizAdiKopyasi =
      GeneratedColumn<String>(
        'egzersiz_adi_kopyasi',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _durumMeta = const VerificationMeta('durum');
  @override
  late final GeneratedColumn<String> durum = GeneratedColumn<String>(
    'durum',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('bekliyor'),
  );
  static const VerificationMeta _notMetniMeta = const VerificationMeta(
    'notMetni',
  );
  @override
  late final GeneratedColumn<String> notMetni = GeneratedColumn<String>(
    'not_metni',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    antrenmanKaydiId,
    egzersizId,
    rutinId,
    egzersizAdiKopyasi,
    durum,
    notMetni,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'egzersiz_kayitlari';
  @override
  VerificationContext validateIntegrity(
    Insertable<EgzersizKayitlariData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('antrenman_kaydi_id')) {
      context.handle(
        _antrenmanKaydiIdMeta,
        antrenmanKaydiId.isAcceptableOrUnknown(
          data['antrenman_kaydi_id']!,
          _antrenmanKaydiIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_antrenmanKaydiIdMeta);
    }
    if (data.containsKey('egzersiz_id')) {
      context.handle(
        _egzersizIdMeta,
        egzersizId.isAcceptableOrUnknown(data['egzersiz_id']!, _egzersizIdMeta),
      );
    } else if (isInserting) {
      context.missing(_egzersizIdMeta);
    }
    if (data.containsKey('rutin_id')) {
      context.handle(
        _rutinIdMeta,
        rutinId.isAcceptableOrUnknown(data['rutin_id']!, _rutinIdMeta),
      );
    }
    if (data.containsKey('egzersiz_adi_kopyasi')) {
      context.handle(
        _egzersizAdiKopyasiMeta,
        egzersizAdiKopyasi.isAcceptableOrUnknown(
          data['egzersiz_adi_kopyasi']!,
          _egzersizAdiKopyasiMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_egzersizAdiKopyasiMeta);
    }
    if (data.containsKey('durum')) {
      context.handle(
        _durumMeta,
        durum.isAcceptableOrUnknown(data['durum']!, _durumMeta),
      );
    }
    if (data.containsKey('not_metni')) {
      context.handle(
        _notMetniMeta,
        notMetni.isAcceptableOrUnknown(data['not_metni']!, _notMetniMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EgzersizKayitlariData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EgzersizKayitlariData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      antrenmanKaydiId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}antrenman_kaydi_id'],
      )!,
      egzersizId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}egzersiz_id'],
      )!,
      rutinId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rutin_id'],
      ),
      egzersizAdiKopyasi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}egzersiz_adi_kopyasi'],
      )!,
      durum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}durum'],
      )!,
      notMetni: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}not_metni'],
      ),
    );
  }

  @override
  $EgzersizKayitlariTable createAlias(String alias) {
    return $EgzersizKayitlariTable(attachedDatabase, alias);
  }
}

class EgzersizKayitlariData extends DataClass
    implements Insertable<EgzersizKayitlariData> {
  final int id;
  final int antrenmanKaydiId;
  final int egzersizId;
  final int? rutinId;
  final String egzersizAdiKopyasi;
  final String durum;
  final String? notMetni;
  const EgzersizKayitlariData({
    required this.id,
    required this.antrenmanKaydiId,
    required this.egzersizId,
    this.rutinId,
    required this.egzersizAdiKopyasi,
    required this.durum,
    this.notMetni,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['antrenman_kaydi_id'] = Variable<int>(antrenmanKaydiId);
    map['egzersiz_id'] = Variable<int>(egzersizId);
    if (!nullToAbsent || rutinId != null) {
      map['rutin_id'] = Variable<int>(rutinId);
    }
    map['egzersiz_adi_kopyasi'] = Variable<String>(egzersizAdiKopyasi);
    map['durum'] = Variable<String>(durum);
    if (!nullToAbsent || notMetni != null) {
      map['not_metni'] = Variable<String>(notMetni);
    }
    return map;
  }

  EgzersizKayitlariCompanion toCompanion(bool nullToAbsent) {
    return EgzersizKayitlariCompanion(
      id: Value(id),
      antrenmanKaydiId: Value(antrenmanKaydiId),
      egzersizId: Value(egzersizId),
      rutinId: rutinId == null && nullToAbsent
          ? const Value.absent()
          : Value(rutinId),
      egzersizAdiKopyasi: Value(egzersizAdiKopyasi),
      durum: Value(durum),
      notMetni: notMetni == null && nullToAbsent
          ? const Value.absent()
          : Value(notMetni),
    );
  }

  factory EgzersizKayitlariData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EgzersizKayitlariData(
      id: serializer.fromJson<int>(json['id']),
      antrenmanKaydiId: serializer.fromJson<int>(json['antrenmanKaydiId']),
      egzersizId: serializer.fromJson<int>(json['egzersizId']),
      rutinId: serializer.fromJson<int?>(json['rutinId']),
      egzersizAdiKopyasi: serializer.fromJson<String>(
        json['egzersizAdiKopyasi'],
      ),
      durum: serializer.fromJson<String>(json['durum']),
      notMetni: serializer.fromJson<String?>(json['notMetni']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'antrenmanKaydiId': serializer.toJson<int>(antrenmanKaydiId),
      'egzersizId': serializer.toJson<int>(egzersizId),
      'rutinId': serializer.toJson<int?>(rutinId),
      'egzersizAdiKopyasi': serializer.toJson<String>(egzersizAdiKopyasi),
      'durum': serializer.toJson<String>(durum),
      'notMetni': serializer.toJson<String?>(notMetni),
    };
  }

  EgzersizKayitlariData copyWith({
    int? id,
    int? antrenmanKaydiId,
    int? egzersizId,
    Value<int?> rutinId = const Value.absent(),
    String? egzersizAdiKopyasi,
    String? durum,
    Value<String?> notMetni = const Value.absent(),
  }) => EgzersizKayitlariData(
    id: id ?? this.id,
    antrenmanKaydiId: antrenmanKaydiId ?? this.antrenmanKaydiId,
    egzersizId: egzersizId ?? this.egzersizId,
    rutinId: rutinId.present ? rutinId.value : this.rutinId,
    egzersizAdiKopyasi: egzersizAdiKopyasi ?? this.egzersizAdiKopyasi,
    durum: durum ?? this.durum,
    notMetni: notMetni.present ? notMetni.value : this.notMetni,
  );
  EgzersizKayitlariData copyWithCompanion(EgzersizKayitlariCompanion data) {
    return EgzersizKayitlariData(
      id: data.id.present ? data.id.value : this.id,
      antrenmanKaydiId: data.antrenmanKaydiId.present
          ? data.antrenmanKaydiId.value
          : this.antrenmanKaydiId,
      egzersizId: data.egzersizId.present
          ? data.egzersizId.value
          : this.egzersizId,
      rutinId: data.rutinId.present ? data.rutinId.value : this.rutinId,
      egzersizAdiKopyasi: data.egzersizAdiKopyasi.present
          ? data.egzersizAdiKopyasi.value
          : this.egzersizAdiKopyasi,
      durum: data.durum.present ? data.durum.value : this.durum,
      notMetni: data.notMetni.present ? data.notMetni.value : this.notMetni,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EgzersizKayitlariData(')
          ..write('id: $id, ')
          ..write('antrenmanKaydiId: $antrenmanKaydiId, ')
          ..write('egzersizId: $egzersizId, ')
          ..write('rutinId: $rutinId, ')
          ..write('egzersizAdiKopyasi: $egzersizAdiKopyasi, ')
          ..write('durum: $durum, ')
          ..write('notMetni: $notMetni')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    antrenmanKaydiId,
    egzersizId,
    rutinId,
    egzersizAdiKopyasi,
    durum,
    notMetni,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EgzersizKayitlariData &&
          other.id == this.id &&
          other.antrenmanKaydiId == this.antrenmanKaydiId &&
          other.egzersizId == this.egzersizId &&
          other.rutinId == this.rutinId &&
          other.egzersizAdiKopyasi == this.egzersizAdiKopyasi &&
          other.durum == this.durum &&
          other.notMetni == this.notMetni);
}

class EgzersizKayitlariCompanion
    extends UpdateCompanion<EgzersizKayitlariData> {
  final Value<int> id;
  final Value<int> antrenmanKaydiId;
  final Value<int> egzersizId;
  final Value<int?> rutinId;
  final Value<String> egzersizAdiKopyasi;
  final Value<String> durum;
  final Value<String?> notMetni;
  const EgzersizKayitlariCompanion({
    this.id = const Value.absent(),
    this.antrenmanKaydiId = const Value.absent(),
    this.egzersizId = const Value.absent(),
    this.rutinId = const Value.absent(),
    this.egzersizAdiKopyasi = const Value.absent(),
    this.durum = const Value.absent(),
    this.notMetni = const Value.absent(),
  });
  EgzersizKayitlariCompanion.insert({
    this.id = const Value.absent(),
    required int antrenmanKaydiId,
    required int egzersizId,
    this.rutinId = const Value.absent(),
    required String egzersizAdiKopyasi,
    this.durum = const Value.absent(),
    this.notMetni = const Value.absent(),
  }) : antrenmanKaydiId = Value(antrenmanKaydiId),
       egzersizId = Value(egzersizId),
       egzersizAdiKopyasi = Value(egzersizAdiKopyasi);
  static Insertable<EgzersizKayitlariData> custom({
    Expression<int>? id,
    Expression<int>? antrenmanKaydiId,
    Expression<int>? egzersizId,
    Expression<int>? rutinId,
    Expression<String>? egzersizAdiKopyasi,
    Expression<String>? durum,
    Expression<String>? notMetni,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (antrenmanKaydiId != null) 'antrenman_kaydi_id': antrenmanKaydiId,
      if (egzersizId != null) 'egzersiz_id': egzersizId,
      if (rutinId != null) 'rutin_id': rutinId,
      if (egzersizAdiKopyasi != null)
        'egzersiz_adi_kopyasi': egzersizAdiKopyasi,
      if (durum != null) 'durum': durum,
      if (notMetni != null) 'not_metni': notMetni,
    });
  }

  EgzersizKayitlariCompanion copyWith({
    Value<int>? id,
    Value<int>? antrenmanKaydiId,
    Value<int>? egzersizId,
    Value<int?>? rutinId,
    Value<String>? egzersizAdiKopyasi,
    Value<String>? durum,
    Value<String?>? notMetni,
  }) {
    return EgzersizKayitlariCompanion(
      id: id ?? this.id,
      antrenmanKaydiId: antrenmanKaydiId ?? this.antrenmanKaydiId,
      egzersizId: egzersizId ?? this.egzersizId,
      rutinId: rutinId ?? this.rutinId,
      egzersizAdiKopyasi: egzersizAdiKopyasi ?? this.egzersizAdiKopyasi,
      durum: durum ?? this.durum,
      notMetni: notMetni ?? this.notMetni,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (antrenmanKaydiId.present) {
      map['antrenman_kaydi_id'] = Variable<int>(antrenmanKaydiId.value);
    }
    if (egzersizId.present) {
      map['egzersiz_id'] = Variable<int>(egzersizId.value);
    }
    if (rutinId.present) {
      map['rutin_id'] = Variable<int>(rutinId.value);
    }
    if (egzersizAdiKopyasi.present) {
      map['egzersiz_adi_kopyasi'] = Variable<String>(egzersizAdiKopyasi.value);
    }
    if (durum.present) {
      map['durum'] = Variable<String>(durum.value);
    }
    if (notMetni.present) {
      map['not_metni'] = Variable<String>(notMetni.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EgzersizKayitlariCompanion(')
          ..write('id: $id, ')
          ..write('antrenmanKaydiId: $antrenmanKaydiId, ')
          ..write('egzersizId: $egzersizId, ')
          ..write('rutinId: $rutinId, ')
          ..write('egzersizAdiKopyasi: $egzersizAdiKopyasi, ')
          ..write('durum: $durum, ')
          ..write('notMetni: $notMetni')
          ..write(')'))
        .toString();
  }
}

class $HatirlaticilarTable extends Hatirlaticilar
    with TableInfo<$HatirlaticilarTable, HatirlaticilarData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HatirlaticilarTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _etiketMeta = const VerificationMeta('etiket');
  @override
  late final GeneratedColumn<String> etiket = GeneratedColumn<String>(
    'etiket',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _saatMeta = const VerificationMeta('saat');
  @override
  late final GeneratedColumn<int> saat = GeneratedColumn<int>(
    'saat',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dakikaMeta = const VerificationMeta('dakika');
  @override
  late final GeneratedColumn<int> dakika = GeneratedColumn<int>(
    'dakika',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _haftaninGunleriMeta = const VerificationMeta(
    'haftaninGunleri',
  );
  @override
  late final GeneratedColumn<String> haftaninGunleri = GeneratedColumn<String>(
    'haftanin_gunleri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('1,2,3,4,5,6,7'),
  );
  static const VerificationMeta _etkinMiMeta = const VerificationMeta(
    'etkinMi',
  );
  @override
  late final GeneratedColumn<bool> etkinMi = GeneratedColumn<bool>(
    'etkin_mi',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("etkin_mi" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    etiket,
    saat,
    dakika,
    haftaninGunleri,
    etkinMi,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hatirlaticilar';
  @override
  VerificationContext validateIntegrity(
    Insertable<HatirlaticilarData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('etiket')) {
      context.handle(
        _etiketMeta,
        etiket.isAcceptableOrUnknown(data['etiket']!, _etiketMeta),
      );
    } else if (isInserting) {
      context.missing(_etiketMeta);
    }
    if (data.containsKey('saat')) {
      context.handle(
        _saatMeta,
        saat.isAcceptableOrUnknown(data['saat']!, _saatMeta),
      );
    } else if (isInserting) {
      context.missing(_saatMeta);
    }
    if (data.containsKey('dakika')) {
      context.handle(
        _dakikaMeta,
        dakika.isAcceptableOrUnknown(data['dakika']!, _dakikaMeta),
      );
    } else if (isInserting) {
      context.missing(_dakikaMeta);
    }
    if (data.containsKey('haftanin_gunleri')) {
      context.handle(
        _haftaninGunleriMeta,
        haftaninGunleri.isAcceptableOrUnknown(
          data['haftanin_gunleri']!,
          _haftaninGunleriMeta,
        ),
      );
    }
    if (data.containsKey('etkin_mi')) {
      context.handle(
        _etkinMiMeta,
        etkinMi.isAcceptableOrUnknown(data['etkin_mi']!, _etkinMiMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HatirlaticilarData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HatirlaticilarData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      etiket: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etiket'],
      )!,
      saat: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saat'],
      )!,
      dakika: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dakika'],
      )!,
      haftaninGunleri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}haftanin_gunleri'],
      )!,
      etkinMi: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}etkin_mi'],
      )!,
    );
  }

  @override
  $HatirlaticilarTable createAlias(String alias) {
    return $HatirlaticilarTable(attachedDatabase, alias);
  }
}

class HatirlaticilarData extends DataClass
    implements Insertable<HatirlaticilarData> {
  final int id;
  final String etiket;
  final int saat;
  final int dakika;
  final String haftaninGunleri;
  final bool etkinMi;
  const HatirlaticilarData({
    required this.id,
    required this.etiket,
    required this.saat,
    required this.dakika,
    required this.haftaninGunleri,
    required this.etkinMi,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['etiket'] = Variable<String>(etiket);
    map['saat'] = Variable<int>(saat);
    map['dakika'] = Variable<int>(dakika);
    map['haftanin_gunleri'] = Variable<String>(haftaninGunleri);
    map['etkin_mi'] = Variable<bool>(etkinMi);
    return map;
  }

  HatirlaticilarCompanion toCompanion(bool nullToAbsent) {
    return HatirlaticilarCompanion(
      id: Value(id),
      etiket: Value(etiket),
      saat: Value(saat),
      dakika: Value(dakika),
      haftaninGunleri: Value(haftaninGunleri),
      etkinMi: Value(etkinMi),
    );
  }

  factory HatirlaticilarData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HatirlaticilarData(
      id: serializer.fromJson<int>(json['id']),
      etiket: serializer.fromJson<String>(json['etiket']),
      saat: serializer.fromJson<int>(json['saat']),
      dakika: serializer.fromJson<int>(json['dakika']),
      haftaninGunleri: serializer.fromJson<String>(json['haftaninGunleri']),
      etkinMi: serializer.fromJson<bool>(json['etkinMi']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'etiket': serializer.toJson<String>(etiket),
      'saat': serializer.toJson<int>(saat),
      'dakika': serializer.toJson<int>(dakika),
      'haftaninGunleri': serializer.toJson<String>(haftaninGunleri),
      'etkinMi': serializer.toJson<bool>(etkinMi),
    };
  }

  HatirlaticilarData copyWith({
    int? id,
    String? etiket,
    int? saat,
    int? dakika,
    String? haftaninGunleri,
    bool? etkinMi,
  }) => HatirlaticilarData(
    id: id ?? this.id,
    etiket: etiket ?? this.etiket,
    saat: saat ?? this.saat,
    dakika: dakika ?? this.dakika,
    haftaninGunleri: haftaninGunleri ?? this.haftaninGunleri,
    etkinMi: etkinMi ?? this.etkinMi,
  );
  HatirlaticilarData copyWithCompanion(HatirlaticilarCompanion data) {
    return HatirlaticilarData(
      id: data.id.present ? data.id.value : this.id,
      etiket: data.etiket.present ? data.etiket.value : this.etiket,
      saat: data.saat.present ? data.saat.value : this.saat,
      dakika: data.dakika.present ? data.dakika.value : this.dakika,
      haftaninGunleri: data.haftaninGunleri.present
          ? data.haftaninGunleri.value
          : this.haftaninGunleri,
      etkinMi: data.etkinMi.present ? data.etkinMi.value : this.etkinMi,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HatirlaticilarData(')
          ..write('id: $id, ')
          ..write('etiket: $etiket, ')
          ..write('saat: $saat, ')
          ..write('dakika: $dakika, ')
          ..write('haftaninGunleri: $haftaninGunleri, ')
          ..write('etkinMi: $etkinMi')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, etiket, saat, dakika, haftaninGunleri, etkinMi);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HatirlaticilarData &&
          other.id == this.id &&
          other.etiket == this.etiket &&
          other.saat == this.saat &&
          other.dakika == this.dakika &&
          other.haftaninGunleri == this.haftaninGunleri &&
          other.etkinMi == this.etkinMi);
}

class HatirlaticilarCompanion extends UpdateCompanion<HatirlaticilarData> {
  final Value<int> id;
  final Value<String> etiket;
  final Value<int> saat;
  final Value<int> dakika;
  final Value<String> haftaninGunleri;
  final Value<bool> etkinMi;
  const HatirlaticilarCompanion({
    this.id = const Value.absent(),
    this.etiket = const Value.absent(),
    this.saat = const Value.absent(),
    this.dakika = const Value.absent(),
    this.haftaninGunleri = const Value.absent(),
    this.etkinMi = const Value.absent(),
  });
  HatirlaticilarCompanion.insert({
    this.id = const Value.absent(),
    required String etiket,
    required int saat,
    required int dakika,
    this.haftaninGunleri = const Value.absent(),
    this.etkinMi = const Value.absent(),
  }) : etiket = Value(etiket),
       saat = Value(saat),
       dakika = Value(dakika);
  static Insertable<HatirlaticilarData> custom({
    Expression<int>? id,
    Expression<String>? etiket,
    Expression<int>? saat,
    Expression<int>? dakika,
    Expression<String>? haftaninGunleri,
    Expression<bool>? etkinMi,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (etiket != null) 'etiket': etiket,
      if (saat != null) 'saat': saat,
      if (dakika != null) 'dakika': dakika,
      if (haftaninGunleri != null) 'haftanin_gunleri': haftaninGunleri,
      if (etkinMi != null) 'etkin_mi': etkinMi,
    });
  }

  HatirlaticilarCompanion copyWith({
    Value<int>? id,
    Value<String>? etiket,
    Value<int>? saat,
    Value<int>? dakika,
    Value<String>? haftaninGunleri,
    Value<bool>? etkinMi,
  }) {
    return HatirlaticilarCompanion(
      id: id ?? this.id,
      etiket: etiket ?? this.etiket,
      saat: saat ?? this.saat,
      dakika: dakika ?? this.dakika,
      haftaninGunleri: haftaninGunleri ?? this.haftaninGunleri,
      etkinMi: etkinMi ?? this.etkinMi,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (etiket.present) {
      map['etiket'] = Variable<String>(etiket.value);
    }
    if (saat.present) {
      map['saat'] = Variable<int>(saat.value);
    }
    if (dakika.present) {
      map['dakika'] = Variable<int>(dakika.value);
    }
    if (haftaninGunleri.present) {
      map['haftanin_gunleri'] = Variable<String>(haftaninGunleri.value);
    }
    if (etkinMi.present) {
      map['etkin_mi'] = Variable<bool>(etkinMi.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HatirlaticilarCompanion(')
          ..write('id: $id, ')
          ..write('etiket: $etiket, ')
          ..write('saat: $saat, ')
          ..write('dakika: $dakika, ')
          ..write('haftaninGunleri: $haftaninGunleri, ')
          ..write('etkinMi: $etkinMi')
          ..write(')'))
        .toString();
  }
}

abstract class _$UygulamaVeritabani extends GeneratedDatabase {
  _$UygulamaVeritabani(QueryExecutor e) : super(e);
  $UygulamaVeritabaniManager get managers => $UygulamaVeritabaniManager(this);
  late final $EgzersizlerTable egzersizler = $EgzersizlerTable(this);
  late final $RutinlerTable rutinler = $RutinlerTable(this);
  late final $RutinEgzersizleriTable rutinEgzersizleri =
      $RutinEgzersizleriTable(this);
  late final $AntrenmanKayitlariTable antrenmanKayitlari =
      $AntrenmanKayitlariTable(this);
  late final $EgzersizKayitlariTable egzersizKayitlari =
      $EgzersizKayitlariTable(this);
  late final $HatirlaticilarTable hatirlaticilar = $HatirlaticilarTable(this);
  late final EgzersizDao egzersizDao = EgzersizDao(this as UygulamaVeritabani);
  late final RutinDao rutinDao = RutinDao(this as UygulamaVeritabani);
  late final AntrenmanDao antrenmanDao = AntrenmanDao(
    this as UygulamaVeritabani,
  );
  late final HatirlaticiDao hatirlaticiDao = HatirlaticiDao(
    this as UygulamaVeritabani,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    egzersizler,
    rutinler,
    rutinEgzersizleri,
    antrenmanKayitlari,
    egzersizKayitlari,
    hatirlaticilar,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'rutinler',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('rutin_egzersizleri', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'rutinler',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('antrenman_kayitlari', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'antrenman_kayitlari',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('egzersiz_kayitlari', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'rutinler',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('egzersiz_kayitlari', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$EgzersizlerTableCreateCompanionBuilder =
    EgzersizlerCompanion Function({
      Value<int> id,
      required String ad,
      Value<String> aciklama,
      required String tur,
      Value<int?> sureSaniye,
      Value<int?> setSayisi,
      Value<int?> tekrarSayisi,
      Value<String> kategori,
      Value<bool> arsivlendiMi,
    });
typedef $$EgzersizlerTableUpdateCompanionBuilder =
    EgzersizlerCompanion Function({
      Value<int> id,
      Value<String> ad,
      Value<String> aciklama,
      Value<String> tur,
      Value<int?> sureSaniye,
      Value<int?> setSayisi,
      Value<int?> tekrarSayisi,
      Value<String> kategori,
      Value<bool> arsivlendiMi,
    });

final class $$EgzersizlerTableReferences
    extends
        BaseReferences<
          _$UygulamaVeritabani,
          $EgzersizlerTable,
          EgzersizlerData
        > {
  $$EgzersizlerTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $RutinEgzersizleriTable,
    List<RutinEgzersizleriData>
  >
  _rutinEgzersizleriRefsTable(_$UygulamaVeritabani db) =>
      MultiTypedResultKey.fromTable(
        db.rutinEgzersizleri,
        aliasName: 'egzersizler__id__rutin_egzersizleri__egzersiz_id',
      );

  $$RutinEgzersizleriTableProcessedTableManager get rutinEgzersizleriRefs {
    final manager = $$RutinEgzersizleriTableTableManager(
      $_db,
      $_db.rutinEgzersizleri,
    ).filter((f) => f.egzersizId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _rutinEgzersizleriRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $EgzersizKayitlariTable,
    List<EgzersizKayitlariData>
  >
  _egzersizKayitlariRefsTable(_$UygulamaVeritabani db) =>
      MultiTypedResultKey.fromTable(
        db.egzersizKayitlari,
        aliasName: 'egzersizler__id__egzersiz_kayitlari__egzersiz_id',
      );

  $$EgzersizKayitlariTableProcessedTableManager get egzersizKayitlariRefs {
    final manager = $$EgzersizKayitlariTableTableManager(
      $_db,
      $_db.egzersizKayitlari,
    ).filter((f) => f.egzersizId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _egzersizKayitlariRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EgzersizlerTableFilterComposer
    extends Composer<_$UygulamaVeritabani, $EgzersizlerTable> {
  $$EgzersizlerTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ad => $composableBuilder(
    column: $table.ad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aciklama => $composableBuilder(
    column: $table.aciklama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tur => $composableBuilder(
    column: $table.tur,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sureSaniye => $composableBuilder(
    column: $table.sureSaniye,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setSayisi => $composableBuilder(
    column: $table.setSayisi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tekrarSayisi => $composableBuilder(
    column: $table.tekrarSayisi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kategori => $composableBuilder(
    column: $table.kategori,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get arsivlendiMi => $composableBuilder(
    column: $table.arsivlendiMi,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> rutinEgzersizleriRefs(
    Expression<bool> Function($$RutinEgzersizleriTableFilterComposer f) f,
  ) {
    final $$RutinEgzersizleriTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rutinEgzersizleri,
      getReferencedColumn: (t) => t.egzersizId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RutinEgzersizleriTableFilterComposer(
            $db: $db,
            $table: $db.rutinEgzersizleri,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> egzersizKayitlariRefs(
    Expression<bool> Function($$EgzersizKayitlariTableFilterComposer f) f,
  ) {
    final $$EgzersizKayitlariTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.egzersizKayitlari,
      getReferencedColumn: (t) => t.egzersizId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EgzersizKayitlariTableFilterComposer(
            $db: $db,
            $table: $db.egzersizKayitlari,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EgzersizlerTableOrderingComposer
    extends Composer<_$UygulamaVeritabani, $EgzersizlerTable> {
  $$EgzersizlerTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ad => $composableBuilder(
    column: $table.ad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aciklama => $composableBuilder(
    column: $table.aciklama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tur => $composableBuilder(
    column: $table.tur,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sureSaniye => $composableBuilder(
    column: $table.sureSaniye,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setSayisi => $composableBuilder(
    column: $table.setSayisi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tekrarSayisi => $composableBuilder(
    column: $table.tekrarSayisi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kategori => $composableBuilder(
    column: $table.kategori,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get arsivlendiMi => $composableBuilder(
    column: $table.arsivlendiMi,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EgzersizlerTableAnnotationComposer
    extends Composer<_$UygulamaVeritabani, $EgzersizlerTable> {
  $$EgzersizlerTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ad =>
      $composableBuilder(column: $table.ad, builder: (column) => column);

  GeneratedColumn<String> get aciklama =>
      $composableBuilder(column: $table.aciklama, builder: (column) => column);

  GeneratedColumn<String> get tur =>
      $composableBuilder(column: $table.tur, builder: (column) => column);

  GeneratedColumn<int> get sureSaniye => $composableBuilder(
    column: $table.sureSaniye,
    builder: (column) => column,
  );

  GeneratedColumn<int> get setSayisi =>
      $composableBuilder(column: $table.setSayisi, builder: (column) => column);

  GeneratedColumn<int> get tekrarSayisi => $composableBuilder(
    column: $table.tekrarSayisi,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kategori =>
      $composableBuilder(column: $table.kategori, builder: (column) => column);

  GeneratedColumn<bool> get arsivlendiMi => $composableBuilder(
    column: $table.arsivlendiMi,
    builder: (column) => column,
  );

  Expression<T> rutinEgzersizleriRefs<T extends Object>(
    Expression<T> Function($$RutinEgzersizleriTableAnnotationComposer a) f,
  ) {
    final $$RutinEgzersizleriTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.rutinEgzersizleri,
          getReferencedColumn: (t) => t.egzersizId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RutinEgzersizleriTableAnnotationComposer(
                $db: $db,
                $table: $db.rutinEgzersizleri,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> egzersizKayitlariRefs<T extends Object>(
    Expression<T> Function($$EgzersizKayitlariTableAnnotationComposer a) f,
  ) {
    final $$EgzersizKayitlariTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.egzersizKayitlari,
          getReferencedColumn: (t) => t.egzersizId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EgzersizKayitlariTableAnnotationComposer(
                $db: $db,
                $table: $db.egzersizKayitlari,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$EgzersizlerTableTableManager
    extends
        RootTableManager<
          _$UygulamaVeritabani,
          $EgzersizlerTable,
          EgzersizlerData,
          $$EgzersizlerTableFilterComposer,
          $$EgzersizlerTableOrderingComposer,
          $$EgzersizlerTableAnnotationComposer,
          $$EgzersizlerTableCreateCompanionBuilder,
          $$EgzersizlerTableUpdateCompanionBuilder,
          (EgzersizlerData, $$EgzersizlerTableReferences),
          EgzersizlerData,
          PrefetchHooks Function({
            bool rutinEgzersizleriRefs,
            bool egzersizKayitlariRefs,
          })
        > {
  $$EgzersizlerTableTableManager(
    _$UygulamaVeritabani db,
    $EgzersizlerTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EgzersizlerTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EgzersizlerTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EgzersizlerTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> ad = const Value.absent(),
                Value<String> aciklama = const Value.absent(),
                Value<String> tur = const Value.absent(),
                Value<int?> sureSaniye = const Value.absent(),
                Value<int?> setSayisi = const Value.absent(),
                Value<int?> tekrarSayisi = const Value.absent(),
                Value<String> kategori = const Value.absent(),
                Value<bool> arsivlendiMi = const Value.absent(),
              }) => EgzersizlerCompanion(
                id: id,
                ad: ad,
                aciklama: aciklama,
                tur: tur,
                sureSaniye: sureSaniye,
                setSayisi: setSayisi,
                tekrarSayisi: tekrarSayisi,
                kategori: kategori,
                arsivlendiMi: arsivlendiMi,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String ad,
                Value<String> aciklama = const Value.absent(),
                required String tur,
                Value<int?> sureSaniye = const Value.absent(),
                Value<int?> setSayisi = const Value.absent(),
                Value<int?> tekrarSayisi = const Value.absent(),
                Value<String> kategori = const Value.absent(),
                Value<bool> arsivlendiMi = const Value.absent(),
              }) => EgzersizlerCompanion.insert(
                id: id,
                ad: ad,
                aciklama: aciklama,
                tur: tur,
                sureSaniye: sureSaniye,
                setSayisi: setSayisi,
                tekrarSayisi: tekrarSayisi,
                kategori: kategori,
                arsivlendiMi: arsivlendiMi,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EgzersizlerTable, EgzersizlerData>(table),
                  $$EgzersizlerTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({rutinEgzersizleriRefs = false, egzersizKayitlariRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (rutinEgzersizleriRefs) db.rutinEgzersizleri,
                    if (egzersizKayitlariRefs) db.egzersizKayitlari,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (rutinEgzersizleriRefs)
                        await $_getPrefetchedDataByColumns<
                          EgzersizlerData,
                          $EgzersizlerTable,
                          RutinEgzersizleriData,
                          $RutinEgzersizleriTable
                        >(
                          currentTable: table,
                          referencedTable: $$EgzersizlerTableReferences
                              ._rutinEgzersizleriRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EgzersizlerTableReferences(
                                db,
                                table,
                                p0,
                              ).rutinEgzersizleriRefs,
                          currentColumn: 'id',
                          referencedColumn: 'egzersiz_id',
                          typedResults: items,
                        ),
                      if (egzersizKayitlariRefs)
                        await $_getPrefetchedDataByColumns<
                          EgzersizlerData,
                          $EgzersizlerTable,
                          EgzersizKayitlariData,
                          $EgzersizKayitlariTable
                        >(
                          currentTable: table,
                          referencedTable: $$EgzersizlerTableReferences
                              ._egzersizKayitlariRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EgzersizlerTableReferences(
                                db,
                                table,
                                p0,
                              ).egzersizKayitlariRefs,
                          currentColumn: 'id',
                          referencedColumn: 'egzersiz_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EgzersizlerTableProcessedTableManager =
    ProcessedTableManager<
      _$UygulamaVeritabani,
      $EgzersizlerTable,
      EgzersizlerData,
      $$EgzersizlerTableFilterComposer,
      $$EgzersizlerTableOrderingComposer,
      $$EgzersizlerTableAnnotationComposer,
      $$EgzersizlerTableCreateCompanionBuilder,
      $$EgzersizlerTableUpdateCompanionBuilder,
      (EgzersizlerData, $$EgzersizlerTableReferences),
      EgzersizlerData,
      PrefetchHooks Function({
        bool rutinEgzersizleriRefs,
        bool egzersizKayitlariRefs,
      })
    >;
typedef $$RutinlerTableCreateCompanionBuilder = RutinlerCompanion Function({
  Value<int> id,
  required String ad,
  Value<String> haftaninGunleri,
  Value<bool> aktifMi,
  Value<String?> sadeceTarih,
  Value<bool> alarmAcikMi,
  Value<int> alarmSaati,
  Value<int> alarmDakikasi,
  Value<String?> alarmMuzikYolu,
  Value<String?> alarmMuzikAdi,
});
typedef $$RutinlerTableUpdateCompanionBuilder = RutinlerCompanion Function({
  Value<int> id,
  Value<String> ad,
  Value<String> haftaninGunleri,
  Value<bool> aktifMi,
  Value<String?> sadeceTarih,
  Value<bool> alarmAcikMi,
  Value<int> alarmSaati,
  Value<int> alarmDakikasi,
  Value<String?> alarmMuzikYolu,
  Value<String?> alarmMuzikAdi,
});

final class $$RutinlerTableReferences
    extends BaseReferences<_$UygulamaVeritabani, $RutinlerTable, RutinlerData> {
  $$RutinlerTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $RutinEgzersizleriTable,
    List<RutinEgzersizleriData>
  >
  _rutinEgzersizleriRefsTable(_$UygulamaVeritabani db) =>
      MultiTypedResultKey.fromTable(
        db.rutinEgzersizleri,
        aliasName: 'rutinler__id__rutin_egzersizleri__rutin_id',
      );

  $$RutinEgzersizleriTableProcessedTableManager get rutinEgzersizleriRefs {
    final manager = $$RutinEgzersizleriTableTableManager(
      $_db,
      $_db.rutinEgzersizleri,
    ).filter((f) => f.rutinId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _rutinEgzersizleriRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $AntrenmanKayitlariTable,
    List<AntrenmanKayitlariData>
  >
  _antrenmanKayitlariRefsTable(_$UygulamaVeritabani db) =>
      MultiTypedResultKey.fromTable(
        db.antrenmanKayitlari,
        aliasName: 'rutinler__id__antrenman_kayitlari__rutin_id',
      );

  $$AntrenmanKayitlariTableProcessedTableManager get antrenmanKayitlariRefs {
    final manager = $$AntrenmanKayitlariTableTableManager(
      $_db,
      $_db.antrenmanKayitlari,
    ).filter((f) => f.rutinId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _antrenmanKayitlariRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $EgzersizKayitlariTable,
    List<EgzersizKayitlariData>
  >
  _egzersizKayitlariRefsTable(_$UygulamaVeritabani db) =>
      MultiTypedResultKey.fromTable(
        db.egzersizKayitlari,
        aliasName: 'rutinler__id__egzersiz_kayitlari__rutin_id',
      );

  $$EgzersizKayitlariTableProcessedTableManager get egzersizKayitlariRefs {
    final manager = $$EgzersizKayitlariTableTableManager(
      $_db,
      $_db.egzersizKayitlari,
    ).filter((f) => f.rutinId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _egzersizKayitlariRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RutinlerTableFilterComposer
    extends Composer<_$UygulamaVeritabani, $RutinlerTable> {
  $$RutinlerTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ad => $composableBuilder(
    column: $table.ad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get haftaninGunleri => $composableBuilder(
    column: $table.haftaninGunleri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get aktifMi => $composableBuilder(
    column: $table.aktifMi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sadeceTarih => $composableBuilder(
    column: $table.sadeceTarih,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get alarmAcikMi => $composableBuilder(
    column: $table.alarmAcikMi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get alarmSaati => $composableBuilder(
    column: $table.alarmSaati,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get alarmDakikasi => $composableBuilder(
    column: $table.alarmDakikasi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alarmMuzikYolu => $composableBuilder(
    column: $table.alarmMuzikYolu,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alarmMuzikAdi => $composableBuilder(
    column: $table.alarmMuzikAdi,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> rutinEgzersizleriRefs(
    Expression<bool> Function($$RutinEgzersizleriTableFilterComposer f) f,
  ) {
    final $$RutinEgzersizleriTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rutinEgzersizleri,
      getReferencedColumn: (t) => t.rutinId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RutinEgzersizleriTableFilterComposer(
            $db: $db,
            $table: $db.rutinEgzersizleri,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> antrenmanKayitlariRefs(
    Expression<bool> Function($$AntrenmanKayitlariTableFilterComposer f) f,
  ) {
    final $$AntrenmanKayitlariTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.antrenmanKayitlari,
      getReferencedColumn: (t) => t.rutinId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AntrenmanKayitlariTableFilterComposer(
            $db: $db,
            $table: $db.antrenmanKayitlari,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> egzersizKayitlariRefs(
    Expression<bool> Function($$EgzersizKayitlariTableFilterComposer f) f,
  ) {
    final $$EgzersizKayitlariTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.egzersizKayitlari,
      getReferencedColumn: (t) => t.rutinId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EgzersizKayitlariTableFilterComposer(
            $db: $db,
            $table: $db.egzersizKayitlari,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RutinlerTableOrderingComposer
    extends Composer<_$UygulamaVeritabani, $RutinlerTable> {
  $$RutinlerTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ad => $composableBuilder(
    column: $table.ad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get haftaninGunleri => $composableBuilder(
    column: $table.haftaninGunleri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get aktifMi => $composableBuilder(
    column: $table.aktifMi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sadeceTarih => $composableBuilder(
    column: $table.sadeceTarih,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get alarmAcikMi => $composableBuilder(
    column: $table.alarmAcikMi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get alarmSaati => $composableBuilder(
    column: $table.alarmSaati,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get alarmDakikasi => $composableBuilder(
    column: $table.alarmDakikasi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alarmMuzikYolu => $composableBuilder(
    column: $table.alarmMuzikYolu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alarmMuzikAdi => $composableBuilder(
    column: $table.alarmMuzikAdi,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RutinlerTableAnnotationComposer
    extends Composer<_$UygulamaVeritabani, $RutinlerTable> {
  $$RutinlerTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ad =>
      $composableBuilder(column: $table.ad, builder: (column) => column);

  GeneratedColumn<String> get haftaninGunleri => $composableBuilder(
    column: $table.haftaninGunleri,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get aktifMi =>
      $composableBuilder(column: $table.aktifMi, builder: (column) => column);

  GeneratedColumn<String> get sadeceTarih => $composableBuilder(
    column: $table.sadeceTarih,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get alarmAcikMi => $composableBuilder(
    column: $table.alarmAcikMi,
    builder: (column) => column,
  );

  GeneratedColumn<int> get alarmSaati => $composableBuilder(
    column: $table.alarmSaati,
    builder: (column) => column,
  );

  GeneratedColumn<int> get alarmDakikasi => $composableBuilder(
    column: $table.alarmDakikasi,
    builder: (column) => column,
  );

  GeneratedColumn<String> get alarmMuzikYolu => $composableBuilder(
    column: $table.alarmMuzikYolu,
    builder: (column) => column,
  );

  GeneratedColumn<String> get alarmMuzikAdi => $composableBuilder(
    column: $table.alarmMuzikAdi,
    builder: (column) => column,
  );

  Expression<T> rutinEgzersizleriRefs<T extends Object>(
    Expression<T> Function($$RutinEgzersizleriTableAnnotationComposer a) f,
  ) {
    final $$RutinEgzersizleriTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.rutinEgzersizleri,
          getReferencedColumn: (t) => t.rutinId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RutinEgzersizleriTableAnnotationComposer(
                $db: $db,
                $table: $db.rutinEgzersizleri,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> antrenmanKayitlariRefs<T extends Object>(
    Expression<T> Function($$AntrenmanKayitlariTableAnnotationComposer a) f,
  ) {
    final $$AntrenmanKayitlariTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.antrenmanKayitlari,
          getReferencedColumn: (t) => t.rutinId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AntrenmanKayitlariTableAnnotationComposer(
                $db: $db,
                $table: $db.antrenmanKayitlari,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> egzersizKayitlariRefs<T extends Object>(
    Expression<T> Function($$EgzersizKayitlariTableAnnotationComposer a) f,
  ) {
    final $$EgzersizKayitlariTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.egzersizKayitlari,
          getReferencedColumn: (t) => t.rutinId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EgzersizKayitlariTableAnnotationComposer(
                $db: $db,
                $table: $db.egzersizKayitlari,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RutinlerTableTableManager
    extends
        RootTableManager<
          _$UygulamaVeritabani,
          $RutinlerTable,
          RutinlerData,
          $$RutinlerTableFilterComposer,
          $$RutinlerTableOrderingComposer,
          $$RutinlerTableAnnotationComposer,
          $$RutinlerTableCreateCompanionBuilder,
          $$RutinlerTableUpdateCompanionBuilder,
          (RutinlerData, $$RutinlerTableReferences),
          RutinlerData,
          PrefetchHooks Function({
            bool rutinEgzersizleriRefs,
            bool antrenmanKayitlariRefs,
            bool egzersizKayitlariRefs,
          })
        > {
  $$RutinlerTableTableManager(_$UygulamaVeritabani db, $RutinlerTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RutinlerTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RutinlerTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RutinlerTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> ad = const Value.absent(),
                Value<String> haftaninGunleri = const Value.absent(),
                Value<bool> aktifMi = const Value.absent(),
                Value<String?> sadeceTarih = const Value.absent(),
                Value<bool> alarmAcikMi = const Value.absent(),
                Value<int> alarmSaati = const Value.absent(),
                Value<int> alarmDakikasi = const Value.absent(),
                Value<String?> alarmMuzikYolu = const Value.absent(),
                Value<String?> alarmMuzikAdi = const Value.absent(),
              }) => RutinlerCompanion(
                id: id,
                ad: ad,
                haftaninGunleri: haftaninGunleri,
                aktifMi: aktifMi,
                sadeceTarih: sadeceTarih,
                alarmAcikMi: alarmAcikMi,
                alarmSaati: alarmSaati,
                alarmDakikasi: alarmDakikasi,
                alarmMuzikYolu: alarmMuzikYolu,
                alarmMuzikAdi: alarmMuzikAdi,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String ad,
                Value<String> haftaninGunleri = const Value.absent(),
                Value<bool> aktifMi = const Value.absent(),
                Value<String?> sadeceTarih = const Value.absent(),
                Value<bool> alarmAcikMi = const Value.absent(),
                Value<int> alarmSaati = const Value.absent(),
                Value<int> alarmDakikasi = const Value.absent(),
                Value<String?> alarmMuzikYolu = const Value.absent(),
                Value<String?> alarmMuzikAdi = const Value.absent(),
              }) => RutinlerCompanion.insert(
                id: id,
                ad: ad,
                haftaninGunleri: haftaninGunleri,
                aktifMi: aktifMi,
                sadeceTarih: sadeceTarih,
                alarmAcikMi: alarmAcikMi,
                alarmSaati: alarmSaati,
                alarmDakikasi: alarmDakikasi,
                alarmMuzikYolu: alarmMuzikYolu,
                alarmMuzikAdi: alarmMuzikAdi,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RutinlerTable, RutinlerData>(table),
                  $$RutinlerTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                rutinEgzersizleriRefs = false,
                antrenmanKayitlariRefs = false,
                egzersizKayitlariRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (rutinEgzersizleriRefs) db.rutinEgzersizleri,
                    if (antrenmanKayitlariRefs) db.antrenmanKayitlari,
                    if (egzersizKayitlariRefs) db.egzersizKayitlari,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (rutinEgzersizleriRefs)
                        await $_getPrefetchedDataByColumns<
                          RutinlerData,
                          $RutinlerTable,
                          RutinEgzersizleriData,
                          $RutinEgzersizleriTable
                        >(
                          currentTable: table,
                          referencedTable: $$RutinlerTableReferences
                              ._rutinEgzersizleriRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RutinlerTableReferences(
                                db,
                                table,
                                p0,
                              ).rutinEgzersizleriRefs,
                          currentColumn: 'id',
                          referencedColumn: 'rutin_id',
                          typedResults: items,
                        ),
                      if (antrenmanKayitlariRefs)
                        await $_getPrefetchedDataByColumns<
                          RutinlerData,
                          $RutinlerTable,
                          AntrenmanKayitlariData,
                          $AntrenmanKayitlariTable
                        >(
                          currentTable: table,
                          referencedTable: $$RutinlerTableReferences
                              ._antrenmanKayitlariRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RutinlerTableReferences(
                                db,
                                table,
                                p0,
                              ).antrenmanKayitlariRefs,
                          currentColumn: 'id',
                          referencedColumn: 'rutin_id',
                          typedResults: items,
                        ),
                      if (egzersizKayitlariRefs)
                        await $_getPrefetchedDataByColumns<
                          RutinlerData,
                          $RutinlerTable,
                          EgzersizKayitlariData,
                          $EgzersizKayitlariTable
                        >(
                          currentTable: table,
                          referencedTable: $$RutinlerTableReferences
                              ._egzersizKayitlariRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RutinlerTableReferences(
                                db,
                                table,
                                p0,
                              ).egzersizKayitlariRefs,
                          currentColumn: 'id',
                          referencedColumn: 'rutin_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RutinlerTableProcessedTableManager =
    ProcessedTableManager<
      _$UygulamaVeritabani,
      $RutinlerTable,
      RutinlerData,
      $$RutinlerTableFilterComposer,
      $$RutinlerTableOrderingComposer,
      $$RutinlerTableAnnotationComposer,
      $$RutinlerTableCreateCompanionBuilder,
      $$RutinlerTableUpdateCompanionBuilder,
      (RutinlerData, $$RutinlerTableReferences),
      RutinlerData,
      PrefetchHooks Function({
        bool rutinEgzersizleriRefs,
        bool antrenmanKayitlariRefs,
        bool egzersizKayitlariRefs,
      })
    >;
typedef $$RutinEgzersizleriTableCreateCompanionBuilder =
    RutinEgzersizleriCompanion Function({
      Value<int> id,
      required int rutinId,
      required int egzersizId,
      required int siraIndeksi,
    });
typedef $$RutinEgzersizleriTableUpdateCompanionBuilder =
    RutinEgzersizleriCompanion Function({
      Value<int> id,
      Value<int> rutinId,
      Value<int> egzersizId,
      Value<int> siraIndeksi,
    });

final class $$RutinEgzersizleriTableReferences
    extends
        BaseReferences<
          _$UygulamaVeritabani,
          $RutinEgzersizleriTable,
          RutinEgzersizleriData
        > {
  $$RutinEgzersizleriTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RutinlerTable _rutinIdTable(_$UygulamaVeritabani db) =>
      db.rutinler.createAlias('rutin_egzersizleri__rutin_id__rutinler__id');

  $$RutinlerTableProcessedTableManager get rutinId {
    final $_column = $_itemColumn<int>('rutin_id')!;

    final manager = $$RutinlerTableTableManager(
      $_db,
      $_db.rutinler,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rutinIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EgzersizlerTable _egzersizIdTable(_$UygulamaVeritabani db) => db
      .egzersizler
      .createAlias('rutin_egzersizleri__egzersiz_id__egzersizler__id');

  $$EgzersizlerTableProcessedTableManager get egzersizId {
    final $_column = $_itemColumn<int>('egzersiz_id')!;

    final manager = $$EgzersizlerTableTableManager(
      $_db,
      $_db.egzersizler,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_egzersizIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RutinEgzersizleriTableFilterComposer
    extends Composer<_$UygulamaVeritabani, $RutinEgzersizleriTable> {
  $$RutinEgzersizleriTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get siraIndeksi => $composableBuilder(
    column: $table.siraIndeksi,
    builder: (column) => ColumnFilters(column),
  );

  $$RutinlerTableFilterComposer get rutinId {
    final $$RutinlerTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rutinId,
      referencedTable: $db.rutinler,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RutinlerTableFilterComposer(
            $db: $db,
            $table: $db.rutinler,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EgzersizlerTableFilterComposer get egzersizId {
    final $$EgzersizlerTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.egzersizId,
      referencedTable: $db.egzersizler,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EgzersizlerTableFilterComposer(
            $db: $db,
            $table: $db.egzersizler,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RutinEgzersizleriTableOrderingComposer
    extends Composer<_$UygulamaVeritabani, $RutinEgzersizleriTable> {
  $$RutinEgzersizleriTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get siraIndeksi => $composableBuilder(
    column: $table.siraIndeksi,
    builder: (column) => ColumnOrderings(column),
  );

  $$RutinlerTableOrderingComposer get rutinId {
    final $$RutinlerTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rutinId,
      referencedTable: $db.rutinler,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RutinlerTableOrderingComposer(
            $db: $db,
            $table: $db.rutinler,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EgzersizlerTableOrderingComposer get egzersizId {
    final $$EgzersizlerTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.egzersizId,
      referencedTable: $db.egzersizler,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EgzersizlerTableOrderingComposer(
            $db: $db,
            $table: $db.egzersizler,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RutinEgzersizleriTableAnnotationComposer
    extends Composer<_$UygulamaVeritabani, $RutinEgzersizleriTable> {
  $$RutinEgzersizleriTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get siraIndeksi => $composableBuilder(
    column: $table.siraIndeksi,
    builder: (column) => column,
  );

  $$RutinlerTableAnnotationComposer get rutinId {
    final $$RutinlerTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rutinId,
      referencedTable: $db.rutinler,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RutinlerTableAnnotationComposer(
            $db: $db,
            $table: $db.rutinler,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EgzersizlerTableAnnotationComposer get egzersizId {
    final $$EgzersizlerTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.egzersizId,
      referencedTable: $db.egzersizler,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EgzersizlerTableAnnotationComposer(
            $db: $db,
            $table: $db.egzersizler,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RutinEgzersizleriTableTableManager
    extends
        RootTableManager<
          _$UygulamaVeritabani,
          $RutinEgzersizleriTable,
          RutinEgzersizleriData,
          $$RutinEgzersizleriTableFilterComposer,
          $$RutinEgzersizleriTableOrderingComposer,
          $$RutinEgzersizleriTableAnnotationComposer,
          $$RutinEgzersizleriTableCreateCompanionBuilder,
          $$RutinEgzersizleriTableUpdateCompanionBuilder,
          (RutinEgzersizleriData, $$RutinEgzersizleriTableReferences),
          RutinEgzersizleriData,
          PrefetchHooks Function({bool rutinId, bool egzersizId})
        > {
  $$RutinEgzersizleriTableTableManager(
    _$UygulamaVeritabani db,
    $RutinEgzersizleriTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RutinEgzersizleriTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RutinEgzersizleriTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RutinEgzersizleriTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> rutinId = const Value.absent(),
                Value<int> egzersizId = const Value.absent(),
                Value<int> siraIndeksi = const Value.absent(),
              }) => RutinEgzersizleriCompanion(
                id: id,
                rutinId: rutinId,
                egzersizId: egzersizId,
                siraIndeksi: siraIndeksi,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int rutinId,
                required int egzersizId,
                required int siraIndeksi,
              }) => RutinEgzersizleriCompanion.insert(
                id: id,
                rutinId: rutinId,
                egzersizId: egzersizId,
                siraIndeksi: siraIndeksi,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RutinEgzersizleriTable, RutinEgzersizleriData>(
                    table,
                  ),
                  $$RutinEgzersizleriTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({rutinId = false, egzersizId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (rutinId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.rutinId,
                        referencedTable: $$RutinEgzersizleriTableReferences
                            ._rutinIdTable(db),
                        referencedColumn: $$RutinEgzersizleriTableReferences
                            ._rutinIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (egzersizId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.egzersizId,
                        referencedTable: $$RutinEgzersizleriTableReferences
                            ._egzersizIdTable(db),
                        referencedColumn: $$RutinEgzersizleriTableReferences
                            ._egzersizIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RutinEgzersizleriTableProcessedTableManager =
    ProcessedTableManager<
      _$UygulamaVeritabani,
      $RutinEgzersizleriTable,
      RutinEgzersizleriData,
      $$RutinEgzersizleriTableFilterComposer,
      $$RutinEgzersizleriTableOrderingComposer,
      $$RutinEgzersizleriTableAnnotationComposer,
      $$RutinEgzersizleriTableCreateCompanionBuilder,
      $$RutinEgzersizleriTableUpdateCompanionBuilder,
      (RutinEgzersizleriData, $$RutinEgzersizleriTableReferences),
      RutinEgzersizleriData,
      PrefetchHooks Function({bool rutinId, bool egzersizId})
    >;
typedef $$AntrenmanKayitlariTableCreateCompanionBuilder =
    AntrenmanKayitlariCompanion Function({
      Value<int> id,
      required String tarih,
      Value<int?> rutinId,
    });
typedef $$AntrenmanKayitlariTableUpdateCompanionBuilder =
    AntrenmanKayitlariCompanion Function({
      Value<int> id,
      Value<String> tarih,
      Value<int?> rutinId,
    });

final class $$AntrenmanKayitlariTableReferences
    extends
        BaseReferences<
          _$UygulamaVeritabani,
          $AntrenmanKayitlariTable,
          AntrenmanKayitlariData
        > {
  $$AntrenmanKayitlariTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RutinlerTable _rutinIdTable(_$UygulamaVeritabani db) =>
      db.rutinler.createAlias('antrenman_kayitlari__rutin_id__rutinler__id');

  $$RutinlerTableProcessedTableManager? get rutinId {
    final $_column = $_itemColumn<int>('rutin_id');
    if ($_column == null) return null;
    final manager = $$RutinlerTableTableManager(
      $_db,
      $_db.rutinler,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rutinIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $EgzersizKayitlariTable,
    List<EgzersizKayitlariData>
  >
  _egzersizKayitlariRefsTable(_$UygulamaVeritabani db) =>
      MultiTypedResultKey.fromTable(
        db.egzersizKayitlari,
        aliasName:
            'antrenman_kayitlari__id__egzersiz_kayitlari__antrenman_kaydi_id',
      );

  $$EgzersizKayitlariTableProcessedTableManager get egzersizKayitlariRefs {
    final manager = $$EgzersizKayitlariTableTableManager(
      $_db,
      $_db.egzersizKayitlari,
    ).filter((f) => f.antrenmanKaydiId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _egzersizKayitlariRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AntrenmanKayitlariTableFilterComposer
    extends Composer<_$UygulamaVeritabani, $AntrenmanKayitlariTable> {
  $$AntrenmanKayitlariTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tarih => $composableBuilder(
    column: $table.tarih,
    builder: (column) => ColumnFilters(column),
  );

  $$RutinlerTableFilterComposer get rutinId {
    final $$RutinlerTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rutinId,
      referencedTable: $db.rutinler,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RutinlerTableFilterComposer(
            $db: $db,
            $table: $db.rutinler,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> egzersizKayitlariRefs(
    Expression<bool> Function($$EgzersizKayitlariTableFilterComposer f) f,
  ) {
    final $$EgzersizKayitlariTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.egzersizKayitlari,
      getReferencedColumn: (t) => t.antrenmanKaydiId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EgzersizKayitlariTableFilterComposer(
            $db: $db,
            $table: $db.egzersizKayitlari,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AntrenmanKayitlariTableOrderingComposer
    extends Composer<_$UygulamaVeritabani, $AntrenmanKayitlariTable> {
  $$AntrenmanKayitlariTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tarih => $composableBuilder(
    column: $table.tarih,
    builder: (column) => ColumnOrderings(column),
  );

  $$RutinlerTableOrderingComposer get rutinId {
    final $$RutinlerTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rutinId,
      referencedTable: $db.rutinler,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RutinlerTableOrderingComposer(
            $db: $db,
            $table: $db.rutinler,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AntrenmanKayitlariTableAnnotationComposer
    extends Composer<_$UygulamaVeritabani, $AntrenmanKayitlariTable> {
  $$AntrenmanKayitlariTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tarih =>
      $composableBuilder(column: $table.tarih, builder: (column) => column);

  $$RutinlerTableAnnotationComposer get rutinId {
    final $$RutinlerTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rutinId,
      referencedTable: $db.rutinler,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RutinlerTableAnnotationComposer(
            $db: $db,
            $table: $db.rutinler,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> egzersizKayitlariRefs<T extends Object>(
    Expression<T> Function($$EgzersizKayitlariTableAnnotationComposer a) f,
  ) {
    final $$EgzersizKayitlariTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.egzersizKayitlari,
          getReferencedColumn: (t) => t.antrenmanKaydiId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EgzersizKayitlariTableAnnotationComposer(
                $db: $db,
                $table: $db.egzersizKayitlari,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AntrenmanKayitlariTableTableManager
    extends
        RootTableManager<
          _$UygulamaVeritabani,
          $AntrenmanKayitlariTable,
          AntrenmanKayitlariData,
          $$AntrenmanKayitlariTableFilterComposer,
          $$AntrenmanKayitlariTableOrderingComposer,
          $$AntrenmanKayitlariTableAnnotationComposer,
          $$AntrenmanKayitlariTableCreateCompanionBuilder,
          $$AntrenmanKayitlariTableUpdateCompanionBuilder,
          (AntrenmanKayitlariData, $$AntrenmanKayitlariTableReferences),
          AntrenmanKayitlariData,
          PrefetchHooks Function({bool rutinId, bool egzersizKayitlariRefs})
        > {
  $$AntrenmanKayitlariTableTableManager(
    _$UygulamaVeritabani db,
    $AntrenmanKayitlariTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AntrenmanKayitlariTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AntrenmanKayitlariTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AntrenmanKayitlariTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> tarih = const Value.absent(),
                Value<int?> rutinId = const Value.absent(),
              }) => AntrenmanKayitlariCompanion(
                id: id,
                tarih: tarih,
                rutinId: rutinId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String tarih,
                Value<int?> rutinId = const Value.absent(),
              }) => AntrenmanKayitlariCompanion.insert(
                id: id,
                tarih: tarih,
                rutinId: rutinId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AntrenmanKayitlariTable, AntrenmanKayitlariData>(
                    table,
                  ),
                  $$AntrenmanKayitlariTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({rutinId = false, egzersizKayitlariRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (egzersizKayitlariRefs) db.egzersizKayitlari,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (rutinId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.rutinId,
                            referencedTable: $$AntrenmanKayitlariTableReferences
                                ._rutinIdTable(db),
                            referencedColumn:
                                $$AntrenmanKayitlariTableReferences
                                    ._rutinIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (egzersizKayitlariRefs)
                        await $_getPrefetchedDataByColumns<
                          AntrenmanKayitlariData,
                          $AntrenmanKayitlariTable,
                          EgzersizKayitlariData,
                          $EgzersizKayitlariTable
                        >(
                          currentTable: table,
                          referencedTable: $$AntrenmanKayitlariTableReferences
                              ._egzersizKayitlariRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AntrenmanKayitlariTableReferences(
                                db,
                                table,
                                p0,
                              ).egzersizKayitlariRefs,
                          currentColumn: 'id',
                          referencedColumn: 'antrenman_kaydi_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AntrenmanKayitlariTableProcessedTableManager =
    ProcessedTableManager<
      _$UygulamaVeritabani,
      $AntrenmanKayitlariTable,
      AntrenmanKayitlariData,
      $$AntrenmanKayitlariTableFilterComposer,
      $$AntrenmanKayitlariTableOrderingComposer,
      $$AntrenmanKayitlariTableAnnotationComposer,
      $$AntrenmanKayitlariTableCreateCompanionBuilder,
      $$AntrenmanKayitlariTableUpdateCompanionBuilder,
      (AntrenmanKayitlariData, $$AntrenmanKayitlariTableReferences),
      AntrenmanKayitlariData,
      PrefetchHooks Function({bool rutinId, bool egzersizKayitlariRefs})
    >;
typedef $$EgzersizKayitlariTableCreateCompanionBuilder =
    EgzersizKayitlariCompanion Function({
      Value<int> id,
      required int antrenmanKaydiId,
      required int egzersizId,
      Value<int?> rutinId,
      required String egzersizAdiKopyasi,
      Value<String> durum,
      Value<String?> notMetni,
    });
typedef $$EgzersizKayitlariTableUpdateCompanionBuilder =
    EgzersizKayitlariCompanion Function({
      Value<int> id,
      Value<int> antrenmanKaydiId,
      Value<int> egzersizId,
      Value<int?> rutinId,
      Value<String> egzersizAdiKopyasi,
      Value<String> durum,
      Value<String?> notMetni,
    });

final class $$EgzersizKayitlariTableReferences
    extends
        BaseReferences<
          _$UygulamaVeritabani,
          $EgzersizKayitlariTable,
          EgzersizKayitlariData
        > {
  $$EgzersizKayitlariTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AntrenmanKayitlariTable _antrenmanKaydiIdTable(
    _$UygulamaVeritabani db,
  ) => db.antrenmanKayitlari.createAlias(
    'egzersiz_kayitlari__antrenman_kaydi_id__antrenman_kayitlari__id',
  );

  $$AntrenmanKayitlariTableProcessedTableManager get antrenmanKaydiId {
    final $_column = $_itemColumn<int>('antrenman_kaydi_id')!;

    final manager = $$AntrenmanKayitlariTableTableManager(
      $_db,
      $_db.antrenmanKayitlari,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_antrenmanKaydiIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EgzersizlerTable _egzersizIdTable(_$UygulamaVeritabani db) => db
      .egzersizler
      .createAlias('egzersiz_kayitlari__egzersiz_id__egzersizler__id');

  $$EgzersizlerTableProcessedTableManager get egzersizId {
    final $_column = $_itemColumn<int>('egzersiz_id')!;

    final manager = $$EgzersizlerTableTableManager(
      $_db,
      $_db.egzersizler,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_egzersizIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RutinlerTable _rutinIdTable(_$UygulamaVeritabani db) =>
      db.rutinler.createAlias('egzersiz_kayitlari__rutin_id__rutinler__id');

  $$RutinlerTableProcessedTableManager? get rutinId {
    final $_column = $_itemColumn<int>('rutin_id');
    if ($_column == null) return null;
    final manager = $$RutinlerTableTableManager(
      $_db,
      $_db.rutinler,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rutinIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EgzersizKayitlariTableFilterComposer
    extends Composer<_$UygulamaVeritabani, $EgzersizKayitlariTable> {
  $$EgzersizKayitlariTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get egzersizAdiKopyasi => $composableBuilder(
    column: $table.egzersizAdiKopyasi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get durum => $composableBuilder(
    column: $table.durum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notMetni => $composableBuilder(
    column: $table.notMetni,
    builder: (column) => ColumnFilters(column),
  );

  $$AntrenmanKayitlariTableFilterComposer get antrenmanKaydiId {
    final $$AntrenmanKayitlariTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.antrenmanKaydiId,
      referencedTable: $db.antrenmanKayitlari,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AntrenmanKayitlariTableFilterComposer(
            $db: $db,
            $table: $db.antrenmanKayitlari,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EgzersizlerTableFilterComposer get egzersizId {
    final $$EgzersizlerTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.egzersizId,
      referencedTable: $db.egzersizler,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EgzersizlerTableFilterComposer(
            $db: $db,
            $table: $db.egzersizler,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RutinlerTableFilterComposer get rutinId {
    final $$RutinlerTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rutinId,
      referencedTable: $db.rutinler,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RutinlerTableFilterComposer(
            $db: $db,
            $table: $db.rutinler,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EgzersizKayitlariTableOrderingComposer
    extends Composer<_$UygulamaVeritabani, $EgzersizKayitlariTable> {
  $$EgzersizKayitlariTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get egzersizAdiKopyasi => $composableBuilder(
    column: $table.egzersizAdiKopyasi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get durum => $composableBuilder(
    column: $table.durum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notMetni => $composableBuilder(
    column: $table.notMetni,
    builder: (column) => ColumnOrderings(column),
  );

  $$AntrenmanKayitlariTableOrderingComposer get antrenmanKaydiId {
    final $$AntrenmanKayitlariTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.antrenmanKaydiId,
      referencedTable: $db.antrenmanKayitlari,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AntrenmanKayitlariTableOrderingComposer(
            $db: $db,
            $table: $db.antrenmanKayitlari,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EgzersizlerTableOrderingComposer get egzersizId {
    final $$EgzersizlerTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.egzersizId,
      referencedTable: $db.egzersizler,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EgzersizlerTableOrderingComposer(
            $db: $db,
            $table: $db.egzersizler,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RutinlerTableOrderingComposer get rutinId {
    final $$RutinlerTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rutinId,
      referencedTable: $db.rutinler,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RutinlerTableOrderingComposer(
            $db: $db,
            $table: $db.rutinler,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EgzersizKayitlariTableAnnotationComposer
    extends Composer<_$UygulamaVeritabani, $EgzersizKayitlariTable> {
  $$EgzersizKayitlariTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get egzersizAdiKopyasi => $composableBuilder(
    column: $table.egzersizAdiKopyasi,
    builder: (column) => column,
  );

  GeneratedColumn<String> get durum =>
      $composableBuilder(column: $table.durum, builder: (column) => column);

  GeneratedColumn<String> get notMetni =>
      $composableBuilder(column: $table.notMetni, builder: (column) => column);

  $$AntrenmanKayitlariTableAnnotationComposer get antrenmanKaydiId {
    final $$AntrenmanKayitlariTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.antrenmanKaydiId,
          referencedTable: $db.antrenmanKayitlari,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AntrenmanKayitlariTableAnnotationComposer(
                $db: $db,
                $table: $db.antrenmanKayitlari,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$EgzersizlerTableAnnotationComposer get egzersizId {
    final $$EgzersizlerTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.egzersizId,
      referencedTable: $db.egzersizler,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EgzersizlerTableAnnotationComposer(
            $db: $db,
            $table: $db.egzersizler,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RutinlerTableAnnotationComposer get rutinId {
    final $$RutinlerTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rutinId,
      referencedTable: $db.rutinler,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RutinlerTableAnnotationComposer(
            $db: $db,
            $table: $db.rutinler,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EgzersizKayitlariTableTableManager
    extends
        RootTableManager<
          _$UygulamaVeritabani,
          $EgzersizKayitlariTable,
          EgzersizKayitlariData,
          $$EgzersizKayitlariTableFilterComposer,
          $$EgzersizKayitlariTableOrderingComposer,
          $$EgzersizKayitlariTableAnnotationComposer,
          $$EgzersizKayitlariTableCreateCompanionBuilder,
          $$EgzersizKayitlariTableUpdateCompanionBuilder,
          (EgzersizKayitlariData, $$EgzersizKayitlariTableReferences),
          EgzersizKayitlariData,
          PrefetchHooks Function({
            bool antrenmanKaydiId,
            bool egzersizId,
            bool rutinId,
          })
        > {
  $$EgzersizKayitlariTableTableManager(
    _$UygulamaVeritabani db,
    $EgzersizKayitlariTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EgzersizKayitlariTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EgzersizKayitlariTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EgzersizKayitlariTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> antrenmanKaydiId = const Value.absent(),
                Value<int> egzersizId = const Value.absent(),
                Value<int?> rutinId = const Value.absent(),
                Value<String> egzersizAdiKopyasi = const Value.absent(),
                Value<String> durum = const Value.absent(),
                Value<String?> notMetni = const Value.absent(),
              }) => EgzersizKayitlariCompanion(
                id: id,
                antrenmanKaydiId: antrenmanKaydiId,
                egzersizId: egzersizId,
                rutinId: rutinId,
                egzersizAdiKopyasi: egzersizAdiKopyasi,
                durum: durum,
                notMetni: notMetni,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int antrenmanKaydiId,
                required int egzersizId,
                Value<int?> rutinId = const Value.absent(),
                required String egzersizAdiKopyasi,
                Value<String> durum = const Value.absent(),
                Value<String?> notMetni = const Value.absent(),
              }) => EgzersizKayitlariCompanion.insert(
                id: id,
                antrenmanKaydiId: antrenmanKaydiId,
                egzersizId: egzersizId,
                rutinId: rutinId,
                egzersizAdiKopyasi: egzersizAdiKopyasi,
                durum: durum,
                notMetni: notMetni,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EgzersizKayitlariTable, EgzersizKayitlariData>(
                    table,
                  ),
                  $$EgzersizKayitlariTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                antrenmanKaydiId = false,
                egzersizId = false,
                rutinId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (antrenmanKaydiId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.antrenmanKaydiId,
                            referencedTable: $$EgzersizKayitlariTableReferences
                                ._antrenmanKaydiIdTable(db),
                            referencedColumn: $$EgzersizKayitlariTableReferences
                                ._antrenmanKaydiIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (egzersizId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.egzersizId,
                            referencedTable: $$EgzersizKayitlariTableReferences
                                ._egzersizIdTable(db),
                            referencedColumn: $$EgzersizKayitlariTableReferences
                                ._egzersizIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (rutinId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.rutinId,
                            referencedTable: $$EgzersizKayitlariTableReferences
                                ._rutinIdTable(db),
                            referencedColumn: $$EgzersizKayitlariTableReferences
                                ._rutinIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$EgzersizKayitlariTableProcessedTableManager =
    ProcessedTableManager<
      _$UygulamaVeritabani,
      $EgzersizKayitlariTable,
      EgzersizKayitlariData,
      $$EgzersizKayitlariTableFilterComposer,
      $$EgzersizKayitlariTableOrderingComposer,
      $$EgzersizKayitlariTableAnnotationComposer,
      $$EgzersizKayitlariTableCreateCompanionBuilder,
      $$EgzersizKayitlariTableUpdateCompanionBuilder,
      (EgzersizKayitlariData, $$EgzersizKayitlariTableReferences),
      EgzersizKayitlariData,
      PrefetchHooks Function({
        bool antrenmanKaydiId,
        bool egzersizId,
        bool rutinId,
      })
    >;
typedef $$HatirlaticilarTableCreateCompanionBuilder =
    HatirlaticilarCompanion Function({
      Value<int> id,
      required String etiket,
      required int saat,
      required int dakika,
      Value<String> haftaninGunleri,
      Value<bool> etkinMi,
    });
typedef $$HatirlaticilarTableUpdateCompanionBuilder =
    HatirlaticilarCompanion Function({
      Value<int> id,
      Value<String> etiket,
      Value<int> saat,
      Value<int> dakika,
      Value<String> haftaninGunleri,
      Value<bool> etkinMi,
    });

class $$HatirlaticilarTableFilterComposer
    extends Composer<_$UygulamaVeritabani, $HatirlaticilarTable> {
  $$HatirlaticilarTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get etiket => $composableBuilder(
    column: $table.etiket,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get saat => $composableBuilder(
    column: $table.saat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dakika => $composableBuilder(
    column: $table.dakika,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get haftaninGunleri => $composableBuilder(
    column: $table.haftaninGunleri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get etkinMi => $composableBuilder(
    column: $table.etkinMi,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HatirlaticilarTableOrderingComposer
    extends Composer<_$UygulamaVeritabani, $HatirlaticilarTable> {
  $$HatirlaticilarTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get etiket => $composableBuilder(
    column: $table.etiket,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get saat => $composableBuilder(
    column: $table.saat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dakika => $composableBuilder(
    column: $table.dakika,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get haftaninGunleri => $composableBuilder(
    column: $table.haftaninGunleri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get etkinMi => $composableBuilder(
    column: $table.etkinMi,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HatirlaticilarTableAnnotationComposer
    extends Composer<_$UygulamaVeritabani, $HatirlaticilarTable> {
  $$HatirlaticilarTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get etiket =>
      $composableBuilder(column: $table.etiket, builder: (column) => column);

  GeneratedColumn<int> get saat =>
      $composableBuilder(column: $table.saat, builder: (column) => column);

  GeneratedColumn<int> get dakika =>
      $composableBuilder(column: $table.dakika, builder: (column) => column);

  GeneratedColumn<String> get haftaninGunleri => $composableBuilder(
    column: $table.haftaninGunleri,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get etkinMi =>
      $composableBuilder(column: $table.etkinMi, builder: (column) => column);
}

class $$HatirlaticilarTableTableManager
    extends
        RootTableManager<
          _$UygulamaVeritabani,
          $HatirlaticilarTable,
          HatirlaticilarData,
          $$HatirlaticilarTableFilterComposer,
          $$HatirlaticilarTableOrderingComposer,
          $$HatirlaticilarTableAnnotationComposer,
          $$HatirlaticilarTableCreateCompanionBuilder,
          $$HatirlaticilarTableUpdateCompanionBuilder,
          (
            HatirlaticilarData,
            BaseReferences<
              _$UygulamaVeritabani,
              $HatirlaticilarTable,
              HatirlaticilarData
            >,
          ),
          HatirlaticilarData,
          PrefetchHooks Function()
        > {
  $$HatirlaticilarTableTableManager(
    _$UygulamaVeritabani db,
    $HatirlaticilarTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HatirlaticilarTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HatirlaticilarTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HatirlaticilarTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> etiket = const Value.absent(),
                Value<int> saat = const Value.absent(),
                Value<int> dakika = const Value.absent(),
                Value<String> haftaninGunleri = const Value.absent(),
                Value<bool> etkinMi = const Value.absent(),
              }) => HatirlaticilarCompanion(
                id: id,
                etiket: etiket,
                saat: saat,
                dakika: dakika,
                haftaninGunleri: haftaninGunleri,
                etkinMi: etkinMi,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String etiket,
                required int saat,
                required int dakika,
                Value<String> haftaninGunleri = const Value.absent(),
                Value<bool> etkinMi = const Value.absent(),
              }) => HatirlaticilarCompanion.insert(
                id: id,
                etiket: etiket,
                saat: saat,
                dakika: dakika,
                haftaninGunleri: haftaninGunleri,
                etkinMi: etkinMi,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HatirlaticilarTable, HatirlaticilarData>(table),
                  BaseReferences<
                    _$UygulamaVeritabani,
                    $HatirlaticilarTable,
                    HatirlaticilarData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HatirlaticilarTableProcessedTableManager =
    ProcessedTableManager<
      _$UygulamaVeritabani,
      $HatirlaticilarTable,
      HatirlaticilarData,
      $$HatirlaticilarTableFilterComposer,
      $$HatirlaticilarTableOrderingComposer,
      $$HatirlaticilarTableAnnotationComposer,
      $$HatirlaticilarTableCreateCompanionBuilder,
      $$HatirlaticilarTableUpdateCompanionBuilder,
      (
        HatirlaticilarData,
        BaseReferences<
          _$UygulamaVeritabani,
          $HatirlaticilarTable,
          HatirlaticilarData
        >,
      ),
      HatirlaticilarData,
      PrefetchHooks Function()
    >;

class $UygulamaVeritabaniManager {
  final _$UygulamaVeritabani _db;
  $UygulamaVeritabaniManager(this._db);
  $$EgzersizlerTableTableManager get egzersizler =>
      $$EgzersizlerTableTableManager(_db, _db.egzersizler);
  $$RutinlerTableTableManager get rutinler =>
      $$RutinlerTableTableManager(_db, _db.rutinler);
  $$RutinEgzersizleriTableTableManager get rutinEgzersizleri =>
      $$RutinEgzersizleriTableTableManager(_db, _db.rutinEgzersizleri);
  $$AntrenmanKayitlariTableTableManager get antrenmanKayitlari =>
      $$AntrenmanKayitlariTableTableManager(_db, _db.antrenmanKayitlari);
  $$EgzersizKayitlariTableTableManager get egzersizKayitlari =>
      $$EgzersizKayitlariTableTableManager(_db, _db.egzersizKayitlari);
  $$HatirlaticilarTableTableManager get hatirlaticilar =>
      $$HatirlaticilarTableTableManager(_db, _db.hatirlaticilar);
}
