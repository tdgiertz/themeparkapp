import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/models/park_detail.dart';
import 'package:themeparkapp/models/wait_time.dart';

/// Menu item model for restaurants.
class MenuItem {
  MenuItem({
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.dietaryTags,
  });

  final String name;
  final double price;
  final String category; // 'Entrees', 'Kids', 'Drinks'
  final String imageUrl;
  final List<String> dietaryTags; // 'Vegan', 'Gluten-Free', 'Dairy-Free', 'Vegetarian'
}

/// Detailed page for a single attraction or dining location.
class FacilityDetailPage extends ConsumerStatefulWidget {
  const FacilityDetailPage({
    required this.facilityId,
    required this.parkId,
    super.key,
  });

  final String facilityId;
  final String parkId;

  @override
  ConsumerState<FacilityDetailPage> createState() => _FacilityDetailPageState();
}

class _FacilityDetailPageState extends ConsumerState<FacilityDetailPage> with SingleTickerProviderStateMixin {
  // Virtual Queue State
  bool _isJoiningQueue = false;
  bool _joinedQueue = false;
  String? _queueGroup;
  String? _queueEstimate;

  // 360 Panorama Drag State
  double _panOffset = 0.5; // 0.0 to 1.0
  Timer? _autoPanTimer;
  bool _isUserDragging = false;
  bool _panDirectionRight = true;

  // Dietary Filters
  final Set<String> _activeDietaryFilters = {};

  // Menu items list
  final List<MenuItem> _menuItems = [
    MenuItem(
      name: 'Grizzly Giant Burger',
      price: 14.99,
      category: 'Entrees',
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=400',
      dietaryTags: ['Dairy', 'Gluten'],
    ),
    MenuItem(
      name: 'Wilderness Salad',
      price: 12.99,
      category: 'Entrees',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=400',
      dietaryTags: ['Vegan', 'Gluten-Free', 'Vegetarian'],
    ),
    MenuItem(
      name: 'Smoked Turkey Leg',
      price: 15.49,
      category: 'Entrees',
      imageUrl: 'https://images.unsplash.com/photo-1529692236671-f1f6e9473bfc?q=80&w=400',
      dietaryTags: ['Gluten-Free', 'Dairy-Free'],
    ),
    MenuItem(
      name: 'Vegan Quinoa Bowl',
      price: 13.99,
      category: 'Entrees',
      imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?q=80&w=400',
      dietaryTags: ['Vegan', 'Gluten-Free', 'Vegetarian', 'Dairy-Free'],
    ),
    MenuItem(
      name: 'Mini Mac & Cheese',
      price: 6.99,
      category: 'Kids',
      imageUrl: 'https://images.unsplash.com/photo-1543339308-43e59d6b73a6?q=80&w=400',
      dietaryTags: ['Gluten', 'Dairy', 'Vegetarian'],
    ),
    MenuItem(
      name: 'Crispy Chicken Tenders',
      price: 7.49,
      category: 'Kids',
      imageUrl: 'https://images.unsplash.com/photo-1562967914-608f82629710?q=80&w=400',
      dietaryTags: ['Gluten'],
    ),
    MenuItem(
      name: 'Fruit & Yogurt Cup',
      price: 4.99,
      category: 'Kids',
      imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?q=80&w=400',
      dietaryTags: ['Gluten-Free', 'Vegetarian', 'Dairy'],
    ),
    MenuItem(
      name: 'Fresh Squeezed Lemonade',
      price: 3.99,
      category: 'Drinks',
      imageUrl: 'https://images.unsplash.com/photo-1534723328310-e82dad3ee43f?q=80&w=400',
      dietaryTags: ['Vegan', 'Gluten-Free', 'Dairy-Free', 'Vegetarian'],
    ),
    MenuItem(
      name: 'Craft Root Beer',
      price: 4.49,
      category: 'Drinks',
      imageUrl: 'https://images.unsplash.com/photo-1532634922-8fe0b757fb13?q=80&w=400',
      dietaryTags: ['Vegan', 'Gluten-Free', 'Dairy-Free', 'Vegetarian'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPan();
  }

  @override
  void dispose() {
    _autoPanTimer?.cancel();
    super.dispose();
  }

  void _startAutoPan() {
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) return;
    _autoPanTimer?.cancel();
    _autoPanTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!_isUserDragging) {
        setState(() {
          if (_panDirectionRight) {
            _panOffset += 0.001;
            if (_panOffset >= 0.8) {
              _panDirectionRight = false;
            }
          } else {
            _panOffset -= 0.001;
            if (_panOffset <= 0.2) {
              _panDirectionRight = true;
            }
          }
        });
      }
    });
  }

  void _joinVirtualQueueFlow() {
    setState(() {
      _isJoiningQueue = true;
    });
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isJoiningQueue = false;
          _joinedQueue = true;
          _queueGroup = 'Group ${math.Random().nextInt(10) + 12}';
          _queueEstimate = '${math.Random().nextInt(30) + 30} min';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully joined Virtual Queue for $_queueGroup!'),
            backgroundColor: Colors.teal,
          ),
        );
      }
    });
  }

  void _simulateNavigation() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.navigation, color: Colors.teal),
            SizedBox(width: 8),
            Text('Navigate Here'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Simulating GPS route optimization. Walk north towards Adventureland.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.explore, size: 40, color: Colors.teal),
                    SizedBox(height: 8),
                    Text(
                      'Distance: 120 yards • 2 min walk',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  bool _isItemCompliant(MenuItem item) {
    if (_activeDietaryFilters.isEmpty) return true;
    for (final filter in _activeDietaryFilters) {
      if (filter == 'Gluten-Free' && !item.dietaryTags.contains('Gluten-Free')) return false;
      if (filter == 'Vegan' && !item.dietaryTags.contains('Vegan')) return false;
      if (filter == 'Dairy-Free' && !item.dietaryTags.contains('Dairy-Free')) return false;
      if (filter == 'Vegetarian' &&
          !item.dietaryTags.contains('Vegetarian') &&
          !item.dietaryTags.contains('Vegan')) {
        return false;
      }
    }
    return true;
  }

  void _toggleDietaryFilter(String filter) {
    setState(() {
      if (_activeDietaryFilters.contains(filter)) {
        _activeDietaryFilters.remove(filter);
      } else {
        _activeDietaryFilters.add(filter);
      }
    });
  }

  Widget _buildImage(String url, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey.shade300,
        child: const Center(child: Icon(Icons.image, color: Colors.grey, size: 16)),
      );
    }
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(parkDetailProvider(widget.parkId));
    final waitsAsync = ref.watch(waitTimesProvider(widget.parkId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: detailAsync.when(
        data: (detail) {
          // Find the facility
          Facility? facility;
          for (final land in detail.children) {
            for (final f in land.children) {
              if (f.id == widget.facilityId) {
                facility = f;
                break;
              }
            }
          }

          if (facility == null) {
            return const Center(child: Text('Facility not found.'));
          }

          // Get wait time
          WaitTime? wait;
          if (waitsAsync.hasValue) {
            final waits = waitsAsync.value!.waitTimes;
            final matched = waits.where((w) => w.rideId == facility!.id);
            if (matched.isNotEmpty) {
              wait = matched.first;
            }
          }

          final isDining = facility.name.toLowerCase().contains(
                RegExp(
                  'cafe|restaurant|grill|dining|eats|table|bakery|kitchen|tavern|food|pub|vine|palace',
                ),
              );

          return ScreenTypeLayout.builder(
            mobile: (context) => _buildMobileLayout(facility!, wait, isDining, theme, isDark),
            desktop: (context) => _buildDesktopLayout(facility!, wait, isDining, theme, isDark),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }

  // --- MOBILE LAYOUT ---
  Widget _buildMobileLayout(
    Facility facility,
    WaitTime? wait,
    bool isDining,
    ThemeData theme,
    bool isDark,
  ) {
    final staticImage = isDining
        ? 'https://images.unsplash.com/photo-1544025162-d76694265947?q=80&w=800'
        : 'https://images.unsplash.com/photo-1513885535751-8b9238bd345a?q=80&w=800';

    return Scaffold(
      bottomNavigationBar: _buildMobileStickyCTA(facility, isDining, theme, isDark),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: theme.colorScheme.surface,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  facility.name,
                  style: TextStyle(
                    color: innerBoxIsScrolled
                        ? theme.colorScheme.onSurface
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: innerBoxIsScrolled
                        ? null
                        : [
                            Shadow(
                              blurRadius: 8,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImage(
                      staticImage,
                    ),
                    Container(
                          decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.colorScheme.onSurface.withValues(alpha: 0.38),
                            Colors.transparent,
                            theme.colorScheme.onSurface.withValues(alpha: 0.54),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickInfoRow(facility, wait, theme, isDark),
              const Divider(height: 32),
              if (!isDining) ...[
                Text(
                  'Wait Time Analysis',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Make a go/no-go decision based on live and predicted trends.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: InteractiveWaitTimeChart(facilityId: facility.id),
                        ),
                        const SizedBox(height: 8),
                        _buildChartLegend(theme),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                _buildDietaryFilterSwitches(theme, isDark),
                const SizedBox(height: 16),
                _buildVisualMenuSections(theme, isDark),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- DESKTOP LAYOUT ---
  Widget _buildDesktopLayout(
    Facility facility,
    WaitTime? wait,
    bool isDining,
    ThemeData theme,
    bool isDark,
  ) {
    final panoramaImage = isDining
        ? 'https://images.unsplash.com/photo-1544025162-d76694265947?q=80&w=2000'
        : 'https://images.unsplash.com/photo-1513885535751-8b9238bd345a?q=80&w=2000';

    return Scaffold(
      appBar: AppBar(
        title: Text(facility.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: 360 Tour & Wait Chart / Menu
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 360 Panorama View
                  Text(
                    'Interactive 360° Preview Tour',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Drag left or right to explore the location.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: GestureDetector(
                      onHorizontalDragStart: (_) => _isUserDragging = true,
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          _panOffset = (_panOffset - details.primaryDelta! / 500).clamp(0.0, 1.0);
                        });
                      },
                      onHorizontalDragEnd: (_) {
                        _isUserDragging = false;
                        _startAutoPan();
                      },
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: FractionallySizedBox(
                              widthFactor: 2.5,
                              alignment: Alignment((_panOffset * 2.0) - 1.0, 0),
                              child: _buildImage(
                                panoramaImage,
                              ),
                            ),
                          ),
                          // Dark Overlay for text legibility
                          Container(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                          ),
                          // Compass UI Overlay
                          Positioned(
                            top: 16,
                            right: 16,
                            child: GlassmorphicContainer(
                              width: 60,
                              height: 60,
                              borderRadius: 30,
                              blur: 8,
                              alignment: Alignment.center,
                              border: 1,
                              linearGradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.2),
                                  Colors.white.withValues(alpha: 0.05),
                                ],
                              ),
                              borderGradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.4),
                                  Colors.white.withValues(alpha: 0.1),
                                ],
                              ),
                              child: Transform.rotate(
                                angle: _panOffset * 2.0 * math.pi,
                                child: const Icon(
                                  Icons.explore,
                                  color: Colors.tealAccent,
                                  size: 36,
                                ),
                              ),
                            ),
                          ),
                          // Overlay Tip
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: Card(
                              color: theme.cardColor,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: Row(
                                  children: [
                                    Icon(
                                      _isUserDragging ? Icons.pan_tool : Icons.swap_horizontal_circle_outlined,
                                      color: Colors.tealAccent,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isUserDragging ? 'Exploring...' : 'Drag Panorama to Look Around',
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (!isDining) ...[
                    Text(
                      'Wait Time Analytics',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 260,
                              child: InteractiveWaitTimeChart(facilityId: facility.id),
                            ),
                            const SizedBox(height: 12),
                            _buildChartLegend(theme),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    _buildDietaryFilterSwitches(theme, isDark),
                    const SizedBox(height: 16),
                    _buildVisualMenuSections(theme, isDark),
                  ],
                ],
              ),
            ),
          ),
          
          // Vertical Divider
          const VerticalDivider(width: 1, thickness: 1),

          // Right Side: Quick Info Card & Call To Actions (Sticky Sidebar)
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildQuickInfoRow(facility, wait, theme, isDark),
                          const Divider(height: 32),
                          const Text(
                            'Quick Actions',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          _buildDesktopStickyCTA(facility, isDining, theme, isDark),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- STICKY MOBILE CTA BAR ---
  Widget _buildMobileStickyCTA(
    Facility facility,
    bool isDining,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_joinedQueue)
              Card(
                color: Colors.teal.withValues(alpha: 0.15),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Virtual Queue: $_queueGroup',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                      Text(
                        'Est. Entry: $_queueEstimate',
                        style: const TextStyle(color: Colors.teal),
                      ),
                    ],
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: _isJoiningQueue
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.confirmation_num),
                    label: Text(
                      _joinedQueue ? 'Queue Joined' : 'Join Virtual Queue',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _joinedQueue || _isJoiningQueue ? null : _joinVirtualQueueFlow,
                  ),
                ),
                const SizedBox(width: 12),
                if (isDining)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.restaurant_menu),
                    label: const Text('Order Food'),
                    onPressed: () {
                      // Scroll to menu in mobile
                    },
                  )
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onSecondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _simulateNavigation,
                    child: const Icon(Icons.navigation),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- STICKY DESKTOP CTA PANEL ---
  Widget _buildDesktopStickyCTA(
    Facility facility,
    bool isDining,
    ThemeData theme,
    bool isDark,
  ) {
    return Column(
      children: [
        if (_joinedQueue) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Queue: $_queueGroup',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                Text(
                  'Est. Entry: $_queueEstimate',
                  style: const TextStyle(color: Colors.teal),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: _isJoiningQueue
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.confirmation_num),
            label: Text(
              _joinedQueue ? 'Queue Joined' : 'Join Virtual Queue',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            onPressed: _joinedQueue || _isJoiningQueue ? null : _joinVirtualQueueFlow,
          ),
        ),
        const SizedBox(height: 12),
        if (isDining)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Mobile Order Food'),
              onPressed: () {
                // Order Food simulation
              },
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.navigation),
              label: const Text('Navigate Here'),
              onPressed: _simulateNavigation,
            ),
          ),
      ],
    );
  }

  // --- QUICK INFO ROW ---
  Widget _buildQuickInfoRow(
    Facility facility,
    WaitTime? wait,
    ThemeData theme,
    bool isDark,
  ) {
    final isClosed = wait == null || wait.status != 'Open';
    final waitMinutes = wait?.waitMinutes ?? 0;
    final waitColor = isClosed
        ? Colors.grey
        : waitMinutes <= 20
            ? Colors.green.shade600
            : waitMinutes <= 50
                ? Colors.orange.shade600
                : Colors.red.shade600;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                facility.category,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.bolt, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Thrill: ${facility.thrillLevel ?? "Low"}',
                      style: theme.textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (facility.heightRequirementInches != null &&
                  facility.heightRequirementInches! > 0) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.height, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Min Height: ${facility.heightRequirementInches}"',
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: waitColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: waitColor.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Column(
            children: [
              Text(
                isClosed ? 'CLOSED' : '$waitMinutes MIN',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: waitColor,
                ),
              ),
              Text(
                'Wait Time',
                style: TextStyle(
                  fontSize: 10,
                  color: waitColor.withValues(alpha: 0.8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- DIETARY FILTERS SWITCHES ---
  Widget _buildDietaryFilterSwitches(ThemeData theme, bool isDark) {
    final filters = ['Gluten-Free', 'Vegan', 'Dairy-Free', 'Vegetarian'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dietary Preferences',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Instantly fade out menu items that contain allergens.',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filters.map((filter) {
            final active = _activeDietaryFilters.contains(filter);
            return FilterChip(
              label: Text(filter),
              selected: active,
              selectedColor: Colors.teal.withValues(alpha: 0.2),
              checkmarkColor: Colors.teal,
              onSelected: (_) => _toggleDietaryFilter(filter),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- VISUAL MENU SECTIONS ---
  Widget _buildVisualMenuSections(ThemeData theme, bool isDark) {
    final categories = ['Entrees', 'Kids', 'Drinks'];

    return Column(
      children: categories.map((cat) {
        final items = _menuItems.where((i) => i.category == cat).toList();
        if (items.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                cat,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final compliant = _isItemCompliant(item);

                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: compliant ? 1.0 : 0.12,
                    child: Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 16),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             _buildImage(
                               item.imageUrl,
                               height: 100,
                               width: double.infinity,
                             ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    const Spacer(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '\$${item.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: Colors.teal,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (item.dietaryTags.contains('Vegan'))
                                          const Icon(Icons.eco, color: Colors.green, size: 16)
                                        else if (item.dietaryTags.contains('Gluten-Free'))
                                          const Icon(Icons.grass, color: Colors.orange, size: 16),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // --- CHART LEGEND ---
  Widget _buildChartLegend(ThemeData theme) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        _legendItem("Today's Wait", Colors.teal, isDotted: false),
        _legendItem('Historical Avg', Colors.blueGrey.withValues(alpha: 0.5), isDotted: true),
        _legendItem('Predictive Wait', Colors.orange, isDotted: true),
      ],
    );
  }

  Widget _legendItem(String label, Color color, {required bool isDotted}) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: isDotted ? null : color,
            borderRadius: BorderRadius.circular(1.5),
          ),
          child: isDotted
              ? Row(
                  children: List.generate(
                    4,
                    (_) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        height: 3,
                        color: color,
                      ),
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

// --- INTERACTIVE WAIT TIME AREA CHART ---
class InteractiveWaitTimeChart extends StatefulWidget {
  const InteractiveWaitTimeChart({required this.facilityId, super.key});
  final String facilityId;

  @override
  State<InteractiveWaitTimeChart> createState() => _InteractiveWaitTimeChartState();
}

class _InteractiveWaitTimeChartState extends State<InteractiveWaitTimeChart> {
  int? _hoveredIndex;

  // Wait time data arrays (X values: 0 to 12 representing 9 AM to 9 PM)
  final List<String> hoursLabels = [
    '9 AM', '10 AM', '11 AM', '12 PM', '1 PM', '2 PM', '3 PM', '4 PM', '5 PM', '6 PM', '7 PM', '8 PM', '9 PM'
  ];

  // Raw mock datasets
  final List<int> actualWaits = [30, 45, 55, 75, 70, 85, 80]; // up to 3 PM
  final List<int> historicalWaits = [25, 35, 50, 65, 60, 70, 75, 70, 60, 55, 45, 35, 20];
  final List<int> predictiveWaits = [75, 65, 50, 40, 30, 15]; // starts at 4 PM (index 7)

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanStart: (details) => _updateHoverIndex(details.localPosition, constraints.maxWidth),
          onPanUpdate: (details) => _updateHoverIndex(details.localPosition, constraints.maxWidth),
          onPanEnd: (_) => setState(() => _hoveredIndex = null),
          child: Stack(
            children: [
              CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _WaitTimePainter(
                  actualWaits: actualWaits,
                  historicalWaits: historicalWaits,
                  predictiveWaits: predictiveWaits,
                  hoveredIndex: _hoveredIndex,
                ),
              ),
              if (_hoveredIndex != null) _buildTooltip(constraints),
            ],
          ),
        );
      },
    );
  }

  void _updateHoverIndex(Offset localPosition, double totalWidth) {
    const margin = 24.0;
    final chartWidth = totalWidth - (margin * 2);
    final xRatio = (localPosition.dx - margin) / chartWidth;
    final rawIndex = (xRatio * 12).round();
    final index = rawIndex.clamp(0, 12);
    if (_hoveredIndex != index) {
      setState(() {
        _hoveredIndex = index;
      });
    }
  }

  Widget _buildTooltip(BoxConstraints constraints) {
    const margin = 24.0;
    final chartWidth = constraints.maxWidth - (margin * 2);
    final index = _hoveredIndex!;
    final xPos = margin + (index * (chartWidth / 12));

    final hour = hoursLabels[index];
    final historical = historicalWaits[index];
    
    int? currentActual;
    int? currentPredicted;
    if (index < actualWaits.length) {
      currentActual = actualWaits[index];
    } else {
      currentPredicted = predictiveWaits[index - actualWaits.length];
    }

    return Positioned(
      left: xPos > constraints.maxWidth - 120 ? xPos - 125 : xPos + 5,
      top: 10,
      child: GlassmorphicContainer(
        width: 120,
        height: 80,
        borderRadius: 8,
        blur: 10,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                hour,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.tealAccent, fontSize: 11),
              ),
              const SizedBox(height: 4),
              if (currentActual != null)
                Text(
                  'Wait: $currentActual min',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              if (currentPredicted != null)
                Text(
                  'Predict: $currentPredicted min',
                  style: const TextStyle(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              Text(
                'Historical: $historical min',
                style: const TextStyle(color: Colors.white70, fontSize: 9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WAIT TIME CUSTOM PAINTER ---
class _WaitTimePainter extends CustomPainter {
  _WaitTimePainter({
    required this.actualWaits,
    required this.historicalWaits,
    required this.predictiveWaits,
    this.hoveredIndex,
  });

  final List<int> actualWaits;
  final List<int> historicalWaits;
  final List<int> predictiveWaits;
  final int? hoveredIndex;

  @override
  void paint(Canvas canvas, Size size) {
    const margin = 24.0;
    final chartWidth = size.width - (margin * 2);
    final chartHeight = size.height - 40;

    const maxWait = 120.0;

    // Helper functions to translate coordinate points
    double getX(int index) => margin + (index * (chartWidth / 12));
    double getY(int wait) => size.height - 20 - ((wait / maxWait) * chartHeight).clamp(0.0, chartHeight);

    // 1. Draw Grid Lines and Labels
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..strokeWidth = 1.0;
    
    final textStyle = TextStyle(color: Colors.grey.shade500, fontSize: 9);

    for (var waitVal = 30; waitVal <= 120; waitVal += 30) {
      final y = getY(waitVal);
      canvas.drawLine(Offset(margin, y), Offset(size.width - margin, y), gridPaint);
      
      final textPainter = TextPainter(
        text: TextSpan(text: '${waitVal}m', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(4, y - (textPainter.height / 2)));
    }

    // Draw bottom X line
    canvas.drawLine(Offset(margin, size.height - 20), Offset(size.width - margin, size.height - 20), gridPaint);

    // Draw X line labels
    final hoursLabels = ['9a', '12p', '3p', '6p', '9p'];
    final hourIndices = [0, 3, 6, 9, 12];
    for (var i = 0; i < hourIndices.length; i++) {
      final idx = hourIndices[i];
      final label = hoursLabels[i];
      final x = getX(idx);
      
      final textPainter = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(x - (textPainter.width / 2), size.height - 18));
    }

    // 2. Draw Historical Average Line (Dashed, Faded Blue-Grey)
    final histPaint = Paint()
      ..color = Colors.blueGrey.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final histPath = Path()..moveTo(getX(0), getY(historicalWaits[0]));
    for (var i = 1; i < historicalWaits.length; i++) {
      histPath.lineTo(getX(i), getY(historicalWaits[i]));
    }
    _drawDashedPath(canvas, histPath, histPaint, dashLength: 6, gapLength: 4);

    // 3. Draw Today's Actual Area & Line (Solid Teal)
    if (actualWaits.isNotEmpty) {
      final actualPath = Path()..moveTo(getX(0), getY(actualWaits[0]));
      for (var i = 1; i < actualWaits.length; i++) {
        actualPath.lineTo(getX(i), getY(actualWaits[i]));
      }

      // Draw Gradient Fill Area
      final areaPath = Path()
        ..moveTo(getX(0), size.height - 20)
        ..lineTo(getX(0), getY(actualWaits[0]));
      for (var i = 1; i < actualWaits.length; i++) {
        areaPath.lineTo(getX(i), getY(actualWaits[i]));
      }
      areaPath
        ..lineTo(getX(actualWaits.length - 1), size.height - 20)
        ..close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.teal.withValues(alpha: 0.35),
            Colors.teal.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTRB(margin, getY(120), size.width - margin, size.height - 20))
        ..style = PaintingStyle.fill;

      canvas.drawPath(areaPath, fillPaint);

      // Draw stroke
      final actualStrokePaint = Paint()
        ..color = Colors.teal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(actualPath, actualStrokePaint);
    }

    // 4. Draw Predictive Wait Times Line (Dashed Orange)
    if (predictiveWaits.isNotEmpty && actualWaits.isNotEmpty) {
      final predictPaint = Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;

      final predictPath = Path()
        ..moveTo(getX(actualWaits.length - 1), getY(actualWaits.last)); // Connect to last actual
      for (var i = 0; i < predictiveWaits.length; i++) {
        predictPath.lineTo(getX(actualWaits.length + i), getY(predictiveWaits[i]));
      }
      _drawDashedPath(canvas, predictPath, predictPaint, dashLength: 4, gapLength: 3);
    }

    // 5. Draw Interactive Hover/Hovered Marker
    if (hoveredIndex != null) {
      final index = hoveredIndex!;
      final x = getX(index);
      
      // Draw vertical indicator line
      final hoverLinePaint = Paint()
        ..color = Colors.tealAccent.withValues(alpha: 0.5)
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(x, 10), Offset(x, size.height - 20), hoverLinePaint);

      // Draw intersection dots
      final dotPaint = Paint()..style = PaintingStyle.fill;

      // Historical average dot
      final histY = getY(historicalWaits[index]);
      canvas.drawCircle(Offset(x, histY), 4, dotPaint..color = Colors.blueGrey);

      // Today's/Predictive dot
      if (index < actualWaits.length) {
        final actY = getY(actualWaits[index]);
        canvas.drawCircle(Offset(x, actY), 6, dotPaint..color = Colors.teal);
        canvas.drawCircle(Offset(x, actY), 4, Paint()..color = Colors.white);
      } else {
        final predY = getY(predictiveWaits[index - actualWaits.length]);
        canvas.drawCircle(Offset(x, predY), 6, dotPaint..color = Colors.orange);
        canvas.drawCircle(Offset(x, predY), 4, Paint()..color = Colors.white);
      }
    }
  }

  // Dashed path helper using path metrics
  void _drawDashedPath(Canvas canvas, Path path, Paint paint, {required double dashLength, required double gapLength}) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final nextDistance = distance + dashLength;
        final extract = metric.extractPath(distance, nextDistance.clamp(0.0, metric.length));
        canvas.drawPath(extract, paint);
        distance = nextDistance + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WaitTimePainter oldDelegate) {
    return oldDelegate.hoveredIndex != hoveredIndex;
  }
}
