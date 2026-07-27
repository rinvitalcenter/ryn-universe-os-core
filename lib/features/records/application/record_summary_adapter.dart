import '../domain/record_summary.dart';

abstract interface class RecordSummaryAdapter {
  RecordModuleType get moduleType;

  Future<List<RecordSummary>> loadSummaries();
}
