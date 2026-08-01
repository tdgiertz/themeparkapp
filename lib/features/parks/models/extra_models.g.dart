// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extra_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShowSchedule _$ShowScheduleFromJson(Map<String, dynamic> json) =>
    _ShowSchedule(
      facilityId: json['facilityId'] as String,
      showtimes: (json['showtimes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ShowScheduleToJson(_ShowSchedule instance) =>
    <String, dynamic>{
      'facilityId': instance.facilityId,
      'showtimes': instance.showtimes,
    };

_RestaurantData _$RestaurantDataFromJson(Map<String, dynamic> json) =>
    _RestaurantData(
      id: json['id'] as String,
      facilityId: json['facilityId'] as String,
      operatingHours: OperatingHours.fromJson(
        json['operatingHours'] as Map<String, dynamic>,
      ),
      cuisine: json['cuisine'] as String,
      priceRange: json['priceRange'] as String,
    );

Map<String, dynamic> _$RestaurantDataToJson(_RestaurantData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'facilityId': instance.facilityId,
      'operatingHours': instance.operatingHours,
      'cuisine': instance.cuisine,
      'priceRange': instance.priceRange,
    };

_MenuData _$MenuDataFromJson(Map<String, dynamic> json) => _MenuData(
  restaurantId: json['restaurantId'] as String,
  categories: (json['categories'] as List<dynamic>)
      .map((e) => MenuCategory.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MenuDataToJson(_MenuData instance) => <String, dynamic>{
  'restaurantId': instance.restaurantId,
  'categories': instance.categories,
};

_MenuCategory _$MenuCategoryFromJson(Map<String, dynamic> json) =>
    _MenuCategory(
      name: json['name'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MenuCategoryToJson(_MenuCategory instance) =>
    <String, dynamic>{'name': instance.name, 'items': instance.items};

_MenuItem _$MenuItemFromJson(Map<String, dynamic> json) => _MenuItem(
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  description: json['description'] as String,
);

Map<String, dynamic> _$MenuItemToJson(_MenuItem instance) => <String, dynamic>{
  'name': instance.name,
  'price': instance.price,
  'description': instance.description,
};

_FavoriteRideRef _$FavoriteRideRefFromJson(Map<String, dynamic> json) =>
    _FavoriteRideRef(rideId: json['rideId'] as String);

Map<String, dynamic> _$FavoriteRideRefToJson(_FavoriteRideRef instance) =>
    <String, dynamic>{'rideId': instance.rideId};

_UserFavorites _$UserFavoritesFromJson(Map<String, dynamic> json) =>
    _UserFavorites(
      userId: json['userId'] as String,
      lastUpdated: json['lastUpdated'] as String,
      favoriteRides: (json['favoriteRides'] as List<dynamic>)
          .map((e) => FavoriteRideRef.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserFavoritesToJson(_UserFavorites instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'lastUpdated': instance.lastUpdated,
      'favoriteRides': instance.favoriteRides,
    };
