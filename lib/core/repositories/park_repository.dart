import 'package:drift/drift.dart';
import 'package:themeparkapp/core/database/database.dart';

class ParkRepository {
  ParkRepository(this.db);

  final AppDatabase db;

  Stream<List<Region>> watchParks() {
    return (db.select(db.regions)..where((r) => r.type.equals('Park'))).watch();
  }

  Stream<List<Region>> watchLandsForPark(String parkId) {
    return (db.select(db.regions)..where((r) => r.parentId.equals(parkId))).watch();
  }

  Stream<List<Location>> watchLocationsForRegion(String regionId) {
    return (db.select(db.locations)..where((l) => l.regionId.equals(regionId))).watch();
  }

  Future<List<Location>> searchLocationsByTargetAge(String ageGroup) async {
    final result = await db.customSelect(
      '''
      SELECT l.* FROM locations l
      WHERE EXISTS (
        SELECT 1 FROM json_each(l.target_ages) WHERE value = ?
      )
      ''',
      variables: [Variable.withString(ageGroup)],
      readsFrom: {db.locations},
    ).get();

    return result.map((row) => db.locations.map(row.data)).toList();
  }
}
