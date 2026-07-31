import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:themeparkapp/features/park/park_explorer_state.dart';
import 'package:themeparkapp/models/park_detail.dart';
import 'package:themeparkapp/models/wait_time.dart';

/// Mapping of known coordinates for facilities.
class AttractionLocation {
  const AttractionLocation(this.latitude, this.longitude);

  factory AttractionLocation.fromId(String id, double centerLat, double centerLng) {
    final known = {
      // Animal Kingdom (p1)
      'a1': const AttractionLocation(28.3575, -81.5930), // Pandora
      'a2': const AttractionLocation(28.3590, -81.5880), // Conservation Station
      'a3': const AttractionLocation(28.3580, -81.5860), // Asia (Everest)
      'a4': const AttractionLocation(28.3595, -81.5900), // Gorilla Falls
      'a5': const AttractionLocation(28.3590, -81.5855), // Kali River
      'a6': const AttractionLocation(28.3610, -81.5910), // Kilimanjaro Safaris
      'a7': const AttractionLocation(28.3595, -81.5850), // Maharajah Jungle
      'a8': const AttractionLocation(28.3570, -81.5900), // Adventurers Outpost
      'a9': const AttractionLocation(28.3578, -81.5925), // Na'vi River
      'a10': const AttractionLocation(28.3555, -81.5903), // Rainforest Cafe
      'a11': const AttractionLocation(28.3595, -81.5898), // Wildlife Express
      'a12': const AttractionLocation(28.3585, -81.5890), // Zootopia

      // Magic Kingdom (p2)
      'a13': const AttractionLocation(28.4208, -81.5824), // small world
      'a14': const AttractionLocation(28.4190, -81.5794), // Astro Orbiter
      'a15': const AttractionLocation(28.4200, -81.5852), // Big Thunder
      'a16': const AttractionLocation(28.4188, -81.5796), // Buzz Lightyear
      'a17': const AttractionLocation(28.4196, -81.5812), // Cinderella Castle
      'a18': const AttractionLocation(28.4190, -81.5835), // Country Bear
      'a19': const AttractionLocation(28.4204, -81.5802), // Dumbo
      'a20': const AttractionLocation(28.4205, -81.5810), // Belle Tales
      'a21': const AttractionLocation(28.4204, -81.5838), // Haunted Mansion
      'a22': const AttractionLocation(28.4183, -81.5836), // Jungle Cruise
      'a23': const AttractionLocation(28.4198, -81.5802), // Mad Tea Party
      'a24': const AttractionLocation(28.4206, -81.5804), // Ariel Grotto
      'a25': const AttractionLocation(28.4198, -81.5810), // Princess Fairytale
      'a26': const AttractionLocation(28.4202, -81.5798), // Pete's Side Show
      'a27': const AttractionLocation(28.4202, -81.5798), // Pete's Side Show Duplicate
      'a28': const AttractionLocation(28.4178, -81.5814), // Mickey Town Square
    };

    if (known.containsKey(id)) {
      return known[id]!;
    }
    
    // Deterministic fallback based on hashcode
    final h = id.hashCode;
    final latOffset = ((h % 100) - 50) / 15000.0;
    final lngOffset = (((h >> 2) % 100) - 50) / 15000.0;
    return AttractionLocation(centerLat + latOffset, centerLng + lngOffset);
  }
  final double latitude;
  final double longitude;
}

/// Interactive Vector Map of the Park.
class ParkMapWidget extends ConsumerStatefulWidget {
  const ParkMapWidget({
    required this.parkId,
    required this.facilities,
    required this.waitTimes,
    required this.isMobile,
    required this.onFacilityTapped,
    this.selectedFacilityId,
    super.key,
  });

  final String parkId;
  final List<Facility> facilities;
  final List<WaitTime> waitTimes;
  final bool isMobile;
  final void Function(Facility) onFacilityTapped;
  final String? selectedFacilityId;

  @override
  ConsumerState<ParkMapWidget> createState() => _ParkMapWidgetState();
}

class _ParkMapWidgetState extends ConsumerState<ParkMapWidget> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late TransformationController _transformationController;
  late AnimationController _mapPanController;
  Animation<Matrix4>? _mapPanAnimation;
  String? _lastSelectedFacilityId;
  final double _paddingDeg = 0.005; // ~550m radius around center

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _mapPanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _lastSelectedFacilityId = widget.selectedFacilityId;
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _mapPanController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onMapPanAnimate() {
    _transformationController.value = _mapPanAnimation!.value;
    if (!_mapPanController.isAnimating) {
      _mapPanAnimation?.removeListener(_onMapPanAnimate);
    }
  }

  void _animateToMatrix(Matrix4 endMatrix) {
    _mapPanAnimation?.removeListener(_onMapPanAnimate);
    _mapPanAnimation = Matrix4Tween(
      begin: _transformationController.value,
      end: endMatrix,
    ).animate(CurvedAnimation(
      parent: _mapPanController,
      curve: Curves.easeInOutCubic,
    ));
    _mapPanController.addListener(_onMapPanAnimate);
    _mapPanController.forward(from: 0);
  }

  void _animateToFacility(Facility facility, Size mapSize) {
    final loc = AttractionLocation.fromId(facility.id, _centerLat, _centerLng);
    final x = (loc.longitude - _minLng) / (_maxLng - _minLng) * mapSize.width;
    final y = (_maxLat - loc.latitude) / (_maxLat - _minLat) * mapSize.height;
    final targetOffset = Offset(x, y);

    const zoom = 2.2;
    final viewportCenter = Offset(mapSize.width / 2, mapSize.height / 2);
    final endMatrix = Matrix4.identity()
      ..translate(
        viewportCenter.dx - targetOffset.dx * zoom,
        viewportCenter.dy - targetOffset.dy * zoom,
      )
      ..scale(zoom);

    _animateToMatrix(endMatrix);
  }

  double get _centerLat => widget.parkId == 'p2' ? 28.4194 : 28.3575;
  double get _centerLng => widget.parkId == 'p2' ? -81.5812 : -81.5907;

  double get _minLat => _centerLat - _paddingDeg;
  double get _maxLat => _centerLat + _paddingDeg;
  double get _minLng => _centerLng - _paddingDeg;
  double get _maxLng => _centerLng + _paddingDeg;

  List<int> _getWaitTimeTrend(String rideId, int currentWait) {
    final list = <int>[];
    final hash = rideId.hashCode;
    for (var i = 6; i > 0; i--) {
      final offset = ((hash ^ i) % 25) - 12;
      final wait = (currentWait + offset).clamp(0, 180);
      list.add(wait);
    }
    list.add(currentWait);
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final userPos = ref.watch(userLocationProvider(widget.parkId));
    final heatmapEnabled = ref.watch(heatmapEnabledProvider(widget.parkId));
    final hourOffset = ref.watch(historyHourOffsetProvider(widget.parkId));

    // Define colors for the pins based on wait time status
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Filter facilities based on active filters
    final activeFilters = ref.watch(selectedFiltersProvider(widget.parkId));
    
    // Filter logic
    final filteredFacilities = widget.facilities.where((f) {
      if (activeFilters.isEmpty) return true;
      
      final matchedWait = widget.waitTimes.where((w) => w.rideId == f.id);
      final wait = matchedWait.isEmpty ? null : matchedWait.first;
      final isClosed = wait == null || wait.status != 'Open';

      // Mobile Map automatically filters out closed attractions
      if (widget.isMobile && isClosed) {
        return false;
      }

      final isThrill = f.thrillLevel == 'High' || f.thrillLevel == 'Moderate';
      final isToddler = f.thrillLevel == 'Low' || (f.heightRequirementInches ?? 0) == 0;
      final isIndoor = f.name.toLowerCase().contains(RegExp('hall|theater|meet|princess|grotto|grizzly|buzz|space|small world|haunted|mansion|cafe|flight|bluey|zootopia|bear|show'));
      final isDining = f.name.toLowerCase().contains(RegExp('cafe|restaurant|grill|dining|eats|table|bakery|kitchen|tavern|food|pub'));

      var matches = false;
      if (activeFilters.contains('thrill') && isThrill) matches = true;
      if (activeFilters.contains('toddler') && isToddler) matches = true;
      if (activeFilters.contains('indoor') && isIndoor) matches = true;
      if (activeFilters.contains('dining') && isDining) matches = true;

      return matches;
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        final mapSize = Size(size, size);

        // Convert lat/lng to canvas position
        Offset getOffset(double lat, double lng) {
          final x = (lng - _minLng) / (_maxLng - _minLng) * mapSize.width;
          final y = (_maxLat - lat) / (_maxLat - _minLat) * mapSize.height;
          return Offset(x, y);
        }

        // Calculate heatmap values for each facility
        final heatmapData = <_HeatPoint>[];
        if (heatmapEnabled && !widget.isMobile) {
          for (final f in filteredFacilities) {
            final matchedWait = widget.waitTimes.where((w) => w.rideId == f.id);
            if (matchedWait.isNotEmpty) {
              final w = matchedWait.first;
              final currentWait = w.waitMinutes ?? 0;
              final trends = _getWaitTimeTrend(f.id, currentWait);
              final historicalWait = trends[(6 - hourOffset).clamp(0, 6)];
              
              final loc = AttractionLocation.fromId(f.id, _centerLat, _centerLng);
              final offset = getOffset(loc.latitude, loc.longitude);
              
              final cs = Theme.of(context).colorScheme;
              Color heatColor = cs.primary;
              if (historicalWait > 50) {
                heatColor = cs.error;
              } else if (historicalWait > 20) {
                heatColor = cs.tertiary;
              }

              heatmapData.add(_HeatPoint(
                offset: offset,
                color: heatColor,
                intensity: historicalWait.toDouble(),
              ));
            }
          }
        }

        final userOffset = getOffset(userPos.latitude, userPos.longitude);
        // Calculate 5-minute walking radius (approx. 400m in degrees)
        const radiusDeg = 0.0036; 
        final radiusPx = (radiusDeg / (_maxLng - _minLng)) * mapSize.width;

        // Check if selected facility changed and trigger animation
        if (widget.selectedFacilityId != _lastSelectedFacilityId) {
          final oldSelected = _lastSelectedFacilityId;
          _lastSelectedFacilityId = widget.selectedFacilityId;
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (widget.selectedFacilityId != null) {
              final target = widget.facilities.firstWhere(
                (f) => f.id == widget.selectedFacilityId,
                orElse: () => widget.facilities.first,
              );
              _animateToFacility(target, mapSize);
            } else if (oldSelected != null) {
              _animateToMatrix(Matrix4.identity());
            }
          });
        }

        return InteractiveViewer(
          transformationController: _transformationController,
          maxScale: 4,
          boundaryMargin: const EdgeInsets.all(100),
          child: Center(
            child: SizedBox(
              width: mapSize.width,
              height: mapSize.height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. Vector Map Background & Path & Heatmap Overlay
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: mapSize,
                        painter: _MapBackgroundPainter(
                          theme: theme,
                          isDark: isDark,
                          parkId: widget.parkId,
                          userOffset: userOffset,
                          walkingRadiusPx: radiusPx,
                          pulseValue: _pulseController.value,
                          heatmapPoints: heatmapData,
                          showWalkingRadius: widget.isMobile,
                          centerOffset: getOffset(_centerLat, _centerLng),
                        ),
                      );
                    },
                  ),

                  // 2. Interactive clustered pins with minimum 44x44 touch targets and high outdoor contrast
                  ..._buildClusteredPins(
                    facilities: filteredFacilities,
                    mapSize: mapSize,
                    getOffset: getOffset,
                    theme: theme,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildClusteredPins({
    required List<Facility> facilities,
    required Size mapSize,
    required Offset Function(double lat, double lng) getOffset,
    required ThemeData theme,
    required bool isDark,
  }) {
    // Current zoom scale from matrix
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final clusterDistanceThreshold = 40.0 / math.max(1.0, currentScale * 0.7);

    // Data structure for pin position
    final items = facilities.map((f) {
      final loc = AttractionLocation.fromId(f.id, _centerLat, _centerLng);
      final offset = getOffset(loc.latitude, loc.longitude);
      return _PinItem(facility: f, offset: offset);
    }).toList();

    // Distance-based simple clustering
    final clusters = <List<_PinItem>>[];
    final visited = <bool>[...List.filled(items.length, false)];

    for (var i = 0; i < items.length; i++) {
      if (visited[i]) continue;
      visited[i] = true;
      final cluster = [_PinItem(facility: items[i].facility, offset: items[i].offset)];

      for (var j = i + 1; j < items.length; j++) {
        if (visited[j]) continue;
        final dist = (items[i].offset - items[j].offset).distance;
        if (dist < clusterDistanceThreshold) {
          visited[j] = true;
          cluster.add(items[j]);
        }
      }
      clusters.add(cluster);
    }

    final widgets = <Widget>[];

    for (final cluster in clusters) {
      if (cluster.length == 1) {
        final f = cluster.first.facility;
        final offset = cluster.first.offset;
        final matchedWait = widget.waitTimes.where((w) => w.rideId == f.id);
        final wait = matchedWait.isEmpty ? null : matchedWait.first;

        final isClosed = wait == null || wait.status != 'Open';
        final waitMinutes = wait?.waitMinutes ?? 0;

        final cs = theme.colorScheme;
        var pinColor = cs.primaryContainer;
        var pinFg = cs.onPrimaryContainer;
        if (isClosed) {
          pinColor = cs.surfaceContainerHigh;
          pinFg = cs.onSurfaceVariant;
        } else if (waitMinutes > 50) {
          pinColor = cs.errorContainer;
          pinFg = cs.onErrorContainer;
        } else if (waitMinutes > 20) {
          pinColor = cs.tertiaryContainer;
          pinFg = cs.onTertiaryContainer;
        }

        final isSelected = widget.selectedFacilityId == f.id;

        widgets.add(
          Positioned(
            left: offset.dx - 22,
            top: offset.dy - 22,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.onFacilityTapped(f),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: Tooltip(
                  message: '${f.name} - ${isClosed ? 'Closed' : '$waitMinutes min'}',
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isSelected ? 40 : 34,
                    height: isSelected ? 40 : 34,
                    decoration: BoxDecoration(
                      color: pinColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? cs.primary : cs.surface,
                        width: isSelected ? 3 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cs.shadow,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: isClosed
                        ? Icon(Icons.block, size: 14, color: pinFg)
                        : Text(
                            '$waitMinutes',
                            style: TextStyle(
                              color: pinFg,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        // Multi-facility cluster pin
        final cs = theme.colorScheme;
        final avgX = cluster.map((c) => c.offset.dx).reduce((a, b) => a + b) / cluster.length;
        final avgY = cluster.map((c) => c.offset.dy).reduce((a, b) => a + b) / cluster.length;
        final centerOffset = Offset(avgX, avgY);
        final containsSelected = cluster.any((c) => c.facility.id == widget.selectedFacilityId);

        widgets.add(
          Positioned(
            left: centerOffset.dx - 22,
            top: centerOffset.dy - 22,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                // If cluster tapped, zoom in or select first facility in cluster
                widget.onFacilityTapped(cluster.first.facility);
                _animateToFacility(cluster.first.facility, mapSize);
              },
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: Tooltip(
                  message: '${cluster.length} attractions near here',
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: containsSelected ? 42 : 38,
                    height: containsSelected ? 42 : 38,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: containsSelected ? cs.tertiary : cs.surface,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cs.shadow,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.place, size: 12, color: cs.onPrimary),
                        Text(
                          '${cluster.length}',
                          style: TextStyle(
                            color: cs.onPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }
}

class _HeatPoint {
  _HeatPoint({
    required this.offset,
    required this.color,
    required this.intensity,
  });
  final Offset offset;
  final Color color;
  final double intensity;
}

class _MapBackgroundPainter extends CustomPainter {
  final ThemeData theme;
  _MapBackgroundPainter({
    required this.theme,
    required this.isDark,
    required this.parkId,
    required this.userOffset,
    required this.walkingRadiusPx,
    required this.pulseValue,
    required this.heatmapPoints,
    required this.showWalkingRadius,
    required this.centerOffset,
  });

  final bool isDark;
  final String parkId;
  final Offset userOffset;
  final double walkingRadiusPx;
  final double pulseValue;
  final List<_HeatPoint> heatmapPoints;
  final bool showWalkingRadius;
  final Offset centerOffset;

  @override
  void paint(Canvas canvas, Size size) {
    // A. Draw green grass background
    final bgPaint = Paint()
      ..color = theme.colorScheme.surface;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // B. Draw park regions / lands
    final regionPaint = Paint()..style = PaintingStyle.fill;
    
    if (parkId == 'p1') {
      // Pandora - Translucent Purple
      regionPaint.color = Colors.purple.withValues(alpha: isDark ? 0.12 : 0.08);
      canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.65), size.width * 0.2, regionPaint);

      // Asia - Translucent Orange/Yellow
      regionPaint.color = Colors.orange.withValues(alpha: isDark ? 0.12 : 0.08);
      canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.5), size.width * 0.22, regionPaint);

      // Africa - Translucent Yellow/Gold
      regionPaint.color = Colors.yellow.withValues(alpha: isDark ? 0.12 : 0.08);
      canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.25), size.width * 0.24, regionPaint);

      // Discovery Island - Translucent Green
      regionPaint.color = Colors.green.withValues(alpha: isDark ? 0.15 : 0.1);
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.55), size.width * 0.15, regionPaint);
    } else {
      // Magic Kingdom Lands
      // Fantasyland
      regionPaint.color = Colors.blue.withValues(alpha: isDark ? 0.12 : 0.08);
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.3), size.width * 0.25, regionPaint);
      
      // Tomorrowland
      regionPaint.color = Colors.indigo.withValues(alpha: isDark ? 0.12 : 0.08);
      canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.6), size.width * 0.2, regionPaint);

      // Adventureland / Frontierland
      regionPaint.color = Colors.brown.withValues(alpha: isDark ? 0.12 : 0.08);
      canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.55), size.width * 0.22, regionPaint);
    }

    // C. Draw serpentine blue water canal/river in the park
    final waterPaint = Paint()
      ..color = theme.colorScheme.surfaceContainerHighest
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final waterPath = parkId == 'p1'
        ? (Path()
          ..moveTo(0, size.height * 0.5)
          ..quadraticBezierTo(size.width * 0.3, size.height * 0.4, size.width * 0.5, size.height * 0.55)
          ..quadraticBezierTo(size.width * 0.7, size.height * 0.7, size.width, size.height * 0.6))
        : (Path()
          ..addOval(Rect.fromCircle(center: Offset(size.width * 0.5, size.height * 0.55), radius: size.width * 0.12)));
    canvas.drawPath(waterPath, waterPaint);

    // D. Draw walkways/paths
    final pathPaint = Paint()
      ..color = theme.colorScheme.surfaceContainerHigh
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final walkPath = Path()
      ..addOval(Rect.fromCircle(center: Offset(size.width * 0.5, size.height * 0.55), radius: size.width * 0.18))
      ..moveTo(size.width * 0.5, size.height * 0.37)
      ..lineTo(size.width * 0.5, size.height * 0.1)
      ..moveTo(size.width * 0.32, size.height * 0.55)
      ..lineTo(size.width * 0.1, size.height * 0.6)
      ..moveTo(size.width * 0.68, size.height * 0.55)
      ..lineTo(size.width * 0.9, size.height * 0.6);
    canvas.drawPath(walkPath, pathPaint);

    // E. Draw Heatmap overlay (translucent radial gradients)
    for (final hp in heatmapPoints) {
      final radius = 25.0 + (hp.intensity * 0.35).clamp(0.0, 50.0);
      final heatPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            hp.color.withValues(alpha: 0.45),
            hp.color.withValues(alpha: 0.2),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: hp.offset, radius: radius))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(hp.offset, radius, heatPaint);
    }

    // F. Draw 5-Minute Walking Radius circle (Mobile)
    if (showWalkingRadius) {
      final primaryColor = theme.colorScheme.primary;
      // Draw 5-min radius translucent circle
      final walkRadiusPaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(userOffset, walkingRadiusPx, walkRadiusPaint);

      // Draw walking radius dotted stroke border
      final walkBorderPaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.35)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(userOffset, walkingRadiusPx, walkBorderPaint);

      // Pulse circle
      final pulseRadius = walkingRadiusPx * (0.8 + 0.2 * pulseValue);
      final pulsePaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.04 * (1.0 - pulseValue))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(userOffset, pulseRadius, pulsePaint);

      // Draw active GPS marker dot
      final gpsMarkerPaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(userOffset, 6, gpsMarkerPaint);

      // Pulse dot border
      final gpsBorderPaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.5 * (1.0 - pulseValue))
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(userOffset, 6.0 + 8.0 * pulseValue, gpsBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MapBackgroundPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.parkId != parkId ||
        oldDelegate.userOffset != userOffset ||
        oldDelegate.walkingRadiusPx != walkingRadiusPx ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.heatmapPoints != heatmapPoints ||
        oldDelegate.showWalkingRadius != showWalkingRadius ||
        oldDelegate.centerOffset != centerOffset;
  }
}

class _PinItem {
  _PinItem({
    required this.facility,
    required this.offset,
  });
  final Facility facility;
  final Offset offset;
}

