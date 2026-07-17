import 'dart:convert';
import 'dart:typed_data';

import '../domain/tarot_backup_manifest.dart';

final class TarotBackupManifestCodec {
  const TarotBackupManifestCodec();

  static const int maximumBytes = 64 * 1024;
  static final RegExp _sha256 = RegExp(r'^[0-9a-f]{64}$');
  static final RegExp _applicationVersion = RegExp(
    r'^[0-9]{1,6}\.[0-9]{1,6}\.[0-9]{1,6}'
    r'(?:-[0-9A-Za-z.-]{1,32})?(?:\+[0-9A-Za-z.-]{1,32})?$',
  );

  static bool isValidApplicationVersion(String value) =>
      value.length <= 64 && _applicationVersion.hasMatch(value);

  Uint8List encode(TarotBackupManifest manifest) {
    _validateManifest(manifest);
    return Uint8List.fromList(utf8.encode(jsonEncode(_canonicalMap(manifest))));
  }

  TarotBackupManifest decode(Uint8List bytes) {
    if (bytes.length > maximumBytes) {
      throw const FormatException('manifest_too_large');
    }
    late final String text;
    try {
      text = utf8.decode(bytes, allowMalformed: false);
    } on FormatException {
      throw const FormatException('manifest_invalid_utf8');
    }

    late final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      throw const FormatException('manifest_invalid_json');
    }
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('manifest_not_object');
    }
    _requireExactKeys(decoded, TarotBackupManifest.canonicalFieldOrder);

    final manifest = TarotBackupManifest(
      applicationVersion: _string(decoded, 'applicationVersion'),
      sourceRuntimeMode: _string(decoded, 'sourceRuntimeMode'),
      sourceEnvironment: _string(decoded, 'sourceEnvironment'),
      sourcePurpose: _string(decoded, 'sourcePurpose'),
      createdAtUtc: _timestamp(decoded, 'createdAtUtc'),
      databasePayloadSizeBytes: _integer(
        decoded,
        'databasePayloadSizeBytes',
        positive: true,
      ),
      databasePayloadSha256: _string(decoded, 'databasePayloadSha256'),
      requiredTables: _stringList(decoded, 'requiredTables'),
      requiredColumnsByTable: _columnsMap(decoded),
      tableRowCounts: _countMap(decoded, 'tableRowCounts'),
      readingIdCount: _integer(decoded, 'readingIdCount'),
      placementCount: _integer(decoded, 'placementCount'),
      interpretationCount: _integer(decoded, 'interpretationCount'),
      runtimeStateRowCount: _integer(decoded, 'runtimeStateRowCount'),
      activeHomeReadingIdPresent: _boolean(
        decoded,
        'activeHomeReadingIdPresent',
      ),
      lifecycleStateCounts: _countMap(
        decoded,
        'lifecycleStateCounts',
        exactKeys: const <String>['continuing', 'finished'],
      ),
      unsupportedTableRowsZero: _boolean(decoded, 'unsupportedTableRowsZero'),
      verifiedAtUtc: _timestamp(decoded, 'verifiedAtUtc'),
    );

    _requireFixed(decoded, 'backupFormatVersion', 1);
    _requireFixed(
      decoded,
      'applicationIdentity',
      TarotBackupManifest.applicationIdentity,
    );
    _requireFixed(decoded, 'contentScope', TarotBackupManifest.contentScope);
    _requireFixed(decoded, 'schemaVersion', TarotBackupManifest.schemaVersion);
    _requireFixed(
      decoded,
      'databasePayloadFilename',
      TarotBackupManifest.databasePayloadFilename,
    );
    _requireFixed(
      decoded,
      'checksumFilename',
      TarotBackupManifest.checksumFilename,
    );
    _requireFixed(
      decoded,
      'verificationResult',
      TarotBackupManifest.verificationResult,
    );
    _validateManifest(manifest);

    final canonical = encode(manifest);
    if (!_sameBytes(bytes, canonical)) {
      throw const FormatException('manifest_not_canonical');
    }
    return manifest;
  }

  Map<String, Object?> _canonicalMap(TarotBackupManifest manifest) =>
      <String, Object?>{
        'backupFormatVersion': TarotBackupManifest.backupFormatVersion,
        'applicationIdentity': TarotBackupManifest.applicationIdentity,
        'applicationVersion': manifest.applicationVersion,
        'sourceRuntimeMode': manifest.sourceRuntimeMode,
        'sourceEnvironment': manifest.sourceEnvironment,
        'sourcePurpose': manifest.sourcePurpose,
        'contentScope': TarotBackupManifest.contentScope,
        'createdAtUtc': _formatTimestamp(manifest.createdAtUtc),
        'schemaVersion': TarotBackupManifest.schemaVersion,
        'databasePayloadFilename': TarotBackupManifest.databasePayloadFilename,
        'databasePayloadSizeBytes': manifest.databasePayloadSizeBytes,
        'databasePayloadSha256': manifest.databasePayloadSha256,
        'checksumFilename': TarotBackupManifest.checksumFilename,
        'requiredTables': manifest.requiredTables,
        'requiredColumnsByTable': <String, Object?>{
          for (final table in TarotBackupManifest.requiredTablesV1)
            table: manifest.requiredColumnsByTable[table],
        },
        'tableRowCounts': <String, Object?>{
          for (final table in TarotBackupManifest.requiredTablesV1)
            table: manifest.tableRowCounts[table],
        },
        'readingIdCount': manifest.readingIdCount,
        'placementCount': manifest.placementCount,
        'interpretationCount': manifest.interpretationCount,
        'runtimeStateRowCount': manifest.runtimeStateRowCount,
        'activeHomeReadingIdPresent': manifest.activeHomeReadingIdPresent,
        'lifecycleStateCounts': <String, Object?>{
          'continuing': manifest.lifecycleStateCounts['continuing'],
          'finished': manifest.lifecycleStateCounts['finished'],
        },
        'unsupportedTableRowsZero': manifest.unsupportedTableRowsZero,
        'verificationResult': TarotBackupManifest.verificationResult,
        'verifiedAtUtc': _formatTimestamp(manifest.verifiedAtUtc),
      };

  void _validateManifest(TarotBackupManifest manifest) {
    if (!isValidApplicationVersion(manifest.applicationVersion) ||
        manifest.sourceRuntimeMode != 'tarot_backup_recovery_qa' ||
        manifest.sourceEnvironment != 'development' ||
        manifest.sourcePurpose != 'core_tarot_backup_recovery_v0_2' ||
        manifest.databasePayloadSizeBytes <= 0 ||
        !_sha256.hasMatch(manifest.databasePayloadSha256) ||
        !_sameList(
          manifest.requiredTables,
          TarotBackupManifest.requiredTablesV1,
        ) ||
        !_sameColumns(
          manifest.requiredColumnsByTable,
          TarotBackupManifest.requiredColumnsByTableV1,
        ) ||
        !_hasExactCountKeys(
          manifest.tableRowCounts,
          TarotBackupManifest.requiredTablesV1,
        ) ||
        !_hasExactCountKeys(manifest.lifecycleStateCounts, const <String>[
          'continuing',
          'finished',
        ]) ||
        manifest.readingIdCount < 0 ||
        manifest.placementCount < 0 ||
        manifest.interpretationCount < 0 ||
        manifest.runtimeStateRowCount < 0 ||
        !manifest.unsupportedTableRowsZero) {
      throw const FormatException('manifest_invalid_contract');
    }
    _formatTimestamp(manifest.createdAtUtc);
    _formatTimestamp(manifest.verifiedAtUtc);
  }

  static String _formatTimestamp(DateTime value) {
    if (!value.isUtc) throw const FormatException('timestamp_not_utc');
    return value.toIso8601String();
  }

  DateTime _timestamp(Map<String, Object?> map, String key) {
    final text = _string(map, key);
    if (!text.endsWith('Z')) throw const FormatException('timestamp_not_utc');
    final value = DateTime.tryParse(text);
    if (value == null || !value.isUtc || value.toIso8601String() != text) {
      throw const FormatException('timestamp_not_canonical');
    }
    return value;
  }

  static String _string(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is! String) throw FormatException('invalid_$key');
    return value;
  }

  static bool _boolean(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is! bool) throw FormatException('invalid_$key');
    return value;
  }

  static int _integer(
    Map<String, Object?> map,
    String key, {
    bool positive = false,
  }) {
    final value = map[key];
    if (value is! int || (positive ? value <= 0 : value < 0)) {
      throw FormatException('invalid_$key');
    }
    return value;
  }

  static List<String> _stringList(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is! List || value.any((item) => item is! String)) {
      throw FormatException('invalid_$key');
    }
    final result = value.cast<String>();
    if (result.toSet().length != result.length) {
      throw FormatException('duplicate_$key');
    }
    return result;
  }

  static Map<String, List<String>> _columnsMap(Map<String, Object?> map) {
    final value = map['requiredColumnsByTable'];
    if (value is! Map<String, Object?>) {
      throw const FormatException('invalid_requiredColumnsByTable');
    }
    _requireExactKeys(value, TarotBackupManifest.requiredTablesV1);
    return <String, List<String>>{
      for (final table in TarotBackupManifest.requiredTablesV1)
        table: _stringList(value, table),
    };
  }

  static Map<String, int> _countMap(
    Map<String, Object?> map,
    String key, {
    List<String>? exactKeys,
  }) {
    final value = map[key];
    if (value is! Map<String, Object?>) throw FormatException('invalid_$key');
    final keys = exactKeys ?? TarotBackupManifest.requiredTablesV1;
    _requireExactKeys(value, keys);
    return <String, int>{
      for (final itemKey in keys) itemKey: _integer(value, itemKey),
    };
  }

  static void _requireFixed(
    Map<String, Object?> map,
    String key,
    Object expected,
  ) {
    if (map[key] != expected) throw FormatException('invalid_$key');
  }

  static void _requireExactKeys(
    Map<String, Object?> map,
    List<String> expected,
  ) {
    if (!_sameList(map.keys.toList(), expected)) {
      throw const FormatException('unexpected_or_missing_keys');
    }
  }

  static bool _sameList(List<Object?> left, List<Object?> right) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }

  static bool _sameColumns(
    Map<String, List<String>> left,
    Map<String, List<String>> right,
  ) {
    if (!_sameList(left.keys.toList(), right.keys.toList())) return false;
    for (final key in right.keys) {
      if (!_sameList(left[key] ?? const <String>[], right[key]!)) return false;
    }
    return true;
  }

  static bool _hasExactCountKeys(Map<String, int> map, List<String> keys) {
    if (!_sameList(map.keys.toList(), keys)) return false;
    return map.values.every((value) => value >= 0);
  }

  static bool _sameBytes(List<int> left, List<int> right) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }
}
