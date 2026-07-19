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

class $TarotReadingsTable extends TarotReadings
    with TableInfo<$TarotReadingsTable, TarotReading> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TarotReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _readingInstanceIdMeta = const VerificationMeta(
    'readingInstanceId',
  );
  @override
  late final GeneratedColumn<String> readingInstanceId =
      GeneratedColumn<String>(
        'reading_instance_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionOriginalSnapshotMeta =
      const VerificationMeta('questionOriginalSnapshot');
  @override
  late final GeneratedColumn<String> questionOriginalSnapshot =
      GeneratedColumn<String>(
        'question_original_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _questionDisplayTextMeta =
      const VerificationMeta('questionDisplayText');
  @override
  late final GeneratedColumn<String> questionDisplayText =
      GeneratedColumn<String>(
        'question_display_text',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<String> deckId = GeneratedColumn<String>(
    'deck_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deckNameSnapshotMeta = const VerificationMeta(
    'deckNameSnapshot',
  );
  @override
  late final GeneratedColumn<String> deckNameSnapshot = GeneratedColumn<String>(
    'deck_name_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spreadIdMeta = const VerificationMeta(
    'spreadId',
  );
  @override
  late final GeneratedColumn<String> spreadId = GeneratedColumn<String>(
    'spread_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spreadNameSnapshotMeta =
      const VerificationMeta('spreadNameSnapshot');
  @override
  late final GeneratedColumn<String> spreadNameSnapshot =
      GeneratedColumn<String>(
        'spread_name_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _expectedPlacementCountMeta =
      const VerificationMeta('expectedPlacementCount');
  @override
  late final GeneratedColumn<int> expectedPlacementCount = GeneratedColumn<int>(
    'expected_placement_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readingAtUtcUsMeta = const VerificationMeta(
    'readingAtUtcUs',
  );
  @override
  late final GeneratedColumn<int> readingAtUtcUs = GeneratedColumn<int>(
    'reading_at_utc_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readingTimezoneOffsetMinMeta =
      const VerificationMeta('readingTimezoneOffsetMin');
  @override
  late final GeneratedColumn<int> readingTimezoneOffsetMin =
      GeneratedColumn<int>(
        'reading_timezone_offset_min',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _createdAtUtcUsMeta = const VerificationMeta(
    'createdAtUtcUs',
  );
  @override
  late final GeneratedColumn<int> createdAtUtcUs = GeneratedColumn<int>(
    'created_at_utc_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcUsMeta = const VerificationMeta(
    'updatedAtUtcUs',
  );
  @override
  late final GeneratedColumn<int> updatedAtUtcUs = GeneratedColumn<int>(
    'updated_at_utc_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lifecycleStatusMeta = const VerificationMeta(
    'lifecycleStatus',
  );
  @override
  late final GeneratedColumn<String> lifecycleStatus = GeneratedColumn<String>(
    'lifecycle_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtUtcUsMeta = const VerificationMeta(
    'finishedAtUtcUs',
  );
  @override
  late final GeneratedColumn<int> finishedAtUtcUs = GeneratedColumn<int>(
    'finished_at_utc_us',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    readingInstanceId,
    sourceType,
    questionOriginalSnapshot,
    questionDisplayText,
    deckId,
    deckNameSnapshot,
    spreadId,
    spreadNameSnapshot,
    expectedPlacementCount,
    readingAtUtcUs,
    readingTimezoneOffsetMin,
    createdAtUtcUs,
    updatedAtUtcUs,
    lifecycleStatus,
    finishedAtUtcUs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tarot_readings';
  @override
  VerificationContext validateIntegrity(
    Insertable<TarotReading> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('reading_instance_id')) {
      context.handle(
        _readingInstanceIdMeta,
        readingInstanceId.isAcceptableOrUnknown(
          data['reading_instance_id']!,
          _readingInstanceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_readingInstanceIdMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('question_original_snapshot')) {
      context.handle(
        _questionOriginalSnapshotMeta,
        questionOriginalSnapshot.isAcceptableOrUnknown(
          data['question_original_snapshot']!,
          _questionOriginalSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionOriginalSnapshotMeta);
    }
    if (data.containsKey('question_display_text')) {
      context.handle(
        _questionDisplayTextMeta,
        questionDisplayText.isAcceptableOrUnknown(
          data['question_display_text']!,
          _questionDisplayTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionDisplayTextMeta);
    }
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('deck_name_snapshot')) {
      context.handle(
        _deckNameSnapshotMeta,
        deckNameSnapshot.isAcceptableOrUnknown(
          data['deck_name_snapshot']!,
          _deckNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deckNameSnapshotMeta);
    }
    if (data.containsKey('spread_id')) {
      context.handle(
        _spreadIdMeta,
        spreadId.isAcceptableOrUnknown(data['spread_id']!, _spreadIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spreadIdMeta);
    }
    if (data.containsKey('spread_name_snapshot')) {
      context.handle(
        _spreadNameSnapshotMeta,
        spreadNameSnapshot.isAcceptableOrUnknown(
          data['spread_name_snapshot']!,
          _spreadNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_spreadNameSnapshotMeta);
    }
    if (data.containsKey('expected_placement_count')) {
      context.handle(
        _expectedPlacementCountMeta,
        expectedPlacementCount.isAcceptableOrUnknown(
          data['expected_placement_count']!,
          _expectedPlacementCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expectedPlacementCountMeta);
    }
    if (data.containsKey('reading_at_utc_us')) {
      context.handle(
        _readingAtUtcUsMeta,
        readingAtUtcUs.isAcceptableOrUnknown(
          data['reading_at_utc_us']!,
          _readingAtUtcUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_readingAtUtcUsMeta);
    }
    if (data.containsKey('reading_timezone_offset_min')) {
      context.handle(
        _readingTimezoneOffsetMinMeta,
        readingTimezoneOffsetMin.isAcceptableOrUnknown(
          data['reading_timezone_offset_min']!,
          _readingTimezoneOffsetMinMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_readingTimezoneOffsetMinMeta);
    }
    if (data.containsKey('created_at_utc_us')) {
      context.handle(
        _createdAtUtcUsMeta,
        createdAtUtcUs.isAcceptableOrUnknown(
          data['created_at_utc_us']!,
          _createdAtUtcUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcUsMeta);
    }
    if (data.containsKey('updated_at_utc_us')) {
      context.handle(
        _updatedAtUtcUsMeta,
        updatedAtUtcUs.isAcceptableOrUnknown(
          data['updated_at_utc_us']!,
          _updatedAtUtcUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcUsMeta);
    }
    if (data.containsKey('lifecycle_status')) {
      context.handle(
        _lifecycleStatusMeta,
        lifecycleStatus.isAcceptableOrUnknown(
          data['lifecycle_status']!,
          _lifecycleStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lifecycleStatusMeta);
    }
    if (data.containsKey('finished_at_utc_us')) {
      context.handle(
        _finishedAtUtcUsMeta,
        finishedAtUtcUs.isAcceptableOrUnknown(
          data['finished_at_utc_us']!,
          _finishedAtUtcUsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {readingInstanceId};
  @override
  TarotReading map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TarotReading(
      readingInstanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reading_instance_id'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      questionOriginalSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_original_snapshot'],
      )!,
      questionDisplayText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_display_text'],
      )!,
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deck_id'],
      )!,
      deckNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deck_name_snapshot'],
      )!,
      spreadId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spread_id'],
      )!,
      spreadNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spread_name_snapshot'],
      )!,
      expectedPlacementCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_placement_count'],
      )!,
      readingAtUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reading_at_utc_us'],
      )!,
      readingTimezoneOffsetMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reading_timezone_offset_min'],
      )!,
      createdAtUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_us'],
      )!,
      updatedAtUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc_us'],
      )!,
      lifecycleStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lifecycle_status'],
      )!,
      finishedAtUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}finished_at_utc_us'],
      ),
    );
  }

  @override
  $TarotReadingsTable createAlias(String alias) {
    return $TarotReadingsTable(attachedDatabase, alias);
  }
}

class TarotReading extends DataClass implements Insertable<TarotReading> {
  final String readingInstanceId;
  final String sourceType;
  final String questionOriginalSnapshot;
  final String questionDisplayText;
  final String deckId;
  final String deckNameSnapshot;
  final String spreadId;
  final String spreadNameSnapshot;
  final int expectedPlacementCount;
  final int readingAtUtcUs;
  final int readingTimezoneOffsetMin;
  final int createdAtUtcUs;
  final int updatedAtUtcUs;
  final String lifecycleStatus;
  final int? finishedAtUtcUs;
  const TarotReading({
    required this.readingInstanceId,
    required this.sourceType,
    required this.questionOriginalSnapshot,
    required this.questionDisplayText,
    required this.deckId,
    required this.deckNameSnapshot,
    required this.spreadId,
    required this.spreadNameSnapshot,
    required this.expectedPlacementCount,
    required this.readingAtUtcUs,
    required this.readingTimezoneOffsetMin,
    required this.createdAtUtcUs,
    required this.updatedAtUtcUs,
    required this.lifecycleStatus,
    this.finishedAtUtcUs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['reading_instance_id'] = Variable<String>(readingInstanceId);
    map['source_type'] = Variable<String>(sourceType);
    map['question_original_snapshot'] = Variable<String>(
      questionOriginalSnapshot,
    );
    map['question_display_text'] = Variable<String>(questionDisplayText);
    map['deck_id'] = Variable<String>(deckId);
    map['deck_name_snapshot'] = Variable<String>(deckNameSnapshot);
    map['spread_id'] = Variable<String>(spreadId);
    map['spread_name_snapshot'] = Variable<String>(spreadNameSnapshot);
    map['expected_placement_count'] = Variable<int>(expectedPlacementCount);
    map['reading_at_utc_us'] = Variable<int>(readingAtUtcUs);
    map['reading_timezone_offset_min'] = Variable<int>(
      readingTimezoneOffsetMin,
    );
    map['created_at_utc_us'] = Variable<int>(createdAtUtcUs);
    map['updated_at_utc_us'] = Variable<int>(updatedAtUtcUs);
    map['lifecycle_status'] = Variable<String>(lifecycleStatus);
    if (!nullToAbsent || finishedAtUtcUs != null) {
      map['finished_at_utc_us'] = Variable<int>(finishedAtUtcUs);
    }
    return map;
  }

  TarotReadingsCompanion toCompanion(bool nullToAbsent) {
    return TarotReadingsCompanion(
      readingInstanceId: Value(readingInstanceId),
      sourceType: Value(sourceType),
      questionOriginalSnapshot: Value(questionOriginalSnapshot),
      questionDisplayText: Value(questionDisplayText),
      deckId: Value(deckId),
      deckNameSnapshot: Value(deckNameSnapshot),
      spreadId: Value(spreadId),
      spreadNameSnapshot: Value(spreadNameSnapshot),
      expectedPlacementCount: Value(expectedPlacementCount),
      readingAtUtcUs: Value(readingAtUtcUs),
      readingTimezoneOffsetMin: Value(readingTimezoneOffsetMin),
      createdAtUtcUs: Value(createdAtUtcUs),
      updatedAtUtcUs: Value(updatedAtUtcUs),
      lifecycleStatus: Value(lifecycleStatus),
      finishedAtUtcUs: finishedAtUtcUs == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAtUtcUs),
    );
  }

  factory TarotReading.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TarotReading(
      readingInstanceId: serializer.fromJson<String>(json['readingInstanceId']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      questionOriginalSnapshot: serializer.fromJson<String>(
        json['questionOriginalSnapshot'],
      ),
      questionDisplayText: serializer.fromJson<String>(
        json['questionDisplayText'],
      ),
      deckId: serializer.fromJson<String>(json['deckId']),
      deckNameSnapshot: serializer.fromJson<String>(json['deckNameSnapshot']),
      spreadId: serializer.fromJson<String>(json['spreadId']),
      spreadNameSnapshot: serializer.fromJson<String>(
        json['spreadNameSnapshot'],
      ),
      expectedPlacementCount: serializer.fromJson<int>(
        json['expectedPlacementCount'],
      ),
      readingAtUtcUs: serializer.fromJson<int>(json['readingAtUtcUs']),
      readingTimezoneOffsetMin: serializer.fromJson<int>(
        json['readingTimezoneOffsetMin'],
      ),
      createdAtUtcUs: serializer.fromJson<int>(json['createdAtUtcUs']),
      updatedAtUtcUs: serializer.fromJson<int>(json['updatedAtUtcUs']),
      lifecycleStatus: serializer.fromJson<String>(json['lifecycleStatus']),
      finishedAtUtcUs: serializer.fromJson<int?>(json['finishedAtUtcUs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'readingInstanceId': serializer.toJson<String>(readingInstanceId),
      'sourceType': serializer.toJson<String>(sourceType),
      'questionOriginalSnapshot': serializer.toJson<String>(
        questionOriginalSnapshot,
      ),
      'questionDisplayText': serializer.toJson<String>(questionDisplayText),
      'deckId': serializer.toJson<String>(deckId),
      'deckNameSnapshot': serializer.toJson<String>(deckNameSnapshot),
      'spreadId': serializer.toJson<String>(spreadId),
      'spreadNameSnapshot': serializer.toJson<String>(spreadNameSnapshot),
      'expectedPlacementCount': serializer.toJson<int>(expectedPlacementCount),
      'readingAtUtcUs': serializer.toJson<int>(readingAtUtcUs),
      'readingTimezoneOffsetMin': serializer.toJson<int>(
        readingTimezoneOffsetMin,
      ),
      'createdAtUtcUs': serializer.toJson<int>(createdAtUtcUs),
      'updatedAtUtcUs': serializer.toJson<int>(updatedAtUtcUs),
      'lifecycleStatus': serializer.toJson<String>(lifecycleStatus),
      'finishedAtUtcUs': serializer.toJson<int?>(finishedAtUtcUs),
    };
  }

  TarotReading copyWith({
    String? readingInstanceId,
    String? sourceType,
    String? questionOriginalSnapshot,
    String? questionDisplayText,
    String? deckId,
    String? deckNameSnapshot,
    String? spreadId,
    String? spreadNameSnapshot,
    int? expectedPlacementCount,
    int? readingAtUtcUs,
    int? readingTimezoneOffsetMin,
    int? createdAtUtcUs,
    int? updatedAtUtcUs,
    String? lifecycleStatus,
    Value<int?> finishedAtUtcUs = const Value.absent(),
  }) => TarotReading(
    readingInstanceId: readingInstanceId ?? this.readingInstanceId,
    sourceType: sourceType ?? this.sourceType,
    questionOriginalSnapshot:
        questionOriginalSnapshot ?? this.questionOriginalSnapshot,
    questionDisplayText: questionDisplayText ?? this.questionDisplayText,
    deckId: deckId ?? this.deckId,
    deckNameSnapshot: deckNameSnapshot ?? this.deckNameSnapshot,
    spreadId: spreadId ?? this.spreadId,
    spreadNameSnapshot: spreadNameSnapshot ?? this.spreadNameSnapshot,
    expectedPlacementCount:
        expectedPlacementCount ?? this.expectedPlacementCount,
    readingAtUtcUs: readingAtUtcUs ?? this.readingAtUtcUs,
    readingTimezoneOffsetMin:
        readingTimezoneOffsetMin ?? this.readingTimezoneOffsetMin,
    createdAtUtcUs: createdAtUtcUs ?? this.createdAtUtcUs,
    updatedAtUtcUs: updatedAtUtcUs ?? this.updatedAtUtcUs,
    lifecycleStatus: lifecycleStatus ?? this.lifecycleStatus,
    finishedAtUtcUs: finishedAtUtcUs.present
        ? finishedAtUtcUs.value
        : this.finishedAtUtcUs,
  );
  TarotReading copyWithCompanion(TarotReadingsCompanion data) {
    return TarotReading(
      readingInstanceId: data.readingInstanceId.present
          ? data.readingInstanceId.value
          : this.readingInstanceId,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      questionOriginalSnapshot: data.questionOriginalSnapshot.present
          ? data.questionOriginalSnapshot.value
          : this.questionOriginalSnapshot,
      questionDisplayText: data.questionDisplayText.present
          ? data.questionDisplayText.value
          : this.questionDisplayText,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      deckNameSnapshot: data.deckNameSnapshot.present
          ? data.deckNameSnapshot.value
          : this.deckNameSnapshot,
      spreadId: data.spreadId.present ? data.spreadId.value : this.spreadId,
      spreadNameSnapshot: data.spreadNameSnapshot.present
          ? data.spreadNameSnapshot.value
          : this.spreadNameSnapshot,
      expectedPlacementCount: data.expectedPlacementCount.present
          ? data.expectedPlacementCount.value
          : this.expectedPlacementCount,
      readingAtUtcUs: data.readingAtUtcUs.present
          ? data.readingAtUtcUs.value
          : this.readingAtUtcUs,
      readingTimezoneOffsetMin: data.readingTimezoneOffsetMin.present
          ? data.readingTimezoneOffsetMin.value
          : this.readingTimezoneOffsetMin,
      createdAtUtcUs: data.createdAtUtcUs.present
          ? data.createdAtUtcUs.value
          : this.createdAtUtcUs,
      updatedAtUtcUs: data.updatedAtUtcUs.present
          ? data.updatedAtUtcUs.value
          : this.updatedAtUtcUs,
      lifecycleStatus: data.lifecycleStatus.present
          ? data.lifecycleStatus.value
          : this.lifecycleStatus,
      finishedAtUtcUs: data.finishedAtUtcUs.present
          ? data.finishedAtUtcUs.value
          : this.finishedAtUtcUs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TarotReading(')
          ..write('readingInstanceId: $readingInstanceId, ')
          ..write('sourceType: $sourceType, ')
          ..write('questionOriginalSnapshot: $questionOriginalSnapshot, ')
          ..write('questionDisplayText: $questionDisplayText, ')
          ..write('deckId: $deckId, ')
          ..write('deckNameSnapshot: $deckNameSnapshot, ')
          ..write('spreadId: $spreadId, ')
          ..write('spreadNameSnapshot: $spreadNameSnapshot, ')
          ..write('expectedPlacementCount: $expectedPlacementCount, ')
          ..write('readingAtUtcUs: $readingAtUtcUs, ')
          ..write('readingTimezoneOffsetMin: $readingTimezoneOffsetMin, ')
          ..write('createdAtUtcUs: $createdAtUtcUs, ')
          ..write('updatedAtUtcUs: $updatedAtUtcUs, ')
          ..write('lifecycleStatus: $lifecycleStatus, ')
          ..write('finishedAtUtcUs: $finishedAtUtcUs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    readingInstanceId,
    sourceType,
    questionOriginalSnapshot,
    questionDisplayText,
    deckId,
    deckNameSnapshot,
    spreadId,
    spreadNameSnapshot,
    expectedPlacementCount,
    readingAtUtcUs,
    readingTimezoneOffsetMin,
    createdAtUtcUs,
    updatedAtUtcUs,
    lifecycleStatus,
    finishedAtUtcUs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TarotReading &&
          other.readingInstanceId == this.readingInstanceId &&
          other.sourceType == this.sourceType &&
          other.questionOriginalSnapshot == this.questionOriginalSnapshot &&
          other.questionDisplayText == this.questionDisplayText &&
          other.deckId == this.deckId &&
          other.deckNameSnapshot == this.deckNameSnapshot &&
          other.spreadId == this.spreadId &&
          other.spreadNameSnapshot == this.spreadNameSnapshot &&
          other.expectedPlacementCount == this.expectedPlacementCount &&
          other.readingAtUtcUs == this.readingAtUtcUs &&
          other.readingTimezoneOffsetMin == this.readingTimezoneOffsetMin &&
          other.createdAtUtcUs == this.createdAtUtcUs &&
          other.updatedAtUtcUs == this.updatedAtUtcUs &&
          other.lifecycleStatus == this.lifecycleStatus &&
          other.finishedAtUtcUs == this.finishedAtUtcUs);
}

class TarotReadingsCompanion extends UpdateCompanion<TarotReading> {
  final Value<String> readingInstanceId;
  final Value<String> sourceType;
  final Value<String> questionOriginalSnapshot;
  final Value<String> questionDisplayText;
  final Value<String> deckId;
  final Value<String> deckNameSnapshot;
  final Value<String> spreadId;
  final Value<String> spreadNameSnapshot;
  final Value<int> expectedPlacementCount;
  final Value<int> readingAtUtcUs;
  final Value<int> readingTimezoneOffsetMin;
  final Value<int> createdAtUtcUs;
  final Value<int> updatedAtUtcUs;
  final Value<String> lifecycleStatus;
  final Value<int?> finishedAtUtcUs;
  final Value<int> rowid;
  const TarotReadingsCompanion({
    this.readingInstanceId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.questionOriginalSnapshot = const Value.absent(),
    this.questionDisplayText = const Value.absent(),
    this.deckId = const Value.absent(),
    this.deckNameSnapshot = const Value.absent(),
    this.spreadId = const Value.absent(),
    this.spreadNameSnapshot = const Value.absent(),
    this.expectedPlacementCount = const Value.absent(),
    this.readingAtUtcUs = const Value.absent(),
    this.readingTimezoneOffsetMin = const Value.absent(),
    this.createdAtUtcUs = const Value.absent(),
    this.updatedAtUtcUs = const Value.absent(),
    this.lifecycleStatus = const Value.absent(),
    this.finishedAtUtcUs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TarotReadingsCompanion.insert({
    required String readingInstanceId,
    required String sourceType,
    required String questionOriginalSnapshot,
    required String questionDisplayText,
    required String deckId,
    required String deckNameSnapshot,
    required String spreadId,
    required String spreadNameSnapshot,
    required int expectedPlacementCount,
    required int readingAtUtcUs,
    required int readingTimezoneOffsetMin,
    required int createdAtUtcUs,
    required int updatedAtUtcUs,
    required String lifecycleStatus,
    this.finishedAtUtcUs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : readingInstanceId = Value(readingInstanceId),
       sourceType = Value(sourceType),
       questionOriginalSnapshot = Value(questionOriginalSnapshot),
       questionDisplayText = Value(questionDisplayText),
       deckId = Value(deckId),
       deckNameSnapshot = Value(deckNameSnapshot),
       spreadId = Value(spreadId),
       spreadNameSnapshot = Value(spreadNameSnapshot),
       expectedPlacementCount = Value(expectedPlacementCount),
       readingAtUtcUs = Value(readingAtUtcUs),
       readingTimezoneOffsetMin = Value(readingTimezoneOffsetMin),
       createdAtUtcUs = Value(createdAtUtcUs),
       updatedAtUtcUs = Value(updatedAtUtcUs),
       lifecycleStatus = Value(lifecycleStatus);
  static Insertable<TarotReading> custom({
    Expression<String>? readingInstanceId,
    Expression<String>? sourceType,
    Expression<String>? questionOriginalSnapshot,
    Expression<String>? questionDisplayText,
    Expression<String>? deckId,
    Expression<String>? deckNameSnapshot,
    Expression<String>? spreadId,
    Expression<String>? spreadNameSnapshot,
    Expression<int>? expectedPlacementCount,
    Expression<int>? readingAtUtcUs,
    Expression<int>? readingTimezoneOffsetMin,
    Expression<int>? createdAtUtcUs,
    Expression<int>? updatedAtUtcUs,
    Expression<String>? lifecycleStatus,
    Expression<int>? finishedAtUtcUs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (readingInstanceId != null) 'reading_instance_id': readingInstanceId,
      if (sourceType != null) 'source_type': sourceType,
      if (questionOriginalSnapshot != null)
        'question_original_snapshot': questionOriginalSnapshot,
      if (questionDisplayText != null)
        'question_display_text': questionDisplayText,
      if (deckId != null) 'deck_id': deckId,
      if (deckNameSnapshot != null) 'deck_name_snapshot': deckNameSnapshot,
      if (spreadId != null) 'spread_id': spreadId,
      if (spreadNameSnapshot != null)
        'spread_name_snapshot': spreadNameSnapshot,
      if (expectedPlacementCount != null)
        'expected_placement_count': expectedPlacementCount,
      if (readingAtUtcUs != null) 'reading_at_utc_us': readingAtUtcUs,
      if (readingTimezoneOffsetMin != null)
        'reading_timezone_offset_min': readingTimezoneOffsetMin,
      if (createdAtUtcUs != null) 'created_at_utc_us': createdAtUtcUs,
      if (updatedAtUtcUs != null) 'updated_at_utc_us': updatedAtUtcUs,
      if (lifecycleStatus != null) 'lifecycle_status': lifecycleStatus,
      if (finishedAtUtcUs != null) 'finished_at_utc_us': finishedAtUtcUs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TarotReadingsCompanion copyWith({
    Value<String>? readingInstanceId,
    Value<String>? sourceType,
    Value<String>? questionOriginalSnapshot,
    Value<String>? questionDisplayText,
    Value<String>? deckId,
    Value<String>? deckNameSnapshot,
    Value<String>? spreadId,
    Value<String>? spreadNameSnapshot,
    Value<int>? expectedPlacementCount,
    Value<int>? readingAtUtcUs,
    Value<int>? readingTimezoneOffsetMin,
    Value<int>? createdAtUtcUs,
    Value<int>? updatedAtUtcUs,
    Value<String>? lifecycleStatus,
    Value<int?>? finishedAtUtcUs,
    Value<int>? rowid,
  }) {
    return TarotReadingsCompanion(
      readingInstanceId: readingInstanceId ?? this.readingInstanceId,
      sourceType: sourceType ?? this.sourceType,
      questionOriginalSnapshot:
          questionOriginalSnapshot ?? this.questionOriginalSnapshot,
      questionDisplayText: questionDisplayText ?? this.questionDisplayText,
      deckId: deckId ?? this.deckId,
      deckNameSnapshot: deckNameSnapshot ?? this.deckNameSnapshot,
      spreadId: spreadId ?? this.spreadId,
      spreadNameSnapshot: spreadNameSnapshot ?? this.spreadNameSnapshot,
      expectedPlacementCount:
          expectedPlacementCount ?? this.expectedPlacementCount,
      readingAtUtcUs: readingAtUtcUs ?? this.readingAtUtcUs,
      readingTimezoneOffsetMin:
          readingTimezoneOffsetMin ?? this.readingTimezoneOffsetMin,
      createdAtUtcUs: createdAtUtcUs ?? this.createdAtUtcUs,
      updatedAtUtcUs: updatedAtUtcUs ?? this.updatedAtUtcUs,
      lifecycleStatus: lifecycleStatus ?? this.lifecycleStatus,
      finishedAtUtcUs: finishedAtUtcUs ?? this.finishedAtUtcUs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (readingInstanceId.present) {
      map['reading_instance_id'] = Variable<String>(readingInstanceId.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (questionOriginalSnapshot.present) {
      map['question_original_snapshot'] = Variable<String>(
        questionOriginalSnapshot.value,
      );
    }
    if (questionDisplayText.present) {
      map['question_display_text'] = Variable<String>(
        questionDisplayText.value,
      );
    }
    if (deckId.present) {
      map['deck_id'] = Variable<String>(deckId.value);
    }
    if (deckNameSnapshot.present) {
      map['deck_name_snapshot'] = Variable<String>(deckNameSnapshot.value);
    }
    if (spreadId.present) {
      map['spread_id'] = Variable<String>(spreadId.value);
    }
    if (spreadNameSnapshot.present) {
      map['spread_name_snapshot'] = Variable<String>(spreadNameSnapshot.value);
    }
    if (expectedPlacementCount.present) {
      map['expected_placement_count'] = Variable<int>(
        expectedPlacementCount.value,
      );
    }
    if (readingAtUtcUs.present) {
      map['reading_at_utc_us'] = Variable<int>(readingAtUtcUs.value);
    }
    if (readingTimezoneOffsetMin.present) {
      map['reading_timezone_offset_min'] = Variable<int>(
        readingTimezoneOffsetMin.value,
      );
    }
    if (createdAtUtcUs.present) {
      map['created_at_utc_us'] = Variable<int>(createdAtUtcUs.value);
    }
    if (updatedAtUtcUs.present) {
      map['updated_at_utc_us'] = Variable<int>(updatedAtUtcUs.value);
    }
    if (lifecycleStatus.present) {
      map['lifecycle_status'] = Variable<String>(lifecycleStatus.value);
    }
    if (finishedAtUtcUs.present) {
      map['finished_at_utc_us'] = Variable<int>(finishedAtUtcUs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TarotReadingsCompanion(')
          ..write('readingInstanceId: $readingInstanceId, ')
          ..write('sourceType: $sourceType, ')
          ..write('questionOriginalSnapshot: $questionOriginalSnapshot, ')
          ..write('questionDisplayText: $questionDisplayText, ')
          ..write('deckId: $deckId, ')
          ..write('deckNameSnapshot: $deckNameSnapshot, ')
          ..write('spreadId: $spreadId, ')
          ..write('spreadNameSnapshot: $spreadNameSnapshot, ')
          ..write('expectedPlacementCount: $expectedPlacementCount, ')
          ..write('readingAtUtcUs: $readingAtUtcUs, ')
          ..write('readingTimezoneOffsetMin: $readingTimezoneOffsetMin, ')
          ..write('createdAtUtcUs: $createdAtUtcUs, ')
          ..write('updatedAtUtcUs: $updatedAtUtcUs, ')
          ..write('lifecycleStatus: $lifecycleStatus, ')
          ..write('finishedAtUtcUs: $finishedAtUtcUs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TarotCardPlacementsTable extends TarotCardPlacements
    with TableInfo<$TarotCardPlacementsTable, TarotCardPlacement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TarotCardPlacementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _readingInstanceIdMeta = const VerificationMeta(
    'readingInstanceId',
  );
  @override
  late final GeneratedColumn<String> readingInstanceId =
      GeneratedColumn<String>(
        'reading_instance_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tarot_readings (reading_instance_id) ON DELETE RESTRICT',
        ),
      );
  static const VerificationMeta _placementOrderMeta = const VerificationMeta(
    'placementOrder',
  );
  @override
  late final GeneratedColumn<int> placementOrder = GeneratedColumn<int>(
    'placement_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionIdMeta = const VerificationMeta(
    'positionId',
  );
  @override
  late final GeneratedColumn<String> positionId = GeneratedColumn<String>(
    'position_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionNameSnapshotMeta =
      const VerificationMeta('positionNameSnapshot');
  @override
  late final GeneratedColumn<String> positionNameSnapshot =
      GeneratedColumn<String>(
        'position_name_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardNameSnapshotMeta = const VerificationMeta(
    'cardNameSnapshot',
  );
  @override
  late final GeneratedColumn<String> cardNameSnapshot = GeneratedColumn<String>(
    'card_name_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orientationMeta = const VerificationMeta(
    'orientation',
  );
  @override
  late final GeneratedColumn<String> orientation = GeneratedColumn<String>(
    'orientation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    readingInstanceId,
    placementOrder,
    positionId,
    positionNameSnapshot,
    cardId,
    cardNameSnapshot,
    orientation,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tarot_card_placements';
  @override
  VerificationContext validateIntegrity(
    Insertable<TarotCardPlacement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('reading_instance_id')) {
      context.handle(
        _readingInstanceIdMeta,
        readingInstanceId.isAcceptableOrUnknown(
          data['reading_instance_id']!,
          _readingInstanceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_readingInstanceIdMeta);
    }
    if (data.containsKey('placement_order')) {
      context.handle(
        _placementOrderMeta,
        placementOrder.isAcceptableOrUnknown(
          data['placement_order']!,
          _placementOrderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_placementOrderMeta);
    }
    if (data.containsKey('position_id')) {
      context.handle(
        _positionIdMeta,
        positionId.isAcceptableOrUnknown(data['position_id']!, _positionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_positionIdMeta);
    }
    if (data.containsKey('position_name_snapshot')) {
      context.handle(
        _positionNameSnapshotMeta,
        positionNameSnapshot.isAcceptableOrUnknown(
          data['position_name_snapshot']!,
          _positionNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_positionNameSnapshotMeta);
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('card_name_snapshot')) {
      context.handle(
        _cardNameSnapshotMeta,
        cardNameSnapshot.isAcceptableOrUnknown(
          data['card_name_snapshot']!,
          _cardNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cardNameSnapshotMeta);
    }
    if (data.containsKey('orientation')) {
      context.handle(
        _orientationMeta,
        orientation.isAcceptableOrUnknown(
          data['orientation']!,
          _orientationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_orientationMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {readingInstanceId, placementOrder};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {readingInstanceId, positionId},
  ];
  @override
  TarotCardPlacement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TarotCardPlacement(
      readingInstanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reading_instance_id'],
      )!,
      placementOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}placement_order'],
      )!,
      positionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}position_id'],
      )!,
      positionNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}position_name_snapshot'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      cardNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_name_snapshot'],
      )!,
      orientation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}orientation'],
      )!,
    );
  }

  @override
  $TarotCardPlacementsTable createAlias(String alias) {
    return $TarotCardPlacementsTable(attachedDatabase, alias);
  }
}

class TarotCardPlacement extends DataClass
    implements Insertable<TarotCardPlacement> {
  final String readingInstanceId;
  final int placementOrder;
  final String positionId;
  final String positionNameSnapshot;
  final String cardId;
  final String cardNameSnapshot;
  final String orientation;
  const TarotCardPlacement({
    required this.readingInstanceId,
    required this.placementOrder,
    required this.positionId,
    required this.positionNameSnapshot,
    required this.cardId,
    required this.cardNameSnapshot,
    required this.orientation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['reading_instance_id'] = Variable<String>(readingInstanceId);
    map['placement_order'] = Variable<int>(placementOrder);
    map['position_id'] = Variable<String>(positionId);
    map['position_name_snapshot'] = Variable<String>(positionNameSnapshot);
    map['card_id'] = Variable<String>(cardId);
    map['card_name_snapshot'] = Variable<String>(cardNameSnapshot);
    map['orientation'] = Variable<String>(orientation);
    return map;
  }

  TarotCardPlacementsCompanion toCompanion(bool nullToAbsent) {
    return TarotCardPlacementsCompanion(
      readingInstanceId: Value(readingInstanceId),
      placementOrder: Value(placementOrder),
      positionId: Value(positionId),
      positionNameSnapshot: Value(positionNameSnapshot),
      cardId: Value(cardId),
      cardNameSnapshot: Value(cardNameSnapshot),
      orientation: Value(orientation),
    );
  }

  factory TarotCardPlacement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TarotCardPlacement(
      readingInstanceId: serializer.fromJson<String>(json['readingInstanceId']),
      placementOrder: serializer.fromJson<int>(json['placementOrder']),
      positionId: serializer.fromJson<String>(json['positionId']),
      positionNameSnapshot: serializer.fromJson<String>(
        json['positionNameSnapshot'],
      ),
      cardId: serializer.fromJson<String>(json['cardId']),
      cardNameSnapshot: serializer.fromJson<String>(json['cardNameSnapshot']),
      orientation: serializer.fromJson<String>(json['orientation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'readingInstanceId': serializer.toJson<String>(readingInstanceId),
      'placementOrder': serializer.toJson<int>(placementOrder),
      'positionId': serializer.toJson<String>(positionId),
      'positionNameSnapshot': serializer.toJson<String>(positionNameSnapshot),
      'cardId': serializer.toJson<String>(cardId),
      'cardNameSnapshot': serializer.toJson<String>(cardNameSnapshot),
      'orientation': serializer.toJson<String>(orientation),
    };
  }

  TarotCardPlacement copyWith({
    String? readingInstanceId,
    int? placementOrder,
    String? positionId,
    String? positionNameSnapshot,
    String? cardId,
    String? cardNameSnapshot,
    String? orientation,
  }) => TarotCardPlacement(
    readingInstanceId: readingInstanceId ?? this.readingInstanceId,
    placementOrder: placementOrder ?? this.placementOrder,
    positionId: positionId ?? this.positionId,
    positionNameSnapshot: positionNameSnapshot ?? this.positionNameSnapshot,
    cardId: cardId ?? this.cardId,
    cardNameSnapshot: cardNameSnapshot ?? this.cardNameSnapshot,
    orientation: orientation ?? this.orientation,
  );
  TarotCardPlacement copyWithCompanion(TarotCardPlacementsCompanion data) {
    return TarotCardPlacement(
      readingInstanceId: data.readingInstanceId.present
          ? data.readingInstanceId.value
          : this.readingInstanceId,
      placementOrder: data.placementOrder.present
          ? data.placementOrder.value
          : this.placementOrder,
      positionId: data.positionId.present
          ? data.positionId.value
          : this.positionId,
      positionNameSnapshot: data.positionNameSnapshot.present
          ? data.positionNameSnapshot.value
          : this.positionNameSnapshot,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      cardNameSnapshot: data.cardNameSnapshot.present
          ? data.cardNameSnapshot.value
          : this.cardNameSnapshot,
      orientation: data.orientation.present
          ? data.orientation.value
          : this.orientation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TarotCardPlacement(')
          ..write('readingInstanceId: $readingInstanceId, ')
          ..write('placementOrder: $placementOrder, ')
          ..write('positionId: $positionId, ')
          ..write('positionNameSnapshot: $positionNameSnapshot, ')
          ..write('cardId: $cardId, ')
          ..write('cardNameSnapshot: $cardNameSnapshot, ')
          ..write('orientation: $orientation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    readingInstanceId,
    placementOrder,
    positionId,
    positionNameSnapshot,
    cardId,
    cardNameSnapshot,
    orientation,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TarotCardPlacement &&
          other.readingInstanceId == this.readingInstanceId &&
          other.placementOrder == this.placementOrder &&
          other.positionId == this.positionId &&
          other.positionNameSnapshot == this.positionNameSnapshot &&
          other.cardId == this.cardId &&
          other.cardNameSnapshot == this.cardNameSnapshot &&
          other.orientation == this.orientation);
}

class TarotCardPlacementsCompanion extends UpdateCompanion<TarotCardPlacement> {
  final Value<String> readingInstanceId;
  final Value<int> placementOrder;
  final Value<String> positionId;
  final Value<String> positionNameSnapshot;
  final Value<String> cardId;
  final Value<String> cardNameSnapshot;
  final Value<String> orientation;
  final Value<int> rowid;
  const TarotCardPlacementsCompanion({
    this.readingInstanceId = const Value.absent(),
    this.placementOrder = const Value.absent(),
    this.positionId = const Value.absent(),
    this.positionNameSnapshot = const Value.absent(),
    this.cardId = const Value.absent(),
    this.cardNameSnapshot = const Value.absent(),
    this.orientation = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TarotCardPlacementsCompanion.insert({
    required String readingInstanceId,
    required int placementOrder,
    required String positionId,
    required String positionNameSnapshot,
    required String cardId,
    required String cardNameSnapshot,
    required String orientation,
    this.rowid = const Value.absent(),
  }) : readingInstanceId = Value(readingInstanceId),
       placementOrder = Value(placementOrder),
       positionId = Value(positionId),
       positionNameSnapshot = Value(positionNameSnapshot),
       cardId = Value(cardId),
       cardNameSnapshot = Value(cardNameSnapshot),
       orientation = Value(orientation);
  static Insertable<TarotCardPlacement> custom({
    Expression<String>? readingInstanceId,
    Expression<int>? placementOrder,
    Expression<String>? positionId,
    Expression<String>? positionNameSnapshot,
    Expression<String>? cardId,
    Expression<String>? cardNameSnapshot,
    Expression<String>? orientation,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (readingInstanceId != null) 'reading_instance_id': readingInstanceId,
      if (placementOrder != null) 'placement_order': placementOrder,
      if (positionId != null) 'position_id': positionId,
      if (positionNameSnapshot != null)
        'position_name_snapshot': positionNameSnapshot,
      if (cardId != null) 'card_id': cardId,
      if (cardNameSnapshot != null) 'card_name_snapshot': cardNameSnapshot,
      if (orientation != null) 'orientation': orientation,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TarotCardPlacementsCompanion copyWith({
    Value<String>? readingInstanceId,
    Value<int>? placementOrder,
    Value<String>? positionId,
    Value<String>? positionNameSnapshot,
    Value<String>? cardId,
    Value<String>? cardNameSnapshot,
    Value<String>? orientation,
    Value<int>? rowid,
  }) {
    return TarotCardPlacementsCompanion(
      readingInstanceId: readingInstanceId ?? this.readingInstanceId,
      placementOrder: placementOrder ?? this.placementOrder,
      positionId: positionId ?? this.positionId,
      positionNameSnapshot: positionNameSnapshot ?? this.positionNameSnapshot,
      cardId: cardId ?? this.cardId,
      cardNameSnapshot: cardNameSnapshot ?? this.cardNameSnapshot,
      orientation: orientation ?? this.orientation,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (readingInstanceId.present) {
      map['reading_instance_id'] = Variable<String>(readingInstanceId.value);
    }
    if (placementOrder.present) {
      map['placement_order'] = Variable<int>(placementOrder.value);
    }
    if (positionId.present) {
      map['position_id'] = Variable<String>(positionId.value);
    }
    if (positionNameSnapshot.present) {
      map['position_name_snapshot'] = Variable<String>(
        positionNameSnapshot.value,
      );
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (cardNameSnapshot.present) {
      map['card_name_snapshot'] = Variable<String>(cardNameSnapshot.value);
    }
    if (orientation.present) {
      map['orientation'] = Variable<String>(orientation.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TarotCardPlacementsCompanion(')
          ..write('readingInstanceId: $readingInstanceId, ')
          ..write('placementOrder: $placementOrder, ')
          ..write('positionId: $positionId, ')
          ..write('positionNameSnapshot: $positionNameSnapshot, ')
          ..write('cardId: $cardId, ')
          ..write('cardNameSnapshot: $cardNameSnapshot, ')
          ..write('orientation: $orientation, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TarotInterpretationsTable extends TarotInterpretations
    with TableInfo<$TarotInterpretationsTable, TarotInterpretation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TarotInterpretationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _readingInstanceIdMeta = const VerificationMeta(
    'readingInstanceId',
  );
  @override
  late final GeneratedColumn<String> readingInstanceId =
      GeneratedColumn<String>(
        'reading_instance_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tarot_readings (reading_instance_id) ON DELETE RESTRICT',
        ),
      );
  static const VerificationMeta _wholeImageObservationMeta =
      const VerificationMeta('wholeImageObservation');
  @override
  late final GeneratedColumn<String> wholeImageObservation =
      GeneratedColumn<String>(
        'whole_image_observation',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _flowInterpretationMeta =
      const VerificationMeta('flowInterpretation');
  @override
  late final GeneratedColumn<String> flowInterpretation =
      GeneratedColumn<String>(
        'flow_interpretation',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _coreMessageMeta = const VerificationMeta(
    'coreMessage',
  );
  @override
  late final GeneratedColumn<String> coreMessage = GeneratedColumn<String>(
    'core_message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _smallActionMeta = const VerificationMeta(
    'smallAction',
  );
  @override
  late final GeneratedColumn<String> smallAction = GeneratedColumn<String>(
    'small_action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtUtcUsMeta = const VerificationMeta(
    'createdAtUtcUs',
  );
  @override
  late final GeneratedColumn<int> createdAtUtcUs = GeneratedColumn<int>(
    'created_at_utc_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcUsMeta = const VerificationMeta(
    'updatedAtUtcUs',
  );
  @override
  late final GeneratedColumn<int> updatedAtUtcUs = GeneratedColumn<int>(
    'updated_at_utc_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    readingInstanceId,
    wholeImageObservation,
    flowInterpretation,
    coreMessage,
    smallAction,
    createdAtUtcUs,
    updatedAtUtcUs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tarot_interpretations';
  @override
  VerificationContext validateIntegrity(
    Insertable<TarotInterpretation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('reading_instance_id')) {
      context.handle(
        _readingInstanceIdMeta,
        readingInstanceId.isAcceptableOrUnknown(
          data['reading_instance_id']!,
          _readingInstanceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_readingInstanceIdMeta);
    }
    if (data.containsKey('whole_image_observation')) {
      context.handle(
        _wholeImageObservationMeta,
        wholeImageObservation.isAcceptableOrUnknown(
          data['whole_image_observation']!,
          _wholeImageObservationMeta,
        ),
      );
    }
    if (data.containsKey('flow_interpretation')) {
      context.handle(
        _flowInterpretationMeta,
        flowInterpretation.isAcceptableOrUnknown(
          data['flow_interpretation']!,
          _flowInterpretationMeta,
        ),
      );
    }
    if (data.containsKey('core_message')) {
      context.handle(
        _coreMessageMeta,
        coreMessage.isAcceptableOrUnknown(
          data['core_message']!,
          _coreMessageMeta,
        ),
      );
    }
    if (data.containsKey('small_action')) {
      context.handle(
        _smallActionMeta,
        smallAction.isAcceptableOrUnknown(
          data['small_action']!,
          _smallActionMeta,
        ),
      );
    }
    if (data.containsKey('created_at_utc_us')) {
      context.handle(
        _createdAtUtcUsMeta,
        createdAtUtcUs.isAcceptableOrUnknown(
          data['created_at_utc_us']!,
          _createdAtUtcUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcUsMeta);
    }
    if (data.containsKey('updated_at_utc_us')) {
      context.handle(
        _updatedAtUtcUsMeta,
        updatedAtUtcUs.isAcceptableOrUnknown(
          data['updated_at_utc_us']!,
          _updatedAtUtcUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcUsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {readingInstanceId};
  @override
  TarotInterpretation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TarotInterpretation(
      readingInstanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reading_instance_id'],
      )!,
      wholeImageObservation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}whole_image_observation'],
      )!,
      flowInterpretation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flow_interpretation'],
      )!,
      coreMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}core_message'],
      )!,
      smallAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}small_action'],
      )!,
      createdAtUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_us'],
      )!,
      updatedAtUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc_us'],
      )!,
    );
  }

  @override
  $TarotInterpretationsTable createAlias(String alias) {
    return $TarotInterpretationsTable(attachedDatabase, alias);
  }
}

class TarotInterpretation extends DataClass
    implements Insertable<TarotInterpretation> {
  final String readingInstanceId;
  final String wholeImageObservation;
  final String flowInterpretation;
  final String coreMessage;
  final String smallAction;
  final int createdAtUtcUs;
  final int updatedAtUtcUs;
  const TarotInterpretation({
    required this.readingInstanceId,
    required this.wholeImageObservation,
    required this.flowInterpretation,
    required this.coreMessage,
    required this.smallAction,
    required this.createdAtUtcUs,
    required this.updatedAtUtcUs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['reading_instance_id'] = Variable<String>(readingInstanceId);
    map['whole_image_observation'] = Variable<String>(wholeImageObservation);
    map['flow_interpretation'] = Variable<String>(flowInterpretation);
    map['core_message'] = Variable<String>(coreMessage);
    map['small_action'] = Variable<String>(smallAction);
    map['created_at_utc_us'] = Variable<int>(createdAtUtcUs);
    map['updated_at_utc_us'] = Variable<int>(updatedAtUtcUs);
    return map;
  }

  TarotInterpretationsCompanion toCompanion(bool nullToAbsent) {
    return TarotInterpretationsCompanion(
      readingInstanceId: Value(readingInstanceId),
      wholeImageObservation: Value(wholeImageObservation),
      flowInterpretation: Value(flowInterpretation),
      coreMessage: Value(coreMessage),
      smallAction: Value(smallAction),
      createdAtUtcUs: Value(createdAtUtcUs),
      updatedAtUtcUs: Value(updatedAtUtcUs),
    );
  }

  factory TarotInterpretation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TarotInterpretation(
      readingInstanceId: serializer.fromJson<String>(json['readingInstanceId']),
      wholeImageObservation: serializer.fromJson<String>(
        json['wholeImageObservation'],
      ),
      flowInterpretation: serializer.fromJson<String>(
        json['flowInterpretation'],
      ),
      coreMessage: serializer.fromJson<String>(json['coreMessage']),
      smallAction: serializer.fromJson<String>(json['smallAction']),
      createdAtUtcUs: serializer.fromJson<int>(json['createdAtUtcUs']),
      updatedAtUtcUs: serializer.fromJson<int>(json['updatedAtUtcUs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'readingInstanceId': serializer.toJson<String>(readingInstanceId),
      'wholeImageObservation': serializer.toJson<String>(wholeImageObservation),
      'flowInterpretation': serializer.toJson<String>(flowInterpretation),
      'coreMessage': serializer.toJson<String>(coreMessage),
      'smallAction': serializer.toJson<String>(smallAction),
      'createdAtUtcUs': serializer.toJson<int>(createdAtUtcUs),
      'updatedAtUtcUs': serializer.toJson<int>(updatedAtUtcUs),
    };
  }

  TarotInterpretation copyWith({
    String? readingInstanceId,
    String? wholeImageObservation,
    String? flowInterpretation,
    String? coreMessage,
    String? smallAction,
    int? createdAtUtcUs,
    int? updatedAtUtcUs,
  }) => TarotInterpretation(
    readingInstanceId: readingInstanceId ?? this.readingInstanceId,
    wholeImageObservation: wholeImageObservation ?? this.wholeImageObservation,
    flowInterpretation: flowInterpretation ?? this.flowInterpretation,
    coreMessage: coreMessage ?? this.coreMessage,
    smallAction: smallAction ?? this.smallAction,
    createdAtUtcUs: createdAtUtcUs ?? this.createdAtUtcUs,
    updatedAtUtcUs: updatedAtUtcUs ?? this.updatedAtUtcUs,
  );
  TarotInterpretation copyWithCompanion(TarotInterpretationsCompanion data) {
    return TarotInterpretation(
      readingInstanceId: data.readingInstanceId.present
          ? data.readingInstanceId.value
          : this.readingInstanceId,
      wholeImageObservation: data.wholeImageObservation.present
          ? data.wholeImageObservation.value
          : this.wholeImageObservation,
      flowInterpretation: data.flowInterpretation.present
          ? data.flowInterpretation.value
          : this.flowInterpretation,
      coreMessage: data.coreMessage.present
          ? data.coreMessage.value
          : this.coreMessage,
      smallAction: data.smallAction.present
          ? data.smallAction.value
          : this.smallAction,
      createdAtUtcUs: data.createdAtUtcUs.present
          ? data.createdAtUtcUs.value
          : this.createdAtUtcUs,
      updatedAtUtcUs: data.updatedAtUtcUs.present
          ? data.updatedAtUtcUs.value
          : this.updatedAtUtcUs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TarotInterpretation(')
          ..write('readingInstanceId: $readingInstanceId, ')
          ..write('wholeImageObservation: $wholeImageObservation, ')
          ..write('flowInterpretation: $flowInterpretation, ')
          ..write('coreMessage: $coreMessage, ')
          ..write('smallAction: $smallAction, ')
          ..write('createdAtUtcUs: $createdAtUtcUs, ')
          ..write('updatedAtUtcUs: $updatedAtUtcUs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    readingInstanceId,
    wholeImageObservation,
    flowInterpretation,
    coreMessage,
    smallAction,
    createdAtUtcUs,
    updatedAtUtcUs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TarotInterpretation &&
          other.readingInstanceId == this.readingInstanceId &&
          other.wholeImageObservation == this.wholeImageObservation &&
          other.flowInterpretation == this.flowInterpretation &&
          other.coreMessage == this.coreMessage &&
          other.smallAction == this.smallAction &&
          other.createdAtUtcUs == this.createdAtUtcUs &&
          other.updatedAtUtcUs == this.updatedAtUtcUs);
}

class TarotInterpretationsCompanion
    extends UpdateCompanion<TarotInterpretation> {
  final Value<String> readingInstanceId;
  final Value<String> wholeImageObservation;
  final Value<String> flowInterpretation;
  final Value<String> coreMessage;
  final Value<String> smallAction;
  final Value<int> createdAtUtcUs;
  final Value<int> updatedAtUtcUs;
  final Value<int> rowid;
  const TarotInterpretationsCompanion({
    this.readingInstanceId = const Value.absent(),
    this.wholeImageObservation = const Value.absent(),
    this.flowInterpretation = const Value.absent(),
    this.coreMessage = const Value.absent(),
    this.smallAction = const Value.absent(),
    this.createdAtUtcUs = const Value.absent(),
    this.updatedAtUtcUs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TarotInterpretationsCompanion.insert({
    required String readingInstanceId,
    this.wholeImageObservation = const Value.absent(),
    this.flowInterpretation = const Value.absent(),
    this.coreMessage = const Value.absent(),
    this.smallAction = const Value.absent(),
    required int createdAtUtcUs,
    required int updatedAtUtcUs,
    this.rowid = const Value.absent(),
  }) : readingInstanceId = Value(readingInstanceId),
       createdAtUtcUs = Value(createdAtUtcUs),
       updatedAtUtcUs = Value(updatedAtUtcUs);
  static Insertable<TarotInterpretation> custom({
    Expression<String>? readingInstanceId,
    Expression<String>? wholeImageObservation,
    Expression<String>? flowInterpretation,
    Expression<String>? coreMessage,
    Expression<String>? smallAction,
    Expression<int>? createdAtUtcUs,
    Expression<int>? updatedAtUtcUs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (readingInstanceId != null) 'reading_instance_id': readingInstanceId,
      if (wholeImageObservation != null)
        'whole_image_observation': wholeImageObservation,
      if (flowInterpretation != null) 'flow_interpretation': flowInterpretation,
      if (coreMessage != null) 'core_message': coreMessage,
      if (smallAction != null) 'small_action': smallAction,
      if (createdAtUtcUs != null) 'created_at_utc_us': createdAtUtcUs,
      if (updatedAtUtcUs != null) 'updated_at_utc_us': updatedAtUtcUs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TarotInterpretationsCompanion copyWith({
    Value<String>? readingInstanceId,
    Value<String>? wholeImageObservation,
    Value<String>? flowInterpretation,
    Value<String>? coreMessage,
    Value<String>? smallAction,
    Value<int>? createdAtUtcUs,
    Value<int>? updatedAtUtcUs,
    Value<int>? rowid,
  }) {
    return TarotInterpretationsCompanion(
      readingInstanceId: readingInstanceId ?? this.readingInstanceId,
      wholeImageObservation:
          wholeImageObservation ?? this.wholeImageObservation,
      flowInterpretation: flowInterpretation ?? this.flowInterpretation,
      coreMessage: coreMessage ?? this.coreMessage,
      smallAction: smallAction ?? this.smallAction,
      createdAtUtcUs: createdAtUtcUs ?? this.createdAtUtcUs,
      updatedAtUtcUs: updatedAtUtcUs ?? this.updatedAtUtcUs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (readingInstanceId.present) {
      map['reading_instance_id'] = Variable<String>(readingInstanceId.value);
    }
    if (wholeImageObservation.present) {
      map['whole_image_observation'] = Variable<String>(
        wholeImageObservation.value,
      );
    }
    if (flowInterpretation.present) {
      map['flow_interpretation'] = Variable<String>(flowInterpretation.value);
    }
    if (coreMessage.present) {
      map['core_message'] = Variable<String>(coreMessage.value);
    }
    if (smallAction.present) {
      map['small_action'] = Variable<String>(smallAction.value);
    }
    if (createdAtUtcUs.present) {
      map['created_at_utc_us'] = Variable<int>(createdAtUtcUs.value);
    }
    if (updatedAtUtcUs.present) {
      map['updated_at_utc_us'] = Variable<int>(updatedAtUtcUs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TarotInterpretationsCompanion(')
          ..write('readingInstanceId: $readingInstanceId, ')
          ..write('wholeImageObservation: $wholeImageObservation, ')
          ..write('flowInterpretation: $flowInterpretation, ')
          ..write('coreMessage: $coreMessage, ')
          ..write('smallAction: $smallAction, ')
          ..write('createdAtUtcUs: $createdAtUtcUs, ')
          ..write('updatedAtUtcUs: $updatedAtUtcUs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppRuntimeStateTable extends AppRuntimeState
    with TableInfo<$AppRuntimeStateTable, AppRuntimeStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppRuntimeStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _stateKeyMeta = const VerificationMeta(
    'stateKey',
  );
  @override
  late final GeneratedColumn<String> stateKey = GeneratedColumn<String>(
    'state_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeHomeTarotReadingIdMeta =
      const VerificationMeta('activeHomeTarotReadingId');
  @override
  late final GeneratedColumn<String> activeHomeTarotReadingId =
      GeneratedColumn<String>(
        'active_home_tarot_reading_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tarot_readings (reading_instance_id) ON DELETE RESTRICT',
        ),
      );
  static const VerificationMeta _updatedAtUtcUsMeta = const VerificationMeta(
    'updatedAtUtcUs',
  );
  @override
  late final GeneratedColumn<int> updatedAtUtcUs = GeneratedColumn<int>(
    'updated_at_utc_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    stateKey,
    activeHomeTarotReadingId,
    updatedAtUtcUs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_runtime_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppRuntimeStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('state_key')) {
      context.handle(
        _stateKeyMeta,
        stateKey.isAcceptableOrUnknown(data['state_key']!, _stateKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_stateKeyMeta);
    }
    if (data.containsKey('active_home_tarot_reading_id')) {
      context.handle(
        _activeHomeTarotReadingIdMeta,
        activeHomeTarotReadingId.isAcceptableOrUnknown(
          data['active_home_tarot_reading_id']!,
          _activeHomeTarotReadingIdMeta,
        ),
      );
    }
    if (data.containsKey('updated_at_utc_us')) {
      context.handle(
        _updatedAtUtcUsMeta,
        updatedAtUtcUs.isAcceptableOrUnknown(
          data['updated_at_utc_us']!,
          _updatedAtUtcUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcUsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {stateKey};
  @override
  AppRuntimeStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppRuntimeStateData(
      stateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state_key'],
      )!,
      activeHomeTarotReadingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_home_tarot_reading_id'],
      ),
      updatedAtUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc_us'],
      )!,
    );
  }

  @override
  $AppRuntimeStateTable createAlias(String alias) {
    return $AppRuntimeStateTable(attachedDatabase, alias);
  }
}

class AppRuntimeStateData extends DataClass
    implements Insertable<AppRuntimeStateData> {
  final String stateKey;
  final String? activeHomeTarotReadingId;
  final int updatedAtUtcUs;
  const AppRuntimeStateData({
    required this.stateKey,
    this.activeHomeTarotReadingId,
    required this.updatedAtUtcUs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['state_key'] = Variable<String>(stateKey);
    if (!nullToAbsent || activeHomeTarotReadingId != null) {
      map['active_home_tarot_reading_id'] = Variable<String>(
        activeHomeTarotReadingId,
      );
    }
    map['updated_at_utc_us'] = Variable<int>(updatedAtUtcUs);
    return map;
  }

  AppRuntimeStateCompanion toCompanion(bool nullToAbsent) {
    return AppRuntimeStateCompanion(
      stateKey: Value(stateKey),
      activeHomeTarotReadingId: activeHomeTarotReadingId == null && nullToAbsent
          ? const Value.absent()
          : Value(activeHomeTarotReadingId),
      updatedAtUtcUs: Value(updatedAtUtcUs),
    );
  }

  factory AppRuntimeStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppRuntimeStateData(
      stateKey: serializer.fromJson<String>(json['stateKey']),
      activeHomeTarotReadingId: serializer.fromJson<String?>(
        json['activeHomeTarotReadingId'],
      ),
      updatedAtUtcUs: serializer.fromJson<int>(json['updatedAtUtcUs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'stateKey': serializer.toJson<String>(stateKey),
      'activeHomeTarotReadingId': serializer.toJson<String?>(
        activeHomeTarotReadingId,
      ),
      'updatedAtUtcUs': serializer.toJson<int>(updatedAtUtcUs),
    };
  }

  AppRuntimeStateData copyWith({
    String? stateKey,
    Value<String?> activeHomeTarotReadingId = const Value.absent(),
    int? updatedAtUtcUs,
  }) => AppRuntimeStateData(
    stateKey: stateKey ?? this.stateKey,
    activeHomeTarotReadingId: activeHomeTarotReadingId.present
        ? activeHomeTarotReadingId.value
        : this.activeHomeTarotReadingId,
    updatedAtUtcUs: updatedAtUtcUs ?? this.updatedAtUtcUs,
  );
  AppRuntimeStateData copyWithCompanion(AppRuntimeStateCompanion data) {
    return AppRuntimeStateData(
      stateKey: data.stateKey.present ? data.stateKey.value : this.stateKey,
      activeHomeTarotReadingId: data.activeHomeTarotReadingId.present
          ? data.activeHomeTarotReadingId.value
          : this.activeHomeTarotReadingId,
      updatedAtUtcUs: data.updatedAtUtcUs.present
          ? data.updatedAtUtcUs.value
          : this.updatedAtUtcUs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppRuntimeStateData(')
          ..write('stateKey: $stateKey, ')
          ..write('activeHomeTarotReadingId: $activeHomeTarotReadingId, ')
          ..write('updatedAtUtcUs: $updatedAtUtcUs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(stateKey, activeHomeTarotReadingId, updatedAtUtcUs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppRuntimeStateData &&
          other.stateKey == this.stateKey &&
          other.activeHomeTarotReadingId == this.activeHomeTarotReadingId &&
          other.updatedAtUtcUs == this.updatedAtUtcUs);
}

class AppRuntimeStateCompanion extends UpdateCompanion<AppRuntimeStateData> {
  final Value<String> stateKey;
  final Value<String?> activeHomeTarotReadingId;
  final Value<int> updatedAtUtcUs;
  final Value<int> rowid;
  const AppRuntimeStateCompanion({
    this.stateKey = const Value.absent(),
    this.activeHomeTarotReadingId = const Value.absent(),
    this.updatedAtUtcUs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppRuntimeStateCompanion.insert({
    required String stateKey,
    this.activeHomeTarotReadingId = const Value.absent(),
    required int updatedAtUtcUs,
    this.rowid = const Value.absent(),
  }) : stateKey = Value(stateKey),
       updatedAtUtcUs = Value(updatedAtUtcUs);
  static Insertable<AppRuntimeStateData> custom({
    Expression<String>? stateKey,
    Expression<String>? activeHomeTarotReadingId,
    Expression<int>? updatedAtUtcUs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (stateKey != null) 'state_key': stateKey,
      if (activeHomeTarotReadingId != null)
        'active_home_tarot_reading_id': activeHomeTarotReadingId,
      if (updatedAtUtcUs != null) 'updated_at_utc_us': updatedAtUtcUs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppRuntimeStateCompanion copyWith({
    Value<String>? stateKey,
    Value<String?>? activeHomeTarotReadingId,
    Value<int>? updatedAtUtcUs,
    Value<int>? rowid,
  }) {
    return AppRuntimeStateCompanion(
      stateKey: stateKey ?? this.stateKey,
      activeHomeTarotReadingId:
          activeHomeTarotReadingId ?? this.activeHomeTarotReadingId,
      updatedAtUtcUs: updatedAtUtcUs ?? this.updatedAtUtcUs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (stateKey.present) {
      map['state_key'] = Variable<String>(stateKey.value);
    }
    if (activeHomeTarotReadingId.present) {
      map['active_home_tarot_reading_id'] = Variable<String>(
        activeHomeTarotReadingId.value,
      );
    }
    if (updatedAtUtcUs.present) {
      map['updated_at_utc_us'] = Variable<int>(updatedAtUtcUs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppRuntimeStateCompanion(')
          ..write('stateKey: $stateKey, ')
          ..write('activeHomeTarotReadingId: $activeHomeTarotReadingId, ')
          ..write('updatedAtUtcUs: $updatedAtUtcUs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonsTable extends Persons with TableInfo<$PersonsTable, PersonRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 240,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relationshipSummaryMeta =
      const VerificationMeta('relationshipSummary');
  @override
  late final GeneratedColumn<String> relationshipSummary =
      GeneratedColumn<String>(
        'relationship_summary',
        aliasedName,
        true,
        additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 2000),
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _firstMetOnUtcUsMeta = const VerificationMeta(
    'firstMetOnUtcUs',
  );
  @override
  late final GeneratedColumn<int> firstMetOnUtcUs = GeneratedColumn<int>(
    'first_met_on_utc_us',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archivedAtUtcUsMeta = const VerificationMeta(
    'archivedAtUtcUs',
  );
  @override
  late final GeneratedColumn<int> archivedAtUtcUs = GeneratedColumn<int>(
    'archived_at_utc_us',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtUtcUsMeta = const VerificationMeta(
    'createdAtUtcUs',
  );
  @override
  late final GeneratedColumn<int> createdAtUtcUs = GeneratedColumn<int>(
    'created_at_utc_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcUsMeta = const VerificationMeta(
    'updatedAtUtcUs',
  );
  @override
  late final GeneratedColumn<int> updatedAtUtcUs = GeneratedColumn<int>(
    'updated_at_utc_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    status,
    relationshipSummary,
    firstMetOnUtcUs,
    archivedAtUtcUs,
    createdAtUtcUs,
    updatedAtUtcUs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'persons';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('relationship_summary')) {
      context.handle(
        _relationshipSummaryMeta,
        relationshipSummary.isAcceptableOrUnknown(
          data['relationship_summary']!,
          _relationshipSummaryMeta,
        ),
      );
    }
    if (data.containsKey('first_met_on_utc_us')) {
      context.handle(
        _firstMetOnUtcUsMeta,
        firstMetOnUtcUs.isAcceptableOrUnknown(
          data['first_met_on_utc_us']!,
          _firstMetOnUtcUsMeta,
        ),
      );
    }
    if (data.containsKey('archived_at_utc_us')) {
      context.handle(
        _archivedAtUtcUsMeta,
        archivedAtUtcUs.isAcceptableOrUnknown(
          data['archived_at_utc_us']!,
          _archivedAtUtcUsMeta,
        ),
      );
    }
    if (data.containsKey('created_at_utc_us')) {
      context.handle(
        _createdAtUtcUsMeta,
        createdAtUtcUs.isAcceptableOrUnknown(
          data['created_at_utc_us']!,
          _createdAtUtcUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcUsMeta);
    }
    if (data.containsKey('updated_at_utc_us')) {
      context.handle(
        _updatedAtUtcUsMeta,
        updatedAtUtcUs.isAcceptableOrUnknown(
          data['updated_at_utc_us']!,
          _updatedAtUtcUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcUsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      relationshipSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relationship_summary'],
      ),
      firstMetOnUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_met_on_utc_us'],
      ),
      archivedAtUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}archived_at_utc_us'],
      ),
      createdAtUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_us'],
      )!,
      updatedAtUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc_us'],
      )!,
    );
  }

  @override
  $PersonsTable createAlias(String alias) {
    return $PersonsTable(attachedDatabase, alias);
  }
}

class PersonRow extends DataClass implements Insertable<PersonRow> {
  final String id;
  final String displayName;
  final String status;
  final String? relationshipSummary;
  final int? firstMetOnUtcUs;
  final int? archivedAtUtcUs;
  final int createdAtUtcUs;
  final int updatedAtUtcUs;
  const PersonRow({
    required this.id,
    required this.displayName,
    required this.status,
    this.relationshipSummary,
    this.firstMetOnUtcUs,
    this.archivedAtUtcUs,
    required this.createdAtUtcUs,
    required this.updatedAtUtcUs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || relationshipSummary != null) {
      map['relationship_summary'] = Variable<String>(relationshipSummary);
    }
    if (!nullToAbsent || firstMetOnUtcUs != null) {
      map['first_met_on_utc_us'] = Variable<int>(firstMetOnUtcUs);
    }
    if (!nullToAbsent || archivedAtUtcUs != null) {
      map['archived_at_utc_us'] = Variable<int>(archivedAtUtcUs);
    }
    map['created_at_utc_us'] = Variable<int>(createdAtUtcUs);
    map['updated_at_utc_us'] = Variable<int>(updatedAtUtcUs);
    return map;
  }

  PersonsCompanion toCompanion(bool nullToAbsent) {
    return PersonsCompanion(
      id: Value(id),
      displayName: Value(displayName),
      status: Value(status),
      relationshipSummary: relationshipSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(relationshipSummary),
      firstMetOnUtcUs: firstMetOnUtcUs == null && nullToAbsent
          ? const Value.absent()
          : Value(firstMetOnUtcUs),
      archivedAtUtcUs: archivedAtUtcUs == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAtUtcUs),
      createdAtUtcUs: Value(createdAtUtcUs),
      updatedAtUtcUs: Value(updatedAtUtcUs),
    );
  }

  factory PersonRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonRow(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      status: serializer.fromJson<String>(json['status']),
      relationshipSummary: serializer.fromJson<String?>(
        json['relationshipSummary'],
      ),
      firstMetOnUtcUs: serializer.fromJson<int?>(json['firstMetOnUtcUs']),
      archivedAtUtcUs: serializer.fromJson<int?>(json['archivedAtUtcUs']),
      createdAtUtcUs: serializer.fromJson<int>(json['createdAtUtcUs']),
      updatedAtUtcUs: serializer.fromJson<int>(json['updatedAtUtcUs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'status': serializer.toJson<String>(status),
      'relationshipSummary': serializer.toJson<String?>(relationshipSummary),
      'firstMetOnUtcUs': serializer.toJson<int?>(firstMetOnUtcUs),
      'archivedAtUtcUs': serializer.toJson<int?>(archivedAtUtcUs),
      'createdAtUtcUs': serializer.toJson<int>(createdAtUtcUs),
      'updatedAtUtcUs': serializer.toJson<int>(updatedAtUtcUs),
    };
  }

  PersonRow copyWith({
    String? id,
    String? displayName,
    String? status,
    Value<String?> relationshipSummary = const Value.absent(),
    Value<int?> firstMetOnUtcUs = const Value.absent(),
    Value<int?> archivedAtUtcUs = const Value.absent(),
    int? createdAtUtcUs,
    int? updatedAtUtcUs,
  }) => PersonRow(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    status: status ?? this.status,
    relationshipSummary: relationshipSummary.present
        ? relationshipSummary.value
        : this.relationshipSummary,
    firstMetOnUtcUs: firstMetOnUtcUs.present
        ? firstMetOnUtcUs.value
        : this.firstMetOnUtcUs,
    archivedAtUtcUs: archivedAtUtcUs.present
        ? archivedAtUtcUs.value
        : this.archivedAtUtcUs,
    createdAtUtcUs: createdAtUtcUs ?? this.createdAtUtcUs,
    updatedAtUtcUs: updatedAtUtcUs ?? this.updatedAtUtcUs,
  );
  PersonRow copyWithCompanion(PersonsCompanion data) {
    return PersonRow(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      status: data.status.present ? data.status.value : this.status,
      relationshipSummary: data.relationshipSummary.present
          ? data.relationshipSummary.value
          : this.relationshipSummary,
      firstMetOnUtcUs: data.firstMetOnUtcUs.present
          ? data.firstMetOnUtcUs.value
          : this.firstMetOnUtcUs,
      archivedAtUtcUs: data.archivedAtUtcUs.present
          ? data.archivedAtUtcUs.value
          : this.archivedAtUtcUs,
      createdAtUtcUs: data.createdAtUtcUs.present
          ? data.createdAtUtcUs.value
          : this.createdAtUtcUs,
      updatedAtUtcUs: data.updatedAtUtcUs.present
          ? data.updatedAtUtcUs.value
          : this.updatedAtUtcUs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonRow(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('status: $status, ')
          ..write('relationshipSummary: $relationshipSummary, ')
          ..write('firstMetOnUtcUs: $firstMetOnUtcUs, ')
          ..write('archivedAtUtcUs: $archivedAtUtcUs, ')
          ..write('createdAtUtcUs: $createdAtUtcUs, ')
          ..write('updatedAtUtcUs: $updatedAtUtcUs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    status,
    relationshipSummary,
    firstMetOnUtcUs,
    archivedAtUtcUs,
    createdAtUtcUs,
    updatedAtUtcUs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonRow &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.status == this.status &&
          other.relationshipSummary == this.relationshipSummary &&
          other.firstMetOnUtcUs == this.firstMetOnUtcUs &&
          other.archivedAtUtcUs == this.archivedAtUtcUs &&
          other.createdAtUtcUs == this.createdAtUtcUs &&
          other.updatedAtUtcUs == this.updatedAtUtcUs);
}

class PersonsCompanion extends UpdateCompanion<PersonRow> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<String> status;
  final Value<String?> relationshipSummary;
  final Value<int?> firstMetOnUtcUs;
  final Value<int?> archivedAtUtcUs;
  final Value<int> createdAtUtcUs;
  final Value<int> updatedAtUtcUs;
  final Value<int> rowid;
  const PersonsCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.status = const Value.absent(),
    this.relationshipSummary = const Value.absent(),
    this.firstMetOnUtcUs = const Value.absent(),
    this.archivedAtUtcUs = const Value.absent(),
    this.createdAtUtcUs = const Value.absent(),
    this.updatedAtUtcUs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonsCompanion.insert({
    required String id,
    required String displayName,
    required String status,
    this.relationshipSummary = const Value.absent(),
    this.firstMetOnUtcUs = const Value.absent(),
    this.archivedAtUtcUs = const Value.absent(),
    required int createdAtUtcUs,
    required int updatedAtUtcUs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       status = Value(status),
       createdAtUtcUs = Value(createdAtUtcUs),
       updatedAtUtcUs = Value(updatedAtUtcUs);
  static Insertable<PersonRow> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? status,
    Expression<String>? relationshipSummary,
    Expression<int>? firstMetOnUtcUs,
    Expression<int>? archivedAtUtcUs,
    Expression<int>? createdAtUtcUs,
    Expression<int>? updatedAtUtcUs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (status != null) 'status': status,
      if (relationshipSummary != null)
        'relationship_summary': relationshipSummary,
      if (firstMetOnUtcUs != null) 'first_met_on_utc_us': firstMetOnUtcUs,
      if (archivedAtUtcUs != null) 'archived_at_utc_us': archivedAtUtcUs,
      if (createdAtUtcUs != null) 'created_at_utc_us': createdAtUtcUs,
      if (updatedAtUtcUs != null) 'updated_at_utc_us': updatedAtUtcUs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonsCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<String>? status,
    Value<String?>? relationshipSummary,
    Value<int?>? firstMetOnUtcUs,
    Value<int?>? archivedAtUtcUs,
    Value<int>? createdAtUtcUs,
    Value<int>? updatedAtUtcUs,
    Value<int>? rowid,
  }) {
    return PersonsCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      status: status ?? this.status,
      relationshipSummary: relationshipSummary ?? this.relationshipSummary,
      firstMetOnUtcUs: firstMetOnUtcUs ?? this.firstMetOnUtcUs,
      archivedAtUtcUs: archivedAtUtcUs ?? this.archivedAtUtcUs,
      createdAtUtcUs: createdAtUtcUs ?? this.createdAtUtcUs,
      updatedAtUtcUs: updatedAtUtcUs ?? this.updatedAtUtcUs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (relationshipSummary.present) {
      map['relationship_summary'] = Variable<String>(relationshipSummary.value);
    }
    if (firstMetOnUtcUs.present) {
      map['first_met_on_utc_us'] = Variable<int>(firstMetOnUtcUs.value);
    }
    if (archivedAtUtcUs.present) {
      map['archived_at_utc_us'] = Variable<int>(archivedAtUtcUs.value);
    }
    if (createdAtUtcUs.present) {
      map['created_at_utc_us'] = Variable<int>(createdAtUtcUs.value);
    }
    if (updatedAtUtcUs.present) {
      map['updated_at_utc_us'] = Variable<int>(updatedAtUtcUs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonsCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('status: $status, ')
          ..write('relationshipSummary: $relationshipSummary, ')
          ..write('firstMetOnUtcUs: $firstMetOnUtcUs, ')
          ..write('archivedAtUtcUs: $archivedAtUtcUs, ')
          ..write('createdAtUtcUs: $createdAtUtcUs, ')
          ..write('updatedAtUtcUs: $updatedAtUtcUs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonRolesTable extends PersonRoles
    with TableInfo<$PersonRolesTable, PersonRoleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonRolesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES persons (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _roleTypeMeta = const VerificationMeta(
    'roleType',
  );
  @override
  late final GeneratedColumn<String> roleType = GeneratedColumn<String>(
    'role_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectiveFromUtcUsMeta =
      const VerificationMeta('effectiveFromUtcUs');
  @override
  late final GeneratedColumn<int> effectiveFromUtcUs = GeneratedColumn<int>(
    'effective_from_utc_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectiveToUtcUsMeta = const VerificationMeta(
    'effectiveToUtcUs',
  );
  @override
  late final GeneratedColumn<int> effectiveToUtcUs = GeneratedColumn<int>(
    'effective_to_utc_us',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 1000),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtUtcUsMeta = const VerificationMeta(
    'createdAtUtcUs',
  );
  @override
  late final GeneratedColumn<int> createdAtUtcUs = GeneratedColumn<int>(
    'created_at_utc_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcUsMeta = const VerificationMeta(
    'updatedAtUtcUs',
  );
  @override
  late final GeneratedColumn<int> updatedAtUtcUs = GeneratedColumn<int>(
    'updated_at_utc_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    personId,
    roleType,
    effectiveFromUtcUs,
    effectiveToUtcUs,
    note,
    createdAtUtcUs,
    updatedAtUtcUs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'person_roles';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonRoleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('role_type')) {
      context.handle(
        _roleTypeMeta,
        roleType.isAcceptableOrUnknown(data['role_type']!, _roleTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_roleTypeMeta);
    }
    if (data.containsKey('effective_from_utc_us')) {
      context.handle(
        _effectiveFromUtcUsMeta,
        effectiveFromUtcUs.isAcceptableOrUnknown(
          data['effective_from_utc_us']!,
          _effectiveFromUtcUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveFromUtcUsMeta);
    }
    if (data.containsKey('effective_to_utc_us')) {
      context.handle(
        _effectiveToUtcUsMeta,
        effectiveToUtcUs.isAcceptableOrUnknown(
          data['effective_to_utc_us']!,
          _effectiveToUtcUsMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at_utc_us')) {
      context.handle(
        _createdAtUtcUsMeta,
        createdAtUtcUs.isAcceptableOrUnknown(
          data['created_at_utc_us']!,
          _createdAtUtcUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcUsMeta);
    }
    if (data.containsKey('updated_at_utc_us')) {
      context.handle(
        _updatedAtUtcUsMeta,
        updatedAtUtcUs.isAcceptableOrUnknown(
          data['updated_at_utc_us']!,
          _updatedAtUtcUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcUsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonRoleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonRoleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      )!,
      roleType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role_type'],
      )!,
      effectiveFromUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}effective_from_utc_us'],
      )!,
      effectiveToUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}effective_to_utc_us'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAtUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_us'],
      )!,
      updatedAtUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc_us'],
      )!,
    );
  }

  @override
  $PersonRolesTable createAlias(String alias) {
    return $PersonRolesTable(attachedDatabase, alias);
  }
}

class PersonRoleRow extends DataClass implements Insertable<PersonRoleRow> {
  final String id;
  final String personId;
  final String roleType;
  final int effectiveFromUtcUs;
  final int? effectiveToUtcUs;
  final String? note;
  final int createdAtUtcUs;
  final int updatedAtUtcUs;
  const PersonRoleRow({
    required this.id,
    required this.personId,
    required this.roleType,
    required this.effectiveFromUtcUs,
    this.effectiveToUtcUs,
    this.note,
    required this.createdAtUtcUs,
    required this.updatedAtUtcUs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['person_id'] = Variable<String>(personId);
    map['role_type'] = Variable<String>(roleType);
    map['effective_from_utc_us'] = Variable<int>(effectiveFromUtcUs);
    if (!nullToAbsent || effectiveToUtcUs != null) {
      map['effective_to_utc_us'] = Variable<int>(effectiveToUtcUs);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at_utc_us'] = Variable<int>(createdAtUtcUs);
    map['updated_at_utc_us'] = Variable<int>(updatedAtUtcUs);
    return map;
  }

  PersonRolesCompanion toCompanion(bool nullToAbsent) {
    return PersonRolesCompanion(
      id: Value(id),
      personId: Value(personId),
      roleType: Value(roleType),
      effectiveFromUtcUs: Value(effectiveFromUtcUs),
      effectiveToUtcUs: effectiveToUtcUs == null && nullToAbsent
          ? const Value.absent()
          : Value(effectiveToUtcUs),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAtUtcUs: Value(createdAtUtcUs),
      updatedAtUtcUs: Value(updatedAtUtcUs),
    );
  }

  factory PersonRoleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonRoleRow(
      id: serializer.fromJson<String>(json['id']),
      personId: serializer.fromJson<String>(json['personId']),
      roleType: serializer.fromJson<String>(json['roleType']),
      effectiveFromUtcUs: serializer.fromJson<int>(json['effectiveFromUtcUs']),
      effectiveToUtcUs: serializer.fromJson<int?>(json['effectiveToUtcUs']),
      note: serializer.fromJson<String?>(json['note']),
      createdAtUtcUs: serializer.fromJson<int>(json['createdAtUtcUs']),
      updatedAtUtcUs: serializer.fromJson<int>(json['updatedAtUtcUs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'personId': serializer.toJson<String>(personId),
      'roleType': serializer.toJson<String>(roleType),
      'effectiveFromUtcUs': serializer.toJson<int>(effectiveFromUtcUs),
      'effectiveToUtcUs': serializer.toJson<int?>(effectiveToUtcUs),
      'note': serializer.toJson<String?>(note),
      'createdAtUtcUs': serializer.toJson<int>(createdAtUtcUs),
      'updatedAtUtcUs': serializer.toJson<int>(updatedAtUtcUs),
    };
  }

  PersonRoleRow copyWith({
    String? id,
    String? personId,
    String? roleType,
    int? effectiveFromUtcUs,
    Value<int?> effectiveToUtcUs = const Value.absent(),
    Value<String?> note = const Value.absent(),
    int? createdAtUtcUs,
    int? updatedAtUtcUs,
  }) => PersonRoleRow(
    id: id ?? this.id,
    personId: personId ?? this.personId,
    roleType: roleType ?? this.roleType,
    effectiveFromUtcUs: effectiveFromUtcUs ?? this.effectiveFromUtcUs,
    effectiveToUtcUs: effectiveToUtcUs.present
        ? effectiveToUtcUs.value
        : this.effectiveToUtcUs,
    note: note.present ? note.value : this.note,
    createdAtUtcUs: createdAtUtcUs ?? this.createdAtUtcUs,
    updatedAtUtcUs: updatedAtUtcUs ?? this.updatedAtUtcUs,
  );
  PersonRoleRow copyWithCompanion(PersonRolesCompanion data) {
    return PersonRoleRow(
      id: data.id.present ? data.id.value : this.id,
      personId: data.personId.present ? data.personId.value : this.personId,
      roleType: data.roleType.present ? data.roleType.value : this.roleType,
      effectiveFromUtcUs: data.effectiveFromUtcUs.present
          ? data.effectiveFromUtcUs.value
          : this.effectiveFromUtcUs,
      effectiveToUtcUs: data.effectiveToUtcUs.present
          ? data.effectiveToUtcUs.value
          : this.effectiveToUtcUs,
      note: data.note.present ? data.note.value : this.note,
      createdAtUtcUs: data.createdAtUtcUs.present
          ? data.createdAtUtcUs.value
          : this.createdAtUtcUs,
      updatedAtUtcUs: data.updatedAtUtcUs.present
          ? data.updatedAtUtcUs.value
          : this.updatedAtUtcUs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonRoleRow(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('roleType: $roleType, ')
          ..write('effectiveFromUtcUs: $effectiveFromUtcUs, ')
          ..write('effectiveToUtcUs: $effectiveToUtcUs, ')
          ..write('note: $note, ')
          ..write('createdAtUtcUs: $createdAtUtcUs, ')
          ..write('updatedAtUtcUs: $updatedAtUtcUs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    personId,
    roleType,
    effectiveFromUtcUs,
    effectiveToUtcUs,
    note,
    createdAtUtcUs,
    updatedAtUtcUs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonRoleRow &&
          other.id == this.id &&
          other.personId == this.personId &&
          other.roleType == this.roleType &&
          other.effectiveFromUtcUs == this.effectiveFromUtcUs &&
          other.effectiveToUtcUs == this.effectiveToUtcUs &&
          other.note == this.note &&
          other.createdAtUtcUs == this.createdAtUtcUs &&
          other.updatedAtUtcUs == this.updatedAtUtcUs);
}

class PersonRolesCompanion extends UpdateCompanion<PersonRoleRow> {
  final Value<String> id;
  final Value<String> personId;
  final Value<String> roleType;
  final Value<int> effectiveFromUtcUs;
  final Value<int?> effectiveToUtcUs;
  final Value<String?> note;
  final Value<int> createdAtUtcUs;
  final Value<int> updatedAtUtcUs;
  final Value<int> rowid;
  const PersonRolesCompanion({
    this.id = const Value.absent(),
    this.personId = const Value.absent(),
    this.roleType = const Value.absent(),
    this.effectiveFromUtcUs = const Value.absent(),
    this.effectiveToUtcUs = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAtUtcUs = const Value.absent(),
    this.updatedAtUtcUs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonRolesCompanion.insert({
    required String id,
    required String personId,
    required String roleType,
    required int effectiveFromUtcUs,
    this.effectiveToUtcUs = const Value.absent(),
    this.note = const Value.absent(),
    required int createdAtUtcUs,
    required int updatedAtUtcUs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       personId = Value(personId),
       roleType = Value(roleType),
       effectiveFromUtcUs = Value(effectiveFromUtcUs),
       createdAtUtcUs = Value(createdAtUtcUs),
       updatedAtUtcUs = Value(updatedAtUtcUs);
  static Insertable<PersonRoleRow> custom({
    Expression<String>? id,
    Expression<String>? personId,
    Expression<String>? roleType,
    Expression<int>? effectiveFromUtcUs,
    Expression<int>? effectiveToUtcUs,
    Expression<String>? note,
    Expression<int>? createdAtUtcUs,
    Expression<int>? updatedAtUtcUs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personId != null) 'person_id': personId,
      if (roleType != null) 'role_type': roleType,
      if (effectiveFromUtcUs != null)
        'effective_from_utc_us': effectiveFromUtcUs,
      if (effectiveToUtcUs != null) 'effective_to_utc_us': effectiveToUtcUs,
      if (note != null) 'note': note,
      if (createdAtUtcUs != null) 'created_at_utc_us': createdAtUtcUs,
      if (updatedAtUtcUs != null) 'updated_at_utc_us': updatedAtUtcUs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonRolesCompanion copyWith({
    Value<String>? id,
    Value<String>? personId,
    Value<String>? roleType,
    Value<int>? effectiveFromUtcUs,
    Value<int?>? effectiveToUtcUs,
    Value<String?>? note,
    Value<int>? createdAtUtcUs,
    Value<int>? updatedAtUtcUs,
    Value<int>? rowid,
  }) {
    return PersonRolesCompanion(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      roleType: roleType ?? this.roleType,
      effectiveFromUtcUs: effectiveFromUtcUs ?? this.effectiveFromUtcUs,
      effectiveToUtcUs: effectiveToUtcUs ?? this.effectiveToUtcUs,
      note: note ?? this.note,
      createdAtUtcUs: createdAtUtcUs ?? this.createdAtUtcUs,
      updatedAtUtcUs: updatedAtUtcUs ?? this.updatedAtUtcUs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (roleType.present) {
      map['role_type'] = Variable<String>(roleType.value);
    }
    if (effectiveFromUtcUs.present) {
      map['effective_from_utc_us'] = Variable<int>(effectiveFromUtcUs.value);
    }
    if (effectiveToUtcUs.present) {
      map['effective_to_utc_us'] = Variable<int>(effectiveToUtcUs.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAtUtcUs.present) {
      map['created_at_utc_us'] = Variable<int>(createdAtUtcUs.value);
    }
    if (updatedAtUtcUs.present) {
      map['updated_at_utc_us'] = Variable<int>(updatedAtUtcUs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonRolesCompanion(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('roleType: $roleType, ')
          ..write('effectiveFromUtcUs: $effectiveFromUtcUs, ')
          ..write('effectiveToUtcUs: $effectiveToUtcUs, ')
          ..write('note: $note, ')
          ..write('createdAtUtcUs: $createdAtUtcUs, ')
          ..write('updatedAtUtcUs: $updatedAtUtcUs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonRelationshipsTable extends PersonRelationships
    with TableInfo<$PersonRelationshipsTable, PersonRelationshipRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonRelationshipsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _fromPersonIdMeta = const VerificationMeta(
    'fromPersonId',
  );
  @override
  late final GeneratedColumn<String> fromPersonId = GeneratedColumn<String>(
    'from_person_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES persons (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _toPersonIdMeta = const VerificationMeta(
    'toPersonId',
  );
  @override
  late final GeneratedColumn<String> toPersonId = GeneratedColumn<String>(
    'to_person_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES persons (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _relationshipTypeMeta = const VerificationMeta(
    'relationshipType',
  );
  @override
  late final GeneratedColumn<String> relationshipType = GeneratedColumn<String>(
    'relationship_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectiveFromUtcUsMeta =
      const VerificationMeta('effectiveFromUtcUs');
  @override
  late final GeneratedColumn<int> effectiveFromUtcUs = GeneratedColumn<int>(
    'effective_from_utc_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectiveToUtcUsMeta = const VerificationMeta(
    'effectiveToUtcUs',
  );
  @override
  late final GeneratedColumn<int> effectiveToUtcUs = GeneratedColumn<int>(
    'effective_to_utc_us',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 1000),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtUtcUsMeta = const VerificationMeta(
    'createdAtUtcUs',
  );
  @override
  late final GeneratedColumn<int> createdAtUtcUs = GeneratedColumn<int>(
    'created_at_utc_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcUsMeta = const VerificationMeta(
    'updatedAtUtcUs',
  );
  @override
  late final GeneratedColumn<int> updatedAtUtcUs = GeneratedColumn<int>(
    'updated_at_utc_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fromPersonId,
    toPersonId,
    relationshipType,
    effectiveFromUtcUs,
    effectiveToUtcUs,
    note,
    createdAtUtcUs,
    updatedAtUtcUs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'person_relationships';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonRelationshipRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('from_person_id')) {
      context.handle(
        _fromPersonIdMeta,
        fromPersonId.isAcceptableOrUnknown(
          data['from_person_id']!,
          _fromPersonIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromPersonIdMeta);
    }
    if (data.containsKey('to_person_id')) {
      context.handle(
        _toPersonIdMeta,
        toPersonId.isAcceptableOrUnknown(
          data['to_person_id']!,
          _toPersonIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_toPersonIdMeta);
    }
    if (data.containsKey('relationship_type')) {
      context.handle(
        _relationshipTypeMeta,
        relationshipType.isAcceptableOrUnknown(
          data['relationship_type']!,
          _relationshipTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relationshipTypeMeta);
    }
    if (data.containsKey('effective_from_utc_us')) {
      context.handle(
        _effectiveFromUtcUsMeta,
        effectiveFromUtcUs.isAcceptableOrUnknown(
          data['effective_from_utc_us']!,
          _effectiveFromUtcUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveFromUtcUsMeta);
    }
    if (data.containsKey('effective_to_utc_us')) {
      context.handle(
        _effectiveToUtcUsMeta,
        effectiveToUtcUs.isAcceptableOrUnknown(
          data['effective_to_utc_us']!,
          _effectiveToUtcUsMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at_utc_us')) {
      context.handle(
        _createdAtUtcUsMeta,
        createdAtUtcUs.isAcceptableOrUnknown(
          data['created_at_utc_us']!,
          _createdAtUtcUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcUsMeta);
    }
    if (data.containsKey('updated_at_utc_us')) {
      context.handle(
        _updatedAtUtcUsMeta,
        updatedAtUtcUs.isAcceptableOrUnknown(
          data['updated_at_utc_us']!,
          _updatedAtUtcUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcUsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {fromPersonId, toPersonId, relationshipType, effectiveFromUtcUs},
  ];
  @override
  PersonRelationshipRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonRelationshipRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fromPersonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_person_id'],
      )!,
      toPersonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_person_id'],
      )!,
      relationshipType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relationship_type'],
      )!,
      effectiveFromUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}effective_from_utc_us'],
      )!,
      effectiveToUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}effective_to_utc_us'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAtUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_us'],
      )!,
      updatedAtUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc_us'],
      )!,
    );
  }

  @override
  $PersonRelationshipsTable createAlias(String alias) {
    return $PersonRelationshipsTable(attachedDatabase, alias);
  }
}

class PersonRelationshipRow extends DataClass
    implements Insertable<PersonRelationshipRow> {
  final String id;
  final String fromPersonId;
  final String toPersonId;
  final String relationshipType;
  final int effectiveFromUtcUs;
  final int? effectiveToUtcUs;
  final String? note;
  final int createdAtUtcUs;
  final int updatedAtUtcUs;
  const PersonRelationshipRow({
    required this.id,
    required this.fromPersonId,
    required this.toPersonId,
    required this.relationshipType,
    required this.effectiveFromUtcUs,
    this.effectiveToUtcUs,
    this.note,
    required this.createdAtUtcUs,
    required this.updatedAtUtcUs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['from_person_id'] = Variable<String>(fromPersonId);
    map['to_person_id'] = Variable<String>(toPersonId);
    map['relationship_type'] = Variable<String>(relationshipType);
    map['effective_from_utc_us'] = Variable<int>(effectiveFromUtcUs);
    if (!nullToAbsent || effectiveToUtcUs != null) {
      map['effective_to_utc_us'] = Variable<int>(effectiveToUtcUs);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at_utc_us'] = Variable<int>(createdAtUtcUs);
    map['updated_at_utc_us'] = Variable<int>(updatedAtUtcUs);
    return map;
  }

  PersonRelationshipsCompanion toCompanion(bool nullToAbsent) {
    return PersonRelationshipsCompanion(
      id: Value(id),
      fromPersonId: Value(fromPersonId),
      toPersonId: Value(toPersonId),
      relationshipType: Value(relationshipType),
      effectiveFromUtcUs: Value(effectiveFromUtcUs),
      effectiveToUtcUs: effectiveToUtcUs == null && nullToAbsent
          ? const Value.absent()
          : Value(effectiveToUtcUs),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAtUtcUs: Value(createdAtUtcUs),
      updatedAtUtcUs: Value(updatedAtUtcUs),
    );
  }

  factory PersonRelationshipRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonRelationshipRow(
      id: serializer.fromJson<String>(json['id']),
      fromPersonId: serializer.fromJson<String>(json['fromPersonId']),
      toPersonId: serializer.fromJson<String>(json['toPersonId']),
      relationshipType: serializer.fromJson<String>(json['relationshipType']),
      effectiveFromUtcUs: serializer.fromJson<int>(json['effectiveFromUtcUs']),
      effectiveToUtcUs: serializer.fromJson<int?>(json['effectiveToUtcUs']),
      note: serializer.fromJson<String?>(json['note']),
      createdAtUtcUs: serializer.fromJson<int>(json['createdAtUtcUs']),
      updatedAtUtcUs: serializer.fromJson<int>(json['updatedAtUtcUs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fromPersonId': serializer.toJson<String>(fromPersonId),
      'toPersonId': serializer.toJson<String>(toPersonId),
      'relationshipType': serializer.toJson<String>(relationshipType),
      'effectiveFromUtcUs': serializer.toJson<int>(effectiveFromUtcUs),
      'effectiveToUtcUs': serializer.toJson<int?>(effectiveToUtcUs),
      'note': serializer.toJson<String?>(note),
      'createdAtUtcUs': serializer.toJson<int>(createdAtUtcUs),
      'updatedAtUtcUs': serializer.toJson<int>(updatedAtUtcUs),
    };
  }

  PersonRelationshipRow copyWith({
    String? id,
    String? fromPersonId,
    String? toPersonId,
    String? relationshipType,
    int? effectiveFromUtcUs,
    Value<int?> effectiveToUtcUs = const Value.absent(),
    Value<String?> note = const Value.absent(),
    int? createdAtUtcUs,
    int? updatedAtUtcUs,
  }) => PersonRelationshipRow(
    id: id ?? this.id,
    fromPersonId: fromPersonId ?? this.fromPersonId,
    toPersonId: toPersonId ?? this.toPersonId,
    relationshipType: relationshipType ?? this.relationshipType,
    effectiveFromUtcUs: effectiveFromUtcUs ?? this.effectiveFromUtcUs,
    effectiveToUtcUs: effectiveToUtcUs.present
        ? effectiveToUtcUs.value
        : this.effectiveToUtcUs,
    note: note.present ? note.value : this.note,
    createdAtUtcUs: createdAtUtcUs ?? this.createdAtUtcUs,
    updatedAtUtcUs: updatedAtUtcUs ?? this.updatedAtUtcUs,
  );
  PersonRelationshipRow copyWithCompanion(PersonRelationshipsCompanion data) {
    return PersonRelationshipRow(
      id: data.id.present ? data.id.value : this.id,
      fromPersonId: data.fromPersonId.present
          ? data.fromPersonId.value
          : this.fromPersonId,
      toPersonId: data.toPersonId.present
          ? data.toPersonId.value
          : this.toPersonId,
      relationshipType: data.relationshipType.present
          ? data.relationshipType.value
          : this.relationshipType,
      effectiveFromUtcUs: data.effectiveFromUtcUs.present
          ? data.effectiveFromUtcUs.value
          : this.effectiveFromUtcUs,
      effectiveToUtcUs: data.effectiveToUtcUs.present
          ? data.effectiveToUtcUs.value
          : this.effectiveToUtcUs,
      note: data.note.present ? data.note.value : this.note,
      createdAtUtcUs: data.createdAtUtcUs.present
          ? data.createdAtUtcUs.value
          : this.createdAtUtcUs,
      updatedAtUtcUs: data.updatedAtUtcUs.present
          ? data.updatedAtUtcUs.value
          : this.updatedAtUtcUs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonRelationshipRow(')
          ..write('id: $id, ')
          ..write('fromPersonId: $fromPersonId, ')
          ..write('toPersonId: $toPersonId, ')
          ..write('relationshipType: $relationshipType, ')
          ..write('effectiveFromUtcUs: $effectiveFromUtcUs, ')
          ..write('effectiveToUtcUs: $effectiveToUtcUs, ')
          ..write('note: $note, ')
          ..write('createdAtUtcUs: $createdAtUtcUs, ')
          ..write('updatedAtUtcUs: $updatedAtUtcUs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fromPersonId,
    toPersonId,
    relationshipType,
    effectiveFromUtcUs,
    effectiveToUtcUs,
    note,
    createdAtUtcUs,
    updatedAtUtcUs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonRelationshipRow &&
          other.id == this.id &&
          other.fromPersonId == this.fromPersonId &&
          other.toPersonId == this.toPersonId &&
          other.relationshipType == this.relationshipType &&
          other.effectiveFromUtcUs == this.effectiveFromUtcUs &&
          other.effectiveToUtcUs == this.effectiveToUtcUs &&
          other.note == this.note &&
          other.createdAtUtcUs == this.createdAtUtcUs &&
          other.updatedAtUtcUs == this.updatedAtUtcUs);
}

class PersonRelationshipsCompanion
    extends UpdateCompanion<PersonRelationshipRow> {
  final Value<String> id;
  final Value<String> fromPersonId;
  final Value<String> toPersonId;
  final Value<String> relationshipType;
  final Value<int> effectiveFromUtcUs;
  final Value<int?> effectiveToUtcUs;
  final Value<String?> note;
  final Value<int> createdAtUtcUs;
  final Value<int> updatedAtUtcUs;
  final Value<int> rowid;
  const PersonRelationshipsCompanion({
    this.id = const Value.absent(),
    this.fromPersonId = const Value.absent(),
    this.toPersonId = const Value.absent(),
    this.relationshipType = const Value.absent(),
    this.effectiveFromUtcUs = const Value.absent(),
    this.effectiveToUtcUs = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAtUtcUs = const Value.absent(),
    this.updatedAtUtcUs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonRelationshipsCompanion.insert({
    required String id,
    required String fromPersonId,
    required String toPersonId,
    required String relationshipType,
    required int effectiveFromUtcUs,
    this.effectiveToUtcUs = const Value.absent(),
    this.note = const Value.absent(),
    required int createdAtUtcUs,
    required int updatedAtUtcUs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fromPersonId = Value(fromPersonId),
       toPersonId = Value(toPersonId),
       relationshipType = Value(relationshipType),
       effectiveFromUtcUs = Value(effectiveFromUtcUs),
       createdAtUtcUs = Value(createdAtUtcUs),
       updatedAtUtcUs = Value(updatedAtUtcUs);
  static Insertable<PersonRelationshipRow> custom({
    Expression<String>? id,
    Expression<String>? fromPersonId,
    Expression<String>? toPersonId,
    Expression<String>? relationshipType,
    Expression<int>? effectiveFromUtcUs,
    Expression<int>? effectiveToUtcUs,
    Expression<String>? note,
    Expression<int>? createdAtUtcUs,
    Expression<int>? updatedAtUtcUs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fromPersonId != null) 'from_person_id': fromPersonId,
      if (toPersonId != null) 'to_person_id': toPersonId,
      if (relationshipType != null) 'relationship_type': relationshipType,
      if (effectiveFromUtcUs != null)
        'effective_from_utc_us': effectiveFromUtcUs,
      if (effectiveToUtcUs != null) 'effective_to_utc_us': effectiveToUtcUs,
      if (note != null) 'note': note,
      if (createdAtUtcUs != null) 'created_at_utc_us': createdAtUtcUs,
      if (updatedAtUtcUs != null) 'updated_at_utc_us': updatedAtUtcUs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonRelationshipsCompanion copyWith({
    Value<String>? id,
    Value<String>? fromPersonId,
    Value<String>? toPersonId,
    Value<String>? relationshipType,
    Value<int>? effectiveFromUtcUs,
    Value<int?>? effectiveToUtcUs,
    Value<String?>? note,
    Value<int>? createdAtUtcUs,
    Value<int>? updatedAtUtcUs,
    Value<int>? rowid,
  }) {
    return PersonRelationshipsCompanion(
      id: id ?? this.id,
      fromPersonId: fromPersonId ?? this.fromPersonId,
      toPersonId: toPersonId ?? this.toPersonId,
      relationshipType: relationshipType ?? this.relationshipType,
      effectiveFromUtcUs: effectiveFromUtcUs ?? this.effectiveFromUtcUs,
      effectiveToUtcUs: effectiveToUtcUs ?? this.effectiveToUtcUs,
      note: note ?? this.note,
      createdAtUtcUs: createdAtUtcUs ?? this.createdAtUtcUs,
      updatedAtUtcUs: updatedAtUtcUs ?? this.updatedAtUtcUs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fromPersonId.present) {
      map['from_person_id'] = Variable<String>(fromPersonId.value);
    }
    if (toPersonId.present) {
      map['to_person_id'] = Variable<String>(toPersonId.value);
    }
    if (relationshipType.present) {
      map['relationship_type'] = Variable<String>(relationshipType.value);
    }
    if (effectiveFromUtcUs.present) {
      map['effective_from_utc_us'] = Variable<int>(effectiveFromUtcUs.value);
    }
    if (effectiveToUtcUs.present) {
      map['effective_to_utc_us'] = Variable<int>(effectiveToUtcUs.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAtUtcUs.present) {
      map['created_at_utc_us'] = Variable<int>(createdAtUtcUs.value);
    }
    if (updatedAtUtcUs.present) {
      map['updated_at_utc_us'] = Variable<int>(updatedAtUtcUs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonRelationshipsCompanion(')
          ..write('id: $id, ')
          ..write('fromPersonId: $fromPersonId, ')
          ..write('toPersonId: $toPersonId, ')
          ..write('relationshipType: $relationshipType, ')
          ..write('effectiveFromUtcUs: $effectiveFromUtcUs, ')
          ..write('effectiveToUtcUs: $effectiveToUtcUs, ')
          ..write('note: $note, ')
          ..write('createdAtUtcUs: $createdAtUtcUs, ')
          ..write('updatedAtUtcUs: $updatedAtUtcUs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonBirthProfilesTable extends PersonBirthProfiles
    with TableInfo<$PersonBirthProfilesTable, PersonBirthProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonBirthProfilesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES persons (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _revisionNumberMeta = const VerificationMeta(
    'revisionNumber',
  );
  @override
  late final GeneratedColumn<int> revisionNumber = GeneratedColumn<int>(
    'revision_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<String> birthDate = GeneratedColumn<String>(
    'birth_date',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 10),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthDatePrecisionMeta =
      const VerificationMeta('birthDatePrecision');
  @override
  late final GeneratedColumn<String> birthDatePrecision =
      GeneratedColumn<String>(
        'birth_date_precision',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 20,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _birthTimeMeta = const VerificationMeta(
    'birthTime',
  );
  @override
  late final GeneratedColumn<String> birthTime = GeneratedColumn<String>(
    'birth_time',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 5),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthTimePrecisionMeta =
      const VerificationMeta('birthTimePrecision');
  @override
  late final GeneratedColumn<String> birthTimePrecision =
      GeneratedColumn<String>(
        'birth_time_precision',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 20,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _birthplaceLabelMeta = const VerificationMeta(
    'birthplaceLabel',
  );
  @override
  late final GeneratedColumn<String> birthplaceLabel = GeneratedColumn<String>(
    'birthplace_label',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 300),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeZoneIdMeta = const VerificationMeta(
    'timeZoneId',
  );
  @override
  late final GeneratedColumn<String> timeZoneId = GeneratedColumn<String>(
    'time_zone_id',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 120),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _utcOffsetMinutesAtBirthMeta =
      const VerificationMeta('utcOffsetMinutesAtBirth');
  @override
  late final GeneratedColumn<int> utcOffsetMinutesAtBirth =
      GeneratedColumn<int>(
        'utc_offset_minutes_at_birth',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _calendarSystemMeta = const VerificationMeta(
    'calendarSystem',
  );
  @override
  late final GeneratedColumn<String> calendarSystem = GeneratedColumn<String>(
    'calendar_system',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isLeapMonthMeta = const VerificationMeta(
    'isLeapMonth',
  );
  @override
  late final GeneratedColumn<bool> isLeapMonth = GeneratedColumn<bool>(
    'is_leap_month',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_leap_month" IN (0, 1))',
    ),
  );
  static const VerificationMeta _sourceNoteMeta = const VerificationMeta(
    'sourceNote',
  );
  @override
  late final GeneratedColumn<String> sourceNote = GeneratedColumn<String>(
    'source_note',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 2000),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _verificationStateMeta = const VerificationMeta(
    'verificationState',
  );
  @override
  late final GeneratedColumn<String> verificationState =
      GeneratedColumn<String>(
        'verification_state',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 20,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _supersedesBirthProfileIdMeta =
      const VerificationMeta('supersedesBirthProfileId');
  @override
  late final GeneratedColumn<String> supersedesBirthProfileId =
      GeneratedColumn<String>(
        'supersedes_birth_profile_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES person_birth_profiles (id) ON DELETE SET NULL',
        ),
      );
  static const VerificationMeta _supersededAtUtcUsMeta = const VerificationMeta(
    'supersededAtUtcUs',
  );
  @override
  late final GeneratedColumn<int> supersededAtUtcUs = GeneratedColumn<int>(
    'superseded_at_utc_us',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtUtcUsMeta = const VerificationMeta(
    'createdAtUtcUs',
  );
  @override
  late final GeneratedColumn<int> createdAtUtcUs = GeneratedColumn<int>(
    'created_at_utc_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    personId,
    revisionNumber,
    birthDate,
    birthDatePrecision,
    birthTime,
    birthTimePrecision,
    birthplaceLabel,
    timeZoneId,
    utcOffsetMinutesAtBirth,
    calendarSystem,
    isLeapMonth,
    sourceNote,
    verificationState,
    supersedesBirthProfileId,
    supersededAtUtcUs,
    createdAtUtcUs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'person_birth_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonBirthProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('revision_number')) {
      context.handle(
        _revisionNumberMeta,
        revisionNumber.isAcceptableOrUnknown(
          data['revision_number']!,
          _revisionNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_revisionNumberMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('birth_date_precision')) {
      context.handle(
        _birthDatePrecisionMeta,
        birthDatePrecision.isAcceptableOrUnknown(
          data['birth_date_precision']!,
          _birthDatePrecisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_birthDatePrecisionMeta);
    }
    if (data.containsKey('birth_time')) {
      context.handle(
        _birthTimeMeta,
        birthTime.isAcceptableOrUnknown(data['birth_time']!, _birthTimeMeta),
      );
    }
    if (data.containsKey('birth_time_precision')) {
      context.handle(
        _birthTimePrecisionMeta,
        birthTimePrecision.isAcceptableOrUnknown(
          data['birth_time_precision']!,
          _birthTimePrecisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_birthTimePrecisionMeta);
    }
    if (data.containsKey('birthplace_label')) {
      context.handle(
        _birthplaceLabelMeta,
        birthplaceLabel.isAcceptableOrUnknown(
          data['birthplace_label']!,
          _birthplaceLabelMeta,
        ),
      );
    }
    if (data.containsKey('time_zone_id')) {
      context.handle(
        _timeZoneIdMeta,
        timeZoneId.isAcceptableOrUnknown(
          data['time_zone_id']!,
          _timeZoneIdMeta,
        ),
      );
    }
    if (data.containsKey('utc_offset_minutes_at_birth')) {
      context.handle(
        _utcOffsetMinutesAtBirthMeta,
        utcOffsetMinutesAtBirth.isAcceptableOrUnknown(
          data['utc_offset_minutes_at_birth']!,
          _utcOffsetMinutesAtBirthMeta,
        ),
      );
    }
    if (data.containsKey('calendar_system')) {
      context.handle(
        _calendarSystemMeta,
        calendarSystem.isAcceptableOrUnknown(
          data['calendar_system']!,
          _calendarSystemMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calendarSystemMeta);
    }
    if (data.containsKey('is_leap_month')) {
      context.handle(
        _isLeapMonthMeta,
        isLeapMonth.isAcceptableOrUnknown(
          data['is_leap_month']!,
          _isLeapMonthMeta,
        ),
      );
    }
    if (data.containsKey('source_note')) {
      context.handle(
        _sourceNoteMeta,
        sourceNote.isAcceptableOrUnknown(data['source_note']!, _sourceNoteMeta),
      );
    }
    if (data.containsKey('verification_state')) {
      context.handle(
        _verificationStateMeta,
        verificationState.isAcceptableOrUnknown(
          data['verification_state']!,
          _verificationStateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_verificationStateMeta);
    }
    if (data.containsKey('supersedes_birth_profile_id')) {
      context.handle(
        _supersedesBirthProfileIdMeta,
        supersedesBirthProfileId.isAcceptableOrUnknown(
          data['supersedes_birth_profile_id']!,
          _supersedesBirthProfileIdMeta,
        ),
      );
    }
    if (data.containsKey('superseded_at_utc_us')) {
      context.handle(
        _supersededAtUtcUsMeta,
        supersededAtUtcUs.isAcceptableOrUnknown(
          data['superseded_at_utc_us']!,
          _supersededAtUtcUsMeta,
        ),
      );
    }
    if (data.containsKey('created_at_utc_us')) {
      context.handle(
        _createdAtUtcUsMeta,
        createdAtUtcUs.isAcceptableOrUnknown(
          data['created_at_utc_us']!,
          _createdAtUtcUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcUsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {personId, revisionNumber},
  ];
  @override
  PersonBirthProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonBirthProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      )!,
      revisionNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision_number'],
      )!,
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birth_date'],
      ),
      birthDatePrecision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birth_date_precision'],
      )!,
      birthTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birth_time'],
      ),
      birthTimePrecision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birth_time_precision'],
      )!,
      birthplaceLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birthplace_label'],
      ),
      timeZoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_zone_id'],
      ),
      utcOffsetMinutesAtBirth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}utc_offset_minutes_at_birth'],
      ),
      calendarSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calendar_system'],
      )!,
      isLeapMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_leap_month'],
      ),
      sourceNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_note'],
      ),
      verificationState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verification_state'],
      )!,
      supersedesBirthProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supersedes_birth_profile_id'],
      ),
      supersededAtUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}superseded_at_utc_us'],
      ),
      createdAtUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_us'],
      )!,
    );
  }

  @override
  $PersonBirthProfilesTable createAlias(String alias) {
    return $PersonBirthProfilesTable(attachedDatabase, alias);
  }
}

class PersonBirthProfileRow extends DataClass
    implements Insertable<PersonBirthProfileRow> {
  final String id;
  final String personId;
  final int revisionNumber;
  final String? birthDate;
  final String birthDatePrecision;
  final String? birthTime;
  final String birthTimePrecision;
  final String? birthplaceLabel;
  final String? timeZoneId;
  final int? utcOffsetMinutesAtBirth;
  final String calendarSystem;
  final bool? isLeapMonth;
  final String? sourceNote;
  final String verificationState;
  final String? supersedesBirthProfileId;
  final int? supersededAtUtcUs;
  final int createdAtUtcUs;
  const PersonBirthProfileRow({
    required this.id,
    required this.personId,
    required this.revisionNumber,
    this.birthDate,
    required this.birthDatePrecision,
    this.birthTime,
    required this.birthTimePrecision,
    this.birthplaceLabel,
    this.timeZoneId,
    this.utcOffsetMinutesAtBirth,
    required this.calendarSystem,
    this.isLeapMonth,
    this.sourceNote,
    required this.verificationState,
    this.supersedesBirthProfileId,
    this.supersededAtUtcUs,
    required this.createdAtUtcUs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['person_id'] = Variable<String>(personId);
    map['revision_number'] = Variable<int>(revisionNumber);
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<String>(birthDate);
    }
    map['birth_date_precision'] = Variable<String>(birthDatePrecision);
    if (!nullToAbsent || birthTime != null) {
      map['birth_time'] = Variable<String>(birthTime);
    }
    map['birth_time_precision'] = Variable<String>(birthTimePrecision);
    if (!nullToAbsent || birthplaceLabel != null) {
      map['birthplace_label'] = Variable<String>(birthplaceLabel);
    }
    if (!nullToAbsent || timeZoneId != null) {
      map['time_zone_id'] = Variable<String>(timeZoneId);
    }
    if (!nullToAbsent || utcOffsetMinutesAtBirth != null) {
      map['utc_offset_minutes_at_birth'] = Variable<int>(
        utcOffsetMinutesAtBirth,
      );
    }
    map['calendar_system'] = Variable<String>(calendarSystem);
    if (!nullToAbsent || isLeapMonth != null) {
      map['is_leap_month'] = Variable<bool>(isLeapMonth);
    }
    if (!nullToAbsent || sourceNote != null) {
      map['source_note'] = Variable<String>(sourceNote);
    }
    map['verification_state'] = Variable<String>(verificationState);
    if (!nullToAbsent || supersedesBirthProfileId != null) {
      map['supersedes_birth_profile_id'] = Variable<String>(
        supersedesBirthProfileId,
      );
    }
    if (!nullToAbsent || supersededAtUtcUs != null) {
      map['superseded_at_utc_us'] = Variable<int>(supersededAtUtcUs);
    }
    map['created_at_utc_us'] = Variable<int>(createdAtUtcUs);
    return map;
  }

  PersonBirthProfilesCompanion toCompanion(bool nullToAbsent) {
    return PersonBirthProfilesCompanion(
      id: Value(id),
      personId: Value(personId),
      revisionNumber: Value(revisionNumber),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      birthDatePrecision: Value(birthDatePrecision),
      birthTime: birthTime == null && nullToAbsent
          ? const Value.absent()
          : Value(birthTime),
      birthTimePrecision: Value(birthTimePrecision),
      birthplaceLabel: birthplaceLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(birthplaceLabel),
      timeZoneId: timeZoneId == null && nullToAbsent
          ? const Value.absent()
          : Value(timeZoneId),
      utcOffsetMinutesAtBirth: utcOffsetMinutesAtBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(utcOffsetMinutesAtBirth),
      calendarSystem: Value(calendarSystem),
      isLeapMonth: isLeapMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(isLeapMonth),
      sourceNote: sourceNote == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceNote),
      verificationState: Value(verificationState),
      supersedesBirthProfileId: supersedesBirthProfileId == null && nullToAbsent
          ? const Value.absent()
          : Value(supersedesBirthProfileId),
      supersededAtUtcUs: supersededAtUtcUs == null && nullToAbsent
          ? const Value.absent()
          : Value(supersededAtUtcUs),
      createdAtUtcUs: Value(createdAtUtcUs),
    );
  }

  factory PersonBirthProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonBirthProfileRow(
      id: serializer.fromJson<String>(json['id']),
      personId: serializer.fromJson<String>(json['personId']),
      revisionNumber: serializer.fromJson<int>(json['revisionNumber']),
      birthDate: serializer.fromJson<String?>(json['birthDate']),
      birthDatePrecision: serializer.fromJson<String>(
        json['birthDatePrecision'],
      ),
      birthTime: serializer.fromJson<String?>(json['birthTime']),
      birthTimePrecision: serializer.fromJson<String>(
        json['birthTimePrecision'],
      ),
      birthplaceLabel: serializer.fromJson<String?>(json['birthplaceLabel']),
      timeZoneId: serializer.fromJson<String?>(json['timeZoneId']),
      utcOffsetMinutesAtBirth: serializer.fromJson<int?>(
        json['utcOffsetMinutesAtBirth'],
      ),
      calendarSystem: serializer.fromJson<String>(json['calendarSystem']),
      isLeapMonth: serializer.fromJson<bool?>(json['isLeapMonth']),
      sourceNote: serializer.fromJson<String?>(json['sourceNote']),
      verificationState: serializer.fromJson<String>(json['verificationState']),
      supersedesBirthProfileId: serializer.fromJson<String?>(
        json['supersedesBirthProfileId'],
      ),
      supersededAtUtcUs: serializer.fromJson<int?>(json['supersededAtUtcUs']),
      createdAtUtcUs: serializer.fromJson<int>(json['createdAtUtcUs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'personId': serializer.toJson<String>(personId),
      'revisionNumber': serializer.toJson<int>(revisionNumber),
      'birthDate': serializer.toJson<String?>(birthDate),
      'birthDatePrecision': serializer.toJson<String>(birthDatePrecision),
      'birthTime': serializer.toJson<String?>(birthTime),
      'birthTimePrecision': serializer.toJson<String>(birthTimePrecision),
      'birthplaceLabel': serializer.toJson<String?>(birthplaceLabel),
      'timeZoneId': serializer.toJson<String?>(timeZoneId),
      'utcOffsetMinutesAtBirth': serializer.toJson<int?>(
        utcOffsetMinutesAtBirth,
      ),
      'calendarSystem': serializer.toJson<String>(calendarSystem),
      'isLeapMonth': serializer.toJson<bool?>(isLeapMonth),
      'sourceNote': serializer.toJson<String?>(sourceNote),
      'verificationState': serializer.toJson<String>(verificationState),
      'supersedesBirthProfileId': serializer.toJson<String?>(
        supersedesBirthProfileId,
      ),
      'supersededAtUtcUs': serializer.toJson<int?>(supersededAtUtcUs),
      'createdAtUtcUs': serializer.toJson<int>(createdAtUtcUs),
    };
  }

  PersonBirthProfileRow copyWith({
    String? id,
    String? personId,
    int? revisionNumber,
    Value<String?> birthDate = const Value.absent(),
    String? birthDatePrecision,
    Value<String?> birthTime = const Value.absent(),
    String? birthTimePrecision,
    Value<String?> birthplaceLabel = const Value.absent(),
    Value<String?> timeZoneId = const Value.absent(),
    Value<int?> utcOffsetMinutesAtBirth = const Value.absent(),
    String? calendarSystem,
    Value<bool?> isLeapMonth = const Value.absent(),
    Value<String?> sourceNote = const Value.absent(),
    String? verificationState,
    Value<String?> supersedesBirthProfileId = const Value.absent(),
    Value<int?> supersededAtUtcUs = const Value.absent(),
    int? createdAtUtcUs,
  }) => PersonBirthProfileRow(
    id: id ?? this.id,
    personId: personId ?? this.personId,
    revisionNumber: revisionNumber ?? this.revisionNumber,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    birthDatePrecision: birthDatePrecision ?? this.birthDatePrecision,
    birthTime: birthTime.present ? birthTime.value : this.birthTime,
    birthTimePrecision: birthTimePrecision ?? this.birthTimePrecision,
    birthplaceLabel: birthplaceLabel.present
        ? birthplaceLabel.value
        : this.birthplaceLabel,
    timeZoneId: timeZoneId.present ? timeZoneId.value : this.timeZoneId,
    utcOffsetMinutesAtBirth: utcOffsetMinutesAtBirth.present
        ? utcOffsetMinutesAtBirth.value
        : this.utcOffsetMinutesAtBirth,
    calendarSystem: calendarSystem ?? this.calendarSystem,
    isLeapMonth: isLeapMonth.present ? isLeapMonth.value : this.isLeapMonth,
    sourceNote: sourceNote.present ? sourceNote.value : this.sourceNote,
    verificationState: verificationState ?? this.verificationState,
    supersedesBirthProfileId: supersedesBirthProfileId.present
        ? supersedesBirthProfileId.value
        : this.supersedesBirthProfileId,
    supersededAtUtcUs: supersededAtUtcUs.present
        ? supersededAtUtcUs.value
        : this.supersededAtUtcUs,
    createdAtUtcUs: createdAtUtcUs ?? this.createdAtUtcUs,
  );
  PersonBirthProfileRow copyWithCompanion(PersonBirthProfilesCompanion data) {
    return PersonBirthProfileRow(
      id: data.id.present ? data.id.value : this.id,
      personId: data.personId.present ? data.personId.value : this.personId,
      revisionNumber: data.revisionNumber.present
          ? data.revisionNumber.value
          : this.revisionNumber,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      birthDatePrecision: data.birthDatePrecision.present
          ? data.birthDatePrecision.value
          : this.birthDatePrecision,
      birthTime: data.birthTime.present ? data.birthTime.value : this.birthTime,
      birthTimePrecision: data.birthTimePrecision.present
          ? data.birthTimePrecision.value
          : this.birthTimePrecision,
      birthplaceLabel: data.birthplaceLabel.present
          ? data.birthplaceLabel.value
          : this.birthplaceLabel,
      timeZoneId: data.timeZoneId.present
          ? data.timeZoneId.value
          : this.timeZoneId,
      utcOffsetMinutesAtBirth: data.utcOffsetMinutesAtBirth.present
          ? data.utcOffsetMinutesAtBirth.value
          : this.utcOffsetMinutesAtBirth,
      calendarSystem: data.calendarSystem.present
          ? data.calendarSystem.value
          : this.calendarSystem,
      isLeapMonth: data.isLeapMonth.present
          ? data.isLeapMonth.value
          : this.isLeapMonth,
      sourceNote: data.sourceNote.present
          ? data.sourceNote.value
          : this.sourceNote,
      verificationState: data.verificationState.present
          ? data.verificationState.value
          : this.verificationState,
      supersedesBirthProfileId: data.supersedesBirthProfileId.present
          ? data.supersedesBirthProfileId.value
          : this.supersedesBirthProfileId,
      supersededAtUtcUs: data.supersededAtUtcUs.present
          ? data.supersededAtUtcUs.value
          : this.supersededAtUtcUs,
      createdAtUtcUs: data.createdAtUtcUs.present
          ? data.createdAtUtcUs.value
          : this.createdAtUtcUs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonBirthProfileRow(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('revisionNumber: $revisionNumber, ')
          ..write('birthDate: $birthDate, ')
          ..write('birthDatePrecision: $birthDatePrecision, ')
          ..write('birthTime: $birthTime, ')
          ..write('birthTimePrecision: $birthTimePrecision, ')
          ..write('birthplaceLabel: $birthplaceLabel, ')
          ..write('timeZoneId: $timeZoneId, ')
          ..write('utcOffsetMinutesAtBirth: $utcOffsetMinutesAtBirth, ')
          ..write('calendarSystem: $calendarSystem, ')
          ..write('isLeapMonth: $isLeapMonth, ')
          ..write('sourceNote: $sourceNote, ')
          ..write('verificationState: $verificationState, ')
          ..write('supersedesBirthProfileId: $supersedesBirthProfileId, ')
          ..write('supersededAtUtcUs: $supersededAtUtcUs, ')
          ..write('createdAtUtcUs: $createdAtUtcUs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    personId,
    revisionNumber,
    birthDate,
    birthDatePrecision,
    birthTime,
    birthTimePrecision,
    birthplaceLabel,
    timeZoneId,
    utcOffsetMinutesAtBirth,
    calendarSystem,
    isLeapMonth,
    sourceNote,
    verificationState,
    supersedesBirthProfileId,
    supersededAtUtcUs,
    createdAtUtcUs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonBirthProfileRow &&
          other.id == this.id &&
          other.personId == this.personId &&
          other.revisionNumber == this.revisionNumber &&
          other.birthDate == this.birthDate &&
          other.birthDatePrecision == this.birthDatePrecision &&
          other.birthTime == this.birthTime &&
          other.birthTimePrecision == this.birthTimePrecision &&
          other.birthplaceLabel == this.birthplaceLabel &&
          other.timeZoneId == this.timeZoneId &&
          other.utcOffsetMinutesAtBirth == this.utcOffsetMinutesAtBirth &&
          other.calendarSystem == this.calendarSystem &&
          other.isLeapMonth == this.isLeapMonth &&
          other.sourceNote == this.sourceNote &&
          other.verificationState == this.verificationState &&
          other.supersedesBirthProfileId == this.supersedesBirthProfileId &&
          other.supersededAtUtcUs == this.supersededAtUtcUs &&
          other.createdAtUtcUs == this.createdAtUtcUs);
}

class PersonBirthProfilesCompanion
    extends UpdateCompanion<PersonBirthProfileRow> {
  final Value<String> id;
  final Value<String> personId;
  final Value<int> revisionNumber;
  final Value<String?> birthDate;
  final Value<String> birthDatePrecision;
  final Value<String?> birthTime;
  final Value<String> birthTimePrecision;
  final Value<String?> birthplaceLabel;
  final Value<String?> timeZoneId;
  final Value<int?> utcOffsetMinutesAtBirth;
  final Value<String> calendarSystem;
  final Value<bool?> isLeapMonth;
  final Value<String?> sourceNote;
  final Value<String> verificationState;
  final Value<String?> supersedesBirthProfileId;
  final Value<int?> supersededAtUtcUs;
  final Value<int> createdAtUtcUs;
  final Value<int> rowid;
  const PersonBirthProfilesCompanion({
    this.id = const Value.absent(),
    this.personId = const Value.absent(),
    this.revisionNumber = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.birthDatePrecision = const Value.absent(),
    this.birthTime = const Value.absent(),
    this.birthTimePrecision = const Value.absent(),
    this.birthplaceLabel = const Value.absent(),
    this.timeZoneId = const Value.absent(),
    this.utcOffsetMinutesAtBirth = const Value.absent(),
    this.calendarSystem = const Value.absent(),
    this.isLeapMonth = const Value.absent(),
    this.sourceNote = const Value.absent(),
    this.verificationState = const Value.absent(),
    this.supersedesBirthProfileId = const Value.absent(),
    this.supersededAtUtcUs = const Value.absent(),
    this.createdAtUtcUs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonBirthProfilesCompanion.insert({
    required String id,
    required String personId,
    required int revisionNumber,
    this.birthDate = const Value.absent(),
    required String birthDatePrecision,
    this.birthTime = const Value.absent(),
    required String birthTimePrecision,
    this.birthplaceLabel = const Value.absent(),
    this.timeZoneId = const Value.absent(),
    this.utcOffsetMinutesAtBirth = const Value.absent(),
    required String calendarSystem,
    this.isLeapMonth = const Value.absent(),
    this.sourceNote = const Value.absent(),
    required String verificationState,
    this.supersedesBirthProfileId = const Value.absent(),
    this.supersededAtUtcUs = const Value.absent(),
    required int createdAtUtcUs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       personId = Value(personId),
       revisionNumber = Value(revisionNumber),
       birthDatePrecision = Value(birthDatePrecision),
       birthTimePrecision = Value(birthTimePrecision),
       calendarSystem = Value(calendarSystem),
       verificationState = Value(verificationState),
       createdAtUtcUs = Value(createdAtUtcUs);
  static Insertable<PersonBirthProfileRow> custom({
    Expression<String>? id,
    Expression<String>? personId,
    Expression<int>? revisionNumber,
    Expression<String>? birthDate,
    Expression<String>? birthDatePrecision,
    Expression<String>? birthTime,
    Expression<String>? birthTimePrecision,
    Expression<String>? birthplaceLabel,
    Expression<String>? timeZoneId,
    Expression<int>? utcOffsetMinutesAtBirth,
    Expression<String>? calendarSystem,
    Expression<bool>? isLeapMonth,
    Expression<String>? sourceNote,
    Expression<String>? verificationState,
    Expression<String>? supersedesBirthProfileId,
    Expression<int>? supersededAtUtcUs,
    Expression<int>? createdAtUtcUs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personId != null) 'person_id': personId,
      if (revisionNumber != null) 'revision_number': revisionNumber,
      if (birthDate != null) 'birth_date': birthDate,
      if (birthDatePrecision != null)
        'birth_date_precision': birthDatePrecision,
      if (birthTime != null) 'birth_time': birthTime,
      if (birthTimePrecision != null)
        'birth_time_precision': birthTimePrecision,
      if (birthplaceLabel != null) 'birthplace_label': birthplaceLabel,
      if (timeZoneId != null) 'time_zone_id': timeZoneId,
      if (utcOffsetMinutesAtBirth != null)
        'utc_offset_minutes_at_birth': utcOffsetMinutesAtBirth,
      if (calendarSystem != null) 'calendar_system': calendarSystem,
      if (isLeapMonth != null) 'is_leap_month': isLeapMonth,
      if (sourceNote != null) 'source_note': sourceNote,
      if (verificationState != null) 'verification_state': verificationState,
      if (supersedesBirthProfileId != null)
        'supersedes_birth_profile_id': supersedesBirthProfileId,
      if (supersededAtUtcUs != null) 'superseded_at_utc_us': supersededAtUtcUs,
      if (createdAtUtcUs != null) 'created_at_utc_us': createdAtUtcUs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonBirthProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? personId,
    Value<int>? revisionNumber,
    Value<String?>? birthDate,
    Value<String>? birthDatePrecision,
    Value<String?>? birthTime,
    Value<String>? birthTimePrecision,
    Value<String?>? birthplaceLabel,
    Value<String?>? timeZoneId,
    Value<int?>? utcOffsetMinutesAtBirth,
    Value<String>? calendarSystem,
    Value<bool?>? isLeapMonth,
    Value<String?>? sourceNote,
    Value<String>? verificationState,
    Value<String?>? supersedesBirthProfileId,
    Value<int?>? supersededAtUtcUs,
    Value<int>? createdAtUtcUs,
    Value<int>? rowid,
  }) {
    return PersonBirthProfilesCompanion(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      revisionNumber: revisionNumber ?? this.revisionNumber,
      birthDate: birthDate ?? this.birthDate,
      birthDatePrecision: birthDatePrecision ?? this.birthDatePrecision,
      birthTime: birthTime ?? this.birthTime,
      birthTimePrecision: birthTimePrecision ?? this.birthTimePrecision,
      birthplaceLabel: birthplaceLabel ?? this.birthplaceLabel,
      timeZoneId: timeZoneId ?? this.timeZoneId,
      utcOffsetMinutesAtBirth:
          utcOffsetMinutesAtBirth ?? this.utcOffsetMinutesAtBirth,
      calendarSystem: calendarSystem ?? this.calendarSystem,
      isLeapMonth: isLeapMonth ?? this.isLeapMonth,
      sourceNote: sourceNote ?? this.sourceNote,
      verificationState: verificationState ?? this.verificationState,
      supersedesBirthProfileId:
          supersedesBirthProfileId ?? this.supersedesBirthProfileId,
      supersededAtUtcUs: supersededAtUtcUs ?? this.supersededAtUtcUs,
      createdAtUtcUs: createdAtUtcUs ?? this.createdAtUtcUs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (revisionNumber.present) {
      map['revision_number'] = Variable<int>(revisionNumber.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<String>(birthDate.value);
    }
    if (birthDatePrecision.present) {
      map['birth_date_precision'] = Variable<String>(birthDatePrecision.value);
    }
    if (birthTime.present) {
      map['birth_time'] = Variable<String>(birthTime.value);
    }
    if (birthTimePrecision.present) {
      map['birth_time_precision'] = Variable<String>(birthTimePrecision.value);
    }
    if (birthplaceLabel.present) {
      map['birthplace_label'] = Variable<String>(birthplaceLabel.value);
    }
    if (timeZoneId.present) {
      map['time_zone_id'] = Variable<String>(timeZoneId.value);
    }
    if (utcOffsetMinutesAtBirth.present) {
      map['utc_offset_minutes_at_birth'] = Variable<int>(
        utcOffsetMinutesAtBirth.value,
      );
    }
    if (calendarSystem.present) {
      map['calendar_system'] = Variable<String>(calendarSystem.value);
    }
    if (isLeapMonth.present) {
      map['is_leap_month'] = Variable<bool>(isLeapMonth.value);
    }
    if (sourceNote.present) {
      map['source_note'] = Variable<String>(sourceNote.value);
    }
    if (verificationState.present) {
      map['verification_state'] = Variable<String>(verificationState.value);
    }
    if (supersedesBirthProfileId.present) {
      map['supersedes_birth_profile_id'] = Variable<String>(
        supersedesBirthProfileId.value,
      );
    }
    if (supersededAtUtcUs.present) {
      map['superseded_at_utc_us'] = Variable<int>(supersededAtUtcUs.value);
    }
    if (createdAtUtcUs.present) {
      map['created_at_utc_us'] = Variable<int>(createdAtUtcUs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonBirthProfilesCompanion(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('revisionNumber: $revisionNumber, ')
          ..write('birthDate: $birthDate, ')
          ..write('birthDatePrecision: $birthDatePrecision, ')
          ..write('birthTime: $birthTime, ')
          ..write('birthTimePrecision: $birthTimePrecision, ')
          ..write('birthplaceLabel: $birthplaceLabel, ')
          ..write('timeZoneId: $timeZoneId, ')
          ..write('utcOffsetMinutesAtBirth: $utcOffsetMinutesAtBirth, ')
          ..write('calendarSystem: $calendarSystem, ')
          ..write('isLeapMonth: $isLeapMonth, ')
          ..write('sourceNote: $sourceNote, ')
          ..write('verificationState: $verificationState, ')
          ..write('supersedesBirthProfileId: $supersedesBirthProfileId, ')
          ..write('supersededAtUtcUs: $supersededAtUtcUs, ')
          ..write('createdAtUtcUs: $createdAtUtcUs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EncountersTable extends Encounters
    with TableInfo<$EncountersTable, EncounterRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EncountersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES persons (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _occurredAtUtcUsMeta = const VerificationMeta(
    'occurredAtUtcUs',
  );
  @override
  late final GeneratedColumn<int> occurredAtUtcUs = GeneratedColumn<int>(
    'occurred_at_utc_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredPrecisionMeta = const VerificationMeta(
    'occurredPrecision',
  );
  @override
  late final GeneratedColumn<String> occurredPrecision =
      GeneratedColumn<String>(
        'occurred_precision',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 20,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _encounterTypeMeta = const VerificationMeta(
    'encounterType',
  );
  @override
  late final GeneratedColumn<String> encounterType = GeneratedColumn<String>(
    'encounter_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
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
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _followUpAtUtcUsMeta = const VerificationMeta(
    'followUpAtUtcUs',
  );
  @override
  late final GeneratedColumn<int> followUpAtUtcUs = GeneratedColumn<int>(
    'follow_up_at_utc_us',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archivedAtUtcUsMeta = const VerificationMeta(
    'archivedAtUtcUs',
  );
  @override
  late final GeneratedColumn<int> archivedAtUtcUs = GeneratedColumn<int>(
    'archived_at_utc_us',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtUtcUsMeta = const VerificationMeta(
    'createdAtUtcUs',
  );
  @override
  late final GeneratedColumn<int> createdAtUtcUs = GeneratedColumn<int>(
    'created_at_utc_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcUsMeta = const VerificationMeta(
    'updatedAtUtcUs',
  );
  @override
  late final GeneratedColumn<int> updatedAtUtcUs = GeneratedColumn<int>(
    'updated_at_utc_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    personId,
    occurredAtUtcUs,
    occurredPrecision,
    encounterType,
    title,
    summary,
    status,
    followUpAtUtcUs,
    archivedAtUtcUs,
    createdAtUtcUs,
    updatedAtUtcUs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'encounters';
  @override
  VerificationContext validateIntegrity(
    Insertable<EncounterRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('occurred_at_utc_us')) {
      context.handle(
        _occurredAtUtcUsMeta,
        occurredAtUtcUs.isAcceptableOrUnknown(
          data['occurred_at_utc_us']!,
          _occurredAtUtcUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurredAtUtcUsMeta);
    }
    if (data.containsKey('occurred_precision')) {
      context.handle(
        _occurredPrecisionMeta,
        occurredPrecision.isAcceptableOrUnknown(
          data['occurred_precision']!,
          _occurredPrecisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurredPrecisionMeta);
    }
    if (data.containsKey('encounter_type')) {
      context.handle(
        _encounterTypeMeta,
        encounterType.isAcceptableOrUnknown(
          data['encounter_type']!,
          _encounterTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encounterTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('follow_up_at_utc_us')) {
      context.handle(
        _followUpAtUtcUsMeta,
        followUpAtUtcUs.isAcceptableOrUnknown(
          data['follow_up_at_utc_us']!,
          _followUpAtUtcUsMeta,
        ),
      );
    }
    if (data.containsKey('archived_at_utc_us')) {
      context.handle(
        _archivedAtUtcUsMeta,
        archivedAtUtcUs.isAcceptableOrUnknown(
          data['archived_at_utc_us']!,
          _archivedAtUtcUsMeta,
        ),
      );
    }
    if (data.containsKey('created_at_utc_us')) {
      context.handle(
        _createdAtUtcUsMeta,
        createdAtUtcUs.isAcceptableOrUnknown(
          data['created_at_utc_us']!,
          _createdAtUtcUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcUsMeta);
    }
    if (data.containsKey('updated_at_utc_us')) {
      context.handle(
        _updatedAtUtcUsMeta,
        updatedAtUtcUs.isAcceptableOrUnknown(
          data['updated_at_utc_us']!,
          _updatedAtUtcUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcUsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EncounterRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EncounterRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      )!,
      occurredAtUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at_utc_us'],
      )!,
      occurredPrecision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurred_precision'],
      )!,
      encounterType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encounter_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      followUpAtUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}follow_up_at_utc_us'],
      ),
      archivedAtUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}archived_at_utc_us'],
      ),
      createdAtUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_us'],
      )!,
      updatedAtUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc_us'],
      )!,
    );
  }

  @override
  $EncountersTable createAlias(String alias) {
    return $EncountersTable(attachedDatabase, alias);
  }
}

class EncounterRow extends DataClass implements Insertable<EncounterRow> {
  final String id;
  final String personId;
  final int occurredAtUtcUs;
  final String occurredPrecision;
  final String encounterType;
  final String title;
  final String? summary;
  final String status;
  final int? followUpAtUtcUs;
  final int? archivedAtUtcUs;
  final int createdAtUtcUs;
  final int updatedAtUtcUs;
  const EncounterRow({
    required this.id,
    required this.personId,
    required this.occurredAtUtcUs,
    required this.occurredPrecision,
    required this.encounterType,
    required this.title,
    this.summary,
    required this.status,
    this.followUpAtUtcUs,
    this.archivedAtUtcUs,
    required this.createdAtUtcUs,
    required this.updatedAtUtcUs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['person_id'] = Variable<String>(personId);
    map['occurred_at_utc_us'] = Variable<int>(occurredAtUtcUs);
    map['occurred_precision'] = Variable<String>(occurredPrecision);
    map['encounter_type'] = Variable<String>(encounterType);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || followUpAtUtcUs != null) {
      map['follow_up_at_utc_us'] = Variable<int>(followUpAtUtcUs);
    }
    if (!nullToAbsent || archivedAtUtcUs != null) {
      map['archived_at_utc_us'] = Variable<int>(archivedAtUtcUs);
    }
    map['created_at_utc_us'] = Variable<int>(createdAtUtcUs);
    map['updated_at_utc_us'] = Variable<int>(updatedAtUtcUs);
    return map;
  }

  EncountersCompanion toCompanion(bool nullToAbsent) {
    return EncountersCompanion(
      id: Value(id),
      personId: Value(personId),
      occurredAtUtcUs: Value(occurredAtUtcUs),
      occurredPrecision: Value(occurredPrecision),
      encounterType: Value(encounterType),
      title: Value(title),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      status: Value(status),
      followUpAtUtcUs: followUpAtUtcUs == null && nullToAbsent
          ? const Value.absent()
          : Value(followUpAtUtcUs),
      archivedAtUtcUs: archivedAtUtcUs == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAtUtcUs),
      createdAtUtcUs: Value(createdAtUtcUs),
      updatedAtUtcUs: Value(updatedAtUtcUs),
    );
  }

  factory EncounterRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EncounterRow(
      id: serializer.fromJson<String>(json['id']),
      personId: serializer.fromJson<String>(json['personId']),
      occurredAtUtcUs: serializer.fromJson<int>(json['occurredAtUtcUs']),
      occurredPrecision: serializer.fromJson<String>(json['occurredPrecision']),
      encounterType: serializer.fromJson<String>(json['encounterType']),
      title: serializer.fromJson<String>(json['title']),
      summary: serializer.fromJson<String?>(json['summary']),
      status: serializer.fromJson<String>(json['status']),
      followUpAtUtcUs: serializer.fromJson<int?>(json['followUpAtUtcUs']),
      archivedAtUtcUs: serializer.fromJson<int?>(json['archivedAtUtcUs']),
      createdAtUtcUs: serializer.fromJson<int>(json['createdAtUtcUs']),
      updatedAtUtcUs: serializer.fromJson<int>(json['updatedAtUtcUs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'personId': serializer.toJson<String>(personId),
      'occurredAtUtcUs': serializer.toJson<int>(occurredAtUtcUs),
      'occurredPrecision': serializer.toJson<String>(occurredPrecision),
      'encounterType': serializer.toJson<String>(encounterType),
      'title': serializer.toJson<String>(title),
      'summary': serializer.toJson<String?>(summary),
      'status': serializer.toJson<String>(status),
      'followUpAtUtcUs': serializer.toJson<int?>(followUpAtUtcUs),
      'archivedAtUtcUs': serializer.toJson<int?>(archivedAtUtcUs),
      'createdAtUtcUs': serializer.toJson<int>(createdAtUtcUs),
      'updatedAtUtcUs': serializer.toJson<int>(updatedAtUtcUs),
    };
  }

  EncounterRow copyWith({
    String? id,
    String? personId,
    int? occurredAtUtcUs,
    String? occurredPrecision,
    String? encounterType,
    String? title,
    Value<String?> summary = const Value.absent(),
    String? status,
    Value<int?> followUpAtUtcUs = const Value.absent(),
    Value<int?> archivedAtUtcUs = const Value.absent(),
    int? createdAtUtcUs,
    int? updatedAtUtcUs,
  }) => EncounterRow(
    id: id ?? this.id,
    personId: personId ?? this.personId,
    occurredAtUtcUs: occurredAtUtcUs ?? this.occurredAtUtcUs,
    occurredPrecision: occurredPrecision ?? this.occurredPrecision,
    encounterType: encounterType ?? this.encounterType,
    title: title ?? this.title,
    summary: summary.present ? summary.value : this.summary,
    status: status ?? this.status,
    followUpAtUtcUs: followUpAtUtcUs.present
        ? followUpAtUtcUs.value
        : this.followUpAtUtcUs,
    archivedAtUtcUs: archivedAtUtcUs.present
        ? archivedAtUtcUs.value
        : this.archivedAtUtcUs,
    createdAtUtcUs: createdAtUtcUs ?? this.createdAtUtcUs,
    updatedAtUtcUs: updatedAtUtcUs ?? this.updatedAtUtcUs,
  );
  EncounterRow copyWithCompanion(EncountersCompanion data) {
    return EncounterRow(
      id: data.id.present ? data.id.value : this.id,
      personId: data.personId.present ? data.personId.value : this.personId,
      occurredAtUtcUs: data.occurredAtUtcUs.present
          ? data.occurredAtUtcUs.value
          : this.occurredAtUtcUs,
      occurredPrecision: data.occurredPrecision.present
          ? data.occurredPrecision.value
          : this.occurredPrecision,
      encounterType: data.encounterType.present
          ? data.encounterType.value
          : this.encounterType,
      title: data.title.present ? data.title.value : this.title,
      summary: data.summary.present ? data.summary.value : this.summary,
      status: data.status.present ? data.status.value : this.status,
      followUpAtUtcUs: data.followUpAtUtcUs.present
          ? data.followUpAtUtcUs.value
          : this.followUpAtUtcUs,
      archivedAtUtcUs: data.archivedAtUtcUs.present
          ? data.archivedAtUtcUs.value
          : this.archivedAtUtcUs,
      createdAtUtcUs: data.createdAtUtcUs.present
          ? data.createdAtUtcUs.value
          : this.createdAtUtcUs,
      updatedAtUtcUs: data.updatedAtUtcUs.present
          ? data.updatedAtUtcUs.value
          : this.updatedAtUtcUs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EncounterRow(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('occurredAtUtcUs: $occurredAtUtcUs, ')
          ..write('occurredPrecision: $occurredPrecision, ')
          ..write('encounterType: $encounterType, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('status: $status, ')
          ..write('followUpAtUtcUs: $followUpAtUtcUs, ')
          ..write('archivedAtUtcUs: $archivedAtUtcUs, ')
          ..write('createdAtUtcUs: $createdAtUtcUs, ')
          ..write('updatedAtUtcUs: $updatedAtUtcUs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    personId,
    occurredAtUtcUs,
    occurredPrecision,
    encounterType,
    title,
    summary,
    status,
    followUpAtUtcUs,
    archivedAtUtcUs,
    createdAtUtcUs,
    updatedAtUtcUs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EncounterRow &&
          other.id == this.id &&
          other.personId == this.personId &&
          other.occurredAtUtcUs == this.occurredAtUtcUs &&
          other.occurredPrecision == this.occurredPrecision &&
          other.encounterType == this.encounterType &&
          other.title == this.title &&
          other.summary == this.summary &&
          other.status == this.status &&
          other.followUpAtUtcUs == this.followUpAtUtcUs &&
          other.archivedAtUtcUs == this.archivedAtUtcUs &&
          other.createdAtUtcUs == this.createdAtUtcUs &&
          other.updatedAtUtcUs == this.updatedAtUtcUs);
}

class EncountersCompanion extends UpdateCompanion<EncounterRow> {
  final Value<String> id;
  final Value<String> personId;
  final Value<int> occurredAtUtcUs;
  final Value<String> occurredPrecision;
  final Value<String> encounterType;
  final Value<String> title;
  final Value<String?> summary;
  final Value<String> status;
  final Value<int?> followUpAtUtcUs;
  final Value<int?> archivedAtUtcUs;
  final Value<int> createdAtUtcUs;
  final Value<int> updatedAtUtcUs;
  final Value<int> rowid;
  const EncountersCompanion({
    this.id = const Value.absent(),
    this.personId = const Value.absent(),
    this.occurredAtUtcUs = const Value.absent(),
    this.occurredPrecision = const Value.absent(),
    this.encounterType = const Value.absent(),
    this.title = const Value.absent(),
    this.summary = const Value.absent(),
    this.status = const Value.absent(),
    this.followUpAtUtcUs = const Value.absent(),
    this.archivedAtUtcUs = const Value.absent(),
    this.createdAtUtcUs = const Value.absent(),
    this.updatedAtUtcUs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EncountersCompanion.insert({
    required String id,
    required String personId,
    required int occurredAtUtcUs,
    required String occurredPrecision,
    required String encounterType,
    required String title,
    this.summary = const Value.absent(),
    required String status,
    this.followUpAtUtcUs = const Value.absent(),
    this.archivedAtUtcUs = const Value.absent(),
    required int createdAtUtcUs,
    required int updatedAtUtcUs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       personId = Value(personId),
       occurredAtUtcUs = Value(occurredAtUtcUs),
       occurredPrecision = Value(occurredPrecision),
       encounterType = Value(encounterType),
       title = Value(title),
       status = Value(status),
       createdAtUtcUs = Value(createdAtUtcUs),
       updatedAtUtcUs = Value(updatedAtUtcUs);
  static Insertable<EncounterRow> custom({
    Expression<String>? id,
    Expression<String>? personId,
    Expression<int>? occurredAtUtcUs,
    Expression<String>? occurredPrecision,
    Expression<String>? encounterType,
    Expression<String>? title,
    Expression<String>? summary,
    Expression<String>? status,
    Expression<int>? followUpAtUtcUs,
    Expression<int>? archivedAtUtcUs,
    Expression<int>? createdAtUtcUs,
    Expression<int>? updatedAtUtcUs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personId != null) 'person_id': personId,
      if (occurredAtUtcUs != null) 'occurred_at_utc_us': occurredAtUtcUs,
      if (occurredPrecision != null) 'occurred_precision': occurredPrecision,
      if (encounterType != null) 'encounter_type': encounterType,
      if (title != null) 'title': title,
      if (summary != null) 'summary': summary,
      if (status != null) 'status': status,
      if (followUpAtUtcUs != null) 'follow_up_at_utc_us': followUpAtUtcUs,
      if (archivedAtUtcUs != null) 'archived_at_utc_us': archivedAtUtcUs,
      if (createdAtUtcUs != null) 'created_at_utc_us': createdAtUtcUs,
      if (updatedAtUtcUs != null) 'updated_at_utc_us': updatedAtUtcUs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EncountersCompanion copyWith({
    Value<String>? id,
    Value<String>? personId,
    Value<int>? occurredAtUtcUs,
    Value<String>? occurredPrecision,
    Value<String>? encounterType,
    Value<String>? title,
    Value<String?>? summary,
    Value<String>? status,
    Value<int?>? followUpAtUtcUs,
    Value<int?>? archivedAtUtcUs,
    Value<int>? createdAtUtcUs,
    Value<int>? updatedAtUtcUs,
    Value<int>? rowid,
  }) {
    return EncountersCompanion(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      occurredAtUtcUs: occurredAtUtcUs ?? this.occurredAtUtcUs,
      occurredPrecision: occurredPrecision ?? this.occurredPrecision,
      encounterType: encounterType ?? this.encounterType,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      status: status ?? this.status,
      followUpAtUtcUs: followUpAtUtcUs ?? this.followUpAtUtcUs,
      archivedAtUtcUs: archivedAtUtcUs ?? this.archivedAtUtcUs,
      createdAtUtcUs: createdAtUtcUs ?? this.createdAtUtcUs,
      updatedAtUtcUs: updatedAtUtcUs ?? this.updatedAtUtcUs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (occurredAtUtcUs.present) {
      map['occurred_at_utc_us'] = Variable<int>(occurredAtUtcUs.value);
    }
    if (occurredPrecision.present) {
      map['occurred_precision'] = Variable<String>(occurredPrecision.value);
    }
    if (encounterType.present) {
      map['encounter_type'] = Variable<String>(encounterType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (followUpAtUtcUs.present) {
      map['follow_up_at_utc_us'] = Variable<int>(followUpAtUtcUs.value);
    }
    if (archivedAtUtcUs.present) {
      map['archived_at_utc_us'] = Variable<int>(archivedAtUtcUs.value);
    }
    if (createdAtUtcUs.present) {
      map['created_at_utc_us'] = Variable<int>(createdAtUtcUs.value);
    }
    if (updatedAtUtcUs.present) {
      map['updated_at_utc_us'] = Variable<int>(updatedAtUtcUs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EncountersCompanion(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('occurredAtUtcUs: $occurredAtUtcUs, ')
          ..write('occurredPrecision: $occurredPrecision, ')
          ..write('encounterType: $encounterType, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('status: $status, ')
          ..write('followUpAtUtcUs: $followUpAtUtcUs, ')
          ..write('archivedAtUtcUs: $archivedAtUtcUs, ')
          ..write('createdAtUtcUs: $createdAtUtcUs, ')
          ..write('updatedAtUtcUs: $updatedAtUtcUs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EncounterNotesTable extends EncounterNotes
    with TableInfo<$EncounterNotesTable, EncounterNoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EncounterNotesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _encounterIdMeta = const VerificationMeta(
    'encounterId',
  );
  @override
  late final GeneratedColumn<String> encounterId = GeneratedColumn<String>(
    'encounter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES encounters (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _noteTypeMeta = const VerificationMeta(
    'noteType',
  );
  @override
  late final GeneratedColumn<String> noteType = GeneratedColumn<String>(
    'note_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 12000),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtUtcUsMeta = const VerificationMeta(
    'recordedAtUtcUs',
  );
  @override
  late final GeneratedColumn<int> recordedAtUtcUs = GeneratedColumn<int>(
    'recorded_at_utc_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcUsMeta = const VerificationMeta(
    'updatedAtUtcUs',
  );
  @override
  late final GeneratedColumn<int> updatedAtUtcUs = GeneratedColumn<int>(
    'updated_at_utc_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supersedesNoteIdMeta = const VerificationMeta(
    'supersedesNoteId',
  );
  @override
  late final GeneratedColumn<String> supersedesNoteId = GeneratedColumn<String>(
    'supersedes_note_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES encounter_notes (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _supersededAtUtcUsMeta = const VerificationMeta(
    'supersededAtUtcUs',
  );
  @override
  late final GeneratedColumn<int> supersededAtUtcUs = GeneratedColumn<int>(
    'superseded_at_utc_us',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _redactedAtUtcUsMeta = const VerificationMeta(
    'redactedAtUtcUs',
  );
  @override
  late final GeneratedColumn<int> redactedAtUtcUs = GeneratedColumn<int>(
    'redacted_at_utc_us',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    encounterId,
    noteType,
    body,
    recordedAtUtcUs,
    updatedAtUtcUs,
    supersedesNoteId,
    supersededAtUtcUs,
    redactedAtUtcUs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'encounter_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<EncounterNoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('encounter_id')) {
      context.handle(
        _encounterIdMeta,
        encounterId.isAcceptableOrUnknown(
          data['encounter_id']!,
          _encounterIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encounterIdMeta);
    }
    if (data.containsKey('note_type')) {
      context.handle(
        _noteTypeMeta,
        noteType.isAcceptableOrUnknown(data['note_type']!, _noteTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_noteTypeMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('recorded_at_utc_us')) {
      context.handle(
        _recordedAtUtcUsMeta,
        recordedAtUtcUs.isAcceptableOrUnknown(
          data['recorded_at_utc_us']!,
          _recordedAtUtcUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordedAtUtcUsMeta);
    }
    if (data.containsKey('updated_at_utc_us')) {
      context.handle(
        _updatedAtUtcUsMeta,
        updatedAtUtcUs.isAcceptableOrUnknown(
          data['updated_at_utc_us']!,
          _updatedAtUtcUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcUsMeta);
    }
    if (data.containsKey('supersedes_note_id')) {
      context.handle(
        _supersedesNoteIdMeta,
        supersedesNoteId.isAcceptableOrUnknown(
          data['supersedes_note_id']!,
          _supersedesNoteIdMeta,
        ),
      );
    }
    if (data.containsKey('superseded_at_utc_us')) {
      context.handle(
        _supersededAtUtcUsMeta,
        supersededAtUtcUs.isAcceptableOrUnknown(
          data['superseded_at_utc_us']!,
          _supersededAtUtcUsMeta,
        ),
      );
    }
    if (data.containsKey('redacted_at_utc_us')) {
      context.handle(
        _redactedAtUtcUsMeta,
        redactedAtUtcUs.isAcceptableOrUnknown(
          data['redacted_at_utc_us']!,
          _redactedAtUtcUsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EncounterNoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EncounterNoteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      encounterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encounter_id'],
      )!,
      noteType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_type'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      recordedAtUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recorded_at_utc_us'],
      )!,
      updatedAtUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc_us'],
      )!,
      supersedesNoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supersedes_note_id'],
      ),
      supersededAtUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}superseded_at_utc_us'],
      ),
      redactedAtUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}redacted_at_utc_us'],
      ),
    );
  }

  @override
  $EncounterNotesTable createAlias(String alias) {
    return $EncounterNotesTable(attachedDatabase, alias);
  }
}

class EncounterNoteRow extends DataClass
    implements Insertable<EncounterNoteRow> {
  final String id;
  final String encounterId;
  final String noteType;
  final String body;
  final int recordedAtUtcUs;
  final int updatedAtUtcUs;
  final String? supersedesNoteId;
  final int? supersededAtUtcUs;
  final int? redactedAtUtcUs;
  const EncounterNoteRow({
    required this.id,
    required this.encounterId,
    required this.noteType,
    required this.body,
    required this.recordedAtUtcUs,
    required this.updatedAtUtcUs,
    this.supersedesNoteId,
    this.supersededAtUtcUs,
    this.redactedAtUtcUs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['encounter_id'] = Variable<String>(encounterId);
    map['note_type'] = Variable<String>(noteType);
    map['body'] = Variable<String>(body);
    map['recorded_at_utc_us'] = Variable<int>(recordedAtUtcUs);
    map['updated_at_utc_us'] = Variable<int>(updatedAtUtcUs);
    if (!nullToAbsent || supersedesNoteId != null) {
      map['supersedes_note_id'] = Variable<String>(supersedesNoteId);
    }
    if (!nullToAbsent || supersededAtUtcUs != null) {
      map['superseded_at_utc_us'] = Variable<int>(supersededAtUtcUs);
    }
    if (!nullToAbsent || redactedAtUtcUs != null) {
      map['redacted_at_utc_us'] = Variable<int>(redactedAtUtcUs);
    }
    return map;
  }

  EncounterNotesCompanion toCompanion(bool nullToAbsent) {
    return EncounterNotesCompanion(
      id: Value(id),
      encounterId: Value(encounterId),
      noteType: Value(noteType),
      body: Value(body),
      recordedAtUtcUs: Value(recordedAtUtcUs),
      updatedAtUtcUs: Value(updatedAtUtcUs),
      supersedesNoteId: supersedesNoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(supersedesNoteId),
      supersededAtUtcUs: supersededAtUtcUs == null && nullToAbsent
          ? const Value.absent()
          : Value(supersededAtUtcUs),
      redactedAtUtcUs: redactedAtUtcUs == null && nullToAbsent
          ? const Value.absent()
          : Value(redactedAtUtcUs),
    );
  }

  factory EncounterNoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EncounterNoteRow(
      id: serializer.fromJson<String>(json['id']),
      encounterId: serializer.fromJson<String>(json['encounterId']),
      noteType: serializer.fromJson<String>(json['noteType']),
      body: serializer.fromJson<String>(json['body']),
      recordedAtUtcUs: serializer.fromJson<int>(json['recordedAtUtcUs']),
      updatedAtUtcUs: serializer.fromJson<int>(json['updatedAtUtcUs']),
      supersedesNoteId: serializer.fromJson<String?>(json['supersedesNoteId']),
      supersededAtUtcUs: serializer.fromJson<int?>(json['supersededAtUtcUs']),
      redactedAtUtcUs: serializer.fromJson<int?>(json['redactedAtUtcUs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'encounterId': serializer.toJson<String>(encounterId),
      'noteType': serializer.toJson<String>(noteType),
      'body': serializer.toJson<String>(body),
      'recordedAtUtcUs': serializer.toJson<int>(recordedAtUtcUs),
      'updatedAtUtcUs': serializer.toJson<int>(updatedAtUtcUs),
      'supersedesNoteId': serializer.toJson<String?>(supersedesNoteId),
      'supersededAtUtcUs': serializer.toJson<int?>(supersededAtUtcUs),
      'redactedAtUtcUs': serializer.toJson<int?>(redactedAtUtcUs),
    };
  }

  EncounterNoteRow copyWith({
    String? id,
    String? encounterId,
    String? noteType,
    String? body,
    int? recordedAtUtcUs,
    int? updatedAtUtcUs,
    Value<String?> supersedesNoteId = const Value.absent(),
    Value<int?> supersededAtUtcUs = const Value.absent(),
    Value<int?> redactedAtUtcUs = const Value.absent(),
  }) => EncounterNoteRow(
    id: id ?? this.id,
    encounterId: encounterId ?? this.encounterId,
    noteType: noteType ?? this.noteType,
    body: body ?? this.body,
    recordedAtUtcUs: recordedAtUtcUs ?? this.recordedAtUtcUs,
    updatedAtUtcUs: updatedAtUtcUs ?? this.updatedAtUtcUs,
    supersedesNoteId: supersedesNoteId.present
        ? supersedesNoteId.value
        : this.supersedesNoteId,
    supersededAtUtcUs: supersededAtUtcUs.present
        ? supersededAtUtcUs.value
        : this.supersededAtUtcUs,
    redactedAtUtcUs: redactedAtUtcUs.present
        ? redactedAtUtcUs.value
        : this.redactedAtUtcUs,
  );
  EncounterNoteRow copyWithCompanion(EncounterNotesCompanion data) {
    return EncounterNoteRow(
      id: data.id.present ? data.id.value : this.id,
      encounterId: data.encounterId.present
          ? data.encounterId.value
          : this.encounterId,
      noteType: data.noteType.present ? data.noteType.value : this.noteType,
      body: data.body.present ? data.body.value : this.body,
      recordedAtUtcUs: data.recordedAtUtcUs.present
          ? data.recordedAtUtcUs.value
          : this.recordedAtUtcUs,
      updatedAtUtcUs: data.updatedAtUtcUs.present
          ? data.updatedAtUtcUs.value
          : this.updatedAtUtcUs,
      supersedesNoteId: data.supersedesNoteId.present
          ? data.supersedesNoteId.value
          : this.supersedesNoteId,
      supersededAtUtcUs: data.supersededAtUtcUs.present
          ? data.supersededAtUtcUs.value
          : this.supersededAtUtcUs,
      redactedAtUtcUs: data.redactedAtUtcUs.present
          ? data.redactedAtUtcUs.value
          : this.redactedAtUtcUs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EncounterNoteRow(')
          ..write('id: $id, ')
          ..write('encounterId: $encounterId, ')
          ..write('noteType: $noteType, ')
          ..write('body: $body, ')
          ..write('recordedAtUtcUs: $recordedAtUtcUs, ')
          ..write('updatedAtUtcUs: $updatedAtUtcUs, ')
          ..write('supersedesNoteId: $supersedesNoteId, ')
          ..write('supersededAtUtcUs: $supersededAtUtcUs, ')
          ..write('redactedAtUtcUs: $redactedAtUtcUs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    encounterId,
    noteType,
    body,
    recordedAtUtcUs,
    updatedAtUtcUs,
    supersedesNoteId,
    supersededAtUtcUs,
    redactedAtUtcUs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EncounterNoteRow &&
          other.id == this.id &&
          other.encounterId == this.encounterId &&
          other.noteType == this.noteType &&
          other.body == this.body &&
          other.recordedAtUtcUs == this.recordedAtUtcUs &&
          other.updatedAtUtcUs == this.updatedAtUtcUs &&
          other.supersedesNoteId == this.supersedesNoteId &&
          other.supersededAtUtcUs == this.supersededAtUtcUs &&
          other.redactedAtUtcUs == this.redactedAtUtcUs);
}

class EncounterNotesCompanion extends UpdateCompanion<EncounterNoteRow> {
  final Value<String> id;
  final Value<String> encounterId;
  final Value<String> noteType;
  final Value<String> body;
  final Value<int> recordedAtUtcUs;
  final Value<int> updatedAtUtcUs;
  final Value<String?> supersedesNoteId;
  final Value<int?> supersededAtUtcUs;
  final Value<int?> redactedAtUtcUs;
  final Value<int> rowid;
  const EncounterNotesCompanion({
    this.id = const Value.absent(),
    this.encounterId = const Value.absent(),
    this.noteType = const Value.absent(),
    this.body = const Value.absent(),
    this.recordedAtUtcUs = const Value.absent(),
    this.updatedAtUtcUs = const Value.absent(),
    this.supersedesNoteId = const Value.absent(),
    this.supersededAtUtcUs = const Value.absent(),
    this.redactedAtUtcUs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EncounterNotesCompanion.insert({
    required String id,
    required String encounterId,
    required String noteType,
    required String body,
    required int recordedAtUtcUs,
    required int updatedAtUtcUs,
    this.supersedesNoteId = const Value.absent(),
    this.supersededAtUtcUs = const Value.absent(),
    this.redactedAtUtcUs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       encounterId = Value(encounterId),
       noteType = Value(noteType),
       body = Value(body),
       recordedAtUtcUs = Value(recordedAtUtcUs),
       updatedAtUtcUs = Value(updatedAtUtcUs);
  static Insertable<EncounterNoteRow> custom({
    Expression<String>? id,
    Expression<String>? encounterId,
    Expression<String>? noteType,
    Expression<String>? body,
    Expression<int>? recordedAtUtcUs,
    Expression<int>? updatedAtUtcUs,
    Expression<String>? supersedesNoteId,
    Expression<int>? supersededAtUtcUs,
    Expression<int>? redactedAtUtcUs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (encounterId != null) 'encounter_id': encounterId,
      if (noteType != null) 'note_type': noteType,
      if (body != null) 'body': body,
      if (recordedAtUtcUs != null) 'recorded_at_utc_us': recordedAtUtcUs,
      if (updatedAtUtcUs != null) 'updated_at_utc_us': updatedAtUtcUs,
      if (supersedesNoteId != null) 'supersedes_note_id': supersedesNoteId,
      if (supersededAtUtcUs != null) 'superseded_at_utc_us': supersededAtUtcUs,
      if (redactedAtUtcUs != null) 'redacted_at_utc_us': redactedAtUtcUs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EncounterNotesCompanion copyWith({
    Value<String>? id,
    Value<String>? encounterId,
    Value<String>? noteType,
    Value<String>? body,
    Value<int>? recordedAtUtcUs,
    Value<int>? updatedAtUtcUs,
    Value<String?>? supersedesNoteId,
    Value<int?>? supersededAtUtcUs,
    Value<int?>? redactedAtUtcUs,
    Value<int>? rowid,
  }) {
    return EncounterNotesCompanion(
      id: id ?? this.id,
      encounterId: encounterId ?? this.encounterId,
      noteType: noteType ?? this.noteType,
      body: body ?? this.body,
      recordedAtUtcUs: recordedAtUtcUs ?? this.recordedAtUtcUs,
      updatedAtUtcUs: updatedAtUtcUs ?? this.updatedAtUtcUs,
      supersedesNoteId: supersedesNoteId ?? this.supersedesNoteId,
      supersededAtUtcUs: supersededAtUtcUs ?? this.supersededAtUtcUs,
      redactedAtUtcUs: redactedAtUtcUs ?? this.redactedAtUtcUs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (encounterId.present) {
      map['encounter_id'] = Variable<String>(encounterId.value);
    }
    if (noteType.present) {
      map['note_type'] = Variable<String>(noteType.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (recordedAtUtcUs.present) {
      map['recorded_at_utc_us'] = Variable<int>(recordedAtUtcUs.value);
    }
    if (updatedAtUtcUs.present) {
      map['updated_at_utc_us'] = Variable<int>(updatedAtUtcUs.value);
    }
    if (supersedesNoteId.present) {
      map['supersedes_note_id'] = Variable<String>(supersedesNoteId.value);
    }
    if (supersededAtUtcUs.present) {
      map['superseded_at_utc_us'] = Variable<int>(supersededAtUtcUs.value);
    }
    if (redactedAtUtcUs.present) {
      map['redacted_at_utc_us'] = Variable<int>(redactedAtUtcUs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EncounterNotesCompanion(')
          ..write('id: $id, ')
          ..write('encounterId: $encounterId, ')
          ..write('noteType: $noteType, ')
          ..write('body: $body, ')
          ..write('recordedAtUtcUs: $recordedAtUtcUs, ')
          ..write('updatedAtUtcUs: $updatedAtUtcUs, ')
          ..write('supersedesNoteId: $supersedesNoteId, ')
          ..write('supersededAtUtcUs: $supersededAtUtcUs, ')
          ..write('redactedAtUtcUs: $redactedAtUtcUs, ')
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
  late final $TarotReadingsTable tarotReadings = $TarotReadingsTable(this);
  late final $TarotCardPlacementsTable tarotCardPlacements =
      $TarotCardPlacementsTable(this);
  late final $TarotInterpretationsTable tarotInterpretations =
      $TarotInterpretationsTable(this);
  late final $AppRuntimeStateTable appRuntimeState = $AppRuntimeStateTable(
    this,
  );
  late final $PersonsTable persons = $PersonsTable(this);
  late final $PersonRolesTable personRoles = $PersonRolesTable(this);
  late final $PersonRelationshipsTable personRelationships =
      $PersonRelationshipsTable(this);
  late final $PersonBirthProfilesTable personBirthProfiles =
      $PersonBirthProfilesTable(this);
  late final $EncountersTable encounters = $EncountersTable(this);
  late final $EncounterNotesTable encounterNotes = $EncounterNotesTable(this);
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
    tarotReadings,
    tarotCardPlacements,
    tarotInterpretations,
    appRuntimeState,
    persons,
    personRoles,
    personRelationships,
    personBirthProfiles,
    encounters,
    encounterNotes,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'persons',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('person_roles', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'persons',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('person_relationships', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'persons',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('person_relationships', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'persons',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('person_birth_profiles', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'person_birth_profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('person_birth_profiles', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'persons',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('encounters', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'encounters',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('encounter_notes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'encounter_notes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('encounter_notes', kind: UpdateKind.update)],
    ),
  ]);
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
typedef $$TarotReadingsTableCreateCompanionBuilder =
    TarotReadingsCompanion Function({
      required String readingInstanceId,
      required String sourceType,
      required String questionOriginalSnapshot,
      required String questionDisplayText,
      required String deckId,
      required String deckNameSnapshot,
      required String spreadId,
      required String spreadNameSnapshot,
      required int expectedPlacementCount,
      required int readingAtUtcUs,
      required int readingTimezoneOffsetMin,
      required int createdAtUtcUs,
      required int updatedAtUtcUs,
      required String lifecycleStatus,
      Value<int?> finishedAtUtcUs,
      Value<int> rowid,
    });
typedef $$TarotReadingsTableUpdateCompanionBuilder =
    TarotReadingsCompanion Function({
      Value<String> readingInstanceId,
      Value<String> sourceType,
      Value<String> questionOriginalSnapshot,
      Value<String> questionDisplayText,
      Value<String> deckId,
      Value<String> deckNameSnapshot,
      Value<String> spreadId,
      Value<String> spreadNameSnapshot,
      Value<int> expectedPlacementCount,
      Value<int> readingAtUtcUs,
      Value<int> readingTimezoneOffsetMin,
      Value<int> createdAtUtcUs,
      Value<int> updatedAtUtcUs,
      Value<String> lifecycleStatus,
      Value<int?> finishedAtUtcUs,
      Value<int> rowid,
    });

final class $$TarotReadingsTableReferences
    extends
        BaseReferences<_$RynAppDatabase, $TarotReadingsTable, TarotReading> {
  $$TarotReadingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $TarotCardPlacementsTable,
    List<TarotCardPlacement>
  >
  _tarotCardPlacementsRefsTable(_$RynAppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.tarotCardPlacements,
        aliasName: $_aliasNameGenerator(
          db.tarotReadings.readingInstanceId,
          db.tarotCardPlacements.readingInstanceId,
        ),
      );

  $$TarotCardPlacementsTableProcessedTableManager get tarotCardPlacementsRefs {
    final manager =
        $$TarotCardPlacementsTableTableManager(
          $_db,
          $_db.tarotCardPlacements,
        ).filter(
          (f) => f.readingInstanceId.readingInstanceId.sqlEquals(
            $_itemColumn<String>('reading_instance_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _tarotCardPlacementsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $TarotInterpretationsTable,
    List<TarotInterpretation>
  >
  _tarotInterpretationsRefsTable(_$RynAppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.tarotInterpretations,
        aliasName: $_aliasNameGenerator(
          db.tarotReadings.readingInstanceId,
          db.tarotInterpretations.readingInstanceId,
        ),
      );

  $$TarotInterpretationsTableProcessedTableManager
  get tarotInterpretationsRefs {
    final manager =
        $$TarotInterpretationsTableTableManager(
          $_db,
          $_db.tarotInterpretations,
        ).filter(
          (f) => f.readingInstanceId.readingInstanceId.sqlEquals(
            $_itemColumn<String>('reading_instance_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _tarotInterpretationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AppRuntimeStateTable, List<AppRuntimeStateData>>
  _appRuntimeStateRefsTable(_$RynAppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.appRuntimeState,
        aliasName: $_aliasNameGenerator(
          db.tarotReadings.readingInstanceId,
          db.appRuntimeState.activeHomeTarotReadingId,
        ),
      );

  $$AppRuntimeStateTableProcessedTableManager get appRuntimeStateRefs {
    final manager =
        $$AppRuntimeStateTableTableManager($_db, $_db.appRuntimeState).filter(
          (f) => f.activeHomeTarotReadingId.readingInstanceId.sqlEquals(
            $_itemColumn<String>('reading_instance_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _appRuntimeStateRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TarotReadingsTableFilterComposer
    extends Composer<_$RynAppDatabase, $TarotReadingsTable> {
  $$TarotReadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get readingInstanceId => $composableBuilder(
    column: $table.readingInstanceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionOriginalSnapshot => $composableBuilder(
    column: $table.questionOriginalSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionDisplayText => $composableBuilder(
    column: $table.questionDisplayText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deckId => $composableBuilder(
    column: $table.deckId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deckNameSnapshot => $composableBuilder(
    column: $table.deckNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spreadId => $composableBuilder(
    column: $table.spreadId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spreadNameSnapshot => $composableBuilder(
    column: $table.spreadNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedPlacementCount => $composableBuilder(
    column: $table.expectedPlacementCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get readingAtUtcUs => $composableBuilder(
    column: $table.readingAtUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get readingTimezoneOffsetMin => $composableBuilder(
    column: $table.readingTimezoneOffsetMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcUs => $composableBuilder(
    column: $table.createdAtUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtcUs => $composableBuilder(
    column: $table.updatedAtUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lifecycleStatus => $composableBuilder(
    column: $table.lifecycleStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get finishedAtUtcUs => $composableBuilder(
    column: $table.finishedAtUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tarotCardPlacementsRefs(
    Expression<bool> Function($$TarotCardPlacementsTableFilterComposer f) f,
  ) {
    final $$TarotCardPlacementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.readingInstanceId,
      referencedTable: $db.tarotCardPlacements,
      getReferencedColumn: (t) => t.readingInstanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TarotCardPlacementsTableFilterComposer(
            $db: $db,
            $table: $db.tarotCardPlacements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tarotInterpretationsRefs(
    Expression<bool> Function($$TarotInterpretationsTableFilterComposer f) f,
  ) {
    final $$TarotInterpretationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.readingInstanceId,
      referencedTable: $db.tarotInterpretations,
      getReferencedColumn: (t) => t.readingInstanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TarotInterpretationsTableFilterComposer(
            $db: $db,
            $table: $db.tarotInterpretations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> appRuntimeStateRefs(
    Expression<bool> Function($$AppRuntimeStateTableFilterComposer f) f,
  ) {
    final $$AppRuntimeStateTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.readingInstanceId,
      referencedTable: $db.appRuntimeState,
      getReferencedColumn: (t) => t.activeHomeTarotReadingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppRuntimeStateTableFilterComposer(
            $db: $db,
            $table: $db.appRuntimeState,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TarotReadingsTableOrderingComposer
    extends Composer<_$RynAppDatabase, $TarotReadingsTable> {
  $$TarotReadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get readingInstanceId => $composableBuilder(
    column: $table.readingInstanceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionOriginalSnapshot => $composableBuilder(
    column: $table.questionOriginalSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionDisplayText => $composableBuilder(
    column: $table.questionDisplayText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deckId => $composableBuilder(
    column: $table.deckId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deckNameSnapshot => $composableBuilder(
    column: $table.deckNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spreadId => $composableBuilder(
    column: $table.spreadId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spreadNameSnapshot => $composableBuilder(
    column: $table.spreadNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedPlacementCount => $composableBuilder(
    column: $table.expectedPlacementCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get readingAtUtcUs => $composableBuilder(
    column: $table.readingAtUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get readingTimezoneOffsetMin => $composableBuilder(
    column: $table.readingTimezoneOffsetMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcUs => $composableBuilder(
    column: $table.createdAtUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtcUs => $composableBuilder(
    column: $table.updatedAtUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lifecycleStatus => $composableBuilder(
    column: $table.lifecycleStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get finishedAtUtcUs => $composableBuilder(
    column: $table.finishedAtUtcUs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TarotReadingsTableAnnotationComposer
    extends Composer<_$RynAppDatabase, $TarotReadingsTable> {
  $$TarotReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get readingInstanceId => $composableBuilder(
    column: $table.readingInstanceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get questionOriginalSnapshot => $composableBuilder(
    column: $table.questionOriginalSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get questionDisplayText => $composableBuilder(
    column: $table.questionDisplayText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deckId =>
      $composableBuilder(column: $table.deckId, builder: (column) => column);

  GeneratedColumn<String> get deckNameSnapshot => $composableBuilder(
    column: $table.deckNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get spreadId =>
      $composableBuilder(column: $table.spreadId, builder: (column) => column);

  GeneratedColumn<String> get spreadNameSnapshot => $composableBuilder(
    column: $table.spreadNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expectedPlacementCount => $composableBuilder(
    column: $table.expectedPlacementCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get readingAtUtcUs => $composableBuilder(
    column: $table.readingAtUtcUs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get readingTimezoneOffsetMin => $composableBuilder(
    column: $table.readingTimezoneOffsetMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtUtcUs => $composableBuilder(
    column: $table.createdAtUtcUs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtcUs => $composableBuilder(
    column: $table.updatedAtUtcUs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lifecycleStatus => $composableBuilder(
    column: $table.lifecycleStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get finishedAtUtcUs => $composableBuilder(
    column: $table.finishedAtUtcUs,
    builder: (column) => column,
  );

  Expression<T> tarotCardPlacementsRefs<T extends Object>(
    Expression<T> Function($$TarotCardPlacementsTableAnnotationComposer a) f,
  ) {
    final $$TarotCardPlacementsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.readingInstanceId,
          referencedTable: $db.tarotCardPlacements,
          getReferencedColumn: (t) => t.readingInstanceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TarotCardPlacementsTableAnnotationComposer(
                $db: $db,
                $table: $db.tarotCardPlacements,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> tarotInterpretationsRefs<T extends Object>(
    Expression<T> Function($$TarotInterpretationsTableAnnotationComposer a) f,
  ) {
    final $$TarotInterpretationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.readingInstanceId,
          referencedTable: $db.tarotInterpretations,
          getReferencedColumn: (t) => t.readingInstanceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TarotInterpretationsTableAnnotationComposer(
                $db: $db,
                $table: $db.tarotInterpretations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> appRuntimeStateRefs<T extends Object>(
    Expression<T> Function($$AppRuntimeStateTableAnnotationComposer a) f,
  ) {
    final $$AppRuntimeStateTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.readingInstanceId,
      referencedTable: $db.appRuntimeState,
      getReferencedColumn: (t) => t.activeHomeTarotReadingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppRuntimeStateTableAnnotationComposer(
            $db: $db,
            $table: $db.appRuntimeState,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TarotReadingsTableTableManager
    extends
        RootTableManager<
          _$RynAppDatabase,
          $TarotReadingsTable,
          TarotReading,
          $$TarotReadingsTableFilterComposer,
          $$TarotReadingsTableOrderingComposer,
          $$TarotReadingsTableAnnotationComposer,
          $$TarotReadingsTableCreateCompanionBuilder,
          $$TarotReadingsTableUpdateCompanionBuilder,
          (TarotReading, $$TarotReadingsTableReferences),
          TarotReading,
          PrefetchHooks Function({
            bool tarotCardPlacementsRefs,
            bool tarotInterpretationsRefs,
            bool appRuntimeStateRefs,
          })
        > {
  $$TarotReadingsTableTableManager(
    _$RynAppDatabase db,
    $TarotReadingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TarotReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TarotReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TarotReadingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> readingInstanceId = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String> questionOriginalSnapshot = const Value.absent(),
                Value<String> questionDisplayText = const Value.absent(),
                Value<String> deckId = const Value.absent(),
                Value<String> deckNameSnapshot = const Value.absent(),
                Value<String> spreadId = const Value.absent(),
                Value<String> spreadNameSnapshot = const Value.absent(),
                Value<int> expectedPlacementCount = const Value.absent(),
                Value<int> readingAtUtcUs = const Value.absent(),
                Value<int> readingTimezoneOffsetMin = const Value.absent(),
                Value<int> createdAtUtcUs = const Value.absent(),
                Value<int> updatedAtUtcUs = const Value.absent(),
                Value<String> lifecycleStatus = const Value.absent(),
                Value<int?> finishedAtUtcUs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TarotReadingsCompanion(
                readingInstanceId: readingInstanceId,
                sourceType: sourceType,
                questionOriginalSnapshot: questionOriginalSnapshot,
                questionDisplayText: questionDisplayText,
                deckId: deckId,
                deckNameSnapshot: deckNameSnapshot,
                spreadId: spreadId,
                spreadNameSnapshot: spreadNameSnapshot,
                expectedPlacementCount: expectedPlacementCount,
                readingAtUtcUs: readingAtUtcUs,
                readingTimezoneOffsetMin: readingTimezoneOffsetMin,
                createdAtUtcUs: createdAtUtcUs,
                updatedAtUtcUs: updatedAtUtcUs,
                lifecycleStatus: lifecycleStatus,
                finishedAtUtcUs: finishedAtUtcUs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String readingInstanceId,
                required String sourceType,
                required String questionOriginalSnapshot,
                required String questionDisplayText,
                required String deckId,
                required String deckNameSnapshot,
                required String spreadId,
                required String spreadNameSnapshot,
                required int expectedPlacementCount,
                required int readingAtUtcUs,
                required int readingTimezoneOffsetMin,
                required int createdAtUtcUs,
                required int updatedAtUtcUs,
                required String lifecycleStatus,
                Value<int?> finishedAtUtcUs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TarotReadingsCompanion.insert(
                readingInstanceId: readingInstanceId,
                sourceType: sourceType,
                questionOriginalSnapshot: questionOriginalSnapshot,
                questionDisplayText: questionDisplayText,
                deckId: deckId,
                deckNameSnapshot: deckNameSnapshot,
                spreadId: spreadId,
                spreadNameSnapshot: spreadNameSnapshot,
                expectedPlacementCount: expectedPlacementCount,
                readingAtUtcUs: readingAtUtcUs,
                readingTimezoneOffsetMin: readingTimezoneOffsetMin,
                createdAtUtcUs: createdAtUtcUs,
                updatedAtUtcUs: updatedAtUtcUs,
                lifecycleStatus: lifecycleStatus,
                finishedAtUtcUs: finishedAtUtcUs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TarotReadingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tarotCardPlacementsRefs = false,
                tarotInterpretationsRefs = false,
                appRuntimeStateRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tarotCardPlacementsRefs) db.tarotCardPlacements,
                    if (tarotInterpretationsRefs) db.tarotInterpretations,
                    if (appRuntimeStateRefs) db.appRuntimeState,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tarotCardPlacementsRefs)
                        await $_getPrefetchedData<
                          TarotReading,
                          $TarotReadingsTable,
                          TarotCardPlacement
                        >(
                          currentTable: table,
                          referencedTable: $$TarotReadingsTableReferences
                              ._tarotCardPlacementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TarotReadingsTableReferences(
                                db,
                                table,
                                p0,
                              ).tarotCardPlacementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) =>
                                    e.readingInstanceId ==
                                    item.readingInstanceId,
                              ),
                          typedResults: items,
                        ),
                      if (tarotInterpretationsRefs)
                        await $_getPrefetchedData<
                          TarotReading,
                          $TarotReadingsTable,
                          TarotInterpretation
                        >(
                          currentTable: table,
                          referencedTable: $$TarotReadingsTableReferences
                              ._tarotInterpretationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TarotReadingsTableReferences(
                                db,
                                table,
                                p0,
                              ).tarotInterpretationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) =>
                                    e.readingInstanceId ==
                                    item.readingInstanceId,
                              ),
                          typedResults: items,
                        ),
                      if (appRuntimeStateRefs)
                        await $_getPrefetchedData<
                          TarotReading,
                          $TarotReadingsTable,
                          AppRuntimeStateData
                        >(
                          currentTable: table,
                          referencedTable: $$TarotReadingsTableReferences
                              ._appRuntimeStateRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TarotReadingsTableReferences(
                                db,
                                table,
                                p0,
                              ).appRuntimeStateRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) =>
                                    e.activeHomeTarotReadingId ==
                                    item.readingInstanceId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TarotReadingsTableProcessedTableManager =
    ProcessedTableManager<
      _$RynAppDatabase,
      $TarotReadingsTable,
      TarotReading,
      $$TarotReadingsTableFilterComposer,
      $$TarotReadingsTableOrderingComposer,
      $$TarotReadingsTableAnnotationComposer,
      $$TarotReadingsTableCreateCompanionBuilder,
      $$TarotReadingsTableUpdateCompanionBuilder,
      (TarotReading, $$TarotReadingsTableReferences),
      TarotReading,
      PrefetchHooks Function({
        bool tarotCardPlacementsRefs,
        bool tarotInterpretationsRefs,
        bool appRuntimeStateRefs,
      })
    >;
typedef $$TarotCardPlacementsTableCreateCompanionBuilder =
    TarotCardPlacementsCompanion Function({
      required String readingInstanceId,
      required int placementOrder,
      required String positionId,
      required String positionNameSnapshot,
      required String cardId,
      required String cardNameSnapshot,
      required String orientation,
      Value<int> rowid,
    });
typedef $$TarotCardPlacementsTableUpdateCompanionBuilder =
    TarotCardPlacementsCompanion Function({
      Value<String> readingInstanceId,
      Value<int> placementOrder,
      Value<String> positionId,
      Value<String> positionNameSnapshot,
      Value<String> cardId,
      Value<String> cardNameSnapshot,
      Value<String> orientation,
      Value<int> rowid,
    });

final class $$TarotCardPlacementsTableReferences
    extends
        BaseReferences<
          _$RynAppDatabase,
          $TarotCardPlacementsTable,
          TarotCardPlacement
        > {
  $$TarotCardPlacementsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TarotReadingsTable _readingInstanceIdTable(_$RynAppDatabase db) =>
      db.tarotReadings.createAlias(
        $_aliasNameGenerator(
          db.tarotCardPlacements.readingInstanceId,
          db.tarotReadings.readingInstanceId,
        ),
      );

  $$TarotReadingsTableProcessedTableManager get readingInstanceId {
    final $_column = $_itemColumn<String>('reading_instance_id')!;

    final manager = $$TarotReadingsTableTableManager(
      $_db,
      $_db.tarotReadings,
    ).filter((f) => f.readingInstanceId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_readingInstanceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TarotCardPlacementsTableFilterComposer
    extends Composer<_$RynAppDatabase, $TarotCardPlacementsTable> {
  $$TarotCardPlacementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get placementOrder => $composableBuilder(
    column: $table.placementOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get positionId => $composableBuilder(
    column: $table.positionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get positionNameSnapshot => $composableBuilder(
    column: $table.positionNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardNameSnapshot => $composableBuilder(
    column: $table.cardNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orientation => $composableBuilder(
    column: $table.orientation,
    builder: (column) => ColumnFilters(column),
  );

  $$TarotReadingsTableFilterComposer get readingInstanceId {
    final $$TarotReadingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.readingInstanceId,
      referencedTable: $db.tarotReadings,
      getReferencedColumn: (t) => t.readingInstanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TarotReadingsTableFilterComposer(
            $db: $db,
            $table: $db.tarotReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TarotCardPlacementsTableOrderingComposer
    extends Composer<_$RynAppDatabase, $TarotCardPlacementsTable> {
  $$TarotCardPlacementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get placementOrder => $composableBuilder(
    column: $table.placementOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get positionId => $composableBuilder(
    column: $table.positionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get positionNameSnapshot => $composableBuilder(
    column: $table.positionNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardNameSnapshot => $composableBuilder(
    column: $table.cardNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orientation => $composableBuilder(
    column: $table.orientation,
    builder: (column) => ColumnOrderings(column),
  );

  $$TarotReadingsTableOrderingComposer get readingInstanceId {
    final $$TarotReadingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.readingInstanceId,
      referencedTable: $db.tarotReadings,
      getReferencedColumn: (t) => t.readingInstanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TarotReadingsTableOrderingComposer(
            $db: $db,
            $table: $db.tarotReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TarotCardPlacementsTableAnnotationComposer
    extends Composer<_$RynAppDatabase, $TarotCardPlacementsTable> {
  $$TarotCardPlacementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get placementOrder => $composableBuilder(
    column: $table.placementOrder,
    builder: (column) => column,
  );

  GeneratedColumn<String> get positionId => $composableBuilder(
    column: $table.positionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get positionNameSnapshot => $composableBuilder(
    column: $table.positionNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<String> get cardNameSnapshot => $composableBuilder(
    column: $table.cardNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get orientation => $composableBuilder(
    column: $table.orientation,
    builder: (column) => column,
  );

  $$TarotReadingsTableAnnotationComposer get readingInstanceId {
    final $$TarotReadingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.readingInstanceId,
      referencedTable: $db.tarotReadings,
      getReferencedColumn: (t) => t.readingInstanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TarotReadingsTableAnnotationComposer(
            $db: $db,
            $table: $db.tarotReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TarotCardPlacementsTableTableManager
    extends
        RootTableManager<
          _$RynAppDatabase,
          $TarotCardPlacementsTable,
          TarotCardPlacement,
          $$TarotCardPlacementsTableFilterComposer,
          $$TarotCardPlacementsTableOrderingComposer,
          $$TarotCardPlacementsTableAnnotationComposer,
          $$TarotCardPlacementsTableCreateCompanionBuilder,
          $$TarotCardPlacementsTableUpdateCompanionBuilder,
          (TarotCardPlacement, $$TarotCardPlacementsTableReferences),
          TarotCardPlacement,
          PrefetchHooks Function({bool readingInstanceId})
        > {
  $$TarotCardPlacementsTableTableManager(
    _$RynAppDatabase db,
    $TarotCardPlacementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TarotCardPlacementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TarotCardPlacementsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TarotCardPlacementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> readingInstanceId = const Value.absent(),
                Value<int> placementOrder = const Value.absent(),
                Value<String> positionId = const Value.absent(),
                Value<String> positionNameSnapshot = const Value.absent(),
                Value<String> cardId = const Value.absent(),
                Value<String> cardNameSnapshot = const Value.absent(),
                Value<String> orientation = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TarotCardPlacementsCompanion(
                readingInstanceId: readingInstanceId,
                placementOrder: placementOrder,
                positionId: positionId,
                positionNameSnapshot: positionNameSnapshot,
                cardId: cardId,
                cardNameSnapshot: cardNameSnapshot,
                orientation: orientation,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String readingInstanceId,
                required int placementOrder,
                required String positionId,
                required String positionNameSnapshot,
                required String cardId,
                required String cardNameSnapshot,
                required String orientation,
                Value<int> rowid = const Value.absent(),
              }) => TarotCardPlacementsCompanion.insert(
                readingInstanceId: readingInstanceId,
                placementOrder: placementOrder,
                positionId: positionId,
                positionNameSnapshot: positionNameSnapshot,
                cardId: cardId,
                cardNameSnapshot: cardNameSnapshot,
                orientation: orientation,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TarotCardPlacementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({readingInstanceId = false}) {
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
                    if (readingInstanceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.readingInstanceId,
                                referencedTable:
                                    $$TarotCardPlacementsTableReferences
                                        ._readingInstanceIdTable(db),
                                referencedColumn:
                                    $$TarotCardPlacementsTableReferences
                                        ._readingInstanceIdTable(db)
                                        .readingInstanceId,
                              )
                              as T;
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

typedef $$TarotCardPlacementsTableProcessedTableManager =
    ProcessedTableManager<
      _$RynAppDatabase,
      $TarotCardPlacementsTable,
      TarotCardPlacement,
      $$TarotCardPlacementsTableFilterComposer,
      $$TarotCardPlacementsTableOrderingComposer,
      $$TarotCardPlacementsTableAnnotationComposer,
      $$TarotCardPlacementsTableCreateCompanionBuilder,
      $$TarotCardPlacementsTableUpdateCompanionBuilder,
      (TarotCardPlacement, $$TarotCardPlacementsTableReferences),
      TarotCardPlacement,
      PrefetchHooks Function({bool readingInstanceId})
    >;
typedef $$TarotInterpretationsTableCreateCompanionBuilder =
    TarotInterpretationsCompanion Function({
      required String readingInstanceId,
      Value<String> wholeImageObservation,
      Value<String> flowInterpretation,
      Value<String> coreMessage,
      Value<String> smallAction,
      required int createdAtUtcUs,
      required int updatedAtUtcUs,
      Value<int> rowid,
    });
typedef $$TarotInterpretationsTableUpdateCompanionBuilder =
    TarotInterpretationsCompanion Function({
      Value<String> readingInstanceId,
      Value<String> wholeImageObservation,
      Value<String> flowInterpretation,
      Value<String> coreMessage,
      Value<String> smallAction,
      Value<int> createdAtUtcUs,
      Value<int> updatedAtUtcUs,
      Value<int> rowid,
    });

final class $$TarotInterpretationsTableReferences
    extends
        BaseReferences<
          _$RynAppDatabase,
          $TarotInterpretationsTable,
          TarotInterpretation
        > {
  $$TarotInterpretationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TarotReadingsTable _readingInstanceIdTable(_$RynAppDatabase db) =>
      db.tarotReadings.createAlias(
        $_aliasNameGenerator(
          db.tarotInterpretations.readingInstanceId,
          db.tarotReadings.readingInstanceId,
        ),
      );

  $$TarotReadingsTableProcessedTableManager get readingInstanceId {
    final $_column = $_itemColumn<String>('reading_instance_id')!;

    final manager = $$TarotReadingsTableTableManager(
      $_db,
      $_db.tarotReadings,
    ).filter((f) => f.readingInstanceId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_readingInstanceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TarotInterpretationsTableFilterComposer
    extends Composer<_$RynAppDatabase, $TarotInterpretationsTable> {
  $$TarotInterpretationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get wholeImageObservation => $composableBuilder(
    column: $table.wholeImageObservation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flowInterpretation => $composableBuilder(
    column: $table.flowInterpretation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coreMessage => $composableBuilder(
    column: $table.coreMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get smallAction => $composableBuilder(
    column: $table.smallAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcUs => $composableBuilder(
    column: $table.createdAtUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtcUs => $composableBuilder(
    column: $table.updatedAtUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  $$TarotReadingsTableFilterComposer get readingInstanceId {
    final $$TarotReadingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.readingInstanceId,
      referencedTable: $db.tarotReadings,
      getReferencedColumn: (t) => t.readingInstanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TarotReadingsTableFilterComposer(
            $db: $db,
            $table: $db.tarotReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TarotInterpretationsTableOrderingComposer
    extends Composer<_$RynAppDatabase, $TarotInterpretationsTable> {
  $$TarotInterpretationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get wholeImageObservation => $composableBuilder(
    column: $table.wholeImageObservation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flowInterpretation => $composableBuilder(
    column: $table.flowInterpretation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coreMessage => $composableBuilder(
    column: $table.coreMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get smallAction => $composableBuilder(
    column: $table.smallAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcUs => $composableBuilder(
    column: $table.createdAtUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtcUs => $composableBuilder(
    column: $table.updatedAtUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  $$TarotReadingsTableOrderingComposer get readingInstanceId {
    final $$TarotReadingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.readingInstanceId,
      referencedTable: $db.tarotReadings,
      getReferencedColumn: (t) => t.readingInstanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TarotReadingsTableOrderingComposer(
            $db: $db,
            $table: $db.tarotReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TarotInterpretationsTableAnnotationComposer
    extends Composer<_$RynAppDatabase, $TarotInterpretationsTable> {
  $$TarotInterpretationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get wholeImageObservation => $composableBuilder(
    column: $table.wholeImageObservation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get flowInterpretation => $composableBuilder(
    column: $table.flowInterpretation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coreMessage => $composableBuilder(
    column: $table.coreMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get smallAction => $composableBuilder(
    column: $table.smallAction,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtUtcUs => $composableBuilder(
    column: $table.createdAtUtcUs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtcUs => $composableBuilder(
    column: $table.updatedAtUtcUs,
    builder: (column) => column,
  );

  $$TarotReadingsTableAnnotationComposer get readingInstanceId {
    final $$TarotReadingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.readingInstanceId,
      referencedTable: $db.tarotReadings,
      getReferencedColumn: (t) => t.readingInstanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TarotReadingsTableAnnotationComposer(
            $db: $db,
            $table: $db.tarotReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TarotInterpretationsTableTableManager
    extends
        RootTableManager<
          _$RynAppDatabase,
          $TarotInterpretationsTable,
          TarotInterpretation,
          $$TarotInterpretationsTableFilterComposer,
          $$TarotInterpretationsTableOrderingComposer,
          $$TarotInterpretationsTableAnnotationComposer,
          $$TarotInterpretationsTableCreateCompanionBuilder,
          $$TarotInterpretationsTableUpdateCompanionBuilder,
          (TarotInterpretation, $$TarotInterpretationsTableReferences),
          TarotInterpretation,
          PrefetchHooks Function({bool readingInstanceId})
        > {
  $$TarotInterpretationsTableTableManager(
    _$RynAppDatabase db,
    $TarotInterpretationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TarotInterpretationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TarotInterpretationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TarotInterpretationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> readingInstanceId = const Value.absent(),
                Value<String> wholeImageObservation = const Value.absent(),
                Value<String> flowInterpretation = const Value.absent(),
                Value<String> coreMessage = const Value.absent(),
                Value<String> smallAction = const Value.absent(),
                Value<int> createdAtUtcUs = const Value.absent(),
                Value<int> updatedAtUtcUs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TarotInterpretationsCompanion(
                readingInstanceId: readingInstanceId,
                wholeImageObservation: wholeImageObservation,
                flowInterpretation: flowInterpretation,
                coreMessage: coreMessage,
                smallAction: smallAction,
                createdAtUtcUs: createdAtUtcUs,
                updatedAtUtcUs: updatedAtUtcUs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String readingInstanceId,
                Value<String> wholeImageObservation = const Value.absent(),
                Value<String> flowInterpretation = const Value.absent(),
                Value<String> coreMessage = const Value.absent(),
                Value<String> smallAction = const Value.absent(),
                required int createdAtUtcUs,
                required int updatedAtUtcUs,
                Value<int> rowid = const Value.absent(),
              }) => TarotInterpretationsCompanion.insert(
                readingInstanceId: readingInstanceId,
                wholeImageObservation: wholeImageObservation,
                flowInterpretation: flowInterpretation,
                coreMessage: coreMessage,
                smallAction: smallAction,
                createdAtUtcUs: createdAtUtcUs,
                updatedAtUtcUs: updatedAtUtcUs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TarotInterpretationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({readingInstanceId = false}) {
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
                    if (readingInstanceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.readingInstanceId,
                                referencedTable:
                                    $$TarotInterpretationsTableReferences
                                        ._readingInstanceIdTable(db),
                                referencedColumn:
                                    $$TarotInterpretationsTableReferences
                                        ._readingInstanceIdTable(db)
                                        .readingInstanceId,
                              )
                              as T;
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

typedef $$TarotInterpretationsTableProcessedTableManager =
    ProcessedTableManager<
      _$RynAppDatabase,
      $TarotInterpretationsTable,
      TarotInterpretation,
      $$TarotInterpretationsTableFilterComposer,
      $$TarotInterpretationsTableOrderingComposer,
      $$TarotInterpretationsTableAnnotationComposer,
      $$TarotInterpretationsTableCreateCompanionBuilder,
      $$TarotInterpretationsTableUpdateCompanionBuilder,
      (TarotInterpretation, $$TarotInterpretationsTableReferences),
      TarotInterpretation,
      PrefetchHooks Function({bool readingInstanceId})
    >;
typedef $$AppRuntimeStateTableCreateCompanionBuilder =
    AppRuntimeStateCompanion Function({
      required String stateKey,
      Value<String?> activeHomeTarotReadingId,
      required int updatedAtUtcUs,
      Value<int> rowid,
    });
typedef $$AppRuntimeStateTableUpdateCompanionBuilder =
    AppRuntimeStateCompanion Function({
      Value<String> stateKey,
      Value<String?> activeHomeTarotReadingId,
      Value<int> updatedAtUtcUs,
      Value<int> rowid,
    });

final class $$AppRuntimeStateTableReferences
    extends
        BaseReferences<
          _$RynAppDatabase,
          $AppRuntimeStateTable,
          AppRuntimeStateData
        > {
  $$AppRuntimeStateTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TarotReadingsTable _activeHomeTarotReadingIdTable(
    _$RynAppDatabase db,
  ) => db.tarotReadings.createAlias(
    $_aliasNameGenerator(
      db.appRuntimeState.activeHomeTarotReadingId,
      db.tarotReadings.readingInstanceId,
    ),
  );

  $$TarotReadingsTableProcessedTableManager? get activeHomeTarotReadingId {
    final $_column = $_itemColumn<String>('active_home_tarot_reading_id');
    if ($_column == null) return null;
    final manager = $$TarotReadingsTableTableManager(
      $_db,
      $_db.tarotReadings,
    ).filter((f) => f.readingInstanceId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _activeHomeTarotReadingIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AppRuntimeStateTableFilterComposer
    extends Composer<_$RynAppDatabase, $AppRuntimeStateTable> {
  $$AppRuntimeStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get stateKey => $composableBuilder(
    column: $table.stateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtcUs => $composableBuilder(
    column: $table.updatedAtUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  $$TarotReadingsTableFilterComposer get activeHomeTarotReadingId {
    final $$TarotReadingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activeHomeTarotReadingId,
      referencedTable: $db.tarotReadings,
      getReferencedColumn: (t) => t.readingInstanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TarotReadingsTableFilterComposer(
            $db: $db,
            $table: $db.tarotReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppRuntimeStateTableOrderingComposer
    extends Composer<_$RynAppDatabase, $AppRuntimeStateTable> {
  $$AppRuntimeStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get stateKey => $composableBuilder(
    column: $table.stateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtcUs => $composableBuilder(
    column: $table.updatedAtUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  $$TarotReadingsTableOrderingComposer get activeHomeTarotReadingId {
    final $$TarotReadingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activeHomeTarotReadingId,
      referencedTable: $db.tarotReadings,
      getReferencedColumn: (t) => t.readingInstanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TarotReadingsTableOrderingComposer(
            $db: $db,
            $table: $db.tarotReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppRuntimeStateTableAnnotationComposer
    extends Composer<_$RynAppDatabase, $AppRuntimeStateTable> {
  $$AppRuntimeStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get stateKey =>
      $composableBuilder(column: $table.stateKey, builder: (column) => column);

  GeneratedColumn<int> get updatedAtUtcUs => $composableBuilder(
    column: $table.updatedAtUtcUs,
    builder: (column) => column,
  );

  $$TarotReadingsTableAnnotationComposer get activeHomeTarotReadingId {
    final $$TarotReadingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activeHomeTarotReadingId,
      referencedTable: $db.tarotReadings,
      getReferencedColumn: (t) => t.readingInstanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TarotReadingsTableAnnotationComposer(
            $db: $db,
            $table: $db.tarotReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppRuntimeStateTableTableManager
    extends
        RootTableManager<
          _$RynAppDatabase,
          $AppRuntimeStateTable,
          AppRuntimeStateData,
          $$AppRuntimeStateTableFilterComposer,
          $$AppRuntimeStateTableOrderingComposer,
          $$AppRuntimeStateTableAnnotationComposer,
          $$AppRuntimeStateTableCreateCompanionBuilder,
          $$AppRuntimeStateTableUpdateCompanionBuilder,
          (AppRuntimeStateData, $$AppRuntimeStateTableReferences),
          AppRuntimeStateData,
          PrefetchHooks Function({bool activeHomeTarotReadingId})
        > {
  $$AppRuntimeStateTableTableManager(
    _$RynAppDatabase db,
    $AppRuntimeStateTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppRuntimeStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppRuntimeStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppRuntimeStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> stateKey = const Value.absent(),
                Value<String?> activeHomeTarotReadingId = const Value.absent(),
                Value<int> updatedAtUtcUs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppRuntimeStateCompanion(
                stateKey: stateKey,
                activeHomeTarotReadingId: activeHomeTarotReadingId,
                updatedAtUtcUs: updatedAtUtcUs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String stateKey,
                Value<String?> activeHomeTarotReadingId = const Value.absent(),
                required int updatedAtUtcUs,
                Value<int> rowid = const Value.absent(),
              }) => AppRuntimeStateCompanion.insert(
                stateKey: stateKey,
                activeHomeTarotReadingId: activeHomeTarotReadingId,
                updatedAtUtcUs: updatedAtUtcUs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AppRuntimeStateTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({activeHomeTarotReadingId = false}) {
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
                    if (activeHomeTarotReadingId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.activeHomeTarotReadingId,
                                referencedTable:
                                    $$AppRuntimeStateTableReferences
                                        ._activeHomeTarotReadingIdTable(db),
                                referencedColumn:
                                    $$AppRuntimeStateTableReferences
                                        ._activeHomeTarotReadingIdTable(db)
                                        .readingInstanceId,
                              )
                              as T;
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

typedef $$AppRuntimeStateTableProcessedTableManager =
    ProcessedTableManager<
      _$RynAppDatabase,
      $AppRuntimeStateTable,
      AppRuntimeStateData,
      $$AppRuntimeStateTableFilterComposer,
      $$AppRuntimeStateTableOrderingComposer,
      $$AppRuntimeStateTableAnnotationComposer,
      $$AppRuntimeStateTableCreateCompanionBuilder,
      $$AppRuntimeStateTableUpdateCompanionBuilder,
      (AppRuntimeStateData, $$AppRuntimeStateTableReferences),
      AppRuntimeStateData,
      PrefetchHooks Function({bool activeHomeTarotReadingId})
    >;
typedef $$PersonsTableCreateCompanionBuilder =
    PersonsCompanion Function({
      required String id,
      required String displayName,
      required String status,
      Value<String?> relationshipSummary,
      Value<int?> firstMetOnUtcUs,
      Value<int?> archivedAtUtcUs,
      required int createdAtUtcUs,
      required int updatedAtUtcUs,
      Value<int> rowid,
    });
typedef $$PersonsTableUpdateCompanionBuilder =
    PersonsCompanion Function({
      Value<String> id,
      Value<String> displayName,
      Value<String> status,
      Value<String?> relationshipSummary,
      Value<int?> firstMetOnUtcUs,
      Value<int?> archivedAtUtcUs,
      Value<int> createdAtUtcUs,
      Value<int> updatedAtUtcUs,
      Value<int> rowid,
    });

final class $$PersonsTableReferences
    extends BaseReferences<_$RynAppDatabase, $PersonsTable, PersonRow> {
  $$PersonsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PersonRolesTable, List<PersonRoleRow>>
  _personRolesRefsTable(_$RynAppDatabase db) => MultiTypedResultKey.fromTable(
    db.personRoles,
    aliasName: $_aliasNameGenerator(db.persons.id, db.personRoles.personId),
  );

  $$PersonRolesTableProcessedTableManager get personRolesRefs {
    final manager = $$PersonRolesTableTableManager(
      $_db,
      $_db.personRoles,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_personRolesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PersonRelationshipsTable,
    List<PersonRelationshipRow>
  >
  _relationshipsFromPersonTable(_$RynAppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.personRelationships,
        aliasName: $_aliasNameGenerator(
          db.persons.id,
          db.personRelationships.fromPersonId,
        ),
      );

  $$PersonRelationshipsTableProcessedTableManager get relationshipsFromPerson {
    final manager = $$PersonRelationshipsTableTableManager(
      $_db,
      $_db.personRelationships,
    ).filter((f) => f.fromPersonId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _relationshipsFromPersonTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PersonRelationshipsTable,
    List<PersonRelationshipRow>
  >
  _relationshipsToPersonTable(_$RynAppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.personRelationships,
        aliasName: $_aliasNameGenerator(
          db.persons.id,
          db.personRelationships.toPersonId,
        ),
      );

  $$PersonRelationshipsTableProcessedTableManager get relationshipsToPerson {
    final manager = $$PersonRelationshipsTableTableManager(
      $_db,
      $_db.personRelationships,
    ).filter((f) => f.toPersonId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _relationshipsToPersonTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PersonBirthProfilesTable,
    List<PersonBirthProfileRow>
  >
  _personBirthProfilesRefsTable(_$RynAppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.personBirthProfiles,
        aliasName: $_aliasNameGenerator(
          db.persons.id,
          db.personBirthProfiles.personId,
        ),
      );

  $$PersonBirthProfilesTableProcessedTableManager get personBirthProfilesRefs {
    final manager = $$PersonBirthProfilesTableTableManager(
      $_db,
      $_db.personBirthProfiles,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _personBirthProfilesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EncountersTable, List<EncounterRow>>
  _encountersRefsTable(_$RynAppDatabase db) => MultiTypedResultKey.fromTable(
    db.encounters,
    aliasName: $_aliasNameGenerator(db.persons.id, db.encounters.personId),
  );

  $$EncountersTableProcessedTableManager get encountersRefs {
    final manager = $$EncountersTableTableManager(
      $_db,
      $_db.encounters,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_encountersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PersonsTableFilterComposer
    extends Composer<_$RynAppDatabase, $PersonsTable> {
  $$PersonsTableFilterComposer({
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

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relationshipSummary => $composableBuilder(
    column: $table.relationshipSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstMetOnUtcUs => $composableBuilder(
    column: $table.firstMetOnUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get archivedAtUtcUs => $composableBuilder(
    column: $table.archivedAtUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcUs => $composableBuilder(
    column: $table.createdAtUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtcUs => $composableBuilder(
    column: $table.updatedAtUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> personRolesRefs(
    Expression<bool> Function($$PersonRolesTableFilterComposer f) f,
  ) {
    final $$PersonRolesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personRoles,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonRolesTableFilterComposer(
            $db: $db,
            $table: $db.personRoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> relationshipsFromPerson(
    Expression<bool> Function($$PersonRelationshipsTableFilterComposer f) f,
  ) {
    final $$PersonRelationshipsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personRelationships,
      getReferencedColumn: (t) => t.fromPersonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonRelationshipsTableFilterComposer(
            $db: $db,
            $table: $db.personRelationships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> relationshipsToPerson(
    Expression<bool> Function($$PersonRelationshipsTableFilterComposer f) f,
  ) {
    final $$PersonRelationshipsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personRelationships,
      getReferencedColumn: (t) => t.toPersonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonRelationshipsTableFilterComposer(
            $db: $db,
            $table: $db.personRelationships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> personBirthProfilesRefs(
    Expression<bool> Function($$PersonBirthProfilesTableFilterComposer f) f,
  ) {
    final $$PersonBirthProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personBirthProfiles,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonBirthProfilesTableFilterComposer(
            $db: $db,
            $table: $db.personBirthProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> encountersRefs(
    Expression<bool> Function($$EncountersTableFilterComposer f) f,
  ) {
    final $$EncountersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.encounters,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EncountersTableFilterComposer(
            $db: $db,
            $table: $db.encounters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PersonsTableOrderingComposer
    extends Composer<_$RynAppDatabase, $PersonsTable> {
  $$PersonsTableOrderingComposer({
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

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relationshipSummary => $composableBuilder(
    column: $table.relationshipSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstMetOnUtcUs => $composableBuilder(
    column: $table.firstMetOnUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archivedAtUtcUs => $composableBuilder(
    column: $table.archivedAtUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcUs => $composableBuilder(
    column: $table.createdAtUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtcUs => $composableBuilder(
    column: $table.updatedAtUtcUs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PersonsTableAnnotationComposer
    extends Composer<_$RynAppDatabase, $PersonsTable> {
  $$PersonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get relationshipSummary => $composableBuilder(
    column: $table.relationshipSummary,
    builder: (column) => column,
  );

  GeneratedColumn<int> get firstMetOnUtcUs => $composableBuilder(
    column: $table.firstMetOnUtcUs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get archivedAtUtcUs => $composableBuilder(
    column: $table.archivedAtUtcUs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtUtcUs => $composableBuilder(
    column: $table.createdAtUtcUs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtcUs => $composableBuilder(
    column: $table.updatedAtUtcUs,
    builder: (column) => column,
  );

  Expression<T> personRolesRefs<T extends Object>(
    Expression<T> Function($$PersonRolesTableAnnotationComposer a) f,
  ) {
    final $$PersonRolesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personRoles,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonRolesTableAnnotationComposer(
            $db: $db,
            $table: $db.personRoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> relationshipsFromPerson<T extends Object>(
    Expression<T> Function($$PersonRelationshipsTableAnnotationComposer a) f,
  ) {
    final $$PersonRelationshipsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.personRelationships,
          getReferencedColumn: (t) => t.fromPersonId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PersonRelationshipsTableAnnotationComposer(
                $db: $db,
                $table: $db.personRelationships,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> relationshipsToPerson<T extends Object>(
    Expression<T> Function($$PersonRelationshipsTableAnnotationComposer a) f,
  ) {
    final $$PersonRelationshipsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.personRelationships,
          getReferencedColumn: (t) => t.toPersonId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PersonRelationshipsTableAnnotationComposer(
                $db: $db,
                $table: $db.personRelationships,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> personBirthProfilesRefs<T extends Object>(
    Expression<T> Function($$PersonBirthProfilesTableAnnotationComposer a) f,
  ) {
    final $$PersonBirthProfilesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.personBirthProfiles,
          getReferencedColumn: (t) => t.personId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PersonBirthProfilesTableAnnotationComposer(
                $db: $db,
                $table: $db.personBirthProfiles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> encountersRefs<T extends Object>(
    Expression<T> Function($$EncountersTableAnnotationComposer a) f,
  ) {
    final $$EncountersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.encounters,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EncountersTableAnnotationComposer(
            $db: $db,
            $table: $db.encounters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PersonsTableTableManager
    extends
        RootTableManager<
          _$RynAppDatabase,
          $PersonsTable,
          PersonRow,
          $$PersonsTableFilterComposer,
          $$PersonsTableOrderingComposer,
          $$PersonsTableAnnotationComposer,
          $$PersonsTableCreateCompanionBuilder,
          $$PersonsTableUpdateCompanionBuilder,
          (PersonRow, $$PersonsTableReferences),
          PersonRow,
          PrefetchHooks Function({
            bool personRolesRefs,
            bool relationshipsFromPerson,
            bool relationshipsToPerson,
            bool personBirthProfilesRefs,
            bool encountersRefs,
          })
        > {
  $$PersonsTableTableManager(_$RynAppDatabase db, $PersonsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> relationshipSummary = const Value.absent(),
                Value<int?> firstMetOnUtcUs = const Value.absent(),
                Value<int?> archivedAtUtcUs = const Value.absent(),
                Value<int> createdAtUtcUs = const Value.absent(),
                Value<int> updatedAtUtcUs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonsCompanion(
                id: id,
                displayName: displayName,
                status: status,
                relationshipSummary: relationshipSummary,
                firstMetOnUtcUs: firstMetOnUtcUs,
                archivedAtUtcUs: archivedAtUtcUs,
                createdAtUtcUs: createdAtUtcUs,
                updatedAtUtcUs: updatedAtUtcUs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayName,
                required String status,
                Value<String?> relationshipSummary = const Value.absent(),
                Value<int?> firstMetOnUtcUs = const Value.absent(),
                Value<int?> archivedAtUtcUs = const Value.absent(),
                required int createdAtUtcUs,
                required int updatedAtUtcUs,
                Value<int> rowid = const Value.absent(),
              }) => PersonsCompanion.insert(
                id: id,
                displayName: displayName,
                status: status,
                relationshipSummary: relationshipSummary,
                firstMetOnUtcUs: firstMetOnUtcUs,
                archivedAtUtcUs: archivedAtUtcUs,
                createdAtUtcUs: createdAtUtcUs,
                updatedAtUtcUs: updatedAtUtcUs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PersonsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                personRolesRefs = false,
                relationshipsFromPerson = false,
                relationshipsToPerson = false,
                personBirthProfilesRefs = false,
                encountersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (personRolesRefs) db.personRoles,
                    if (relationshipsFromPerson) db.personRelationships,
                    if (relationshipsToPerson) db.personRelationships,
                    if (personBirthProfilesRefs) db.personBirthProfiles,
                    if (encountersRefs) db.encounters,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (personRolesRefs)
                        await $_getPrefetchedData<
                          PersonRow,
                          $PersonsTable,
                          PersonRoleRow
                        >(
                          currentTable: table,
                          referencedTable: $$PersonsTableReferences
                              ._personRolesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PersonsTableReferences(
                                db,
                                table,
                                p0,
                              ).personRolesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.personId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (relationshipsFromPerson)
                        await $_getPrefetchedData<
                          PersonRow,
                          $PersonsTable,
                          PersonRelationshipRow
                        >(
                          currentTable: table,
                          referencedTable: $$PersonsTableReferences
                              ._relationshipsFromPersonTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PersonsTableReferences(
                                db,
                                table,
                                p0,
                              ).relationshipsFromPerson,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.fromPersonId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (relationshipsToPerson)
                        await $_getPrefetchedData<
                          PersonRow,
                          $PersonsTable,
                          PersonRelationshipRow
                        >(
                          currentTable: table,
                          referencedTable: $$PersonsTableReferences
                              ._relationshipsToPersonTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PersonsTableReferences(
                                db,
                                table,
                                p0,
                              ).relationshipsToPerson,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.toPersonId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (personBirthProfilesRefs)
                        await $_getPrefetchedData<
                          PersonRow,
                          $PersonsTable,
                          PersonBirthProfileRow
                        >(
                          currentTable: table,
                          referencedTable: $$PersonsTableReferences
                              ._personBirthProfilesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PersonsTableReferences(
                                db,
                                table,
                                p0,
                              ).personBirthProfilesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.personId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (encountersRefs)
                        await $_getPrefetchedData<
                          PersonRow,
                          $PersonsTable,
                          EncounterRow
                        >(
                          currentTable: table,
                          referencedTable: $$PersonsTableReferences
                              ._encountersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PersonsTableReferences(
                                db,
                                table,
                                p0,
                              ).encountersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.personId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PersonsTableProcessedTableManager =
    ProcessedTableManager<
      _$RynAppDatabase,
      $PersonsTable,
      PersonRow,
      $$PersonsTableFilterComposer,
      $$PersonsTableOrderingComposer,
      $$PersonsTableAnnotationComposer,
      $$PersonsTableCreateCompanionBuilder,
      $$PersonsTableUpdateCompanionBuilder,
      (PersonRow, $$PersonsTableReferences),
      PersonRow,
      PrefetchHooks Function({
        bool personRolesRefs,
        bool relationshipsFromPerson,
        bool relationshipsToPerson,
        bool personBirthProfilesRefs,
        bool encountersRefs,
      })
    >;
typedef $$PersonRolesTableCreateCompanionBuilder =
    PersonRolesCompanion Function({
      required String id,
      required String personId,
      required String roleType,
      required int effectiveFromUtcUs,
      Value<int?> effectiveToUtcUs,
      Value<String?> note,
      required int createdAtUtcUs,
      required int updatedAtUtcUs,
      Value<int> rowid,
    });
typedef $$PersonRolesTableUpdateCompanionBuilder =
    PersonRolesCompanion Function({
      Value<String> id,
      Value<String> personId,
      Value<String> roleType,
      Value<int> effectiveFromUtcUs,
      Value<int?> effectiveToUtcUs,
      Value<String?> note,
      Value<int> createdAtUtcUs,
      Value<int> updatedAtUtcUs,
      Value<int> rowid,
    });

final class $$PersonRolesTableReferences
    extends BaseReferences<_$RynAppDatabase, $PersonRolesTable, PersonRoleRow> {
  $$PersonRolesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PersonsTable _personIdTable(_$RynAppDatabase db) =>
      db.persons.createAlias(
        $_aliasNameGenerator(db.personRoles.personId, db.persons.id),
      );

  $$PersonsTableProcessedTableManager get personId {
    final $_column = $_itemColumn<String>('person_id')!;

    final manager = $$PersonsTableTableManager(
      $_db,
      $_db.persons,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PersonRolesTableFilterComposer
    extends Composer<_$RynAppDatabase, $PersonRolesTable> {
  $$PersonRolesTableFilterComposer({
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

  ColumnFilters<String> get roleType => $composableBuilder(
    column: $table.roleType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get effectiveFromUtcUs => $composableBuilder(
    column: $table.effectiveFromUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get effectiveToUtcUs => $composableBuilder(
    column: $table.effectiveToUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcUs => $composableBuilder(
    column: $table.createdAtUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtcUs => $composableBuilder(
    column: $table.updatedAtUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  $$PersonsTableFilterComposer get personId {
    final $$PersonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableFilterComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonRolesTableOrderingComposer
    extends Composer<_$RynAppDatabase, $PersonRolesTable> {
  $$PersonRolesTableOrderingComposer({
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

  ColumnOrderings<String> get roleType => $composableBuilder(
    column: $table.roleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get effectiveFromUtcUs => $composableBuilder(
    column: $table.effectiveFromUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get effectiveToUtcUs => $composableBuilder(
    column: $table.effectiveToUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcUs => $composableBuilder(
    column: $table.createdAtUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtcUs => $composableBuilder(
    column: $table.updatedAtUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  $$PersonsTableOrderingComposer get personId {
    final $$PersonsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableOrderingComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonRolesTableAnnotationComposer
    extends Composer<_$RynAppDatabase, $PersonRolesTable> {
  $$PersonRolesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get roleType =>
      $composableBuilder(column: $table.roleType, builder: (column) => column);

  GeneratedColumn<int> get effectiveFromUtcUs => $composableBuilder(
    column: $table.effectiveFromUtcUs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get effectiveToUtcUs => $composableBuilder(
    column: $table.effectiveToUtcUs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAtUtcUs => $composableBuilder(
    column: $table.createdAtUtcUs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtcUs => $composableBuilder(
    column: $table.updatedAtUtcUs,
    builder: (column) => column,
  );

  $$PersonsTableAnnotationComposer get personId {
    final $$PersonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableAnnotationComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonRolesTableTableManager
    extends
        RootTableManager<
          _$RynAppDatabase,
          $PersonRolesTable,
          PersonRoleRow,
          $$PersonRolesTableFilterComposer,
          $$PersonRolesTableOrderingComposer,
          $$PersonRolesTableAnnotationComposer,
          $$PersonRolesTableCreateCompanionBuilder,
          $$PersonRolesTableUpdateCompanionBuilder,
          (PersonRoleRow, $$PersonRolesTableReferences),
          PersonRoleRow,
          PrefetchHooks Function({bool personId})
        > {
  $$PersonRolesTableTableManager(_$RynAppDatabase db, $PersonRolesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonRolesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonRolesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonRolesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> personId = const Value.absent(),
                Value<String> roleType = const Value.absent(),
                Value<int> effectiveFromUtcUs = const Value.absent(),
                Value<int?> effectiveToUtcUs = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> createdAtUtcUs = const Value.absent(),
                Value<int> updatedAtUtcUs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonRolesCompanion(
                id: id,
                personId: personId,
                roleType: roleType,
                effectiveFromUtcUs: effectiveFromUtcUs,
                effectiveToUtcUs: effectiveToUtcUs,
                note: note,
                createdAtUtcUs: createdAtUtcUs,
                updatedAtUtcUs: updatedAtUtcUs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String personId,
                required String roleType,
                required int effectiveFromUtcUs,
                Value<int?> effectiveToUtcUs = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required int createdAtUtcUs,
                required int updatedAtUtcUs,
                Value<int> rowid = const Value.absent(),
              }) => PersonRolesCompanion.insert(
                id: id,
                personId: personId,
                roleType: roleType,
                effectiveFromUtcUs: effectiveFromUtcUs,
                effectiveToUtcUs: effectiveToUtcUs,
                note: note,
                createdAtUtcUs: createdAtUtcUs,
                updatedAtUtcUs: updatedAtUtcUs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PersonRolesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({personId = false}) {
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
                    if (personId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.personId,
                                referencedTable: $$PersonRolesTableReferences
                                    ._personIdTable(db),
                                referencedColumn: $$PersonRolesTableReferences
                                    ._personIdTable(db)
                                    .id,
                              )
                              as T;
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

typedef $$PersonRolesTableProcessedTableManager =
    ProcessedTableManager<
      _$RynAppDatabase,
      $PersonRolesTable,
      PersonRoleRow,
      $$PersonRolesTableFilterComposer,
      $$PersonRolesTableOrderingComposer,
      $$PersonRolesTableAnnotationComposer,
      $$PersonRolesTableCreateCompanionBuilder,
      $$PersonRolesTableUpdateCompanionBuilder,
      (PersonRoleRow, $$PersonRolesTableReferences),
      PersonRoleRow,
      PrefetchHooks Function({bool personId})
    >;
typedef $$PersonRelationshipsTableCreateCompanionBuilder =
    PersonRelationshipsCompanion Function({
      required String id,
      required String fromPersonId,
      required String toPersonId,
      required String relationshipType,
      required int effectiveFromUtcUs,
      Value<int?> effectiveToUtcUs,
      Value<String?> note,
      required int createdAtUtcUs,
      required int updatedAtUtcUs,
      Value<int> rowid,
    });
typedef $$PersonRelationshipsTableUpdateCompanionBuilder =
    PersonRelationshipsCompanion Function({
      Value<String> id,
      Value<String> fromPersonId,
      Value<String> toPersonId,
      Value<String> relationshipType,
      Value<int> effectiveFromUtcUs,
      Value<int?> effectiveToUtcUs,
      Value<String?> note,
      Value<int> createdAtUtcUs,
      Value<int> updatedAtUtcUs,
      Value<int> rowid,
    });

final class $$PersonRelationshipsTableReferences
    extends
        BaseReferences<
          _$RynAppDatabase,
          $PersonRelationshipsTable,
          PersonRelationshipRow
        > {
  $$PersonRelationshipsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PersonsTable _fromPersonIdTable(_$RynAppDatabase db) =>
      db.persons.createAlias(
        $_aliasNameGenerator(
          db.personRelationships.fromPersonId,
          db.persons.id,
        ),
      );

  $$PersonsTableProcessedTableManager get fromPersonId {
    final $_column = $_itemColumn<String>('from_person_id')!;

    final manager = $$PersonsTableTableManager(
      $_db,
      $_db.persons,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fromPersonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PersonsTable _toPersonIdTable(_$RynAppDatabase db) =>
      db.persons.createAlias(
        $_aliasNameGenerator(db.personRelationships.toPersonId, db.persons.id),
      );

  $$PersonsTableProcessedTableManager get toPersonId {
    final $_column = $_itemColumn<String>('to_person_id')!;

    final manager = $$PersonsTableTableManager(
      $_db,
      $_db.persons,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toPersonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PersonRelationshipsTableFilterComposer
    extends Composer<_$RynAppDatabase, $PersonRelationshipsTable> {
  $$PersonRelationshipsTableFilterComposer({
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

  ColumnFilters<String> get relationshipType => $composableBuilder(
    column: $table.relationshipType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get effectiveFromUtcUs => $composableBuilder(
    column: $table.effectiveFromUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get effectiveToUtcUs => $composableBuilder(
    column: $table.effectiveToUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcUs => $composableBuilder(
    column: $table.createdAtUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtcUs => $composableBuilder(
    column: $table.updatedAtUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  $$PersonsTableFilterComposer get fromPersonId {
    final $$PersonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromPersonId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableFilterComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PersonsTableFilterComposer get toPersonId {
    final $$PersonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toPersonId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableFilterComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonRelationshipsTableOrderingComposer
    extends Composer<_$RynAppDatabase, $PersonRelationshipsTable> {
  $$PersonRelationshipsTableOrderingComposer({
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

  ColumnOrderings<String> get relationshipType => $composableBuilder(
    column: $table.relationshipType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get effectiveFromUtcUs => $composableBuilder(
    column: $table.effectiveFromUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get effectiveToUtcUs => $composableBuilder(
    column: $table.effectiveToUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcUs => $composableBuilder(
    column: $table.createdAtUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtcUs => $composableBuilder(
    column: $table.updatedAtUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  $$PersonsTableOrderingComposer get fromPersonId {
    final $$PersonsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromPersonId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableOrderingComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PersonsTableOrderingComposer get toPersonId {
    final $$PersonsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toPersonId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableOrderingComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonRelationshipsTableAnnotationComposer
    extends Composer<_$RynAppDatabase, $PersonRelationshipsTable> {
  $$PersonRelationshipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get relationshipType => $composableBuilder(
    column: $table.relationshipType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get effectiveFromUtcUs => $composableBuilder(
    column: $table.effectiveFromUtcUs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get effectiveToUtcUs => $composableBuilder(
    column: $table.effectiveToUtcUs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAtUtcUs => $composableBuilder(
    column: $table.createdAtUtcUs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtcUs => $composableBuilder(
    column: $table.updatedAtUtcUs,
    builder: (column) => column,
  );

  $$PersonsTableAnnotationComposer get fromPersonId {
    final $$PersonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromPersonId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableAnnotationComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PersonsTableAnnotationComposer get toPersonId {
    final $$PersonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toPersonId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableAnnotationComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonRelationshipsTableTableManager
    extends
        RootTableManager<
          _$RynAppDatabase,
          $PersonRelationshipsTable,
          PersonRelationshipRow,
          $$PersonRelationshipsTableFilterComposer,
          $$PersonRelationshipsTableOrderingComposer,
          $$PersonRelationshipsTableAnnotationComposer,
          $$PersonRelationshipsTableCreateCompanionBuilder,
          $$PersonRelationshipsTableUpdateCompanionBuilder,
          (PersonRelationshipRow, $$PersonRelationshipsTableReferences),
          PersonRelationshipRow,
          PrefetchHooks Function({bool fromPersonId, bool toPersonId})
        > {
  $$PersonRelationshipsTableTableManager(
    _$RynAppDatabase db,
    $PersonRelationshipsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonRelationshipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonRelationshipsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PersonRelationshipsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fromPersonId = const Value.absent(),
                Value<String> toPersonId = const Value.absent(),
                Value<String> relationshipType = const Value.absent(),
                Value<int> effectiveFromUtcUs = const Value.absent(),
                Value<int?> effectiveToUtcUs = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> createdAtUtcUs = const Value.absent(),
                Value<int> updatedAtUtcUs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonRelationshipsCompanion(
                id: id,
                fromPersonId: fromPersonId,
                toPersonId: toPersonId,
                relationshipType: relationshipType,
                effectiveFromUtcUs: effectiveFromUtcUs,
                effectiveToUtcUs: effectiveToUtcUs,
                note: note,
                createdAtUtcUs: createdAtUtcUs,
                updatedAtUtcUs: updatedAtUtcUs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fromPersonId,
                required String toPersonId,
                required String relationshipType,
                required int effectiveFromUtcUs,
                Value<int?> effectiveToUtcUs = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required int createdAtUtcUs,
                required int updatedAtUtcUs,
                Value<int> rowid = const Value.absent(),
              }) => PersonRelationshipsCompanion.insert(
                id: id,
                fromPersonId: fromPersonId,
                toPersonId: toPersonId,
                relationshipType: relationshipType,
                effectiveFromUtcUs: effectiveFromUtcUs,
                effectiveToUtcUs: effectiveToUtcUs,
                note: note,
                createdAtUtcUs: createdAtUtcUs,
                updatedAtUtcUs: updatedAtUtcUs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PersonRelationshipsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({fromPersonId = false, toPersonId = false}) {
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
                    if (fromPersonId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.fromPersonId,
                                referencedTable:
                                    $$PersonRelationshipsTableReferences
                                        ._fromPersonIdTable(db),
                                referencedColumn:
                                    $$PersonRelationshipsTableReferences
                                        ._fromPersonIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (toPersonId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.toPersonId,
                                referencedTable:
                                    $$PersonRelationshipsTableReferences
                                        ._toPersonIdTable(db),
                                referencedColumn:
                                    $$PersonRelationshipsTableReferences
                                        ._toPersonIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$PersonRelationshipsTableProcessedTableManager =
    ProcessedTableManager<
      _$RynAppDatabase,
      $PersonRelationshipsTable,
      PersonRelationshipRow,
      $$PersonRelationshipsTableFilterComposer,
      $$PersonRelationshipsTableOrderingComposer,
      $$PersonRelationshipsTableAnnotationComposer,
      $$PersonRelationshipsTableCreateCompanionBuilder,
      $$PersonRelationshipsTableUpdateCompanionBuilder,
      (PersonRelationshipRow, $$PersonRelationshipsTableReferences),
      PersonRelationshipRow,
      PrefetchHooks Function({bool fromPersonId, bool toPersonId})
    >;
typedef $$PersonBirthProfilesTableCreateCompanionBuilder =
    PersonBirthProfilesCompanion Function({
      required String id,
      required String personId,
      required int revisionNumber,
      Value<String?> birthDate,
      required String birthDatePrecision,
      Value<String?> birthTime,
      required String birthTimePrecision,
      Value<String?> birthplaceLabel,
      Value<String?> timeZoneId,
      Value<int?> utcOffsetMinutesAtBirth,
      required String calendarSystem,
      Value<bool?> isLeapMonth,
      Value<String?> sourceNote,
      required String verificationState,
      Value<String?> supersedesBirthProfileId,
      Value<int?> supersededAtUtcUs,
      required int createdAtUtcUs,
      Value<int> rowid,
    });
typedef $$PersonBirthProfilesTableUpdateCompanionBuilder =
    PersonBirthProfilesCompanion Function({
      Value<String> id,
      Value<String> personId,
      Value<int> revisionNumber,
      Value<String?> birthDate,
      Value<String> birthDatePrecision,
      Value<String?> birthTime,
      Value<String> birthTimePrecision,
      Value<String?> birthplaceLabel,
      Value<String?> timeZoneId,
      Value<int?> utcOffsetMinutesAtBirth,
      Value<String> calendarSystem,
      Value<bool?> isLeapMonth,
      Value<String?> sourceNote,
      Value<String> verificationState,
      Value<String?> supersedesBirthProfileId,
      Value<int?> supersededAtUtcUs,
      Value<int> createdAtUtcUs,
      Value<int> rowid,
    });

final class $$PersonBirthProfilesTableReferences
    extends
        BaseReferences<
          _$RynAppDatabase,
          $PersonBirthProfilesTable,
          PersonBirthProfileRow
        > {
  $$PersonBirthProfilesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PersonsTable _personIdTable(_$RynAppDatabase db) =>
      db.persons.createAlias(
        $_aliasNameGenerator(db.personBirthProfiles.personId, db.persons.id),
      );

  $$PersonsTableProcessedTableManager get personId {
    final $_column = $_itemColumn<String>('person_id')!;

    final manager = $$PersonsTableTableManager(
      $_db,
      $_db.persons,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PersonBirthProfilesTable _supersedesBirthProfileIdTable(
    _$RynAppDatabase db,
  ) => db.personBirthProfiles.createAlias(
    $_aliasNameGenerator(
      db.personBirthProfiles.supersedesBirthProfileId,
      db.personBirthProfiles.id,
    ),
  );

  $$PersonBirthProfilesTableProcessedTableManager?
  get supersedesBirthProfileId {
    final $_column = $_itemColumn<String>('supersedes_birth_profile_id');
    if ($_column == null) return null;
    final manager = $$PersonBirthProfilesTableTableManager(
      $_db,
      $_db.personBirthProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _supersedesBirthProfileIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PersonBirthProfilesTableFilterComposer
    extends Composer<_$RynAppDatabase, $PersonBirthProfilesTable> {
  $$PersonBirthProfilesTableFilterComposer({
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

  ColumnFilters<int> get revisionNumber => $composableBuilder(
    column: $table.revisionNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthDatePrecision => $composableBuilder(
    column: $table.birthDatePrecision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthTime => $composableBuilder(
    column: $table.birthTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthTimePrecision => $composableBuilder(
    column: $table.birthTimePrecision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthplaceLabel => $composableBuilder(
    column: $table.birthplaceLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeZoneId => $composableBuilder(
    column: $table.timeZoneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get utcOffsetMinutesAtBirth => $composableBuilder(
    column: $table.utcOffsetMinutesAtBirth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calendarSystem => $composableBuilder(
    column: $table.calendarSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLeapMonth => $composableBuilder(
    column: $table.isLeapMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceNote => $composableBuilder(
    column: $table.sourceNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verificationState => $composableBuilder(
    column: $table.verificationState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get supersededAtUtcUs => $composableBuilder(
    column: $table.supersededAtUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcUs => $composableBuilder(
    column: $table.createdAtUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  $$PersonsTableFilterComposer get personId {
    final $$PersonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableFilterComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PersonBirthProfilesTableFilterComposer get supersedesBirthProfileId {
    final $$PersonBirthProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supersedesBirthProfileId,
      referencedTable: $db.personBirthProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonBirthProfilesTableFilterComposer(
            $db: $db,
            $table: $db.personBirthProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonBirthProfilesTableOrderingComposer
    extends Composer<_$RynAppDatabase, $PersonBirthProfilesTable> {
  $$PersonBirthProfilesTableOrderingComposer({
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

  ColumnOrderings<int> get revisionNumber => $composableBuilder(
    column: $table.revisionNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthDatePrecision => $composableBuilder(
    column: $table.birthDatePrecision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthTime => $composableBuilder(
    column: $table.birthTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthTimePrecision => $composableBuilder(
    column: $table.birthTimePrecision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthplaceLabel => $composableBuilder(
    column: $table.birthplaceLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeZoneId => $composableBuilder(
    column: $table.timeZoneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get utcOffsetMinutesAtBirth => $composableBuilder(
    column: $table.utcOffsetMinutesAtBirth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calendarSystem => $composableBuilder(
    column: $table.calendarSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLeapMonth => $composableBuilder(
    column: $table.isLeapMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceNote => $composableBuilder(
    column: $table.sourceNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verificationState => $composableBuilder(
    column: $table.verificationState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get supersededAtUtcUs => $composableBuilder(
    column: $table.supersededAtUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcUs => $composableBuilder(
    column: $table.createdAtUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  $$PersonsTableOrderingComposer get personId {
    final $$PersonsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableOrderingComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PersonBirthProfilesTableOrderingComposer get supersedesBirthProfileId {
    final $$PersonBirthProfilesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.supersedesBirthProfileId,
          referencedTable: $db.personBirthProfiles,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PersonBirthProfilesTableOrderingComposer(
                $db: $db,
                $table: $db.personBirthProfiles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$PersonBirthProfilesTableAnnotationComposer
    extends Composer<_$RynAppDatabase, $PersonBirthProfilesTable> {
  $$PersonBirthProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get revisionNumber => $composableBuilder(
    column: $table.revisionNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get birthDatePrecision => $composableBuilder(
    column: $table.birthDatePrecision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get birthTime =>
      $composableBuilder(column: $table.birthTime, builder: (column) => column);

  GeneratedColumn<String> get birthTimePrecision => $composableBuilder(
    column: $table.birthTimePrecision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get birthplaceLabel => $composableBuilder(
    column: $table.birthplaceLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timeZoneId => $composableBuilder(
    column: $table.timeZoneId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get utcOffsetMinutesAtBirth => $composableBuilder(
    column: $table.utcOffsetMinutesAtBirth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get calendarSystem => $composableBuilder(
    column: $table.calendarSystem,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLeapMonth => $composableBuilder(
    column: $table.isLeapMonth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceNote => $composableBuilder(
    column: $table.sourceNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get verificationState => $composableBuilder(
    column: $table.verificationState,
    builder: (column) => column,
  );

  GeneratedColumn<int> get supersededAtUtcUs => $composableBuilder(
    column: $table.supersededAtUtcUs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtUtcUs => $composableBuilder(
    column: $table.createdAtUtcUs,
    builder: (column) => column,
  );

  $$PersonsTableAnnotationComposer get personId {
    final $$PersonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableAnnotationComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PersonBirthProfilesTableAnnotationComposer get supersedesBirthProfileId {
    final $$PersonBirthProfilesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.supersedesBirthProfileId,
          referencedTable: $db.personBirthProfiles,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PersonBirthProfilesTableAnnotationComposer(
                $db: $db,
                $table: $db.personBirthProfiles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$PersonBirthProfilesTableTableManager
    extends
        RootTableManager<
          _$RynAppDatabase,
          $PersonBirthProfilesTable,
          PersonBirthProfileRow,
          $$PersonBirthProfilesTableFilterComposer,
          $$PersonBirthProfilesTableOrderingComposer,
          $$PersonBirthProfilesTableAnnotationComposer,
          $$PersonBirthProfilesTableCreateCompanionBuilder,
          $$PersonBirthProfilesTableUpdateCompanionBuilder,
          (PersonBirthProfileRow, $$PersonBirthProfilesTableReferences),
          PersonBirthProfileRow,
          PrefetchHooks Function({bool personId, bool supersedesBirthProfileId})
        > {
  $$PersonBirthProfilesTableTableManager(
    _$RynAppDatabase db,
    $PersonBirthProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonBirthProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonBirthProfilesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PersonBirthProfilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> personId = const Value.absent(),
                Value<int> revisionNumber = const Value.absent(),
                Value<String?> birthDate = const Value.absent(),
                Value<String> birthDatePrecision = const Value.absent(),
                Value<String?> birthTime = const Value.absent(),
                Value<String> birthTimePrecision = const Value.absent(),
                Value<String?> birthplaceLabel = const Value.absent(),
                Value<String?> timeZoneId = const Value.absent(),
                Value<int?> utcOffsetMinutesAtBirth = const Value.absent(),
                Value<String> calendarSystem = const Value.absent(),
                Value<bool?> isLeapMonth = const Value.absent(),
                Value<String?> sourceNote = const Value.absent(),
                Value<String> verificationState = const Value.absent(),
                Value<String?> supersedesBirthProfileId = const Value.absent(),
                Value<int?> supersededAtUtcUs = const Value.absent(),
                Value<int> createdAtUtcUs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonBirthProfilesCompanion(
                id: id,
                personId: personId,
                revisionNumber: revisionNumber,
                birthDate: birthDate,
                birthDatePrecision: birthDatePrecision,
                birthTime: birthTime,
                birthTimePrecision: birthTimePrecision,
                birthplaceLabel: birthplaceLabel,
                timeZoneId: timeZoneId,
                utcOffsetMinutesAtBirth: utcOffsetMinutesAtBirth,
                calendarSystem: calendarSystem,
                isLeapMonth: isLeapMonth,
                sourceNote: sourceNote,
                verificationState: verificationState,
                supersedesBirthProfileId: supersedesBirthProfileId,
                supersededAtUtcUs: supersededAtUtcUs,
                createdAtUtcUs: createdAtUtcUs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String personId,
                required int revisionNumber,
                Value<String?> birthDate = const Value.absent(),
                required String birthDatePrecision,
                Value<String?> birthTime = const Value.absent(),
                required String birthTimePrecision,
                Value<String?> birthplaceLabel = const Value.absent(),
                Value<String?> timeZoneId = const Value.absent(),
                Value<int?> utcOffsetMinutesAtBirth = const Value.absent(),
                required String calendarSystem,
                Value<bool?> isLeapMonth = const Value.absent(),
                Value<String?> sourceNote = const Value.absent(),
                required String verificationState,
                Value<String?> supersedesBirthProfileId = const Value.absent(),
                Value<int?> supersededAtUtcUs = const Value.absent(),
                required int createdAtUtcUs,
                Value<int> rowid = const Value.absent(),
              }) => PersonBirthProfilesCompanion.insert(
                id: id,
                personId: personId,
                revisionNumber: revisionNumber,
                birthDate: birthDate,
                birthDatePrecision: birthDatePrecision,
                birthTime: birthTime,
                birthTimePrecision: birthTimePrecision,
                birthplaceLabel: birthplaceLabel,
                timeZoneId: timeZoneId,
                utcOffsetMinutesAtBirth: utcOffsetMinutesAtBirth,
                calendarSystem: calendarSystem,
                isLeapMonth: isLeapMonth,
                sourceNote: sourceNote,
                verificationState: verificationState,
                supersedesBirthProfileId: supersedesBirthProfileId,
                supersededAtUtcUs: supersededAtUtcUs,
                createdAtUtcUs: createdAtUtcUs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PersonBirthProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({personId = false, supersedesBirthProfileId = false}) {
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
                        if (personId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.personId,
                                    referencedTable:
                                        $$PersonBirthProfilesTableReferences
                                            ._personIdTable(db),
                                    referencedColumn:
                                        $$PersonBirthProfilesTableReferences
                                            ._personIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (supersedesBirthProfileId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn:
                                        table.supersedesBirthProfileId,
                                    referencedTable:
                                        $$PersonBirthProfilesTableReferences
                                            ._supersedesBirthProfileIdTable(db),
                                    referencedColumn:
                                        $$PersonBirthProfilesTableReferences
                                            ._supersedesBirthProfileIdTable(db)
                                            .id,
                                  )
                                  as T;
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

typedef $$PersonBirthProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$RynAppDatabase,
      $PersonBirthProfilesTable,
      PersonBirthProfileRow,
      $$PersonBirthProfilesTableFilterComposer,
      $$PersonBirthProfilesTableOrderingComposer,
      $$PersonBirthProfilesTableAnnotationComposer,
      $$PersonBirthProfilesTableCreateCompanionBuilder,
      $$PersonBirthProfilesTableUpdateCompanionBuilder,
      (PersonBirthProfileRow, $$PersonBirthProfilesTableReferences),
      PersonBirthProfileRow,
      PrefetchHooks Function({bool personId, bool supersedesBirthProfileId})
    >;
typedef $$EncountersTableCreateCompanionBuilder =
    EncountersCompanion Function({
      required String id,
      required String personId,
      required int occurredAtUtcUs,
      required String occurredPrecision,
      required String encounterType,
      required String title,
      Value<String?> summary,
      required String status,
      Value<int?> followUpAtUtcUs,
      Value<int?> archivedAtUtcUs,
      required int createdAtUtcUs,
      required int updatedAtUtcUs,
      Value<int> rowid,
    });
typedef $$EncountersTableUpdateCompanionBuilder =
    EncountersCompanion Function({
      Value<String> id,
      Value<String> personId,
      Value<int> occurredAtUtcUs,
      Value<String> occurredPrecision,
      Value<String> encounterType,
      Value<String> title,
      Value<String?> summary,
      Value<String> status,
      Value<int?> followUpAtUtcUs,
      Value<int?> archivedAtUtcUs,
      Value<int> createdAtUtcUs,
      Value<int> updatedAtUtcUs,
      Value<int> rowid,
    });

final class $$EncountersTableReferences
    extends BaseReferences<_$RynAppDatabase, $EncountersTable, EncounterRow> {
  $$EncountersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PersonsTable _personIdTable(_$RynAppDatabase db) => db.persons
      .createAlias($_aliasNameGenerator(db.encounters.personId, db.persons.id));

  $$PersonsTableProcessedTableManager get personId {
    final $_column = $_itemColumn<String>('person_id')!;

    final manager = $$PersonsTableTableManager(
      $_db,
      $_db.persons,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EncounterNotesTable, List<EncounterNoteRow>>
  _encounterNotesRefsTable(_$RynAppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.encounterNotes,
        aliasName: $_aliasNameGenerator(
          db.encounters.id,
          db.encounterNotes.encounterId,
        ),
      );

  $$EncounterNotesTableProcessedTableManager get encounterNotesRefs {
    final manager = $$EncounterNotesTableTableManager(
      $_db,
      $_db.encounterNotes,
    ).filter((f) => f.encounterId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_encounterNotesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EncountersTableFilterComposer
    extends Composer<_$RynAppDatabase, $EncountersTable> {
  $$EncountersTableFilterComposer({
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

  ColumnFilters<int> get occurredAtUtcUs => $composableBuilder(
    column: $table.occurredAtUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occurredPrecision => $composableBuilder(
    column: $table.occurredPrecision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encounterType => $composableBuilder(
    column: $table.encounterType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get followUpAtUtcUs => $composableBuilder(
    column: $table.followUpAtUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get archivedAtUtcUs => $composableBuilder(
    column: $table.archivedAtUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcUs => $composableBuilder(
    column: $table.createdAtUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtcUs => $composableBuilder(
    column: $table.updatedAtUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  $$PersonsTableFilterComposer get personId {
    final $$PersonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableFilterComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> encounterNotesRefs(
    Expression<bool> Function($$EncounterNotesTableFilterComposer f) f,
  ) {
    final $$EncounterNotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.encounterNotes,
      getReferencedColumn: (t) => t.encounterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EncounterNotesTableFilterComposer(
            $db: $db,
            $table: $db.encounterNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EncountersTableOrderingComposer
    extends Composer<_$RynAppDatabase, $EncountersTable> {
  $$EncountersTableOrderingComposer({
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

  ColumnOrderings<int> get occurredAtUtcUs => $composableBuilder(
    column: $table.occurredAtUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occurredPrecision => $composableBuilder(
    column: $table.occurredPrecision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encounterType => $composableBuilder(
    column: $table.encounterType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get followUpAtUtcUs => $composableBuilder(
    column: $table.followUpAtUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archivedAtUtcUs => $composableBuilder(
    column: $table.archivedAtUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcUs => $composableBuilder(
    column: $table.createdAtUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtcUs => $composableBuilder(
    column: $table.updatedAtUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  $$PersonsTableOrderingComposer get personId {
    final $$PersonsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableOrderingComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EncountersTableAnnotationComposer
    extends Composer<_$RynAppDatabase, $EncountersTable> {
  $$EncountersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get occurredAtUtcUs => $composableBuilder(
    column: $table.occurredAtUtcUs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get occurredPrecision => $composableBuilder(
    column: $table.occurredPrecision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get encounterType => $composableBuilder(
    column: $table.encounterType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get followUpAtUtcUs => $composableBuilder(
    column: $table.followUpAtUtcUs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get archivedAtUtcUs => $composableBuilder(
    column: $table.archivedAtUtcUs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtUtcUs => $composableBuilder(
    column: $table.createdAtUtcUs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtcUs => $composableBuilder(
    column: $table.updatedAtUtcUs,
    builder: (column) => column,
  );

  $$PersonsTableAnnotationComposer get personId {
    final $$PersonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableAnnotationComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> encounterNotesRefs<T extends Object>(
    Expression<T> Function($$EncounterNotesTableAnnotationComposer a) f,
  ) {
    final $$EncounterNotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.encounterNotes,
      getReferencedColumn: (t) => t.encounterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EncounterNotesTableAnnotationComposer(
            $db: $db,
            $table: $db.encounterNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EncountersTableTableManager
    extends
        RootTableManager<
          _$RynAppDatabase,
          $EncountersTable,
          EncounterRow,
          $$EncountersTableFilterComposer,
          $$EncountersTableOrderingComposer,
          $$EncountersTableAnnotationComposer,
          $$EncountersTableCreateCompanionBuilder,
          $$EncountersTableUpdateCompanionBuilder,
          (EncounterRow, $$EncountersTableReferences),
          EncounterRow,
          PrefetchHooks Function({bool personId, bool encounterNotesRefs})
        > {
  $$EncountersTableTableManager(_$RynAppDatabase db, $EncountersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EncountersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EncountersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EncountersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> personId = const Value.absent(),
                Value<int> occurredAtUtcUs = const Value.absent(),
                Value<String> occurredPrecision = const Value.absent(),
                Value<String> encounterType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> followUpAtUtcUs = const Value.absent(),
                Value<int?> archivedAtUtcUs = const Value.absent(),
                Value<int> createdAtUtcUs = const Value.absent(),
                Value<int> updatedAtUtcUs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EncountersCompanion(
                id: id,
                personId: personId,
                occurredAtUtcUs: occurredAtUtcUs,
                occurredPrecision: occurredPrecision,
                encounterType: encounterType,
                title: title,
                summary: summary,
                status: status,
                followUpAtUtcUs: followUpAtUtcUs,
                archivedAtUtcUs: archivedAtUtcUs,
                createdAtUtcUs: createdAtUtcUs,
                updatedAtUtcUs: updatedAtUtcUs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String personId,
                required int occurredAtUtcUs,
                required String occurredPrecision,
                required String encounterType,
                required String title,
                Value<String?> summary = const Value.absent(),
                required String status,
                Value<int?> followUpAtUtcUs = const Value.absent(),
                Value<int?> archivedAtUtcUs = const Value.absent(),
                required int createdAtUtcUs,
                required int updatedAtUtcUs,
                Value<int> rowid = const Value.absent(),
              }) => EncountersCompanion.insert(
                id: id,
                personId: personId,
                occurredAtUtcUs: occurredAtUtcUs,
                occurredPrecision: occurredPrecision,
                encounterType: encounterType,
                title: title,
                summary: summary,
                status: status,
                followUpAtUtcUs: followUpAtUtcUs,
                archivedAtUtcUs: archivedAtUtcUs,
                createdAtUtcUs: createdAtUtcUs,
                updatedAtUtcUs: updatedAtUtcUs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EncountersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({personId = false, encounterNotesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (encounterNotesRefs) db.encounterNotes,
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
                        if (personId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.personId,
                                    referencedTable: $$EncountersTableReferences
                                        ._personIdTable(db),
                                    referencedColumn:
                                        $$EncountersTableReferences
                                            ._personIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (encounterNotesRefs)
                        await $_getPrefetchedData<
                          EncounterRow,
                          $EncountersTable,
                          EncounterNoteRow
                        >(
                          currentTable: table,
                          referencedTable: $$EncountersTableReferences
                              ._encounterNotesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EncountersTableReferences(
                                db,
                                table,
                                p0,
                              ).encounterNotesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.encounterId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EncountersTableProcessedTableManager =
    ProcessedTableManager<
      _$RynAppDatabase,
      $EncountersTable,
      EncounterRow,
      $$EncountersTableFilterComposer,
      $$EncountersTableOrderingComposer,
      $$EncountersTableAnnotationComposer,
      $$EncountersTableCreateCompanionBuilder,
      $$EncountersTableUpdateCompanionBuilder,
      (EncounterRow, $$EncountersTableReferences),
      EncounterRow,
      PrefetchHooks Function({bool personId, bool encounterNotesRefs})
    >;
typedef $$EncounterNotesTableCreateCompanionBuilder =
    EncounterNotesCompanion Function({
      required String id,
      required String encounterId,
      required String noteType,
      required String body,
      required int recordedAtUtcUs,
      required int updatedAtUtcUs,
      Value<String?> supersedesNoteId,
      Value<int?> supersededAtUtcUs,
      Value<int?> redactedAtUtcUs,
      Value<int> rowid,
    });
typedef $$EncounterNotesTableUpdateCompanionBuilder =
    EncounterNotesCompanion Function({
      Value<String> id,
      Value<String> encounterId,
      Value<String> noteType,
      Value<String> body,
      Value<int> recordedAtUtcUs,
      Value<int> updatedAtUtcUs,
      Value<String?> supersedesNoteId,
      Value<int?> supersededAtUtcUs,
      Value<int?> redactedAtUtcUs,
      Value<int> rowid,
    });

final class $$EncounterNotesTableReferences
    extends
        BaseReferences<
          _$RynAppDatabase,
          $EncounterNotesTable,
          EncounterNoteRow
        > {
  $$EncounterNotesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EncountersTable _encounterIdTable(_$RynAppDatabase db) =>
      db.encounters.createAlias(
        $_aliasNameGenerator(db.encounterNotes.encounterId, db.encounters.id),
      );

  $$EncountersTableProcessedTableManager get encounterId {
    final $_column = $_itemColumn<String>('encounter_id')!;

    final manager = $$EncountersTableTableManager(
      $_db,
      $_db.encounters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_encounterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EncounterNotesTable _supersedesNoteIdTable(_$RynAppDatabase db) =>
      db.encounterNotes.createAlias(
        $_aliasNameGenerator(
          db.encounterNotes.supersedesNoteId,
          db.encounterNotes.id,
        ),
      );

  $$EncounterNotesTableProcessedTableManager? get supersedesNoteId {
    final $_column = $_itemColumn<String>('supersedes_note_id');
    if ($_column == null) return null;
    final manager = $$EncounterNotesTableTableManager(
      $_db,
      $_db.encounterNotes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supersedesNoteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EncounterNotesTableFilterComposer
    extends Composer<_$RynAppDatabase, $EncounterNotesTable> {
  $$EncounterNotesTableFilterComposer({
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

  ColumnFilters<String> get noteType => $composableBuilder(
    column: $table.noteType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordedAtUtcUs => $composableBuilder(
    column: $table.recordedAtUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtcUs => $composableBuilder(
    column: $table.updatedAtUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get supersededAtUtcUs => $composableBuilder(
    column: $table.supersededAtUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get redactedAtUtcUs => $composableBuilder(
    column: $table.redactedAtUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  $$EncountersTableFilterComposer get encounterId {
    final $$EncountersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.encounterId,
      referencedTable: $db.encounters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EncountersTableFilterComposer(
            $db: $db,
            $table: $db.encounters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EncounterNotesTableFilterComposer get supersedesNoteId {
    final $$EncounterNotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supersedesNoteId,
      referencedTable: $db.encounterNotes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EncounterNotesTableFilterComposer(
            $db: $db,
            $table: $db.encounterNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EncounterNotesTableOrderingComposer
    extends Composer<_$RynAppDatabase, $EncounterNotesTable> {
  $$EncounterNotesTableOrderingComposer({
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

  ColumnOrderings<String> get noteType => $composableBuilder(
    column: $table.noteType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordedAtUtcUs => $composableBuilder(
    column: $table.recordedAtUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtcUs => $composableBuilder(
    column: $table.updatedAtUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get supersededAtUtcUs => $composableBuilder(
    column: $table.supersededAtUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get redactedAtUtcUs => $composableBuilder(
    column: $table.redactedAtUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  $$EncountersTableOrderingComposer get encounterId {
    final $$EncountersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.encounterId,
      referencedTable: $db.encounters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EncountersTableOrderingComposer(
            $db: $db,
            $table: $db.encounters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EncounterNotesTableOrderingComposer get supersedesNoteId {
    final $$EncounterNotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supersedesNoteId,
      referencedTable: $db.encounterNotes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EncounterNotesTableOrderingComposer(
            $db: $db,
            $table: $db.encounterNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EncounterNotesTableAnnotationComposer
    extends Composer<_$RynAppDatabase, $EncounterNotesTable> {
  $$EncounterNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get noteType =>
      $composableBuilder(column: $table.noteType, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<int> get recordedAtUtcUs => $composableBuilder(
    column: $table.recordedAtUtcUs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtcUs => $composableBuilder(
    column: $table.updatedAtUtcUs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get supersededAtUtcUs => $composableBuilder(
    column: $table.supersededAtUtcUs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get redactedAtUtcUs => $composableBuilder(
    column: $table.redactedAtUtcUs,
    builder: (column) => column,
  );

  $$EncountersTableAnnotationComposer get encounterId {
    final $$EncountersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.encounterId,
      referencedTable: $db.encounters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EncountersTableAnnotationComposer(
            $db: $db,
            $table: $db.encounters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EncounterNotesTableAnnotationComposer get supersedesNoteId {
    final $$EncounterNotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supersedesNoteId,
      referencedTable: $db.encounterNotes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EncounterNotesTableAnnotationComposer(
            $db: $db,
            $table: $db.encounterNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EncounterNotesTableTableManager
    extends
        RootTableManager<
          _$RynAppDatabase,
          $EncounterNotesTable,
          EncounterNoteRow,
          $$EncounterNotesTableFilterComposer,
          $$EncounterNotesTableOrderingComposer,
          $$EncounterNotesTableAnnotationComposer,
          $$EncounterNotesTableCreateCompanionBuilder,
          $$EncounterNotesTableUpdateCompanionBuilder,
          (EncounterNoteRow, $$EncounterNotesTableReferences),
          EncounterNoteRow,
          PrefetchHooks Function({bool encounterId, bool supersedesNoteId})
        > {
  $$EncounterNotesTableTableManager(
    _$RynAppDatabase db,
    $EncounterNotesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EncounterNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EncounterNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EncounterNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> encounterId = const Value.absent(),
                Value<String> noteType = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> recordedAtUtcUs = const Value.absent(),
                Value<int> updatedAtUtcUs = const Value.absent(),
                Value<String?> supersedesNoteId = const Value.absent(),
                Value<int?> supersededAtUtcUs = const Value.absent(),
                Value<int?> redactedAtUtcUs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EncounterNotesCompanion(
                id: id,
                encounterId: encounterId,
                noteType: noteType,
                body: body,
                recordedAtUtcUs: recordedAtUtcUs,
                updatedAtUtcUs: updatedAtUtcUs,
                supersedesNoteId: supersedesNoteId,
                supersededAtUtcUs: supersededAtUtcUs,
                redactedAtUtcUs: redactedAtUtcUs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String encounterId,
                required String noteType,
                required String body,
                required int recordedAtUtcUs,
                required int updatedAtUtcUs,
                Value<String?> supersedesNoteId = const Value.absent(),
                Value<int?> supersededAtUtcUs = const Value.absent(),
                Value<int?> redactedAtUtcUs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EncounterNotesCompanion.insert(
                id: id,
                encounterId: encounterId,
                noteType: noteType,
                body: body,
                recordedAtUtcUs: recordedAtUtcUs,
                updatedAtUtcUs: updatedAtUtcUs,
                supersedesNoteId: supersedesNoteId,
                supersededAtUtcUs: supersededAtUtcUs,
                redactedAtUtcUs: redactedAtUtcUs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EncounterNotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({encounterId = false, supersedesNoteId = false}) {
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
                        if (encounterId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.encounterId,
                                    referencedTable:
                                        $$EncounterNotesTableReferences
                                            ._encounterIdTable(db),
                                    referencedColumn:
                                        $$EncounterNotesTableReferences
                                            ._encounterIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (supersedesNoteId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.supersedesNoteId,
                                    referencedTable:
                                        $$EncounterNotesTableReferences
                                            ._supersedesNoteIdTable(db),
                                    referencedColumn:
                                        $$EncounterNotesTableReferences
                                            ._supersedesNoteIdTable(db)
                                            .id,
                                  )
                                  as T;
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

typedef $$EncounterNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$RynAppDatabase,
      $EncounterNotesTable,
      EncounterNoteRow,
      $$EncounterNotesTableFilterComposer,
      $$EncounterNotesTableOrderingComposer,
      $$EncounterNotesTableAnnotationComposer,
      $$EncounterNotesTableCreateCompanionBuilder,
      $$EncounterNotesTableUpdateCompanionBuilder,
      (EncounterNoteRow, $$EncounterNotesTableReferences),
      EncounterNoteRow,
      PrefetchHooks Function({bool encounterId, bool supersedesNoteId})
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
  $$TarotReadingsTableTableManager get tarotReadings =>
      $$TarotReadingsTableTableManager(_db, _db.tarotReadings);
  $$TarotCardPlacementsTableTableManager get tarotCardPlacements =>
      $$TarotCardPlacementsTableTableManager(_db, _db.tarotCardPlacements);
  $$TarotInterpretationsTableTableManager get tarotInterpretations =>
      $$TarotInterpretationsTableTableManager(_db, _db.tarotInterpretations);
  $$AppRuntimeStateTableTableManager get appRuntimeState =>
      $$AppRuntimeStateTableTableManager(_db, _db.appRuntimeState);
  $$PersonsTableTableManager get persons =>
      $$PersonsTableTableManager(_db, _db.persons);
  $$PersonRolesTableTableManager get personRoles =>
      $$PersonRolesTableTableManager(_db, _db.personRoles);
  $$PersonRelationshipsTableTableManager get personRelationships =>
      $$PersonRelationshipsTableTableManager(_db, _db.personRelationships);
  $$PersonBirthProfilesTableTableManager get personBirthProfiles =>
      $$PersonBirthProfilesTableTableManager(_db, _db.personBirthProfiles);
  $$EncountersTableTableManager get encounters =>
      $$EncountersTableTableManager(_db, _db.encounters);
  $$EncounterNotesTableTableManager get encounterNotes =>
      $$EncounterNotesTableTableManager(_db, _db.encounterNotes);
}
