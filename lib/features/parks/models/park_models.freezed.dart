// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'park_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Park {

 String get id; String get type; String get name; OperatingHours get operatingHours; String get crowdLevel; List<ParkChild> get children;
/// Create a copy of Park
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParkCopyWith<Park> get copyWith => _$ParkCopyWithImpl<Park>(this as Park, _$identity);

  /// Serializes this Park to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Park&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.operatingHours, operatingHours) || other.operatingHours == operatingHours)&&(identical(other.crowdLevel, crowdLevel) || other.crowdLevel == crowdLevel)&&const DeepCollectionEquality().equals(other.children, children));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,name,operatingHours,crowdLevel,const DeepCollectionEquality().hash(children));

@override
String toString() {
  return 'Park(id: $id, type: $type, name: $name, operatingHours: $operatingHours, crowdLevel: $crowdLevel, children: $children)';
}


}

/// @nodoc
abstract mixin class $ParkCopyWith<$Res>  {
  factory $ParkCopyWith(Park value, $Res Function(Park) _then) = _$ParkCopyWithImpl;
@useResult
$Res call({
 String id, String type, String name, OperatingHours operatingHours, String crowdLevel, List<ParkChild> children
});


$OperatingHoursCopyWith<$Res> get operatingHours;

}
/// @nodoc
class _$ParkCopyWithImpl<$Res>
    implements $ParkCopyWith<$Res> {
  _$ParkCopyWithImpl(this._self, this._then);

  final Park _self;
  final $Res Function(Park) _then;

/// Create a copy of Park
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? name = null,Object? operatingHours = null,Object? crowdLevel = null,Object? children = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,operatingHours: null == operatingHours ? _self.operatingHours : operatingHours // ignore: cast_nullable_to_non_nullable
as OperatingHours,crowdLevel: null == crowdLevel ? _self.crowdLevel : crowdLevel // ignore: cast_nullable_to_non_nullable
as String,children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as List<ParkChild>,
  ));
}
/// Create a copy of Park
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OperatingHoursCopyWith<$Res> get operatingHours {
  
  return $OperatingHoursCopyWith<$Res>(_self.operatingHours, (value) {
    return _then(_self.copyWith(operatingHours: value));
  });
}
}


/// Adds pattern-matching-related methods to [Park].
extension ParkPatterns on Park {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Park value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Park() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Park value)  $default,){
final _that = this;
switch (_that) {
case _Park():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Park value)?  $default,){
final _that = this;
switch (_that) {
case _Park() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String name,  OperatingHours operatingHours,  String crowdLevel,  List<ParkChild> children)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Park() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.operatingHours,_that.crowdLevel,_that.children);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String name,  OperatingHours operatingHours,  String crowdLevel,  List<ParkChild> children)  $default,) {final _that = this;
switch (_that) {
case _Park():
return $default(_that.id,_that.type,_that.name,_that.operatingHours,_that.crowdLevel,_that.children);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String name,  OperatingHours operatingHours,  String crowdLevel,  List<ParkChild> children)?  $default,) {final _that = this;
switch (_that) {
case _Park() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.operatingHours,_that.crowdLevel,_that.children);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Park extends Park {
  const _Park({required this.id, required this.type, required this.name, required this.operatingHours, required this.crowdLevel, final  List<ParkChild> children = const []}): _children = children,super._();
  factory _Park.fromJson(Map<String, dynamic> json) => _$ParkFromJson(json);

@override final  String id;
@override final  String type;
@override final  String name;
@override final  OperatingHours operatingHours;
@override final  String crowdLevel;
 final  List<ParkChild> _children;
@override@JsonKey() List<ParkChild> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}


/// Create a copy of Park
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParkCopyWith<_Park> get copyWith => __$ParkCopyWithImpl<_Park>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParkToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Park&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.operatingHours, operatingHours) || other.operatingHours == operatingHours)&&(identical(other.crowdLevel, crowdLevel) || other.crowdLevel == crowdLevel)&&const DeepCollectionEquality().equals(other._children, _children));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,name,operatingHours,crowdLevel,const DeepCollectionEquality().hash(_children));

@override
String toString() {
  return 'Park(id: $id, type: $type, name: $name, operatingHours: $operatingHours, crowdLevel: $crowdLevel, children: $children)';
}


}

/// @nodoc
abstract mixin class _$ParkCopyWith<$Res> implements $ParkCopyWith<$Res> {
  factory _$ParkCopyWith(_Park value, $Res Function(_Park) _then) = __$ParkCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String name, OperatingHours operatingHours, String crowdLevel, List<ParkChild> children
});


@override $OperatingHoursCopyWith<$Res> get operatingHours;

}
/// @nodoc
class __$ParkCopyWithImpl<$Res>
    implements _$ParkCopyWith<$Res> {
  __$ParkCopyWithImpl(this._self, this._then);

  final _Park _self;
  final $Res Function(_Park) _then;

/// Create a copy of Park
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? name = null,Object? operatingHours = null,Object? crowdLevel = null,Object? children = null,}) {
  return _then(_Park(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,operatingHours: null == operatingHours ? _self.operatingHours : operatingHours // ignore: cast_nullable_to_non_nullable
as OperatingHours,crowdLevel: null == crowdLevel ? _self.crowdLevel : crowdLevel // ignore: cast_nullable_to_non_nullable
as String,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<ParkChild>,
  ));
}

/// Create a copy of Park
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
mixin _$OperatingHours {

 String get open; String get close;
/// Create a copy of OperatingHours
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OperatingHoursCopyWith<OperatingHours> get copyWith => _$OperatingHoursCopyWithImpl<OperatingHours>(this as OperatingHours, _$identity);

  /// Serializes this OperatingHours to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OperatingHours&&(identical(other.open, open) || other.open == open)&&(identical(other.close, close) || other.close == close));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,open,close);

@override
String toString() {
  return 'OperatingHours(open: $open, close: $close)';
}


}

/// @nodoc
abstract mixin class $OperatingHoursCopyWith<$Res>  {
  factory $OperatingHoursCopyWith(OperatingHours value, $Res Function(OperatingHours) _then) = _$OperatingHoursCopyWithImpl;
@useResult
$Res call({
 String open, String close
});




}
/// @nodoc
class _$OperatingHoursCopyWithImpl<$Res>
    implements $OperatingHoursCopyWith<$Res> {
  _$OperatingHoursCopyWithImpl(this._self, this._then);

  final OperatingHours _self;
  final $Res Function(OperatingHours) _then;

/// Create a copy of OperatingHours
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? open = null,Object? close = null,}) {
  return _then(_self.copyWith(
open: null == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as String,close: null == close ? _self.close : close // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OperatingHours].
extension OperatingHoursPatterns on OperatingHours {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OperatingHours value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OperatingHours() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OperatingHours value)  $default,){
final _that = this;
switch (_that) {
case _OperatingHours():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OperatingHours value)?  $default,){
final _that = this;
switch (_that) {
case _OperatingHours() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String open,  String close)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OperatingHours() when $default != null:
return $default(_that.open,_that.close);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String open,  String close)  $default,) {final _that = this;
switch (_that) {
case _OperatingHours():
return $default(_that.open,_that.close);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String open,  String close)?  $default,) {final _that = this;
switch (_that) {
case _OperatingHours() when $default != null:
return $default(_that.open,_that.close);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OperatingHours implements OperatingHours {
  const _OperatingHours({required this.open, required this.close});
  factory _OperatingHours.fromJson(Map<String, dynamic> json) => _$OperatingHoursFromJson(json);

@override final  String open;
@override final  String close;

/// Create a copy of OperatingHours
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OperatingHoursCopyWith<_OperatingHours> get copyWith => __$OperatingHoursCopyWithImpl<_OperatingHours>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OperatingHoursToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OperatingHours&&(identical(other.open, open) || other.open == open)&&(identical(other.close, close) || other.close == close));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,open,close);

@override
String toString() {
  return 'OperatingHours(open: $open, close: $close)';
}


}

/// @nodoc
abstract mixin class _$OperatingHoursCopyWith<$Res> implements $OperatingHoursCopyWith<$Res> {
  factory _$OperatingHoursCopyWith(_OperatingHours value, $Res Function(_OperatingHours) _then) = __$OperatingHoursCopyWithImpl;
@override @useResult
$Res call({
 String open, String close
});




}
/// @nodoc
class __$OperatingHoursCopyWithImpl<$Res>
    implements _$OperatingHoursCopyWith<$Res> {
  __$OperatingHoursCopyWithImpl(this._self, this._then);

  final _OperatingHours _self;
  final $Res Function(_OperatingHours) _then;

/// Create a copy of OperatingHours
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? open = null,Object? close = null,}) {
  return _then(_OperatingHours(
open: null == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as String,close: null == close ? _self.close : close // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ParkChild {

 String get id; String get type; String get name;// We assume children of a Land are Facilities
 List<Facility> get children;
/// Create a copy of ParkChild
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParkChildCopyWith<ParkChild> get copyWith => _$ParkChildCopyWithImpl<ParkChild>(this as ParkChild, _$identity);

  /// Serializes this ParkChild to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParkChild&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.children, children));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,name,const DeepCollectionEquality().hash(children));

@override
String toString() {
  return 'ParkChild(id: $id, type: $type, name: $name, children: $children)';
}


}

/// @nodoc
abstract mixin class $ParkChildCopyWith<$Res>  {
  factory $ParkChildCopyWith(ParkChild value, $Res Function(ParkChild) _then) = _$ParkChildCopyWithImpl;
@useResult
$Res call({
 String id, String type, String name, List<Facility> children
});




}
/// @nodoc
class _$ParkChildCopyWithImpl<$Res>
    implements $ParkChildCopyWith<$Res> {
  _$ParkChildCopyWithImpl(this._self, this._then);

  final ParkChild _self;
  final $Res Function(ParkChild) _then;

/// Create a copy of ParkChild
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? name = null,Object? children = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as List<Facility>,
  ));
}

}


/// Adds pattern-matching-related methods to [ParkChild].
extension ParkChildPatterns on ParkChild {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParkChild value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParkChild() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParkChild value)  $default,){
final _that = this;
switch (_that) {
case _ParkChild():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParkChild value)?  $default,){
final _that = this;
switch (_that) {
case _ParkChild() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String name,  List<Facility> children)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParkChild() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.children);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String name,  List<Facility> children)  $default,) {final _that = this;
switch (_that) {
case _ParkChild():
return $default(_that.id,_that.type,_that.name,_that.children);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String name,  List<Facility> children)?  $default,) {final _that = this;
switch (_that) {
case _ParkChild() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.children);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ParkChild extends ParkChild {
  const _ParkChild({required this.id, required this.type, required this.name, final  List<Facility> children = const []}): _children = children,super._();
  factory _ParkChild.fromJson(Map<String, dynamic> json) => _$ParkChildFromJson(json);

@override final  String id;
@override final  String type;
@override final  String name;
// We assume children of a Land are Facilities
 final  List<Facility> _children;
// We assume children of a Land are Facilities
@override@JsonKey() List<Facility> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}


/// Create a copy of ParkChild
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParkChildCopyWith<_ParkChild> get copyWith => __$ParkChildCopyWithImpl<_ParkChild>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParkChildToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParkChild&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._children, _children));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,name,const DeepCollectionEquality().hash(_children));

@override
String toString() {
  return 'ParkChild(id: $id, type: $type, name: $name, children: $children)';
}


}

/// @nodoc
abstract mixin class _$ParkChildCopyWith<$Res> implements $ParkChildCopyWith<$Res> {
  factory _$ParkChildCopyWith(_ParkChild value, $Res Function(_ParkChild) _then) = __$ParkChildCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String name, List<Facility> children
});




}
/// @nodoc
class __$ParkChildCopyWithImpl<$Res>
    implements _$ParkChildCopyWith<$Res> {
  __$ParkChildCopyWithImpl(this._self, this._then);

  final _ParkChild _self;
  final $Res Function(_ParkChild) _then;

/// Create a copy of ParkChild
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? name = null,Object? children = null,}) {
  return _then(_ParkChild(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<Facility>,
  ));
}


}


/// @nodoc
mixin _$Facility {

 String get id; String get type; String get category; String get name; String get thrillLevel; int get heightRequirementInches;
/// Create a copy of Facility
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FacilityCopyWith<Facility> get copyWith => _$FacilityCopyWithImpl<Facility>(this as Facility, _$identity);

  /// Serializes this Facility to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Facility&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.category, category) || other.category == category)&&(identical(other.name, name) || other.name == name)&&(identical(other.thrillLevel, thrillLevel) || other.thrillLevel == thrillLevel)&&(identical(other.heightRequirementInches, heightRequirementInches) || other.heightRequirementInches == heightRequirementInches));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,category,name,thrillLevel,heightRequirementInches);

@override
String toString() {
  return 'Facility(id: $id, type: $type, category: $category, name: $name, thrillLevel: $thrillLevel, heightRequirementInches: $heightRequirementInches)';
}


}

/// @nodoc
abstract mixin class $FacilityCopyWith<$Res>  {
  factory $FacilityCopyWith(Facility value, $Res Function(Facility) _then) = _$FacilityCopyWithImpl;
@useResult
$Res call({
 String id, String type, String category, String name, String thrillLevel, int heightRequirementInches
});




}
/// @nodoc
class _$FacilityCopyWithImpl<$Res>
    implements $FacilityCopyWith<$Res> {
  _$FacilityCopyWithImpl(this._self, this._then);

  final Facility _self;
  final $Res Function(Facility) _then;

/// Create a copy of Facility
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? category = null,Object? name = null,Object? thrillLevel = null,Object? heightRequirementInches = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,thrillLevel: null == thrillLevel ? _self.thrillLevel : thrillLevel // ignore: cast_nullable_to_non_nullable
as String,heightRequirementInches: null == heightRequirementInches ? _self.heightRequirementInches : heightRequirementInches // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Facility].
extension FacilityPatterns on Facility {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Facility value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Facility() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Facility value)  $default,){
final _that = this;
switch (_that) {
case _Facility():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Facility value)?  $default,){
final _that = this;
switch (_that) {
case _Facility() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String category,  String name,  String thrillLevel,  int heightRequirementInches)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Facility() when $default != null:
return $default(_that.id,_that.type,_that.category,_that.name,_that.thrillLevel,_that.heightRequirementInches);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String category,  String name,  String thrillLevel,  int heightRequirementInches)  $default,) {final _that = this;
switch (_that) {
case _Facility():
return $default(_that.id,_that.type,_that.category,_that.name,_that.thrillLevel,_that.heightRequirementInches);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String category,  String name,  String thrillLevel,  int heightRequirementInches)?  $default,) {final _that = this;
switch (_that) {
case _Facility() when $default != null:
return $default(_that.id,_that.type,_that.category,_that.name,_that.thrillLevel,_that.heightRequirementInches);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Facility extends Facility {
  const _Facility({required this.id, required this.type, required this.category, required this.name, required this.thrillLevel, required this.heightRequirementInches}): super._();
  factory _Facility.fromJson(Map<String, dynamic> json) => _$FacilityFromJson(json);

@override final  String id;
@override final  String type;
@override final  String category;
@override final  String name;
@override final  String thrillLevel;
@override final  int heightRequirementInches;

/// Create a copy of Facility
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FacilityCopyWith<_Facility> get copyWith => __$FacilityCopyWithImpl<_Facility>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FacilityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Facility&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.category, category) || other.category == category)&&(identical(other.name, name) || other.name == name)&&(identical(other.thrillLevel, thrillLevel) || other.thrillLevel == thrillLevel)&&(identical(other.heightRequirementInches, heightRequirementInches) || other.heightRequirementInches == heightRequirementInches));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,category,name,thrillLevel,heightRequirementInches);

@override
String toString() {
  return 'Facility(id: $id, type: $type, category: $category, name: $name, thrillLevel: $thrillLevel, heightRequirementInches: $heightRequirementInches)';
}


}

/// @nodoc
abstract mixin class _$FacilityCopyWith<$Res> implements $FacilityCopyWith<$Res> {
  factory _$FacilityCopyWith(_Facility value, $Res Function(_Facility) _then) = __$FacilityCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String category, String name, String thrillLevel, int heightRequirementInches
});




}
/// @nodoc
class __$FacilityCopyWithImpl<$Res>
    implements _$FacilityCopyWith<$Res> {
  __$FacilityCopyWithImpl(this._self, this._then);

  final _Facility _self;
  final $Res Function(_Facility) _then;

/// Create a copy of Facility
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? category = null,Object? name = null,Object? thrillLevel = null,Object? heightRequirementInches = null,}) {
  return _then(_Facility(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,thrillLevel: null == thrillLevel ? _self.thrillLevel : thrillLevel // ignore: cast_nullable_to_non_nullable
as String,heightRequirementInches: null == heightRequirementInches ? _self.heightRequirementInches : heightRequirementInches // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
