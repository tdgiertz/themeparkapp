import 'package:drift/drift.dart';
import 'package:themeparkapp/core/database/database.dart';

class WaitTimesRepository {
  WaitTimesRepository(this.db);

  final AppDatabase db;

  /// Streams the latest wait time record for a given facility ID.
  Stream<WaitTime?> watchLatestWaitTime(String facilityId) {
    return (db.select(db.waitTimes)
          ..where((tbl) => tbl.facilityId.equals(facilityId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.timestamp)])
          ..limit(1))
        .watchSingleOrNull();
  }

  /// Fetches historical wait time records for a given facility since a specific timestamp.
  Future<List<WaitTime>> getHistoricalWaitTimes(String facilityId, DateTime since) {
    return (db.select(db.waitTimes)
          ..where((tbl) => tbl.facilityId.equals(facilityId) & tbl.timestamp.isBiggerOrEqualValue(since))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.timestamp)]))
        .get();
  }
}
