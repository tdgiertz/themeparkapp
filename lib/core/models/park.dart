import 'package:themeparkapp/core/models/enums.dart';
export 'package:themeparkapp/core/models/enums.dart';

/// Represents a park summary returned by the parks API.
class Park {
  Park({
    required this.id,
    required this.type,
    required this.name,
    this.operatingHours,
    this.crowdLevel,
    this.highlights,
  });

  factory Park.fromJson(Map<String, dynamic> json) => Park(
    id: json['id'] as String,
    type: json['type'] is ElementType
        ? json['type'] as ElementType
        : ElementType.fromString(json['type'] as String?),
    name: json['name'] as String,
    operatingHours: (json['operatingHours'] as Map?)?.cast<String, String>(),
    crowdLevel: json['crowdLevel'] is CrowdLevel
        ? json['crowdLevel'] as CrowdLevel
        : (json['crowdLevel'] != null
              ? CrowdLevel.fromString(json['crowdLevel'] as String?)
              : null),
    highlights: json['highlights'] as Map<String, dynamic>?,
  );
  final String id;
  final ElementType type;
  final String name;
  final Map<String, String>? operatingHours;
  final CrowdLevel? crowdLevel;
  final Map<String, dynamic>? highlights;
}

/// Response wrapper containing a list of parks.
class ParksResponse {
  ParksResponse({required this.parks});
  factory ParksResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final list = (data['parks'] as List?) ?? [];
    return ParksResponse(
      parks: list.map((e) => Park.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
  final List<Park> parks;
}
