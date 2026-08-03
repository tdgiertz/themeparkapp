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

@DriftDatabase(tables: [Regions, Locations])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

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
