// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LiveCategoriesTable extends LiveCategories
    with TableInfo<$LiveCategoriesTable, LiveCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LiveCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountKeyMeta = const VerificationMeta(
    'accountKey',
  );
  @override
  late final GeneratedColumn<String> accountKey = GeneratedColumn<String>(
    'account_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [accountKey, id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'live_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<LiveCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_key')) {
      context.handle(
        _accountKeyMeta,
        accountKey.isAcceptableOrUnknown(data['account_key']!, _accountKeyMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountKey, id};
  @override
  LiveCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LiveCategory(
      accountKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_key'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $LiveCategoriesTable createAlias(String alias) {
    return $LiveCategoriesTable(attachedDatabase, alias);
  }
}

class LiveCategory extends DataClass implements Insertable<LiveCategory> {
  /// Id de la cuenta (fingerprint) a la que pertenece la fila.
  final String accountKey;
  final int id;
  final String name;
  const LiveCategory({
    required this.accountKey,
    required this.id,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_key'] = Variable<String>(accountKey);
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  LiveCategoriesCompanion toCompanion(bool nullToAbsent) {
    return LiveCategoriesCompanion(
      accountKey: Value(accountKey),
      id: Value(id),
      name: Value(name),
    );
  }

  factory LiveCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LiveCategory(
      accountKey: serializer.fromJson<String>(json['accountKey']),
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountKey': serializer.toJson<String>(accountKey),
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  LiveCategory copyWith({String? accountKey, int? id, String? name}) =>
      LiveCategory(
        accountKey: accountKey ?? this.accountKey,
        id: id ?? this.id,
        name: name ?? this.name,
      );
  LiveCategory copyWithCompanion(LiveCategoriesCompanion data) {
    return LiveCategory(
      accountKey: data.accountKey.present
          ? data.accountKey.value
          : this.accountKey,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LiveCategory(')
          ..write('accountKey: $accountKey, ')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(accountKey, id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LiveCategory &&
          other.accountKey == this.accountKey &&
          other.id == this.id &&
          other.name == this.name);
}

class LiveCategoriesCompanion extends UpdateCompanion<LiveCategory> {
  final Value<String> accountKey;
  final Value<int> id;
  final Value<String> name;
  final Value<int> rowid;
  const LiveCategoriesCompanion({
    this.accountKey = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LiveCategoriesCompanion.insert({
    this.accountKey = const Value.absent(),
    required int id,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<LiveCategory> custom({
    Expression<String>? accountKey,
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountKey != null) 'account_key': accountKey,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LiveCategoriesCompanion copyWith({
    Value<String>? accountKey,
    Value<int>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return LiveCategoriesCompanion(
      accountKey: accountKey ?? this.accountKey,
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountKey.present) {
      map['account_key'] = Variable<String>(accountKey.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LiveCategoriesCompanion(')
          ..write('accountKey: $accountKey, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LiveChannelsTable extends LiveChannels
    with TableInfo<$LiveChannelsTable, LiveChannel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LiveChannelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountKeyMeta = const VerificationMeta(
    'accountKey',
  );
  @override
  late final GeneratedColumn<String> accountKey = GeneratedColumn<String>(
    'account_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
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
  static const VerificationMeta _streamIdMeta = const VerificationMeta(
    'streamId',
  );
  @override
  late final GeneratedColumn<int> streamId = GeneratedColumn<int>(
    'stream_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _logoMeta = const VerificationMeta('logo');
  @override
  late final GeneratedColumn<String> logo = GeneratedColumn<String>(
    'logo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _epgChannelIdMeta = const VerificationMeta(
    'epgChannelId',
  );
  @override
  late final GeneratedColumn<String> epgChannelId = GeneratedColumn<String>(
    'epg_channel_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasArchiveMeta = const VerificationMeta(
    'hasArchive',
  );
  @override
  late final GeneratedColumn<bool> hasArchive = GeneratedColumn<bool>(
    'has_archive',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_archive" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _archiveDurationDaysMeta =
      const VerificationMeta('archiveDurationDays');
  @override
  late final GeneratedColumn<int> archiveDurationDays = GeneratedColumn<int>(
    'archive_duration_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    accountKey,
    id,
    streamId,
    name,
    categoryId,
    number,
    logo,
    epgChannelId,
    hasArchive,
    archiveDurationDays,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'live_channels';
  @override
  VerificationContext validateIntegrity(
    Insertable<LiveChannel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_key')) {
      context.handle(
        _accountKeyMeta,
        accountKey.isAcceptableOrUnknown(data['account_key']!, _accountKeyMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('stream_id')) {
      context.handle(
        _streamIdMeta,
        streamId.isAcceptableOrUnknown(data['stream_id']!, _streamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_streamIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('logo')) {
      context.handle(
        _logoMeta,
        logo.isAcceptableOrUnknown(data['logo']!, _logoMeta),
      );
    }
    if (data.containsKey('epg_channel_id')) {
      context.handle(
        _epgChannelIdMeta,
        epgChannelId.isAcceptableOrUnknown(
          data['epg_channel_id']!,
          _epgChannelIdMeta,
        ),
      );
    }
    if (data.containsKey('has_archive')) {
      context.handle(
        _hasArchiveMeta,
        hasArchive.isAcceptableOrUnknown(data['has_archive']!, _hasArchiveMeta),
      );
    }
    if (data.containsKey('archive_duration_days')) {
      context.handle(
        _archiveDurationDaysMeta,
        archiveDurationDays.isAcceptableOrUnknown(
          data['archive_duration_days']!,
          _archiveDurationDaysMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LiveChannel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LiveChannel(
      accountKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_key'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      streamId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stream_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      ),
      logo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo'],
      ),
      epgChannelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}epg_channel_id'],
      ),
      hasArchive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_archive'],
      )!,
      archiveDurationDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}archive_duration_days'],
      ),
    );
  }

  @override
  $LiveChannelsTable createAlias(String alias) {
    return $LiveChannelsTable(attachedDatabase, alias);
  }
}

class LiveChannel extends DataClass implements Insertable<LiveChannel> {
  /// Id de la cuenta (fingerprint) a la que pertenece la fila.
  final String accountKey;
  final int id;
  final int streamId;
  final String name;
  final int categoryId;
  final int? number;
  final String? logo;
  final String? epgChannelId;
  final bool hasArchive;
  final int? archiveDurationDays;
  const LiveChannel({
    required this.accountKey,
    required this.id,
    required this.streamId,
    required this.name,
    required this.categoryId,
    this.number,
    this.logo,
    this.epgChannelId,
    required this.hasArchive,
    this.archiveDurationDays,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_key'] = Variable<String>(accountKey);
    map['id'] = Variable<int>(id);
    map['stream_id'] = Variable<int>(streamId);
    map['name'] = Variable<String>(name);
    map['category_id'] = Variable<int>(categoryId);
    if (!nullToAbsent || number != null) {
      map['number'] = Variable<int>(number);
    }
    if (!nullToAbsent || logo != null) {
      map['logo'] = Variable<String>(logo);
    }
    if (!nullToAbsent || epgChannelId != null) {
      map['epg_channel_id'] = Variable<String>(epgChannelId);
    }
    map['has_archive'] = Variable<bool>(hasArchive);
    if (!nullToAbsent || archiveDurationDays != null) {
      map['archive_duration_days'] = Variable<int>(archiveDurationDays);
    }
    return map;
  }

  LiveChannelsCompanion toCompanion(bool nullToAbsent) {
    return LiveChannelsCompanion(
      accountKey: Value(accountKey),
      id: Value(id),
      streamId: Value(streamId),
      name: Value(name),
      categoryId: Value(categoryId),
      number: number == null && nullToAbsent
          ? const Value.absent()
          : Value(number),
      logo: logo == null && nullToAbsent ? const Value.absent() : Value(logo),
      epgChannelId: epgChannelId == null && nullToAbsent
          ? const Value.absent()
          : Value(epgChannelId),
      hasArchive: Value(hasArchive),
      archiveDurationDays: archiveDurationDays == null && nullToAbsent
          ? const Value.absent()
          : Value(archiveDurationDays),
    );
  }

  factory LiveChannel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LiveChannel(
      accountKey: serializer.fromJson<String>(json['accountKey']),
      id: serializer.fromJson<int>(json['id']),
      streamId: serializer.fromJson<int>(json['streamId']),
      name: serializer.fromJson<String>(json['name']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      number: serializer.fromJson<int?>(json['number']),
      logo: serializer.fromJson<String?>(json['logo']),
      epgChannelId: serializer.fromJson<String?>(json['epgChannelId']),
      hasArchive: serializer.fromJson<bool>(json['hasArchive']),
      archiveDurationDays: serializer.fromJson<int?>(
        json['archiveDurationDays'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountKey': serializer.toJson<String>(accountKey),
      'id': serializer.toJson<int>(id),
      'streamId': serializer.toJson<int>(streamId),
      'name': serializer.toJson<String>(name),
      'categoryId': serializer.toJson<int>(categoryId),
      'number': serializer.toJson<int?>(number),
      'logo': serializer.toJson<String?>(logo),
      'epgChannelId': serializer.toJson<String?>(epgChannelId),
      'hasArchive': serializer.toJson<bool>(hasArchive),
      'archiveDurationDays': serializer.toJson<int?>(archiveDurationDays),
    };
  }

  LiveChannel copyWith({
    String? accountKey,
    int? id,
    int? streamId,
    String? name,
    int? categoryId,
    Value<int?> number = const Value.absent(),
    Value<String?> logo = const Value.absent(),
    Value<String?> epgChannelId = const Value.absent(),
    bool? hasArchive,
    Value<int?> archiveDurationDays = const Value.absent(),
  }) => LiveChannel(
    accountKey: accountKey ?? this.accountKey,
    id: id ?? this.id,
    streamId: streamId ?? this.streamId,
    name: name ?? this.name,
    categoryId: categoryId ?? this.categoryId,
    number: number.present ? number.value : this.number,
    logo: logo.present ? logo.value : this.logo,
    epgChannelId: epgChannelId.present ? epgChannelId.value : this.epgChannelId,
    hasArchive: hasArchive ?? this.hasArchive,
    archiveDurationDays: archiveDurationDays.present
        ? archiveDurationDays.value
        : this.archiveDurationDays,
  );
  LiveChannel copyWithCompanion(LiveChannelsCompanion data) {
    return LiveChannel(
      accountKey: data.accountKey.present
          ? data.accountKey.value
          : this.accountKey,
      id: data.id.present ? data.id.value : this.id,
      streamId: data.streamId.present ? data.streamId.value : this.streamId,
      name: data.name.present ? data.name.value : this.name,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      number: data.number.present ? data.number.value : this.number,
      logo: data.logo.present ? data.logo.value : this.logo,
      epgChannelId: data.epgChannelId.present
          ? data.epgChannelId.value
          : this.epgChannelId,
      hasArchive: data.hasArchive.present
          ? data.hasArchive.value
          : this.hasArchive,
      archiveDurationDays: data.archiveDurationDays.present
          ? data.archiveDurationDays.value
          : this.archiveDurationDays,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LiveChannel(')
          ..write('accountKey: $accountKey, ')
          ..write('id: $id, ')
          ..write('streamId: $streamId, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('number: $number, ')
          ..write('logo: $logo, ')
          ..write('epgChannelId: $epgChannelId, ')
          ..write('hasArchive: $hasArchive, ')
          ..write('archiveDurationDays: $archiveDurationDays')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    accountKey,
    id,
    streamId,
    name,
    categoryId,
    number,
    logo,
    epgChannelId,
    hasArchive,
    archiveDurationDays,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LiveChannel &&
          other.accountKey == this.accountKey &&
          other.id == this.id &&
          other.streamId == this.streamId &&
          other.name == this.name &&
          other.categoryId == this.categoryId &&
          other.number == this.number &&
          other.logo == this.logo &&
          other.epgChannelId == this.epgChannelId &&
          other.hasArchive == this.hasArchive &&
          other.archiveDurationDays == this.archiveDurationDays);
}

class LiveChannelsCompanion extends UpdateCompanion<LiveChannel> {
  final Value<String> accountKey;
  final Value<int> id;
  final Value<int> streamId;
  final Value<String> name;
  final Value<int> categoryId;
  final Value<int?> number;
  final Value<String?> logo;
  final Value<String?> epgChannelId;
  final Value<bool> hasArchive;
  final Value<int?> archiveDurationDays;
  const LiveChannelsCompanion({
    this.accountKey = const Value.absent(),
    this.id = const Value.absent(),
    this.streamId = const Value.absent(),
    this.name = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.number = const Value.absent(),
    this.logo = const Value.absent(),
    this.epgChannelId = const Value.absent(),
    this.hasArchive = const Value.absent(),
    this.archiveDurationDays = const Value.absent(),
  });
  LiveChannelsCompanion.insert({
    this.accountKey = const Value.absent(),
    this.id = const Value.absent(),
    required int streamId,
    required String name,
    required int categoryId,
    this.number = const Value.absent(),
    this.logo = const Value.absent(),
    this.epgChannelId = const Value.absent(),
    this.hasArchive = const Value.absent(),
    this.archiveDurationDays = const Value.absent(),
  }) : streamId = Value(streamId),
       name = Value(name),
       categoryId = Value(categoryId);
  static Insertable<LiveChannel> custom({
    Expression<String>? accountKey,
    Expression<int>? id,
    Expression<int>? streamId,
    Expression<String>? name,
    Expression<int>? categoryId,
    Expression<int>? number,
    Expression<String>? logo,
    Expression<String>? epgChannelId,
    Expression<bool>? hasArchive,
    Expression<int>? archiveDurationDays,
  }) {
    return RawValuesInsertable({
      if (accountKey != null) 'account_key': accountKey,
      if (id != null) 'id': id,
      if (streamId != null) 'stream_id': streamId,
      if (name != null) 'name': name,
      if (categoryId != null) 'category_id': categoryId,
      if (number != null) 'number': number,
      if (logo != null) 'logo': logo,
      if (epgChannelId != null) 'epg_channel_id': epgChannelId,
      if (hasArchive != null) 'has_archive': hasArchive,
      if (archiveDurationDays != null)
        'archive_duration_days': archiveDurationDays,
    });
  }

  LiveChannelsCompanion copyWith({
    Value<String>? accountKey,
    Value<int>? id,
    Value<int>? streamId,
    Value<String>? name,
    Value<int>? categoryId,
    Value<int?>? number,
    Value<String?>? logo,
    Value<String?>? epgChannelId,
    Value<bool>? hasArchive,
    Value<int?>? archiveDurationDays,
  }) {
    return LiveChannelsCompanion(
      accountKey: accountKey ?? this.accountKey,
      id: id ?? this.id,
      streamId: streamId ?? this.streamId,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      number: number ?? this.number,
      logo: logo ?? this.logo,
      epgChannelId: epgChannelId ?? this.epgChannelId,
      hasArchive: hasArchive ?? this.hasArchive,
      archiveDurationDays: archiveDurationDays ?? this.archiveDurationDays,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountKey.present) {
      map['account_key'] = Variable<String>(accountKey.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (streamId.present) {
      map['stream_id'] = Variable<int>(streamId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (logo.present) {
      map['logo'] = Variable<String>(logo.value);
    }
    if (epgChannelId.present) {
      map['epg_channel_id'] = Variable<String>(epgChannelId.value);
    }
    if (hasArchive.present) {
      map['has_archive'] = Variable<bool>(hasArchive.value);
    }
    if (archiveDurationDays.present) {
      map['archive_duration_days'] = Variable<int>(archiveDurationDays.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LiveChannelsCompanion(')
          ..write('accountKey: $accountKey, ')
          ..write('id: $id, ')
          ..write('streamId: $streamId, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('number: $number, ')
          ..write('logo: $logo, ')
          ..write('epgChannelId: $epgChannelId, ')
          ..write('hasArchive: $hasArchive, ')
          ..write('archiveDurationDays: $archiveDurationDays')
          ..write(')'))
        .toString();
  }
}

class $VodCategoriesTable extends VodCategories
    with TableInfo<$VodCategoriesTable, VodCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VodCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountKeyMeta = const VerificationMeta(
    'accountKey',
  );
  @override
  late final GeneratedColumn<String> accountKey = GeneratedColumn<String>(
    'account_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [accountKey, id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vod_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<VodCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_key')) {
      context.handle(
        _accountKeyMeta,
        accountKey.isAcceptableOrUnknown(data['account_key']!, _accountKeyMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountKey, id};
  @override
  VodCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VodCategory(
      accountKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_key'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $VodCategoriesTable createAlias(String alias) {
    return $VodCategoriesTable(attachedDatabase, alias);
  }
}

class VodCategory extends DataClass implements Insertable<VodCategory> {
  final String accountKey;
  final int id;
  final String name;
  const VodCategory({
    required this.accountKey,
    required this.id,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_key'] = Variable<String>(accountKey);
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  VodCategoriesCompanion toCompanion(bool nullToAbsent) {
    return VodCategoriesCompanion(
      accountKey: Value(accountKey),
      id: Value(id),
      name: Value(name),
    );
  }

  factory VodCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VodCategory(
      accountKey: serializer.fromJson<String>(json['accountKey']),
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountKey': serializer.toJson<String>(accountKey),
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  VodCategory copyWith({String? accountKey, int? id, String? name}) =>
      VodCategory(
        accountKey: accountKey ?? this.accountKey,
        id: id ?? this.id,
        name: name ?? this.name,
      );
  VodCategory copyWithCompanion(VodCategoriesCompanion data) {
    return VodCategory(
      accountKey: data.accountKey.present
          ? data.accountKey.value
          : this.accountKey,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VodCategory(')
          ..write('accountKey: $accountKey, ')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(accountKey, id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VodCategory &&
          other.accountKey == this.accountKey &&
          other.id == this.id &&
          other.name == this.name);
}

class VodCategoriesCompanion extends UpdateCompanion<VodCategory> {
  final Value<String> accountKey;
  final Value<int> id;
  final Value<String> name;
  final Value<int> rowid;
  const VodCategoriesCompanion({
    this.accountKey = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VodCategoriesCompanion.insert({
    this.accountKey = const Value.absent(),
    required int id,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<VodCategory> custom({
    Expression<String>? accountKey,
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountKey != null) 'account_key': accountKey,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VodCategoriesCompanion copyWith({
    Value<String>? accountKey,
    Value<int>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return VodCategoriesCompanion(
      accountKey: accountKey ?? this.accountKey,
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountKey.present) {
      map['account_key'] = Variable<String>(accountKey.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VodCategoriesCompanion(')
          ..write('accountKey: $accountKey, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VodMoviesTable extends VodMovies
    with TableInfo<$VodMoviesTable, VodMovy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VodMoviesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountKeyMeta = const VerificationMeta(
    'accountKey',
  );
  @override
  late final GeneratedColumn<String> accountKey = GeneratedColumn<String>(
    'account_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
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
  static const VerificationMeta _streamIdMeta = const VerificationMeta(
    'streamId',
  );
  @override
  late final GeneratedColumn<int> streamId = GeneratedColumn<int>(
    'stream_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _streamTypeMeta = const VerificationMeta(
    'streamType',
  );
  @override
  late final GeneratedColumn<String> streamType = GeneratedColumn<String>(
    'stream_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _streamIconMeta = const VerificationMeta(
    'streamIcon',
  );
  @override
  late final GeneratedColumn<String> streamIcon = GeneratedColumn<String>(
    'stream_icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<String> rating = GeneratedColumn<String>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rating5BasedMeta = const VerificationMeta(
    'rating5Based',
  );
  @override
  late final GeneratedColumn<String> rating5Based = GeneratedColumn<String>(
    'rating5_based',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedMeta = const VerificationMeta('added');
  @override
  late final GeneratedColumn<String> added = GeneratedColumn<String>(
    'added',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _containerExtensionMeta =
      const VerificationMeta('containerExtension');
  @override
  late final GeneratedColumn<String> containerExtension =
      GeneratedColumn<String>(
        'container_extension',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _customSkinMeta = const VerificationMeta(
    'customSkin',
  );
  @override
  late final GeneratedColumn<String> customSkin = GeneratedColumn<String>(
    'custom_skin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _directSourceMeta = const VerificationMeta(
    'directSource',
  );
  @override
  late final GeneratedColumn<String> directSource = GeneratedColumn<String>(
    'direct_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    accountKey,
    id,
    streamId,
    name,
    categoryId,
    number,
    streamType,
    streamIcon,
    rating,
    rating5Based,
    added,
    containerExtension,
    customSkin,
    directSource,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vod_movies';
  @override
  VerificationContext validateIntegrity(
    Insertable<VodMovy> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_key')) {
      context.handle(
        _accountKeyMeta,
        accountKey.isAcceptableOrUnknown(data['account_key']!, _accountKeyMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('stream_id')) {
      context.handle(
        _streamIdMeta,
        streamId.isAcceptableOrUnknown(data['stream_id']!, _streamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_streamIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('stream_type')) {
      context.handle(
        _streamTypeMeta,
        streamType.isAcceptableOrUnknown(data['stream_type']!, _streamTypeMeta),
      );
    }
    if (data.containsKey('stream_icon')) {
      context.handle(
        _streamIconMeta,
        streamIcon.isAcceptableOrUnknown(data['stream_icon']!, _streamIconMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('rating5_based')) {
      context.handle(
        _rating5BasedMeta,
        rating5Based.isAcceptableOrUnknown(
          data['rating5_based']!,
          _rating5BasedMeta,
        ),
      );
    }
    if (data.containsKey('added')) {
      context.handle(
        _addedMeta,
        added.isAcceptableOrUnknown(data['added']!, _addedMeta),
      );
    }
    if (data.containsKey('container_extension')) {
      context.handle(
        _containerExtensionMeta,
        containerExtension.isAcceptableOrUnknown(
          data['container_extension']!,
          _containerExtensionMeta,
        ),
      );
    }
    if (data.containsKey('custom_skin')) {
      context.handle(
        _customSkinMeta,
        customSkin.isAcceptableOrUnknown(data['custom_skin']!, _customSkinMeta),
      );
    }
    if (data.containsKey('direct_source')) {
      context.handle(
        _directSourceMeta,
        directSource.isAcceptableOrUnknown(
          data['direct_source']!,
          _directSourceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VodMovy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VodMovy(
      accountKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_key'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      streamId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stream_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      ),
      streamType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stream_type'],
      ),
      streamIcon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stream_icon'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rating'],
      ),
      rating5Based: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rating5_based'],
      ),
      added: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}added'],
      ),
      containerExtension: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}container_extension'],
      ),
      customSkin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_skin'],
      ),
      directSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direct_source'],
      ),
    );
  }

  @override
  $VodMoviesTable createAlias(String alias) {
    return $VodMoviesTable(attachedDatabase, alias);
  }
}

class VodMovy extends DataClass implements Insertable<VodMovy> {
  final String accountKey;
  final int id;
  final int streamId;
  final String name;
  final int categoryId;
  final int? number;
  final String? streamType;
  final String? streamIcon;
  final String? rating;
  final String? rating5Based;
  final String? added;
  final String? containerExtension;
  final String? customSkin;
  final String? directSource;
  const VodMovy({
    required this.accountKey,
    required this.id,
    required this.streamId,
    required this.name,
    required this.categoryId,
    this.number,
    this.streamType,
    this.streamIcon,
    this.rating,
    this.rating5Based,
    this.added,
    this.containerExtension,
    this.customSkin,
    this.directSource,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_key'] = Variable<String>(accountKey);
    map['id'] = Variable<int>(id);
    map['stream_id'] = Variable<int>(streamId);
    map['name'] = Variable<String>(name);
    map['category_id'] = Variable<int>(categoryId);
    if (!nullToAbsent || number != null) {
      map['number'] = Variable<int>(number);
    }
    if (!nullToAbsent || streamType != null) {
      map['stream_type'] = Variable<String>(streamType);
    }
    if (!nullToAbsent || streamIcon != null) {
      map['stream_icon'] = Variable<String>(streamIcon);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<String>(rating);
    }
    if (!nullToAbsent || rating5Based != null) {
      map['rating5_based'] = Variable<String>(rating5Based);
    }
    if (!nullToAbsent || added != null) {
      map['added'] = Variable<String>(added);
    }
    if (!nullToAbsent || containerExtension != null) {
      map['container_extension'] = Variable<String>(containerExtension);
    }
    if (!nullToAbsent || customSkin != null) {
      map['custom_skin'] = Variable<String>(customSkin);
    }
    if (!nullToAbsent || directSource != null) {
      map['direct_source'] = Variable<String>(directSource);
    }
    return map;
  }

  VodMoviesCompanion toCompanion(bool nullToAbsent) {
    return VodMoviesCompanion(
      accountKey: Value(accountKey),
      id: Value(id),
      streamId: Value(streamId),
      name: Value(name),
      categoryId: Value(categoryId),
      number: number == null && nullToAbsent
          ? const Value.absent()
          : Value(number),
      streamType: streamType == null && nullToAbsent
          ? const Value.absent()
          : Value(streamType),
      streamIcon: streamIcon == null && nullToAbsent
          ? const Value.absent()
          : Value(streamIcon),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      rating5Based: rating5Based == null && nullToAbsent
          ? const Value.absent()
          : Value(rating5Based),
      added: added == null && nullToAbsent
          ? const Value.absent()
          : Value(added),
      containerExtension: containerExtension == null && nullToAbsent
          ? const Value.absent()
          : Value(containerExtension),
      customSkin: customSkin == null && nullToAbsent
          ? const Value.absent()
          : Value(customSkin),
      directSource: directSource == null && nullToAbsent
          ? const Value.absent()
          : Value(directSource),
    );
  }

  factory VodMovy.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VodMovy(
      accountKey: serializer.fromJson<String>(json['accountKey']),
      id: serializer.fromJson<int>(json['id']),
      streamId: serializer.fromJson<int>(json['streamId']),
      name: serializer.fromJson<String>(json['name']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      number: serializer.fromJson<int?>(json['number']),
      streamType: serializer.fromJson<String?>(json['streamType']),
      streamIcon: serializer.fromJson<String?>(json['streamIcon']),
      rating: serializer.fromJson<String?>(json['rating']),
      rating5Based: serializer.fromJson<String?>(json['rating5Based']),
      added: serializer.fromJson<String?>(json['added']),
      containerExtension: serializer.fromJson<String?>(
        json['containerExtension'],
      ),
      customSkin: serializer.fromJson<String?>(json['customSkin']),
      directSource: serializer.fromJson<String?>(json['directSource']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountKey': serializer.toJson<String>(accountKey),
      'id': serializer.toJson<int>(id),
      'streamId': serializer.toJson<int>(streamId),
      'name': serializer.toJson<String>(name),
      'categoryId': serializer.toJson<int>(categoryId),
      'number': serializer.toJson<int?>(number),
      'streamType': serializer.toJson<String?>(streamType),
      'streamIcon': serializer.toJson<String?>(streamIcon),
      'rating': serializer.toJson<String?>(rating),
      'rating5Based': serializer.toJson<String?>(rating5Based),
      'added': serializer.toJson<String?>(added),
      'containerExtension': serializer.toJson<String?>(containerExtension),
      'customSkin': serializer.toJson<String?>(customSkin),
      'directSource': serializer.toJson<String?>(directSource),
    };
  }

  VodMovy copyWith({
    String? accountKey,
    int? id,
    int? streamId,
    String? name,
    int? categoryId,
    Value<int?> number = const Value.absent(),
    Value<String?> streamType = const Value.absent(),
    Value<String?> streamIcon = const Value.absent(),
    Value<String?> rating = const Value.absent(),
    Value<String?> rating5Based = const Value.absent(),
    Value<String?> added = const Value.absent(),
    Value<String?> containerExtension = const Value.absent(),
    Value<String?> customSkin = const Value.absent(),
    Value<String?> directSource = const Value.absent(),
  }) => VodMovy(
    accountKey: accountKey ?? this.accountKey,
    id: id ?? this.id,
    streamId: streamId ?? this.streamId,
    name: name ?? this.name,
    categoryId: categoryId ?? this.categoryId,
    number: number.present ? number.value : this.number,
    streamType: streamType.present ? streamType.value : this.streamType,
    streamIcon: streamIcon.present ? streamIcon.value : this.streamIcon,
    rating: rating.present ? rating.value : this.rating,
    rating5Based: rating5Based.present ? rating5Based.value : this.rating5Based,
    added: added.present ? added.value : this.added,
    containerExtension: containerExtension.present
        ? containerExtension.value
        : this.containerExtension,
    customSkin: customSkin.present ? customSkin.value : this.customSkin,
    directSource: directSource.present ? directSource.value : this.directSource,
  );
  VodMovy copyWithCompanion(VodMoviesCompanion data) {
    return VodMovy(
      accountKey: data.accountKey.present
          ? data.accountKey.value
          : this.accountKey,
      id: data.id.present ? data.id.value : this.id,
      streamId: data.streamId.present ? data.streamId.value : this.streamId,
      name: data.name.present ? data.name.value : this.name,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      number: data.number.present ? data.number.value : this.number,
      streamType: data.streamType.present
          ? data.streamType.value
          : this.streamType,
      streamIcon: data.streamIcon.present
          ? data.streamIcon.value
          : this.streamIcon,
      rating: data.rating.present ? data.rating.value : this.rating,
      rating5Based: data.rating5Based.present
          ? data.rating5Based.value
          : this.rating5Based,
      added: data.added.present ? data.added.value : this.added,
      containerExtension: data.containerExtension.present
          ? data.containerExtension.value
          : this.containerExtension,
      customSkin: data.customSkin.present
          ? data.customSkin.value
          : this.customSkin,
      directSource: data.directSource.present
          ? data.directSource.value
          : this.directSource,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VodMovy(')
          ..write('accountKey: $accountKey, ')
          ..write('id: $id, ')
          ..write('streamId: $streamId, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('number: $number, ')
          ..write('streamType: $streamType, ')
          ..write('streamIcon: $streamIcon, ')
          ..write('rating: $rating, ')
          ..write('rating5Based: $rating5Based, ')
          ..write('added: $added, ')
          ..write('containerExtension: $containerExtension, ')
          ..write('customSkin: $customSkin, ')
          ..write('directSource: $directSource')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    accountKey,
    id,
    streamId,
    name,
    categoryId,
    number,
    streamType,
    streamIcon,
    rating,
    rating5Based,
    added,
    containerExtension,
    customSkin,
    directSource,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VodMovy &&
          other.accountKey == this.accountKey &&
          other.id == this.id &&
          other.streamId == this.streamId &&
          other.name == this.name &&
          other.categoryId == this.categoryId &&
          other.number == this.number &&
          other.streamType == this.streamType &&
          other.streamIcon == this.streamIcon &&
          other.rating == this.rating &&
          other.rating5Based == this.rating5Based &&
          other.added == this.added &&
          other.containerExtension == this.containerExtension &&
          other.customSkin == this.customSkin &&
          other.directSource == this.directSource);
}

class VodMoviesCompanion extends UpdateCompanion<VodMovy> {
  final Value<String> accountKey;
  final Value<int> id;
  final Value<int> streamId;
  final Value<String> name;
  final Value<int> categoryId;
  final Value<int?> number;
  final Value<String?> streamType;
  final Value<String?> streamIcon;
  final Value<String?> rating;
  final Value<String?> rating5Based;
  final Value<String?> added;
  final Value<String?> containerExtension;
  final Value<String?> customSkin;
  final Value<String?> directSource;
  const VodMoviesCompanion({
    this.accountKey = const Value.absent(),
    this.id = const Value.absent(),
    this.streamId = const Value.absent(),
    this.name = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.number = const Value.absent(),
    this.streamType = const Value.absent(),
    this.streamIcon = const Value.absent(),
    this.rating = const Value.absent(),
    this.rating5Based = const Value.absent(),
    this.added = const Value.absent(),
    this.containerExtension = const Value.absent(),
    this.customSkin = const Value.absent(),
    this.directSource = const Value.absent(),
  });
  VodMoviesCompanion.insert({
    this.accountKey = const Value.absent(),
    this.id = const Value.absent(),
    required int streamId,
    required String name,
    required int categoryId,
    this.number = const Value.absent(),
    this.streamType = const Value.absent(),
    this.streamIcon = const Value.absent(),
    this.rating = const Value.absent(),
    this.rating5Based = const Value.absent(),
    this.added = const Value.absent(),
    this.containerExtension = const Value.absent(),
    this.customSkin = const Value.absent(),
    this.directSource = const Value.absent(),
  }) : streamId = Value(streamId),
       name = Value(name),
       categoryId = Value(categoryId);
  static Insertable<VodMovy> custom({
    Expression<String>? accountKey,
    Expression<int>? id,
    Expression<int>? streamId,
    Expression<String>? name,
    Expression<int>? categoryId,
    Expression<int>? number,
    Expression<String>? streamType,
    Expression<String>? streamIcon,
    Expression<String>? rating,
    Expression<String>? rating5Based,
    Expression<String>? added,
    Expression<String>? containerExtension,
    Expression<String>? customSkin,
    Expression<String>? directSource,
  }) {
    return RawValuesInsertable({
      if (accountKey != null) 'account_key': accountKey,
      if (id != null) 'id': id,
      if (streamId != null) 'stream_id': streamId,
      if (name != null) 'name': name,
      if (categoryId != null) 'category_id': categoryId,
      if (number != null) 'number': number,
      if (streamType != null) 'stream_type': streamType,
      if (streamIcon != null) 'stream_icon': streamIcon,
      if (rating != null) 'rating': rating,
      if (rating5Based != null) 'rating5_based': rating5Based,
      if (added != null) 'added': added,
      if (containerExtension != null) 'container_extension': containerExtension,
      if (customSkin != null) 'custom_skin': customSkin,
      if (directSource != null) 'direct_source': directSource,
    });
  }

  VodMoviesCompanion copyWith({
    Value<String>? accountKey,
    Value<int>? id,
    Value<int>? streamId,
    Value<String>? name,
    Value<int>? categoryId,
    Value<int?>? number,
    Value<String?>? streamType,
    Value<String?>? streamIcon,
    Value<String?>? rating,
    Value<String?>? rating5Based,
    Value<String?>? added,
    Value<String?>? containerExtension,
    Value<String?>? customSkin,
    Value<String?>? directSource,
  }) {
    return VodMoviesCompanion(
      accountKey: accountKey ?? this.accountKey,
      id: id ?? this.id,
      streamId: streamId ?? this.streamId,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      number: number ?? this.number,
      streamType: streamType ?? this.streamType,
      streamIcon: streamIcon ?? this.streamIcon,
      rating: rating ?? this.rating,
      rating5Based: rating5Based ?? this.rating5Based,
      added: added ?? this.added,
      containerExtension: containerExtension ?? this.containerExtension,
      customSkin: customSkin ?? this.customSkin,
      directSource: directSource ?? this.directSource,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountKey.present) {
      map['account_key'] = Variable<String>(accountKey.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (streamId.present) {
      map['stream_id'] = Variable<int>(streamId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (streamType.present) {
      map['stream_type'] = Variable<String>(streamType.value);
    }
    if (streamIcon.present) {
      map['stream_icon'] = Variable<String>(streamIcon.value);
    }
    if (rating.present) {
      map['rating'] = Variable<String>(rating.value);
    }
    if (rating5Based.present) {
      map['rating5_based'] = Variable<String>(rating5Based.value);
    }
    if (added.present) {
      map['added'] = Variable<String>(added.value);
    }
    if (containerExtension.present) {
      map['container_extension'] = Variable<String>(containerExtension.value);
    }
    if (customSkin.present) {
      map['custom_skin'] = Variable<String>(customSkin.value);
    }
    if (directSource.present) {
      map['direct_source'] = Variable<String>(directSource.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VodMoviesCompanion(')
          ..write('accountKey: $accountKey, ')
          ..write('id: $id, ')
          ..write('streamId: $streamId, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('number: $number, ')
          ..write('streamType: $streamType, ')
          ..write('streamIcon: $streamIcon, ')
          ..write('rating: $rating, ')
          ..write('rating5Based: $rating5Based, ')
          ..write('added: $added, ')
          ..write('containerExtension: $containerExtension, ')
          ..write('customSkin: $customSkin, ')
          ..write('directSource: $directSource')
          ..write(')'))
        .toString();
  }
}

class $SeriesCategoriesTable extends SeriesCategories
    with TableInfo<$SeriesCategoriesTable, SeriesCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeriesCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountKeyMeta = const VerificationMeta(
    'accountKey',
  );
  @override
  late final GeneratedColumn<String> accountKey = GeneratedColumn<String>(
    'account_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [accountKey, id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeriesCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_key')) {
      context.handle(
        _accountKeyMeta,
        accountKey.isAcceptableOrUnknown(data['account_key']!, _accountKeyMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountKey, id};
  @override
  SeriesCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeriesCategory(
      accountKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_key'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $SeriesCategoriesTable createAlias(String alias) {
    return $SeriesCategoriesTable(attachedDatabase, alias);
  }
}

class SeriesCategory extends DataClass implements Insertable<SeriesCategory> {
  final String accountKey;
  final int id;
  final String name;
  const SeriesCategory({
    required this.accountKey,
    required this.id,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_key'] = Variable<String>(accountKey);
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  SeriesCategoriesCompanion toCompanion(bool nullToAbsent) {
    return SeriesCategoriesCompanion(
      accountKey: Value(accountKey),
      id: Value(id),
      name: Value(name),
    );
  }

  factory SeriesCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeriesCategory(
      accountKey: serializer.fromJson<String>(json['accountKey']),
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountKey': serializer.toJson<String>(accountKey),
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  SeriesCategory copyWith({String? accountKey, int? id, String? name}) =>
      SeriesCategory(
        accountKey: accountKey ?? this.accountKey,
        id: id ?? this.id,
        name: name ?? this.name,
      );
  SeriesCategory copyWithCompanion(SeriesCategoriesCompanion data) {
    return SeriesCategory(
      accountKey: data.accountKey.present
          ? data.accountKey.value
          : this.accountKey,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeriesCategory(')
          ..write('accountKey: $accountKey, ')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(accountKey, id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeriesCategory &&
          other.accountKey == this.accountKey &&
          other.id == this.id &&
          other.name == this.name);
}

class SeriesCategoriesCompanion extends UpdateCompanion<SeriesCategory> {
  final Value<String> accountKey;
  final Value<int> id;
  final Value<String> name;
  final Value<int> rowid;
  const SeriesCategoriesCompanion({
    this.accountKey = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeriesCategoriesCompanion.insert({
    this.accountKey = const Value.absent(),
    required int id,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<SeriesCategory> custom({
    Expression<String>? accountKey,
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountKey != null) 'account_key': accountKey,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeriesCategoriesCompanion copyWith({
    Value<String>? accountKey,
    Value<int>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return SeriesCategoriesCompanion(
      accountKey: accountKey ?? this.accountKey,
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountKey.present) {
      map['account_key'] = Variable<String>(accountKey.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeriesCategoriesCompanion(')
          ..write('accountKey: $accountKey, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeriesCacheTable extends SeriesCache
    with TableInfo<$SeriesCacheTable, SeriesCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeriesCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountKeyMeta = const VerificationMeta(
    'accountKey',
  );
  @override
  late final GeneratedColumn<String> accountKey = GeneratedColumn<String>(
    'account_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
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
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<int> seriesId = GeneratedColumn<int>(
    'series_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<int> season = GeneratedColumn<int>(
    'season',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverMeta = const VerificationMeta('cover');
  @override
  late final GeneratedColumn<String> cover = GeneratedColumn<String>(
    'cover',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plotMeta = const VerificationMeta('plot');
  @override
  late final GeneratedColumn<String> plot = GeneratedColumn<String>(
    'plot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _castMeta = const VerificationMeta('cast');
  @override
  late final GeneratedColumn<String> cast = GeneratedColumn<String>(
    'cast',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _directorMeta = const VerificationMeta(
    'director',
  );
  @override
  late final GeneratedColumn<String> director = GeneratedColumn<String>(
    'director',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _releaseDateMeta = const VerificationMeta(
    'releaseDate',
  );
  @override
  late final GeneratedColumn<String> releaseDate = GeneratedColumn<String>(
    'release_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<String> lastModified = GeneratedColumn<String>(
    'last_modified',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<String> rating = GeneratedColumn<String>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rating5BasedMeta = const VerificationMeta(
    'rating5Based',
  );
  @override
  late final GeneratedColumn<String> rating5Based = GeneratedColumn<String>(
    'rating5_based',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _backdropPathMeta = const VerificationMeta(
    'backdropPath',
  );
  @override
  late final GeneratedColumn<String> backdropPath = GeneratedColumn<String>(
    'backdrop_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _youtubeTrailerMeta = const VerificationMeta(
    'youtubeTrailer',
  );
  @override
  late final GeneratedColumn<String> youtubeTrailer = GeneratedColumn<String>(
    'youtube_trailer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _episodeRunTimeMeta = const VerificationMeta(
    'episodeRunTime',
  );
  @override
  late final GeneratedColumn<String> episodeRunTime = GeneratedColumn<String>(
    'episode_run_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    accountKey,
    id,
    seriesId,
    name,
    number,
    season,
    cover,
    plot,
    cast,
    director,
    genre,
    releaseDate,
    lastModified,
    rating,
    rating5Based,
    backdropPath,
    youtubeTrailer,
    episodeRunTime,
    categoryId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeriesCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_key')) {
      context.handle(
        _accountKeyMeta,
        accountKey.isAcceptableOrUnknown(data['account_key']!, _accountKeyMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_seriesIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('season')) {
      context.handle(
        _seasonMeta,
        season.isAcceptableOrUnknown(data['season']!, _seasonMeta),
      );
    }
    if (data.containsKey('cover')) {
      context.handle(
        _coverMeta,
        cover.isAcceptableOrUnknown(data['cover']!, _coverMeta),
      );
    }
    if (data.containsKey('plot')) {
      context.handle(
        _plotMeta,
        plot.isAcceptableOrUnknown(data['plot']!, _plotMeta),
      );
    }
    if (data.containsKey('cast')) {
      context.handle(
        _castMeta,
        cast.isAcceptableOrUnknown(data['cast']!, _castMeta),
      );
    }
    if (data.containsKey('director')) {
      context.handle(
        _directorMeta,
        director.isAcceptableOrUnknown(data['director']!, _directorMeta),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('release_date')) {
      context.handle(
        _releaseDateMeta,
        releaseDate.isAcceptableOrUnknown(
          data['release_date']!,
          _releaseDateMeta,
        ),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('rating5_based')) {
      context.handle(
        _rating5BasedMeta,
        rating5Based.isAcceptableOrUnknown(
          data['rating5_based']!,
          _rating5BasedMeta,
        ),
      );
    }
    if (data.containsKey('backdrop_path')) {
      context.handle(
        _backdropPathMeta,
        backdropPath.isAcceptableOrUnknown(
          data['backdrop_path']!,
          _backdropPathMeta,
        ),
      );
    }
    if (data.containsKey('youtube_trailer')) {
      context.handle(
        _youtubeTrailerMeta,
        youtubeTrailer.isAcceptableOrUnknown(
          data['youtube_trailer']!,
          _youtubeTrailerMeta,
        ),
      );
    }
    if (data.containsKey('episode_run_time')) {
      context.handle(
        _episodeRunTimeMeta,
        episodeRunTime.isAcceptableOrUnknown(
          data['episode_run_time']!,
          _episodeRunTimeMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SeriesCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeriesCacheData(
      accountKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_key'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}series_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      ),
      season: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}season'],
      ),
      cover: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover'],
      ),
      plot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plot'],
      ),
      cast: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cast'],
      ),
      director: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}director'],
      ),
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      ),
      releaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}release_date'],
      ),
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_modified'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rating'],
      ),
      rating5Based: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rating5_based'],
      ),
      backdropPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}backdrop_path'],
      ),
      youtubeTrailer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}youtube_trailer'],
      ),
      episodeRunTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}episode_run_time'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
    );
  }

  @override
  $SeriesCacheTable createAlias(String alias) {
    return $SeriesCacheTable(attachedDatabase, alias);
  }
}

class SeriesCacheData extends DataClass implements Insertable<SeriesCacheData> {
  final String accountKey;
  final int id;
  final int seriesId;
  final String name;
  final int? number;
  final int? season;
  final String? cover;
  final String? plot;
  final String? cast;
  final String? director;
  final String? genre;
  final String? releaseDate;
  final String? lastModified;
  final String? rating;
  final String? rating5Based;
  final String? backdropPath;
  final String? youtubeTrailer;
  final String? episodeRunTime;
  final int? categoryId;
  const SeriesCacheData({
    required this.accountKey,
    required this.id,
    required this.seriesId,
    required this.name,
    this.number,
    this.season,
    this.cover,
    this.plot,
    this.cast,
    this.director,
    this.genre,
    this.releaseDate,
    this.lastModified,
    this.rating,
    this.rating5Based,
    this.backdropPath,
    this.youtubeTrailer,
    this.episodeRunTime,
    this.categoryId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_key'] = Variable<String>(accountKey);
    map['id'] = Variable<int>(id);
    map['series_id'] = Variable<int>(seriesId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || number != null) {
      map['number'] = Variable<int>(number);
    }
    if (!nullToAbsent || season != null) {
      map['season'] = Variable<int>(season);
    }
    if (!nullToAbsent || cover != null) {
      map['cover'] = Variable<String>(cover);
    }
    if (!nullToAbsent || plot != null) {
      map['plot'] = Variable<String>(plot);
    }
    if (!nullToAbsent || cast != null) {
      map['cast'] = Variable<String>(cast);
    }
    if (!nullToAbsent || director != null) {
      map['director'] = Variable<String>(director);
    }
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(genre);
    }
    if (!nullToAbsent || releaseDate != null) {
      map['release_date'] = Variable<String>(releaseDate);
    }
    if (!nullToAbsent || lastModified != null) {
      map['last_modified'] = Variable<String>(lastModified);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<String>(rating);
    }
    if (!nullToAbsent || rating5Based != null) {
      map['rating5_based'] = Variable<String>(rating5Based);
    }
    if (!nullToAbsent || backdropPath != null) {
      map['backdrop_path'] = Variable<String>(backdropPath);
    }
    if (!nullToAbsent || youtubeTrailer != null) {
      map['youtube_trailer'] = Variable<String>(youtubeTrailer);
    }
    if (!nullToAbsent || episodeRunTime != null) {
      map['episode_run_time'] = Variable<String>(episodeRunTime);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    return map;
  }

  SeriesCacheCompanion toCompanion(bool nullToAbsent) {
    return SeriesCacheCompanion(
      accountKey: Value(accountKey),
      id: Value(id),
      seriesId: Value(seriesId),
      name: Value(name),
      number: number == null && nullToAbsent
          ? const Value.absent()
          : Value(number),
      season: season == null && nullToAbsent
          ? const Value.absent()
          : Value(season),
      cover: cover == null && nullToAbsent
          ? const Value.absent()
          : Value(cover),
      plot: plot == null && nullToAbsent ? const Value.absent() : Value(plot),
      cast: cast == null && nullToAbsent ? const Value.absent() : Value(cast),
      director: director == null && nullToAbsent
          ? const Value.absent()
          : Value(director),
      genre: genre == null && nullToAbsent
          ? const Value.absent()
          : Value(genre),
      releaseDate: releaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseDate),
      lastModified: lastModified == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModified),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      rating5Based: rating5Based == null && nullToAbsent
          ? const Value.absent()
          : Value(rating5Based),
      backdropPath: backdropPath == null && nullToAbsent
          ? const Value.absent()
          : Value(backdropPath),
      youtubeTrailer: youtubeTrailer == null && nullToAbsent
          ? const Value.absent()
          : Value(youtubeTrailer),
      episodeRunTime: episodeRunTime == null && nullToAbsent
          ? const Value.absent()
          : Value(episodeRunTime),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
    );
  }

  factory SeriesCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeriesCacheData(
      accountKey: serializer.fromJson<String>(json['accountKey']),
      id: serializer.fromJson<int>(json['id']),
      seriesId: serializer.fromJson<int>(json['seriesId']),
      name: serializer.fromJson<String>(json['name']),
      number: serializer.fromJson<int?>(json['number']),
      season: serializer.fromJson<int?>(json['season']),
      cover: serializer.fromJson<String?>(json['cover']),
      plot: serializer.fromJson<String?>(json['plot']),
      cast: serializer.fromJson<String?>(json['cast']),
      director: serializer.fromJson<String?>(json['director']),
      genre: serializer.fromJson<String?>(json['genre']),
      releaseDate: serializer.fromJson<String?>(json['releaseDate']),
      lastModified: serializer.fromJson<String?>(json['lastModified']),
      rating: serializer.fromJson<String?>(json['rating']),
      rating5Based: serializer.fromJson<String?>(json['rating5Based']),
      backdropPath: serializer.fromJson<String?>(json['backdropPath']),
      youtubeTrailer: serializer.fromJson<String?>(json['youtubeTrailer']),
      episodeRunTime: serializer.fromJson<String?>(json['episodeRunTime']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountKey': serializer.toJson<String>(accountKey),
      'id': serializer.toJson<int>(id),
      'seriesId': serializer.toJson<int>(seriesId),
      'name': serializer.toJson<String>(name),
      'number': serializer.toJson<int?>(number),
      'season': serializer.toJson<int?>(season),
      'cover': serializer.toJson<String?>(cover),
      'plot': serializer.toJson<String?>(plot),
      'cast': serializer.toJson<String?>(cast),
      'director': serializer.toJson<String?>(director),
      'genre': serializer.toJson<String?>(genre),
      'releaseDate': serializer.toJson<String?>(releaseDate),
      'lastModified': serializer.toJson<String?>(lastModified),
      'rating': serializer.toJson<String?>(rating),
      'rating5Based': serializer.toJson<String?>(rating5Based),
      'backdropPath': serializer.toJson<String?>(backdropPath),
      'youtubeTrailer': serializer.toJson<String?>(youtubeTrailer),
      'episodeRunTime': serializer.toJson<String?>(episodeRunTime),
      'categoryId': serializer.toJson<int?>(categoryId),
    };
  }

  SeriesCacheData copyWith({
    String? accountKey,
    int? id,
    int? seriesId,
    String? name,
    Value<int?> number = const Value.absent(),
    Value<int?> season = const Value.absent(),
    Value<String?> cover = const Value.absent(),
    Value<String?> plot = const Value.absent(),
    Value<String?> cast = const Value.absent(),
    Value<String?> director = const Value.absent(),
    Value<String?> genre = const Value.absent(),
    Value<String?> releaseDate = const Value.absent(),
    Value<String?> lastModified = const Value.absent(),
    Value<String?> rating = const Value.absent(),
    Value<String?> rating5Based = const Value.absent(),
    Value<String?> backdropPath = const Value.absent(),
    Value<String?> youtubeTrailer = const Value.absent(),
    Value<String?> episodeRunTime = const Value.absent(),
    Value<int?> categoryId = const Value.absent(),
  }) => SeriesCacheData(
    accountKey: accountKey ?? this.accountKey,
    id: id ?? this.id,
    seriesId: seriesId ?? this.seriesId,
    name: name ?? this.name,
    number: number.present ? number.value : this.number,
    season: season.present ? season.value : this.season,
    cover: cover.present ? cover.value : this.cover,
    plot: plot.present ? plot.value : this.plot,
    cast: cast.present ? cast.value : this.cast,
    director: director.present ? director.value : this.director,
    genre: genre.present ? genre.value : this.genre,
    releaseDate: releaseDate.present ? releaseDate.value : this.releaseDate,
    lastModified: lastModified.present ? lastModified.value : this.lastModified,
    rating: rating.present ? rating.value : this.rating,
    rating5Based: rating5Based.present ? rating5Based.value : this.rating5Based,
    backdropPath: backdropPath.present ? backdropPath.value : this.backdropPath,
    youtubeTrailer: youtubeTrailer.present
        ? youtubeTrailer.value
        : this.youtubeTrailer,
    episodeRunTime: episodeRunTime.present
        ? episodeRunTime.value
        : this.episodeRunTime,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
  );
  SeriesCacheData copyWithCompanion(SeriesCacheCompanion data) {
    return SeriesCacheData(
      accountKey: data.accountKey.present
          ? data.accountKey.value
          : this.accountKey,
      id: data.id.present ? data.id.value : this.id,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      name: data.name.present ? data.name.value : this.name,
      number: data.number.present ? data.number.value : this.number,
      season: data.season.present ? data.season.value : this.season,
      cover: data.cover.present ? data.cover.value : this.cover,
      plot: data.plot.present ? data.plot.value : this.plot,
      cast: data.cast.present ? data.cast.value : this.cast,
      director: data.director.present ? data.director.value : this.director,
      genre: data.genre.present ? data.genre.value : this.genre,
      releaseDate: data.releaseDate.present
          ? data.releaseDate.value
          : this.releaseDate,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      rating: data.rating.present ? data.rating.value : this.rating,
      rating5Based: data.rating5Based.present
          ? data.rating5Based.value
          : this.rating5Based,
      backdropPath: data.backdropPath.present
          ? data.backdropPath.value
          : this.backdropPath,
      youtubeTrailer: data.youtubeTrailer.present
          ? data.youtubeTrailer.value
          : this.youtubeTrailer,
      episodeRunTime: data.episodeRunTime.present
          ? data.episodeRunTime.value
          : this.episodeRunTime,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeriesCacheData(')
          ..write('accountKey: $accountKey, ')
          ..write('id: $id, ')
          ..write('seriesId: $seriesId, ')
          ..write('name: $name, ')
          ..write('number: $number, ')
          ..write('season: $season, ')
          ..write('cover: $cover, ')
          ..write('plot: $plot, ')
          ..write('cast: $cast, ')
          ..write('director: $director, ')
          ..write('genre: $genre, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('lastModified: $lastModified, ')
          ..write('rating: $rating, ')
          ..write('rating5Based: $rating5Based, ')
          ..write('backdropPath: $backdropPath, ')
          ..write('youtubeTrailer: $youtubeTrailer, ')
          ..write('episodeRunTime: $episodeRunTime, ')
          ..write('categoryId: $categoryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    accountKey,
    id,
    seriesId,
    name,
    number,
    season,
    cover,
    plot,
    cast,
    director,
    genre,
    releaseDate,
    lastModified,
    rating,
    rating5Based,
    backdropPath,
    youtubeTrailer,
    episodeRunTime,
    categoryId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeriesCacheData &&
          other.accountKey == this.accountKey &&
          other.id == this.id &&
          other.seriesId == this.seriesId &&
          other.name == this.name &&
          other.number == this.number &&
          other.season == this.season &&
          other.cover == this.cover &&
          other.plot == this.plot &&
          other.cast == this.cast &&
          other.director == this.director &&
          other.genre == this.genre &&
          other.releaseDate == this.releaseDate &&
          other.lastModified == this.lastModified &&
          other.rating == this.rating &&
          other.rating5Based == this.rating5Based &&
          other.backdropPath == this.backdropPath &&
          other.youtubeTrailer == this.youtubeTrailer &&
          other.episodeRunTime == this.episodeRunTime &&
          other.categoryId == this.categoryId);
}

class SeriesCacheCompanion extends UpdateCompanion<SeriesCacheData> {
  final Value<String> accountKey;
  final Value<int> id;
  final Value<int> seriesId;
  final Value<String> name;
  final Value<int?> number;
  final Value<int?> season;
  final Value<String?> cover;
  final Value<String?> plot;
  final Value<String?> cast;
  final Value<String?> director;
  final Value<String?> genre;
  final Value<String?> releaseDate;
  final Value<String?> lastModified;
  final Value<String?> rating;
  final Value<String?> rating5Based;
  final Value<String?> backdropPath;
  final Value<String?> youtubeTrailer;
  final Value<String?> episodeRunTime;
  final Value<int?> categoryId;
  const SeriesCacheCompanion({
    this.accountKey = const Value.absent(),
    this.id = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.name = const Value.absent(),
    this.number = const Value.absent(),
    this.season = const Value.absent(),
    this.cover = const Value.absent(),
    this.plot = const Value.absent(),
    this.cast = const Value.absent(),
    this.director = const Value.absent(),
    this.genre = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.rating = const Value.absent(),
    this.rating5Based = const Value.absent(),
    this.backdropPath = const Value.absent(),
    this.youtubeTrailer = const Value.absent(),
    this.episodeRunTime = const Value.absent(),
    this.categoryId = const Value.absent(),
  });
  SeriesCacheCompanion.insert({
    this.accountKey = const Value.absent(),
    this.id = const Value.absent(),
    required int seriesId,
    required String name,
    this.number = const Value.absent(),
    this.season = const Value.absent(),
    this.cover = const Value.absent(),
    this.plot = const Value.absent(),
    this.cast = const Value.absent(),
    this.director = const Value.absent(),
    this.genre = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.rating = const Value.absent(),
    this.rating5Based = const Value.absent(),
    this.backdropPath = const Value.absent(),
    this.youtubeTrailer = const Value.absent(),
    this.episodeRunTime = const Value.absent(),
    this.categoryId = const Value.absent(),
  }) : seriesId = Value(seriesId),
       name = Value(name);
  static Insertable<SeriesCacheData> custom({
    Expression<String>? accountKey,
    Expression<int>? id,
    Expression<int>? seriesId,
    Expression<String>? name,
    Expression<int>? number,
    Expression<int>? season,
    Expression<String>? cover,
    Expression<String>? plot,
    Expression<String>? cast,
    Expression<String>? director,
    Expression<String>? genre,
    Expression<String>? releaseDate,
    Expression<String>? lastModified,
    Expression<String>? rating,
    Expression<String>? rating5Based,
    Expression<String>? backdropPath,
    Expression<String>? youtubeTrailer,
    Expression<String>? episodeRunTime,
    Expression<int>? categoryId,
  }) {
    return RawValuesInsertable({
      if (accountKey != null) 'account_key': accountKey,
      if (id != null) 'id': id,
      if (seriesId != null) 'series_id': seriesId,
      if (name != null) 'name': name,
      if (number != null) 'number': number,
      if (season != null) 'season': season,
      if (cover != null) 'cover': cover,
      if (plot != null) 'plot': plot,
      if (cast != null) 'cast': cast,
      if (director != null) 'director': director,
      if (genre != null) 'genre': genre,
      if (releaseDate != null) 'release_date': releaseDate,
      if (lastModified != null) 'last_modified': lastModified,
      if (rating != null) 'rating': rating,
      if (rating5Based != null) 'rating5_based': rating5Based,
      if (backdropPath != null) 'backdrop_path': backdropPath,
      if (youtubeTrailer != null) 'youtube_trailer': youtubeTrailer,
      if (episodeRunTime != null) 'episode_run_time': episodeRunTime,
      if (categoryId != null) 'category_id': categoryId,
    });
  }

  SeriesCacheCompanion copyWith({
    Value<String>? accountKey,
    Value<int>? id,
    Value<int>? seriesId,
    Value<String>? name,
    Value<int?>? number,
    Value<int?>? season,
    Value<String?>? cover,
    Value<String?>? plot,
    Value<String?>? cast,
    Value<String?>? director,
    Value<String?>? genre,
    Value<String?>? releaseDate,
    Value<String?>? lastModified,
    Value<String?>? rating,
    Value<String?>? rating5Based,
    Value<String?>? backdropPath,
    Value<String?>? youtubeTrailer,
    Value<String?>? episodeRunTime,
    Value<int?>? categoryId,
  }) {
    return SeriesCacheCompanion(
      accountKey: accountKey ?? this.accountKey,
      id: id ?? this.id,
      seriesId: seriesId ?? this.seriesId,
      name: name ?? this.name,
      number: number ?? this.number,
      season: season ?? this.season,
      cover: cover ?? this.cover,
      plot: plot ?? this.plot,
      cast: cast ?? this.cast,
      director: director ?? this.director,
      genre: genre ?? this.genre,
      releaseDate: releaseDate ?? this.releaseDate,
      lastModified: lastModified ?? this.lastModified,
      rating: rating ?? this.rating,
      rating5Based: rating5Based ?? this.rating5Based,
      backdropPath: backdropPath ?? this.backdropPath,
      youtubeTrailer: youtubeTrailer ?? this.youtubeTrailer,
      episodeRunTime: episodeRunTime ?? this.episodeRunTime,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountKey.present) {
      map['account_key'] = Variable<String>(accountKey.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<int>(seriesId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (season.present) {
      map['season'] = Variable<int>(season.value);
    }
    if (cover.present) {
      map['cover'] = Variable<String>(cover.value);
    }
    if (plot.present) {
      map['plot'] = Variable<String>(plot.value);
    }
    if (cast.present) {
      map['cast'] = Variable<String>(cast.value);
    }
    if (director.present) {
      map['director'] = Variable<String>(director.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (releaseDate.present) {
      map['release_date'] = Variable<String>(releaseDate.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<String>(lastModified.value);
    }
    if (rating.present) {
      map['rating'] = Variable<String>(rating.value);
    }
    if (rating5Based.present) {
      map['rating5_based'] = Variable<String>(rating5Based.value);
    }
    if (backdropPath.present) {
      map['backdrop_path'] = Variable<String>(backdropPath.value);
    }
    if (youtubeTrailer.present) {
      map['youtube_trailer'] = Variable<String>(youtubeTrailer.value);
    }
    if (episodeRunTime.present) {
      map['episode_run_time'] = Variable<String>(episodeRunTime.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeriesCacheCompanion(')
          ..write('accountKey: $accountKey, ')
          ..write('id: $id, ')
          ..write('seriesId: $seriesId, ')
          ..write('name: $name, ')
          ..write('number: $number, ')
          ..write('season: $season, ')
          ..write('cover: $cover, ')
          ..write('plot: $plot, ')
          ..write('cast: $cast, ')
          ..write('director: $director, ')
          ..write('genre: $genre, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('lastModified: $lastModified, ')
          ..write('rating: $rating, ')
          ..write('rating5Based: $rating5Based, ')
          ..write('backdropPath: $backdropPath, ')
          ..write('youtubeTrailer: $youtubeTrailer, ')
          ..write('episodeRunTime: $episodeRunTime, ')
          ..write('categoryId: $categoryId')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTable extends Favorites
    with TableInfo<$FavoritesTable, Favorite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountKeyMeta = const VerificationMeta(
    'accountKey',
  );
  @override
  late final GeneratedColumn<String> accountKey = GeneratedColumn<String>(
    'account_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
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
  static const VerificationMeta _contentIdMeta = const VerificationMeta(
    'contentId',
  );
  @override
  late final GeneratedColumn<int> contentId = GeneratedColumn<int>(
    'content_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _logoMeta = const VerificationMeta('logo');
  @override
  late final GeneratedColumn<String> logo = GeneratedColumn<String>(
    'logo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    accountKey,
    id,
    contentId,
    contentType,
    name,
    logo,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<Favorite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_key')) {
      context.handle(
        _accountKeyMeta,
        accountKey.isAcceptableOrUnknown(data['account_key']!, _accountKeyMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('content_id')) {
      context.handle(
        _contentIdMeta,
        contentId.isAcceptableOrUnknown(data['content_id']!, _contentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contentIdMeta);
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentTypeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('logo')) {
      context.handle(
        _logoMeta,
        logo.isAcceptableOrUnknown(data['logo']!, _logoMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Favorite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Favorite(
      accountKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_key'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      contentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}content_id'],
      )!,
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      logo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $FavoritesTable createAlias(String alias) {
    return $FavoritesTable(attachedDatabase, alias);
  }
}

class Favorite extends DataClass implements Insertable<Favorite> {
  /// Id de la cuenta (fingerprint) a la que pertenece la fila.
  final String accountKey;
  final int id;
  final int contentId;
  final String contentType;
  final String name;
  final String? logo;
  final DateTime addedAt;
  const Favorite({
    required this.accountKey,
    required this.id,
    required this.contentId,
    required this.contentType,
    required this.name,
    this.logo,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_key'] = Variable<String>(accountKey);
    map['id'] = Variable<int>(id);
    map['content_id'] = Variable<int>(contentId);
    map['content_type'] = Variable<String>(contentType);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || logo != null) {
      map['logo'] = Variable<String>(logo);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  FavoritesCompanion toCompanion(bool nullToAbsent) {
    return FavoritesCompanion(
      accountKey: Value(accountKey),
      id: Value(id),
      contentId: Value(contentId),
      contentType: Value(contentType),
      name: Value(name),
      logo: logo == null && nullToAbsent ? const Value.absent() : Value(logo),
      addedAt: Value(addedAt),
    );
  }

  factory Favorite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Favorite(
      accountKey: serializer.fromJson<String>(json['accountKey']),
      id: serializer.fromJson<int>(json['id']),
      contentId: serializer.fromJson<int>(json['contentId']),
      contentType: serializer.fromJson<String>(json['contentType']),
      name: serializer.fromJson<String>(json['name']),
      logo: serializer.fromJson<String?>(json['logo']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountKey': serializer.toJson<String>(accountKey),
      'id': serializer.toJson<int>(id),
      'contentId': serializer.toJson<int>(contentId),
      'contentType': serializer.toJson<String>(contentType),
      'name': serializer.toJson<String>(name),
      'logo': serializer.toJson<String?>(logo),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  Favorite copyWith({
    String? accountKey,
    int? id,
    int? contentId,
    String? contentType,
    String? name,
    Value<String?> logo = const Value.absent(),
    DateTime? addedAt,
  }) => Favorite(
    accountKey: accountKey ?? this.accountKey,
    id: id ?? this.id,
    contentId: contentId ?? this.contentId,
    contentType: contentType ?? this.contentType,
    name: name ?? this.name,
    logo: logo.present ? logo.value : this.logo,
    addedAt: addedAt ?? this.addedAt,
  );
  Favorite copyWithCompanion(FavoritesCompanion data) {
    return Favorite(
      accountKey: data.accountKey.present
          ? data.accountKey.value
          : this.accountKey,
      id: data.id.present ? data.id.value : this.id,
      contentId: data.contentId.present ? data.contentId.value : this.contentId,
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
      name: data.name.present ? data.name.value : this.name,
      logo: data.logo.present ? data.logo.value : this.logo,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Favorite(')
          ..write('accountKey: $accountKey, ')
          ..write('id: $id, ')
          ..write('contentId: $contentId, ')
          ..write('contentType: $contentType, ')
          ..write('name: $name, ')
          ..write('logo: $logo, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(accountKey, id, contentId, contentType, name, logo, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Favorite &&
          other.accountKey == this.accountKey &&
          other.id == this.id &&
          other.contentId == this.contentId &&
          other.contentType == this.contentType &&
          other.name == this.name &&
          other.logo == this.logo &&
          other.addedAt == this.addedAt);
}

class FavoritesCompanion extends UpdateCompanion<Favorite> {
  final Value<String> accountKey;
  final Value<int> id;
  final Value<int> contentId;
  final Value<String> contentType;
  final Value<String> name;
  final Value<String?> logo;
  final Value<DateTime> addedAt;
  const FavoritesCompanion({
    this.accountKey = const Value.absent(),
    this.id = const Value.absent(),
    this.contentId = const Value.absent(),
    this.contentType = const Value.absent(),
    this.name = const Value.absent(),
    this.logo = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  FavoritesCompanion.insert({
    this.accountKey = const Value.absent(),
    this.id = const Value.absent(),
    required int contentId,
    required String contentType,
    required String name,
    this.logo = const Value.absent(),
    required DateTime addedAt,
  }) : contentId = Value(contentId),
       contentType = Value(contentType),
       name = Value(name),
       addedAt = Value(addedAt);
  static Insertable<Favorite> custom({
    Expression<String>? accountKey,
    Expression<int>? id,
    Expression<int>? contentId,
    Expression<String>? contentType,
    Expression<String>? name,
    Expression<String>? logo,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (accountKey != null) 'account_key': accountKey,
      if (id != null) 'id': id,
      if (contentId != null) 'content_id': contentId,
      if (contentType != null) 'content_type': contentType,
      if (name != null) 'name': name,
      if (logo != null) 'logo': logo,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  FavoritesCompanion copyWith({
    Value<String>? accountKey,
    Value<int>? id,
    Value<int>? contentId,
    Value<String>? contentType,
    Value<String>? name,
    Value<String?>? logo,
    Value<DateTime>? addedAt,
  }) {
    return FavoritesCompanion(
      accountKey: accountKey ?? this.accountKey,
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      contentType: contentType ?? this.contentType,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountKey.present) {
      map['account_key'] = Variable<String>(accountKey.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contentId.present) {
      map['content_id'] = Variable<int>(contentId.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (logo.present) {
      map['logo'] = Variable<String>(logo.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesCompanion(')
          ..write('accountKey: $accountKey, ')
          ..write('id: $id, ')
          ..write('contentId: $contentId, ')
          ..write('contentType: $contentType, ')
          ..write('name: $name, ')
          ..write('logo: $logo, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

class $FavoriteGroupsTable extends FavoriteGroups
    with TableInfo<$FavoriteGroupsTable, FavoriteGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountKeyMeta = const VerificationMeta(
    'accountKey',
  );
  @override
  late final GeneratedColumn<String> accountKey = GeneratedColumn<String>(
    'account_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isRadioMeta = const VerificationMeta(
    'isRadio',
  );
  @override
  late final GeneratedColumn<bool> isRadio = GeneratedColumn<bool>(
    'is_radio',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_radio" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    accountKey,
    categoryId,
    name,
    isRadio,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_key')) {
      context.handle(
        _accountKeyMeta,
        accountKey.isAcceptableOrUnknown(data['account_key']!, _accountKeyMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_radio')) {
      context.handle(
        _isRadioMeta,
        isRadio.isAcceptableOrUnknown(data['is_radio']!, _isRadioMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountKey, categoryId};
  @override
  FavoriteGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteGroup(
      accountKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_key'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isRadio: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_radio'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $FavoriteGroupsTable createAlias(String alias) {
    return $FavoriteGroupsTable(attachedDatabase, alias);
  }
}

class FavoriteGroup extends DataClass implements Insertable<FavoriteGroup> {
  final String accountKey;
  final int categoryId;
  final String name;
  final bool isRadio;
  final DateTime addedAt;
  const FavoriteGroup({
    required this.accountKey,
    required this.categoryId,
    required this.name,
    required this.isRadio,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_key'] = Variable<String>(accountKey);
    map['category_id'] = Variable<int>(categoryId);
    map['name'] = Variable<String>(name);
    map['is_radio'] = Variable<bool>(isRadio);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  FavoriteGroupsCompanion toCompanion(bool nullToAbsent) {
    return FavoriteGroupsCompanion(
      accountKey: Value(accountKey),
      categoryId: Value(categoryId),
      name: Value(name),
      isRadio: Value(isRadio),
      addedAt: Value(addedAt),
    );
  }

  factory FavoriteGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteGroup(
      accountKey: serializer.fromJson<String>(json['accountKey']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      name: serializer.fromJson<String>(json['name']),
      isRadio: serializer.fromJson<bool>(json['isRadio']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountKey': serializer.toJson<String>(accountKey),
      'categoryId': serializer.toJson<int>(categoryId),
      'name': serializer.toJson<String>(name),
      'isRadio': serializer.toJson<bool>(isRadio),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  FavoriteGroup copyWith({
    String? accountKey,
    int? categoryId,
    String? name,
    bool? isRadio,
    DateTime? addedAt,
  }) => FavoriteGroup(
    accountKey: accountKey ?? this.accountKey,
    categoryId: categoryId ?? this.categoryId,
    name: name ?? this.name,
    isRadio: isRadio ?? this.isRadio,
    addedAt: addedAt ?? this.addedAt,
  );
  FavoriteGroup copyWithCompanion(FavoriteGroupsCompanion data) {
    return FavoriteGroup(
      accountKey: data.accountKey.present
          ? data.accountKey.value
          : this.accountKey,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      name: data.name.present ? data.name.value : this.name,
      isRadio: data.isRadio.present ? data.isRadio.value : this.isRadio,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteGroup(')
          ..write('accountKey: $accountKey, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('isRadio: $isRadio, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(accountKey, categoryId, name, isRadio, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteGroup &&
          other.accountKey == this.accountKey &&
          other.categoryId == this.categoryId &&
          other.name == this.name &&
          other.isRadio == this.isRadio &&
          other.addedAt == this.addedAt);
}

class FavoriteGroupsCompanion extends UpdateCompanion<FavoriteGroup> {
  final Value<String> accountKey;
  final Value<int> categoryId;
  final Value<String> name;
  final Value<bool> isRadio;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const FavoriteGroupsCompanion({
    this.accountKey = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.name = const Value.absent(),
    this.isRadio = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoriteGroupsCompanion.insert({
    this.accountKey = const Value.absent(),
    required int categoryId,
    required String name,
    this.isRadio = const Value.absent(),
    required DateTime addedAt,
    this.rowid = const Value.absent(),
  }) : categoryId = Value(categoryId),
       name = Value(name),
       addedAt = Value(addedAt);
  static Insertable<FavoriteGroup> custom({
    Expression<String>? accountKey,
    Expression<int>? categoryId,
    Expression<String>? name,
    Expression<bool>? isRadio,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountKey != null) 'account_key': accountKey,
      if (categoryId != null) 'category_id': categoryId,
      if (name != null) 'name': name,
      if (isRadio != null) 'is_radio': isRadio,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoriteGroupsCompanion copyWith({
    Value<String>? accountKey,
    Value<int>? categoryId,
    Value<String>? name,
    Value<bool>? isRadio,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return FavoriteGroupsCompanion(
      accountKey: accountKey ?? this.accountKey,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      isRadio: isRadio ?? this.isRadio,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountKey.present) {
      map['account_key'] = Variable<String>(accountKey.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isRadio.present) {
      map['is_radio'] = Variable<bool>(isRadio.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteGroupsCompanion(')
          ..write('accountKey: $accountKey, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('isRadio: $isRadio, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HistoryTable extends History with TableInfo<$HistoryTable, HistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountKeyMeta = const VerificationMeta(
    'accountKey',
  );
  @override
  late final GeneratedColumn<String> accountKey = GeneratedColumn<String>(
    'account_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
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
  static const VerificationMeta _contentIdMeta = const VerificationMeta(
    'contentId',
  );
  @override
  late final GeneratedColumn<int> contentId = GeneratedColumn<int>(
    'content_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _logoMeta = const VerificationMeta('logo');
  @override
  late final GeneratedColumn<String> logo = GeneratedColumn<String>(
    'logo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _watchedAtMeta = const VerificationMeta(
    'watchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> watchedAt = GeneratedColumn<DateTime>(
    'watched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _streamUrlMeta = const VerificationMeta(
    'streamUrl',
  );
  @override
  late final GeneratedColumn<String> streamUrl = GeneratedColumn<String>(
    'stream_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    accountKey,
    id,
    contentId,
    contentType,
    name,
    logo,
    watchedAt,
    position,
    duration,
    streamUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_key')) {
      context.handle(
        _accountKeyMeta,
        accountKey.isAcceptableOrUnknown(data['account_key']!, _accountKeyMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('content_id')) {
      context.handle(
        _contentIdMeta,
        contentId.isAcceptableOrUnknown(data['content_id']!, _contentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contentIdMeta);
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentTypeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('logo')) {
      context.handle(
        _logoMeta,
        logo.isAcceptableOrUnknown(data['logo']!, _logoMeta),
      );
    }
    if (data.containsKey('watched_at')) {
      context.handle(
        _watchedAtMeta,
        watchedAt.isAcceptableOrUnknown(data['watched_at']!, _watchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_watchedAtMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('stream_url')) {
      context.handle(
        _streamUrlMeta,
        streamUrl.isAcceptableOrUnknown(data['stream_url']!, _streamUrlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryData(
      accountKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_key'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      contentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}content_id'],
      )!,
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      logo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo'],
      ),
      watchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}watched_at'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      ),
      streamUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stream_url'],
      ),
    );
  }

  @override
  $HistoryTable createAlias(String alias) {
    return $HistoryTable(attachedDatabase, alias);
  }
}

class HistoryData extends DataClass implements Insertable<HistoryData> {
  /// Id de la cuenta (fingerprint) a la que pertenece la fila.
  final String accountKey;
  final int id;
  final int contentId;
  final String contentType;
  final String name;
  final String? logo;
  final DateTime watchedAt;
  final int position;
  final int? duration;

  /// URL del stream en el momento de la reproducción (para "Continuar
  /// visualización" sin depender de estado de sesión/catálogo al reanudar).
  final String? streamUrl;
  const HistoryData({
    required this.accountKey,
    required this.id,
    required this.contentId,
    required this.contentType,
    required this.name,
    this.logo,
    required this.watchedAt,
    required this.position,
    this.duration,
    this.streamUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_key'] = Variable<String>(accountKey);
    map['id'] = Variable<int>(id);
    map['content_id'] = Variable<int>(contentId);
    map['content_type'] = Variable<String>(contentType);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || logo != null) {
      map['logo'] = Variable<String>(logo);
    }
    map['watched_at'] = Variable<DateTime>(watchedAt);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || duration != null) {
      map['duration'] = Variable<int>(duration);
    }
    if (!nullToAbsent || streamUrl != null) {
      map['stream_url'] = Variable<String>(streamUrl);
    }
    return map;
  }

  HistoryCompanion toCompanion(bool nullToAbsent) {
    return HistoryCompanion(
      accountKey: Value(accountKey),
      id: Value(id),
      contentId: Value(contentId),
      contentType: Value(contentType),
      name: Value(name),
      logo: logo == null && nullToAbsent ? const Value.absent() : Value(logo),
      watchedAt: Value(watchedAt),
      position: Value(position),
      duration: duration == null && nullToAbsent
          ? const Value.absent()
          : Value(duration),
      streamUrl: streamUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(streamUrl),
    );
  }

  factory HistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryData(
      accountKey: serializer.fromJson<String>(json['accountKey']),
      id: serializer.fromJson<int>(json['id']),
      contentId: serializer.fromJson<int>(json['contentId']),
      contentType: serializer.fromJson<String>(json['contentType']),
      name: serializer.fromJson<String>(json['name']),
      logo: serializer.fromJson<String?>(json['logo']),
      watchedAt: serializer.fromJson<DateTime>(json['watchedAt']),
      position: serializer.fromJson<int>(json['position']),
      duration: serializer.fromJson<int?>(json['duration']),
      streamUrl: serializer.fromJson<String?>(json['streamUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountKey': serializer.toJson<String>(accountKey),
      'id': serializer.toJson<int>(id),
      'contentId': serializer.toJson<int>(contentId),
      'contentType': serializer.toJson<String>(contentType),
      'name': serializer.toJson<String>(name),
      'logo': serializer.toJson<String?>(logo),
      'watchedAt': serializer.toJson<DateTime>(watchedAt),
      'position': serializer.toJson<int>(position),
      'duration': serializer.toJson<int?>(duration),
      'streamUrl': serializer.toJson<String?>(streamUrl),
    };
  }

  HistoryData copyWith({
    String? accountKey,
    int? id,
    int? contentId,
    String? contentType,
    String? name,
    Value<String?> logo = const Value.absent(),
    DateTime? watchedAt,
    int? position,
    Value<int?> duration = const Value.absent(),
    Value<String?> streamUrl = const Value.absent(),
  }) => HistoryData(
    accountKey: accountKey ?? this.accountKey,
    id: id ?? this.id,
    contentId: contentId ?? this.contentId,
    contentType: contentType ?? this.contentType,
    name: name ?? this.name,
    logo: logo.present ? logo.value : this.logo,
    watchedAt: watchedAt ?? this.watchedAt,
    position: position ?? this.position,
    duration: duration.present ? duration.value : this.duration,
    streamUrl: streamUrl.present ? streamUrl.value : this.streamUrl,
  );
  HistoryData copyWithCompanion(HistoryCompanion data) {
    return HistoryData(
      accountKey: data.accountKey.present
          ? data.accountKey.value
          : this.accountKey,
      id: data.id.present ? data.id.value : this.id,
      contentId: data.contentId.present ? data.contentId.value : this.contentId,
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
      name: data.name.present ? data.name.value : this.name,
      logo: data.logo.present ? data.logo.value : this.logo,
      watchedAt: data.watchedAt.present ? data.watchedAt.value : this.watchedAt,
      position: data.position.present ? data.position.value : this.position,
      duration: data.duration.present ? data.duration.value : this.duration,
      streamUrl: data.streamUrl.present ? data.streamUrl.value : this.streamUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryData(')
          ..write('accountKey: $accountKey, ')
          ..write('id: $id, ')
          ..write('contentId: $contentId, ')
          ..write('contentType: $contentType, ')
          ..write('name: $name, ')
          ..write('logo: $logo, ')
          ..write('watchedAt: $watchedAt, ')
          ..write('position: $position, ')
          ..write('duration: $duration, ')
          ..write('streamUrl: $streamUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    accountKey,
    id,
    contentId,
    contentType,
    name,
    logo,
    watchedAt,
    position,
    duration,
    streamUrl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryData &&
          other.accountKey == this.accountKey &&
          other.id == this.id &&
          other.contentId == this.contentId &&
          other.contentType == this.contentType &&
          other.name == this.name &&
          other.logo == this.logo &&
          other.watchedAt == this.watchedAt &&
          other.position == this.position &&
          other.duration == this.duration &&
          other.streamUrl == this.streamUrl);
}

class HistoryCompanion extends UpdateCompanion<HistoryData> {
  final Value<String> accountKey;
  final Value<int> id;
  final Value<int> contentId;
  final Value<String> contentType;
  final Value<String> name;
  final Value<String?> logo;
  final Value<DateTime> watchedAt;
  final Value<int> position;
  final Value<int?> duration;
  final Value<String?> streamUrl;
  const HistoryCompanion({
    this.accountKey = const Value.absent(),
    this.id = const Value.absent(),
    this.contentId = const Value.absent(),
    this.contentType = const Value.absent(),
    this.name = const Value.absent(),
    this.logo = const Value.absent(),
    this.watchedAt = const Value.absent(),
    this.position = const Value.absent(),
    this.duration = const Value.absent(),
    this.streamUrl = const Value.absent(),
  });
  HistoryCompanion.insert({
    this.accountKey = const Value.absent(),
    this.id = const Value.absent(),
    required int contentId,
    required String contentType,
    required String name,
    this.logo = const Value.absent(),
    required DateTime watchedAt,
    this.position = const Value.absent(),
    this.duration = const Value.absent(),
    this.streamUrl = const Value.absent(),
  }) : contentId = Value(contentId),
       contentType = Value(contentType),
       name = Value(name),
       watchedAt = Value(watchedAt);
  static Insertable<HistoryData> custom({
    Expression<String>? accountKey,
    Expression<int>? id,
    Expression<int>? contentId,
    Expression<String>? contentType,
    Expression<String>? name,
    Expression<String>? logo,
    Expression<DateTime>? watchedAt,
    Expression<int>? position,
    Expression<int>? duration,
    Expression<String>? streamUrl,
  }) {
    return RawValuesInsertable({
      if (accountKey != null) 'account_key': accountKey,
      if (id != null) 'id': id,
      if (contentId != null) 'content_id': contentId,
      if (contentType != null) 'content_type': contentType,
      if (name != null) 'name': name,
      if (logo != null) 'logo': logo,
      if (watchedAt != null) 'watched_at': watchedAt,
      if (position != null) 'position': position,
      if (duration != null) 'duration': duration,
      if (streamUrl != null) 'stream_url': streamUrl,
    });
  }

  HistoryCompanion copyWith({
    Value<String>? accountKey,
    Value<int>? id,
    Value<int>? contentId,
    Value<String>? contentType,
    Value<String>? name,
    Value<String?>? logo,
    Value<DateTime>? watchedAt,
    Value<int>? position,
    Value<int?>? duration,
    Value<String?>? streamUrl,
  }) {
    return HistoryCompanion(
      accountKey: accountKey ?? this.accountKey,
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      contentType: contentType ?? this.contentType,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      watchedAt: watchedAt ?? this.watchedAt,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      streamUrl: streamUrl ?? this.streamUrl,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountKey.present) {
      map['account_key'] = Variable<String>(accountKey.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contentId.present) {
      map['content_id'] = Variable<int>(contentId.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (logo.present) {
      map['logo'] = Variable<String>(logo.value);
    }
    if (watchedAt.present) {
      map['watched_at'] = Variable<DateTime>(watchedAt.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (streamUrl.present) {
      map['stream_url'] = Variable<String>(streamUrl.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryCompanion(')
          ..write('accountKey: $accountKey, ')
          ..write('id: $id, ')
          ..write('contentId: $contentId, ')
          ..write('contentType: $contentType, ')
          ..write('name: $name, ')
          ..write('logo: $logo, ')
          ..write('watchedAt: $watchedAt, ')
          ..write('position: $position, ')
          ..write('duration: $duration, ')
          ..write('streamUrl: $streamUrl')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String? value;
  const AppSetting({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  AppSetting copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
  }) => AppSetting(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LiveCategoriesTable liveCategories = $LiveCategoriesTable(this);
  late final $LiveChannelsTable liveChannels = $LiveChannelsTable(this);
  late final $VodCategoriesTable vodCategories = $VodCategoriesTable(this);
  late final $VodMoviesTable vodMovies = $VodMoviesTable(this);
  late final $SeriesCategoriesTable seriesCategories = $SeriesCategoriesTable(
    this,
  );
  late final $SeriesCacheTable seriesCache = $SeriesCacheTable(this);
  late final $FavoritesTable favorites = $FavoritesTable(this);
  late final $FavoriteGroupsTable favoriteGroups = $FavoriteGroupsTable(this);
  late final $HistoryTable history = $HistoryTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final Index liveChannelsNameIdx = Index(
    'live_channels_name_idx',
    'CREATE INDEX live_channels_name_idx ON live_channels (name)',
  );
  late final Index vodMoviesNameIdx = Index(
    'vod_movies_name_idx',
    'CREATE INDEX vod_movies_name_idx ON vod_movies (name)',
  );
  late final Index seriesCacheNameIdx = Index(
    'series_cache_name_idx',
    'CREATE INDEX series_cache_name_idx ON series_cache (name)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    liveCategories,
    liveChannels,
    vodCategories,
    vodMovies,
    seriesCategories,
    seriesCache,
    favorites,
    favoriteGroups,
    history,
    appSettings,
    liveChannelsNameIdx,
    vodMoviesNameIdx,
    seriesCacheNameIdx,
  ];
}

typedef $$LiveCategoriesTableCreateCompanionBuilder =
    LiveCategoriesCompanion Function({
      Value<String> accountKey,
      required int id,
      required String name,
      Value<int> rowid,
    });
typedef $$LiveCategoriesTableUpdateCompanionBuilder =
    LiveCategoriesCompanion Function({
      Value<String> accountKey,
      Value<int> id,
      Value<String> name,
      Value<int> rowid,
    });

class $$LiveCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $LiveCategoriesTable> {
  $$LiveCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LiveCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LiveCategoriesTable> {
  $$LiveCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LiveCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LiveCategoriesTable> {
  $$LiveCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$LiveCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LiveCategoriesTable,
          LiveCategory,
          $$LiveCategoriesTableFilterComposer,
          $$LiveCategoriesTableOrderingComposer,
          $$LiveCategoriesTableAnnotationComposer,
          $$LiveCategoriesTableCreateCompanionBuilder,
          $$LiveCategoriesTableUpdateCompanionBuilder,
          (
            LiveCategory,
            BaseReferences<_$AppDatabase, $LiveCategoriesTable, LiveCategory>,
          ),
          LiveCategory,
          PrefetchHooks Function()
        > {
  $$LiveCategoriesTableTableManager(
    _$AppDatabase db,
    $LiveCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LiveCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LiveCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LiveCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountKey = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LiveCategoriesCompanion(
                accountKey: accountKey,
                id: id,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> accountKey = const Value.absent(),
                required int id,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => LiveCategoriesCompanion.insert(
                accountKey: accountKey,
                id: id,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LiveCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LiveCategoriesTable,
      LiveCategory,
      $$LiveCategoriesTableFilterComposer,
      $$LiveCategoriesTableOrderingComposer,
      $$LiveCategoriesTableAnnotationComposer,
      $$LiveCategoriesTableCreateCompanionBuilder,
      $$LiveCategoriesTableUpdateCompanionBuilder,
      (
        LiveCategory,
        BaseReferences<_$AppDatabase, $LiveCategoriesTable, LiveCategory>,
      ),
      LiveCategory,
      PrefetchHooks Function()
    >;
typedef $$LiveChannelsTableCreateCompanionBuilder =
    LiveChannelsCompanion Function({
      Value<String> accountKey,
      Value<int> id,
      required int streamId,
      required String name,
      required int categoryId,
      Value<int?> number,
      Value<String?> logo,
      Value<String?> epgChannelId,
      Value<bool> hasArchive,
      Value<int?> archiveDurationDays,
    });
typedef $$LiveChannelsTableUpdateCompanionBuilder =
    LiveChannelsCompanion Function({
      Value<String> accountKey,
      Value<int> id,
      Value<int> streamId,
      Value<String> name,
      Value<int> categoryId,
      Value<int?> number,
      Value<String?> logo,
      Value<String?> epgChannelId,
      Value<bool> hasArchive,
      Value<int?> archiveDurationDays,
    });

class $$LiveChannelsTableFilterComposer
    extends Composer<_$AppDatabase, $LiveChannelsTable> {
  $$LiveChannelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streamId => $composableBuilder(
    column: $table.streamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logo => $composableBuilder(
    column: $table.logo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get epgChannelId => $composableBuilder(
    column: $table.epgChannelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasArchive => $composableBuilder(
    column: $table.hasArchive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get archiveDurationDays => $composableBuilder(
    column: $table.archiveDurationDays,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LiveChannelsTableOrderingComposer
    extends Composer<_$AppDatabase, $LiveChannelsTable> {
  $$LiveChannelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streamId => $composableBuilder(
    column: $table.streamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logo => $composableBuilder(
    column: $table.logo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get epgChannelId => $composableBuilder(
    column: $table.epgChannelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasArchive => $composableBuilder(
    column: $table.hasArchive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archiveDurationDays => $composableBuilder(
    column: $table.archiveDurationDays,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LiveChannelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LiveChannelsTable> {
  $$LiveChannelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get streamId =>
      $composableBuilder(column: $table.streamId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get logo =>
      $composableBuilder(column: $table.logo, builder: (column) => column);

  GeneratedColumn<String> get epgChannelId => $composableBuilder(
    column: $table.epgChannelId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasArchive => $composableBuilder(
    column: $table.hasArchive,
    builder: (column) => column,
  );

  GeneratedColumn<int> get archiveDurationDays => $composableBuilder(
    column: $table.archiveDurationDays,
    builder: (column) => column,
  );
}

class $$LiveChannelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LiveChannelsTable,
          LiveChannel,
          $$LiveChannelsTableFilterComposer,
          $$LiveChannelsTableOrderingComposer,
          $$LiveChannelsTableAnnotationComposer,
          $$LiveChannelsTableCreateCompanionBuilder,
          $$LiveChannelsTableUpdateCompanionBuilder,
          (
            LiveChannel,
            BaseReferences<_$AppDatabase, $LiveChannelsTable, LiveChannel>,
          ),
          LiveChannel,
          PrefetchHooks Function()
        > {
  $$LiveChannelsTableTableManager(_$AppDatabase db, $LiveChannelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LiveChannelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LiveChannelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LiveChannelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountKey = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int> streamId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<int?> number = const Value.absent(),
                Value<String?> logo = const Value.absent(),
                Value<String?> epgChannelId = const Value.absent(),
                Value<bool> hasArchive = const Value.absent(),
                Value<int?> archiveDurationDays = const Value.absent(),
              }) => LiveChannelsCompanion(
                accountKey: accountKey,
                id: id,
                streamId: streamId,
                name: name,
                categoryId: categoryId,
                number: number,
                logo: logo,
                epgChannelId: epgChannelId,
                hasArchive: hasArchive,
                archiveDurationDays: archiveDurationDays,
              ),
          createCompanionCallback:
              ({
                Value<String> accountKey = const Value.absent(),
                Value<int> id = const Value.absent(),
                required int streamId,
                required String name,
                required int categoryId,
                Value<int?> number = const Value.absent(),
                Value<String?> logo = const Value.absent(),
                Value<String?> epgChannelId = const Value.absent(),
                Value<bool> hasArchive = const Value.absent(),
                Value<int?> archiveDurationDays = const Value.absent(),
              }) => LiveChannelsCompanion.insert(
                accountKey: accountKey,
                id: id,
                streamId: streamId,
                name: name,
                categoryId: categoryId,
                number: number,
                logo: logo,
                epgChannelId: epgChannelId,
                hasArchive: hasArchive,
                archiveDurationDays: archiveDurationDays,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LiveChannelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LiveChannelsTable,
      LiveChannel,
      $$LiveChannelsTableFilterComposer,
      $$LiveChannelsTableOrderingComposer,
      $$LiveChannelsTableAnnotationComposer,
      $$LiveChannelsTableCreateCompanionBuilder,
      $$LiveChannelsTableUpdateCompanionBuilder,
      (
        LiveChannel,
        BaseReferences<_$AppDatabase, $LiveChannelsTable, LiveChannel>,
      ),
      LiveChannel,
      PrefetchHooks Function()
    >;
typedef $$VodCategoriesTableCreateCompanionBuilder =
    VodCategoriesCompanion Function({
      Value<String> accountKey,
      required int id,
      required String name,
      Value<int> rowid,
    });
typedef $$VodCategoriesTableUpdateCompanionBuilder =
    VodCategoriesCompanion Function({
      Value<String> accountKey,
      Value<int> id,
      Value<String> name,
      Value<int> rowid,
    });

class $$VodCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $VodCategoriesTable> {
  $$VodCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VodCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $VodCategoriesTable> {
  $$VodCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VodCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VodCategoriesTable> {
  $$VodCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$VodCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VodCategoriesTable,
          VodCategory,
          $$VodCategoriesTableFilterComposer,
          $$VodCategoriesTableOrderingComposer,
          $$VodCategoriesTableAnnotationComposer,
          $$VodCategoriesTableCreateCompanionBuilder,
          $$VodCategoriesTableUpdateCompanionBuilder,
          (
            VodCategory,
            BaseReferences<_$AppDatabase, $VodCategoriesTable, VodCategory>,
          ),
          VodCategory,
          PrefetchHooks Function()
        > {
  $$VodCategoriesTableTableManager(_$AppDatabase db, $VodCategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VodCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VodCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VodCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountKey = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VodCategoriesCompanion(
                accountKey: accountKey,
                id: id,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> accountKey = const Value.absent(),
                required int id,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => VodCategoriesCompanion.insert(
                accountKey: accountKey,
                id: id,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VodCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VodCategoriesTable,
      VodCategory,
      $$VodCategoriesTableFilterComposer,
      $$VodCategoriesTableOrderingComposer,
      $$VodCategoriesTableAnnotationComposer,
      $$VodCategoriesTableCreateCompanionBuilder,
      $$VodCategoriesTableUpdateCompanionBuilder,
      (
        VodCategory,
        BaseReferences<_$AppDatabase, $VodCategoriesTable, VodCategory>,
      ),
      VodCategory,
      PrefetchHooks Function()
    >;
typedef $$VodMoviesTableCreateCompanionBuilder = VodMoviesCompanion Function({
  Value<String> accountKey,
  Value<int> id,
  required int streamId,
  required String name,
  required int categoryId,
  Value<int?> number,
  Value<String?> streamType,
  Value<String?> streamIcon,
  Value<String?> rating,
  Value<String?> rating5Based,
  Value<String?> added,
  Value<String?> containerExtension,
  Value<String?> customSkin,
  Value<String?> directSource,
});
typedef $$VodMoviesTableUpdateCompanionBuilder = VodMoviesCompanion Function({
  Value<String> accountKey,
  Value<int> id,
  Value<int> streamId,
  Value<String> name,
  Value<int> categoryId,
  Value<int?> number,
  Value<String?> streamType,
  Value<String?> streamIcon,
  Value<String?> rating,
  Value<String?> rating5Based,
  Value<String?> added,
  Value<String?> containerExtension,
  Value<String?> customSkin,
  Value<String?> directSource,
});

class $$VodMoviesTableFilterComposer
    extends Composer<_$AppDatabase, $VodMoviesTable> {
  $$VodMoviesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streamId => $composableBuilder(
    column: $table.streamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get streamType => $composableBuilder(
    column: $table.streamType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get streamIcon => $composableBuilder(
    column: $table.streamIcon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rating5Based => $composableBuilder(
    column: $table.rating5Based,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get added => $composableBuilder(
    column: $table.added,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get containerExtension => $composableBuilder(
    column: $table.containerExtension,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customSkin => $composableBuilder(
    column: $table.customSkin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get directSource => $composableBuilder(
    column: $table.directSource,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VodMoviesTableOrderingComposer
    extends Composer<_$AppDatabase, $VodMoviesTable> {
  $$VodMoviesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streamId => $composableBuilder(
    column: $table.streamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get streamType => $composableBuilder(
    column: $table.streamType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get streamIcon => $composableBuilder(
    column: $table.streamIcon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rating5Based => $composableBuilder(
    column: $table.rating5Based,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get added => $composableBuilder(
    column: $table.added,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get containerExtension => $composableBuilder(
    column: $table.containerExtension,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customSkin => $composableBuilder(
    column: $table.customSkin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get directSource => $composableBuilder(
    column: $table.directSource,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VodMoviesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VodMoviesTable> {
  $$VodMoviesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get streamId =>
      $composableBuilder(column: $table.streamId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get streamType => $composableBuilder(
    column: $table.streamType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get streamIcon => $composableBuilder(
    column: $table.streamIcon,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get rating5Based => $composableBuilder(
    column: $table.rating5Based,
    builder: (column) => column,
  );

  GeneratedColumn<String> get added =>
      $composableBuilder(column: $table.added, builder: (column) => column);

  GeneratedColumn<String> get containerExtension => $composableBuilder(
    column: $table.containerExtension,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customSkin => $composableBuilder(
    column: $table.customSkin,
    builder: (column) => column,
  );

  GeneratedColumn<String> get directSource => $composableBuilder(
    column: $table.directSource,
    builder: (column) => column,
  );
}

class $$VodMoviesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VodMoviesTable,
          VodMovy,
          $$VodMoviesTableFilterComposer,
          $$VodMoviesTableOrderingComposer,
          $$VodMoviesTableAnnotationComposer,
          $$VodMoviesTableCreateCompanionBuilder,
          $$VodMoviesTableUpdateCompanionBuilder,
          (VodMovy, BaseReferences<_$AppDatabase, $VodMoviesTable, VodMovy>),
          VodMovy,
          PrefetchHooks Function()
        > {
  $$VodMoviesTableTableManager(_$AppDatabase db, $VodMoviesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VodMoviesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VodMoviesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VodMoviesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountKey = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int> streamId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<int?> number = const Value.absent(),
                Value<String?> streamType = const Value.absent(),
                Value<String?> streamIcon = const Value.absent(),
                Value<String?> rating = const Value.absent(),
                Value<String?> rating5Based = const Value.absent(),
                Value<String?> added = const Value.absent(),
                Value<String?> containerExtension = const Value.absent(),
                Value<String?> customSkin = const Value.absent(),
                Value<String?> directSource = const Value.absent(),
              }) => VodMoviesCompanion(
                accountKey: accountKey,
                id: id,
                streamId: streamId,
                name: name,
                categoryId: categoryId,
                number: number,
                streamType: streamType,
                streamIcon: streamIcon,
                rating: rating,
                rating5Based: rating5Based,
                added: added,
                containerExtension: containerExtension,
                customSkin: customSkin,
                directSource: directSource,
              ),
          createCompanionCallback:
              ({
                Value<String> accountKey = const Value.absent(),
                Value<int> id = const Value.absent(),
                required int streamId,
                required String name,
                required int categoryId,
                Value<int?> number = const Value.absent(),
                Value<String?> streamType = const Value.absent(),
                Value<String?> streamIcon = const Value.absent(),
                Value<String?> rating = const Value.absent(),
                Value<String?> rating5Based = const Value.absent(),
                Value<String?> added = const Value.absent(),
                Value<String?> containerExtension = const Value.absent(),
                Value<String?> customSkin = const Value.absent(),
                Value<String?> directSource = const Value.absent(),
              }) => VodMoviesCompanion.insert(
                accountKey: accountKey,
                id: id,
                streamId: streamId,
                name: name,
                categoryId: categoryId,
                number: number,
                streamType: streamType,
                streamIcon: streamIcon,
                rating: rating,
                rating5Based: rating5Based,
                added: added,
                containerExtension: containerExtension,
                customSkin: customSkin,
                directSource: directSource,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VodMoviesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VodMoviesTable,
      VodMovy,
      $$VodMoviesTableFilterComposer,
      $$VodMoviesTableOrderingComposer,
      $$VodMoviesTableAnnotationComposer,
      $$VodMoviesTableCreateCompanionBuilder,
      $$VodMoviesTableUpdateCompanionBuilder,
      (VodMovy, BaseReferences<_$AppDatabase, $VodMoviesTable, VodMovy>),
      VodMovy,
      PrefetchHooks Function()
    >;
typedef $$SeriesCategoriesTableCreateCompanionBuilder =
    SeriesCategoriesCompanion Function({
      Value<String> accountKey,
      required int id,
      required String name,
      Value<int> rowid,
    });
typedef $$SeriesCategoriesTableUpdateCompanionBuilder =
    SeriesCategoriesCompanion Function({
      Value<String> accountKey,
      Value<int> id,
      Value<String> name,
      Value<int> rowid,
    });

class $$SeriesCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $SeriesCategoriesTable> {
  $$SeriesCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SeriesCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SeriesCategoriesTable> {
  $$SeriesCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SeriesCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeriesCategoriesTable> {
  $$SeriesCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$SeriesCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeriesCategoriesTable,
          SeriesCategory,
          $$SeriesCategoriesTableFilterComposer,
          $$SeriesCategoriesTableOrderingComposer,
          $$SeriesCategoriesTableAnnotationComposer,
          $$SeriesCategoriesTableCreateCompanionBuilder,
          $$SeriesCategoriesTableUpdateCompanionBuilder,
          (
            SeriesCategory,
            BaseReferences<
              _$AppDatabase,
              $SeriesCategoriesTable,
              SeriesCategory
            >,
          ),
          SeriesCategory,
          PrefetchHooks Function()
        > {
  $$SeriesCategoriesTableTableManager(
    _$AppDatabase db,
    $SeriesCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeriesCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeriesCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeriesCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountKey = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeriesCategoriesCompanion(
                accountKey: accountKey,
                id: id,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> accountKey = const Value.absent(),
                required int id,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => SeriesCategoriesCompanion.insert(
                accountKey: accountKey,
                id: id,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SeriesCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeriesCategoriesTable,
      SeriesCategory,
      $$SeriesCategoriesTableFilterComposer,
      $$SeriesCategoriesTableOrderingComposer,
      $$SeriesCategoriesTableAnnotationComposer,
      $$SeriesCategoriesTableCreateCompanionBuilder,
      $$SeriesCategoriesTableUpdateCompanionBuilder,
      (
        SeriesCategory,
        BaseReferences<_$AppDatabase, $SeriesCategoriesTable, SeriesCategory>,
      ),
      SeriesCategory,
      PrefetchHooks Function()
    >;
typedef $$SeriesCacheTableCreateCompanionBuilder =
    SeriesCacheCompanion Function({
      Value<String> accountKey,
      Value<int> id,
      required int seriesId,
      required String name,
      Value<int?> number,
      Value<int?> season,
      Value<String?> cover,
      Value<String?> plot,
      Value<String?> cast,
      Value<String?> director,
      Value<String?> genre,
      Value<String?> releaseDate,
      Value<String?> lastModified,
      Value<String?> rating,
      Value<String?> rating5Based,
      Value<String?> backdropPath,
      Value<String?> youtubeTrailer,
      Value<String?> episodeRunTime,
      Value<int?> categoryId,
    });
typedef $$SeriesCacheTableUpdateCompanionBuilder =
    SeriesCacheCompanion Function({
      Value<String> accountKey,
      Value<int> id,
      Value<int> seriesId,
      Value<String> name,
      Value<int?> number,
      Value<int?> season,
      Value<String?> cover,
      Value<String?> plot,
      Value<String?> cast,
      Value<String?> director,
      Value<String?> genre,
      Value<String?> releaseDate,
      Value<String?> lastModified,
      Value<String?> rating,
      Value<String?> rating5Based,
      Value<String?> backdropPath,
      Value<String?> youtubeTrailer,
      Value<String?> episodeRunTime,
      Value<int?> categoryId,
    });

class $$SeriesCacheTableFilterComposer
    extends Composer<_$AppDatabase, $SeriesCacheTable> {
  $$SeriesCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cover => $composableBuilder(
    column: $table.cover,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plot => $composableBuilder(
    column: $table.plot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cast => $composableBuilder(
    column: $table.cast,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get director => $composableBuilder(
    column: $table.director,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rating5Based => $composableBuilder(
    column: $table.rating5Based,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backdropPath => $composableBuilder(
    column: $table.backdropPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get youtubeTrailer => $composableBuilder(
    column: $table.youtubeTrailer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get episodeRunTime => $composableBuilder(
    column: $table.episodeRunTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SeriesCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $SeriesCacheTable> {
  $$SeriesCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cover => $composableBuilder(
    column: $table.cover,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plot => $composableBuilder(
    column: $table.plot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cast => $composableBuilder(
    column: $table.cast,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get director => $composableBuilder(
    column: $table.director,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rating5Based => $composableBuilder(
    column: $table.rating5Based,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backdropPath => $composableBuilder(
    column: $table.backdropPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get youtubeTrailer => $composableBuilder(
    column: $table.youtubeTrailer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get episodeRunTime => $composableBuilder(
    column: $table.episodeRunTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SeriesCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeriesCacheTable> {
  $$SeriesCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get seriesId =>
      $composableBuilder(column: $table.seriesId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<int> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<String> get cover =>
      $composableBuilder(column: $table.cover, builder: (column) => column);

  GeneratedColumn<String> get plot =>
      $composableBuilder(column: $table.plot, builder: (column) => column);

  GeneratedColumn<String> get cast =>
      $composableBuilder(column: $table.cast, builder: (column) => column);

  GeneratedColumn<String> get director =>
      $composableBuilder(column: $table.director, builder: (column) => column);

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<String> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get rating5Based => $composableBuilder(
    column: $table.rating5Based,
    builder: (column) => column,
  );

  GeneratedColumn<String> get backdropPath => $composableBuilder(
    column: $table.backdropPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get youtubeTrailer => $composableBuilder(
    column: $table.youtubeTrailer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get episodeRunTime => $composableBuilder(
    column: $table.episodeRunTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );
}

class $$SeriesCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeriesCacheTable,
          SeriesCacheData,
          $$SeriesCacheTableFilterComposer,
          $$SeriesCacheTableOrderingComposer,
          $$SeriesCacheTableAnnotationComposer,
          $$SeriesCacheTableCreateCompanionBuilder,
          $$SeriesCacheTableUpdateCompanionBuilder,
          (
            SeriesCacheData,
            BaseReferences<_$AppDatabase, $SeriesCacheTable, SeriesCacheData>,
          ),
          SeriesCacheData,
          PrefetchHooks Function()
        > {
  $$SeriesCacheTableTableManager(_$AppDatabase db, $SeriesCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeriesCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeriesCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeriesCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountKey = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int> seriesId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> number = const Value.absent(),
                Value<int?> season = const Value.absent(),
                Value<String?> cover = const Value.absent(),
                Value<String?> plot = const Value.absent(),
                Value<String?> cast = const Value.absent(),
                Value<String?> director = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<String?> releaseDate = const Value.absent(),
                Value<String?> lastModified = const Value.absent(),
                Value<String?> rating = const Value.absent(),
                Value<String?> rating5Based = const Value.absent(),
                Value<String?> backdropPath = const Value.absent(),
                Value<String?> youtubeTrailer = const Value.absent(),
                Value<String?> episodeRunTime = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
              }) => SeriesCacheCompanion(
                accountKey: accountKey,
                id: id,
                seriesId: seriesId,
                name: name,
                number: number,
                season: season,
                cover: cover,
                plot: plot,
                cast: cast,
                director: director,
                genre: genre,
                releaseDate: releaseDate,
                lastModified: lastModified,
                rating: rating,
                rating5Based: rating5Based,
                backdropPath: backdropPath,
                youtubeTrailer: youtubeTrailer,
                episodeRunTime: episodeRunTime,
                categoryId: categoryId,
              ),
          createCompanionCallback:
              ({
                Value<String> accountKey = const Value.absent(),
                Value<int> id = const Value.absent(),
                required int seriesId,
                required String name,
                Value<int?> number = const Value.absent(),
                Value<int?> season = const Value.absent(),
                Value<String?> cover = const Value.absent(),
                Value<String?> plot = const Value.absent(),
                Value<String?> cast = const Value.absent(),
                Value<String?> director = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<String?> releaseDate = const Value.absent(),
                Value<String?> lastModified = const Value.absent(),
                Value<String?> rating = const Value.absent(),
                Value<String?> rating5Based = const Value.absent(),
                Value<String?> backdropPath = const Value.absent(),
                Value<String?> youtubeTrailer = const Value.absent(),
                Value<String?> episodeRunTime = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
              }) => SeriesCacheCompanion.insert(
                accountKey: accountKey,
                id: id,
                seriesId: seriesId,
                name: name,
                number: number,
                season: season,
                cover: cover,
                plot: plot,
                cast: cast,
                director: director,
                genre: genre,
                releaseDate: releaseDate,
                lastModified: lastModified,
                rating: rating,
                rating5Based: rating5Based,
                backdropPath: backdropPath,
                youtubeTrailer: youtubeTrailer,
                episodeRunTime: episodeRunTime,
                categoryId: categoryId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SeriesCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeriesCacheTable,
      SeriesCacheData,
      $$SeriesCacheTableFilterComposer,
      $$SeriesCacheTableOrderingComposer,
      $$SeriesCacheTableAnnotationComposer,
      $$SeriesCacheTableCreateCompanionBuilder,
      $$SeriesCacheTableUpdateCompanionBuilder,
      (
        SeriesCacheData,
        BaseReferences<_$AppDatabase, $SeriesCacheTable, SeriesCacheData>,
      ),
      SeriesCacheData,
      PrefetchHooks Function()
    >;
typedef $$FavoritesTableCreateCompanionBuilder = FavoritesCompanion Function({
  Value<String> accountKey,
  Value<int> id,
  required int contentId,
  required String contentType,
  required String name,
  Value<String?> logo,
  required DateTime addedAt,
});
typedef $$FavoritesTableUpdateCompanionBuilder = FavoritesCompanion Function({
  Value<String> accountKey,
  Value<int> id,
  Value<int> contentId,
  Value<String> contentType,
  Value<String> name,
  Value<String?> logo,
  Value<DateTime> addedAt,
});

class $$FavoritesTableFilterComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contentId => $composableBuilder(
    column: $table.contentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logo => $composableBuilder(
    column: $table.logo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoritesTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contentId => $composableBuilder(
    column: $table.contentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logo => $composableBuilder(
    column: $table.logo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoritesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get contentId =>
      $composableBuilder(column: $table.contentId, builder: (column) => column);

  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get logo =>
      $composableBuilder(column: $table.logo, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$FavoritesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoritesTable,
          Favorite,
          $$FavoritesTableFilterComposer,
          $$FavoritesTableOrderingComposer,
          $$FavoritesTableAnnotationComposer,
          $$FavoritesTableCreateCompanionBuilder,
          $$FavoritesTableUpdateCompanionBuilder,
          (Favorite, BaseReferences<_$AppDatabase, $FavoritesTable, Favorite>),
          Favorite,
          PrefetchHooks Function()
        > {
  $$FavoritesTableTableManager(_$AppDatabase db, $FavoritesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountKey = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int> contentId = const Value.absent(),
                Value<String> contentType = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> logo = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => FavoritesCompanion(
                accountKey: accountKey,
                id: id,
                contentId: contentId,
                contentType: contentType,
                name: name,
                logo: logo,
                addedAt: addedAt,
              ),
          createCompanionCallback:
              ({
                Value<String> accountKey = const Value.absent(),
                Value<int> id = const Value.absent(),
                required int contentId,
                required String contentType,
                required String name,
                Value<String?> logo = const Value.absent(),
                required DateTime addedAt,
              }) => FavoritesCompanion.insert(
                accountKey: accountKey,
                id: id,
                contentId: contentId,
                contentType: contentType,
                name: name,
                logo: logo,
                addedAt: addedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoritesTable,
      Favorite,
      $$FavoritesTableFilterComposer,
      $$FavoritesTableOrderingComposer,
      $$FavoritesTableAnnotationComposer,
      $$FavoritesTableCreateCompanionBuilder,
      $$FavoritesTableUpdateCompanionBuilder,
      (Favorite, BaseReferences<_$AppDatabase, $FavoritesTable, Favorite>),
      Favorite,
      PrefetchHooks Function()
    >;
typedef $$FavoriteGroupsTableCreateCompanionBuilder =
    FavoriteGroupsCompanion Function({
      Value<String> accountKey,
      required int categoryId,
      required String name,
      Value<bool> isRadio,
      required DateTime addedAt,
      Value<int> rowid,
    });
typedef $$FavoriteGroupsTableUpdateCompanionBuilder =
    FavoriteGroupsCompanion Function({
      Value<String> accountKey,
      Value<int> categoryId,
      Value<String> name,
      Value<bool> isRadio,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });

class $$FavoriteGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $FavoriteGroupsTable> {
  $$FavoriteGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRadio => $composableBuilder(
    column: $table.isRadio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoriteGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoriteGroupsTable> {
  $$FavoriteGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRadio => $composableBuilder(
    column: $table.isRadio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoriteGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoriteGroupsTable> {
  $$FavoriteGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isRadio =>
      $composableBuilder(column: $table.isRadio, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$FavoriteGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoriteGroupsTable,
          FavoriteGroup,
          $$FavoriteGroupsTableFilterComposer,
          $$FavoriteGroupsTableOrderingComposer,
          $$FavoriteGroupsTableAnnotationComposer,
          $$FavoriteGroupsTableCreateCompanionBuilder,
          $$FavoriteGroupsTableUpdateCompanionBuilder,
          (
            FavoriteGroup,
            BaseReferences<_$AppDatabase, $FavoriteGroupsTable, FavoriteGroup>,
          ),
          FavoriteGroup,
          PrefetchHooks Function()
        > {
  $$FavoriteGroupsTableTableManager(
    _$AppDatabase db,
    $FavoriteGroupsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoriteGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountKey = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isRadio = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoriteGroupsCompanion(
                accountKey: accountKey,
                categoryId: categoryId,
                name: name,
                isRadio: isRadio,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> accountKey = const Value.absent(),
                required int categoryId,
                required String name,
                Value<bool> isRadio = const Value.absent(),
                required DateTime addedAt,
                Value<int> rowid = const Value.absent(),
              }) => FavoriteGroupsCompanion.insert(
                accountKey: accountKey,
                categoryId: categoryId,
                name: name,
                isRadio: isRadio,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoriteGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoriteGroupsTable,
      FavoriteGroup,
      $$FavoriteGroupsTableFilterComposer,
      $$FavoriteGroupsTableOrderingComposer,
      $$FavoriteGroupsTableAnnotationComposer,
      $$FavoriteGroupsTableCreateCompanionBuilder,
      $$FavoriteGroupsTableUpdateCompanionBuilder,
      (
        FavoriteGroup,
        BaseReferences<_$AppDatabase, $FavoriteGroupsTable, FavoriteGroup>,
      ),
      FavoriteGroup,
      PrefetchHooks Function()
    >;
typedef $$HistoryTableCreateCompanionBuilder = HistoryCompanion Function({
  Value<String> accountKey,
  Value<int> id,
  required int contentId,
  required String contentType,
  required String name,
  Value<String?> logo,
  required DateTime watchedAt,
  Value<int> position,
  Value<int?> duration,
  Value<String?> streamUrl,
});
typedef $$HistoryTableUpdateCompanionBuilder = HistoryCompanion Function({
  Value<String> accountKey,
  Value<int> id,
  Value<int> contentId,
  Value<String> contentType,
  Value<String> name,
  Value<String?> logo,
  Value<DateTime> watchedAt,
  Value<int> position,
  Value<int?> duration,
  Value<String?> streamUrl,
});

class $$HistoryTableFilterComposer
    extends Composer<_$AppDatabase, $HistoryTable> {
  $$HistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contentId => $composableBuilder(
    column: $table.contentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logo => $composableBuilder(
    column: $table.logo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get watchedAt => $composableBuilder(
    column: $table.watchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get streamUrl => $composableBuilder(
    column: $table.streamUrl,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $HistoryTable> {
  $$HistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contentId => $composableBuilder(
    column: $table.contentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logo => $composableBuilder(
    column: $table.logo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get watchedAt => $composableBuilder(
    column: $table.watchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get streamUrl => $composableBuilder(
    column: $table.streamUrl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistoryTable> {
  $$HistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get contentId =>
      $composableBuilder(column: $table.contentId, builder: (column) => column);

  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get logo =>
      $composableBuilder(column: $table.logo, builder: (column) => column);

  GeneratedColumn<DateTime> get watchedAt =>
      $composableBuilder(column: $table.watchedAt, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<String> get streamUrl =>
      $composableBuilder(column: $table.streamUrl, builder: (column) => column);
}

class $$HistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HistoryTable,
          HistoryData,
          $$HistoryTableFilterComposer,
          $$HistoryTableOrderingComposer,
          $$HistoryTableAnnotationComposer,
          $$HistoryTableCreateCompanionBuilder,
          $$HistoryTableUpdateCompanionBuilder,
          (
            HistoryData,
            BaseReferences<_$AppDatabase, $HistoryTable, HistoryData>,
          ),
          HistoryData,
          PrefetchHooks Function()
        > {
  $$HistoryTableTableManager(_$AppDatabase db, $HistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountKey = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int> contentId = const Value.absent(),
                Value<String> contentType = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> logo = const Value.absent(),
                Value<DateTime> watchedAt = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int?> duration = const Value.absent(),
                Value<String?> streamUrl = const Value.absent(),
              }) => HistoryCompanion(
                accountKey: accountKey,
                id: id,
                contentId: contentId,
                contentType: contentType,
                name: name,
                logo: logo,
                watchedAt: watchedAt,
                position: position,
                duration: duration,
                streamUrl: streamUrl,
              ),
          createCompanionCallback:
              ({
                Value<String> accountKey = const Value.absent(),
                Value<int> id = const Value.absent(),
                required int contentId,
                required String contentType,
                required String name,
                Value<String?> logo = const Value.absent(),
                required DateTime watchedAt,
                Value<int> position = const Value.absent(),
                Value<int?> duration = const Value.absent(),
                Value<String?> streamUrl = const Value.absent(),
              }) => HistoryCompanion.insert(
                accountKey: accountKey,
                id: id,
                contentId: contentId,
                contentType: contentType,
                name: name,
                logo: logo,
                watchedAt: watchedAt,
                position: position,
                duration: duration,
                streamUrl: streamUrl,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HistoryTable,
      HistoryData,
      $$HistoryTableFilterComposer,
      $$HistoryTableOrderingComposer,
      $$HistoryTableAnnotationComposer,
      $$HistoryTableCreateCompanionBuilder,
      $$HistoryTableUpdateCompanionBuilder,
      (HistoryData, BaseReferences<_$AppDatabase, $HistoryTable, HistoryData>),
      HistoryData,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      Value<String?> value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String?> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LiveCategoriesTableTableManager get liveCategories =>
      $$LiveCategoriesTableTableManager(_db, _db.liveCategories);
  $$LiveChannelsTableTableManager get liveChannels =>
      $$LiveChannelsTableTableManager(_db, _db.liveChannels);
  $$VodCategoriesTableTableManager get vodCategories =>
      $$VodCategoriesTableTableManager(_db, _db.vodCategories);
  $$VodMoviesTableTableManager get vodMovies =>
      $$VodMoviesTableTableManager(_db, _db.vodMovies);
  $$SeriesCategoriesTableTableManager get seriesCategories =>
      $$SeriesCategoriesTableTableManager(_db, _db.seriesCategories);
  $$SeriesCacheTableTableManager get seriesCache =>
      $$SeriesCacheTableTableManager(_db, _db.seriesCache);
  $$FavoritesTableTableManager get favorites =>
      $$FavoritesTableTableManager(_db, _db.favorites);
  $$FavoriteGroupsTableTableManager get favoriteGroups =>
      $$FavoriteGroupsTableTableManager(_db, _db.favoriteGroups);
  $$HistoryTableTableManager get history =>
      $$HistoryTableTableManager(_db, _db.history);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
