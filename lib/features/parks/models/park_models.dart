import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:themeparkapp/core/models/enums.dart';

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
  const Park._();

  factory Park.fromJson(Map<String, dynamic> json) => _$ParkFromJson(json);

  ElementType get typeEnum => ElementType.fromString(type);
  CrowdLevel get crowdLevelEnum => CrowdLevel.fromString(crowdLevel);
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
  const ParkChild._();

  factory ParkChild.fromJson(Map<String, dynamic> json) =>
      _$ParkChildFromJson(json);

  ElementType get typeEnum => ElementType.fromString(type);
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
  const Facility._();

  factory Facility.fromJson(Map<String, dynamic> json) =>
      _$FacilityFromJson(json);

  FacilityCategory get categoryEnum => FacilityCategory.fromString(category);
  ThrillLevel get thrillLevelEnum => ThrillLevel.fromString(thrillLevel);
  ElementType get typeEnum => ElementType.fromString(type);
}
