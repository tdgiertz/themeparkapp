// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file

part of 'park_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Park _$ParkFromJson(Map<String, dynamic> json) => _Park(
  id: json['id'] as String,
  type: json['type'] as String,
  name: json['name'] as String,
  operatingHours: OperatingHours.fromJson(
    json['operatingHours'] as Map<String, dynamic>,
  ),
  crowdLevel: json['crowdLevel'] as String,
  children:
      (json['children'] as List<dynamic>?)
          ?.map((e) => ParkChild.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ParkToJson(_Park instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'name': instance.name,
  'operatingHours': instance.operatingHours,
  'crowdLevel': instance.crowdLevel,
  'children': instance.children,
};

_OperatingHours _$OperatingHoursFromJson(Map<String, dynamic> json) =>
    _OperatingHours(
      open: json['open'] as String,
      close: json['close'] as String,
    );

Map<String, dynamic> _$OperatingHoursToJson(_OperatingHours instance) =>
    <String, dynamic>{'open': instance.open, 'close': instance.close};

_ParkChild _$ParkChildFromJson(Map<String, dynamic> json) => _ParkChild(
  id: json['id'] as String,
  type: json['type'] as String,
  name: json['name'] as String,
  children:
      (json['children'] as List<dynamic>?)
          ?.map((e) => Facility.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ParkChildToJson(_ParkChild instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'name': instance.name,
      'children': instance.children,
    };

_Facility _$FacilityFromJson(Map<String, dynamic> json) => _Facility(
  id: json['id'] as String,
  type: json['type'] as String,
  category: json['category'] as String,
  name: json['name'] as String,
  thrillLevel: json['thrillLevel'] as String,
  heightRequirementInches: (json['heightRequirementInches'] as num).toInt(),
);

Map<String, dynamic> _$FacilityToJson(_Facility instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'category': instance.category,
  'name': instance.name,
  'thrillLevel': instance.thrillLevel,
  'heightRequirementInches': instance.heightRequirementInches,
};
