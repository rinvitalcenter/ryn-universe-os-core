import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:ryn_universe_os_core/core/persistence/runtime_data_profile.dart';

void main() {
  group('development runtime data profile', () {
    late Directory temporaryRoot;
    late RynRuntimeDataPathContract paths;

    setUp(() async {
      temporaryRoot = await Directory.systemTemp.createTemp(
        'ryn-synthetic-profile-',
      );
      paths = RynRuntimeDataPathContract.forApplicationSupportRoot(
        temporaryRoot,
      );
    });

    tearDown(() async {
      if (temporaryRoot.existsSync()) {
        await temporaryRoot.delete(recursive: true);
      }
    });

    test('development and production-reserved paths are distinct', () {
      final development = paths.resolve(RynDataProfile.development);
      final production = paths.resolve(RynDataProfile.productionReserved);

      expect(development.databasePath, isNot(production.databasePath));
      expect(
        development.databasePath,
        p.join(
          temporaryRoot.path,
          'RinVitalCenter',
          'RynUniverseOS',
          'development',
          'runtime',
          'ryn_universe_os_core_dev.sqlite',
        ),
      );
      expect(
        production.databasePath,
        p.join(
          temporaryRoot.path,
          'RinVitalCenter',
          'RynUniverseOS',
          'production',
          'runtime',
          'ryn_universe_os_core.sqlite',
        ),
      );
    });

    test('default runtime mode preserves the standard development path', () {
      final mode = RynRuntimeDataModeContract.parseSelector('');
      final resolved = paths.resolveMode(mode);

      expect(mode, RynRuntimeDataMode.standardDevelopment);
      expect(resolved.profile, RynDataProfile.development);
      expect(resolved.isStandardDevelopment, isTrue);
      expect(resolved.isTaskSpecificQa, isFalse);
      expect(resolved.environment, 'development');
      expect(resolved.purpose, 'standard');
      expect(
        resolved.databasePath,
        p.join(
          temporaryRoot.path,
          'RinVitalCenter',
          'RynUniverseOS',
          'development',
          'runtime',
          'ryn_universe_os_core_dev.sqlite',
        ),
      );
    });

    test('approved QA mode resolves to the exact isolated path', () {
      final mode = RynRuntimeDataModeContract.parseSelector(
        'tarot_persistence_qa',
      );
      final standard = paths.resolveMode(
        RynRuntimeDataMode.standardDevelopment,
      );
      final qa = paths.resolveMode(mode);

      expect(mode, RynRuntimeDataMode.tarotPersistenceQa);
      expect(qa.profile, RynDataProfile.development);
      expect(qa.isStandardDevelopment, isFalse);
      expect(qa.isTaskSpecificQa, isTrue);
      expect(qa.environment, 'development');
      expect(qa.purpose, 'core_tarot_self_reading_persistence1');
      expect(
        qa.relativeDatabasePath,
        p.join(
          'development',
          'qa',
          'core_tarot_self_reading_persistence1',
          'runtime',
          'ryn_universe_os_core_qa.sqlite',
        ),
      );
      expect(
        qa.databasePath,
        p.join(
          temporaryRoot.path,
          'RinVitalCenter',
          'RynUniverseOS',
          'development',
          'qa',
          'core_tarot_self_reading_persistence1',
          'runtime',
          'ryn_universe_os_core_qa.sqlite',
        ),
      );
      expect(p.basename(qa.databasePath), 'ryn_universe_os_core_qa.sqlite');
      expect(p.split(qa.relativeDatabasePath), contains('development'));
      expect(p.split(qa.relativeDatabasePath), isNot(contains('production')));
      expect(qa.databasePath, isNot(standard.databasePath));
    });

    test('unknown, production, and arbitrary path selectors fail closed', () {
      for (final selector in <String>[
        'unexpected',
        'production',
        'productionReserved',
        r'C:\temp\injected.sqlite',
        '../injected.sqlite',
      ]) {
        expect(
          () => RynRuntimeDataModeContract.parseSelector(selector),
          throwsA(isA<RynDataProfileException>()),
          reason: selector,
        );
      }
    });

    test('native binary name remains unchanged', () {
      final cmake = File(
        p.join(Directory.current.path, 'windows', 'CMakeLists.txt'),
      ).readAsStringSync();

      expect(cmake, contains('set(BINARY_NAME "ryn_universe_os_core")'));
    });

    test('resolving either profile creates no directory or database', () {
      final development = paths.resolve(RynDataProfile.development);
      final production = paths.resolve(RynDataProfile.productionReserved);

      expect(Directory(development.runtimeDirectoryPath).existsSync(), isFalse);
      expect(File(development.databasePath).existsSync(), isFalse);
      expect(Directory(production.runtimeDirectoryPath).existsSync(), isFalse);
      expect(File(production.databasePath).existsSync(), isFalse);
    });

    test('only development profile can be opened', () {
      expect(
        () => paths.requireOpenable(RynDataProfile.productionReserved),
        throwsA(isA<RynDataProfileException>()),
      );
      expect(
        paths.requireOpenable(RynDataProfile.development).profile,
        RynDataProfile.development,
      );
    });

    test('invalid profile text fails explicitly', () {
      expect(
        () => RynDataProfileContract.parse('unexpected'),
        throwsA(isA<RynDataProfileException>()),
      );
    });

    test('runtime paths never depend on the current working directory', () {
      final original = Directory.current;
      final other = Directory(p.join(temporaryRoot.path, 'other'))
        ..createSync();
      final before = paths.resolve(RynDataProfile.development).databasePath;
      try {
        Directory.current = other;
        final after = paths.resolve(RynDataProfile.development).databasePath;
        expect(after, before);
      } finally {
        Directory.current = original;
      }
    });
  });
}
