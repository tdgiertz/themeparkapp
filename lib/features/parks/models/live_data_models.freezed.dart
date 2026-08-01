// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'live_data_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RideWaitTime {

 String get rideId; String get name; int get waitMinutes;
/// Create a copy of RideWaitTime
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideWaitTimeCopyWith<RideWaitTime> get copyWith => _$RideWaitTimeCopyWithImpl<RideWaitTime>(this as RideWaitTime, _$identity);

  /// Serializes this RideWaitTime to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideWaitTime&&(identical(other.rideId, rideId) || other.rideId == rideId)&&(identical(other.name, name) || other.name == name)&&(identical(other.waitMinutes, waitMinutes) || other.waitMinutes == waitMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rideId,name,waitMinutes);

@override
String toString() {
  return 'RideWaitTime(rideId: $rideId, name: $name, waitMinutes: $waitMinutes)';
}


}

/// @nodoc
abstract mixin class $RideWaitTimeCopyWith<$Res>  {
  factory $RideWaitTimeCopyWith(RideWaitTime value, $Res Function(RideWaitTime) _then) = _$RideWaitTimeCopyWithImpl;
@useResult
$Res call({
 String rideId, String name, int waitMinutes
});




}
/// @nodoc
class _$RideWaitTimeCopyWithImpl<$Res>
    implements $RideWaitTimeCopyWith<$Res> {
  _$RideWaitTimeCopyWithImpl(this._self, this._then);

  final RideWaitTime _self;
  final $Res Function(RideWaitTime) _then;

/// Create a copy of RideWaitTime
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rideId = null,Object? name = null,Object? waitMinutes = null,}) {
  return _then(RideWaitTime(
rideId: null == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,waitMinutes: null == waitMinutes ? _self.waitMinutes : waitMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RideWaitTime].
extension RideWaitTimePatterns on RideWaitTime {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideWaitTime value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideWaitTime() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideWaitTime value)  $default,){
final _that = this;
switch (_that) {
case _RideWaitTime():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideWaitTime value)?  $default,){
final _that = this;
switch (_that) {
case _RideWaitTime() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String rideId,  String name,  int waitMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideWaitTime() when $default != null:
return $default(_that.rideId,_that.name,_that.waitMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String rideId,  String name,  int waitMinutes)  $default,) {final _that = this;
switch (_that) {
case _RideWaitTime():
return $default(_that.rideId,_that.name,_that.waitMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String rideId,  String name,  int waitMinutes)?  $default,) {final _that = this;
switch (_that) {
case _RideWaitTime() when $default != null:
return $default(_that.rideId,_that.name,_that.waitMinutes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RideWaitTime implements RideWaitTime {
  const _RideWaitTime({required this.rideId, this.name = '', required this.waitMinutes});
  factory _RideWaitTime.fromJson(Map<String, dynamic> json) => _$RideWaitTimeFromJson(json);

@override final  String rideId;
@override final  String name;
@override final  int waitMinutes;

/// Create a copy of RideWaitTime
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideWaitTimeCopyWith<_RideWaitTime> get copyWith => __$RideWaitTimeCopyWithImpl<_RideWaitTime>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RideWaitTimeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideWaitTime&&(identical(other.rideId, rideId) || other.rideId == rideId)&&(identical(other.name, name) || other.name == name)&&(identical(other.waitMinutes, waitMinutes) || other.waitMinutes == waitMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rideId,name,waitMinutes);

@override
String toString() {
  return 'RideWaitTime(rideId: $rideId, name: $name, waitMinutes: $waitMinutes)';
}


}

/// @nodoc
abstract mixin class _$RideWaitTimeCopyWith<$Res> implements $RideWaitTimeCopyWith<$Res> {
  factory _$RideWaitTimeCopyWith(_RideWaitTime value, $Res Function(_RideWaitTime) _then) = __$RideWaitTimeCopyWithImpl;
@override @useResult
$Res call({
 String rideId, String name, int waitMinutes
});




}
/// @nodoc
class __$RideWaitTimeCopyWithImpl<$Res>
    implements _$RideWaitTimeCopyWith<$Res> {
  __$RideWaitTimeCopyWithImpl(this._self, this._then);

  final _RideWaitTime _self;
  final $Res Function(_RideWaitTime) _then;

/// Create a copy of RideWaitTime
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rideId = null,Object? name = null,Object? waitMinutes = null,}) {
  return _then(_RideWaitTime(
rideId: null == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,waitMinutes: null == waitMinutes ? _self.waitMinutes : waitMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Showtime {

 String get showId; String get name; String get time;
/// Create a copy of Showtime
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShowtimeCopyWith<Showtime> get copyWith => _$ShowtimeCopyWithImpl<Showtime>(this as Showtime, _$identity);

  /// Serializes this Showtime to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Showtime&&(identical(other.showId, showId) || other.showId == showId)&&(identical(other.name, name) || other.name == name)&&(identical(other.time, time) || other.time == time));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,showId,name,time);

@override
String toString() {
  return 'Showtime(showId: $showId, name: $name, time: $time)';
}


}

/// @nodoc
abstract mixin class $ShowtimeCopyWith<$Res>  {
  factory $ShowtimeCopyWith(Showtime value, $Res Function(Showtime) _then) = _$ShowtimeCopyWithImpl;
@useResult
$Res call({
 String showId, String name, String time
});




}
/// @nodoc
class _$ShowtimeCopyWithImpl<$Res>
    implements $ShowtimeCopyWith<$Res> {
  _$ShowtimeCopyWithImpl(this._self, this._then);

  final Showtime _self;
  final $Res Function(Showtime) _then;

/// Create a copy of Showtime
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? showId = null,Object? name = null,Object? time = null,}) {
  return _then(Showtime(
showId: null == showId ? _self.showId : showId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Showtime].
extension ShowtimePatterns on Showtime {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Showtime value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Showtime() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Showtime value)  $default,){
final _that = this;
switch (_that) {
case _Showtime():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Showtime value)?  $default,){
final _that = this;
switch (_that) {
case _Showtime() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String showId,  String name,  String time)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Showtime() when $default != null:
return $default(_that.showId,_that.name,_that.time);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String showId,  String name,  String time)  $default,) {final _that = this;
switch (_that) {
case _Showtime():
return $default(_that.showId,_that.name,_that.time);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String showId,  String name,  String time)?  $default,) {final _that = this;
switch (_that) {
case _Showtime() when $default != null:
return $default(_that.showId,_that.name,_that.time);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Showtime implements Showtime {
  const _Showtime({required this.showId, required this.name, required this.time});
  factory _Showtime.fromJson(Map<String, dynamic> json) => _$ShowtimeFromJson(json);

@override final  String showId;
@override final  String name;
@override final  String time;

/// Create a copy of Showtime
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShowtimeCopyWith<_Showtime> get copyWith => __$ShowtimeCopyWithImpl<_Showtime>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShowtimeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Showtime&&(identical(other.showId, showId) || other.showId == showId)&&(identical(other.name, name) || other.name == name)&&(identical(other.time, time) || other.time == time));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,showId,name,time);

@override
String toString() {
  return 'Showtime(showId: $showId, name: $name, time: $time)';
}


}

/// @nodoc
abstract mixin class _$ShowtimeCopyWith<$Res> implements $ShowtimeCopyWith<$Res> {
  factory _$ShowtimeCopyWith(_Showtime value, $Res Function(_Showtime) _then) = __$ShowtimeCopyWithImpl;
@override @useResult
$Res call({
 String showId, String name, String time
});




}
/// @nodoc
class __$ShowtimeCopyWithImpl<$Res>
    implements _$ShowtimeCopyWith<$Res> {
  __$ShowtimeCopyWithImpl(this._self, this._then);

  final _Showtime _self;
  final $Res Function(_Showtime) _then;

/// Create a copy of Showtime
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? showId = null,Object? name = null,Object? time = null,}) {
  return _then(_Showtime(
showId: null == showId ? _self.showId : showId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ParkHighlights {

 List<RideWaitTime> get shortestWaitTimes; List<Showtime> get nextShowtimes;
/// Create a copy of ParkHighlights
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParkHighlightsCopyWith<ParkHighlights> get copyWith => _$ParkHighlightsCopyWithImpl<ParkHighlights>(this as ParkHighlights, _$identity);

  /// Serializes this ParkHighlights to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParkHighlights&&const DeepCollectionEquality().equals(other.shortestWaitTimes, shortestWaitTimes)&&const DeepCollectionEquality().equals(other.nextShowtimes, nextShowtimes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(shortestWaitTimes),const DeepCollectionEquality().hash(nextShowtimes));

@override
String toString() {
  return 'ParkHighlights(shortestWaitTimes: $shortestWaitTimes, nextShowtimes: $nextShowtimes)';
}


}

/// @nodoc
abstract mixin class $ParkHighlightsCopyWith<$Res>  {
  factory $ParkHighlightsCopyWith(ParkHighlights value, $Res Function(ParkHighlights) _then) = _$ParkHighlightsCopyWithImpl;
@useResult
$Res call({
 List<RideWaitTime> shortestWaitTimes, List<Showtime> nextShowtimes
});




}
/// @nodoc
class _$ParkHighlightsCopyWithImpl<$Res>
    implements $ParkHighlightsCopyWith<$Res> {
  _$ParkHighlightsCopyWithImpl(this._self, this._then);

  final ParkHighlights _self;
  final $Res Function(ParkHighlights) _then;

/// Create a copy of ParkHighlights
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? shortestWaitTimes = null,Object? nextShowtimes = null,}) {
  return _then(ParkHighlights(
shortestWaitTimes: null == shortestWaitTimes ? _self.shortestWaitTimes : shortestWaitTimes // ignore: cast_nullable_to_non_nullable
as List<RideWaitTime>,nextShowtimes: null == nextShowtimes ? _self.nextShowtimes : nextShowtimes // ignore: cast_nullable_to_non_nullable
as List<Showtime>,
  ));
}

}


/// Adds pattern-matching-related methods to [ParkHighlights].
extension ParkHighlightsPatterns on ParkHighlights {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParkHighlights value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParkHighlights() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParkHighlights value)  $default,){
final _that = this;
switch (_that) {
case _ParkHighlights():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParkHighlights value)?  $default,){
final _that = this;
switch (_that) {
case _ParkHighlights() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<RideWaitTime> shortestWaitTimes,  List<Showtime> nextShowtimes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParkHighlights() when $default != null:
return $default(_that.shortestWaitTimes,_that.nextShowtimes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<RideWaitTime> shortestWaitTimes,  List<Showtime> nextShowtimes)  $default,) {final _that = this;
switch (_that) {
case _ParkHighlights():
return $default(_that.shortestWaitTimes,_that.nextShowtimes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<RideWaitTime> shortestWaitTimes,  List<Showtime> nextShowtimes)?  $default,) {final _that = this;
switch (_that) {
case _ParkHighlights() when $default != null:
return $default(_that.shortestWaitTimes,_that.nextShowtimes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ParkHighlights implements ParkHighlights {
  const _ParkHighlights({ List<RideWaitTime> shortestWaitTimes = const [],  List<Showtime> nextShowtimes = const []}): _shortestWaitTimes = shortestWaitTimes,_nextShowtimes = nextShowtimes;
  factory _ParkHighlights.fromJson(Map<String, dynamic> json) => _$ParkHighlightsFromJson(json);

 final  List<RideWaitTime> _shortestWaitTimes;
@override@JsonKey() List<RideWaitTime> get shortestWaitTimes {
  if (_shortestWaitTimes is EqualUnmodifiableListView) return _shortestWaitTimes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_shortestWaitTimes);
}

 final  List<Showtime> _nextShowtimes;
@override@JsonKey() List<Showtime> get nextShowtimes {
  if (_nextShowtimes is EqualUnmodifiableListView) return _nextShowtimes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_nextShowtimes);
}


/// Create a copy of ParkHighlights
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParkHighlightsCopyWith<_ParkHighlights> get copyWith => __$ParkHighlightsCopyWithImpl<_ParkHighlights>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParkHighlightsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParkHighlights&&const DeepCollectionEquality().equals(other._shortestWaitTimes, _shortestWaitTimes)&&const DeepCollectionEquality().equals(other._nextShowtimes, _nextShowtimes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_shortestWaitTimes),const DeepCollectionEquality().hash(_nextShowtimes));

@override
String toString() {
  return 'ParkHighlights(shortestWaitTimes: $shortestWaitTimes, nextShowtimes: $nextShowtimes)';
}


}

/// @nodoc
abstract mixin class _$ParkHighlightsCopyWith<$Res> implements $ParkHighlightsCopyWith<$Res> {
  factory _$ParkHighlightsCopyWith(_ParkHighlights value, $Res Function(_ParkHighlights) _then) = __$ParkHighlightsCopyWithImpl;
@override @useResult
$Res call({
 List<RideWaitTime> shortestWaitTimes, List<Showtime> nextShowtimes
});




}
/// @nodoc
class __$ParkHighlightsCopyWithImpl<$Res>
    implements _$ParkHighlightsCopyWith<$Res> {
  __$ParkHighlightsCopyWithImpl(this._self, this._then);

  final _ParkHighlights _self;
  final $Res Function(_ParkHighlights) _then;

/// Create a copy of ParkHighlights
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? shortestWaitTimes = null,Object? nextShowtimes = null,}) {
  return _then(_ParkHighlights(
shortestWaitTimes: null == shortestWaitTimes ? _self._shortestWaitTimes : shortestWaitTimes // ignore: cast_nullable_to_non_nullable
as List<RideWaitTime>,nextShowtimes: null == nextShowtimes ? _self._nextShowtimes : nextShowtimes // ignore: cast_nullable_to_non_nullable
as List<Showtime>,
  ));
}


}

// dart format on
