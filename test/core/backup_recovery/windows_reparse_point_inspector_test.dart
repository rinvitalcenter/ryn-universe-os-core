import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/backup_recovery/windows_reparse_point_inspector.dart';

void main() {
  const inspector = WindowsReparsePointInspector();

  test(
    'regular temporary hierarchy is accepted without filesystem mutation',
    () async {
      final root = await Directory.systemTemp.createTemp('ryn-path-safe-');
      try {
        final regular = Directory(
          '${root.path}${Platform.pathSeparator}regular${Platform.pathSeparator}child',
        )..createSync(recursive: true);
        final before = _relativeEntries(root);

        expect(inspector.isSafe(regular.path), Platform.isWindows);
        expect(
          inspector.isSafe(
            '${regular.path}${Platform.pathSeparator}not-created${Platform.pathSeparator}payload',
          ),
          Platform.isWindows,
        );
        expect(_relativeEntries(root), before);
      } finally {
        await root.delete(recursive: true);
      }
    },
  );

  test('invalid path fails closed', () {
    expect(inspector.isSafe(''), isFalse);
    expect(inspector.isSafe('invalid\u0000path'), isFalse);
    if (Platform.isWindows) {
      expect(
        inspector.isSafe(
          '${Directory.systemTemp.path}${Platform.pathSeparator}bad*component',
        ),
        isFalse,
      );
    }
  });

  test('unsupported platform behavior is explicitly fail closed', () async {
    if (Platform.isWindows) {
      final root = await Directory.systemTemp.createTemp('ryn-path-platform-');
      try {
        expect(inspector.isSafe(root.path), isTrue);
      } finally {
        await root.delete(recursive: true);
      }
      return;
    }

    expect(inspector.isSafe(Directory.systemTemp.path), isFalse);
  });

  test('real Windows junction and every descendant fail closed', () async {
    if (!Platform.isWindows) {
      expect(inspector.isSafe(Directory.systemTemp.path), isFalse);
      return;
    }

    final root = await Directory.systemTemp.createTemp('ryn-reparse-probe-');
    final source = Directory(
      '${root.path}${Platform.pathSeparator}junction-source',
    )..createSync();
    final junction = Directory(
      '${root.path}${Platform.pathSeparator}actual-junction',
    );
    final sibling = Directory(
      '${root.path}${Platform.pathSeparator}regular-sibling',
    )..createSync();
    var junctionCreated = false;

    try {
      final result = await Process.run('cmd.exe', <String>[
        '/c',
        'mklink',
        '/J',
        junction.path,
        source.path,
      ]);
      expect(
        result.exitCode,
        0,
        reason:
            'A real Windows junction is mandatory. '
            'mklink output: ${result.stdout} ${result.stderr}',
      );
      junctionCreated = junction.existsSync();
      expect(junctionCreated, isTrue);

      expect(inspector.isSafe(junction.path), isFalse);
      expect(
        inspector.isSafe('${junction.path}${Platform.pathSeparator}child'),
        isFalse,
      );
      expect(
        inspector.isSafe(
          '${junction.path}${Platform.pathSeparator}missing${Platform.pathSeparator}payload',
        ),
        isFalse,
      );
      expect(inspector.isSafe(sibling.path), isTrue);
      expect(
        inspector.isSafe(
          '${sibling.path}${Platform.pathSeparator}missing${Platform.pathSeparator}payload',
        ),
        isTrue,
      );
    } finally {
      if (junctionCreated && junction.existsSync()) {
        await junction.delete();
      }
      if (root.existsSync()) {
        await root.delete(recursive: true);
      }
      expect(
        root.existsSync(),
        isFalse,
        reason: 'temporary junction root cleanup',
      );
    }
  });
}

List<String> _relativeEntries(Directory root) {
  final prefix = '${root.path}${Platform.pathSeparator}';
  return root
      .listSync(recursive: true, followLinks: false)
      .map((entry) => entry.path.substring(prefix.length))
      .toList()
    ..sort();
}
