// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LiveCategoriesTable extends LiveCategories
    with TableInfo<$LiveCategoriesTable, LiveCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LiveCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  List<GeneratedColumn> get $columns => [id, name];
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
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LiveCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LiveCategory(
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
  final int id;
  final String name;
  const LiveCategory({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  LiveCategoriesCompanion toCompanion(bool nullToAbsent) {
    return LiveCategoriesCompanion(id: Value(id), name: Value(name));
  }

  factory LiveCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LiveCategory(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  LiveCategory copyWith({int? id, String? name}) =>
      LiveCategory(id: id ?? this.id, name: name ?? this.name);
  LiveCategory copyWithCompanion(LiveCategoriesCompanion data) {
    return LiveCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LiveCategory(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LiveCategory && other.id == this.id && other.name == this.name);
}

class LiveCategoriesCompanion extends UpdateCompanion<LiveCategory> {
  final Value<int> id;
  final Value<String> name;
  const LiveCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  LiveCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<LiveCategory> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  LiveCategoriesCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return LiveCategoriesCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LiveCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
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
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    streamId,
    name,
    categoryId,
    number,
    logo,
    epgChannelId,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LiveChannel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LiveChannel(
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
    );
  }

  @override
  $LiveChannelsTable createAlias(String alias) {
    return $LiveChannelsTable(attachedDatabase, alias);
  }
}

class LiveChannel extends DataClass implements Insertable<LiveChannel> {
  final int id;
  final int streamId;
  final String name;
  final int categoryId;
  final int? number;
  final String? logo;
  final String? epgChannelId;
  const LiveChannel({
    required this.id,
    required this.streamId,
    required this.name,
    required this.categoryId,
    this.number,
    this.logo,
    this.epgChannelId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
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
    return map;
  }

  LiveChannelsCompanion toCompanion(bool nullToAbsent) {
    return LiveChannelsCompanion(
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
    );
  }

  factory LiveChannel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LiveChannel(
      id: serializer.fromJson<int>(json['id']),
      streamId: serializer.fromJson<int>(json['streamId']),
      name: serializer.fromJson<String>(json['name']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      number: serializer.fromJson<int?>(json['number']),
      logo: serializer.fromJson<String?>(json['logo']),
      epgChannelId: serializer.fromJson<String?>(json['epgChannelId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'streamId': serializer.toJson<int>(streamId),
      'name': serializer.toJson<String>(name),
      'categoryId': serializer.toJson<int>(categoryId),
      'number': serializer.toJson<int?>(number),
      'logo': serializer.toJson<String?>(logo),
      'epgChannelId': serializer.toJson<String?>(epgChannelId),
    };
  }

  LiveChannel copyWith({
    int? id,
    int? streamId,
    String? name,
    int? categoryId,
    Value<int?> number = const Value.absent(),
    Value<String?> logo = const Value.absent(),
    Value<String?> epgChannelId = const Value.absent(),
  }) => LiveChannel(
    id: id ?? this.id,
    streamId: streamId ?? this.streamId,
    name: name ?? this.name,
    categoryId: categoryId ?? this.categoryId,
    number: number.present ? number.value : this.number,
    logo: logo.present ? logo.value : this.logo,
    epgChannelId: epgChannelId.present ? epgChannelId.value : this.epgChannelId,
  );
  LiveChannel copyWithCompanion(LiveChannelsCompanion data) {
    return LiveChannel(
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
    );
  }

  @override
  String toString() {
    return (StringBuffer('LiveChannel(')
          ..write('id: $id, ')
          ..write('streamId: $streamId, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('number: $number, ')
          ..write('logo: $logo, ')
          ..write('epgChannelId: $epgChannelId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, streamId, name, categoryId, number, logo, epgChannelId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LiveChannel &&
          other.id == this.id &&
          other.streamId == this.streamId &&
          other.name == this.name &&
          other.categoryId == this.categoryId &&
          other.number == this.number &&
          other.logo == this.logo &&
          other.epgChannelId == this.epgChannelId);
}

class LiveChannelsCompanion extends UpdateCompanion<LiveChannel> {
  final Value<int> id;
  final Value<int> streamId;
  final Value<String> name;
  final Value<int> categoryId;
  final Value<int?> number;
  final Value<String?> logo;
  final Value<String?> epgChannelId;
  const LiveChannelsCompanion({
    this.id = const Value.absent(),
    this.streamId = const Value.absent(),
    this.name = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.number = const Value.absent(),
    this.logo = const Value.absent(),
    this.epgChannelId = const Value.absent(),
  });
  LiveChannelsCompanion.insert({
    this.id = const Value.absent(),
    required int streamId,
    required String name,
    required int categoryId,
    this.number = const Value.absent(),
    this.logo = const Value.absent(),
    this.epgChannelId = const Value.absent(),
  }) : streamId = Value(streamId),
       name = Value(name),
       categoryId = Value(categoryId);
  static Insertable<LiveChannel> custom({
    Expression<int>? id,
    Expression<int>? streamId,
    Expression<String>? name,
    Expression<int>? categoryId,
    Expression<int>? number,
    Expression<String>? logo,
    Expression<String>? epgChannelId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (streamId != null) 'stream_id': streamId,
      if (name != null) 'name': name,
      if (categoryId != null) 'category_id': categoryId,
      if (number != null) 'number': number,
      if (logo != null) 'logo': logo,
      if (epgChannelId != null) 'epg_channel_id': epgChannelId,
    });
  }

  LiveChannelsCompanion copyWith({
    Value<int>? id,
    Value<int>? streamId,
    Value<String>? name,
    Value<int>? categoryId,
    Value<int?>? number,
    Value<String?>? logo,
    Value<String?>? epgChannelId,
  }) {
    return LiveChannelsCompanion(
      id: id ?? this.id,
      streamId: streamId ?? this.streamId,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      number: number ?? this.number,
      logo: logo ?? this.logo,
      epgChannelId: epgChannelId ?? this.epgChannelId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LiveChannelsCompanion(')
          ..write('id: $id, ')
          ..write('streamId: $streamId, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('number: $number, ')
          ..write('logo: $logo, ')
          ..write('epgChannelId: $epgChannelId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LiveCategoriesTable liveCategories = $LiveCategoriesTable(this);
  late final $LiveChannelsTable liveChannels = $LiveChannelsTable(this);
  late final Index liveChannelsNameIdx = Index(
    'live_channels_name_idx',
    'CREATE INDEX live_channels_name_idx ON live_channels (name)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    liveCategories,
    liveChannels,
    liveChannelsNameIdx,
  ];
}

typedef $$LiveCategoriesTableCreateCompanionBuilder =
    LiveCategoriesCompanion Function({Value<int> id, required String name});
typedef $$LiveCategoriesTableUpdateCompanionBuilder =
    LiveCategoriesCompanion Function({Value<int> id, Value<String> name});

class $$LiveCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $LiveCategoriesTable> {
  $$LiveCategoriesTableFilterComposer({
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
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) => LiveCategoriesCompanion(id: id, name: name),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) => LiveCategoriesCompanion.insert(id: id, name: name),
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
      Value<int> id,
      required int streamId,
      required String name,
      required int categoryId,
      Value<int?> number,
      Value<String?> logo,
      Value<String?> epgChannelId,
    });
typedef $$LiveChannelsTableUpdateCompanionBuilder =
    LiveChannelsCompanion Function({
      Value<int> id,
      Value<int> streamId,
      Value<String> name,
      Value<int> categoryId,
      Value<int?> number,
      Value<String?> logo,
      Value<String?> epgChannelId,
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
                Value<int> id = const Value.absent(),
                Value<int> streamId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<int?> number = const Value.absent(),
                Value<String?> logo = const Value.absent(),
                Value<String?> epgChannelId = const Value.absent(),
              }) => LiveChannelsCompanion(
                id: id,
                streamId: streamId,
                name: name,
                categoryId: categoryId,
                number: number,
                logo: logo,
                epgChannelId: epgChannelId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int streamId,
                required String name,
                required int categoryId,
                Value<int?> number = const Value.absent(),
                Value<String?> logo = const Value.absent(),
                Value<String?> epgChannelId = const Value.absent(),
              }) => LiveChannelsCompanion.insert(
                id: id,
                streamId: streamId,
                name: name,
                categoryId: categoryId,
                number: number,
                logo: logo,
                epgChannelId: epgChannelId,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LiveCategoriesTableTableManager get liveCategories =>
      $$LiveCategoriesTableTableManager(_db, _db.liveCategories);
  $$LiveChannelsTableTableManager get liveChannels =>
      $$LiveChannelsTableTableManager(_db, _db.liveChannels);
}
