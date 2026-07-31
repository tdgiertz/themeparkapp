import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/features/park/park_explorer_state.dart';
import 'package:themeparkapp/features/park/widgets/park_map.dart';
import 'package:themeparkapp/features/park/widgets/sparkline_chart.dart';
import 'package:themeparkapp/features/park/widgets/pulse_dot.dart';
import 'package:themeparkapp/features/park/widgets/facility_detail_sheet.dart';
import 'package:themeparkapp/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:themeparkapp/models/park_detail.dart';
import 'package:themeparkapp/models/wait_time.dart';

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
  
  // Mobile layout local state
  bool _showMapOnMobile = false;

  // Track the highlighted attraction
  String? _selectedFacilityId;

  // Split view ratio for Tablet (600px - 1024px)
  double _splitRatio = 0.4;

  // Desktop Local Filter States
  final Set<String> _desktopActiveTypes = {};
  final Set<String> _desktopActiveWaitTimes = {}; // '15', '30', '60'
  final Set<String> _desktopActiveLands = {};

  @override
  void initState() {
    super.initState();
    if (_autoRefreshEnabled) {
      _startAutoRefresh();
    }
  }

  void _startAutoRefresh() {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
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

  Color _getWaitColor(int waitTime) {
    if (waitTime <= 20) return Colors.green.shade600;
    if (waitTime <= 50) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  List<_ListFacilityItem> _getFilteredItems(ParkDetail detail, WaitTimesResponse waits) {
    final activeFilters = ref.watch(selectedFiltersProvider(widget.parkId));
    final items = <_ListFacilityItem>[];
    for (final land in detail.children) {
      for (final f in land.children) {
        final matchedWait = waits.waitTimes.where((w) => w.rideId == f.id);
        final wait = matchedWait.isEmpty ? null : matchedWait.first;

        final isThrill = f.thrillLevel == 'High' || f.thrillLevel == 'Moderate';
        final isToddler = f.thrillLevel == 'Low' || (f.heightRequirementInches ?? 0) == 0;
        final isIndoor = f.name.toLowerCase().contains(RegExp('hall|theater|meet|princess|grotto|grizzly|buzz|space|small world|haunted|mansion|cafe|flight|bluey|zootopia|bear|show'));
        final isDining = f.name.toLowerCase().contains(RegExp('cafe|restaurant|grill|dining|eats|table|bakery|kitchen|tavern|food|pub'));

        bool matches = true;
        if (activeFilters.isNotEmpty) {
          matches = false;
          if (activeFilters.contains('thrill') && isThrill) matches = true;
          if (activeFilters.contains('toddler') && isToddler) matches = true;
          if (activeFilters.contains('indoor') && isIndoor) matches = true;
          if (activeFilters.contains('dining') && isDining) matches = true;
        }

        if (matches) {
          items.add(_ListFacilityItem(facility: f, wait: wait, landName: land.name));
        }
      }
    }
    return items;
  }

  List<_ListFacilityItem> _getDesktopFilteredItems(ParkDetail detail, WaitTimesResponse waits) {
    final items = <_ListFacilityItem>[];
    for (final land in detail.children) {
      for (final f in land.children) {
        final matchedWait = waits.waitTimes.where((w) => w.rideId == f.id);
        final wait = matchedWait.isEmpty ? null : matchedWait.first;

        final isThrill = f.thrillLevel == 'High' || f.thrillLevel == 'Moderate';
        final isToddler = f.thrillLevel == 'Low' || (f.heightRequirementInches ?? 0) == 0;
        final isIndoor = f.name.toLowerCase().contains(RegExp('hall|theater|meet|princess|grotto|grizzly|buzz|space|small world|haunted|mansion|cafe|flight|bluey|zootopia|bear|show'));
        final isDining = f.name.toLowerCase().contains(RegExp('cafe|restaurant|grill|dining|eats|table|bakery|kitchen|tavern|food|pub'));

        // 1. Check type filters
        if (_desktopActiveTypes.isNotEmpty) {
          bool matchesType = false;
          if (_desktopActiveTypes.contains('thrill') && isThrill) matchesType = true;
          if (_desktopActiveTypes.contains('toddler') && isToddler) matchesType = true;
          if (_desktopActiveTypes.contains('indoor') && isIndoor) matchesType = true;
          if (_desktopActiveTypes.contains('dining') && isDining) matchesType = true;
          if (!matchesType) continue;
        }

        // 2. Check wait time filters
        if (_desktopActiveWaitTimes.isNotEmpty) {
          final waitMinutes = wait?.waitMinutes ?? 0;
          final isClosed = wait == null || wait.status != 'Open';
          if (isClosed) continue;

          bool matchesWait = false;
          if (_desktopActiveWaitTimes.contains('15') && waitMinutes <= 15) matchesWait = true;
          if (_desktopActiveWaitTimes.contains('30') && waitMinutes <= 30) matchesWait = true;
          if (_desktopActiveWaitTimes.contains('60') && waitMinutes <= 60) matchesWait = true;
          if (!matchesWait) continue;
        }

        // 3. Check land filters
        if (_desktopActiveLands.isNotEmpty) {
          if (!_desktopActiveLands.contains(land.id)) continue;
        }

        items.add(_ListFacilityItem(facility: f, wait: wait, landName: land.name));
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(parkDetailProvider(widget.parkId));
    final waitsAsync = ref.watch(waitTimesProvider(widget.parkId));
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F4),
      appBar: AppBar(
        title: Text(widget.parkName),
      ),
      body: detailAsync.when(
        data: (ParkDetail detail) => waitsAsync.when(
          data: (WaitTimesResponse waits) {
            return ScreenTypeLayout.builder(
              mobile: (context) => _buildMobileLayout(detail, waits, loc),
              tablet: (context) => _buildTabletLayout(detail, waits, loc),
              desktop: (context) => _buildDesktopLayout(detail, waits, loc),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(child: Text('Error loading waits: $err')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error loading park: $err')),
      ),
    );
  }

  // --- MOBILE LAYOUT ---
  Widget _buildMobileLayout(
    ParkDetail detail,
    WaitTimesResponse waits,
    AppLocalizations? loc,
  ) {
    final items = _getFilteredItems(detail, waits);
    
    return Scaffold(
      body: Stack(
        children: [
          _buildStaticBackground(),
          
          Column(
            children: [
              _buildFilterChips(horizontal: true, loc: loc),
              Expanded(
                child: _showMapOnMobile
                    ? _buildMapSection(detail, waits, isMobile: true)
                    : RefreshIndicator(
                        onRefresh: _handleRefresh,
                        child: items.isEmpty
                            ? const Center(
                                child: Text('No attractions match selection.'),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                                itemCount: items.length,
                                itemBuilder: (context, idx) {
                                  final item = items[idx];
                                  return MobileAttractionTile(
                                    facility: item.facility,
                                    landName: item.landName,
                                    wait: item.wait,
                                    onTap: () {
                                      setState(() {
                                        _selectedFacilityId = item.facility.id;
                                      });
                                      context.push('/home/details?facilityId=${item.facility.id}&parkId=${widget.parkId}');
                                    },
                                  );
                                },
                              ),
                      ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _showMapOnMobile = !_showMapOnMobile;
          });
        },
        icon: Icon(_showMapOnMobile ? Icons.list_alt : Icons.map_outlined),
        label: Text(_showMapOnMobile ? 'List View' : 'Map View'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // --- TABLET LAYOUT ---
  Widget _buildTabletLayout(
    ParkDetail detail,
    WaitTimesResponse waits,
    AppLocalizations? loc,
  ) {
    final items = _getFilteredItems(detail, waits);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final leftWidth = constraints.maxWidth * _splitRatio;
        final rightWidth = constraints.maxWidth * (1 - _splitRatio);

        return Row(
          children: [
            // Left column list (Master Pane)
            SizedBox(
              width: leftWidth,
              child: Stack(
                children: [
                  _buildStaticBackground(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      children: [
                        _buildFilterChips(horizontal: true, loc: loc),
                        Expanded(
                          child: items.isEmpty
                              ? const Center(child: Text('No matching items.'))
                              : ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  itemCount: items.length,
                                  itemBuilder: (context, index) {
                                    final item = items[index];
                                    final isSelected = _selectedFacilityId == item.facility.id;
                                    return TabletAttractionTile(
                                      facility: item.facility,
                                      landName: item.landName,
                                      wait: item.wait,
                                      isSelected: isSelected,
                                      onTap: () {
                                        setState(() {
                                          _selectedFacilityId = item.facility.id;
                                        });
                                      },
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

            // Draggable Divider
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (details) {
                setState(() {
                  final newRatio = _splitRatio + (details.delta.dx / constraints.maxWidth);
                  _splitRatio = newRatio.clamp(0.25, 0.65);
                });
              },
              child: Container(
                width: 6,
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
                alignment: Alignment.center,
                child: Container(
                  width: 2,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white30 : Colors.black38,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),

            // Right: Detail map with sliding detail modal
            SizedBox(
              width: rightWidth - 6,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _buildMapSection(detail, waits, isMobile: false),
                  ),
                  if (_selectedFacilityId != null)
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (Filters): checkbox tree sidebar
        SizedBox(
          width: 250,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: _buildDesktopLeftSidebar(detail),
          ),
        ),

        const VerticalDivider(width: 1, thickness: 1),

        // Center Column: Advanced Data Grid
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attractions Directory',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: items.isEmpty
                      ? const Center(child: Text('No attractions match selected filters.'))
                      : ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final isSelected = _selectedFacilityId == item.facility.id;
                            return DesktopAttractionRow(
                              facility: item.facility,
                              landName: item.landName,
                              wait: item.wait,
                              isSelected: isSelected,
                              onTap: () {
                                setState(() {
                                  _selectedFacilityId = item.facility.id;
                                });
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
                child: _buildMapSection(detail, waits, isMobile: false),
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
    final isDark = theme.brightness == Brightness.dark;
    
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
            errorBuilder: (_, __, ___) => Container(
              color: isDark ? const Color(0xFF121B13) : const Color(0xFFE3EDE5),
            ),
          ),
          Container(
            color: isDark
                ? Colors.black.withOpacity(0.7)
                : Colors.white.withOpacity(0.7),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips({required bool horizontal, required AppLocalizations? loc}) {
    final activeFilters = ref.watch(selectedFiltersProvider(widget.parkId));

    final filters = [
      _FilterOption(key: 'thrill', label: loc?.filter_thrill ?? 'Thrill', icon: Icons.bolt),
      _FilterOption(key: 'toddler', label: loc?.filter_toddler ?? 'Toddler', icon: Icons.child_care),
      _FilterOption(key: 'indoor', label: loc?.filter_indoor ?? 'Indoor', icon: Icons.home),
      _FilterOption(key: 'dining', label: loc?.filter_dining ?? 'Dining', icon: Icons.restaurant),
    ];

    void toggleFilter(String key) {
      final notifier = ref.read(selectedFiltersProvider(widget.parkId).notifier);
      if (activeFilters.contains(key)) {
        notifier.state = activeFilters.where((f) => f != key).toSet();
      } else {
        notifier.state = {...activeFilters, key};
      }
    }

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final opt = filters[index];
          final selected = activeFilters.contains(opt.key);
          return FilterChip(
            materialTapTargetSize: MaterialTapTargetSize.padded,
            avatar: Icon(opt.icon, size: 16, color: selected ? Colors.white : null),
            label: Text(opt.label, style: TextStyle(color: selected ? Colors.white : null)),
            selected: selected,
            selectedColor: Theme.of(context).colorScheme.primary,
            checkmarkColor: Colors.white,
            onSelected: (_) => toggleFilter(opt.key),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLeftSidebar(ParkDetail detail) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E281F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced Filters',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            
            Text(
              'Attraction Type',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            _buildCheckbox('Thrill Rides', _desktopActiveTypes.contains('thrill'), (val) {
              setState(() {
                if (val == true) _desktopActiveTypes.add('thrill');
                else _desktopActiveTypes.remove('thrill');
              });
            }),
            _buildCheckbox('Toddler Friendly', _desktopActiveTypes.contains('toddler'), (val) {
              setState(() {
                if (val == true) _desktopActiveTypes.add('toddler');
                else _desktopActiveTypes.remove('toddler');
              });
            }),
            _buildCheckbox('Indoor Shows/Rides', _desktopActiveTypes.contains('indoor'), (val) {
              setState(() {
                if (val == true) _desktopActiveTypes.add('indoor');
                else _desktopActiveTypes.remove('indoor');
              });
            }),
            _buildCheckbox('Dining / Restaurants', _desktopActiveTypes.contains('dining'), (val) {
              setState(() {
                if (val == true) _desktopActiveTypes.add('dining');
                else _desktopActiveTypes.remove('dining');
              });
            }),
            
            const Divider(height: 24),
            
            Text(
              'Standby Wait Time',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            _buildCheckbox('Under 15 min', _desktopActiveWaitTimes.contains('15'), (val) {
              setState(() {
                if (val == true) _desktopActiveWaitTimes.add('15');
                else _desktopActiveWaitTimes.remove('15');
              });
            }),
            _buildCheckbox('Under 30 min', _desktopActiveWaitTimes.contains('30'), (val) {
              setState(() {
                if (val == true) _desktopActiveWaitTimes.add('30');
                else _desktopActiveWaitTimes.remove('30');
              });
            }),
            _buildCheckbox('Under 60 min', _desktopActiveWaitTimes.contains('60'), (val) {
              setState(() {
                if (val == true) _desktopActiveWaitTimes.add('60');
                else _desktopActiveWaitTimes.remove('60');
              });
            }),
            
            const Divider(height: 24),
            
            Text(
              'Park Lands',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            ...detail.children.map((land) {
              return _buildCheckbox(land.name, _desktopActiveLands.contains(land.id), (val) {
                setState(() {
                  if (val == true) _desktopActiveLands.add(land.id);
                  else _desktopActiveLands.remove(land.id);
                });
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
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
    
    final matchedWait = waits.waitTimes.where((w) => w.rideId == selectedFac!.id);
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
    
    final matchedWait = waits.waitTimes.where((w) => w.rideId == selectedFac!.id);
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
    ParkDetail detail,
    WaitTimesResponse waits, {
    required bool isMobile,
  }) {
    final allFacilities = <Facility>[];
    for (final land in detail.children) {
      allFacilities.addAll(land.children);
    }

    return ParkMapWidget(
      parkId: widget.parkId,
      facilities: allFacilities,
      waitTimes: waits.waitTimes,
      isMobile: isMobile,
      selectedFacilityId: _selectedFacilityId,
      onFacilityTapped: (facility) {
        setState(() {
          _selectedFacilityId = facility.id;
        });
        if (isMobile) {
          context.push('/home/details?facilityId=${facility.id}&parkId=${widget.parkId}');
        }
      },
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
    if (nameLower.contains('flight') || nameLower.contains('avatar') || nameLower.contains('space') || nameLower.contains('astro')) {
      return 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=200';
    }
    if (nameLower.contains('everest') || nameLower.contains('thunder') || nameLower.contains('mountain')) {
      return 'https://images.unsplash.com/photo-1513885535751-8b9238bd345a?q=80&w=200';
    }
    if (nameLower.contains('safaris') || nameLower.contains('rapid') || nameLower.contains('jungle') || nameLower.contains('river')) {
      return 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?q=80&w=200';
    }
    if (nameLower.contains('cafe') || nameLower.contains('restaurant') || nameLower.contains('grill')) {
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
    
    Color waitColor = Colors.green.shade600;
    if (isClosed) {
      waitColor = Colors.grey;
    } else if (currentWait > 50) {
      waitColor = Colors.red.shade600;
    } else if (currentWait > 20) {
      waitColor = Colors.orange.shade600;
    }

    final imageUrl = _getStaticImageUrl(facility);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 96,
        borderRadius: 16,
        blur: 15,
        alignment: Alignment.center,
        border: 1.0,
        linearGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(isDark ? 0.06 : 0.5),
            Colors.white.withOpacity(isDark ? 0.02 : 0.2),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(isDark ? 0.15 : 0.6),
            Colors.white.withOpacity(isDark ? 0.05 : 0.2),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
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
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${landName} • Thrill: ${facility.thrillLevel ?? "Low"}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white60 : Colors.black54,
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
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                (facility.heightRequirementInches ?? 0) > 0
                                    ? '${facility.heightRequirementInches}"'
                                    : 'Family',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? Colors.white38 : Colors.black38,
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
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Accessible',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? Colors.white38 : Colors.black38,
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
    if (nameLower.contains('flight') || nameLower.contains('avatar') || nameLower.contains('space') || nameLower.contains('astro')) {
      return 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=200';
    }
    if (nameLower.contains('everest') || nameLower.contains('thunder') || nameLower.contains('mountain')) {
      return 'https://images.unsplash.com/photo-1513885535751-8b9238bd345a?q=80&w=200';
    }
    if (nameLower.contains('safaris') || nameLower.contains('rapid') || nameLower.contains('jungle') || nameLower.contains('river')) {
      return 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?q=80&w=200';
    }
    if (nameLower.contains('cafe') || nameLower.contains('restaurant') || nameLower.contains('grill')) {
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
    
    Color waitColor = Colors.green.shade600;
    if (isClosed) {
      waitColor = Colors.grey;
    } else if (currentWait > 50) {
      waitColor = Colors.red.shade600;
    } else if (currentWait > 20) {
      waitColor = Colors.orange.shade600;
    }

    final trend = _getWaitTimeTrend(facility.id, currentWait);
    final imageUrl = _getStaticImageUrl(facility);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 80,
        borderRadius: 16,
        blur: 15,
        alignment: Alignment.center,
        border: isSelected ? 2.0 : 1.0,
        linearGradient: LinearGradient(
          colors: [
            isSelected 
                ? theme.colorScheme.primary.withOpacity(isDark ? 0.18 : 0.35)
                : Colors.white.withOpacity(isDark ? 0.06 : 0.5),
            Colors.white.withOpacity(isDark ? 0.02 : 0.2),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            isSelected
                ? theme.colorScheme.primary.withOpacity(0.8)
                : Colors.white.withOpacity(isDark ? 0.15 : 0.6),
            Colors.white.withOpacity(isDark ? 0.05 : 0.2),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
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
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        landName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white60 : Colors.black54,
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
    if (nameLower.contains('flight') || nameLower.contains('avatar') || nameLower.contains('space') || nameLower.contains('astro')) {
      return 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExM3h5cHF4bml1bGVwdDlwZmR5bWZkcTV4dzB5cHkyZWQzOGc1eWxtNCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/3ornk57KwDXf81rjWM/giphy.gif';
    }
    if (nameLower.contains('everest') || nameLower.contains('thunder') || nameLower.contains('mountain')) {
      return 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExOHkycHkyMTJrNDl1cmh5a2txNXZ5azUzdjVxMmtxbXF2NTh2bTRiayZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/YhW0QsO2usWQi1oXcc/giphy.gif';
    }
    if (nameLower.contains('safaris') || nameLower.contains('rapid') || nameLower.contains('jungle') || nameLower.contains('river')) {
      return 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExdDVxbzh2MTJrMjEzdjVxNmh5NXZ5MTJrMjEzdjVxNmh5NXZ5bTRiayZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/l2JJEIMrgrcSBueWs/giphy.gif';
    }
    return 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExbTRhaTFyOHlycHkyMTJrNDl1cmh5a2txNXZ5azUzdjVxMmtxbXF2NTh2bTRiayZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/3o7TKSjRrfIPjei1fG/giphy.gif';
  }

  String _getStaticImageUrl(Facility f) {
    final nameLower = f.name.toLowerCase();
    if (nameLower.contains('flight') || nameLower.contains('avatar') || nameLower.contains('space') || nameLower.contains('astro')) {
      return 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=200';
    }
    if (nameLower.contains('everest') || nameLower.contains('thunder') || nameLower.contains('mountain')) {
      return 'https://images.unsplash.com/photo-1513885535751-8b9238bd345a?q=80&w=200';
    }
    if (nameLower.contains('safaris') || nameLower.contains('rapid') || nameLower.contains('jungle') || nameLower.contains('river')) {
      return 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?q=80&w=200';
    }
    if (nameLower.contains('cafe') || nameLower.contains('restaurant') || nameLower.contains('grill')) {
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
    
    Color waitColor = Colors.green.shade600;
    if (isClosed) {
      waitColor = Colors.grey;
    } else if (currentWait > 50) {
      waitColor = Colors.red.shade600;
    } else if (currentWait > 20) {
      waitColor = Colors.orange.shade600;
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
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
          transformAlignment: Alignment.center,
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? theme.colorScheme.primary.withOpacity(isDark ? 0.15 : 0.25)
                : (_isHovered
                    ? (isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.8))
                    : (isDark ? Colors.white.withOpacity(0.03) : Colors.white.withOpacity(0.45))),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected
                  ? theme.colorScheme.primary.withOpacity(0.6)
                  : (_isHovered
                      ? (isDark ? Colors.white24 : Colors.black12)
                      : Colors.transparent),
              width: 1.5,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    )
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
                    _isHovered ? _getGIFUrl(widget.facility) : _getStaticImageUrl(widget.facility),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
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
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.landName,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
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
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
