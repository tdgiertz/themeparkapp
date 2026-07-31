import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:themeparkapp/features/park/park_explorer_state.dart';
import 'package:themeparkapp/features/search/search_state.dart';
import 'package:themeparkapp/models/park_detail.dart';

/// Interactive AI Assistant Search Dashboard Page.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();

  // Voice simulation state
  bool _showVoiceOverlay = false;
  String _voiceStatusText = 'Listening...';
  late AnimationController _waveController;
  Timer? _voiceTimer;

  // Selected restaurant filter
  final Set<String> _activeDietaryFilters = {};
  final List<Map<String, dynamic>> _mockMenuItems = [
    {
      'name': 'Grizzly Giant Burger',
      'price': 14.99,
      'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=200',
      'dietaryTags': ['Dairy', 'Gluten'],
    },
    {
      'name': 'Wilderness Salad',
      'price': 12.99,
      'imageUrl': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=200',
      'dietaryTags': ['Vegan', 'Gluten-Free', 'Vegetarian'],
    },
    {
      'name': 'Smoked Turkey Leg',
      'price': 15.49,
      'imageUrl': 'https://images.unsplash.com/photo-1529692236671-f1f6e9473bfc?q=80&w=200',
      'dietaryTags': ['Gluten-Free', 'Dairy-Free'],
    },
    {
      'name': 'Vegan Quinoa Bowl',
      'price': 13.99,
      'imageUrl': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?q=80&w=200',
      'dietaryTags': ['Vegan', 'Gluten-Free', 'Vegetarian', 'Dairy-Free'],
    },
    {
      'name': 'Fresh Squeezed Lemonade',
      'price': 3.99,
      'imageUrl': 'https://images.unsplash.com/photo-1534723328310-e82dad3ee43f?q=80&w=200',
      'dietaryTags': ['Vegan', 'Gluten-Free', 'Dairy-Free', 'Vegetarian'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    
    // Auto-focus input on Desktop for keyboard priority
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && MediaQuery.of(context).size.width > 1024) {
        _inputFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _chatScrollController.dispose();
    _inputFocusNode.dispose();
    _waveController.dispose();
    _voiceTimer?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _submitText(String text) {
    if (text.trim().isEmpty) return;
    ref.read(searchProvider.notifier).submitQuery(text);
    _textController.clear();
    _scrollToBottom();
    // Keep focus on desktop
    if (MediaQuery.of(context).size.width > 1024) {
      _inputFocusNode.requestFocus();
    }
  }

  void _startVoiceInput() {
    setState(() {
      _showVoiceOverlay = true;
      _voiceStatusText = 'Listening...';
    });
    ref.read(searchProvider.notifier).setListening(true);

    final queries = [
      'Where is the nearest pretzel?',
      'Help me plan my day at Magic Kingdom',
      'Suggest dining near me',
      'High thrill rides in Animal Kingdom'
    ];
    final selectedQuery = queries[math.Random().nextInt(queries.length)];

    // Simulate voice dictation stages
    _voiceTimer?.cancel();
    _voiceTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _voiceStatusText = '"$selectedQuery"';
        });
      }
      _voiceTimer = Timer(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _showVoiceOverlay = false;
          });
          ref.read(searchProvider.notifier).setListening(false);
          _submitText(selectedQuery);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Travel Agent (Search)'),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Clear Conversation',
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              ref.invalidate(searchProvider);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          ScreenTypeLayout.builder(
            mobile: (context) => _buildMobileLayout(searchState),
            tablet: (context) => _buildDesktopLayout(searchState, isTablet: true),
            desktop: (context) => _buildDesktopLayout(searchState, isTablet: false),
          ),
          if (_showVoiceOverlay) _buildVoiceOverlayWidget(),
        ],
      ),
    );
  }

  // --- MOBILE LAYOUT ---
  Widget _buildMobileLayout(SearchState state) {
    final userPos = ref.watch(userLocationProvider('p2')); // magic kingdom coords for mock
    return Column(
      children: [
        // Chat messages thread
        Expanded(
          child: ListView.builder(
            controller: _chatScrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: state.messages.length,
            itemBuilder: (context, index) {
              final msg = state.messages[index];
              return _buildChatMessageItem(msg, isMobile: true);
            },
          ),
        ),

        // GPS Ping status indicator
        Container(
          width: double.infinity,
          color: Colors.blue.withOpacity(0.08),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.gps_fixed, size: 14, color: Colors.blueAccent),
              const SizedBox(width: 6),
              Text(
                'Live Location: ${userPos.latitude.toStringAsFixed(4)}, ${userPos.longitude.toStringAsFixed(4)}',
                style: const TextStyle(fontSize: 11, color: Colors.blueAccent, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // Text / Voice Input area
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.5))),
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Voice button
                GestureDetector(
                  onTap: _startVoiceInput,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.teal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mic, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                // Text Field
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type complex query or plan...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: _submitText,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),
                  onPressed: () => _submitText(_textController.text),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- DESKTOP LAYOUT (3 Panes) ---
  Widget _buildDesktopLayout(SearchState state, {required bool isTablet}) {
    return Row(
      children: [
        // Pane 1: Chat Pane (Width: 320 to 380px)
        Container(
          width: isTablet ? 300 : 380,
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Column(
            children: [
              // Chat Header
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline, color: Colors.teal),
                    const SizedBox(width: 8),
                    Text('Chat History & Thread', style: Theme.of(context).textTheme.titleSmall),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Message List
              Expanded(
                child: ListView.builder(
                  controller: _chatScrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final msg = state.messages[index];
                    return _buildChatMessageItem(msg, isMobile: false);
                  },
                ),
              ),
              // Keyboard Priority Input
              Container(
                padding: const EdgeInsets.all(12),
                color: Theme.of(context).cardColor,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            focusNode: _inputFocusNode,
                            decoration: InputDecoration(
                              hintText: 'Press Enter to ask travel agent...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.mic, color: Colors.teal),
                                tooltip: 'Simulate Voice Input',
                                onPressed: _startVoiceInput,
                              ),
                            ),
                            onSubmitted: _submitText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Keyboard priority: Type query and press Enter to search.',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Pane 2: Active Interactive Widgets
        Expanded(
          flex: 3,
          child: Container(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade900
                : Colors.grey.shade50,
            child: _buildActiveWidgetsPane(state),
          ),
        ),

        // Pane 3: Map
        Expanded(
          flex: 4,
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: _buildMapPane(state),
          ),
        ),
      ],
    );
  }

  // --- CHAT MESSAGE BUBBLE WIDGET ---
  Widget _buildChatMessageItem(ChatMessage msg, {required bool isMobile}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // GPS Implicit Info Banner
          if (msg.statusInfo != null && isMobile)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 10, color: Colors.teal),
                  const SizedBox(width: 4),
                  Text(
                    msg.statusInfo!,
                    style: TextStyle(fontSize: 10, color: Colors.teal.shade400, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          
          // Main text bubble
          Row(
            mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!msg.isUser)
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.support_agent, size: 16, color: Colors.white),
                ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: msg.isUser
                        ? Colors.teal.shade700
                        : (isDark ? Colors.grey.shade800 : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                      bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                    ),
                      boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.onSurface.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      color: msg.isUser ? Colors.white : theme.colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Universal Horizontal Scrolling Cards
          if (msg.suggestedFacilities != null && msg.suggestedFacilities!.isNotEmpty)
            _buildHorizontalSuggestedFacilities(msg.suggestedFacilities!, isMobile: isMobile),

          // Generative Itinerary preview on mobile
          if (msg.itinerary != null && msg.itinerary!.isNotEmpty && isMobile)
            _buildMobileItineraryPreview(msg.itinerary!),
        ],
      ),
    );
  }

  // --- HORIZONTAL SCROLL SUGGESTIONS WIDGET ---
  Widget _buildHorizontalSuggestedFacilities(List<Facility> facilities, {required bool isMobile}) {
    return Container(
      height: 155,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: facilities.length,
        itemBuilder: (context, index) {
          final theme = Theme.of(context);
          final f = facilities[index];
          final isDining = f.name.toLowerCase().contains(RegExp('pretzel|cafe|restaurant|grill|dining|eats|table|bakery'));
          
          return Container(
            width: 220,
            margin: const EdgeInsets.only(right: 12),
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDining
                              ? [Colors.orange.shade800, Colors.deepOrange.shade900]
                              : [Colors.teal.shade800, Colors.indigo.shade900],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isDining ? Icons.restaurant : Icons.attractions,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                f.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Category tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            f.category,
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Open',
                              style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: theme.colorScheme.onSurface,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                minimumSize: const Size(60, 24),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('View', style: TextStyle(fontSize: 11)),
                              onPressed: () {
                                if (isMobile) {
                                  // Push details page on Mobile
                                  context.push('/home/details?facilityId=${f.id}&parkId=p2');
                                } else {
                                  // Display details in Pane 2 on Desktop
                                  ref.read(searchProvider.notifier).selectFacility(f);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- MOBILE ITINERARY PREVIEW WIDGET ---
  Widget _buildMobileItineraryPreview(List<SearchItineraryItem> itinerary) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_note, color: Colors.teal, size: 18),
              const SizedBox(width: 8),
              Text(
                'Magic Kingdom Timeline (${itinerary.length} items)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: itinerary.length,
            separatorBuilder: (_, __) => const Icon(Icons.arrow_downward, size: 12, color: Colors.grey),
            itemBuilder: (context, index) {
              final item = itinerary[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Text(
                      item.time,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.teal),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Switch to Desktop dashboard to Drag & Drop and modify times!',
              style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  // --- PANE 2: ACTIVE INTERACTIVE WIDGETS ---
  Widget _buildActiveWidgetsPane(SearchState state) {

    // Case 1: Selected Restaurant Details showing menu items and dietary filters
    if (state.selectedFacilityDetails != null) {
      final f = state.selectedFacilityDetails!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal.shade800,
            width: double.infinity,
            child: Row(
              children: [
                const Icon(Icons.restaurant, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Dining Location • Magic Kingdom', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    ref.read(searchProvider.notifier).selectFacility(null);
                  },
                ),
              ],
            ),
          ),
          
          // Dietary filter options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dietary Restrictions Filter:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Vegan', 'Vegetarian', 'Gluten-Free', 'Dairy-Free'].map((filter) {
                    final active = _activeDietaryFilters.contains(filter);
                    return ChoiceChip(
                      label: Text(filter, style: TextStyle(color: active ? Colors.white : null)),
                      selected: active,
                      selectedColor: Colors.teal,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _activeDietaryFilters.add(filter);
                          } else {
                            _activeDietaryFilters.remove(filter);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Menu Items grid
          Expanded(
            child: _buildFilteredMenuItemsGrid(),
          ),
        ],
      );
    }

    // Case 2: Drag & Drop Itinerary Timeline
    if (state.currentItineraryItems != null) {
      final items = state.currentItineraryItems!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal.shade800,
            width: double.infinity,
            child: Row(
              children: [
                const Icon(Icons.timeline, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Generative Daily Itinerary Planner', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Drag and drop items to reorder and calculate path routes.', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  key: ValueKey(item.id),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade50,
                      child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                    ),
                    title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, size: 12, color: Colors.teal),
                          const SizedBox(width: 4),
                          Text(item.time, style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(width: 12),
                          const Icon(Icons.hourglass_empty, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('${item.durationMinutes} min', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.drag_handle, color: Colors.grey),
                  ),
                );
              },
              onReorder: (oldIndex, newIndex) {
                ref.read(searchProvider.notifier).reorderItinerary(oldIndex, newIndex);
              },
            ),
          ),
        ],
      );
    }

    // Default: Welcome / Instructions panel
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assistant, size: 80, color: Colors.teal.shade200),
            const SizedBox(height: 16),
            const Text(
              'Active Interactive Widget Panel',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Interactive response details and drag-and-drop itinerary timelines will be displayed here when you ask planning questions.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // --- FILTERED RESTAURANT MENU ITEMS GRID ---
  Widget _buildFilteredMenuItemsGrid() {
    final filteredItems = _mockMenuItems.where((item) {
      if (_activeDietaryFilters.isEmpty) return true;
      final tags = item['dietaryTags'] as List<String>;
      
      // All active filters must be present in the item
      for (final filter in _activeDietaryFilters) {
        if (filter == 'Gluten-Free' && !tags.contains('Gluten-Free')) return false;
        if (filter == 'Vegan' && !tags.contains('Vegan')) return false;
        if (filter == 'Dairy-Free' && !tags.contains('Dairy-Free')) return false;
        if (filter == 'Vegetarian' && !tags.contains('Vegetarian') && !tags.contains('Vegan')) return false;
      }
      return true;
    }).toList();

    if (filteredItems.isEmpty) {
      return const Center(
        child: Text('No menu items match selected filters.'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: Image.network(
                    item['imageUrl'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.restaurant_menu),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('\$${(item['price'] as double).toStringAsFixed(2)}', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 11)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: (item['dietaryTags'] as List<String>).map((t) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(t, style: const TextStyle(fontSize: 8, color: Colors.teal)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- PANE 3: VECTOR MAP DISPLAY ---
  Widget _buildMapPane(SearchState state) {
    final userPos = ref.watch(userLocationProvider('p2')); // user live location (Orlando MK)
    
    // Extract points to plot:
    // If itinerary is active, plot itinerary sequence.
    // If pretzel/dining search is active, plot suggested pins.
    final List<MapPin> mapPins = [];
    final List<Offset> routeLines = [];

    // Let's identify the park center and coordinates boundary.
    // We'll use Magic Kingdom coords as default: Center = 28.4194, -81.5812
    const double centerLat = 28.4194;
    const double centerLng = -81.5812;
    const double paddingDeg = 0.005;
    const double minLat = centerLat - paddingDeg;
    const double maxLat = centerLat + paddingDeg;
    const double minLng = centerLng - paddingDeg;
    const double maxLng = centerLng + paddingDeg;

    Offset getCanvasOffset(double lat, double lng, Size mapSize) {
      final x = (lng - minLng) / (maxLng - minLng) * mapSize.width;
      final y = (maxLat - lat) / (maxLat - minLat) * mapSize.height;
      return Offset(x, y);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        final mapSize = Size(size, size);

        // Add user coordinate pin
        final userOffset = getCanvasOffset(userPos.latitude, userPos.longitude, mapSize);
        mapPins.add(MapPin(
          offset: userOffset,
          label: 'YOU',
          isUser: true,
        ));

        // Add itinerary pins and compile route path lines
        if (state.currentItineraryItems != null) {
          final items = state.currentItineraryItems!;
          for (int i = 0; i < items.length; i++) {
            final item = items[i];
            final pinOffset = getCanvasOffset(item.latitude, item.longitude, mapSize);
            mapPins.add(MapPin(
              offset: pinOffset,
              label: '${i + 1}',
              name: item.title,
              isUser: false,
            ));
            routeLines.add(pinOffset);
          }
        } 
        // Or if restaurant search cards are showing in the last assistant response
        else if (state.messages.isNotEmpty) {
          final lastMsg = state.messages.lastWhere(
            (m) => !m.isUser && m.suggestedFacilities != null,
            orElse: () => ChatMessage(id: '', text: '', isUser: false, timestamp: DateTime.now()),
          );
          if (lastMsg.suggestedFacilities != null) {
            final pretCoordMap = {
              'pretzel_1': [28.4208, -81.5820],
              'pretzel_2': [28.4188, -81.5790],
              'pretzel_3': [28.4183, -81.5840],
            };
            for (final f in lastMsg.suggestedFacilities!) {
              List<double>? coords = pretCoordMap[f.id];
              if (coords == null) {
                coords = SearchNotifier.knownCoords[f.id];
              }
              if (coords != null) {
                final pinOffset = getCanvasOffset(coords[0], coords[1], mapSize);
                mapPins.add(MapPin(
                  offset: pinOffset,
                  label: 'S',
                  name: f.name,
                  isUser: false,
                  isSnack: true,
                ));
              }
            }
          }
        }

        return Center(
          child: Container(
            width: mapSize.width,
            height: mapSize.height,
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF0F0F0F)
                : Colors.grey.shade100,
            child: Stack(
              children: [
                // Custom Paint for grid and route lines
                Positioned.fill(
                  child: CustomPaint(
                    painter: _AIHelperMapPainter(
                      pins: mapPins,
                      route: routeLines,
                      userOffset: userOffset,
                      isDark: Theme.of(context).brightness == Brightness.dark,
                      gridColor: Theme.of(context).colorScheme.onSurface.withOpacity(
                          Theme.of(context).brightness == Brightness.dark ? 0.10 : 0.04),
                    ),
                  ),
                ),
                // Interactive Marker labels as widgets positioned over coords
                ...mapPins.map((pin) {
                  return Positioned(
                    left: pin.offset.dx - 12,
                    top: pin.offset.dy - 12,
                    child: Tooltip(
                      message: pin.isUser ? 'Your GPS Location' : (pin.name ?? 'Location'),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: pin.isUser
                              ? Colors.blueAccent
                              : (pin.isSnack ? Colors.orange : Colors.teal),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            pin.label,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- VOICE VOICE SIMULATOR FLOATING WIDGET ---
  Widget _buildVoiceOverlayWidget() {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.onSurface.withOpacity(0.87),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Card(
          color: Colors.grey.shade900,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mic, size: 64, color: Colors.tealAccent),
                const SizedBox(height: 16),
                const Text(
                  'AI TRAVEL AGENT DICTATION',
                  style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
                const SizedBox(height: 12),
                Text(
                  _voiceStatusText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                // Audio Wave Visualizer
                SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _VoiceWaveformPainter(animationValue: _waveController.value),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    _voiceTimer?.cancel();
                    setState(() {
                      _showVoiceOverlay = false;
                    });
                    ref.read(searchProvider.notifier).setListening(false);
                  },
                  child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- HELPER CLASSES FOR COORDINATES PLOTTING ---
class MapPin {
  MapPin({
    required this.offset,
    required this.label,
    this.name,
    required this.isUser,
    this.isSnack = false,
  });

  final Offset offset;
  final String label;
  final String? name;
  final bool isUser;
  final bool isSnack;
}

// --- PAINTER FOR SCHEMATIC GRID MAP & dashed route line ---
class _AIHelperMapPainter extends CustomPainter {
  _AIHelperMapPainter({
    required this.pins,
    required this.route,
    required this.userOffset,
    required this.isDark,
    required this.gridColor,
  });

  final List<MapPin> pins;
  final List<Offset> route;
  final Offset userOffset;
  final bool isDark;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    // Draw background grid lines
    const double step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw coordinate zones (mock park boundaries for styling)
    final zonePaint = Paint()
      ..color = Colors.teal.withOpacity(isDark ? 0.05 : 0.03)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.45), size.width * 0.35, zonePaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.3), size.width * 0.2, zonePaint);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.65), size.width * 0.2, zonePaint);

    // Draw route lines connecting the itinerary points in order
    if (route.length > 1) {
      final routePaint = Paint()
        ..color = Colors.tealAccent.shade400
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // Draw dashed connecting path
      for (int i = 0; i < route.length - 1; i++) {
        final p1 = route[i];
        final p2 = route[i + 1];
        _drawDashedLine(canvas, p1, p2, routePaint);
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dashWidth = 8.0;
    const double dashSpace = 6.0;

    final double distance = (p2 - p1).distance;
    final int dashCount = (distance / (dashWidth + dashSpace)).floor();
    
    final Offset direction = (p2 - p1) / distance;
    
    for (int i = 0; i < dashCount; i++) {
      final double startOffset = i * (dashWidth + dashSpace);
      final double endOffset = startOffset + dashWidth;
      
      canvas.drawLine(
        p1 + direction * startOffset,
        p1 + direction * endOffset,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AIHelperMapPainter oldDelegate) => true;
}

// --- VOICE AUDIO PULSING WAVEFORM PAINTER ---
class _VoiceWaveformPainter extends CustomPainter {
  _VoiceWaveformPainter({required this.animationValue});

  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final wavePaint = Paint()
      ..color = Colors.tealAccent
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final int barCount = 20;
    final double spacing = size.width / barCount;
    
    for (int i = 0; i < barCount; i++) {
      // Calculate random wave heights influenced by animation value and bar position
      final double phase = (i * 0.5) + (animationValue * 2.0 * math.pi);
      final double heightScale = (math.sin(phase).abs() * 0.7) + 0.3;
      final double barHeight = size.height * heightScale;
      
      final double x = (i * spacing) + (spacing / 2);
      final double startY = (size.height - barHeight) / 2;
      final double endY = startY + barHeight;
      
      canvas.drawLine(Offset(x, startY), Offset(x, endY), wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _VoiceWaveformPainter oldDelegate) => true;
}
