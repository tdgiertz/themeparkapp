import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:themeparkapp/features/park/park_explorer_state.dart';
import 'package:themeparkapp/features/search/search_state.dart';
import 'package:themeparkapp/core/models/park_detail.dart';

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
    if (mounted && MediaQuery.of(context).size.width > 1024) {
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
          color: Theme.of(context).colorScheme.primaryContainer,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.gps_fixed, size: 14, color: Theme.of(context).colorScheme.onPrimaryContainer),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Live Location: ${userPos.latitude.toStringAsFixed(4)}, ${userPos.longitude.toStringAsFixed(4)}',
                  style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Text / Voice Input area
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.5))),
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Voice button
                GestureDetector(
                  onTap: _startVoiceInput,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.mic, color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
                const SizedBox(width: 8),
                // Text Field
                Expanded(
                  child: TextField(
                    key: const ValueKey('search_textfield_mobile'),
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type complex query or plan...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: _submitText,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
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
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, color: Theme.of(context).colorScheme.primary),
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
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            key: const ValueKey('search_textfield_desktop'),
                            controller: _textController,
                            focusNode: _inputFocusNode,
                            decoration: InputDecoration(
                              hintText: 'Press Enter to ask travel agent...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.mic, color: Theme.of(context).colorScheme.primary),
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
                    Text(
                      'Keyboard priority: Type query and press Enter to search.',
                      style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
          child: ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // GPS Implicit Info Banner
          if (msg.statusInfo != null && isMobile)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 10, color: theme.colorScheme.secondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      msg.statusInfo!,
                      style: TextStyle(fontSize: 10, color: theme.colorScheme.secondary, fontStyle: FontStyle.italic),
                      overflow: TextOverflow.ellipsis,
                    ),
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
                CircleAvatar(
                  radius: 14,
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  child: Icon(Icons.support_agent, size: 16, color: theme.colorScheme.onSecondaryContainer),
                ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: msg.isUser
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                      bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      color: msg.isUser ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
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
                              ? [theme.colorScheme.tertiaryContainer, theme.colorScheme.secondaryContainer]
                              : [theme.colorScheme.primaryContainer, theme.colorScheme.secondaryContainer],
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
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                f.name,
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimaryContainer,
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
                            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            f.category,
                            style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontSize: 10),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Open',
                              style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.surface,
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
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_note, color: Theme.of(context).colorScheme.primary, size: 18),
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
            separatorBuilder: (_, __) => Icon(Icons.arrow_downward, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
            itemBuilder: (context, index) {
              final item = itinerary[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(
                      item.time,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Theme.of(context).colorScheme.primary),
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
          Center(
            child: Text(
              'Switch to Desktop dashboard to Drag & Drop and modify times!',
              style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic),
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
            color: Theme.of(context).colorScheme.primaryContainer,
            width: double.infinity,
            child: Row(
              children: [
                Icon(Icons.restaurant, color: Theme.of(context).colorScheme.onPrimaryContainer, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.name, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Dining Location • Magic Kingdom', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8), fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onPrimaryContainer),
                  onPressed: () {
                    ref.read(searchProvider.notifier).selectFacility(null);
                  },
                ),
              ],
            ),
          ),
          
          // Dietary filter options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      label: Text(filter, style: TextStyle(color: active ? Theme.of(context).colorScheme.onPrimary : null)),
                      selected: active,
                      selectedColor: Theme.of(context).colorScheme.primary,
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
            color: Theme.of(context).colorScheme.primaryContainer,
            width: double.infinity,
            child: Row(
              children: [
                Icon(Icons.timeline, color: Theme.of(context).colorScheme.onPrimaryContainer, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Generative Daily Itinerary Planner', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Drag and drop items to reorder and calculate path routes.', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8), fontSize: 12)),
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
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text('${index + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimaryContainer)),
                    ),
                    title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(item.time, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(width: 12),
                          Icon(Icons.hourglass_empty, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text('${item.durationMinutes} min', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                        ],
                      ),
                    ),
                    trailing: Icon(Icons.drag_handle, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assistant, size: 80, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text(
              'Active Interactive Widget Panel',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Interactive response details and drag-and-drop itinerary timelines will be displayed here when you ask planning questions.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  child: Image.network(
                    item['imageUrl'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.restaurant_menu),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('\$${(item['price'] as double).toStringAsFixed(2)}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 11)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: (item['dietaryTags'] as List<String>).map((t) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(t, style: TextStyle(fontSize: 8, color: Theme.of(context).colorScheme.onSecondaryContainer)),
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
    final mapPins = <MapPin>[];
    final routeLines = <Offset>[];

    // Let's identify the park center and coordinates boundary.
    // We'll use Magic Kingdom coords as default: Center = 28.4194, -81.5812
    const centerLat = 28.4194;
    const centerLng = -81.5812;
    const paddingDeg = 0.005;
    const minLat = centerLat - paddingDeg;
    const maxLat = centerLat + paddingDeg;
    const minLng = centerLng - paddingDeg;
    const maxLng = centerLng + paddingDeg;

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
          for (var i = 0; i < items.length; i++) {
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
              var coords = pretCoordMap[f.id];
              coords ??= SearchNotifier.knownCoords[f.id];
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

        final colorScheme = Theme.of(context).colorScheme;

        return Center(
          child: Container(
            width: mapSize.width,
            height: mapSize.height,
            color: colorScheme.surfaceContainerLowest,
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
                      gridColor: colorScheme.onSurface.withValues(
                          alpha: Theme.of(context).brightness == Brightness.dark ? 0.10 : 0.04),
                      accentColor: colorScheme.primary,
                      secondaryColor: colorScheme.secondary,
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
                              ? colorScheme.primary
                              : (pin.isSnack ? colorScheme.tertiary : colorScheme.secondary),
                          shape: BoxShape.circle,
                          border: Border.all(color: colorScheme.surface, width: 2),
                          boxShadow: [
                            BoxShadow(color: colorScheme.shadow, blurRadius: 4, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            pin.label,
                            style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 10),
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
      color: theme.colorScheme.scrim.withValues(alpha: 0.87),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Card(
          color: theme.colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mic, size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'AI TRAVEL AGENT DICTATION',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
                const SizedBox(height: 12),
                Text(
                  _voiceStatusText,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                // Audio Wave Visualizer
                SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _VoiceWaveformPainter(
                      animationValue: _waveController.value,
                      waveColor: theme.colorScheme.primary,
                    ),
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
                  child: Text('Cancel', style: TextStyle(color: theme.colorScheme.error)),
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
    required this.isUser, this.name,
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
    required this.accentColor,
    required this.secondaryColor,
  });

  final List<MapPin> pins;
  final List<Offset> route;
  final Offset userOffset;
  final bool isDark;
  final Color gridColor;
  final Color accentColor;
  final Color secondaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    // Draw background grid lines
    const step = 20;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw coordinate zones (mock park boundaries for styling)
    final zonePaint = Paint()
      ..color = secondaryColor.withValues(alpha: isDark ? 0.05 : 0.03)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.45), size.width * 0.35, zonePaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.3), size.width * 0.2, zonePaint);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.65), size.width * 0.2, zonePaint);

    // Draw route lines connecting the itinerary points in order
    if (route.length > 1) {
      final routePaint = Paint()
        ..color = accentColor
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // Draw dashed connecting path
      for (var i = 0; i < route.length - 1; i++) {
        final p1 = route[i];
        final p2 = route[i + 1];
        _drawDashedLine(canvas, p1, p2, routePaint);
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 8;
    const dashSpace = 6;

    final distance = (p2 - p1).distance;
    final dashCount = (distance / (dashWidth + dashSpace)).floor();
    
    final direction = (p2 - p1) / distance;
    
    for (var i = 0; i < dashCount; i++) {
      final startOffset = i * (dashWidth + dashSpace);
      final endOffset = startOffset + dashWidth;
      
      canvas.drawLine(
        p1 + direction * startOffset.toDouble(),
        p1 + direction * endOffset.toDouble(),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AIHelperMapPainter oldDelegate) => true;
}

// --- VOICE AUDIO PULSING WAVEFORM PAINTER ---
class _VoiceWaveformPainter extends CustomPainter {
  _VoiceWaveformPainter({
    required this.animationValue,
    required this.waveColor,
  });

  final double animationValue;
  final Color waveColor;

  @override
  void paint(Canvas canvas, Size size) {
    final wavePaint = Paint()
      ..color = waveColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    const barCount = 20;
    final spacing = size.width / barCount;
    
    for (var i = 0; i < barCount; i++) {
      // Calculate random wave heights influenced by animation value and bar position
      final phase = (i * 0.5) + (animationValue * 2.0 * math.pi);
      final heightScale = (math.sin(phase).abs() * 0.7) + 0.3;
      final barHeight = size.height * heightScale;
      
      final x = (i * spacing) + (spacing / 2);
      final startY = (size.height - barHeight) / 2;
      final endY = startY + barHeight;
      
      canvas.drawLine(Offset(x, startY), Offset(x, endY), wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _VoiceWaveformPainter oldDelegate) => true;
}
