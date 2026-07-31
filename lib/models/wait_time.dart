/// Wait time information for a single ride.
class WaitTime {
  WaitTime({
    required this.rideId,
    required this.updatedAt,
    required this.status,
    this.waitMinutes,
    this.singleRider = false,
    this.fastLane = false,
    this.sourceId,
  });

  factory WaitTime.fromJson(Map<String, dynamic> json) => WaitTime(
    rideId: json['rideId'] as String,
    updatedAt: json['updatedAt'] as String,
    status: json['status'] as String,
    waitMinutes: json['waitMinutes'] as int?,
    singleRider: json['singleRider'] as bool? ?? false,
    fastLane: json['fastLane'] as bool? ?? false,
    sourceId: json['sourceId'] as String?,
  );
  final String rideId;
  final String updatedAt;
  final String status;
  final int? waitMinutes;
  final bool singleRider;
  final bool fastLane;
  final String? sourceId;
}

/// Wrapper for wait times responses.
class WaitTimesResponse {
  WaitTimesResponse({required this.waitTimes, this.meta});

  factory WaitTimesResponse.fromJson(Map<String, dynamic> json) =>
      WaitTimesResponse(
        meta: json['meta'] as Map<String, dynamic>?,
        waitTimes: (json['waitTimes'] as List? ?? [])
            .map((e) => WaitTime.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
  final Map<String, dynamic>? meta;
  final List<WaitTime> waitTimes;
}
