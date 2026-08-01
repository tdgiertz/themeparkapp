// ignore_for_file: prefer_int_literals

import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:themeparkapp/core/logging/logger.dart';
import 'package:themeparkapp/core/models/park_detail.dart';
import 'package:themeparkapp/core/models/wait_time.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/features/park/facility_detail_page.dart';
import 'package:themeparkapp/features/park/park_explorer_state.dart';
import 'package:themeparkapp/features/park/widgets/area_chart.dart';
import 'package:themeparkapp/features/park/widgets/facility_detail_sheet.dart';
import 'package:themeparkapp/features/park/widgets/park_map.dart';
import 'package:themeparkapp/features/park/widgets/pulse_dot.dart';
import 'package:themeparkapp/features/park/widgets/sparkline_chart.dart';
import 'package:themeparkapp/l10n/app_localizations.dart';

enum _MobileViewMode { split, fullMap, fullList }

/// Park detail explorer page showing lands, facilities, list, and interactive map.
class ParkPage extends ConsumerStatefulWidget {
  const ParkPage({required this.parkId, required this.parkName, super.key});
  final String parkId;
  final String parkName;

  @override
  ConsumerState<ParkPage> createState() => _ParkPageState();
}

class _ParkPageState extends ConsumerState<ParkPage> {
  Timer? _autoRefreshTimer;
  final bool _autoRefreshEnabled = true;
  static const _refreshInterval = Duration(seconds: 30);

  // Responsive Layout Mode State
  _MobileViewMode _mobileViewMode = _MobileViewMode.split;
  bool _landscapePanelCollapsed = false;

  // Single-open Inline Accordion State
  String? _expandedFacilityId;
  final Map<String, GlobalKey> _tileKeys = {};

  // Track selected attraction for map highlighting
  String? _selectedFacilityId;

  // Virtual Queue State per attraction
  final Set<String> _joiningVirtualQueues = {};
  final Set<String> _joinedVirtualQueues = {};

  // Split view ratio for Tablet (600px - 1024px)
  double _splitRatio = 0.38;

  // Desktop Local Filter States
  final Set<String> _desktopActiveTypes = {};
  final Set<String> _desktopActiveWaitTimes = {}; // '15', '30', '60'
  final Set<String> _desktopActiveLands = {};

  // Sorting States
  String _mobileSort = 'proximity'; // 'proximity', 'waitTime', 'recency'
  String _desktopSort =
      'alphabetical'; // 'alphabetical', 'historicalAverage', 'rating'

  double get _centerLat => widget.parkId == 'p2' ? 28.4194 : 28.3575;
  double get _centerLng => widget.parkId == 'p2' ? -81.5812 : -81.5907;

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295; // Pi/180
    final a =
        0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a)); // 2 * R; R = 6371 km
  }

  @override
  void initState() {
    super.initState();
    if (_autoRefreshEnabled) {
      _startAutoRefresh();
    }
  }

  void _startAutoRefresh() {
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) return;
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(_refreshInterval, (_) {
      try {
        ref.read(waitTimesProvider(widget.parkId).notifier).refresh();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await ref.read(waitTimesProvider(widget.parkId).notifier).refresh();
  }

  void _toggleAccordionTile(String facilityId) {
    setState(() {
      if (_expandedFacilityId == facilityId) {
        _expandedFacilityId = null;
      } else {
        _expandedFacilityId = facilityId;
        _selectedFacilityId = facilityId;
      }
    });

    // Auto-scroll correction: if expanded content flows below visible viewport, scroll up
    if (_expandedFacilityId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final key = _tileKeys[facilityId];
        if (key?.currentContext != null) {
          Scrollable.ensureVisible(
            key!.currentContext!,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            alignment: 0.1,
          );
        }
      });
    }
  }

  void _joinVirtualQueue(String facilityId, String facilityName) {
    if (_joinedVirtualQueues.contains(facilityId) ||
        _joiningVirtualQueues.contains(facilityId)) {
      return;
    }
    setState(() {
      _joiningVirtualQueues.add(facilityId);
    });
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _joiningVirtualQueues.remove(facilityId);
          _joinedVirtualQueues.add(facilityId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Joined Virtual Queue for $facilityName!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    });
  }

  List<_ListFacilityItem> _getFilteredItems(
    ParkDetail detail,
    WaitTimesResponse waits,
  ) {
    final activeFilters = ref.watch(selectedFiltersProvider(widget.parkId));
    final items = <_ListFacilityItem>[];
    for (final land in detail.children) {
      for (final f in land.children) {
        final matchedWait = waits.waitTimes.where((w) => w.rideId == f.id);
        final wait = matchedWait.isEmpty ? null : matchedWait.first;

        final isThrill = f.thrillLevel == 'High' || f.thrillLevel == 'Moderate';
        final isToddler =
            f.thrillLevel == 'Low' || (f.heightRequirementInches ?? 0) == 0;
        final isIndoor = f.name.toLowerCase().contains(
          RegExp(
            'hall|theater|meet|princess|grotto|grizzly|buzz|space|small world|haunted|mansion|cafe|flight|bluey|zootopia|bear|show',
          ),
        );
        final isDining = f.name.toLowerCase().contains(
          RegExp(
            'cafe|restaurant|grill|dining|eats|table|bakery|kitchen|tavern|food|pub',
          ),
        );

        var matches = true;
        if (activeFilters.isNotEmpty) {
          matches = false;
          if (activeFilters.contains('thrill') && isThrill) matches = true;
          if (activeFilters.contains('toddler') && isToddler) matches = true;
          if (activeFilters.contains('indoor') && isIndoor) matches = true;
          if (activeFilters.contains('dining') && isDining) matches = true;
        }

        if (matches) {
          items.add(
            _ListFacilityItem(facility: f, wait: wait, landName: land.name),
          );
        }
      }
    }

    final userPos = ref.read(userLocationProvider(widget.parkId));
    if (_mobileSort == 'proximity') {
      items.sort((a, b) {
        final locA = AttractionLocation.fromId(
          a.facility.id,
          _centerLat,
          _centerLng,
        );
        final locB = AttractionLocation.fromId(
          b.facility.id,
          _centerLat,
          _centerLng,
        );
        final distA = _calculateDistance(
          userPos.latitude,
          userPos.longitude,
          locA.latitude,
          locA.longitude,
        );
        final distB = _calculateDistance(
          userPos.latitude,
          userPos.longitude,
          locB.latitude,
          locB.longitude,
        );
        return distA.compareTo(distB);
      });
    } else if (_mobileSort == 'waitTime') {
      items.sort((a, b) {
        final isClosedA = a.wait == null || a.wait!.status != 'Open';
        final isClosedB = b.wait == null || b.wait!.status != 'Open';
        final waitA = isClosedA ? 9999 : (a.wait!.waitMinutes ?? 0);
        final waitB = isClosedB ? 9999 : (b.wait!.waitMinutes ?? 0);
        if (waitA == waitB) {
          final locA = AttractionLocation.fromId(
            a.facility.id,
            _centerLat,
            _centerLng,
          );
          final locB = AttractionLocation.fromId(
            b.facility.id,
            _centerLat,
            _centerLng,
          );
          final distA = _calculateDistance(
            userPos.latitude,
            userPos.longitude,
            locA.latitude,
            locA.longitude,
          );
          final distB = _calculateDistance(
            userPos.latitude,
            userPos.longitude,
            locB.latitude,
            locB.longitude,
          );
          return distA.compareTo(distB);
        }
        return waitA.compareTo(waitB);
      });
    } else if (_mobileSort == 'recency') {
      items.sort((a, b) {
        final timeA =
            DateTime.tryParse(a.wait?.updatedAt ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final timeB =
            DateTime.tryParse(b.wait?.updatedAt ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return timeB.compareTo(timeA); // descending
      });
    }

    return items;
  }

  List<_ListFacilityItem> _getDesktopFilteredItems(
    ParkDetail detail,
    WaitTimesResponse waits,
  ) {
    final items = <_ListFacilityItem>[];
    for (final land in detail.children) {
      for (final f in land.children) {
        final matchedWait = waits.waitTimes.where((w) => w.rideId == f.id);
        final wait = matchedWait.isEmpty ? null : matchedWait.first;

        final isThrill = f.thrillLevel == 'High' || f.thrillLevel == 'Moderate';
        final isToddler =
            f.thrillLevel == 'Low' || (f.heightRequirementInches ?? 0) == 0;
        final isIndoor = f.name.toLowerCase().contains(
          RegExp(
            'hall|theater|meet|princess|grotto|grizzly|buzz|space|small world|haunted|mansion|cafe|flight|bluey|zootopia|bear|show',
          ),
        );
        final isDining = f.name.toLowerCase().contains(
          RegExp(
            'cafe|restaurant|grill|dining|eats|table|bakery|kitchen|tavern|food|pub',
          ),
        );

        // 1. Check type filters
        if (_desktopActiveTypes.isNotEmpty) {
          var matchesType = false;
          if (_desktopActiveTypes.contains('thrill') && isThrill) {
            matchesType = true;
          }
          if (_desktopActiveTypes.contains('toddler') && isToddler) {
            matchesType = true;
          }
          if (_desktopActiveTypes.contains('indoor') && isIndoor) {
            matchesType = true;
          }
          if (_desktopActiveTypes.contains('dining') && isDining) {
            matchesType = true;
          }
          if (!matchesType) continue;
        }

        // 2. Check wait time filters
        if (_desktopActiveWaitTimes.isNotEmpty) {
          final waitMinutes = wait?.waitMinutes ?? 0;
          final isClosed = wait == null || wait.status != 'Open';
          if (isClosed) continue;

          var matchesWait = false;
          if (_desktopActiveWaitTimes.contains('15') && waitMinutes <= 15) {
            matchesWait = true;
          }
          if (_desktopActiveWaitTimes.contains('30') && waitMinutes <= 30) {
            matchesWait = true;
          }
          if (_desktopActiveWaitTimes.contains('60') && waitMinutes <= 60) {
            matchesWait = true;
          }
          if (!matchesWait) continue;
        }

        // 3. Check land filters
        if (_desktopActiveLands.isNotEmpty) {
          if (!_desktopActiveLands.contains(land.id)) continue;
        }

        items.add(
          _ListFacilityItem(facility: f, wait: wait, landName: land.name),
        );
      }
    }

    if (_desktopSort == 'alphabetical') {
      items.sort((a, b) => a.facility.name.compareTo(b.facility.name));
    } else if (_desktopSort == 'historicalAverage') {
      items.sort((a, b) {
        final histA = (a.facility.id.hashCode % 45) + 15;
        final histB = (b.facility.id.hashCode % 45) + 15;
        return histA.compareTo(histB);
      });
    } else if (_desktopSort == 'rating') {
      items.sort((a, b) {
        final ratingA = 4.0 + ((a.facility.id.hashCode % 10) / 10.0) * 0.9;
        final ratingB = 4.0 + ((b.facility.id.hashCode % 10) / 10.0) * 0.9;
        return ratingB.compareTo(ratingA); // descending
      });
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(parkDetailProvider(widget.parkId));
    final waitsAsync = ref.watch(waitTimesProvider(widget.parkId));
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(widget.parkName)),
      body: detailAsync.when(
        data: (ParkDetail detail) => waitsAsync.when(
          data: (WaitTimesResponse waits) {
            return ScreenTypeLayout.builder(
              breakpoints: const ScreenBreakpoints(
                desktop: 1001,
                tablet: 600,
                watch: 300,
              ),
              mobile: (context) => _buildMobileLayout(detail, waits, loc),
              tablet: (context) => _buildTabletLayout(detail, waits, loc),
              desktop: (context) => _buildDesktopLayout(detail, waits, loc),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) {
            talker.handle(err, st);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error loading waits: $err'),
                    behavior: SnackBarBehavior.floating,
                    action: SnackBarAction(
                      label: 'RETRY',
                      onPressed: () {
                        ref.invalidate(waitTimesProvider(widget.parkId));
                      },
                    ),
                  ),
                );
              }
            });
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      ref.invalidate(waitTimesProvider(widget.parkId)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry loading wait times'),
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) {
          talker.handle(err, st);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error loading park: $err'),
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'RETRY',
                    onPressed: () {
                      ref.invalidate(parkDetailProvider(widget.parkId));
                    },
                  ),
                ),
              );
            }
          });
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: OutlinedButton.icon(
                onPressed: () =>
                    ref.invalidate(parkDetailProvider(widget.parkId)),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry loading park details'),
              ),
            ),
          );
        },
      ),
    );
  }


  // --- MOBILE PORTRAIT LAYOUT ---
  Widget _buildMobileLayout(
    ParkDetail detail,
    WaitTimesResponse waits,
    AppLocalizations? loc,
  ) {
    final items = _getFilteredItems(detail, waits);
    final filteredFacilities = items.map((e) => e.facility).toList();
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final totalHeight = constraints.maxHeight;

              var mapHeight = totalHeight * 0.35;
              if (_mobileViewMode == _MobileViewMode.fullMap) {
                mapHeight = totalHeight;
              } else if (_mobileViewMode == _MobileViewMode.fullList) {
                mapHeight = 0;
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _buildFilterChips(
                      horizontal: true,
                      loc: loc,
                      height: 40,
                    ),
                  ),

                  // Top Map Section
                  if (_mobileViewMode == _MobileViewMode.fullMap)
                    Expanded(
                      child: _buildMapSection(
                        filteredFacilities,
                        waits,
                        isMobile: true,
                      ),
                    )
                  else if (mapHeight > 0)
                    SizedBox(
                      height: mapHeight,
                      width: double.infinity,
                      child: _buildMapSection(
                        filteredFacilities,
                        waits,
                        isMobile: true,
                      ),
                    ),

                  // Mode Toggle Handle Bar & List Section
                  if (_mobileViewMode == _MobileViewMode.fullMap)
                    Container(
                      color: theme.colorScheme.surface,
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildModeSegmentButton(
                                label: 'Full Map',
                                icon: Icons.map,
                                isSelected: true,
                                onTap: () => setState(
                                  () =>
                                      _mobileViewMode = _MobileViewMode.fullMap,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildModeSegmentButton(
                                label: 'Split',
                                icon: Icons.vertical_split,
                                isSelected: false,
                                onTap: () => setState(
                                  () => _mobileViewMode = _MobileViewMode.split,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildModeSegmentButton(
                                label: 'Full List',
                                icon: Icons.view_list,
                                isSelected: false,
                                onTap: () => setState(
                                  () => _mobileViewMode =
                                      _MobileViewMode.fullList,
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            right: 12,
                            child: _buildMobileSortIconButton(),
                          ),
                        ],
                      ),
                    )
                  else
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(
                            alpha: 0.95,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          border: Border(
                            top: BorderSide(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.4,
                              ),
                              width: 1.5,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.15,
                              ),
                              blurRadius: 16,
                              spreadRadius: 1,
                              offset: const Offset(0, -4),
                            ),
                            BoxShadow(
                              color: theme.colorScheme.shadow.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Draggable Handle & Mode Toggle Buttons
                            GestureDetector(
                              onVerticalDragUpdate: (details) {
                                if (details.delta.dy < -6) {
                                  setState(
                                    () => _mobileViewMode =
                                        _MobileViewMode.fullList,
                                  );
                                } else if (details.delta.dy > 6) {
                                  setState(
                                    () => _mobileViewMode =
                                        _MobileViewMode.fullMap,
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                color: Colors.transparent,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            _buildModeSegmentButton(
                                              label: 'Full Map',
                                              icon: Icons.map,
                                              isSelected:
                                                  _mobileViewMode ==
                                                  _MobileViewMode.fullMap,
                                              onTap: () => setState(
                                                () => _mobileViewMode =
                                                    _MobileViewMode.fullMap,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            _buildModeSegmentButton(
                                              label: 'Split',
                                              icon: Icons.vertical_split,
                                              isSelected:
                                                  _mobileViewMode ==
                                                  _MobileViewMode.split,
                                              onTap: () => setState(
                                                () => _mobileViewMode =
                                                    _MobileViewMode.split,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            _buildModeSegmentButton(
                                              label: 'Full List',
                                              icon: Icons.view_list,
                                              isSelected:
                                                  _mobileViewMode ==
                                                  _MobileViewMode.fullList,
                                              onTap: () => setState(
                                                () => _mobileViewMode =
                                                    _MobileViewMode.fullList,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Positioned(
                                          right: 12,
                                          child: _buildMobileSortIconButton(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const Divider(height: 1),

                            // Inline Accordion Attraction List
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: _handleRefresh,
                                child: items.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'No attractions match selection.',
                                        ),
                                      )
                                    : ListView.builder(
                                        padding: const EdgeInsets.fromLTRB(
                                          12,
                                          6,
                                          12,
                                          24,
                                        ),
                                        itemCount: items.length,
                                        itemBuilder: (context, idx) {
                                          final item = items[idx];
                                          final key = _tileKeys.putIfAbsent(
                                            item.facility.id,
                                            GlobalKey.new,
                                          );
                                          final isExpanded =
                                              _expandedFacilityId ==
                                              item.facility.id;

                                          return InlineAccordionAttractionTile(
                                            key: key,
                                            facility: item.facility,
                                            landName: item.landName,
                                            wait: item.wait,
                                            parkId: widget.parkId,
                                            isExpanded: isExpanded,
                                            isJoiningQueue:
                                                _joiningVirtualQueues.contains(
                                                  item.facility.id,
                                                ),
                                            hasJoinedQueue: _joinedVirtualQueues
                                                .contains(item.facility.id),
                                            onTap: () => _toggleAccordionTile(
                                              item.facility.id,
                                            ),
                                            onJoinQueue: () =>
                                                _joinVirtualQueue(
                                                  item.facility.id,
                                                  item.facility.name,
                                                ),
                                          );
                                        },
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeSegmentButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          border: isSelected
              ? null
              : Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LANDSCAPE / TABLET LAYOUT ---
  Widget _buildTabletLayout(
    ParkDetail detail,
    WaitTimesResponse waits,
    AppLocalizations? loc,
  ) {
    final items = _getFilteredItems(detail, waits);
    final filteredFacilities = items.map((e) => e.facility).toList();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final leftWidth = _landscapePanelCollapsed
            ? 0.0
            : (constraints.maxWidth * _splitRatio).clamp(300.0, 420.0);

        return Row(
          children: [
            // Left Collapsible Master Pane (Attraction List with Inline Accordion)
            if (!_landscapePanelCollapsed)
              SizedBox(
                width: leftWidth,
                child: Stack(
                  children: [
                    _buildStaticBackground(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          _buildFilterChips(horizontal: true, loc: loc),
                          _buildMobileSortRow(),
                          Expanded(
                            child: items.isEmpty
                                ? const Center(
                                    child: Text('No matching items.'),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    itemCount: items.length,
                                    itemBuilder: (context, index) {
                                      final item = items[index];
                                      final key = _tileKeys.putIfAbsent(
                                        'tab_${item.facility.id}',
                                        GlobalKey.new,
                                      );
                                      final isExpanded =
                                          _expandedFacilityId ==
                                          item.facility.id;

                                      return InlineAccordionAttractionTile(
                                        key: key,
                                        facility: item.facility,
                                        landName: item.landName,
                                        wait: item.wait,
                                        parkId: widget.parkId,
                                        isExpanded: isExpanded,
                                        isJoiningQueue: _joiningVirtualQueues
                                            .contains(item.facility.id),
                                        hasJoinedQueue: _joinedVirtualQueues
                                            .contains(item.facility.id),
                                        onTap: () => _toggleAccordionTile(
                                          item.facility.id,
                                        ),
                                        onJoinQueue: () => _joinVirtualQueue(
                                          item.facility.id,
                                          item.facility.name,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Draggable / Resizable Divider
            if (!_landscapePanelCollapsed)
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    final newRatio =
                        _splitRatio + (details.delta.dx / constraints.maxWidth);
                    _splitRatio = newRatio.clamp(0.25, 0.55);
                  });
                },
                child: Container(
                  width: 6,
                  color: theme.colorScheme.onSurface.withValues(
                    alpha: isDark ? 0.08 : 0.06,
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 2,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: isDark ? 0.30 : 0.38,
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),

            // Right Pane: Map with Collapsible Toggle Button
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _buildMapSection(
                      filteredFacilities,
                      waits,
                      isMobile: false,
                    ),
                  ),

                  // Collapsible Side-Panel Button (Top-Left of Map Pane)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(24),
                      color: theme.colorScheme.surface,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _landscapePanelCollapsed =
                                !_landscapePanelCollapsed;
                          });
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _landscapePanelCollapsed
                                    ? Icons.menu_open
                                    : Icons.chevron_left,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _landscapePanelCollapsed
                                    ? 'Show List'
                                    : 'Full Map',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (_selectedFacilityId != null && _landscapePanelCollapsed)
                    _buildSlidingDetailModal(detail, waits),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // --- DESKTOP LAYOUT ---
  Widget _buildDesktopLayout(
    ParkDetail detail,
    WaitTimesResponse waits,
    AppLocalizations? loc,
  ) {
    final items = _getDesktopFilteredItems(detail, waits);
    final filteredFacilities = items.map((e) => e.facility).toList();
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (Filters): checkbox tree sidebar
        SizedBox(
          width: 250,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _buildDesktopLeftSidebar(detail),
          ),
        ),

        const VerticalDivider(width: 1, thickness: 1),

        // Center Column: Advanced Data Grid
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Attractions Directory',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 140,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _desktopSort,
                          focusColor: Colors.transparent,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, size: 20),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _desktopSort = newValue;
                              });
                              FocusManager.instance.primaryFocus?.unfocus();
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                              value: 'alphabetical',
                              child: Text('Alphabetical'),
                            ),
                            DropdownMenuItem(
                              value: 'historicalAverage',
                              child: Text('Hist. Average'),
                            ),
                            DropdownMenuItem(
                              value: 'rating',
                              child: Text('User Rating'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: items.isEmpty
                      ? const Center(
                          child: Text('No attractions match selected filters.'),
                        )
                      : ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final isSelected =
                                _selectedFacilityId == item.facility.id;
                            return DesktopAttractionRow(
                              facility: item.facility,
                              landName: item.landName,
                              wait: item.wait,
                              isSelected: isSelected,
                              onTap: () {
                                setState(() {
                                  _selectedFacilityId = item.facility.id;
                                });
                                context.push(
                                  '/home/details?facilityId=${item.facility.id}&parkId=${widget.parkId}',
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),

        const VerticalDivider(width: 1, thickness: 1),

        // Right Column: Map + Detail view
        Expanded(
          flex: 4,
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: _buildMapSection(
                  filteredFacilities,
                  waits,
                  isMobile: false,
                ),
              ),
              const Divider(height: 1, thickness: 1),
              Expanded(
                flex: 5,
                child: _selectedFacilityId == null
                    ? const Center(
                        child: Text(
                          'Select an attraction to view details.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : _buildDesktopDetailPanel(detail, waits),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- SUB WIDGET BUILDERS ---

  Widget _buildStaticBackground() {
    final theme = Theme.of(context);

    final bgUrl = widget.parkId == 'p2'
        ? 'https://images.unsplash.com/photo-1597466765990-64ad1c35dafc?q=80&w=1200'
        : 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=1200';

    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            bgUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: theme.colorScheme.surface),
          ),
          Container(
            color: theme.scaffoldBackgroundColor.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips({
    required bool horizontal,
    required AppLocalizations? loc,
    double height = 44,
  }) {
    final activeFilters = ref.watch(selectedFiltersProvider(widget.parkId));

    final filters = [
      _FilterOption(
        key: 'thrill',
        label: loc?.filter_thrill ?? 'Thrill',
        icon: Icons.bolt,
      ),
      _FilterOption(
        key: 'toddler',
        label: loc?.filter_toddler ?? 'Toddler',
        icon: Icons.child_care,
      ),
      _FilterOption(
        key: 'indoor',
        label: loc?.filter_indoor ?? 'Indoor',
        icon: Icons.home,
      ),
      _FilterOption(
        key: 'dining',
        label: loc?.filter_dining ?? 'Dining',
        icon: Icons.restaurant,
      ),
    ];

    void toggleFilter(String key) {
      ref.read(
        selectedFiltersProvider(widget.parkId).notifier,
      ).toggle(key);
    }

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final opt = filters[index];
          final selected = activeFilters.contains(opt.key);
          return FilterChip(
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            avatar: Icon(
              opt.icon,
              size: 14,
              color: selected ? Theme.of(context).colorScheme.onPrimary : null,
            ),
            label: Text(
              opt.label,
              style: TextStyle(
                fontSize: 12,
                color: selected
                    ? Theme.of(context).colorScheme.onPrimary
                    : null,
              ),
            ),
            selected: selected,
            selectedColor: Theme.of(context).colorScheme.primary,
            checkmarkColor: Theme.of(context).colorScheme.onPrimary,
            onSelected: (_) => toggleFilter(opt.key),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLeftSidebar(ParkDetail detail) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced Filters',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),

            Text(
              'Attraction Type',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            _buildCheckbox(
              'Thrill Rides',
              _desktopActiveTypes.contains('thrill'),
              (val) {
                setState(() {
                  if (val ?? false) {
                    _desktopActiveTypes.add('thrill');
                  } else {
                    _desktopActiveTypes.remove('thrill');
                  }
                });
              },
            ),
            _buildCheckbox(
              'Toddler Friendly',
              _desktopActiveTypes.contains('toddler'),
              (val) {
                setState(() {
                  if (val ?? false) {
                    _desktopActiveTypes.add('toddler');
                  } else {
                    _desktopActiveTypes.remove('toddler');
                  }
                });
              },
            ),
            _buildCheckbox(
              'Indoor Shows/Rides',
              _desktopActiveTypes.contains('indoor'),
              (val) {
                setState(() {
                  if (val ?? false) {
                    _desktopActiveTypes.add('indoor');
                  } else {
                    _desktopActiveTypes.remove('indoor');
                  }
                });
              },
            ),
            _buildCheckbox(
              'Dining / Restaurants',
              _desktopActiveTypes.contains('dining'),
              (val) {
                setState(() {
                  if (val ?? false) {
                    _desktopActiveTypes.add('dining');
                  } else {
                    _desktopActiveTypes.remove('dining');
                  }
                });
              },
            ),

            const Divider(height: 24),

            Text(
              'Standby Wait Time',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            _buildCheckbox(
              'Under 15 min',
              _desktopActiveWaitTimes.contains('15'),
              (val) {
                setState(() {
                  if (val ?? false) {
                    _desktopActiveWaitTimes.add('15');
                  } else {
                    _desktopActiveWaitTimes.remove('15');
                  }
                });
              },
            ),
            _buildCheckbox(
              'Under 30 min',
              _desktopActiveWaitTimes.contains('30'),
              (val) {
                setState(() {
                  if (val ?? false) {
                    _desktopActiveWaitTimes.add('30');
                  } else {
                    _desktopActiveWaitTimes.remove('30');
                  }
                });
              },
            ),
            _buildCheckbox(
              'Under 60 min',
              _desktopActiveWaitTimes.contains('60'),
              (val) {
                setState(() {
                  if (val ?? false) {
                    _desktopActiveWaitTimes.add('60');
                  } else {
                    _desktopActiveWaitTimes.remove('60');
                  }
                });
              },
            ),

            const Divider(height: 24),

            Text(
              'Park Lands',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            ...detail.children.map((land) {
              return _buildCheckbox(
                land.name,
                _desktopActiveLands.contains(land.id),
                (val) {
                  setState(() {
                    if (val ?? false) {
                      _desktopActiveLands.add(land.id);
                    } else {
                      _desktopActiveLands.remove(land.id);
                    }
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlidingDetailModal(ParkDetail detail, WaitTimesResponse waits) {
    Facility? selectedFac;
    for (final land in detail.children) {
      for (final f in land.children) {
        if (f.id == _selectedFacilityId) {
          selectedFac = f;
          break;
        }
      }
    }
    if (selectedFac == null) return const SizedBox.shrink();

    final matchedWait = waits.waitTimes.where(
      (w) => w.rideId == selectedFac!.id,
    );
    final wait = matchedWait.isEmpty ? null : matchedWait.first;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 380,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: FacilityDetailSheetContent(
          facility: selectedFac,
          wait: wait,
          parkId: widget.parkId,
          onClose: () {
            setState(() {
              _selectedFacilityId = null;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDesktopDetailPanel(ParkDetail detail, WaitTimesResponse waits) {
    Facility? selectedFac;
    for (final land in detail.children) {
      for (final f in land.children) {
        if (f.id == _selectedFacilityId) {
          selectedFac = f;
          break;
        }
      }
    }
    if (selectedFac == null) return const SizedBox.shrink();

    final matchedWait = waits.waitTimes.where(
      (w) => w.rideId == selectedFac!.id,
    );
    final wait = matchedWait.isEmpty ? null : matchedWait.first;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: FacilityDetailSheetContent(
        facility: selectedFac,
        wait: wait,
        parkId: widget.parkId,
      ),
    );
  }

  Widget _buildMapSection(
    List<Facility> facilities,
    WaitTimesResponse waits, {
    required bool isMobile,
  }) {
    return ParkMapWidget(
      parkId: widget.parkId,
      facilities: facilities,
      waitTimes: waits.waitTimes,
      isMobile: isMobile,
      selectedFacilityId: _selectedFacilityId,
      onFacilityTapped: (facility) {
        setState(() {
          _selectedFacilityId = facility.id;
        });
        if (isMobile) {
          context.push(
            '/home/details?facilityId=${facility.id}&parkId=${widget.parkId}',
          );
        }
      },
    );
  }

  Widget _buildMobileSortRow() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Sort by: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(
            width: 130,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _mobileSort,
                focusColor: Colors.transparent,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, size: 20),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _mobileSort = newValue;
                    });
                    FocusManager.instance.primaryFocus?.unfocus();
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: 'proximity',
                    child: Text('Nearest to Me'),
                  ),
                  DropdownMenuItem(
                    value: 'waitTime',
                    child: Text('Lowest Wait'),
                  ),
                  DropdownMenuItem(
                    value: 'recency',
                    child: Text('Data Recency'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileSortIconButton() {
    final theme = Theme.of(context);
    return PopupMenuButton<String>(
      icon: Icon(Icons.sort, color: theme.colorScheme.primary),
      tooltip: 'Sort options',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onSelected: (String newValue) {
        setState(() {
          _mobileSort = newValue;
        });
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'proximity',
          child: Row(
            children: [
              Icon(
                Icons.near_me,
                size: 18,
                color: _mobileSort == 'proximity'
                    ? theme.colorScheme.primary
                    : null,
              ),
              const SizedBox(width: 8),
              const Text('Nearest to Me'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'waitTime',
          child: Row(
            children: [
              Icon(
                Icons.hourglass_empty,
                size: 18,
                color: _mobileSort == 'waitTime'
                    ? theme.colorScheme.primary
                    : null,
              ),
              const SizedBox(width: 8),
              const Text('Lowest Wait'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'recency',
          child: Row(
            children: [
              Icon(
                Icons.update,
                size: 18,
                color: _mobileSort == 'recency'
                    ? theme.colorScheme.primary
                    : null,
              ),
              const SizedBox(width: 8),
              const Text('Data Recency'),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterOption {
  const _FilterOption({
    required this.key,
    required this.label,
    required this.icon,
  });
  final String key;
  final String label;
  final IconData icon;
}

class _ListFacilityItem {
  const _ListFacilityItem({
    required this.facility,
    required this.wait,
    required this.landName,
  });
  final Facility facility;
  final WaitTime? wait;
  final String landName;
}

// --- RESPONSIVE Breakpoint Child Widgets & Accordion ---

class InlineAccordionAttractionTile extends ConsumerWidget {
  const InlineAccordionAttractionTile({
    required this.facility,
    required this.landName,
    required this.wait,
    required this.parkId,
    required this.isExpanded,
    required this.isJoiningQueue,
    required this.hasJoinedQueue,
    required this.onTap,
    required this.onJoinQueue,
    super.key,
  });

  final Facility facility;
  final String landName;
  final WaitTime? wait;
  final String parkId;
  final bool isExpanded;
  final bool isJoiningQueue;
  final bool hasJoinedQueue;
  final VoidCallback onTap;
  final VoidCallback onJoinQueue;

  String _getStaticImageUrl(Facility f) {
    final nameLower = f.name.toLowerCase();
    if (nameLower.contains('flight') ||
        nameLower.contains('avatar') ||
        nameLower.contains('space') ||
        nameLower.contains('astro')) {
      return 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=200';
    }
    if (nameLower.contains('everest') ||
        nameLower.contains('thunder') ||
        nameLower.contains('mountain')) {
      return 'https://images.unsplash.com/photo-1513885535751-8b9238bd345a?q=80&w=200';
    }
    if (nameLower.contains('safaris') ||
        nameLower.contains('rapid') ||
        nameLower.contains('jungle') ||
        nameLower.contains('river')) {
      return 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?q=80&w=200';
    }
    if (nameLower.contains('cafe') ||
        nameLower.contains('restaurant') ||
        nameLower.contains('grill')) {
      return 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=200';
    }
    return 'https://images.unsplash.com/photo-1603048588665-791ca8aea617?q=80&w=200';
  }

  List<int> _getWaitTimeTrend(String rideId, int currentWait) {
    final list = <int>[];
    final hash = rideId.hashCode;
    for (var i = 6; i > 0; i--) {
      final offset = ((hash ^ i) % 25) - 12;
      final waitVal = (currentWait + offset).clamp(5, 180);
      list.add(waitVal);
    }
    list.add(currentWait);
    return list;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isClosed = wait == null || wait!.status != 'Open';
    final currentWait = wait?.waitMinutes ?? 0;
    final waitText = isClosed ? 'Closed' : '${currentWait}m';

    final cs = theme.colorScheme;
    var waitColor = cs.primary;
    if (isClosed) {
      waitColor = cs.outline;
    } else if (currentWait > 50) {
      waitColor = cs.error;
    } else if (currentWait > 20) {
      waitColor = cs.tertiary;
    }

    final imageUrl = _getStaticImageUrl(facility);
    final trendData = _getWaitTimeTrend(facility.id, currentWait);

    final waitBg = isClosed
        ? cs.surfaceContainerHigh
        : (currentWait > 50
              ? cs.errorContainer
              : (currentWait > 20
                    ? cs.tertiaryContainer
                    : cs.primaryContainer));
    final waitFg = isClosed
        ? cs.onSurfaceVariant
        : (currentWait > 50
              ? cs.onErrorContainer
              : (currentWait > 20
                    ? cs.onTertiaryContainer
                    : cs.onPrimaryContainer));

    void navigateToDetails() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              FacilityDetailPage(facilityId: facility.id, parkId: parkId),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpanded
                ? theme.colorScheme.primary
                : (isDark ? Colors.white24 : Colors.black12),
            width: isExpanded ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isExpanded ? 0.2 : 0.06),
              blurRadius: isExpanded ? 10 : 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Card Header Row wrapped in InkWell for Quick Context Accordion expansion
            InkWell(
              onTap: onTap, // Toggles inline accordion (Quick Context)
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    // Attraction Image (Deep Dive Tap Target)
                    InkWell(
                      onTap: navigateToDetails,
                      borderRadius: BorderRadius.circular(12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Attraction Info Column (Title = Deep Dive; rest = Quick Context)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: navigateToDetails,
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 2,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      facility.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: theme.colorScheme.primary,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.open_in_new_rounded,
                                    size: 14,
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$landName • Thrill: ${facility.thrillLevel ?? "Low"}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text.rich(
                            TextSpan(
                              children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Icon(
                                    (facility.heightRequirementInches ?? 0) > 0
                                        ? Icons.height
                                        : Icons.child_care,
                                    size: 13,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                                const WidgetSpan(child: SizedBox(width: 3)),
                                TextSpan(
                                  text:
                                      (facility.heightRequirementInches ?? 0) >
                                          0
                                      ? '${facility.heightRequirementInches}" min'
                                      : 'All Ages',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Right side: Emphasized Wait Badge + Downward Chevron Accordion Toggle
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: waitBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: waitColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PulseDot(color: waitFg, size: 6),
                              const SizedBox(width: 6),
                              Text(
                                waitText,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: waitFg,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Downward chevron button
                        IconButton(
                          onPressed: onTap,
                          icon: Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: theme.colorScheme.primary,
                            size: 26,
                          ),
                          tooltip: isExpanded
                              ? 'Collapse Quick Context'
                              : 'Expand Quick Context',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Inline Accordion Expanded Details (Quick Context & Sparkline)
            if (isExpanded) ...[
              const Divider(height: 1, indent: 12, endIndent: 12),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sparkline chart of downsampled wait-time trend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Wait Time Trend (Continuous Aggregate)',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Downsampled',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: SparklineChart(
                          data: trendData,
                          lineColor: waitColor,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Concise 1-sentence description
                    Text(
                      'Experience thrilling excitement in $landName with real-time downsampled queue insights and immersive environments.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.85,
                        ),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Virtual Queue Action Row (Min 44pt touch target)
                    Row(
                      children: [
                        Expanded(
                          child: isJoiningQueue
                              ? Container(
                                  height: 44,
                                  alignment: Alignment.center,
                                  child: const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                )
                              : hasJoinedQueue
                              ? Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: theme
                                            .colorScheme
                                            .onPrimaryContainer,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Virtual Queue Joined (Group 14)',
                                        style: TextStyle(
                                          color: theme
                                              .colorScheme
                                              .onPrimaryContainer,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox(
                                  height: 44,
                                  child: ElevatedButton.icon(
                                    onPressed: onJoinQueue,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      foregroundColor:
                                          theme.colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.confirmation_number_outlined,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      'Join Virtual Queue',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // TimescaleDB Continuous Aggregates Historical Wait Time Chart
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Wait Time History (TimescaleDB)',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Last 3 Hours',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Non-blocking AreaChartWidget
                    AreaChartWidget(
                      data: trendData,
                      lineColor: waitColor,
                      height: 130,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// --- RESPONSIVE Breakpoint Child Widgets ---

class MobileAttractionTile extends StatelessWidget {
  const MobileAttractionTile({
    required this.facility,
    required this.landName,
    required this.wait,
    required this.onTap,
    super.key,
  });

  final Facility facility;
  final String landName;
  final WaitTime? wait;
  final VoidCallback onTap;

  String _getStaticImageUrl(Facility f) {
    final nameLower = f.name.toLowerCase();
    if (nameLower.contains('flight') ||
        nameLower.contains('avatar') ||
        nameLower.contains('space') ||
        nameLower.contains('astro')) {
      return 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=200';
    }
    if (nameLower.contains('everest') ||
        nameLower.contains('thunder') ||
        nameLower.contains('mountain')) {
      return 'https://images.unsplash.com/photo-1513885535751-8b9238bd345a?q=80&w=200';
    }
    if (nameLower.contains('safaris') ||
        nameLower.contains('rapid') ||
        nameLower.contains('jungle') ||
        nameLower.contains('river')) {
      return 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?q=80&w=200';
    }
    if (nameLower.contains('cafe') ||
        nameLower.contains('restaurant') ||
        nameLower.contains('grill')) {
      return 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=200';
    }
    return 'https://images.unsplash.com/photo-1603048588665-791ca8aea617?q=80&w=200';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isClosed = wait == null || wait!.status != 'Open';
    final waitText = isClosed ? 'Closed' : '${wait!.waitMinutes}m';
    final currentWait = wait?.waitMinutes ?? 0;

    final cs = Theme.of(context).colorScheme;
    var waitColor = cs.primary;
    if (isClosed) {
      waitColor = cs.outline;
    } else if (currentWait > 50) {
      waitColor = cs.error;
    } else if (currentWait > 20) {
      waitColor = cs.tertiary;
    }

    final imageUrl = _getStaticImageUrl(facility);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 96,
        borderRadius: 16,
        blur: 15,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: isDark ? 0.06 : 0.5),
            Colors.white.withValues(alpha: isDark ? 0.02 : 0.2),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: isDark ? 0.15 : 0.6),
            Colors.white.withValues(alpha: isDark ? 0.05 : 0.2),
          ],
        ),
        child: InkWell(
          key: ValueKey('facility_list_item_${facility.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        facility.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$landName • Thrill: ${facility.thrillLevel ?? "Low"}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                (facility.heightRequirementInches ?? 0) > 0
                                    ? Icons.height
                                    : Icons.child_care,
                                size: 13,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                (facility.heightRequirementInches ?? 0) > 0
                                    ? '${facility.heightRequirementInches}"'
                                    : 'Family',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.accessible_forward,
                                size: 13,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.38,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Accessible',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PulseDot(color: waitColor, size: 7),
                    const SizedBox(width: 6),
                    Text(
                      waitText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: waitColor,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TabletAttractionTile extends StatelessWidget {
  const TabletAttractionTile({
    required this.facility,
    required this.landName,
    required this.wait,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final Facility facility;
  final String landName;
  final WaitTime? wait;
  final bool isSelected;
  final VoidCallback onTap;

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

  String _getStaticImageUrl(Facility f) {
    final nameLower = f.name.toLowerCase();
    if (nameLower.contains('flight') ||
        nameLower.contains('avatar') ||
        nameLower.contains('space') ||
        nameLower.contains('astro')) {
      return 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=200';
    }
    if (nameLower.contains('everest') ||
        nameLower.contains('thunder') ||
        nameLower.contains('mountain')) {
      return 'https://images.unsplash.com/photo-1513885535751-8b9238bd345a?q=80&w=200';
    }
    if (nameLower.contains('safaris') ||
        nameLower.contains('rapid') ||
        nameLower.contains('jungle') ||
        nameLower.contains('river')) {
      return 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?q=80&w=200';
    }
    if (nameLower.contains('cafe') ||
        nameLower.contains('restaurant') ||
        nameLower.contains('grill')) {
      return 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=200';
    }
    return 'https://images.unsplash.com/photo-1603048588665-791ca8aea617?q=80&w=200';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isClosed = wait == null || wait!.status != 'Open';
    final currentWait = wait?.waitMinutes ?? 0;

    var waitColor = theme.colorScheme.primary;
    if (isClosed) {
      waitColor = theme.colorScheme.outline;
    } else if (currentWait > 50) {
      waitColor = theme.colorScheme.error;
    } else if (currentWait > 20) {
      waitColor = theme.colorScheme.tertiary;
    }

    final trend = _getWaitTimeTrend(facility.id, currentWait);
    final imageUrl = _getStaticImageUrl(facility);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 80,
        borderRadius: 16,
        blur: 15,
        alignment: Alignment.center,
        border: isSelected ? 2.0 : 1.0,
        linearGradient: LinearGradient(
          colors: [
            if (isSelected)
              theme.colorScheme.primary.withValues(alpha: isDark ? 0.18 : 0.35)
            else
              Colors.white.withValues(alpha: isDark ? 0.06 : 0.5),
            Colors.white.withValues(alpha: isDark ? 0.02 : 0.2),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            if (isSelected)
              theme.colorScheme.primary.withValues(alpha: 0.8)
            else
              Colors.white.withValues(alpha: isDark ? 0.15 : 0.6),
            Colors.white.withValues(alpha: isDark ? 0.05 : 0.2),
          ],
        ),
        child: InkWell(
          key: ValueKey('facility_list_item_${facility.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        facility.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        landName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                if (!isClosed) ...[
                  SparklineChart(
                    data: trend,
                    lineColor: waitColor,
                    width: 70,
                    height: 30,
                  ),
                ] else ...[
                  Container(
                    width: 70,
                    alignment: Alignment.center,
                    child: Text(
                      'Closed',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DesktopAttractionRow extends StatefulWidget {
  const DesktopAttractionRow({
    required this.facility,
    required this.landName,
    required this.wait,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final Facility facility;
  final String landName;
  final WaitTime? wait;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<DesktopAttractionRow> createState() => _DesktopAttractionRowState();
}

class _DesktopAttractionRowState extends State<DesktopAttractionRow> {
  bool _isHovered = false;

  String _getGIFUrl(Facility f) {
    final nameLower = f.name.toLowerCase();
    if (nameLower.contains('flight') ||
        nameLower.contains('avatar') ||
        nameLower.contains('space') ||
        nameLower.contains('astro')) {
      return 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExM3h5cHF4bml1bGVwdDlwZmR5bWZkcTV4dzB5cHkyZWQzOGc1eWxtNCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/3ornk57KwDXf81rjWM/giphy.gif';
    }
    if (nameLower.contains('everest') ||
        nameLower.contains('thunder') ||
        nameLower.contains('mountain')) {
      return 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExOHkycHkyMTJrNDl1cmh5a2txNXZ5azUzdjVxMmtxbXF2NTh2bTRiayZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/YhW0QsO2usWQi1oXcc/giphy.gif';
    }
    if (nameLower.contains('safaris') ||
        nameLower.contains('rapid') ||
        nameLower.contains('jungle') ||
        nameLower.contains('river')) {
      return 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExdDVxbzh2MTJrMjEzdjVxNmh5NXZ5MTJrMjEzdjVxNmh5NXZ5bTRiayZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/l2JJEIMrgrcSBueWs/giphy.gif';
    }
    return 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExbTRhaTFyOHlycHkyMTJrNDl1cmh5a2txNXZ5azUzdjVxMmtxbXF2NTh2bTRiayZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/3o7TKSjRrfIPjei1fG/giphy.gif';
  }

  String _getStaticImageUrl(Facility f) {
    final nameLower = f.name.toLowerCase();
    if (nameLower.contains('flight') ||
        nameLower.contains('avatar') ||
        nameLower.contains('space') ||
        nameLower.contains('astro')) {
      return 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=200';
    }
    if (nameLower.contains('everest') ||
        nameLower.contains('thunder') ||
        nameLower.contains('mountain')) {
      return 'https://images.unsplash.com/photo-1513885535751-8b9238bd345a?q=80&w=200';
    }
    if (nameLower.contains('safaris') ||
        nameLower.contains('rapid') ||
        nameLower.contains('jungle') ||
        nameLower.contains('river')) {
      return 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?q=80&w=200';
    }
    if (nameLower.contains('cafe') ||
        nameLower.contains('restaurant') ||
        nameLower.contains('grill')) {
      return 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=200';
    }
    return 'https://images.unsplash.com/photo-1603048588665-791ca8aea617?q=80&w=200';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isClosed = widget.wait == null || widget.wait!.status != 'Open';
    final waitText = isClosed ? 'Closed' : '${widget.wait!.waitMinutes}m';
    final currentWait = widget.wait?.waitMinutes ?? 0;

    var waitColor = theme.colorScheme.primary;
    if (isClosed) {
      waitColor = theme.colorScheme.outline;
    } else if (currentWait > 50) {
      waitColor = theme.colorScheme.error;
    } else if (currentWait > 20) {
      waitColor = theme.colorScheme.tertiary;
    }

    final hash = widget.facility.id.hashCode;
    final histAvg = (hash % 45) + 15;
    final predWait = ((hash ^ 2) % 40) + 10;
    final rating = 4.0 + ((hash % 10) / 10.0) * 0.9;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        key: ValueKey('facility_list_item_${widget.facility.id}'),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scaleByDouble(
              _isHovered ? 1.02 : 1.0,
              _isHovered ? 1.02 : 1.0,
              1.0,
              1.0,
            ),
          transformAlignment: Alignment.center,
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? theme.colorScheme.primary.withValues(
                    alpha: isDark ? 0.15 : 0.25,
                  )
                : (_isHovered
                      ? (isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.8))
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.03)
                            : Colors.white.withValues(alpha: 0.45))),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.6)
                  : (_isHovered
                        ? (isDark
                              ? Colors.white24
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.12,
                                ))
                        : Colors.transparent),
              width: 1.5,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: isDark ? 0.4 : 0.1,
                      ),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Image.network(
                    _isHovered
                        ? _getGIFUrl(widget.facility)
                        : _getStaticImageUrl(widget.facility),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => ColoredBox(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image, size: 24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.facility.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.landName,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    PulseDot(color: waitColor, size: 7),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        waitText,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: waitColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                flex: 2,
                child: Text(
                  '${histAvg}m avg',
                  style: const TextStyle(fontSize: 12),
                ),
              ),

              Expanded(
                flex: 2,
                child: Text(
                  '${predWait}m @ 2pm',
                  style: const TextStyle(fontSize: 12),
                ),
              ),

              Expanded(
                flex: 2,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
