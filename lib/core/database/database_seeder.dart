import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:themeparkapp/core/database/data_import_service.dart';
import 'package:themeparkapp/core/database/database.dart';

Future<void> seedDatabase(AppDatabase db) async {
  try {
    final parksJsonString = await rootBundle.loadString('assets/data/parks.json');
    final parksData = json.decode(parksJsonString) as Map<String, dynamic>;
    final parks = (parksData['data'] as Map<String, dynamic>)['parks'] as List<dynamic>;
    
    for (final parkData in parks) {
      final parkMap = parkData as Map<String, dynamic>;
      final parkId = parkMap['id'] as String;
      await db.into(db.regions).insert(
            RegionsCompanion.insert(
              id: parkId,
              name: parkMap['name'] as String,
              type: parkMap['type'] as String,
            ),
            mode: InsertMode.insertOrIgnore,
          );
          
      final lands = parkMap['children'] as List<dynamic>? ?? [];
      for (final landData in lands) {
        final landMap = landData as Map<String, dynamic>;
        final landId = landMap['id'] as String;
        await db.into(db.regions).insert(
              RegionsCompanion.insert(
                id: landId,
                parentId: Value(parkId),
                name: landMap['name'] as String,
                type: landMap['type'] as String,
              ),
              mode: InsertMode.insertOrIgnore,
            );
            
        final facilities = landMap['children'] as List<dynamic>? ?? [];
        for (final facilityData in facilities) {
          final facilityMap = facilityData as Map<String, dynamic>;
          final facilityId = facilityMap['id'] as String;
          
          final targetAgesList = (facilityMap['targetAges'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList();
          
          await db.into(db.locations).insert(
                LocationsCompanion.insert(
                  id: facilityId,
                  regionId: landId,
                  name: facilityMap['name'] as String,
                  type: (facilityMap['type'] as String?) ?? 'Facility',
                  subtype: Value(facilityMap['category'] as String?),
                  targetAges: Value(targetAgesList),
                ),
                mode: InsertMode.insertOrIgnore,
              );
        }
      }
    }
    
    // Import additional datasets (Wait Times, Favorites, Restaurants, Menus, Showtimes)
    final importService = DataImportService(db);
    await importService.importAllData();
  } catch (e) {
    // ignore: avoid_print
    print('Error seeding database: $e');
  }
}
