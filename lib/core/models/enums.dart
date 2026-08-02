import 'package:freezed_annotation/freezed_annotation.dart';

/// Operational status of an attraction, ride, or facility.
enum WaitTimeStatus {
  @JsonValue('Open')
  open('Open'),

  @JsonValue('Closed')
  closed('Closed'),

  @JsonValue('Down')
  down('Down'),

  @JsonValue('Refurbishment')
  refurbishment('Refurbishment'),

  @JsonValue('n/a')
  unknown('n/a');

  const WaitTimeStatus(this.jsonValue);
  final String jsonValue;

  bool get isOpen => this == WaitTimeStatus.open;
  bool get isClosed => this != WaitTimeStatus.open;

  String get displayName {
    switch (this) {
      case WaitTimeStatus.open:
        return 'Open';
      case WaitTimeStatus.closed:
        return 'Closed';
      case WaitTimeStatus.down:
        return 'Down';
      case WaitTimeStatus.refurbishment:
        return 'Under Refurbishment';
      case WaitTimeStatus.unknown:
        return 'N/A';
    }
  }

  static WaitTimeStatus fromString(String? value) {
    if (value == null) return WaitTimeStatus.unknown;
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'open':
      case 'operating':
        return WaitTimeStatus.open;
      case 'closed':
        return WaitTimeStatus.closed;
      case 'down':
      case 'temporarily closed':
      case 'temporarily closed / down':
        return WaitTimeStatus.down;
      case 'refurbishment':
      case 'under refurbishment':
        return WaitTimeStatus.refurbishment;
      default:
        return WaitTimeStatus.unknown;
    }
  }
}

/// Category of facility or attraction.
enum FacilityCategory {
  @JsonValue('Ride')
  ride('Ride'),

  @JsonValue('Show')
  show('Show'),

  @JsonValue('Restaurant')
  restaurant('Restaurant'),

  @JsonValue('Shop')
  shop('Shop'),

  @JsonValue('Entertainment')
  entertainment('Entertainment'),

  @JsonValue('Character')
  character('Character'),

  @JsonValue('PlayArea')
  playArea('PlayArea'),

  @JsonValue('Attraction')
  attraction('Attraction'),

  @JsonValue('Dining')
  dining('Dining'),

  @JsonValue('Other')
  unknown('Other');

  const FacilityCategory(this.jsonValue);
  final String jsonValue;

  bool get isRide => this == FacilityCategory.ride;
  bool get isShow => this == FacilityCategory.show || this == FacilityCategory.entertainment;
  bool get isDining => this == FacilityCategory.restaurant || this == FacilityCategory.dining;

  String get displayName {
    switch (this) {
      case FacilityCategory.ride:
        return 'Ride';
      case FacilityCategory.show:
        return 'Show';
      case FacilityCategory.restaurant:
      case FacilityCategory.dining:
        return 'Dining';
      case FacilityCategory.shop:
        return 'Shop';
      case FacilityCategory.entertainment:
        return 'Entertainment';
      case FacilityCategory.character:
        return 'Character';
      case FacilityCategory.playArea:
        return 'Play Area';
      case FacilityCategory.attraction:
        return 'Attraction';
      case FacilityCategory.unknown:
        return 'Other';
    }
  }

  static FacilityCategory fromString(String? value) {
    if (value == null) return FacilityCategory.unknown;
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'ride':
      case 'rides':
        return FacilityCategory.ride;
      case 'show':
      case 'shows':
        return FacilityCategory.show;
      case 'restaurant':
      case 'dining':
      case 'dining / restaurants':
        return FacilityCategory.restaurant;
      case 'shop':
      case 'shops':
        return FacilityCategory.shop;
      case 'entertainment':
        return FacilityCategory.entertainment;
      case 'character':
      case 'character experiences':
        return FacilityCategory.character;
      case 'playarea':
      case 'play area':
      case 'walkthroughs / play areas':
        return FacilityCategory.playArea;
      case 'attraction':
        return FacilityCategory.attraction;
      default:
        return FacilityCategory.unknown;
    }
  }
}

/// Element/Item structural type in park hierarchy.
enum ElementType {
  @JsonValue('Park')
  park('Park'),

  @JsonValue('Land')
  land('Land'),

  @JsonValue('Facility')
  facility('Facility'),

  @JsonValue('Unknown')
  unknown('Unknown');

  const ElementType(this.jsonValue);
  final String jsonValue;

  static ElementType fromString(String? value) {
    if (value == null) return ElementType.unknown;
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'park':
        return ElementType.park;
      case 'land':
        return ElementType.land;
      case 'facility':
        return ElementType.facility;
      default:
        return ElementType.unknown;
    }
  }
}

/// Thrill level rating of an attraction.
enum ThrillLevel {
  @JsonValue('Low')
  low('Low'),

  @JsonValue('Moderate')
  moderate('Moderate'),

  @JsonValue('High')
  high('High'),

  @JsonValue('Extreme')
  extreme('Extreme'),

  @JsonValue('Kid Friendly')
  kidFriendly('Kid Friendly'),

  @JsonValue('Unknown')
  unknown('Unknown');

  const ThrillLevel(this.jsonValue);
  final String jsonValue;

  String get displayName => jsonValue;

  static ThrillLevel fromString(String? value) {
    if (value == null) return ThrillLevel.unknown;
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'low':
        return ThrillLevel.low;
      case 'moderate':
        return ThrillLevel.moderate;
      case 'high':
        return ThrillLevel.high;
      case 'extreme':
        return ThrillLevel.extreme;
      case 'kid friendly':
      case 'kidfriendly':
        return ThrillLevel.kidFriendly;
      default:
        return ThrillLevel.unknown;
    }
  }
}

/// Park crowd level assessment.
enum CrowdLevel {
  @JsonValue('Low')
  low('Low'),

  @JsonValue('Moderate')
  moderate('Moderate'),

  @JsonValue('High')
  high('High'),

  @JsonValue('Very High')
  veryHigh('Very High'),

  @JsonValue('Unknown')
  unknown('Unknown');

  const CrowdLevel(this.jsonValue);
  final String jsonValue;

  String get displayName => jsonValue;

  static CrowdLevel fromString(String? value) {
    if (value == null) return CrowdLevel.unknown;
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'low':
        return CrowdLevel.low;
      case 'moderate':
        return CrowdLevel.moderate;
      case 'high':
        return CrowdLevel.high;
      case 'very high':
      case 'veryhigh':
        return CrowdLevel.veryHigh;
      default:
        return CrowdLevel.unknown;
    }
  }
}

/// Data update payload type.
enum UpdateType {
  @JsonValue('Full')
  full('Full'),

  @JsonValue('Incremental')
  incremental('Incremental'),

  @JsonValue('Unknown')
  unknown('Unknown');

  const UpdateType(this.jsonValue);
  final String jsonValue;

  static UpdateType fromString(String? value) {
    if (value == null) return UpdateType.unknown;
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'full':
        return UpdateType.full;
      case 'incremental':
      case 'delta':
        return UpdateType.incremental;
      default:
        return UpdateType.unknown;
    }
  }
}
