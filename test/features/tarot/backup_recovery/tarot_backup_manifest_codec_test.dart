import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/domain/tarot_backup_manifest.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/infrastructure/tarot_backup_manifest_codec.dart';

void main() {
  const codec = TarotBackupManifestCodec();

  test('canonical encoding is compact deterministic and round trips', () {
    final manifest = sampleManifest();
    final first = codec.encode(manifest);
    final second = codec.encode(manifest);
    final decoded = codec.decode(first);

    expect(first, second);
    expect(utf8.decode(first), isNot(contains('\n')));
    expect(codec.encode(decoded), first);
    expect(decoded.databasePayloadSha256, 'a' * 64);
  });

  test('top-level and nested keys use the exact canonical order', () {
    final text = utf8.decode(codec.encode(sampleManifest()));
    final decoded = jsonDecode(text) as Map<String, Object?>;

    expect(decoded.keys, TarotBackupManifest.canonicalFieldOrder);
    final columns = decoded['requiredColumnsByTable'] as Map;
    expect(columns.keys, TarotBackupManifest.requiredTablesV1);
    for (final table in TarotBackupManifest.requiredTablesV1) {
      expect(
        (columns[table] as List).cast<String>(),
        TarotBackupManifest.requiredColumnsByTableV1[table],
      );
    }
  });

  test('unknown and privacy-sensitive fields are rejected', () {
    for (final key in <String>[
      'unknownField',
      'questionText',
      'interpretationText',
      'cardIds',
      'readingIds',
      'personId',
    ]) {
      final map = _decodedMap(codec.encode(sampleManifest()))
        ..[key] = 'private';
      expect(() => codec.decode(_canonicalBytes(map)), throwsFormatException);
    }
  });

  test('missing fields are rejected', () {
    final map = _decodedMap(codec.encode(sampleManifest()))
      ..remove('verificationResult');

    expect(() => codec.decode(_canonicalBytes(map)), throwsFormatException);
  });

  test('duplicate keys are rejected by canonical byte comparison', () {
    final canonical = utf8.decode(codec.encode(sampleManifest()));
    final duplicate = canonical.replaceFirst('{', '{"backupFormatVersion":1,');

    expect(
      () => codec.decode(Uint8List.fromList(utf8.encode(duplicate))),
      throwsFormatException,
    );
  });

  test('whitespace and alternate key order are noncanonical', () {
    final canonical = utf8.decode(codec.encode(sampleManifest()));
    final spaced = canonical.replaceFirst(':', ': ');
    final map = _decodedMap(utf8.encode(canonical));
    final reversed = <String, Object?>{
      for (final key in map.keys.toList().reversed) key: map[key],
    };

    expect(
      () => codec.decode(Uint8List.fromList(utf8.encode(spaced))),
      throwsFormatException,
    );
    expect(
      () => codec.decode(_canonicalBytes(reversed)),
      throwsFormatException,
    );
  });

  test('invalid UTF-8 and oversized manifests are rejected before parsing', () {
    expect(
      () => codec.decode(Uint8List.fromList(<int>[0xc3, 0x28])),
      throwsFormatException,
    );
    expect(() => codec.decode(Uint8List(64 * 1024 + 1)), throwsFormatException);
  });

  test('invalid hashes and nonpositive payload sizes are rejected', () {
    final base = _decodedMap(codec.encode(sampleManifest()));
    for (final hash in <String>['A' * 64, 'a' * 63, 'not-a-hash']) {
      final map = Map<String, Object?>.from(base)
        ..['databasePayloadSha256'] = hash;
      expect(() => codec.decode(_canonicalBytes(map)), throwsFormatException);
    }
    for (final size in <int>[0, -1]) {
      final map = Map<String, Object?>.from(base)
        ..['databasePayloadSizeBytes'] = size;
      expect(() => codec.decode(_canonicalBytes(map)), throwsFormatException);
    }
  });

  test('application version accepts only the bounded canonical language', () {
    for (final version in <String>[
      '0.1.0',
      '1.2.3+45',
      '1.2.3-beta.1',
      '1.2.3-beta.1+45',
    ]) {
      expect(
        () => codec.encode(sampleManifest(version: version)),
        returnsNormally,
      );
    }
    for (final version in <String>[
      '',
      '1.2',
      '1.2.3 private',
      '1.2.3\nprivate',
      r'1.2.3/path',
      r'1.2.3\path',
      '1.2.3:private',
      '버전.1.0',
      'SYNTHETIC_SELF_READING_A',
      '1.2.3+${'a' * 33}',
    ]) {
      expect(
        () => codec.encode(sampleManifest(version: version)),
        throwsFormatException,
      );
    }
  });

  test('timestamps must be canonical UTC with trailing Z', () {
    final base = _decodedMap(codec.encode(sampleManifest()));
    for (final timestamp in <String>[
      '2026-07-17T01:02:03+09:00',
      '2026-07-17T01:02:03',
      '2026-07-17 01:02:03Z',
    ]) {
      final map = Map<String, Object?>.from(base)..['createdAtUtc'] = timestamp;
      expect(() => codec.decode(_canonicalBytes(map)), throwsFormatException);
    }
  });

  test('negative structural counts are rejected', () {
    final base = _decodedMap(codec.encode(sampleManifest()));
    for (final key in <String>[
      'readingIdCount',
      'placementCount',
      'interpretationCount',
      'runtimeStateRowCount',
    ]) {
      final map = Map<String, Object?>.from(base)..[key] = -1;
      expect(() => codec.decode(_canonicalBytes(map)), throwsFormatException);
    }
    final rows = Map<String, Object?>.from(base['tableRowCounts']! as Map)
      ..['tarot_readings'] = -1;
    final nested = Map<String, Object?>.from(base)..['tableRowCounts'] = rows;
    expect(() => codec.decode(_canonicalBytes(nested)), throwsFormatException);
  });

  test('fixed values and canonical collection orders are enforced', () {
    final base = _decodedMap(codec.encode(sampleManifest()));
    for (final entry in <MapEntry<String, Object?>>[
      const MapEntry('backupFormatVersion', 2),
      const MapEntry('applicationIdentity', 'other'),
      const MapEntry('contentScope', 'other'),
      const MapEntry('schemaVersion', 4),
      const MapEntry('verificationResult', 'unchecked'),
    ]) {
      final map = Map<String, Object?>.from(base)..[entry.key] = entry.value;
      expect(() => codec.decode(_canonicalBytes(map)), throwsFormatException);
    }
    final tables = List<String>.from(base['requiredTables']! as List)..add('x');
    final map = Map<String, Object?>.from(base)..['requiredTables'] = tables;
    expect(() => codec.decode(_canonicalBytes(map)), throwsFormatException);
  });

  test('canonical bytes contain no record-level private content', () {
    final text = utf8.decode(codec.encode(sampleManifest()));

    for (final forbidden in <String>[
      'SYNTHETIC_PRIVATE_QUESTION',
      'reading-id-1',
      'SYNTHETIC_PRIVATE_INTERPRETATION',
      'SYNTHETIC_CARD_NAME',
      'SYNTHETIC_PERSON_ID',
      'SYNTHETIC_CONTACT',
      'SYNTHETIC_BIRTH_DATE',
    ]) {
      expect(text.toLowerCase(), isNot(contains(forbidden.toLowerCase())));
    }
  });
}

TarotBackupManifest sampleManifest({String version = '1.0.0+1'}) {
  final rowCounts = <String, int>{
    for (final table in TarotBackupManifest.requiredTablesV1) table: 0,
  };
  rowCounts
    ..['tarot_readings'] = 1
    ..['tarot_card_placements'] = 3
    ..['tarot_interpretations'] = 1
    ..['app_runtime_state'] = 1;
  return TarotBackupManifest(
    applicationVersion: version,
    sourceRuntimeMode: 'tarot_backup_recovery_qa',
    sourceEnvironment: 'development',
    sourcePurpose: 'core_tarot_backup_recovery_v0_2',
    createdAtUtc: DateTime.utc(2026, 7, 17, 1, 2, 3),
    databasePayloadSizeBytes: 4096,
    databasePayloadSha256: 'a' * 64,
    requiredTables: TarotBackupManifest.requiredTablesV1,
    requiredColumnsByTable: TarotBackupManifest.requiredColumnsByTableV1,
    tableRowCounts: rowCounts,
    readingIdCount: 1,
    placementCount: 3,
    interpretationCount: 1,
    runtimeStateRowCount: 1,
    activeHomeReadingIdPresent: true,
    lifecycleStateCounts: const <String, int>{'continuing': 1, 'finished': 0},
    unsupportedTableRowsZero: true,
    verifiedAtUtc: DateTime.utc(2026, 7, 17, 1, 2, 4),
  );
}

Map<String, Object?> _decodedMap(List<int> bytes) =>
    (jsonDecode(utf8.decode(bytes)) as Map).cast<String, Object?>();

Uint8List _canonicalBytes(Map<String, Object?> map) =>
    Uint8List.fromList(utf8.encode(jsonEncode(map)));
