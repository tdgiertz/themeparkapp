import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:themeparkapp/core/models/park.dart';
import 'package:themeparkapp/core/models/park_detail.dart';
import 'package:themeparkapp/core/models/wait_time.dart';
import 'package:themeparkapp/features/parks/models/extra_models.dart';

void main() {
  test('Park.fromJson parses parks.json', () {
    final raw = File('assets/data/parks.json').readAsStringSync();
    final map = json.decode(raw) as Map<String, dynamic>;
    final resp = ParksResponse.fromJson(map);
    expect(resp.parks, isNotEmpty);
    final park = resp.parks.first;
    expect(park.id, isNotEmpty);
    expect(park.name, isNotEmpty);
  });

  test('Favorites.fromJson parses favorites.json', () {
    final raw = File('assets/data/favorites.json').readAsStringSync();
    final map = json.decode(raw) as Map<String, dynamic>;
    final resp = UserFavorites.fromJson(map);
    expect(resp.favoriteRides, isNotNull);
  });

  test('ParkDetail.fromJson parses parks.json', () {
    final raw = File('assets/data/parks.json').readAsStringSync();
    final map = json.decode(raw) as Map<String, dynamic>;
    final data = map['data'] as Map<String, dynamic>? ?? {};
    final parks = (data['parks'] as List? ?? map['parks'] as List)
        .cast<Map<String, dynamic>>();
    final p1Map = parks.firstWhere((e) => e['id'] == 'p1');
    final detail = ParkDetail.fromJson({'park': p1Map});
    expect(detail.name, isNotEmpty);
    expect(detail.children, isA<List<Land>>());
  });

  test('WaitTimesResponse.fromJson parses wait_times.json', () {
    final raw = File('assets/data/wait_times.json').readAsStringSync();
    final map = json.decode(raw) as Map<String, dynamic>;
    final resp = WaitTimesResponse.fromJson(map);
    expect(resp.waitTimes, isA<List<WaitTime>>());
  });
}
