import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:themeparkapp/core/database/database.dart';

Future<void> seedDatabase(AppDatabase db) async {
  try {
    final parksJsonString = await rootBundle.loadString('assets/data/parks.json');
    final parksData = json.decode(parksJsonString) as Map<String, dynamic>;
    final parks = (parksData['data'] as Map<String, dynamic>)['parks'] as List<dynamic>;
    
    for (final parkData in parks) {
      final parkMap = parkData as Map<String, dynamic>;
      final parkId = parkMap['id'] as String;
      await db.into(db.regions).insert(RegionsCompanion.insert(
            id: parkId,
            name: parkMap['name'] as String,
            type: parkMap['type'] as String,
          ));
          
      final lands = parkMap['children'] as List<dynamic>? ?? [];
      for (final landData in lands) {
        final landMap = landData as Map<String, dynamic>;
        final landId = landMap['id'] as String;
        await db.into(db.regions).insert(RegionsCompanion.insert(
              id: landId,
              parentId: Value(parkId),
              name: landMap['name'] as String,
              type: landMap['type'] as String,
            ));
            
        final facilities = landMap['children'] as List<dynamic>? ?? [];
        for (final facilityData in facilities) {
          final facilityMap = facilityData as Map<String, dynamic>;
          final facilityId = facilityMap['id'] as String;
          
          final targetAgesList = (facilityMap['targetAges'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList();
          
          await db.into(db.locations).insert(LocationsCompanion.insert(
                id: facilityId,
                regionId: landId,
                name: facilityMap['name'] as String,
                type: (facilityMap['type'] as String?) ?? 'Facility',
                subtype: Value(facilityMap['category'] as String?),
                targetAges: Value(targetAgesList),
              ));
        }
      }
    }
    
    // Parse restaurants to update operating hours
    try {
      final restaurantsString = await rootBundle.loadString('assets/data/restaurants.json');
      final restaurantsData = json.decode(restaurantsString) as Map<String, dynamic>;
      final restaurants = restaurantsData['restaurants'] as List<dynamic>;
      for (final r in restaurants) {
        final restaurantMap = r as Map<String, dynamic>;
        final facId = restaurantMap['facilityId'] as String;
        final operatingHours = restaurantMap['operatingHours'] as Map<String, dynamic>?;
        if (operatingHours != null) {
          final open = operatingHours['open'] as String?;
          final close = operatingHours['close'] as String?;
          
          await (db.update(db.locations)..where((tbl) => tbl.id.equals(facId))).write(
            LocationsCompanion(
              openTime: Value(open),
              closeTime: Value(close),
            ),
          );
        }
      }
    } catch (e) {
      // Ignored if missing
    }
  } catch (e) {
    // ignore: avoid_print
    print('Error seeding database: $e');
  }
}
