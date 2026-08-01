// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_data_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RideWaitTime _$RideWaitTimeFromJson(Map<String, dynamic> json) =>
    _RideWaitTime(
      rideId: json['rideId'] as String,
      waitMinutes: (json['waitMinutes'] as num).toInt(),
      name: json['name'] as String? ?? '',
    );

Map<String, dynamic> _$RideWaitTimeToJson(_RideWaitTime instance) =>
    <String, dynamic>{
      'rideId': instance.rideId,
      'waitMinutes': instance.waitMinutes,
      'name': instance.name,
    };

_Showtime _$ShowtimeFromJson(Map<String, dynamic> json) => _Showtime(
  showId: json['showId'] as String,
  name: json['name'] as String,
  time: json['time'] as String,
);

Map<String, dynamic> _$ShowtimeToJson(_Showtime instance) => <String, dynamic>{
  'showId': instance.showId,
  'name': instance.name,
  'time': instance.time,
};

_ParkHighlights _$ParkHighlightsFromJson(Map<String, dynamic> json) =>
    _ParkHighlights(
      shortestWaitTimes:
          (json['shortestWaitTimes'] as List<dynamic>?)
              ?.map((e) => RideWaitTime.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      nextShowtimes:
          (json['nextShowtimes'] as List<dynamic>?)
              ?.map((e) => Showtime.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ParkHighlightsToJson(_ParkHighlights instance) =>
    <String, dynamic>{
      'shortestWaitTimes': instance.shortestWaitTimes,
      'nextShowtimes': instance.nextShowtimes,
    };
