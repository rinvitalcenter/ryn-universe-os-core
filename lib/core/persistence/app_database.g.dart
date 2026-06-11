// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 1000),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valueTypeMeta = const VerificationMeta(
    'valueType',
  );
  @override
  late final GeneratedColumn<String> valueType = GeneratedColumn<String>(
    'value_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('string'),
  );
  static const VerificationMeta _redactionStateMeta = const VerificationMeta(
    'redactionState',
  );
  @override
  late final GeneratedColumn<String> redactionState = GeneratedColumn<String>(
    'redaction_state',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none_required'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    key,
    value,
    valueType,
    redactionState,
    updatedAt,
  ];
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
    if (data.containsKey('value_type')) {
      context.handle(
        _valueTypeMeta,
        valueType.isAcceptableOrUnknown(data['value_type']!, _valueTypeMeta),
      );
    }
    if (data.containsKey('redaction_state')) {
      context.handle(
        _redactionStateMeta,
        redactionState.isAcceptableOrUnknown(
          data['redaction_state']!,
          _redactionStateMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
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
      valueType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_type'],
      )!,
      redactionState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}redaction_state'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
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
  final String valueType;
  final String redactionState;
  final DateTime updatedAt;
  const AppSetting({
    required this.key,
    this.value,
    required this.valueType,
    required this.redactionState,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    map['value_type'] = Variable<String>(valueType);
    map['redaction_state'] = Variable<String>(redactionState);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
      valueType: Value(valueType),
      redactionState: Value(redactionState),
      updatedAt: Value(updatedAt),
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
      valueType: serializer.fromJson<String>(json['valueType']),
      redactionState: serializer.fromJson<String>(json['redactionState']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
      'valueType': serializer.toJson<String>(valueType),
      'redactionState': serializer.toJson<String>(redactionState),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSetting copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
    String? valueType,
    String? redactionState,
    DateTime? updatedAt,
  }) => AppSetting(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
    valueType: valueType ?? this.valueType,
    redactionState: redactionState ?? this.redactionState,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      valueType: data.valueType.present ? data.valueType.value : this.valueType,
      redactionState: data.redactionState.present
          ? data.redactionState.value
          : this.redactionState,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('valueType: $valueType, ')
          ..write('redactionState: $redactionState, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(key, value, valueType, redactionState, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.valueType == this.valueType &&
          other.redactionState == this.redactionState &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String?> value;
  final Value<String> valueType;
  final Value<String> redactionState;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.valueType = const Value.absent(),
    this.redactionState = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.valueType = const Value.absent(),
    this.redactionState = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       updatedAt = Value(updatedAt);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<String>? valueType,
    Expression<String>? redactionState,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (valueType != null) 'value_type': valueType,
      if (redactionState != null) 'redaction_state': redactionState,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<String>? valueType,
    Value<String>? redactionState,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      valueType: valueType ?? this.valueType,
      redactionState: redactionState ?? this.redactionState,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (valueType.present) {
      map['value_type'] = Variable<String>(valueType.value);
    }
    if (redactionState.present) {
      map['redaction_state'] = Variable<String>(redactionState.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
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
          ..write('valueType: $valueType, ')
          ..write('redactionState: $redactionState, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ObsidianReportRefsTable extends ObsidianReportRefs
    with TableInfo<$ObsidianReportRefsTable, ObsidianReportRef> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ObsidianReportRefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _docTypeMeta = const VerificationMeta(
    'docType',
  );
  @override
  late final GeneratedColumn<String> docType = GeneratedColumn<String>(
    'doc_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vaultPathMeta = const VerificationMeta(
    'vaultPath',
  );
  @override
  late final GeneratedColumn<String> vaultPath = GeneratedColumn<String>(
    'vault_path',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 500,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 64,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _redactionStateMeta = const VerificationMeta(
    'redactionState',
  );
  @override
  late final GeneratedColumn<String> redactionState = GeneratedColumn<String>(
    'redaction_state',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none_required'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    docType,
    vaultPath,
    sha256,
    redactionState,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'obsidian_report_refs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ObsidianReportRef> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('doc_type')) {
      context.handle(
        _docTypeMeta,
        docType.isAcceptableOrUnknown(data['doc_type']!, _docTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_docTypeMeta);
    }
    if (data.containsKey('vault_path')) {
      context.handle(
        _vaultPathMeta,
        vaultPath.isAcceptableOrUnknown(data['vault_path']!, _vaultPathMeta),
      );
    } else if (isInserting) {
      context.missing(_vaultPathMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    }
    if (data.containsKey('redaction_state')) {
      context.handle(
        _redactionStateMeta,
        redactionState.isAcceptableOrUnknown(
          data['redaction_state']!,
          _redactionStateMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ObsidianReportRef map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ObsidianReportRef(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      docType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doc_type'],
      )!,
      vaultPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vault_path'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      ),
      redactionState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}redaction_state'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $ObsidianReportRefsTable createAlias(String alias) {
    return $ObsidianReportRefsTable(attachedDatabase, alias);
  }
}

class ObsidianReportRef extends DataClass
    implements Insertable<ObsidianReportRef> {
  final String id;
  final String docType;
  final String vaultPath;
  final String? sha256;
  final String redactionState;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const ObsidianReportRef({
    required this.id,
    required this.docType,
    required this.vaultPath,
    this.sha256,
    required this.redactionState,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['doc_type'] = Variable<String>(docType);
    map['vault_path'] = Variable<String>(vaultPath);
    if (!nullToAbsent || sha256 != null) {
      map['sha256'] = Variable<String>(sha256);
    }
    map['redaction_state'] = Variable<String>(redactionState);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  ObsidianReportRefsCompanion toCompanion(bool nullToAbsent) {
    return ObsidianReportRefsCompanion(
      id: Value(id),
      docType: Value(docType),
      vaultPath: Value(vaultPath),
      sha256: sha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(sha256),
      redactionState: Value(redactionState),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory ObsidianReportRef.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ObsidianReportRef(
      id: serializer.fromJson<String>(json['id']),
      docType: serializer.fromJson<String>(json['docType']),
      vaultPath: serializer.fromJson<String>(json['vaultPath']),
      sha256: serializer.fromJson<String?>(json['sha256']),
      redactionState: serializer.fromJson<String>(json['redactionState']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'docType': serializer.toJson<String>(docType),
      'vaultPath': serializer.toJson<String>(vaultPath),
      'sha256': serializer.toJson<String?>(sha256),
      'redactionState': serializer.toJson<String>(redactionState),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  ObsidianReportRef copyWith({
    String? id,
    String? docType,
    String? vaultPath,
    Value<String?> sha256 = const Value.absent(),
    String? redactionState,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => ObsidianReportRef(
    id: id ?? this.id,
    docType: docType ?? this.docType,
    vaultPath: vaultPath ?? this.vaultPath,
    sha256: sha256.present ? sha256.value : this.sha256,
    redactionState: redactionState ?? this.redactionState,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  ObsidianReportRef copyWithCompanion(ObsidianReportRefsCompanion data) {
    return ObsidianReportRef(
      id: data.id.present ? data.id.value : this.id,
      docType: data.docType.present ? data.docType.value : this.docType,
      vaultPath: data.vaultPath.present ? data.vaultPath.value : this.vaultPath,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      redactionState: data.redactionState.present
          ? data.redactionState.value
          : this.redactionState,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ObsidianReportRef(')
          ..write('id: $id, ')
          ..write('docType: $docType, ')
          ..write('vaultPath: $vaultPath, ')
          ..write('sha256: $sha256, ')
          ..write('redactionState: $redactionState, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    docType,
    vaultPath,
    sha256,
    redactionState,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ObsidianReportRef &&
          other.id == this.id &&
          other.docType == this.docType &&
          other.vaultPath == this.vaultPath &&
          other.sha256 == this.sha256 &&
          other.redactionState == this.redactionState &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ObsidianReportRefsCompanion extends UpdateCompanion<ObsidianReportRef> {
  final Value<String> id;
  final Value<String> docType;
  final Value<String> vaultPath;
  final Value<String?> sha256;
  final Value<String> redactionState;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const ObsidianReportRefsCompanion({
    this.id = const Value.absent(),
    this.docType = const Value.absent(),
    this.vaultPath = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.redactionState = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ObsidianReportRefsCompanion.insert({
    required String id,
    required String docType,
    required String vaultPath,
    this.sha256 = const Value.absent(),
    this.redactionState = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       docType = Value(docType),
       vaultPath = Value(vaultPath),
       createdAt = Value(createdAt);
  static Insertable<ObsidianReportRef> custom({
    Expression<String>? id,
    Expression<String>? docType,
    Expression<String>? vaultPath,
    Expression<String>? sha256,
    Expression<String>? redactionState,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (docType != null) 'doc_type': docType,
      if (vaultPath != null) 'vault_path': vaultPath,
      if (sha256 != null) 'sha256': sha256,
      if (redactionState != null) 'redaction_state': redactionState,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ObsidianReportRefsCompanion copyWith({
    Value<String>? id,
    Value<String>? docType,
    Value<String>? vaultPath,
    Value<String?>? sha256,
    Value<String>? redactionState,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return ObsidianReportRefsCompanion(
      id: id ?? this.id,
      docType: docType ?? this.docType,
      vaultPath: vaultPath ?? this.vaultPath,
      sha256: sha256 ?? this.sha256,
      redactionState: redactionState ?? this.redactionState,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (docType.present) {
      map['doc_type'] = Variable<String>(docType.value);
    }
    if (vaultPath.present) {
      map['vault_path'] = Variable<String>(vaultPath.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (redactionState.present) {
      map['redaction_state'] = Variable<String>(redactionState.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObsidianReportRefsCompanion(')
          ..write('id: $id, ')
          ..write('docType: $docType, ')
          ..write('vaultPath: $vaultPath, ')
          ..write('sha256: $sha256, ')
          ..write('redactionState: $redactionState, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditTrailTable extends AuditTrail
    with TableInfo<$AuditTrailTable, AuditTrailData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditTrailTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorTypeMeta = const VerificationMeta(
    'actorType',
  );
  @override
  late final GeneratedColumn<String> actorType = GeneratedColumn<String>(
    'actor_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
    'actor_id',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTypeMeta = const VerificationMeta(
    'targetType',
  );
  @override
  late final GeneratedColumn<String> targetType = GeneratedColumn<String>(
    'target_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
    'target_id',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _beforeHashMeta = const VerificationMeta(
    'beforeHash',
  );
  @override
  late final GeneratedColumn<String> beforeHash = GeneratedColumn<String>(
    'before_hash',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 64,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _afterHashMeta = const VerificationMeta(
    'afterHash',
  );
  @override
  late final GeneratedColumn<String> afterHash = GeneratedColumn<String>(
    'after_hash',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 64,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _redactedSnapshotMeta = const VerificationMeta(
    'redactedSnapshot',
  );
  @override
  late final GeneratedColumn<String> redactedSnapshot = GeneratedColumn<String>(
    'redacted_snapshot',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 8000),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _redactionStateMeta = const VerificationMeta(
    'redactionState',
  );
  @override
  late final GeneratedColumn<String> redactionState = GeneratedColumn<String>(
    'redaction_state',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none_required'),
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 1000),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _correlationIdMeta = const VerificationMeta(
    'correlationId',
  );
  @override
  late final GeneratedColumn<String> correlationId = GeneratedColumn<String>(
    'correlation_id',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    occurredAt,
    actorType,
    actorId,
    action,
    targetType,
    targetId,
    beforeHash,
    afterHash,
    redactedSnapshot,
    redactionState,
    reason,
    correlationId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_trail';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditTrailData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('actor_type')) {
      context.handle(
        _actorTypeMeta,
        actorType.isAcceptableOrUnknown(data['actor_type']!, _actorTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_actorTypeMeta);
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('target_type')) {
      context.handle(
        _targetTypeMeta,
        targetType.isAcceptableOrUnknown(data['target_type']!, _targetTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_targetTypeMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    }
    if (data.containsKey('before_hash')) {
      context.handle(
        _beforeHashMeta,
        beforeHash.isAcceptableOrUnknown(data['before_hash']!, _beforeHashMeta),
      );
    }
    if (data.containsKey('after_hash')) {
      context.handle(
        _afterHashMeta,
        afterHash.isAcceptableOrUnknown(data['after_hash']!, _afterHashMeta),
      );
    }
    if (data.containsKey('redacted_snapshot')) {
      context.handle(
        _redactedSnapshotMeta,
        redactedSnapshot.isAcceptableOrUnknown(
          data['redacted_snapshot']!,
          _redactedSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('redaction_state')) {
      context.handle(
        _redactionStateMeta,
        redactionState.isAcceptableOrUnknown(
          data['redaction_state']!,
          _redactionStateMeta,
        ),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('correlation_id')) {
      context.handle(
        _correlationIdMeta,
        correlationId.isAcceptableOrUnknown(
          data['correlation_id']!,
          _correlationIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditTrailData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditTrailData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      actorType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_type'],
      )!,
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_id'],
      ),
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      targetType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_type'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_id'],
      ),
      beforeHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}before_hash'],
      ),
      afterHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}after_hash'],
      ),
      redactedSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}redacted_snapshot'],
      ),
      redactionState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}redaction_state'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      correlationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}correlation_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AuditTrailTable createAlias(String alias) {
    return $AuditTrailTable(attachedDatabase, alias);
  }
}

class AuditTrailData extends DataClass implements Insertable<AuditTrailData> {
  final String id;
  final DateTime occurredAt;
  final String actorType;
  final String? actorId;
  final String action;
  final String targetType;
  final String? targetId;
  final String? beforeHash;
  final String? afterHash;
  final String? redactedSnapshot;
  final String redactionState;
  final String? reason;
  final String? correlationId;
  final DateTime createdAt;
  const AuditTrailData({
    required this.id,
    required this.occurredAt,
    required this.actorType,
    this.actorId,
    required this.action,
    required this.targetType,
    this.targetId,
    this.beforeHash,
    this.afterHash,
    this.redactedSnapshot,
    required this.redactionState,
    this.reason,
    this.correlationId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['actor_type'] = Variable<String>(actorType);
    if (!nullToAbsent || actorId != null) {
      map['actor_id'] = Variable<String>(actorId);
    }
    map['action'] = Variable<String>(action);
    map['target_type'] = Variable<String>(targetType);
    if (!nullToAbsent || targetId != null) {
      map['target_id'] = Variable<String>(targetId);
    }
    if (!nullToAbsent || beforeHash != null) {
      map['before_hash'] = Variable<String>(beforeHash);
    }
    if (!nullToAbsent || afterHash != null) {
      map['after_hash'] = Variable<String>(afterHash);
    }
    if (!nullToAbsent || redactedSnapshot != null) {
      map['redacted_snapshot'] = Variable<String>(redactedSnapshot);
    }
    map['redaction_state'] = Variable<String>(redactionState);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    if (!nullToAbsent || correlationId != null) {
      map['correlation_id'] = Variable<String>(correlationId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AuditTrailCompanion toCompanion(bool nullToAbsent) {
    return AuditTrailCompanion(
      id: Value(id),
      occurredAt: Value(occurredAt),
      actorType: Value(actorType),
      actorId: actorId == null && nullToAbsent
          ? const Value.absent()
          : Value(actorId),
      action: Value(action),
      targetType: Value(targetType),
      targetId: targetId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetId),
      beforeHash: beforeHash == null && nullToAbsent
          ? const Value.absent()
          : Value(beforeHash),
      afterHash: afterHash == null && nullToAbsent
          ? const Value.absent()
          : Value(afterHash),
      redactedSnapshot: redactedSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(redactedSnapshot),
      redactionState: Value(redactionState),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      correlationId: correlationId == null && nullToAbsent
          ? const Value.absent()
          : Value(correlationId),
      createdAt: Value(createdAt),
    );
  }

  factory AuditTrailData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditTrailData(
      id: serializer.fromJson<String>(json['id']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      actorType: serializer.fromJson<String>(json['actorType']),
      actorId: serializer.fromJson<String?>(json['actorId']),
      action: serializer.fromJson<String>(json['action']),
      targetType: serializer.fromJson<String>(json['targetType']),
      targetId: serializer.fromJson<String?>(json['targetId']),
      beforeHash: serializer.fromJson<String?>(json['beforeHash']),
      afterHash: serializer.fromJson<String?>(json['afterHash']),
      redactedSnapshot: serializer.fromJson<String?>(json['redactedSnapshot']),
      redactionState: serializer.fromJson<String>(json['redactionState']),
      reason: serializer.fromJson<String?>(json['reason']),
      correlationId: serializer.fromJson<String?>(json['correlationId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'actorType': serializer.toJson<String>(actorType),
      'actorId': serializer.toJson<String?>(actorId),
      'action': serializer.toJson<String>(action),
      'targetType': serializer.toJson<String>(targetType),
      'targetId': serializer.toJson<String?>(targetId),
      'beforeHash': serializer.toJson<String?>(beforeHash),
      'afterHash': serializer.toJson<String?>(afterHash),
      'redactedSnapshot': serializer.toJson<String?>(redactedSnapshot),
      'redactionState': serializer.toJson<String>(redactionState),
      'reason': serializer.toJson<String?>(reason),
      'correlationId': serializer.toJson<String?>(correlationId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AuditTrailData copyWith({
    String? id,
    DateTime? occurredAt,
    String? actorType,
    Value<String?> actorId = const Value.absent(),
    String? action,
    String? targetType,
    Value<String?> targetId = const Value.absent(),
    Value<String?> beforeHash = const Value.absent(),
    Value<String?> afterHash = const Value.absent(),
    Value<String?> redactedSnapshot = const Value.absent(),
    String? redactionState,
    Value<String?> reason = const Value.absent(),
    Value<String?> correlationId = const Value.absent(),
    DateTime? createdAt,
  }) => AuditTrailData(
    id: id ?? this.id,
    occurredAt: occurredAt ?? this.occurredAt,
    actorType: actorType ?? this.actorType,
    actorId: actorId.present ? actorId.value : this.actorId,
    action: action ?? this.action,
    targetType: targetType ?? this.targetType,
    targetId: targetId.present ? targetId.value : this.targetId,
    beforeHash: beforeHash.present ? beforeHash.value : this.beforeHash,
    afterHash: afterHash.present ? afterHash.value : this.afterHash,
    redactedSnapshot: redactedSnapshot.present
        ? redactedSnapshot.value
        : this.redactedSnapshot,
    redactionState: redactionState ?? this.redactionState,
    reason: reason.present ? reason.value : this.reason,
    correlationId: correlationId.present
        ? correlationId.value
        : this.correlationId,
    createdAt: createdAt ?? this.createdAt,
  );
  AuditTrailData copyWithCompanion(AuditTrailCompanion data) {
    return AuditTrailData(
      id: data.id.present ? data.id.value : this.id,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      actorType: data.actorType.present ? data.actorType.value : this.actorType,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      action: data.action.present ? data.action.value : this.action,
      targetType: data.targetType.present
          ? data.targetType.value
          : this.targetType,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      beforeHash: data.beforeHash.present
          ? data.beforeHash.value
          : this.beforeHash,
      afterHash: data.afterHash.present ? data.afterHash.value : this.afterHash,
      redactedSnapshot: data.redactedSnapshot.present
          ? data.redactedSnapshot.value
          : this.redactedSnapshot,
      redactionState: data.redactionState.present
          ? data.redactionState.value
          : this.redactionState,
      reason: data.reason.present ? data.reason.value : this.reason,
      correlationId: data.correlationId.present
          ? data.correlationId.value
          : this.correlationId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditTrailData(')
          ..write('id: $id, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('actorType: $actorType, ')
          ..write('actorId: $actorId, ')
          ..write('action: $action, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('beforeHash: $beforeHash, ')
          ..write('afterHash: $afterHash, ')
          ..write('redactedSnapshot: $redactedSnapshot, ')
          ..write('redactionState: $redactionState, ')
          ..write('reason: $reason, ')
          ..write('correlationId: $correlationId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    occurredAt,
    actorType,
    actorId,
    action,
    targetType,
    targetId,
    beforeHash,
    afterHash,
    redactedSnapshot,
    redactionState,
    reason,
    correlationId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditTrailData &&
          other.id == this.id &&
          other.occurredAt == this.occurredAt &&
          other.actorType == this.actorType &&
          other.actorId == this.actorId &&
          other.action == this.action &&
          other.targetType == this.targetType &&
          other.targetId == this.targetId &&
          other.beforeHash == this.beforeHash &&
          other.afterHash == this.afterHash &&
          other.redactedSnapshot == this.redactedSnapshot &&
          other.redactionState == this.redactionState &&
          other.reason == this.reason &&
          other.correlationId == this.correlationId &&
          other.createdAt == this.createdAt);
}

class AuditTrailCompanion extends UpdateCompanion<AuditTrailData> {
  final Value<String> id;
  final Value<DateTime> occurredAt;
  final Value<String> actorType;
  final Value<String?> actorId;
  final Value<String> action;
  final Value<String> targetType;
  final Value<String?> targetId;
  final Value<String?> beforeHash;
  final Value<String?> afterHash;
  final Value<String?> redactedSnapshot;
  final Value<String> redactionState;
  final Value<String?> reason;
  final Value<String?> correlationId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AuditTrailCompanion({
    this.id = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.actorType = const Value.absent(),
    this.actorId = const Value.absent(),
    this.action = const Value.absent(),
    this.targetType = const Value.absent(),
    this.targetId = const Value.absent(),
    this.beforeHash = const Value.absent(),
    this.afterHash = const Value.absent(),
    this.redactedSnapshot = const Value.absent(),
    this.redactionState = const Value.absent(),
    this.reason = const Value.absent(),
    this.correlationId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditTrailCompanion.insert({
    required String id,
    required DateTime occurredAt,
    required String actorType,
    this.actorId = const Value.absent(),
    required String action,
    required String targetType,
    this.targetId = const Value.absent(),
    this.beforeHash = const Value.absent(),
    this.afterHash = const Value.absent(),
    this.redactedSnapshot = const Value.absent(),
    this.redactionState = const Value.absent(),
    this.reason = const Value.absent(),
    this.correlationId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       occurredAt = Value(occurredAt),
       actorType = Value(actorType),
       action = Value(action),
       targetType = Value(targetType),
       createdAt = Value(createdAt);
  static Insertable<AuditTrailData> custom({
    Expression<String>? id,
    Expression<DateTime>? occurredAt,
    Expression<String>? actorType,
    Expression<String>? actorId,
    Expression<String>? action,
    Expression<String>? targetType,
    Expression<String>? targetId,
    Expression<String>? beforeHash,
    Expression<String>? afterHash,
    Expression<String>? redactedSnapshot,
    Expression<String>? redactionState,
    Expression<String>? reason,
    Expression<String>? correlationId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (actorType != null) 'actor_type': actorType,
      if (actorId != null) 'actor_id': actorId,
      if (action != null) 'action': action,
      if (targetType != null) 'target_type': targetType,
      if (targetId != null) 'target_id': targetId,
      if (beforeHash != null) 'before_hash': beforeHash,
      if (afterHash != null) 'after_hash': afterHash,
      if (redactedSnapshot != null) 'redacted_snapshot': redactedSnapshot,
      if (redactionState != null) 'redaction_state': redactionState,
      if (reason != null) 'reason': reason,
      if (correlationId != null) 'correlation_id': correlationId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditTrailCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? occurredAt,
    Value<String>? actorType,
    Value<String?>? actorId,
    Value<String>? action,
    Value<String>? targetType,
    Value<String?>? targetId,
    Value<String?>? beforeHash,
    Value<String?>? afterHash,
    Value<String?>? redactedSnapshot,
    Value<String>? redactionState,
    Value<String?>? reason,
    Value<String?>? correlationId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AuditTrailCompanion(
      id: id ?? this.id,
      occurredAt: occurredAt ?? this.occurredAt,
      actorType: actorType ?? this.actorType,
      actorId: actorId ?? this.actorId,
      action: action ?? this.action,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      beforeHash: beforeHash ?? this.beforeHash,
      afterHash: afterHash ?? this.afterHash,
      redactedSnapshot: redactedSnapshot ?? this.redactedSnapshot,
      redactionState: redactionState ?? this.redactionState,
      reason: reason ?? this.reason,
      correlationId: correlationId ?? this.correlationId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (actorType.present) {
      map['actor_type'] = Variable<String>(actorType.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (targetType.present) {
      map['target_type'] = Variable<String>(targetType.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (beforeHash.present) {
      map['before_hash'] = Variable<String>(beforeHash.value);
    }
    if (afterHash.present) {
      map['after_hash'] = Variable<String>(afterHash.value);
    }
    if (redactedSnapshot.present) {
      map['redacted_snapshot'] = Variable<String>(redactedSnapshot.value);
    }
    if (redactionState.present) {
      map['redaction_state'] = Variable<String>(redactionState.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (correlationId.present) {
      map['correlation_id'] = Variable<String>(correlationId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditTrailCompanion(')
          ..write('id: $id, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('actorType: $actorType, ')
          ..write('actorId: $actorId, ')
          ..write('action: $action, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('beforeHash: $beforeHash, ')
          ..write('afterHash: $afterHash, ')
          ..write('redactedSnapshot: $redactedSnapshot, ')
          ..write('redactionState: $redactionState, ')
          ..write('reason: $reason, ')
          ..write('correlationId: $correlationId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MissionsTable extends Missions with TableInfo<$MissionsTable, Mission> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MissionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 240,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 2000),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('standard'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    status,
    mode,
    createdAt,
    updatedAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'missions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Mission> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Mission map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Mission(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $MissionsTable createAlias(String alias) {
    return $MissionsTable(attachedDatabase, alias);
  }
}

class Mission extends DataClass implements Insertable<Mission> {
  final String id;
  final String title;
  final String? description;
  final String status;
  final String mode;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? archivedAt;
  const Mission({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.mode,
    required this.createdAt,
    this.updatedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['status'] = Variable<String>(status);
    map['mode'] = Variable<String>(mode);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  MissionsCompanion toCompanion(bool nullToAbsent) {
    return MissionsCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      status: Value(status),
      mode: Value(mode),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory Mission.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Mission(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      status: serializer.fromJson<String>(json['status']),
      mode: serializer.fromJson<String>(json['mode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'status': serializer.toJson<String>(status),
      'mode': serializer.toJson<String>(mode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  Mission copyWith({
    String? id,
    String? title,
    Value<String?> description = const Value.absent(),
    String? status,
    String? mode,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => Mission(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    status: status ?? this.status,
    mode: mode ?? this.mode,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  Mission copyWithCompanion(MissionsCompanion data) {
    return Mission(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      status: data.status.present ? data.status.value : this.status,
      mode: data.mode.present ? data.mode.value : this.mode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Mission(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('mode: $mode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    status,
    mode,
    createdAt,
    updatedAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Mission &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.status == this.status &&
          other.mode == this.mode &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt);
}

class MissionsCompanion extends UpdateCompanion<Mission> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> status;
  final Value<String> mode;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const MissionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.mode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MissionsCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.mode = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<Mission> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? status,
    Expression<String>? mode,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (mode != null) 'mode': mode,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MissionsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<String>? status,
    Value<String>? mode,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return MissionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MissionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('mode: $mode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskCardsTable extends TaskCards
    with TableInfo<$TaskCardsTable, TaskCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _missionIdMeta = const VerificationMeta(
    'missionId',
  );
  @override
  late final GeneratedColumn<String> missionId = GeneratedColumn<String>(
    'mission_id',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 240,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 4000),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _laneMeta = const VerificationMeta('lane');
  @override
  late final GeneratedColumn<String> lane = GeneratedColumn<String>(
    'lane',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('planned'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('planned'),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('normal'),
  );
  static const VerificationMeta _orderKeyMeta = const VerificationMeta(
    'orderKey',
  );
  @override
  late final GeneratedColumn<String> orderKey = GeneratedColumn<String>(
    'order_key',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _riskLevelMeta = const VerificationMeta(
    'riskLevel',
  );
  @override
  late final GeneratedColumn<String> riskLevel = GeneratedColumn<String>(
    'risk_level',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('low'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    missionId,
    title,
    description,
    lane,
    status,
    priority,
    orderKey,
    riskLevel,
    createdAt,
    updatedAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mission_id')) {
      context.handle(
        _missionIdMeta,
        missionId.isAcceptableOrUnknown(data['mission_id']!, _missionIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('lane')) {
      context.handle(
        _laneMeta,
        lane.isAcceptableOrUnknown(data['lane']!, _laneMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('order_key')) {
      context.handle(
        _orderKeyMeta,
        orderKey.isAcceptableOrUnknown(data['order_key']!, _orderKeyMeta),
      );
    }
    if (data.containsKey('risk_level')) {
      context.handle(
        _riskLevelMeta,
        riskLevel.isAcceptableOrUnknown(data['risk_level']!, _riskLevelMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskCard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      missionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mission_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      lane: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lane'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      orderKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_key'],
      ),
      riskLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}risk_level'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $TaskCardsTable createAlias(String alias) {
    return $TaskCardsTable(attachedDatabase, alias);
  }
}

class TaskCard extends DataClass implements Insertable<TaskCard> {
  final String id;
  final String? missionId;
  final String title;
  final String? description;
  final String lane;
  final String status;
  final String priority;
  final String? orderKey;
  final String riskLevel;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? archivedAt;
  const TaskCard({
    required this.id,
    this.missionId,
    required this.title,
    this.description,
    required this.lane,
    required this.status,
    required this.priority,
    this.orderKey,
    required this.riskLevel,
    required this.createdAt,
    this.updatedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || missionId != null) {
      map['mission_id'] = Variable<String>(missionId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['lane'] = Variable<String>(lane);
    map['status'] = Variable<String>(status);
    map['priority'] = Variable<String>(priority);
    if (!nullToAbsent || orderKey != null) {
      map['order_key'] = Variable<String>(orderKey);
    }
    map['risk_level'] = Variable<String>(riskLevel);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  TaskCardsCompanion toCompanion(bool nullToAbsent) {
    return TaskCardsCompanion(
      id: Value(id),
      missionId: missionId == null && nullToAbsent
          ? const Value.absent()
          : Value(missionId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      lane: Value(lane),
      status: Value(status),
      priority: Value(priority),
      orderKey: orderKey == null && nullToAbsent
          ? const Value.absent()
          : Value(orderKey),
      riskLevel: Value(riskLevel),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory TaskCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskCard(
      id: serializer.fromJson<String>(json['id']),
      missionId: serializer.fromJson<String?>(json['missionId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      lane: serializer.fromJson<String>(json['lane']),
      status: serializer.fromJson<String>(json['status']),
      priority: serializer.fromJson<String>(json['priority']),
      orderKey: serializer.fromJson<String?>(json['orderKey']),
      riskLevel: serializer.fromJson<String>(json['riskLevel']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'missionId': serializer.toJson<String?>(missionId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'lane': serializer.toJson<String>(lane),
      'status': serializer.toJson<String>(status),
      'priority': serializer.toJson<String>(priority),
      'orderKey': serializer.toJson<String?>(orderKey),
      'riskLevel': serializer.toJson<String>(riskLevel),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  TaskCard copyWith({
    String? id,
    Value<String?> missionId = const Value.absent(),
    String? title,
    Value<String?> description = const Value.absent(),
    String? lane,
    String? status,
    String? priority,
    Value<String?> orderKey = const Value.absent(),
    String? riskLevel,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => TaskCard(
    id: id ?? this.id,
    missionId: missionId.present ? missionId.value : this.missionId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    lane: lane ?? this.lane,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    orderKey: orderKey.present ? orderKey.value : this.orderKey,
    riskLevel: riskLevel ?? this.riskLevel,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  TaskCard copyWithCompanion(TaskCardsCompanion data) {
    return TaskCard(
      id: data.id.present ? data.id.value : this.id,
      missionId: data.missionId.present ? data.missionId.value : this.missionId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      lane: data.lane.present ? data.lane.value : this.lane,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      orderKey: data.orderKey.present ? data.orderKey.value : this.orderKey,
      riskLevel: data.riskLevel.present ? data.riskLevel.value : this.riskLevel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskCard(')
          ..write('id: $id, ')
          ..write('missionId: $missionId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('lane: $lane, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('orderKey: $orderKey, ')
          ..write('riskLevel: $riskLevel, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    missionId,
    title,
    description,
    lane,
    status,
    priority,
    orderKey,
    riskLevel,
    createdAt,
    updatedAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskCard &&
          other.id == this.id &&
          other.missionId == this.missionId &&
          other.title == this.title &&
          other.description == this.description &&
          other.lane == this.lane &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.orderKey == this.orderKey &&
          other.riskLevel == this.riskLevel &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt);
}

class TaskCardsCompanion extends UpdateCompanion<TaskCard> {
  final Value<String> id;
  final Value<String?> missionId;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> lane;
  final Value<String> status;
  final Value<String> priority;
  final Value<String?> orderKey;
  final Value<String> riskLevel;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const TaskCardsCompanion({
    this.id = const Value.absent(),
    this.missionId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.lane = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.orderKey = const Value.absent(),
    this.riskLevel = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskCardsCompanion.insert({
    required String id,
    this.missionId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.lane = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.orderKey = const Value.absent(),
    this.riskLevel = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<TaskCard> custom({
    Expression<String>? id,
    Expression<String>? missionId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? lane,
    Expression<String>? status,
    Expression<String>? priority,
    Expression<String>? orderKey,
    Expression<String>? riskLevel,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (missionId != null) 'mission_id': missionId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (lane != null) 'lane': lane,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (orderKey != null) 'order_key': orderKey,
      if (riskLevel != null) 'risk_level': riskLevel,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskCardsCompanion copyWith({
    Value<String>? id,
    Value<String?>? missionId,
    Value<String>? title,
    Value<String?>? description,
    Value<String>? lane,
    Value<String>? status,
    Value<String>? priority,
    Value<String?>? orderKey,
    Value<String>? riskLevel,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return TaskCardsCompanion(
      id: id ?? this.id,
      missionId: missionId ?? this.missionId,
      title: title ?? this.title,
      description: description ?? this.description,
      lane: lane ?? this.lane,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      orderKey: orderKey ?? this.orderKey,
      riskLevel: riskLevel ?? this.riskLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (missionId.present) {
      map['mission_id'] = Variable<String>(missionId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (lane.present) {
      map['lane'] = Variable<String>(lane.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (orderKey.present) {
      map['order_key'] = Variable<String>(orderKey.value);
    }
    if (riskLevel.present) {
      map['risk_level'] = Variable<String>(riskLevel.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskCardsCompanion(')
          ..write('id: $id, ')
          ..write('missionId: $missionId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('lane: $lane, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('orderKey: $orderKey, ')
          ..write('riskLevel: $riskLevel, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AgentRunsTable extends AgentRuns
    with TableInfo<$AgentRunsTable, AgentRun> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AgentRunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _missionIdMeta = const VerificationMeta(
    'missionId',
  );
  @override
  late final GeneratedColumn<String> missionId = GeneratedColumn<String>(
    'mission_id',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taskCardIdMeta = const VerificationMeta(
    'taskCardId',
  );
  @override
  late final GeneratedColumn<String> taskCardId = GeneratedColumn<String>(
    'task_card_id',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _agentNameMeta = const VerificationMeta(
    'agentName',
  );
  @override
  late final GeneratedColumn<String> agentName = GeneratedColumn<String>(
    'agent_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _runKindMeta = const VerificationMeta(
    'runKind',
  );
  @override
  late final GeneratedColumn<String> runKind = GeneratedColumn<String>(
    'run_kind',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _phaseMeta = const VerificationMeta('phase');
  @override
  late final GeneratedColumn<String> phase = GeneratedColumn<String>(
    'phase',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _conditionMeta = const VerificationMeta(
    'condition',
  );
  @override
  late final GeneratedColumn<String> condition = GeneratedColumn<String>(
    'condition',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('healthy'),
  );
  static const VerificationMeta _autonomyLevelMeta = const VerificationMeta(
    'autonomyLevel',
  );
  @override
  late final GeneratedColumn<String> autonomyLevel = GeneratedColumn<String>(
    'autonomy_level',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('guarded'),
  );
  static const VerificationMeta _executionTargetMeta = const VerificationMeta(
    'executionTarget',
  );
  @override
  late final GeneratedColumn<String> executionTarget = GeneratedColumn<String>(
    'execution_target',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 4000),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorTextMeta = const VerificationMeta(
    'errorText',
  );
  @override
  late final GeneratedColumn<String> errorText = GeneratedColumn<String>(
    'error_text',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 4000),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outputRefMeta = const VerificationMeta(
    'outputRef',
  );
  @override
  late final GeneratedColumn<String> outputRef = GeneratedColumn<String>(
    'output_ref',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 500),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    missionId,
    taskCardId,
    agentName,
    runKind,
    phase,
    condition,
    autonomyLevel,
    executionTarget,
    startedAt,
    endedAt,
    summary,
    errorText,
    outputRef,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'agent_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AgentRun> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mission_id')) {
      context.handle(
        _missionIdMeta,
        missionId.isAcceptableOrUnknown(data['mission_id']!, _missionIdMeta),
      );
    }
    if (data.containsKey('task_card_id')) {
      context.handle(
        _taskCardIdMeta,
        taskCardId.isAcceptableOrUnknown(
          data['task_card_id']!,
          _taskCardIdMeta,
        ),
      );
    }
    if (data.containsKey('agent_name')) {
      context.handle(
        _agentNameMeta,
        agentName.isAcceptableOrUnknown(data['agent_name']!, _agentNameMeta),
      );
    } else if (isInserting) {
      context.missing(_agentNameMeta);
    }
    if (data.containsKey('run_kind')) {
      context.handle(
        _runKindMeta,
        runKind.isAcceptableOrUnknown(data['run_kind']!, _runKindMeta),
      );
    }
    if (data.containsKey('phase')) {
      context.handle(
        _phaseMeta,
        phase.isAcceptableOrUnknown(data['phase']!, _phaseMeta),
      );
    }
    if (data.containsKey('condition')) {
      context.handle(
        _conditionMeta,
        condition.isAcceptableOrUnknown(data['condition']!, _conditionMeta),
      );
    }
    if (data.containsKey('autonomy_level')) {
      context.handle(
        _autonomyLevelMeta,
        autonomyLevel.isAcceptableOrUnknown(
          data['autonomy_level']!,
          _autonomyLevelMeta,
        ),
      );
    }
    if (data.containsKey('execution_target')) {
      context.handle(
        _executionTargetMeta,
        executionTarget.isAcceptableOrUnknown(
          data['execution_target']!,
          _executionTargetMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('error_text')) {
      context.handle(
        _errorTextMeta,
        errorText.isAcceptableOrUnknown(data['error_text']!, _errorTextMeta),
      );
    }
    if (data.containsKey('output_ref')) {
      context.handle(
        _outputRefMeta,
        outputRef.isAcceptableOrUnknown(data['output_ref']!, _outputRefMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AgentRun map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AgentRun(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      missionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mission_id'],
      ),
      taskCardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_card_id'],
      ),
      agentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}agent_name'],
      )!,
      runKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}run_kind'],
      )!,
      phase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phase'],
      )!,
      condition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition'],
      )!,
      autonomyLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}autonomy_level'],
      )!,
      executionTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}execution_target'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      errorText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_text'],
      ),
      outputRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}output_ref'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $AgentRunsTable createAlias(String alias) {
    return $AgentRunsTable(attachedDatabase, alias);
  }
}

class AgentRun extends DataClass implements Insertable<AgentRun> {
  final String id;
  final String? missionId;
  final String? taskCardId;
  final String agentName;
  final String runKind;
  final String phase;
  final String condition;
  final String autonomyLevel;
  final String executionTarget;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? summary;
  final String? errorText;
  final String? outputRef;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const AgentRun({
    required this.id,
    this.missionId,
    this.taskCardId,
    required this.agentName,
    required this.runKind,
    required this.phase,
    required this.condition,
    required this.autonomyLevel,
    required this.executionTarget,
    this.startedAt,
    this.endedAt,
    this.summary,
    this.errorText,
    this.outputRef,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || missionId != null) {
      map['mission_id'] = Variable<String>(missionId);
    }
    if (!nullToAbsent || taskCardId != null) {
      map['task_card_id'] = Variable<String>(taskCardId);
    }
    map['agent_name'] = Variable<String>(agentName);
    map['run_kind'] = Variable<String>(runKind);
    map['phase'] = Variable<String>(phase);
    map['condition'] = Variable<String>(condition);
    map['autonomy_level'] = Variable<String>(autonomyLevel);
    map['execution_target'] = Variable<String>(executionTarget);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    if (!nullToAbsent || errorText != null) {
      map['error_text'] = Variable<String>(errorText);
    }
    if (!nullToAbsent || outputRef != null) {
      map['output_ref'] = Variable<String>(outputRef);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  AgentRunsCompanion toCompanion(bool nullToAbsent) {
    return AgentRunsCompanion(
      id: Value(id),
      missionId: missionId == null && nullToAbsent
          ? const Value.absent()
          : Value(missionId),
      taskCardId: taskCardId == null && nullToAbsent
          ? const Value.absent()
          : Value(taskCardId),
      agentName: Value(agentName),
      runKind: Value(runKind),
      phase: Value(phase),
      condition: Value(condition),
      autonomyLevel: Value(autonomyLevel),
      executionTarget: Value(executionTarget),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      errorText: errorText == null && nullToAbsent
          ? const Value.absent()
          : Value(errorText),
      outputRef: outputRef == null && nullToAbsent
          ? const Value.absent()
          : Value(outputRef),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory AgentRun.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AgentRun(
      id: serializer.fromJson<String>(json['id']),
      missionId: serializer.fromJson<String?>(json['missionId']),
      taskCardId: serializer.fromJson<String?>(json['taskCardId']),
      agentName: serializer.fromJson<String>(json['agentName']),
      runKind: serializer.fromJson<String>(json['runKind']),
      phase: serializer.fromJson<String>(json['phase']),
      condition: serializer.fromJson<String>(json['condition']),
      autonomyLevel: serializer.fromJson<String>(json['autonomyLevel']),
      executionTarget: serializer.fromJson<String>(json['executionTarget']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      summary: serializer.fromJson<String?>(json['summary']),
      errorText: serializer.fromJson<String?>(json['errorText']),
      outputRef: serializer.fromJson<String?>(json['outputRef']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'missionId': serializer.toJson<String?>(missionId),
      'taskCardId': serializer.toJson<String?>(taskCardId),
      'agentName': serializer.toJson<String>(agentName),
      'runKind': serializer.toJson<String>(runKind),
      'phase': serializer.toJson<String>(phase),
      'condition': serializer.toJson<String>(condition),
      'autonomyLevel': serializer.toJson<String>(autonomyLevel),
      'executionTarget': serializer.toJson<String>(executionTarget),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'summary': serializer.toJson<String?>(summary),
      'errorText': serializer.toJson<String?>(errorText),
      'outputRef': serializer.toJson<String?>(outputRef),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  AgentRun copyWith({
    String? id,
    Value<String?> missionId = const Value.absent(),
    Value<String?> taskCardId = const Value.absent(),
    String? agentName,
    String? runKind,
    String? phase,
    String? condition,
    String? autonomyLevel,
    String? executionTarget,
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> endedAt = const Value.absent(),
    Value<String?> summary = const Value.absent(),
    Value<String?> errorText = const Value.absent(),
    Value<String?> outputRef = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => AgentRun(
    id: id ?? this.id,
    missionId: missionId.present ? missionId.value : this.missionId,
    taskCardId: taskCardId.present ? taskCardId.value : this.taskCardId,
    agentName: agentName ?? this.agentName,
    runKind: runKind ?? this.runKind,
    phase: phase ?? this.phase,
    condition: condition ?? this.condition,
    autonomyLevel: autonomyLevel ?? this.autonomyLevel,
    executionTarget: executionTarget ?? this.executionTarget,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    summary: summary.present ? summary.value : this.summary,
    errorText: errorText.present ? errorText.value : this.errorText,
    outputRef: outputRef.present ? outputRef.value : this.outputRef,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  AgentRun copyWithCompanion(AgentRunsCompanion data) {
    return AgentRun(
      id: data.id.present ? data.id.value : this.id,
      missionId: data.missionId.present ? data.missionId.value : this.missionId,
      taskCardId: data.taskCardId.present
          ? data.taskCardId.value
          : this.taskCardId,
      agentName: data.agentName.present ? data.agentName.value : this.agentName,
      runKind: data.runKind.present ? data.runKind.value : this.runKind,
      phase: data.phase.present ? data.phase.value : this.phase,
      condition: data.condition.present ? data.condition.value : this.condition,
      autonomyLevel: data.autonomyLevel.present
          ? data.autonomyLevel.value
          : this.autonomyLevel,
      executionTarget: data.executionTarget.present
          ? data.executionTarget.value
          : this.executionTarget,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      summary: data.summary.present ? data.summary.value : this.summary,
      errorText: data.errorText.present ? data.errorText.value : this.errorText,
      outputRef: data.outputRef.present ? data.outputRef.value : this.outputRef,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AgentRun(')
          ..write('id: $id, ')
          ..write('missionId: $missionId, ')
          ..write('taskCardId: $taskCardId, ')
          ..write('agentName: $agentName, ')
          ..write('runKind: $runKind, ')
          ..write('phase: $phase, ')
          ..write('condition: $condition, ')
          ..write('autonomyLevel: $autonomyLevel, ')
          ..write('executionTarget: $executionTarget, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('summary: $summary, ')
          ..write('errorText: $errorText, ')
          ..write('outputRef: $outputRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    missionId,
    taskCardId,
    agentName,
    runKind,
    phase,
    condition,
    autonomyLevel,
    executionTarget,
    startedAt,
    endedAt,
    summary,
    errorText,
    outputRef,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AgentRun &&
          other.id == this.id &&
          other.missionId == this.missionId &&
          other.taskCardId == this.taskCardId &&
          other.agentName == this.agentName &&
          other.runKind == this.runKind &&
          other.phase == this.phase &&
          other.condition == this.condition &&
          other.autonomyLevel == this.autonomyLevel &&
          other.executionTarget == this.executionTarget &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.summary == this.summary &&
          other.errorText == this.errorText &&
          other.outputRef == this.outputRef &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AgentRunsCompanion extends UpdateCompanion<AgentRun> {
  final Value<String> id;
  final Value<String?> missionId;
  final Value<String?> taskCardId;
  final Value<String> agentName;
  final Value<String> runKind;
  final Value<String> phase;
  final Value<String> condition;
  final Value<String> autonomyLevel;
  final Value<String> executionTarget;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> endedAt;
  final Value<String?> summary;
  final Value<String?> errorText;
  final Value<String?> outputRef;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const AgentRunsCompanion({
    this.id = const Value.absent(),
    this.missionId = const Value.absent(),
    this.taskCardId = const Value.absent(),
    this.agentName = const Value.absent(),
    this.runKind = const Value.absent(),
    this.phase = const Value.absent(),
    this.condition = const Value.absent(),
    this.autonomyLevel = const Value.absent(),
    this.executionTarget = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.summary = const Value.absent(),
    this.errorText = const Value.absent(),
    this.outputRef = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AgentRunsCompanion.insert({
    required String id,
    this.missionId = const Value.absent(),
    this.taskCardId = const Value.absent(),
    required String agentName,
    this.runKind = const Value.absent(),
    this.phase = const Value.absent(),
    this.condition = const Value.absent(),
    this.autonomyLevel = const Value.absent(),
    this.executionTarget = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.summary = const Value.absent(),
    this.errorText = const Value.absent(),
    this.outputRef = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       agentName = Value(agentName),
       createdAt = Value(createdAt);
  static Insertable<AgentRun> custom({
    Expression<String>? id,
    Expression<String>? missionId,
    Expression<String>? taskCardId,
    Expression<String>? agentName,
    Expression<String>? runKind,
    Expression<String>? phase,
    Expression<String>? condition,
    Expression<String>? autonomyLevel,
    Expression<String>? executionTarget,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? summary,
    Expression<String>? errorText,
    Expression<String>? outputRef,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (missionId != null) 'mission_id': missionId,
      if (taskCardId != null) 'task_card_id': taskCardId,
      if (agentName != null) 'agent_name': agentName,
      if (runKind != null) 'run_kind': runKind,
      if (phase != null) 'phase': phase,
      if (condition != null) 'condition': condition,
      if (autonomyLevel != null) 'autonomy_level': autonomyLevel,
      if (executionTarget != null) 'execution_target': executionTarget,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (summary != null) 'summary': summary,
      if (errorText != null) 'error_text': errorText,
      if (outputRef != null) 'output_ref': outputRef,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AgentRunsCompanion copyWith({
    Value<String>? id,
    Value<String?>? missionId,
    Value<String?>? taskCardId,
    Value<String>? agentName,
    Value<String>? runKind,
    Value<String>? phase,
    Value<String>? condition,
    Value<String>? autonomyLevel,
    Value<String>? executionTarget,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? endedAt,
    Value<String?>? summary,
    Value<String?>? errorText,
    Value<String?>? outputRef,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return AgentRunsCompanion(
      id: id ?? this.id,
      missionId: missionId ?? this.missionId,
      taskCardId: taskCardId ?? this.taskCardId,
      agentName: agentName ?? this.agentName,
      runKind: runKind ?? this.runKind,
      phase: phase ?? this.phase,
      condition: condition ?? this.condition,
      autonomyLevel: autonomyLevel ?? this.autonomyLevel,
      executionTarget: executionTarget ?? this.executionTarget,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      summary: summary ?? this.summary,
      errorText: errorText ?? this.errorText,
      outputRef: outputRef ?? this.outputRef,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (missionId.present) {
      map['mission_id'] = Variable<String>(missionId.value);
    }
    if (taskCardId.present) {
      map['task_card_id'] = Variable<String>(taskCardId.value);
    }
    if (agentName.present) {
      map['agent_name'] = Variable<String>(agentName.value);
    }
    if (runKind.present) {
      map['run_kind'] = Variable<String>(runKind.value);
    }
    if (phase.present) {
      map['phase'] = Variable<String>(phase.value);
    }
    if (condition.present) {
      map['condition'] = Variable<String>(condition.value);
    }
    if (autonomyLevel.present) {
      map['autonomy_level'] = Variable<String>(autonomyLevel.value);
    }
    if (executionTarget.present) {
      map['execution_target'] = Variable<String>(executionTarget.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (errorText.present) {
      map['error_text'] = Variable<String>(errorText.value);
    }
    if (outputRef.present) {
      map['output_ref'] = Variable<String>(outputRef.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AgentRunsCompanion(')
          ..write('id: $id, ')
          ..write('missionId: $missionId, ')
          ..write('taskCardId: $taskCardId, ')
          ..write('agentName: $agentName, ')
          ..write('runKind: $runKind, ')
          ..write('phase: $phase, ')
          ..write('condition: $condition, ')
          ..write('autonomyLevel: $autonomyLevel, ')
          ..write('executionTarget: $executionTarget, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('summary: $summary, ')
          ..write('errorText: $errorText, ')
          ..write('outputRef: $outputRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ApprovalRecordsTable extends ApprovalRecords
    with TableInfo<$ApprovalRecordsTable, ApprovalRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ApprovalRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectTypeMeta = const VerificationMeta(
    'subjectType',
  );
  @override
  late final GeneratedColumn<String> subjectType = GeneratedColumn<String>(
    'subject_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _approvalTypeMeta = const VerificationMeta(
    'approvalType',
  );
  @override
  late final GeneratedColumn<String> approvalType = GeneratedColumn<String>(
    'approval_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _requestedByMeta = const VerificationMeta(
    'requestedBy',
  );
  @override
  late final GeneratedColumn<String> requestedBy = GeneratedColumn<String>(
    'requested_by',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requestedAtMeta = const VerificationMeta(
    'requestedAt',
  );
  @override
  late final GeneratedColumn<DateTime> requestedAt = GeneratedColumn<DateTime>(
    'requested_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _decidedByMeta = const VerificationMeta(
    'decidedBy',
  );
  @override
  late final GeneratedColumn<String> decidedBy = GeneratedColumn<String>(
    'decided_by',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _decidedAtMeta = const VerificationMeta(
    'decidedAt',
  );
  @override
  late final GeneratedColumn<DateTime> decidedAt = GeneratedColumn<DateTime>(
    'decided_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _decisionMeta = const VerificationMeta(
    'decision',
  );
  @override
  late final GeneratedColumn<String> decision = GeneratedColumn<String>(
    'decision',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 60),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _decisionNoteMeta = const VerificationMeta(
    'decisionNote',
  );
  @override
  late final GeneratedColumn<String> decisionNote = GeneratedColumn<String>(
    'decision_note',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 4000),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _successorApprovalIdMeta =
      const VerificationMeta('successorApprovalId');
  @override
  late final GeneratedColumn<String> successorApprovalId =
      GeneratedColumn<String>(
        'successor_approval_id',
        aliasedName,
        true,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 120,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _obsidianRefIdMeta = const VerificationMeta(
    'obsidianRefId',
  );
  @override
  late final GeneratedColumn<String> obsidianRefId = GeneratedColumn<String>(
    'obsidian_ref_id',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    subjectType,
    subjectId,
    approvalType,
    state,
    requestedBy,
    requestedAt,
    decidedBy,
    decidedAt,
    decision,
    decisionNote,
    successorApprovalId,
    obsidianRefId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'approval_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ApprovalRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subject_type')) {
      context.handle(
        _subjectTypeMeta,
        subjectType.isAcceptableOrUnknown(
          data['subject_type']!,
          _subjectTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subjectTypeMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('approval_type')) {
      context.handle(
        _approvalTypeMeta,
        approvalType.isAcceptableOrUnknown(
          data['approval_type']!,
          _approvalTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_approvalTypeMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('requested_by')) {
      context.handle(
        _requestedByMeta,
        requestedBy.isAcceptableOrUnknown(
          data['requested_by']!,
          _requestedByMeta,
        ),
      );
    }
    if (data.containsKey('requested_at')) {
      context.handle(
        _requestedAtMeta,
        requestedAt.isAcceptableOrUnknown(
          data['requested_at']!,
          _requestedAtMeta,
        ),
      );
    }
    if (data.containsKey('decided_by')) {
      context.handle(
        _decidedByMeta,
        decidedBy.isAcceptableOrUnknown(data['decided_by']!, _decidedByMeta),
      );
    }
    if (data.containsKey('decided_at')) {
      context.handle(
        _decidedAtMeta,
        decidedAt.isAcceptableOrUnknown(data['decided_at']!, _decidedAtMeta),
      );
    }
    if (data.containsKey('decision')) {
      context.handle(
        _decisionMeta,
        decision.isAcceptableOrUnknown(data['decision']!, _decisionMeta),
      );
    }
    if (data.containsKey('decision_note')) {
      context.handle(
        _decisionNoteMeta,
        decisionNote.isAcceptableOrUnknown(
          data['decision_note']!,
          _decisionNoteMeta,
        ),
      );
    }
    if (data.containsKey('successor_approval_id')) {
      context.handle(
        _successorApprovalIdMeta,
        successorApprovalId.isAcceptableOrUnknown(
          data['successor_approval_id']!,
          _successorApprovalIdMeta,
        ),
      );
    }
    if (data.containsKey('obsidian_ref_id')) {
      context.handle(
        _obsidianRefIdMeta,
        obsidianRefId.isAcceptableOrUnknown(
          data['obsidian_ref_id']!,
          _obsidianRefIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ApprovalRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ApprovalRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      subjectType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_type'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      )!,
      approvalType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}approval_type'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      requestedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}requested_by'],
      ),
      requestedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}requested_at'],
      ),
      decidedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decided_by'],
      ),
      decidedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}decided_at'],
      ),
      decision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decision'],
      ),
      decisionNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decision_note'],
      ),
      successorApprovalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}successor_approval_id'],
      ),
      obsidianRefId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}obsidian_ref_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $ApprovalRecordsTable createAlias(String alias) {
    return $ApprovalRecordsTable(attachedDatabase, alias);
  }
}

class ApprovalRecord extends DataClass implements Insertable<ApprovalRecord> {
  final String id;
  final String subjectType;
  final String subjectId;
  final String approvalType;
  final String state;
  final String? requestedBy;
  final DateTime? requestedAt;
  final String? decidedBy;
  final DateTime? decidedAt;
  final String? decision;
  final String? decisionNote;
  final String? successorApprovalId;
  final String? obsidianRefId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const ApprovalRecord({
    required this.id,
    required this.subjectType,
    required this.subjectId,
    required this.approvalType,
    required this.state,
    this.requestedBy,
    this.requestedAt,
    this.decidedBy,
    this.decidedAt,
    this.decision,
    this.decisionNote,
    this.successorApprovalId,
    this.obsidianRefId,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subject_type'] = Variable<String>(subjectType);
    map['subject_id'] = Variable<String>(subjectId);
    map['approval_type'] = Variable<String>(approvalType);
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || requestedBy != null) {
      map['requested_by'] = Variable<String>(requestedBy);
    }
    if (!nullToAbsent || requestedAt != null) {
      map['requested_at'] = Variable<DateTime>(requestedAt);
    }
    if (!nullToAbsent || decidedBy != null) {
      map['decided_by'] = Variable<String>(decidedBy);
    }
    if (!nullToAbsent || decidedAt != null) {
      map['decided_at'] = Variable<DateTime>(decidedAt);
    }
    if (!nullToAbsent || decision != null) {
      map['decision'] = Variable<String>(decision);
    }
    if (!nullToAbsent || decisionNote != null) {
      map['decision_note'] = Variable<String>(decisionNote);
    }
    if (!nullToAbsent || successorApprovalId != null) {
      map['successor_approval_id'] = Variable<String>(successorApprovalId);
    }
    if (!nullToAbsent || obsidianRefId != null) {
      map['obsidian_ref_id'] = Variable<String>(obsidianRefId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  ApprovalRecordsCompanion toCompanion(bool nullToAbsent) {
    return ApprovalRecordsCompanion(
      id: Value(id),
      subjectType: Value(subjectType),
      subjectId: Value(subjectId),
      approvalType: Value(approvalType),
      state: Value(state),
      requestedBy: requestedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(requestedBy),
      requestedAt: requestedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(requestedAt),
      decidedBy: decidedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(decidedBy),
      decidedAt: decidedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(decidedAt),
      decision: decision == null && nullToAbsent
          ? const Value.absent()
          : Value(decision),
      decisionNote: decisionNote == null && nullToAbsent
          ? const Value.absent()
          : Value(decisionNote),
      successorApprovalId: successorApprovalId == null && nullToAbsent
          ? const Value.absent()
          : Value(successorApprovalId),
      obsidianRefId: obsidianRefId == null && nullToAbsent
          ? const Value.absent()
          : Value(obsidianRefId),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory ApprovalRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ApprovalRecord(
      id: serializer.fromJson<String>(json['id']),
      subjectType: serializer.fromJson<String>(json['subjectType']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      approvalType: serializer.fromJson<String>(json['approvalType']),
      state: serializer.fromJson<String>(json['state']),
      requestedBy: serializer.fromJson<String?>(json['requestedBy']),
      requestedAt: serializer.fromJson<DateTime?>(json['requestedAt']),
      decidedBy: serializer.fromJson<String?>(json['decidedBy']),
      decidedAt: serializer.fromJson<DateTime?>(json['decidedAt']),
      decision: serializer.fromJson<String?>(json['decision']),
      decisionNote: serializer.fromJson<String?>(json['decisionNote']),
      successorApprovalId: serializer.fromJson<String?>(
        json['successorApprovalId'],
      ),
      obsidianRefId: serializer.fromJson<String?>(json['obsidianRefId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subjectType': serializer.toJson<String>(subjectType),
      'subjectId': serializer.toJson<String>(subjectId),
      'approvalType': serializer.toJson<String>(approvalType),
      'state': serializer.toJson<String>(state),
      'requestedBy': serializer.toJson<String?>(requestedBy),
      'requestedAt': serializer.toJson<DateTime?>(requestedAt),
      'decidedBy': serializer.toJson<String?>(decidedBy),
      'decidedAt': serializer.toJson<DateTime?>(decidedAt),
      'decision': serializer.toJson<String?>(decision),
      'decisionNote': serializer.toJson<String?>(decisionNote),
      'successorApprovalId': serializer.toJson<String?>(successorApprovalId),
      'obsidianRefId': serializer.toJson<String?>(obsidianRefId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  ApprovalRecord copyWith({
    String? id,
    String? subjectType,
    String? subjectId,
    String? approvalType,
    String? state,
    Value<String?> requestedBy = const Value.absent(),
    Value<DateTime?> requestedAt = const Value.absent(),
    Value<String?> decidedBy = const Value.absent(),
    Value<DateTime?> decidedAt = const Value.absent(),
    Value<String?> decision = const Value.absent(),
    Value<String?> decisionNote = const Value.absent(),
    Value<String?> successorApprovalId = const Value.absent(),
    Value<String?> obsidianRefId = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => ApprovalRecord(
    id: id ?? this.id,
    subjectType: subjectType ?? this.subjectType,
    subjectId: subjectId ?? this.subjectId,
    approvalType: approvalType ?? this.approvalType,
    state: state ?? this.state,
    requestedBy: requestedBy.present ? requestedBy.value : this.requestedBy,
    requestedAt: requestedAt.present ? requestedAt.value : this.requestedAt,
    decidedBy: decidedBy.present ? decidedBy.value : this.decidedBy,
    decidedAt: decidedAt.present ? decidedAt.value : this.decidedAt,
    decision: decision.present ? decision.value : this.decision,
    decisionNote: decisionNote.present ? decisionNote.value : this.decisionNote,
    successorApprovalId: successorApprovalId.present
        ? successorApprovalId.value
        : this.successorApprovalId,
    obsidianRefId: obsidianRefId.present
        ? obsidianRefId.value
        : this.obsidianRefId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  ApprovalRecord copyWithCompanion(ApprovalRecordsCompanion data) {
    return ApprovalRecord(
      id: data.id.present ? data.id.value : this.id,
      subjectType: data.subjectType.present
          ? data.subjectType.value
          : this.subjectType,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      approvalType: data.approvalType.present
          ? data.approvalType.value
          : this.approvalType,
      state: data.state.present ? data.state.value : this.state,
      requestedBy: data.requestedBy.present
          ? data.requestedBy.value
          : this.requestedBy,
      requestedAt: data.requestedAt.present
          ? data.requestedAt.value
          : this.requestedAt,
      decidedBy: data.decidedBy.present ? data.decidedBy.value : this.decidedBy,
      decidedAt: data.decidedAt.present ? data.decidedAt.value : this.decidedAt,
      decision: data.decision.present ? data.decision.value : this.decision,
      decisionNote: data.decisionNote.present
          ? data.decisionNote.value
          : this.decisionNote,
      successorApprovalId: data.successorApprovalId.present
          ? data.successorApprovalId.value
          : this.successorApprovalId,
      obsidianRefId: data.obsidianRefId.present
          ? data.obsidianRefId.value
          : this.obsidianRefId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ApprovalRecord(')
          ..write('id: $id, ')
          ..write('subjectType: $subjectType, ')
          ..write('subjectId: $subjectId, ')
          ..write('approvalType: $approvalType, ')
          ..write('state: $state, ')
          ..write('requestedBy: $requestedBy, ')
          ..write('requestedAt: $requestedAt, ')
          ..write('decidedBy: $decidedBy, ')
          ..write('decidedAt: $decidedAt, ')
          ..write('decision: $decision, ')
          ..write('decisionNote: $decisionNote, ')
          ..write('successorApprovalId: $successorApprovalId, ')
          ..write('obsidianRefId: $obsidianRefId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    subjectType,
    subjectId,
    approvalType,
    state,
    requestedBy,
    requestedAt,
    decidedBy,
    decidedAt,
    decision,
    decisionNote,
    successorApprovalId,
    obsidianRefId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ApprovalRecord &&
          other.id == this.id &&
          other.subjectType == this.subjectType &&
          other.subjectId == this.subjectId &&
          other.approvalType == this.approvalType &&
          other.state == this.state &&
          other.requestedBy == this.requestedBy &&
          other.requestedAt == this.requestedAt &&
          other.decidedBy == this.decidedBy &&
          other.decidedAt == this.decidedAt &&
          other.decision == this.decision &&
          other.decisionNote == this.decisionNote &&
          other.successorApprovalId == this.successorApprovalId &&
          other.obsidianRefId == this.obsidianRefId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ApprovalRecordsCompanion extends UpdateCompanion<ApprovalRecord> {
  final Value<String> id;
  final Value<String> subjectType;
  final Value<String> subjectId;
  final Value<String> approvalType;
  final Value<String> state;
  final Value<String?> requestedBy;
  final Value<DateTime?> requestedAt;
  final Value<String?> decidedBy;
  final Value<DateTime?> decidedAt;
  final Value<String?> decision;
  final Value<String?> decisionNote;
  final Value<String?> successorApprovalId;
  final Value<String?> obsidianRefId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const ApprovalRecordsCompanion({
    this.id = const Value.absent(),
    this.subjectType = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.approvalType = const Value.absent(),
    this.state = const Value.absent(),
    this.requestedBy = const Value.absent(),
    this.requestedAt = const Value.absent(),
    this.decidedBy = const Value.absent(),
    this.decidedAt = const Value.absent(),
    this.decision = const Value.absent(),
    this.decisionNote = const Value.absent(),
    this.successorApprovalId = const Value.absent(),
    this.obsidianRefId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ApprovalRecordsCompanion.insert({
    required String id,
    required String subjectType,
    required String subjectId,
    required String approvalType,
    this.state = const Value.absent(),
    this.requestedBy = const Value.absent(),
    this.requestedAt = const Value.absent(),
    this.decidedBy = const Value.absent(),
    this.decidedAt = const Value.absent(),
    this.decision = const Value.absent(),
    this.decisionNote = const Value.absent(),
    this.successorApprovalId = const Value.absent(),
    this.obsidianRefId = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       subjectType = Value(subjectType),
       subjectId = Value(subjectId),
       approvalType = Value(approvalType),
       createdAt = Value(createdAt);
  static Insertable<ApprovalRecord> custom({
    Expression<String>? id,
    Expression<String>? subjectType,
    Expression<String>? subjectId,
    Expression<String>? approvalType,
    Expression<String>? state,
    Expression<String>? requestedBy,
    Expression<DateTime>? requestedAt,
    Expression<String>? decidedBy,
    Expression<DateTime>? decidedAt,
    Expression<String>? decision,
    Expression<String>? decisionNote,
    Expression<String>? successorApprovalId,
    Expression<String>? obsidianRefId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectType != null) 'subject_type': subjectType,
      if (subjectId != null) 'subject_id': subjectId,
      if (approvalType != null) 'approval_type': approvalType,
      if (state != null) 'state': state,
      if (requestedBy != null) 'requested_by': requestedBy,
      if (requestedAt != null) 'requested_at': requestedAt,
      if (decidedBy != null) 'decided_by': decidedBy,
      if (decidedAt != null) 'decided_at': decidedAt,
      if (decision != null) 'decision': decision,
      if (decisionNote != null) 'decision_note': decisionNote,
      if (successorApprovalId != null)
        'successor_approval_id': successorApprovalId,
      if (obsidianRefId != null) 'obsidian_ref_id': obsidianRefId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ApprovalRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? subjectType,
    Value<String>? subjectId,
    Value<String>? approvalType,
    Value<String>? state,
    Value<String?>? requestedBy,
    Value<DateTime?>? requestedAt,
    Value<String?>? decidedBy,
    Value<DateTime?>? decidedAt,
    Value<String?>? decision,
    Value<String?>? decisionNote,
    Value<String?>? successorApprovalId,
    Value<String?>? obsidianRefId,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return ApprovalRecordsCompanion(
      id: id ?? this.id,
      subjectType: subjectType ?? this.subjectType,
      subjectId: subjectId ?? this.subjectId,
      approvalType: approvalType ?? this.approvalType,
      state: state ?? this.state,
      requestedBy: requestedBy ?? this.requestedBy,
      requestedAt: requestedAt ?? this.requestedAt,
      decidedBy: decidedBy ?? this.decidedBy,
      decidedAt: decidedAt ?? this.decidedAt,
      decision: decision ?? this.decision,
      decisionNote: decisionNote ?? this.decisionNote,
      successorApprovalId: successorApprovalId ?? this.successorApprovalId,
      obsidianRefId: obsidianRefId ?? this.obsidianRefId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (subjectType.present) {
      map['subject_type'] = Variable<String>(subjectType.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (approvalType.present) {
      map['approval_type'] = Variable<String>(approvalType.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (requestedBy.present) {
      map['requested_by'] = Variable<String>(requestedBy.value);
    }
    if (requestedAt.present) {
      map['requested_at'] = Variable<DateTime>(requestedAt.value);
    }
    if (decidedBy.present) {
      map['decided_by'] = Variable<String>(decidedBy.value);
    }
    if (decidedAt.present) {
      map['decided_at'] = Variable<DateTime>(decidedAt.value);
    }
    if (decision.present) {
      map['decision'] = Variable<String>(decision.value);
    }
    if (decisionNote.present) {
      map['decision_note'] = Variable<String>(decisionNote.value);
    }
    if (successorApprovalId.present) {
      map['successor_approval_id'] = Variable<String>(
        successorApprovalId.value,
      );
    }
    if (obsidianRefId.present) {
      map['obsidian_ref_id'] = Variable<String>(obsidianRefId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ApprovalRecordsCompanion(')
          ..write('id: $id, ')
          ..write('subjectType: $subjectType, ')
          ..write('subjectId: $subjectId, ')
          ..write('approvalType: $approvalType, ')
          ..write('state: $state, ')
          ..write('requestedBy: $requestedBy, ')
          ..write('requestedAt: $requestedAt, ')
          ..write('decidedBy: $decidedBy, ')
          ..write('decidedAt: $decidedAt, ')
          ..write('decision: $decision, ')
          ..write('decisionNote: $decisionNote, ')
          ..write('successorApprovalId: $successorApprovalId, ')
          ..write('obsidianRefId: $obsidianRefId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$RynAppDatabase extends GeneratedDatabase {
  _$RynAppDatabase(QueryExecutor e) : super(e);
  $RynAppDatabaseManager get managers => $RynAppDatabaseManager(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $ObsidianReportRefsTable obsidianReportRefs =
      $ObsidianReportRefsTable(this);
  late final $AuditTrailTable auditTrail = $AuditTrailTable(this);
  late final $MissionsTable missions = $MissionsTable(this);
  late final $TaskCardsTable taskCards = $TaskCardsTable(this);
  late final $AgentRunsTable agentRuns = $AgentRunsTable(this);
  late final $ApprovalRecordsTable approvalRecords = $ApprovalRecordsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appSettings,
    obsidianReportRefs,
    auditTrail,
    missions,
    taskCards,
    agentRuns,
    approvalRecords,
  ];
}

typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      Value<String?> value,
      Value<String> valueType,
      Value<String> redactionState,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<String> valueType,
      Value<String> redactionState,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$RynAppDatabase, $AppSettingsTable> {
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

  ColumnFilters<String> get valueType => $composableBuilder(
    column: $table.valueType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get redactionState => $composableBuilder(
    column: $table.redactionState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$RynAppDatabase, $AppSettingsTable> {
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

  ColumnOrderings<String> get valueType => $composableBuilder(
    column: $table.valueType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get redactionState => $composableBuilder(
    column: $table.redactionState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$RynAppDatabase, $AppSettingsTable> {
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

  GeneratedColumn<String> get valueType =>
      $composableBuilder(column: $table.valueType, builder: (column) => column);

  GeneratedColumn<String> get redactionState => $composableBuilder(
    column: $table.redactionState,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$RynAppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$RynAppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$RynAppDatabase db, $AppSettingsTable table)
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
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<String> valueType = const Value.absent(),
                Value<String> redactionState = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                value: value,
                valueType: valueType,
                redactionState: redactionState,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                Value<String> valueType = const Value.absent(),
                Value<String> redactionState = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                valueType: valueType,
                redactionState: redactionState,
                updatedAt: updatedAt,
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
      _$RynAppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$RynAppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$ObsidianReportRefsTableCreateCompanionBuilder =
    ObsidianReportRefsCompanion Function({
      required String id,
      required String docType,
      required String vaultPath,
      Value<String?> sha256,
      Value<String> redactionState,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$ObsidianReportRefsTableUpdateCompanionBuilder =
    ObsidianReportRefsCompanion Function({
      Value<String> id,
      Value<String> docType,
      Value<String> vaultPath,
      Value<String?> sha256,
      Value<String> redactionState,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$ObsidianReportRefsTableFilterComposer
    extends Composer<_$RynAppDatabase, $ObsidianReportRefsTable> {
  $$ObsidianReportRefsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get docType => $composableBuilder(
    column: $table.docType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vaultPath => $composableBuilder(
    column: $table.vaultPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get redactionState => $composableBuilder(
    column: $table.redactionState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ObsidianReportRefsTableOrderingComposer
    extends Composer<_$RynAppDatabase, $ObsidianReportRefsTable> {
  $$ObsidianReportRefsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get docType => $composableBuilder(
    column: $table.docType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vaultPath => $composableBuilder(
    column: $table.vaultPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get redactionState => $composableBuilder(
    column: $table.redactionState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ObsidianReportRefsTableAnnotationComposer
    extends Composer<_$RynAppDatabase, $ObsidianReportRefsTable> {
  $$ObsidianReportRefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get docType =>
      $composableBuilder(column: $table.docType, builder: (column) => column);

  GeneratedColumn<String> get vaultPath =>
      $composableBuilder(column: $table.vaultPath, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<String> get redactionState => $composableBuilder(
    column: $table.redactionState,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ObsidianReportRefsTableTableManager
    extends
        RootTableManager<
          _$RynAppDatabase,
          $ObsidianReportRefsTable,
          ObsidianReportRef,
          $$ObsidianReportRefsTableFilterComposer,
          $$ObsidianReportRefsTableOrderingComposer,
          $$ObsidianReportRefsTableAnnotationComposer,
          $$ObsidianReportRefsTableCreateCompanionBuilder,
          $$ObsidianReportRefsTableUpdateCompanionBuilder,
          (
            ObsidianReportRef,
            BaseReferences<
              _$RynAppDatabase,
              $ObsidianReportRefsTable,
              ObsidianReportRef
            >,
          ),
          ObsidianReportRef,
          PrefetchHooks Function()
        > {
  $$ObsidianReportRefsTableTableManager(
    _$RynAppDatabase db,
    $ObsidianReportRefsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ObsidianReportRefsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ObsidianReportRefsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ObsidianReportRefsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> docType = const Value.absent(),
                Value<String> vaultPath = const Value.absent(),
                Value<String?> sha256 = const Value.absent(),
                Value<String> redactionState = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObsidianReportRefsCompanion(
                id: id,
                docType: docType,
                vaultPath: vaultPath,
                sha256: sha256,
                redactionState: redactionState,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String docType,
                required String vaultPath,
                Value<String?> sha256 = const Value.absent(),
                Value<String> redactionState = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObsidianReportRefsCompanion.insert(
                id: id,
                docType: docType,
                vaultPath: vaultPath,
                sha256: sha256,
                redactionState: redactionState,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ObsidianReportRefsTableProcessedTableManager =
    ProcessedTableManager<
      _$RynAppDatabase,
      $ObsidianReportRefsTable,
      ObsidianReportRef,
      $$ObsidianReportRefsTableFilterComposer,
      $$ObsidianReportRefsTableOrderingComposer,
      $$ObsidianReportRefsTableAnnotationComposer,
      $$ObsidianReportRefsTableCreateCompanionBuilder,
      $$ObsidianReportRefsTableUpdateCompanionBuilder,
      (
        ObsidianReportRef,
        BaseReferences<
          _$RynAppDatabase,
          $ObsidianReportRefsTable,
          ObsidianReportRef
        >,
      ),
      ObsidianReportRef,
      PrefetchHooks Function()
    >;
typedef $$AuditTrailTableCreateCompanionBuilder =
    AuditTrailCompanion Function({
      required String id,
      required DateTime occurredAt,
      required String actorType,
      Value<String?> actorId,
      required String action,
      required String targetType,
      Value<String?> targetId,
      Value<String?> beforeHash,
      Value<String?> afterHash,
      Value<String?> redactedSnapshot,
      Value<String> redactionState,
      Value<String?> reason,
      Value<String?> correlationId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$AuditTrailTableUpdateCompanionBuilder =
    AuditTrailCompanion Function({
      Value<String> id,
      Value<DateTime> occurredAt,
      Value<String> actorType,
      Value<String?> actorId,
      Value<String> action,
      Value<String> targetType,
      Value<String?> targetId,
      Value<String?> beforeHash,
      Value<String?> afterHash,
      Value<String?> redactedSnapshot,
      Value<String> redactionState,
      Value<String?> reason,
      Value<String?> correlationId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$AuditTrailTableFilterComposer
    extends Composer<_$RynAppDatabase, $AuditTrailTable> {
  $$AuditTrailTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorType => $composableBuilder(
    column: $table.actorType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beforeHash => $composableBuilder(
    column: $table.beforeHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get afterHash => $composableBuilder(
    column: $table.afterHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get redactedSnapshot => $composableBuilder(
    column: $table.redactedSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get redactionState => $composableBuilder(
    column: $table.redactionState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correlationId => $composableBuilder(
    column: $table.correlationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuditTrailTableOrderingComposer
    extends Composer<_$RynAppDatabase, $AuditTrailTable> {
  $$AuditTrailTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorType => $composableBuilder(
    column: $table.actorType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beforeHash => $composableBuilder(
    column: $table.beforeHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get afterHash => $composableBuilder(
    column: $table.afterHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get redactedSnapshot => $composableBuilder(
    column: $table.redactedSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get redactionState => $composableBuilder(
    column: $table.redactionState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correlationId => $composableBuilder(
    column: $table.correlationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditTrailTableAnnotationComposer
    extends Composer<_$RynAppDatabase, $AuditTrailTable> {
  $$AuditTrailTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actorType =>
      $composableBuilder(column: $table.actorType, builder: (column) => column);

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get beforeHash => $composableBuilder(
    column: $table.beforeHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get afterHash =>
      $composableBuilder(column: $table.afterHash, builder: (column) => column);

  GeneratedColumn<String> get redactedSnapshot => $composableBuilder(
    column: $table.redactedSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get redactionState => $composableBuilder(
    column: $table.redactionState,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get correlationId => $composableBuilder(
    column: $table.correlationId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AuditTrailTableTableManager
    extends
        RootTableManager<
          _$RynAppDatabase,
          $AuditTrailTable,
          AuditTrailData,
          $$AuditTrailTableFilterComposer,
          $$AuditTrailTableOrderingComposer,
          $$AuditTrailTableAnnotationComposer,
          $$AuditTrailTableCreateCompanionBuilder,
          $$AuditTrailTableUpdateCompanionBuilder,
          (
            AuditTrailData,
            BaseReferences<_$RynAppDatabase, $AuditTrailTable, AuditTrailData>,
          ),
          AuditTrailData,
          PrefetchHooks Function()
        > {
  $$AuditTrailTableTableManager(_$RynAppDatabase db, $AuditTrailTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditTrailTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditTrailTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditTrailTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String> actorType = const Value.absent(),
                Value<String?> actorId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> targetType = const Value.absent(),
                Value<String?> targetId = const Value.absent(),
                Value<String?> beforeHash = const Value.absent(),
                Value<String?> afterHash = const Value.absent(),
                Value<String?> redactedSnapshot = const Value.absent(),
                Value<String> redactionState = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String?> correlationId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditTrailCompanion(
                id: id,
                occurredAt: occurredAt,
                actorType: actorType,
                actorId: actorId,
                action: action,
                targetType: targetType,
                targetId: targetId,
                beforeHash: beforeHash,
                afterHash: afterHash,
                redactedSnapshot: redactedSnapshot,
                redactionState: redactionState,
                reason: reason,
                correlationId: correlationId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime occurredAt,
                required String actorType,
                Value<String?> actorId = const Value.absent(),
                required String action,
                required String targetType,
                Value<String?> targetId = const Value.absent(),
                Value<String?> beforeHash = const Value.absent(),
                Value<String?> afterHash = const Value.absent(),
                Value<String?> redactedSnapshot = const Value.absent(),
                Value<String> redactionState = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String?> correlationId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AuditTrailCompanion.insert(
                id: id,
                occurredAt: occurredAt,
                actorType: actorType,
                actorId: actorId,
                action: action,
                targetType: targetType,
                targetId: targetId,
                beforeHash: beforeHash,
                afterHash: afterHash,
                redactedSnapshot: redactedSnapshot,
                redactionState: redactionState,
                reason: reason,
                correlationId: correlationId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuditTrailTableProcessedTableManager =
    ProcessedTableManager<
      _$RynAppDatabase,
      $AuditTrailTable,
      AuditTrailData,
      $$AuditTrailTableFilterComposer,
      $$AuditTrailTableOrderingComposer,
      $$AuditTrailTableAnnotationComposer,
      $$AuditTrailTableCreateCompanionBuilder,
      $$AuditTrailTableUpdateCompanionBuilder,
      (
        AuditTrailData,
        BaseReferences<_$RynAppDatabase, $AuditTrailTable, AuditTrailData>,
      ),
      AuditTrailData,
      PrefetchHooks Function()
    >;
typedef $$MissionsTableCreateCompanionBuilder =
    MissionsCompanion Function({
      required String id,
      required String title,
      Value<String?> description,
      Value<String> status,
      Value<String> mode,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });
typedef $$MissionsTableUpdateCompanionBuilder =
    MissionsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> description,
      Value<String> status,
      Value<String> mode,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });

class $$MissionsTableFilterComposer
    extends Composer<_$RynAppDatabase, $MissionsTable> {
  $$MissionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MissionsTableOrderingComposer
    extends Composer<_$RynAppDatabase, $MissionsTable> {
  $$MissionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MissionsTableAnnotationComposer
    extends Composer<_$RynAppDatabase, $MissionsTable> {
  $$MissionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );
}

class $$MissionsTableTableManager
    extends
        RootTableManager<
          _$RynAppDatabase,
          $MissionsTable,
          Mission,
          $$MissionsTableFilterComposer,
          $$MissionsTableOrderingComposer,
          $$MissionsTableAnnotationComposer,
          $$MissionsTableCreateCompanionBuilder,
          $$MissionsTableUpdateCompanionBuilder,
          (Mission, BaseReferences<_$RynAppDatabase, $MissionsTable, Mission>),
          Mission,
          PrefetchHooks Function()
        > {
  $$MissionsTableTableManager(_$RynAppDatabase db, $MissionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MissionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MissionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MissionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MissionsCompanion(
                id: id,
                title: title,
                description: description,
                status: status,
                mode: mode,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> mode = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MissionsCompanion.insert(
                id: id,
                title: title,
                description: description,
                status: status,
                mode: mode,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MissionsTableProcessedTableManager =
    ProcessedTableManager<
      _$RynAppDatabase,
      $MissionsTable,
      Mission,
      $$MissionsTableFilterComposer,
      $$MissionsTableOrderingComposer,
      $$MissionsTableAnnotationComposer,
      $$MissionsTableCreateCompanionBuilder,
      $$MissionsTableUpdateCompanionBuilder,
      (Mission, BaseReferences<_$RynAppDatabase, $MissionsTable, Mission>),
      Mission,
      PrefetchHooks Function()
    >;
typedef $$TaskCardsTableCreateCompanionBuilder =
    TaskCardsCompanion Function({
      required String id,
      Value<String?> missionId,
      required String title,
      Value<String?> description,
      Value<String> lane,
      Value<String> status,
      Value<String> priority,
      Value<String?> orderKey,
      Value<String> riskLevel,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });
typedef $$TaskCardsTableUpdateCompanionBuilder =
    TaskCardsCompanion Function({
      Value<String> id,
      Value<String?> missionId,
      Value<String> title,
      Value<String?> description,
      Value<String> lane,
      Value<String> status,
      Value<String> priority,
      Value<String?> orderKey,
      Value<String> riskLevel,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });

class $$TaskCardsTableFilterComposer
    extends Composer<_$RynAppDatabase, $TaskCardsTable> {
  $$TaskCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get missionId => $composableBuilder(
    column: $table.missionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lane => $composableBuilder(
    column: $table.lane,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderKey => $composableBuilder(
    column: $table.orderKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get riskLevel => $composableBuilder(
    column: $table.riskLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaskCardsTableOrderingComposer
    extends Composer<_$RynAppDatabase, $TaskCardsTable> {
  $$TaskCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get missionId => $composableBuilder(
    column: $table.missionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lane => $composableBuilder(
    column: $table.lane,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderKey => $composableBuilder(
    column: $table.orderKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get riskLevel => $composableBuilder(
    column: $table.riskLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaskCardsTableAnnotationComposer
    extends Composer<_$RynAppDatabase, $TaskCardsTable> {
  $$TaskCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get missionId =>
      $composableBuilder(column: $table.missionId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lane =>
      $composableBuilder(column: $table.lane, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get orderKey =>
      $composableBuilder(column: $table.orderKey, builder: (column) => column);

  GeneratedColumn<String> get riskLevel =>
      $composableBuilder(column: $table.riskLevel, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );
}

class $$TaskCardsTableTableManager
    extends
        RootTableManager<
          _$RynAppDatabase,
          $TaskCardsTable,
          TaskCard,
          $$TaskCardsTableFilterComposer,
          $$TaskCardsTableOrderingComposer,
          $$TaskCardsTableAnnotationComposer,
          $$TaskCardsTableCreateCompanionBuilder,
          $$TaskCardsTableUpdateCompanionBuilder,
          (
            TaskCard,
            BaseReferences<_$RynAppDatabase, $TaskCardsTable, TaskCard>,
          ),
          TaskCard,
          PrefetchHooks Function()
        > {
  $$TaskCardsTableTableManager(_$RynAppDatabase db, $TaskCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> missionId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> lane = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<String?> orderKey = const Value.absent(),
                Value<String> riskLevel = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskCardsCompanion(
                id: id,
                missionId: missionId,
                title: title,
                description: description,
                lane: lane,
                status: status,
                priority: priority,
                orderKey: orderKey,
                riskLevel: riskLevel,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> missionId = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String> lane = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<String?> orderKey = const Value.absent(),
                Value<String> riskLevel = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskCardsCompanion.insert(
                id: id,
                missionId: missionId,
                title: title,
                description: description,
                lane: lane,
                status: status,
                priority: priority,
                orderKey: orderKey,
                riskLevel: riskLevel,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaskCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$RynAppDatabase,
      $TaskCardsTable,
      TaskCard,
      $$TaskCardsTableFilterComposer,
      $$TaskCardsTableOrderingComposer,
      $$TaskCardsTableAnnotationComposer,
      $$TaskCardsTableCreateCompanionBuilder,
      $$TaskCardsTableUpdateCompanionBuilder,
      (TaskCard, BaseReferences<_$RynAppDatabase, $TaskCardsTable, TaskCard>),
      TaskCard,
      PrefetchHooks Function()
    >;
typedef $$AgentRunsTableCreateCompanionBuilder =
    AgentRunsCompanion Function({
      required String id,
      Value<String?> missionId,
      Value<String?> taskCardId,
      required String agentName,
      Value<String> runKind,
      Value<String> phase,
      Value<String> condition,
      Value<String> autonomyLevel,
      Value<String> executionTarget,
      Value<DateTime?> startedAt,
      Value<DateTime?> endedAt,
      Value<String?> summary,
      Value<String?> errorText,
      Value<String?> outputRef,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$AgentRunsTableUpdateCompanionBuilder =
    AgentRunsCompanion Function({
      Value<String> id,
      Value<String?> missionId,
      Value<String?> taskCardId,
      Value<String> agentName,
      Value<String> runKind,
      Value<String> phase,
      Value<String> condition,
      Value<String> autonomyLevel,
      Value<String> executionTarget,
      Value<DateTime?> startedAt,
      Value<DateTime?> endedAt,
      Value<String?> summary,
      Value<String?> errorText,
      Value<String?> outputRef,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$AgentRunsTableFilterComposer
    extends Composer<_$RynAppDatabase, $AgentRunsTable> {
  $$AgentRunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get missionId => $composableBuilder(
    column: $table.missionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskCardId => $composableBuilder(
    column: $table.taskCardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get agentName => $composableBuilder(
    column: $table.agentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get runKind => $composableBuilder(
    column: $table.runKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get autonomyLevel => $composableBuilder(
    column: $table.autonomyLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get executionTarget => $composableBuilder(
    column: $table.executionTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorText => $composableBuilder(
    column: $table.errorText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outputRef => $composableBuilder(
    column: $table.outputRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AgentRunsTableOrderingComposer
    extends Composer<_$RynAppDatabase, $AgentRunsTable> {
  $$AgentRunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get missionId => $composableBuilder(
    column: $table.missionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskCardId => $composableBuilder(
    column: $table.taskCardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get agentName => $composableBuilder(
    column: $table.agentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get runKind => $composableBuilder(
    column: $table.runKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get autonomyLevel => $composableBuilder(
    column: $table.autonomyLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get executionTarget => $composableBuilder(
    column: $table.executionTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorText => $composableBuilder(
    column: $table.errorText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outputRef => $composableBuilder(
    column: $table.outputRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AgentRunsTableAnnotationComposer
    extends Composer<_$RynAppDatabase, $AgentRunsTable> {
  $$AgentRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get missionId =>
      $composableBuilder(column: $table.missionId, builder: (column) => column);

  GeneratedColumn<String> get taskCardId => $composableBuilder(
    column: $table.taskCardId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get agentName =>
      $composableBuilder(column: $table.agentName, builder: (column) => column);

  GeneratedColumn<String> get runKind =>
      $composableBuilder(column: $table.runKind, builder: (column) => column);

  GeneratedColumn<String> get phase =>
      $composableBuilder(column: $table.phase, builder: (column) => column);

  GeneratedColumn<String> get condition =>
      $composableBuilder(column: $table.condition, builder: (column) => column);

  GeneratedColumn<String> get autonomyLevel => $composableBuilder(
    column: $table.autonomyLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get executionTarget => $composableBuilder(
    column: $table.executionTarget,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get errorText =>
      $composableBuilder(column: $table.errorText, builder: (column) => column);

  GeneratedColumn<String> get outputRef =>
      $composableBuilder(column: $table.outputRef, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AgentRunsTableTableManager
    extends
        RootTableManager<
          _$RynAppDatabase,
          $AgentRunsTable,
          AgentRun,
          $$AgentRunsTableFilterComposer,
          $$AgentRunsTableOrderingComposer,
          $$AgentRunsTableAnnotationComposer,
          $$AgentRunsTableCreateCompanionBuilder,
          $$AgentRunsTableUpdateCompanionBuilder,
          (
            AgentRun,
            BaseReferences<_$RynAppDatabase, $AgentRunsTable, AgentRun>,
          ),
          AgentRun,
          PrefetchHooks Function()
        > {
  $$AgentRunsTableTableManager(_$RynAppDatabase db, $AgentRunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AgentRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AgentRunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AgentRunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> missionId = const Value.absent(),
                Value<String?> taskCardId = const Value.absent(),
                Value<String> agentName = const Value.absent(),
                Value<String> runKind = const Value.absent(),
                Value<String> phase = const Value.absent(),
                Value<String> condition = const Value.absent(),
                Value<String> autonomyLevel = const Value.absent(),
                Value<String> executionTarget = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String?> errorText = const Value.absent(),
                Value<String?> outputRef = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AgentRunsCompanion(
                id: id,
                missionId: missionId,
                taskCardId: taskCardId,
                agentName: agentName,
                runKind: runKind,
                phase: phase,
                condition: condition,
                autonomyLevel: autonomyLevel,
                executionTarget: executionTarget,
                startedAt: startedAt,
                endedAt: endedAt,
                summary: summary,
                errorText: errorText,
                outputRef: outputRef,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> missionId = const Value.absent(),
                Value<String?> taskCardId = const Value.absent(),
                required String agentName,
                Value<String> runKind = const Value.absent(),
                Value<String> phase = const Value.absent(),
                Value<String> condition = const Value.absent(),
                Value<String> autonomyLevel = const Value.absent(),
                Value<String> executionTarget = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String?> errorText = const Value.absent(),
                Value<String?> outputRef = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AgentRunsCompanion.insert(
                id: id,
                missionId: missionId,
                taskCardId: taskCardId,
                agentName: agentName,
                runKind: runKind,
                phase: phase,
                condition: condition,
                autonomyLevel: autonomyLevel,
                executionTarget: executionTarget,
                startedAt: startedAt,
                endedAt: endedAt,
                summary: summary,
                errorText: errorText,
                outputRef: outputRef,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AgentRunsTableProcessedTableManager =
    ProcessedTableManager<
      _$RynAppDatabase,
      $AgentRunsTable,
      AgentRun,
      $$AgentRunsTableFilterComposer,
      $$AgentRunsTableOrderingComposer,
      $$AgentRunsTableAnnotationComposer,
      $$AgentRunsTableCreateCompanionBuilder,
      $$AgentRunsTableUpdateCompanionBuilder,
      (AgentRun, BaseReferences<_$RynAppDatabase, $AgentRunsTable, AgentRun>),
      AgentRun,
      PrefetchHooks Function()
    >;
typedef $$ApprovalRecordsTableCreateCompanionBuilder =
    ApprovalRecordsCompanion Function({
      required String id,
      required String subjectType,
      required String subjectId,
      required String approvalType,
      Value<String> state,
      Value<String?> requestedBy,
      Value<DateTime?> requestedAt,
      Value<String?> decidedBy,
      Value<DateTime?> decidedAt,
      Value<String?> decision,
      Value<String?> decisionNote,
      Value<String?> successorApprovalId,
      Value<String?> obsidianRefId,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$ApprovalRecordsTableUpdateCompanionBuilder =
    ApprovalRecordsCompanion Function({
      Value<String> id,
      Value<String> subjectType,
      Value<String> subjectId,
      Value<String> approvalType,
      Value<String> state,
      Value<String?> requestedBy,
      Value<DateTime?> requestedAt,
      Value<String?> decidedBy,
      Value<DateTime?> decidedAt,
      Value<String?> decision,
      Value<String?> decisionNote,
      Value<String?> successorApprovalId,
      Value<String?> obsidianRefId,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$ApprovalRecordsTableFilterComposer
    extends Composer<_$RynAppDatabase, $ApprovalRecordsTable> {
  $$ApprovalRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectType => $composableBuilder(
    column: $table.subjectType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get approvalType => $composableBuilder(
    column: $table.approvalType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestedBy => $composableBuilder(
    column: $table.requestedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get requestedAt => $composableBuilder(
    column: $table.requestedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decidedBy => $composableBuilder(
    column: $table.decidedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get decidedAt => $composableBuilder(
    column: $table.decidedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decision => $composableBuilder(
    column: $table.decision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decisionNote => $composableBuilder(
    column: $table.decisionNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get successorApprovalId => $composableBuilder(
    column: $table.successorApprovalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get obsidianRefId => $composableBuilder(
    column: $table.obsidianRefId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ApprovalRecordsTableOrderingComposer
    extends Composer<_$RynAppDatabase, $ApprovalRecordsTable> {
  $$ApprovalRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectType => $composableBuilder(
    column: $table.subjectType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get approvalType => $composableBuilder(
    column: $table.approvalType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestedBy => $composableBuilder(
    column: $table.requestedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get requestedAt => $composableBuilder(
    column: $table.requestedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decidedBy => $composableBuilder(
    column: $table.decidedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get decidedAt => $composableBuilder(
    column: $table.decidedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decision => $composableBuilder(
    column: $table.decision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decisionNote => $composableBuilder(
    column: $table.decisionNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get successorApprovalId => $composableBuilder(
    column: $table.successorApprovalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get obsidianRefId => $composableBuilder(
    column: $table.obsidianRefId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ApprovalRecordsTableAnnotationComposer
    extends Composer<_$RynAppDatabase, $ApprovalRecordsTable> {
  $$ApprovalRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get subjectType => $composableBuilder(
    column: $table.subjectType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get approvalType => $composableBuilder(
    column: $table.approvalType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get requestedBy => $composableBuilder(
    column: $table.requestedBy,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get requestedAt => $composableBuilder(
    column: $table.requestedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get decidedBy =>
      $composableBuilder(column: $table.decidedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get decidedAt =>
      $composableBuilder(column: $table.decidedAt, builder: (column) => column);

  GeneratedColumn<String> get decision =>
      $composableBuilder(column: $table.decision, builder: (column) => column);

  GeneratedColumn<String> get decisionNote => $composableBuilder(
    column: $table.decisionNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get successorApprovalId => $composableBuilder(
    column: $table.successorApprovalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get obsidianRefId => $composableBuilder(
    column: $table.obsidianRefId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ApprovalRecordsTableTableManager
    extends
        RootTableManager<
          _$RynAppDatabase,
          $ApprovalRecordsTable,
          ApprovalRecord,
          $$ApprovalRecordsTableFilterComposer,
          $$ApprovalRecordsTableOrderingComposer,
          $$ApprovalRecordsTableAnnotationComposer,
          $$ApprovalRecordsTableCreateCompanionBuilder,
          $$ApprovalRecordsTableUpdateCompanionBuilder,
          (
            ApprovalRecord,
            BaseReferences<
              _$RynAppDatabase,
              $ApprovalRecordsTable,
              ApprovalRecord
            >,
          ),
          ApprovalRecord,
          PrefetchHooks Function()
        > {
  $$ApprovalRecordsTableTableManager(
    _$RynAppDatabase db,
    $ApprovalRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ApprovalRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ApprovalRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ApprovalRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> subjectType = const Value.absent(),
                Value<String> subjectId = const Value.absent(),
                Value<String> approvalType = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String?> requestedBy = const Value.absent(),
                Value<DateTime?> requestedAt = const Value.absent(),
                Value<String?> decidedBy = const Value.absent(),
                Value<DateTime?> decidedAt = const Value.absent(),
                Value<String?> decision = const Value.absent(),
                Value<String?> decisionNote = const Value.absent(),
                Value<String?> successorApprovalId = const Value.absent(),
                Value<String?> obsidianRefId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApprovalRecordsCompanion(
                id: id,
                subjectType: subjectType,
                subjectId: subjectId,
                approvalType: approvalType,
                state: state,
                requestedBy: requestedBy,
                requestedAt: requestedAt,
                decidedBy: decidedBy,
                decidedAt: decidedAt,
                decision: decision,
                decisionNote: decisionNote,
                successorApprovalId: successorApprovalId,
                obsidianRefId: obsidianRefId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String subjectType,
                required String subjectId,
                required String approvalType,
                Value<String> state = const Value.absent(),
                Value<String?> requestedBy = const Value.absent(),
                Value<DateTime?> requestedAt = const Value.absent(),
                Value<String?> decidedBy = const Value.absent(),
                Value<DateTime?> decidedAt = const Value.absent(),
                Value<String?> decision = const Value.absent(),
                Value<String?> decisionNote = const Value.absent(),
                Value<String?> successorApprovalId = const Value.absent(),
                Value<String?> obsidianRefId = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApprovalRecordsCompanion.insert(
                id: id,
                subjectType: subjectType,
                subjectId: subjectId,
                approvalType: approvalType,
                state: state,
                requestedBy: requestedBy,
                requestedAt: requestedAt,
                decidedBy: decidedBy,
                decidedAt: decidedAt,
                decision: decision,
                decisionNote: decisionNote,
                successorApprovalId: successorApprovalId,
                obsidianRefId: obsidianRefId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ApprovalRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$RynAppDatabase,
      $ApprovalRecordsTable,
      ApprovalRecord,
      $$ApprovalRecordsTableFilterComposer,
      $$ApprovalRecordsTableOrderingComposer,
      $$ApprovalRecordsTableAnnotationComposer,
      $$ApprovalRecordsTableCreateCompanionBuilder,
      $$ApprovalRecordsTableUpdateCompanionBuilder,
      (
        ApprovalRecord,
        BaseReferences<_$RynAppDatabase, $ApprovalRecordsTable, ApprovalRecord>,
      ),
      ApprovalRecord,
      PrefetchHooks Function()
    >;

class $RynAppDatabaseManager {
  final _$RynAppDatabase _db;
  $RynAppDatabaseManager(this._db);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$ObsidianReportRefsTableTableManager get obsidianReportRefs =>
      $$ObsidianReportRefsTableTableManager(_db, _db.obsidianReportRefs);
  $$AuditTrailTableTableManager get auditTrail =>
      $$AuditTrailTableTableManager(_db, _db.auditTrail);
  $$MissionsTableTableManager get missions =>
      $$MissionsTableTableManager(_db, _db.missions);
  $$TaskCardsTableTableManager get taskCards =>
      $$TaskCardsTableTableManager(_db, _db.taskCards);
  $$AgentRunsTableTableManager get agentRuns =>
      $$AgentRunsTableTableManager(_db, _db.agentRuns);
  $$ApprovalRecordsTableTableManager get approvalRecords =>
      $$ApprovalRecordsTableTableManager(_db, _db.approvalRecords);
}
