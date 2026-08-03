import 'package:drift/drift.dart';
import 'package:themeparkapp/core/database/database.dart';

class FavoritesRepository {
  FavoritesRepository(this.db);

  final AppDatabase db;

  /// Toggles a facility as a favorite (inserts if missing, deletes if exists).
  Future<void> toggleFavorite(String facilityId) async {
    final existing = await (db.select(db.favorites)
          ..where((tbl) => tbl.facilityId.equals(facilityId)))
        .getSingleOrNull();

    if (existing != null) {
      await (db.delete(db.favorites)
            ..where((tbl) => tbl.facilityId.equals(facilityId)))
          .go();
    } else {
      await db.into(db.favorites).insert(
            FavoritesCompanion.insert(
              facilityId: facilityId,
              savedAt: Value(DateTime.now()),
            ),
          );
    }
  }

  /// Streams the list of bookmarked Location facilities by joining Favorites and Locations.
  Stream<List<Location>> watchFavoriteLocations() {
    final query = db.select(db.locations).join([
      innerJoin(
        db.favorites,
        db.favorites.facilityId.equalsExp(db.locations.id),
      ),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) => row.readTable(db.locations)).toList();
    });
  }
}
