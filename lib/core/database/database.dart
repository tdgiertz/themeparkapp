import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:themeparkapp/core/database/database_seeder.dart';

part 'database.g.dart';

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    return List<String>.from(json.decode(fromDb) as Iterable<dynamic>);
  }

  @override
  String toSql(List<String> value) {
    return json.encode(value);
  }
}

class Regions extends Table {
  TextColumn get id => text()();
  TextColumn get parentId => text().nullable().references(Regions, #id)();
  TextColumn get name => text()();
  TextColumn get type => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Locations extends Table {
  TextColumn get id => text()();
  TextColumn get regionId => text().references(Regions, #id)();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get subtype => text().nullable()();
  TextColumn get openTime => text().nullable()();
  TextColumn get closeTime => text().nullable()();
  TextColumn get targetAges => text().map(const StringListConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_wait_times_facility_timestamp', columns: {#facilityId, #timestamp})
class WaitTimes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get facilityId => text().references(Locations, #id)();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get status => text()();
  IntColumn get waitMinutes => integer().nullable()();
  BoolColumn get singleRider => boolean()();
  BoolColumn get fastLane => boolean()();
}

class Favorites extends Table {
  TextColumn get facilityId => text().references(Locations, #id)();
  DateTimeColumn get savedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {facilityId};
}

class RestaurantDetails extends Table {
  TextColumn get facilityId => text().references(Locations, #id)();
  TextColumn get cuisine => text().nullable()();
  TextColumn get priceRange => text().nullable()();

  @override
  Set<Column> get primaryKey => {facilityId};
}

class MenuCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get facilityId => text().references(Locations, #id)();
  TextColumn get name => text()();
}

class MenuItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(MenuCategories, #id)();
  TextColumn get name => text()();
  RealColumn get price => real()();
  TextColumn get description => text().nullable()();
}

class Showtimes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get facilityId => text().references(Locations, #id)();
  TextColumn get startTime => text()();
}

@DriftDatabase(tables: [
  Regions,
  Locations,
  WaitTimes,
  Favorites,
  RestaurantDetails,
  MenuCategories,
  MenuItems,
  Showtimes,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await seedDatabase(this);
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'themepark_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
