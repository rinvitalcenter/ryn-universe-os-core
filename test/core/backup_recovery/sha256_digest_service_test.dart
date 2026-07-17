import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/backup_recovery/sha256_digest_service.dart';

void main() {
  const emptyDigest =
      'e3b0c44298fc1c149afbf4c8996fb924'
      '27ae41e4649b934ca495991b7852b855';
  const abcDigest =
      'ba7816bf8f01cfea414140de5dae2223'
      'b00361a396177a9cb410ff61f20015ad';
  const multiBlockDigest =
      '248d6a61d20638b8e5c026930c3e6039'
      'a33ce45964ff2167f6ecedd419db06c1';
  const millionADigest =
      'cdc76e5c9914fb9281a1c7e284d73e67'
      'f1809a48a497200e046d39ccc7112cd0';

  late DartSha256DigestService service;

  setUp(() {
    service = DartSha256DigestService();
  });

  group('SHA-256 recognized vectors', () {
    test('empty input matches the recognized digest', () {
      expect(_digest(service, const <int>[]), emptyDigest);
    });

    test('abc matches the recognized digest', () {
      expect(_digest(service, 'abc'.codeUnits), abcDigest);
    });

    test('standard multi-block input matches the recognized digest', () {
      const input =
          'abcdbcdecdefdefgefghfghighijhijk'
          'ijkljklmklmnlmnomnopnopq';

      expect(_digest(service, input.codeUnits), multiBlockDigest);
    });

    test('one million ASCII a bytes are processed without skipping', () {
      final accumulator = service.start();
      final thousandAs = List<int>.filled(1000, 0x61);
      for (var index = 0; index < 1000; index += 1) {
        accumulator.add(thousandAs);
      }

      expect(accumulator.close(), millionADigest);
    });
  });

  test('streamed digest is deterministic across required chunk sizes', () {
    final bytes = List<int>.generate(200003, (index) => (index * 31) & 0xff);
    final expected = _digest(service, bytes);

    for (final chunkSize in <int>[1, 7, 63, 64, 65, 4096, 65536]) {
      expect(
        _digestChunked(service, bytes, chunkSize),
        expected,
        reason: 'chunk size $chunkSize',
      );
    }
  });

  test('altering one byte changes the digest', () {
    final original = List<int>.generate(1024, (index) => index & 0xff);
    final altered = List<int>.from(original)..[511] ^= 0x01;

    expect(_digest(service, altered), isNot(_digest(service, original)));
  });

  test('close can be called only once', () {
    final accumulator = service.start()..add('abc'.codeUnits);
    expect(accumulator.close(), abcDigest);

    expect(accumulator.close, throwsStateError);
  });

  test('add after close fails', () {
    final accumulator = service.start();
    accumulator.close();

    expect(() => accumulator.add(<int>[1]), throwsStateError);
  });

  test('digest output is lowercase hexadecimal with exactly 64 characters', () {
    final digest = _digest(service, 'format'.codeUnits);

    expect(digest, hasLength(64));
    expect(digest, matches(RegExp(r'^[0-9a-f]{64}$')));
  });

  group('streaming files', () {
    late Directory temporaryRoot;

    setUp(() async {
      temporaryRoot = await Directory.systemTemp.createTemp('ryn-sha256-test-');
    });

    tearDown(() async {
      if (temporaryRoot.existsSync()) {
        await temporaryRoot.delete(recursive: true);
      }
    });

    test('empty file matches the empty recognized digest', () async {
      final file = File(
        '${temporaryRoot.path}${Platform.pathSeparator}empty.bin',
      );
      await file.create();

      expect(await service.digestFile(file), emptyDigest);
    });

    test(
      'temporary large file is deterministic across file chunk sizes',
      () async {
        final file = File(
          '${temporaryRoot.path}${Platform.pathSeparator}large.bin',
        );
        final sink = file.openWrite();
        final block = List<int>.generate(65536, (index) => (index * 17) & 0xff);
        for (var index = 0; index < 32; index += 1) {
          sink.add(block);
        }
        await sink.close();

        final expected = await service.digestFile(file, chunkSize: 65536);
        expect(await service.digestFile(file, chunkSize: 4096), expected);
        expect(await service.digestFile(file, chunkSize: 65537), expected);
        expect(await file.length(), 2 * 1024 * 1024);
      },
    );

    test('invalid file chunk sizes fail before reading', () async {
      final file = File(
        '${temporaryRoot.path}${Platform.pathSeparator}data.bin',
      );
      await file.writeAsBytes(<int>[1, 2, 3]);

      await expectLater(
        service.digestFile(file, chunkSize: 0),
        throwsArgumentError,
      );
      await expectLater(
        service.digestFile(file, chunkSize: -1),
        throwsArgumentError,
      );
    });

    test('file read errors surface as failures', () async {
      final missing = File(
        '${temporaryRoot.path}${Platform.pathSeparator}missing.bin',
      );

      await expectLater(
        service.digestFile(missing),
        throwsA(isA<FileSystemException>()),
      );
    });
  });
}

String _digest(DartSha256DigestService service, List<int> bytes) {
  final accumulator = service.start()..add(bytes);
  return accumulator.close();
}

String _digestChunked(
  DartSha256DigestService service,
  List<int> bytes,
  int chunkSize,
) {
  final accumulator = service.start();
  for (var offset = 0; offset < bytes.length; offset += chunkSize) {
    final end = offset + chunkSize < bytes.length
        ? offset + chunkSize
        : bytes.length;
    accumulator.add(bytes.sublist(offset, end));
  }
  return accumulator.close();
}
