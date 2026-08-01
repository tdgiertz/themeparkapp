// ignore_for_file: one_member_abstracts

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:themeparkapp/features/parks/models/extra_models.dart';
import 'package:themeparkapp/features/parks/models/live_data_models.dart';
import 'package:themeparkapp/features/parks/models/park_models.dart';

abstract class ParkRepository {
  Future<List<Park>> fetchParks();
}

class FakeParkRepository implements ParkRepository {
  @override
  Future<List<Park>> fetchParks() async {
    await Future<void>.delayed(
      const Duration(seconds: 1),
    ); // Fake network latency
    final jsonString = await rootBundle.loadString('assets/data/parks.json');
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;

    final dataMap = jsonMap['data'] as Map<String, dynamic>;
    final parksList = dataMap['parks'] as List<dynamic>;
    return parksList
        .map((data) => Park.fromJson(data as Map<String, dynamic>))
        .toList();
  }
}

abstract class WaitTimesRepository {
  Future<List<RideWaitTime>> fetchWaitTimes();
}

class FakeWaitTimesRepository implements WaitTimesRepository {
  @override
  Future<List<RideWaitTime>> fetchWaitTimes() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    final jsonString = await rootBundle.loadString(
      'assets/data/wait_times.json',
    );
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;

    final waitTimesList = jsonMap['waitTimes'] as List<dynamic>;
    return waitTimesList
        .map((data) => RideWaitTime.fromJson(data as Map<String, dynamic>))
        .toList();
  }
}

abstract class ShowtimesRepository {
  Future<List<ShowSchedule>> fetchShowtimes();
}

class FakeShowtimesRepository implements ShowtimesRepository {
  @override
  Future<List<ShowSchedule>> fetchShowtimes() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    final jsonString = await rootBundle.loadString('assets/data/shows.json');
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;

    final showsList = jsonMap['shows'] as List<dynamic>;
    return showsList
        .map((data) => ShowSchedule.fromJson(data as Map<String, dynamic>))
        .toList();
  }
}

abstract class FavoritesRepository {
  Future<UserFavorites> fetchFavorites();
}

class FakeFavoritesRepository implements FavoritesRepository {
  @override
  Future<UserFavorites> fetchFavorites() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    final jsonString = await rootBundle.loadString(
      'assets/data/favorites.json',
    );
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;

    return UserFavorites.fromJson(jsonMap);
  }
}

abstract class RestaurantsRepository {
  Future<List<RestaurantData>> fetchRestaurants();
}

class FakeRestaurantsRepository implements RestaurantsRepository {
  @override
  Future<List<RestaurantData>> fetchRestaurants() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    final jsonString = await rootBundle.loadString(
      'assets/data/restaurants.json',
    );
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;

    final restaurantsList = jsonMap['restaurants'] as List<dynamic>;
    return restaurantsList
        .map((data) => RestaurantData.fromJson(data as Map<String, dynamic>))
        .toList();
  }
}

abstract class MenusRepository {
  Future<List<MenuData>> fetchMenus();
}

class FakeMenusRepository implements MenusRepository {
  @override
  Future<List<MenuData>> fetchMenus() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    final jsonString = await rootBundle.loadString('assets/data/menus.json');
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;

    final menusList = jsonMap['menus'] as List<dynamic>;
    return menusList
        .map((data) => MenuData.fromJson(data as Map<String, dynamic>))
        .toList();
  }
}
