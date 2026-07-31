/// A facility within a park (ride, shop, etc.).
class Facility {
  Facility({
    required this.id,
    required this.type,
    required this.category,
    required this.name,
    this.thrillLevel,
    this.heightRequirementInches,
  });

  factory Facility.fromJson(Map<String, dynamic> json) => Facility(
    id: json['id'] as String,
    type: json['type'] as String,
    category: json['category'] as String,
    name: json['name'] as String,
    thrillLevel: json['thrillLevel'] as String?,
    heightRequirementInches: json['heightRequirementInches'] as int?,
  );
  final String id;
  final String type;
  final String category;
  final String name;
  final String? thrillLevel;
  final int? heightRequirementInches;
}

/// A themed land within a park, containing facilities.
class Land {
  Land({
    required this.id,
    required this.type,
    required this.name,
    required this.children,
  });

  factory Land.fromJson(Map<String, dynamic> json) => Land(
    id: json['id'] as String,
    type: json['type'] as String,
    name: json['name'] as String,
    children: (json['children'] as List? ?? [])
        .map((e) => Facility.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
  final String id;
  final String type;
  final String name;
  final List<Facility> children;
}

/// Detailed park structure including lands and facilities.
class ParkDetail {
  ParkDetail({
    required this.id,
    required this.type,
    required this.name,
    required this.children,
  });

  factory ParkDetail.fromJson(Map<String, dynamic> json) {
    final park = json['park'] as Map<String, dynamic>? ?? {};
    return ParkDetail(
      id: park['id'] as String? ?? '',
      type: park['type'] as String? ?? '',
      name: park['name'] as String? ?? '',
      children: (park['children'] as List? ?? [])
          .map((e) => Land.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
  final String id;
  final String type;
  final String name;
  final List<Land> children;
}
