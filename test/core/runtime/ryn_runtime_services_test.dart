import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/persistence/runtime_data_profile.dart';
import 'package:ryn_universe_os_core/core/runtime/ryn_runtime_services.dart';
import 'package:ryn_universe_os_core/features/tarot/application/tarot_runtime_controller.dart';

void main() {
  test(
    'Tarot runtime exposes one shared database service composition',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'ryn-synthetic-services-',
      );
      addTearDown(() async {
        if (root.existsSync()) await root.delete(recursive: true);
      });
      final controller = TarotRuntimeController.development(
        pathContract: RynRuntimeDataPathContract.forApplicationSupportRoot(
          root,
        ),
      );
      addTearDown(controller.close);

      await controller.bootstrap();

      final RynRuntimeServices services = controller.runtimeServices!;
      final version = await services.database
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(version.read<int>('user_version'), 6);
      expect(services.tarotReadings, isNotNull);
      expect(services.people, isNotNull);
      expect(services.personRoles, isNotNull);
      expect(services.personRelationships, isNotNull);
      expect(services.personBirthProfiles, isNotNull);
      expect(services.encounters, isNotNull);
      expect(services.encounterNotes, isNotNull);
      expect(controller.startupStatus, TarotRuntimeStartupStatus.readyEmpty);
    },
  );
}
