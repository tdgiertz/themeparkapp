import 'package:themeparkapp/core/database/database.dart';

class MenuCategoryWithItems {
  MenuCategoryWithItems({
    required this.category,
    required this.items,
  });

  final MenuCategory category;
  final List<MenuItem> items;
}

class FacilityDetailsRepository {
  FacilityDetailsRepository(this.db);

  final AppDatabase db;

  /// Fetches restaurant details for a facility ID.
  Future<RestaurantDetail?> getRestaurantDetails(String facilityId) {
    return (db.select(db.restaurantDetails)
          ..where((tbl) => tbl.facilityId.equals(facilityId)))
        .getSingleOrNull();
  }

  /// Fetches menu categories and their associated menu items for a facility ID.
  Future<List<MenuCategoryWithItems>> getMenu(String facilityId) async {
    final categories = await (db.select(db.menuCategories)
          ..where((tbl) => tbl.facilityId.equals(facilityId)))
        .get();

    if (categories.isEmpty) return [];

    final categoryIds = categories.map((c) => c.id).toList();
    final items = await (db.select(db.menuItems)
          ..where((tbl) => tbl.categoryId.isIn(categoryIds)))
        .get();

    return categories.map((category) {
      return MenuCategoryWithItems(
        category: category,
        items: items.where((item) => item.categoryId == category.id).toList(),
      );
    }).toList();
  }

  /// Streams showtimes for a given facility ID.
  Stream<List<Showtime>> watchShowtimes(String facilityId) {
    return (db.select(db.showtimes)
          ..where((tbl) => tbl.facilityId.equals(facilityId)))
        .watch();
  }
}
