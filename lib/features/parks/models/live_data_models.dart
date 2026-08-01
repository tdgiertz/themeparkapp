import 'package:freezed_annotation/freezed_annotation.dart';

part 'live_data_models.freezed.dart';
part 'live_data_models.g.dart';

@freezed
abstract class RideWaitTime with _$RideWaitTime {
  const factory RideWaitTime({
    required String rideId,
    @Default('') String name,
    required int waitMinutes,
  }) = _RideWaitTime;

  factory RideWaitTime.fromJson(Map<String, dynamic> json) =>
      _$RideWaitTimeFromJson(json);
}

@freezed
abstract class Showtime with _$Showtime {
  const factory Showtime({
    required String showId,
    required String name,
    required String time,
  }) = _Showtime;

  factory Showtime.fromJson(Map<String, dynamic> json) =>
      _$ShowtimeFromJson(json);
}

@freezed
abstract class ParkHighlights with _$ParkHighlights {
  const factory ParkHighlights({
    @Default([]) List<RideWaitTime> shortestWaitTimes,
    @Default([]) List<Showtime> nextShowtimes,
  }) = _ParkHighlights;

  factory ParkHighlights.fromJson(Map<String, dynamic> json) =>
      _$ParkHighlightsFromJson(json);
}
