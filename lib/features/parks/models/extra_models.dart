import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:themeparkapp/features/parks/models/park_models.dart';

part 'extra_models.freezed.dart';
part 'extra_models.g.dart';

@freezed
abstract class ShowSchedule with _$ShowSchedule {
  const factory ShowSchedule({
    required String facilityId,
    required List<String> showtimes,
  }) = _ShowSchedule;

  factory ShowSchedule.fromJson(Map<String, dynamic> json) =>
      _$ShowScheduleFromJson(json);
}

@freezed
abstract class RestaurantData with _$RestaurantData {
  const factory RestaurantData({
    required String id,
    required String facilityId,
    required OperatingHours operatingHours,
    required String cuisine,
    required String priceRange,
  }) = _RestaurantData;

  factory RestaurantData.fromJson(Map<String, dynamic> json) =>
      _$RestaurantDataFromJson(json);
}

@freezed
abstract class MenuData with _$MenuData {
  const factory MenuData({
    required String restaurantId,
    required List<MenuCategory> categories,
  }) = _MenuData;

  factory MenuData.fromJson(Map<String, dynamic> json) =>
      _$MenuDataFromJson(json);
}

@freezed
abstract class MenuCategory with _$MenuCategory {
  const factory MenuCategory({
    required String name,
    required List<MenuItem> items,
  }) = _MenuCategory;

  factory MenuCategory.fromJson(Map<String, dynamic> json) =>
      _$MenuCategoryFromJson(json);
}

@freezed
abstract class MenuItem with _$MenuItem {
  const factory MenuItem({
    required String name,
    required double price,
    required String description,
  }) = _MenuItem;

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);
}

@freezed
abstract class FavoriteRideRef with _$FavoriteRideRef {
  const factory FavoriteRideRef({required String rideId}) = _FavoriteRideRef;

  factory FavoriteRideRef.fromJson(Map<String, dynamic> json) =>
      _$FavoriteRideRefFromJson(json);
}

@freezed
abstract class UserFavorites with _$UserFavorites {
  const factory UserFavorites({
    required String userId,
    required String lastUpdated,
    required List<FavoriteRideRef> favoriteRides,
  }) = _UserFavorites;

  factory UserFavorites.fromJson(Map<String, dynamic> json) =>
      _$UserFavoritesFromJson(json);
}
