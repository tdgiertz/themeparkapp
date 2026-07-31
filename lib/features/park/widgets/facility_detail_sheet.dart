import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:themeparkapp/models/park_detail.dart';
import 'package:themeparkapp/models/wait_time.dart';
import 'package:themeparkapp/features/park/widgets/area_chart.dart';
import 'package:themeparkapp/features/park/widgets/pulse_dot.dart';

// Reusing MenuItem class structure from facility_detail_page.dart
class LocalMenuItem {
  LocalMenuItem({
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.dietaryTags,
  });

  final String name;
  final double price;
  final String category;
  final String imageUrl;
  final List<String> dietaryTags;
}

class FacilityDetailSheetContent extends ConsumerStatefulWidget {
  const FacilityDetailSheetContent({
    required this.facility,
    required this.wait,
    required this.parkId,
    this.onClose,
    super.key,
  });

  final Facility facility;
  final WaitTime? wait;
  final String parkId;
  final VoidCallback? onClose;

  @override
  ConsumerState<FacilityDetailSheetContent> createState() => _FacilityDetailSheetContentState();
}

class _FacilityDetailSheetContentState extends ConsumerState<FacilityDetailSheetContent> {
  // Virtual Queue State
  bool _isJoiningQueue = false;
  bool _joinedQueue = false;
  String? _queueGroup;
  String? _queueEstimate;

  // Dietary Filters
  final Set<String> _activeDietaryFilters = {};

  final List<LocalMenuItem> _menuItems = [
    LocalMenuItem(
      name: 'Grizzly Giant Burger',
      price: 14.99,
      category: 'Entrees',
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=400',
      dietaryTags: ['Dairy', 'Gluten'],
    ),
    LocalMenuItem(
      name: 'Wilderness Salad',
      price: 12.99,
      category: 'Entrees',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=400',
      dietaryTags: ['Vegan', 'Gluten-Free', 'Vegetarian'],
    ),
    LocalMenuItem(
      name: 'Smoked Turkey Leg',
      price: 15.49,
      category: 'Entrees',
      imageUrl: 'https://images.unsplash.com/photo-1529692236671-f1f6e9473bfc?q=80&w=400',
      dietaryTags: ['Gluten-Free', 'Dairy-Free'],
    ),
    LocalMenuItem(
      name: 'Vegan Quinoa Bowl',
      price: 13.99,
      category: 'Entrees',
      imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?q=80&w=400',
      dietaryTags: ['Vegan', 'Gluten-Free', 'Vegetarian', 'Dairy-Free'],
    ),
    LocalMenuItem(
      name: 'Mini Mac & Cheese',
      price: 6.99,
      category: 'Kids',
      imageUrl: 'https://images.unsplash.com/photo-1543339308-43e59d6b73a6?q=80&w=400',
      dietaryTags: ['Gluten', 'Dairy', 'Vegetarian'],
    ),
    LocalMenuItem(
      name: 'Crispy Chicken Tenders',
      price: 7.49,
      category: 'Kids',
      imageUrl: 'https://images.unsplash.com/photo-1562967914-608f82629710?q=80&w=400',
      dietaryTags: ['Gluten'],
    ),
    LocalMenuItem(
      name: 'Fruit & Yogurt Cup',
      price: 4.99,
      category: 'Kids',
      imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?q=80&w=400',
      dietaryTags: ['Gluten-Free', 'Vegetarian', 'Dairy'],
    ),
    LocalMenuItem(
      name: 'Fresh Squeezed Lemonade',
      price: 3.99,
      category: 'Drinks',
      imageUrl: 'https://images.unsplash.com/photo-1534723328310-e82dad3ee43f?q=80&w=400',
      dietaryTags: ['Vegan', 'Gluten-Free', 'Dairy-Free', 'Vegetarian'],
    ),
    LocalMenuItem(
      name: 'Craft Root Beer',
      price: 4.49,
      category: 'Drinks',
      imageUrl: 'https://images.unsplash.com/photo-1532634922-8fe0b757fb13?q=80&w=400',
      dietaryTags: ['Vegan', 'Gluten-Free', 'Dairy-Free', 'Vegetarian'],
    ),
  ];

  String _getFacilityImageUrl(Facility f) {
    final nameLower = f.name.toLowerCase();
    if (nameLower.contains('flight') || nameLower.contains('avatar') || nameLower.contains('space') || nameLower.contains('astro')) {
      return 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=400';
    }
    if (nameLower.contains('everest') || nameLower.contains('thunder') || nameLower.contains('mountain')) {
      return 'https://images.unsplash.com/photo-1513885535751-8b9238bd345a?q=80&w=400';
    }
    if (nameLower.contains('safaris') || nameLower.contains('rapid') || nameLower.contains('jungle') || nameLower.contains('river')) {
      return 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?q=80&w=400';
    }
    if (nameLower.contains('cafe') || nameLower.contains('restaurant') || nameLower.contains('grill')) {
      return 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=400';
    }
    return 'https://images.unsplash.com/photo-1603048588665-791ca8aea617?q=80&w=400';
  }

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
            content: Text('Successfully joined Virtual Queue for ${_queueGroup}!'),
            backgroundColor: Colors.teal,
          ),
        );
      }
    });
  }

  bool _isItemCompliant(LocalMenuItem item) {
    if (_activeDietaryFilters.isEmpty) return true;
    for (final filter in _activeDietaryFilters) {
      if (filter == 'Gluten-Free' && !item.dietaryTags.contains('Gluten-Free')) return false;
      if (filter == 'Vegan' && !item.dietaryTags.contains('Vegan')) return false;
      if (filter == 'Dairy-Free' && !item.dietaryTags.contains('Dairy-Free')) return false;
      if (filter == 'Vegetarian' &&
          !item.dietaryTags.contains('Vegetarian') &&
          !item.dietaryTags.contains('Vegan')) return false;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final isClosed = widget.wait == null || widget.wait!.status != 'Open';
    final currentWait = widget.wait?.waitMinutes ?? 0;
    final waitText = isClosed ? 'Closed' : '${currentWait}m';
    
    Color waitColor = Colors.green.shade600;
    if (isClosed) {
      waitColor = Colors.grey;
    } else if (currentWait > 50) {
      waitColor = Colors.red.shade600;
    } else if (currentWait > 20) {
      waitColor = Colors.orange.shade600;
    }

    final isDining = widget.facility.name.toLowerCase().contains(
          RegExp('cafe|restaurant|grill|dining|eats|table|bakery|kitchen|tavern|food|pub|vine|palace'),
        );

    final imageUrl = _getFacilityImageUrl(widget.facility);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E281F) : const Color(0xFFF4F7F4),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header details
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        imageUrl,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 90,
                          height: 90,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image, size: 40, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Texts
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.facility.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.facility.category,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.facility.thrillLevel != null
                                      ? 'Thrill: ${widget.facility.thrillLevel}'
                                      : 'Relaxing ride',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (widget.facility.heightRequirementInches != null && widget.facility.heightRequirementInches! > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.height, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  'Min Height: ${widget.facility.heightRequirementInches}"',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Close button spacer if close button is rendered in stack
                    const SizedBox(width: 36),
                  ],
                ),
                
                const Divider(height: 32),
                
                // Content based on ride vs dining
                if (isDining) ...[
                  // Dining Menu Section
                  Text(
                    'Dining Menu',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  
                  // Dietary Filters
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: ['Vegan', 'Vegetarian', 'Gluten-Free', 'Dairy-Free'].map((filter) {
                      final active = _activeDietaryFilters.contains(filter);
                      return FilterChip(
                        label: Text(filter, style: TextStyle(fontSize: 12, color: active ? Colors.white : null)),
                        selected: active,
                        onSelected: (_) => _toggleDietaryFilter(filter),
                        selectedColor: theme.colorScheme.primary,
                        checkmarkColor: Colors.white,
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Menu Items
                  ...['Entrees', 'Kids', 'Drinks'].map((cat) {
                    final items = _menuItems
                        .where((i) => i.category == cat && _isItemCompliant(i))
                        .toList();
                    if (items.isEmpty) return const SizedBox.shrink();
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            cat,
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                          ),
                        ),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, idx) {
                            final item = items[idx];
                            return Card(
                              elevation: 0,
                              color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        item.imageUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            item.dietaryTags.join(', '),
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '\$${item.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }),
                ] else ...[
                  // Ride Section: Virtual Queue & Wait Time Chart
                  
                  // Wait Time & Glowing Pulse Dot Indicator
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: waitColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: waitColor.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PulseDot(color: waitColor, size: 8),
                            const SizedBox(width: 8),
                            Text(
                              isClosed ? 'Closed' : 'Wait Time: $waitText',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: waitColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Virtual Queue Card
                  Card(
                    elevation: 0,
                    color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.confirmation_num_outlined, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Virtual Queue',
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (!_joinedQueue) ...[
                            Text(
                              'Skip the standby line by joining the virtual queue. Standby lines can be extremely long during peak hours.',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isJoiningQueue ? null : _joinVirtualQueueFlow,
                                icon: _isJoiningQueue
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.group_add),
                                label: Text(_isJoiningQueue ? 'Joining...' : 'Join Virtual Queue'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.teal.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.teal.withOpacity(0.4)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.teal),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Assigned: $_queueGroup',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Estimated Return: $_queueEstimate',
                                          style: const TextStyle(fontSize: 12, color: Colors.teal),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Wait Time Area Chart
                  Text(
                    'Historical Wait Times',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Average queues over the last 3 hours',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  
                  Card(
                    elevation: 0,
                    color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: AreaChartWidget(
                        data: _getWaitTimeTrend(widget.facility.id, currentWait),
                        lineColor: waitColor,
                        height: 140,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Close button at top right
          if (widget.onClose != null)
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(isDark ? 0.38 : 0.54),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 20),
                ),
                onPressed: widget.onClose,
              ),
            ),
        ],
      ),
    );
  }
}
