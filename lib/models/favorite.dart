/// Represents a user's favorite ride entry.
class FavoriteRide {
  FavoriteRide({
    required this.rideId,
    required this.name,
    required this.parkId,
    required this.parkName,
    this.currentWait,
  });

  factory FavoriteRide.fromJson(Map<String, dynamic> json) => FavoriteRide(
    rideId: json['rideId'] as String,
    name: json['name'] as String,
    parkId: json['parkId'] as String,
    parkName: json['parkName'] as String,
    currentWait: json['currentWait'] as Map<String, dynamic>?,
  );
  final String rideId;
  final String name;
  final String parkId;
  final String parkName;
  final Map<String, dynamic>? currentWait;
}

/// Response wrapper for user favorites.
class FavoritesResponse {
  FavoritesResponse({
    required this.userId,
    required this.lastUpdated,
    required this.favoriteRides,
  });

  factory FavoritesResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['favoriteRides'] as List?) ?? [];
    return FavoritesResponse(
      userId: json['userId'] as String? ?? '',
      lastUpdated: json['lastUpdated'] as String? ?? '',
      favoriteRides: list
          .map((e) => FavoriteRide.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
  final String userId;
  final String lastUpdated;
  final List<FavoriteRide> favoriteRides;
}
