// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'extra_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShowSchedule {

 String get facilityId; List<String> get showtimes;
/// Create a copy of ShowSchedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShowScheduleCopyWith<ShowSchedule> get copyWith => _$ShowScheduleCopyWithImpl<ShowSchedule>(this as ShowSchedule, _$identity);

  /// Serializes this ShowSchedule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShowSchedule&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&const DeepCollectionEquality().equals(other.showtimes, showtimes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,facilityId,const DeepCollectionEquality().hash(showtimes));

@override
String toString() {
  return 'ShowSchedule(facilityId: $facilityId, showtimes: $showtimes)';
}


}

/// @nodoc
abstract mixin class $ShowScheduleCopyWith<$Res>  {
  factory $ShowScheduleCopyWith(ShowSchedule value, $Res Function(ShowSchedule) _then) = _$ShowScheduleCopyWithImpl;
@useResult
$Res call({
 String facilityId, List<String> showtimes
});




}
/// @nodoc
class _$ShowScheduleCopyWithImpl<$Res>
    implements $ShowScheduleCopyWith<$Res> {
  _$ShowScheduleCopyWithImpl(this._self, this._then);

  final ShowSchedule _self;
  final $Res Function(ShowSchedule) _then;

/// Create a copy of ShowSchedule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? facilityId = null,Object? showtimes = null,}) {
  return _then(_self.copyWith(
facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as String,showtimes: null == showtimes ? _self.showtimes : showtimes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ShowSchedule].
extension ShowSchedulePatterns on ShowSchedule {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShowSchedule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShowSchedule() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShowSchedule value)  $default,){
final _that = this;
switch (_that) {
case _ShowSchedule():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShowSchedule value)?  $default,){
final _that = this;
switch (_that) {
case _ShowSchedule() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String facilityId,  List<String> showtimes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShowSchedule() when $default != null:
return $default(_that.facilityId,_that.showtimes);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String facilityId,  List<String> showtimes)  $default,) {final _that = this;
switch (_that) {
case _ShowSchedule():
return $default(_that.facilityId,_that.showtimes);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String facilityId,  List<String> showtimes)?  $default,) {final _that = this;
switch (_that) {
case _ShowSchedule() when $default != null:
return $default(_that.facilityId,_that.showtimes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShowSchedule implements ShowSchedule {
  const _ShowSchedule({required this.facilityId, required final  List<String> showtimes}): _showtimes = showtimes;
  factory _ShowSchedule.fromJson(Map<String, dynamic> json) => _$ShowScheduleFromJson(json);

@override final  String facilityId;
 final  List<String> _showtimes;
@override List<String> get showtimes {
  if (_showtimes is EqualUnmodifiableListView) return _showtimes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_showtimes);
}


/// Create a copy of ShowSchedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShowScheduleCopyWith<_ShowSchedule> get copyWith => __$ShowScheduleCopyWithImpl<_ShowSchedule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShowScheduleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShowSchedule&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&const DeepCollectionEquality().equals(other._showtimes, _showtimes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,facilityId,const DeepCollectionEquality().hash(_showtimes));

@override
String toString() {
  return 'ShowSchedule(facilityId: $facilityId, showtimes: $showtimes)';
}


}

/// @nodoc
abstract mixin class _$ShowScheduleCopyWith<$Res> implements $ShowScheduleCopyWith<$Res> {
  factory _$ShowScheduleCopyWith(_ShowSchedule value, $Res Function(_ShowSchedule) _then) = __$ShowScheduleCopyWithImpl;
@override @useResult
$Res call({
 String facilityId, List<String> showtimes
});




}
/// @nodoc
class __$ShowScheduleCopyWithImpl<$Res>
    implements _$ShowScheduleCopyWith<$Res> {
  __$ShowScheduleCopyWithImpl(this._self, this._then);

  final _ShowSchedule _self;
  final $Res Function(_ShowSchedule) _then;

/// Create a copy of ShowSchedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? facilityId = null,Object? showtimes = null,}) {
  return _then(_ShowSchedule(
facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as String,showtimes: null == showtimes ? _self._showtimes : showtimes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$RestaurantData {

 String get id; String get facilityId; OperatingHours get operatingHours; String get cuisine; String get priceRange;
/// Create a copy of RestaurantData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RestaurantDataCopyWith<RestaurantData> get copyWith => _$RestaurantDataCopyWithImpl<RestaurantData>(this as RestaurantData, _$identity);

  /// Serializes this RestaurantData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RestaurantData&&(identical(other.id, id) || other.id == id)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.operatingHours, operatingHours) || other.operatingHours == operatingHours)&&(identical(other.cuisine, cuisine) || other.cuisine == cuisine)&&(identical(other.priceRange, priceRange) || other.priceRange == priceRange));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,facilityId,operatingHours,cuisine,priceRange);

@override
String toString() {
  return 'RestaurantData(id: $id, facilityId: $facilityId, operatingHours: $operatingHours, cuisine: $cuisine, priceRange: $priceRange)';
}


}

/// @nodoc
abstract mixin class $RestaurantDataCopyWith<$Res>  {
  factory $RestaurantDataCopyWith(RestaurantData value, $Res Function(RestaurantData) _then) = _$RestaurantDataCopyWithImpl;
@useResult
$Res call({
 String id, String facilityId, OperatingHours operatingHours, String cuisine, String priceRange
});


$OperatingHoursCopyWith<$Res> get operatingHours;

}
/// @nodoc
class _$RestaurantDataCopyWithImpl<$Res>
    implements $RestaurantDataCopyWith<$Res> {
  _$RestaurantDataCopyWithImpl(this._self, this._then);

  final RestaurantData _self;
  final $Res Function(RestaurantData) _then;

/// Create a copy of RestaurantData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? facilityId = null,Object? operatingHours = null,Object? cuisine = null,Object? priceRange = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as String,operatingHours: null == operatingHours ? _self.operatingHours : operatingHours // ignore: cast_nullable_to_non_nullable
as OperatingHours,cuisine: null == cuisine ? _self.cuisine : cuisine // ignore: cast_nullable_to_non_nullable
as String,priceRange: null == priceRange ? _self.priceRange : priceRange // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of RestaurantData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OperatingHoursCopyWith<$Res> get operatingHours {
  
  return $OperatingHoursCopyWith<$Res>(_self.operatingHours, (value) {
    return _then(_self.copyWith(operatingHours: value));
  });
}
}


/// Adds pattern-matching-related methods to [RestaurantData].
extension RestaurantDataPatterns on RestaurantData {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RestaurantData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RestaurantData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RestaurantData value)  $default,){
final _that = this;
switch (_that) {
case _RestaurantData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RestaurantData value)?  $default,){
final _that = this;
switch (_that) {
case _RestaurantData() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String facilityId,  OperatingHours operatingHours,  String cuisine,  String priceRange)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RestaurantData() when $default != null:
return $default(_that.id,_that.facilityId,_that.operatingHours,_that.cuisine,_that.priceRange);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String facilityId,  OperatingHours operatingHours,  String cuisine,  String priceRange)  $default,) {final _that = this;
switch (_that) {
case _RestaurantData():
return $default(_that.id,_that.facilityId,_that.operatingHours,_that.cuisine,_that.priceRange);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String facilityId,  OperatingHours operatingHours,  String cuisine,  String priceRange)?  $default,) {final _that = this;
switch (_that) {
case _RestaurantData() when $default != null:
return $default(_that.id,_that.facilityId,_that.operatingHours,_that.cuisine,_that.priceRange);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RestaurantData implements RestaurantData {
  const _RestaurantData({required this.id, required this.facilityId, required this.operatingHours, required this.cuisine, required this.priceRange});
  factory _RestaurantData.fromJson(Map<String, dynamic> json) => _$RestaurantDataFromJson(json);

@override final  String id;
@override final  String facilityId;
@override final  OperatingHours operatingHours;
@override final  String cuisine;
@override final  String priceRange;

/// Create a copy of RestaurantData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RestaurantDataCopyWith<_RestaurantData> get copyWith => __$RestaurantDataCopyWithImpl<_RestaurantData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RestaurantDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RestaurantData&&(identical(other.id, id) || other.id == id)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.operatingHours, operatingHours) || other.operatingHours == operatingHours)&&(identical(other.cuisine, cuisine) || other.cuisine == cuisine)&&(identical(other.priceRange, priceRange) || other.priceRange == priceRange));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,facilityId,operatingHours,cuisine,priceRange);

@override
String toString() {
  return 'RestaurantData(id: $id, facilityId: $facilityId, operatingHours: $operatingHours, cuisine: $cuisine, priceRange: $priceRange)';
}


}

/// @nodoc
abstract mixin class _$RestaurantDataCopyWith<$Res> implements $RestaurantDataCopyWith<$Res> {
  factory _$RestaurantDataCopyWith(_RestaurantData value, $Res Function(_RestaurantData) _then) = __$RestaurantDataCopyWithImpl;
@override @useResult
$Res call({
 String id, String facilityId, OperatingHours operatingHours, String cuisine, String priceRange
});


@override $OperatingHoursCopyWith<$Res> get operatingHours;

}
/// @nodoc
class __$RestaurantDataCopyWithImpl<$Res>
    implements _$RestaurantDataCopyWith<$Res> {
  __$RestaurantDataCopyWithImpl(this._self, this._then);

  final _RestaurantData _self;
  final $Res Function(_RestaurantData) _then;

/// Create a copy of RestaurantData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? facilityId = null,Object? operatingHours = null,Object? cuisine = null,Object? priceRange = null,}) {
  return _then(_RestaurantData(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as String,operatingHours: null == operatingHours ? _self.operatingHours : operatingHours // ignore: cast_nullable_to_non_nullable
as OperatingHours,cuisine: null == cuisine ? _self.cuisine : cuisine // ignore: cast_nullable_to_non_nullable
as String,priceRange: null == priceRange ? _self.priceRange : priceRange // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of RestaurantData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OperatingHoursCopyWith<$Res> get operatingHours {
  
  return $OperatingHoursCopyWith<$Res>(_self.operatingHours, (value) {
    return _then(_self.copyWith(operatingHours: value));
  });
}
}


/// @nodoc
mixin _$MenuData {

 String get restaurantId; List<MenuCategory> get categories;
/// Create a copy of MenuData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuDataCopyWith<MenuData> get copyWith => _$MenuDataCopyWithImpl<MenuData>(this as MenuData, _$identity);

  /// Serializes this MenuData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuData&&(identical(other.restaurantId, restaurantId) || other.restaurantId == restaurantId)&&const DeepCollectionEquality().equals(other.categories, categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,restaurantId,const DeepCollectionEquality().hash(categories));

@override
String toString() {
  return 'MenuData(restaurantId: $restaurantId, categories: $categories)';
}


}

/// @nodoc
abstract mixin class $MenuDataCopyWith<$Res>  {
  factory $MenuDataCopyWith(MenuData value, $Res Function(MenuData) _then) = _$MenuDataCopyWithImpl;
@useResult
$Res call({
 String restaurantId, List<MenuCategory> categories
});




}
/// @nodoc
class _$MenuDataCopyWithImpl<$Res>
    implements $MenuDataCopyWith<$Res> {
  _$MenuDataCopyWithImpl(this._self, this._then);

  final MenuData _self;
  final $Res Function(MenuData) _then;

/// Create a copy of MenuData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? restaurantId = null,Object? categories = null,}) {
  return _then(_self.copyWith(
restaurantId: null == restaurantId ? _self.restaurantId : restaurantId // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<MenuCategory>,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuData].
extension MenuDataPatterns on MenuData {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuData value)  $default,){
final _that = this;
switch (_that) {
case _MenuData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuData value)?  $default,){
final _that = this;
switch (_that) {
case _MenuData() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String restaurantId,  List<MenuCategory> categories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuData() when $default != null:
return $default(_that.restaurantId,_that.categories);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String restaurantId,  List<MenuCategory> categories)  $default,) {final _that = this;
switch (_that) {
case _MenuData():
return $default(_that.restaurantId,_that.categories);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String restaurantId,  List<MenuCategory> categories)?  $default,) {final _that = this;
switch (_that) {
case _MenuData() when $default != null:
return $default(_that.restaurantId,_that.categories);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MenuData implements MenuData {
  const _MenuData({required this.restaurantId, required final  List<MenuCategory> categories}): _categories = categories;
  factory _MenuData.fromJson(Map<String, dynamic> json) => _$MenuDataFromJson(json);

@override final  String restaurantId;
 final  List<MenuCategory> _categories;
@override List<MenuCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}


/// Create a copy of MenuData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuDataCopyWith<_MenuData> get copyWith => __$MenuDataCopyWithImpl<_MenuData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MenuDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuData&&(identical(other.restaurantId, restaurantId) || other.restaurantId == restaurantId)&&const DeepCollectionEquality().equals(other._categories, _categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,restaurantId,const DeepCollectionEquality().hash(_categories));

@override
String toString() {
  return 'MenuData(restaurantId: $restaurantId, categories: $categories)';
}


}

/// @nodoc
abstract mixin class _$MenuDataCopyWith<$Res> implements $MenuDataCopyWith<$Res> {
  factory _$MenuDataCopyWith(_MenuData value, $Res Function(_MenuData) _then) = __$MenuDataCopyWithImpl;
@override @useResult
$Res call({
 String restaurantId, List<MenuCategory> categories
});




}
/// @nodoc
class __$MenuDataCopyWithImpl<$Res>
    implements _$MenuDataCopyWith<$Res> {
  __$MenuDataCopyWithImpl(this._self, this._then);

  final _MenuData _self;
  final $Res Function(_MenuData) _then;

/// Create a copy of MenuData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? restaurantId = null,Object? categories = null,}) {
  return _then(_MenuData(
restaurantId: null == restaurantId ? _self.restaurantId : restaurantId // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<MenuCategory>,
  ));
}


}


/// @nodoc
mixin _$MenuCategory {

 String get name; List<MenuItem> get items;
/// Create a copy of MenuCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuCategoryCopyWith<MenuCategory> get copyWith => _$MenuCategoryCopyWithImpl<MenuCategory>(this as MenuCategory, _$identity);

  /// Serializes this MenuCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuCategory&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'MenuCategory(name: $name, items: $items)';
}


}

/// @nodoc
abstract mixin class $MenuCategoryCopyWith<$Res>  {
  factory $MenuCategoryCopyWith(MenuCategory value, $Res Function(MenuCategory) _then) = _$MenuCategoryCopyWithImpl;
@useResult
$Res call({
 String name, List<MenuItem> items
});




}
/// @nodoc
class _$MenuCategoryCopyWithImpl<$Res>
    implements $MenuCategoryCopyWith<$Res> {
  _$MenuCategoryCopyWithImpl(this._self, this._then);

  final MenuCategory _self;
  final $Res Function(MenuCategory) _then;

/// Create a copy of MenuCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? items = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<MenuItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuCategory].
extension MenuCategoryPatterns on MenuCategory {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuCategory() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuCategory value)  $default,){
final _that = this;
switch (_that) {
case _MenuCategory():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuCategory value)?  $default,){
final _that = this;
switch (_that) {
case _MenuCategory() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  List<MenuItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuCategory() when $default != null:
return $default(_that.name,_that.items);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  List<MenuItem> items)  $default,) {final _that = this;
switch (_that) {
case _MenuCategory():
return $default(_that.name,_that.items);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  List<MenuItem> items)?  $default,) {final _that = this;
switch (_that) {
case _MenuCategory() when $default != null:
return $default(_that.name,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MenuCategory implements MenuCategory {
  const _MenuCategory({required this.name, required final  List<MenuItem> items}): _items = items;
  factory _MenuCategory.fromJson(Map<String, dynamic> json) => _$MenuCategoryFromJson(json);

@override final  String name;
 final  List<MenuItem> _items;
@override List<MenuItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of MenuCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuCategoryCopyWith<_MenuCategory> get copyWith => __$MenuCategoryCopyWithImpl<_MenuCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MenuCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuCategory&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'MenuCategory(name: $name, items: $items)';
}


}

/// @nodoc
abstract mixin class _$MenuCategoryCopyWith<$Res> implements $MenuCategoryCopyWith<$Res> {
  factory _$MenuCategoryCopyWith(_MenuCategory value, $Res Function(_MenuCategory) _then) = __$MenuCategoryCopyWithImpl;
@override @useResult
$Res call({
 String name, List<MenuItem> items
});




}
/// @nodoc
class __$MenuCategoryCopyWithImpl<$Res>
    implements _$MenuCategoryCopyWith<$Res> {
  __$MenuCategoryCopyWithImpl(this._self, this._then);

  final _MenuCategory _self;
  final $Res Function(_MenuCategory) _then;

/// Create a copy of MenuCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? items = null,}) {
  return _then(_MenuCategory(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<MenuItem>,
  ));
}


}


/// @nodoc
mixin _$MenuItem {

 String get name; double get price; String get description;
/// Create a copy of MenuItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuItemCopyWith<MenuItem> get copyWith => _$MenuItemCopyWithImpl<MenuItem>(this as MenuItem, _$identity);

  /// Serializes this MenuItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuItem&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,price,description);

@override
String toString() {
  return 'MenuItem(name: $name, price: $price, description: $description)';
}


}

/// @nodoc
abstract mixin class $MenuItemCopyWith<$Res>  {
  factory $MenuItemCopyWith(MenuItem value, $Res Function(MenuItem) _then) = _$MenuItemCopyWithImpl;
@useResult
$Res call({
 String name, double price, String description
});




}
/// @nodoc
class _$MenuItemCopyWithImpl<$Res>
    implements $MenuItemCopyWith<$Res> {
  _$MenuItemCopyWithImpl(this._self, this._then);

  final MenuItem _self;
  final $Res Function(MenuItem) _then;

/// Create a copy of MenuItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? price = null,Object? description = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuItem].
extension MenuItemPatterns on MenuItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuItem value)  $default,){
final _that = this;
switch (_that) {
case _MenuItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuItem value)?  $default,){
final _that = this;
switch (_that) {
case _MenuItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  double price,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuItem() when $default != null:
return $default(_that.name,_that.price,_that.description);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  double price,  String description)  $default,) {final _that = this;
switch (_that) {
case _MenuItem():
return $default(_that.name,_that.price,_that.description);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  double price,  String description)?  $default,) {final _that = this;
switch (_that) {
case _MenuItem() when $default != null:
return $default(_that.name,_that.price,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MenuItem implements MenuItem {
  const _MenuItem({required this.name, required this.price, required this.description});
  factory _MenuItem.fromJson(Map<String, dynamic> json) => _$MenuItemFromJson(json);

@override final  String name;
@override final  double price;
@override final  String description;

/// Create a copy of MenuItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuItemCopyWith<_MenuItem> get copyWith => __$MenuItemCopyWithImpl<_MenuItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MenuItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuItem&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,price,description);

@override
String toString() {
  return 'MenuItem(name: $name, price: $price, description: $description)';
}


}

/// @nodoc
abstract mixin class _$MenuItemCopyWith<$Res> implements $MenuItemCopyWith<$Res> {
  factory _$MenuItemCopyWith(_MenuItem value, $Res Function(_MenuItem) _then) = __$MenuItemCopyWithImpl;
@override @useResult
$Res call({
 String name, double price, String description
});




}
/// @nodoc
class __$MenuItemCopyWithImpl<$Res>
    implements _$MenuItemCopyWith<$Res> {
  __$MenuItemCopyWithImpl(this._self, this._then);

  final _MenuItem _self;
  final $Res Function(_MenuItem) _then;

/// Create a copy of MenuItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? price = null,Object? description = null,}) {
  return _then(_MenuItem(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$FavoriteRideRef {

 String get rideId;
/// Create a copy of FavoriteRideRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoriteRideRefCopyWith<FavoriteRideRef> get copyWith => _$FavoriteRideRefCopyWithImpl<FavoriteRideRef>(this as FavoriteRideRef, _$identity);

  /// Serializes this FavoriteRideRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoriteRideRef&&(identical(other.rideId, rideId) || other.rideId == rideId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rideId);

@override
String toString() {
  return 'FavoriteRideRef(rideId: $rideId)';
}


}

/// @nodoc
abstract mixin class $FavoriteRideRefCopyWith<$Res>  {
  factory $FavoriteRideRefCopyWith(FavoriteRideRef value, $Res Function(FavoriteRideRef) _then) = _$FavoriteRideRefCopyWithImpl;
@useResult
$Res call({
 String rideId
});




}
/// @nodoc
class _$FavoriteRideRefCopyWithImpl<$Res>
    implements $FavoriteRideRefCopyWith<$Res> {
  _$FavoriteRideRefCopyWithImpl(this._self, this._then);

  final FavoriteRideRef _self;
  final $Res Function(FavoriteRideRef) _then;

/// Create a copy of FavoriteRideRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rideId = null,}) {
  return _then(_self.copyWith(
rideId: null == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FavoriteRideRef].
extension FavoriteRideRefPatterns on FavoriteRideRef {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavoriteRideRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavoriteRideRef() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavoriteRideRef value)  $default,){
final _that = this;
switch (_that) {
case _FavoriteRideRef():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavoriteRideRef value)?  $default,){
final _that = this;
switch (_that) {
case _FavoriteRideRef() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String rideId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavoriteRideRef() when $default != null:
return $default(_that.rideId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String rideId)  $default,) {final _that = this;
switch (_that) {
case _FavoriteRideRef():
return $default(_that.rideId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String rideId)?  $default,) {final _that = this;
switch (_that) {
case _FavoriteRideRef() when $default != null:
return $default(_that.rideId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FavoriteRideRef implements FavoriteRideRef {
  const _FavoriteRideRef({required this.rideId});
  factory _FavoriteRideRef.fromJson(Map<String, dynamic> json) => _$FavoriteRideRefFromJson(json);

@override final  String rideId;

/// Create a copy of FavoriteRideRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavoriteRideRefCopyWith<_FavoriteRideRef> get copyWith => __$FavoriteRideRefCopyWithImpl<_FavoriteRideRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FavoriteRideRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavoriteRideRef&&(identical(other.rideId, rideId) || other.rideId == rideId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rideId);

@override
String toString() {
  return 'FavoriteRideRef(rideId: $rideId)';
}


}

/// @nodoc
abstract mixin class _$FavoriteRideRefCopyWith<$Res> implements $FavoriteRideRefCopyWith<$Res> {
  factory _$FavoriteRideRefCopyWith(_FavoriteRideRef value, $Res Function(_FavoriteRideRef) _then) = __$FavoriteRideRefCopyWithImpl;
@override @useResult
$Res call({
 String rideId
});




}
/// @nodoc
class __$FavoriteRideRefCopyWithImpl<$Res>
    implements _$FavoriteRideRefCopyWith<$Res> {
  __$FavoriteRideRefCopyWithImpl(this._self, this._then);

  final _FavoriteRideRef _self;
  final $Res Function(_FavoriteRideRef) _then;

/// Create a copy of FavoriteRideRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rideId = null,}) {
  return _then(_FavoriteRideRef(
rideId: null == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UserFavorites {

 String get userId; String get lastUpdated; List<FavoriteRideRef> get favoriteRides;
/// Create a copy of UserFavorites
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserFavoritesCopyWith<UserFavorites> get copyWith => _$UserFavoritesCopyWithImpl<UserFavorites>(this as UserFavorites, _$identity);

  /// Serializes this UserFavorites to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserFavorites&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&const DeepCollectionEquality().equals(other.favoriteRides, favoriteRides));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,lastUpdated,const DeepCollectionEquality().hash(favoriteRides));

@override
String toString() {
  return 'UserFavorites(userId: $userId, lastUpdated: $lastUpdated, favoriteRides: $favoriteRides)';
}


}

/// @nodoc
abstract mixin class $UserFavoritesCopyWith<$Res>  {
  factory $UserFavoritesCopyWith(UserFavorites value, $Res Function(UserFavorites) _then) = _$UserFavoritesCopyWithImpl;
@useResult
$Res call({
 String userId, String lastUpdated, List<FavoriteRideRef> favoriteRides
});




}
/// @nodoc
class _$UserFavoritesCopyWithImpl<$Res>
    implements $UserFavoritesCopyWith<$Res> {
  _$UserFavoritesCopyWithImpl(this._self, this._then);

  final UserFavorites _self;
  final $Res Function(UserFavorites) _then;

/// Create a copy of UserFavorites
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? lastUpdated = null,Object? favoriteRides = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as String,favoriteRides: null == favoriteRides ? _self.favoriteRides : favoriteRides // ignore: cast_nullable_to_non_nullable
as List<FavoriteRideRef>,
  ));
}

}


/// Adds pattern-matching-related methods to [UserFavorites].
extension UserFavoritesPatterns on UserFavorites {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserFavorites value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserFavorites() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserFavorites value)  $default,){
final _that = this;
switch (_that) {
case _UserFavorites():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserFavorites value)?  $default,){
final _that = this;
switch (_that) {
case _UserFavorites() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String lastUpdated,  List<FavoriteRideRef> favoriteRides)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserFavorites() when $default != null:
return $default(_that.userId,_that.lastUpdated,_that.favoriteRides);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String lastUpdated,  List<FavoriteRideRef> favoriteRides)  $default,) {final _that = this;
switch (_that) {
case _UserFavorites():
return $default(_that.userId,_that.lastUpdated,_that.favoriteRides);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String lastUpdated,  List<FavoriteRideRef> favoriteRides)?  $default,) {final _that = this;
switch (_that) {
case _UserFavorites() when $default != null:
return $default(_that.userId,_that.lastUpdated,_that.favoriteRides);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserFavorites implements UserFavorites {
  const _UserFavorites({required this.userId, required this.lastUpdated, required final  List<FavoriteRideRef> favoriteRides}): _favoriteRides = favoriteRides;
  factory _UserFavorites.fromJson(Map<String, dynamic> json) => _$UserFavoritesFromJson(json);

@override final  String userId;
@override final  String lastUpdated;
 final  List<FavoriteRideRef> _favoriteRides;
@override List<FavoriteRideRef> get favoriteRides {
  if (_favoriteRides is EqualUnmodifiableListView) return _favoriteRides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_favoriteRides);
}


/// Create a copy of UserFavorites
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserFavoritesCopyWith<_UserFavorites> get copyWith => __$UserFavoritesCopyWithImpl<_UserFavorites>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserFavoritesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserFavorites&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&const DeepCollectionEquality().equals(other._favoriteRides, _favoriteRides));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,lastUpdated,const DeepCollectionEquality().hash(_favoriteRides));

@override
String toString() {
  return 'UserFavorites(userId: $userId, lastUpdated: $lastUpdated, favoriteRides: $favoriteRides)';
}


}

/// @nodoc
abstract mixin class _$UserFavoritesCopyWith<$Res> implements $UserFavoritesCopyWith<$Res> {
  factory _$UserFavoritesCopyWith(_UserFavorites value, $Res Function(_UserFavorites) _then) = __$UserFavoritesCopyWithImpl;
@override @useResult
$Res call({
 String userId, String lastUpdated, List<FavoriteRideRef> favoriteRides
});




}
/// @nodoc
class __$UserFavoritesCopyWithImpl<$Res>
    implements _$UserFavoritesCopyWith<$Res> {
  __$UserFavoritesCopyWithImpl(this._self, this._then);

  final _UserFavorites _self;
  final $Res Function(_UserFavorites) _then;

/// Create a copy of UserFavorites
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? lastUpdated = null,Object? favoriteRides = null,}) {
  return _then(_UserFavorites(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as String,favoriteRides: null == favoriteRides ? _self._favoriteRides : favoriteRides // ignore: cast_nullable_to_non_nullable
as List<FavoriteRideRef>,
  ));
}


}

// dart format on
