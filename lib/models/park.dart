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
    type: json['type'] as String,
    name: json['name'] as String,
    operatingHours: (json['operatingHours'] as Map?)?.cast<String, String>(),
    crowdLevel: json['crowdLevel'] as String?,
    highlights: json['highlights'] as Map<String, dynamic>?,
  );
  final String id;
  final String type;
  final String name;
  final Map<String, String>? operatingHours;
  final String? crowdLevel;
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
