import 'package:freezed_annotation/freezed_annotation.dart';

part 'park_models.freezed.dart';
part 'park_models.g.dart';

@freezed
abstract class Park with _$Park {
  const factory Park({
    required String id,
    required String type,
    required String name,
    required OperatingHours operatingHours,
    required String crowdLevel,
    @Default([]) List<ParkChild> children,
  }) = _Park;

  factory Park.fromJson(Map<String, dynamic> json) => _$ParkFromJson(json);
}

@freezed
abstract class OperatingHours with _$OperatingHours {
  const factory OperatingHours({required String open, required String close}) =
      _OperatingHours;

  factory OperatingHours.fromJson(Map<String, dynamic> json) =>
      _$OperatingHoursFromJson(json);
}

@freezed
abstract class ParkChild with _$ParkChild {
  const factory ParkChild({
    required String id,
    required String type,
    required String name,
    // We assume children of a Land are Facilities
    @Default([]) List<Facility> children,
  }) = _ParkChild;

  factory ParkChild.fromJson(Map<String, dynamic> json) =>
      _$ParkChildFromJson(json);
}

@freezed
abstract class Facility with _$Facility {
  const factory Facility({
    required String id,
    required String type,
    required String category,
    required String name,
    required String thrillLevel,
    required int heightRequirementInches,
  }) = _Facility;

  factory Facility.fromJson(Map<String, dynamic> json) =>
      _$FacilityFromJson(json);
}
