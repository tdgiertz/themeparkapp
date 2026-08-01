import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:themeparkapp/core/models/park_detail.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/features/park/park_explorer_state.dart';

/// Represents a single item in the drag-and-drop itinerary.
class SearchItineraryItem {
  SearchItineraryItem({
    required this.id,
    required this.time,
    required this.title,
    required this.facilityId,
    required this.parkId,
    required this.latitude,
    required this.longitude,
    required this.durationMinutes,
  });

  final String id;
  final String time;
  final String title;
  final String facilityId;
  final String parkId;
  final double latitude;
  final double longitude;
  final int durationMinutes;

  SearchItineraryItem copyWith({
    String? time,
  }) {
    return SearchItineraryItem(
      id: id,
      time: time ?? this.time,
      title: title,
      facilityId: facilityId,
      parkId: parkId,
      latitude: latitude,
      longitude: longitude,
      durationMinutes: durationMinutes,
    );
  }
}

/// Represents a message in the chat thread.
class ChatMessage {
  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.suggestedFacilities,
    this.itinerary,
    this.statusInfo,
  });

  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<Facility>? suggestedFacilities;
  final List<SearchItineraryItem>? itinerary;
  final String? statusInfo;
}

/// State for the Search and AI Assistant view.
class SearchState {
  SearchState({
    required this.messages,
    required this.isListening,
    this.currentItineraryItems,
    this.selectedFacilityDetails,
  });

  final List<ChatMessage> messages;
  final bool isListening;
  final List<SearchItineraryItem>? currentItineraryItems;
  final Facility? selectedFacilityDetails;

  SearchState copyWith({
    List<ChatMessage>? messages,
    bool? isListening,
    List<SearchItineraryItem>? currentItineraryItems,
    Facility? selectedFacilityDetails,
    bool clearSelectedFacility = false,
  }) {
    return SearchState(
      messages: messages ?? this.messages,
      isListening: isListening ?? this.isListening,
      currentItineraryItems: currentItineraryItems ?? this.currentItineraryItems,
      selectedFacilityDetails: clearSelectedFacility ? null : (selectedFacilityDetails ?? this.selectedFacilityDetails),
    );
  }
}

/// StateNotifier that handles the assistant's behavior and conversational flow.
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(this.ref)
      : super(
          SearchState(
            messages: [
              ChatMessage(
                id: 'welcome',
                text: 'Welcome! I am your AI travel agent assistant. Ask me to:\n• "Find the nearest pretzel"\n• "Plan my day at Magic Kingdom"\n• "Suggest dining near me"',
                isUser: false,
                timestamp: DateTime.now(),
              )
            ],
            isListening: false,
          ),
        ) {
    _loadAllFacilities();
  }

  final Ref ref;
  List<Facility> _allFacilities = [];

  // Helper mapping of known coordinates for facilities to draw pins and lines.
  static const Map<String, List<double>> knownCoords = {
    // Animal Kingdom (p1)
    'a1': [28.3575, -81.5930], // Avatar Flight
    'a2': [28.3590, -81.5880], // Conservation Station
    'a3': [28.3580, -81.5860], // Expedition Everest
    'a4': [28.3595, -81.5900], // Gorilla Falls
    'a5': [28.3590, -81.5855], // Kali River Rapids
    'a6': [28.3610, -81.5910], // Kilimanjaro Safaris
    'a7': [28.3595, -81.5850], // Maharajah Jungle
    'a8': [28.3570, -81.5900], // Adventurers Outpost
    'a9': [28.3578, -81.5925], // Na'vi River
    'a10': [28.3555, -81.5903], // Rainforest Cafe
    'a11': [28.3595, -81.5898], // Wildlife Express
    'a12': [28.3585, -81.5890], // Zootopia
    // Magic Kingdom (p2)
    'a13': [28.4208, -81.5824], // small world
    'a14': [28.4190, -81.5794], // Astro Orbiter
    'a15': [28.4200, -81.5852], // Big Thunder
    'a16': [28.4188, -81.5796], // Buzz Lightyear
    'a17': [28.4196, -81.5812], // Cinderella Castle
    'a18': [28.4190, -81.5835], // Country Bear
    'a19': [28.4204, -81.5802], // Dumbo
    'a20': [28.4205, -81.5810], // Belle Tales
    'a21': [28.4204, -81.5838], // Haunted Mansion
    'a22': [28.4183, -81.5836], // Jungle Cruise
    'a23': [28.4198, -81.5802], // Mad Tea Party
    'a24': [28.4206, -81.5804], // Ariel Grotto
    'a25': [28.4198, -81.5810], // Princess Fairytale
    'a26': [28.4202, -81.5798], // Pete's Side Show
    'a28': [28.4178, -81.5814], // Mickey Town Square
  };

  /// Loads all facilities from parks.json asset.
  Future<void> _loadAllFacilities() async {
    try {
      final loader = ref.read(assetLoaderProvider);
      final raw = await loader('assets/data/parks.json');
      final decoded = json.decode(raw) as Map<String, dynamic>;
      final data = decoded['data'] as Map<String, dynamic>? ?? {};
      final parksList = data['parks'] as List? ?? decoded['parks'] as List? ?? [];
      final facilities = <Facility>[];
      for (final parkMap in parksList) {
        final lands = parkMap['children'] as List? ?? [];
        for (final landMap in lands) {
          final children = landMap['children'] as List? ?? [];
          for (final facMap in children) {
            facilities.add(Facility.fromJson(facMap as Map<String, dynamic>));
          }
        }
      }
      _allFacilities = facilities;
    } catch (_) {}
  }

  /// Sets whether the assistant is currently listening to voice input.
  void setListening(bool listening) {
    state = state.copyWith(isListening: listening);
  }

  /// Sets selected facility details for middle panel display.
  void selectFacility(Facility? facility) {
    if (facility == null) {
      state = state.copyWith(clearSelectedFacility: true);
    } else {
      state = state.copyWith(selectedFacilityDetails: facility);
    }
  }

  /// Submits a search query and processes the response.
  Future<void> submitQuery(String queryText) async {
    if (queryText.trim().isEmpty) return;

    // Add user message
    final userMsg = ChatMessage(
      id: DateTime.now().toString(),
      text: queryText,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(messages: [...state.messages, userMsg]);

    // Simulate think delay
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final normalizedQuery = queryText.toLowerCase();

    // 1. Nearest pretzel / food (Location Context API)
    if (normalizedQuery.contains('pretzel') || normalizedQuery.contains('nearest') || normalizedQuery.contains('food near me') || normalizedQuery.contains('dining near me')) {
      // Get location: default to Magic Kingdom center if geolocator is inactive
      final userPos = ref.read(userLocationProvider('p2')); // read Magic Kingdom position
      final lat = userPos.latitude;
      final lng = userPos.longitude;

      // Define some mock pretzel/snack stands at high fidelity locations
      final mockPretzelStands = [
        Facility(
          id: 'pretzel_1',
          type: 'Facility',
          category: 'Dining',
          name: 'Fantasyland Pretzel Oasis',
          thrillLevel: 'Low',
          heightRequirementInches: 0,
        ),
        Facility(
          id: 'pretzel_2',
          type: 'Facility',
          category: 'Dining',
          name: 'Tomorrowland Pretzel Cart',
          thrillLevel: 'Low',
          heightRequirementInches: 0,
        ),
        Facility(
          id: 'pretzel_3',
          type: 'Facility',
          category: 'Dining',
          name: 'Adventureland Pretzel & Slush',
          thrillLevel: 'Low',
          heightRequirementInches: 0,
        ),
      ];

      // Add actual dining spots from attractions.json that are in Magic Kingdom
      final searchPool = <Facility>[...mockPretzelStands];
      for (final fac in _allFacilities) {
        final isDining = fac.name.toLowerCase().contains(RegExp('cafe|restaurant|grill|dining|eats|table|bakery|kitchen|tavern|pub|food'));
        if (isDining) {
          searchPool.add(fac);
        }
      }

      // Compute distances in yards
      // Approx scale: lat degree = 121,000 yds, lng degree = 107,000 yds
      double distanceYards(double lat1, double lng1, double lat2, double lng2) {
        final dy = (lat2 - lat1) * 121000.0;
        final dx = (lng2 - lng1) * 107000.0;
        return math.sqrt(dx * dx + dy * dy);
      }

      // Map coordinates for pretzel stands
      final pretzelCoords = {
        'pretzel_1': [28.4208, -81.5820], // near small world
        'pretzel_2': [28.4188, -81.5790], // near Buzz
        'pretzel_3': [28.4183, -81.5840], // near Jungle Cruise
      };

      final sortedStands = <MapEntry<Facility, double>>[];
      for (final stand in searchPool) {
        var coords = pretzelCoords[stand.id];
        coords ??= knownCoords[stand.id];
        if (coords == null) {
          // deterministic fallback coordinate
          final hash = stand.id.hashCode;
          final latOffset = ((hash % 100) - 50) / 25000.0;
          final lngOffset = (((hash >> 2) % 100) - 50) / 25000.0;
          coords = [lat + latOffset, lng + lngOffset];
        }

        final dist = distanceYards(lat, lng, coords[0], coords[1]);
        sortedStands.add(MapEntry(stand, dist));
      }

      // Sort by distance
      sortedStands.sort((a, b) => a.value.compareTo(b.value));

      // Build cards for top 3
      final suggested = sortedStands.take(3).map((e) => e.key).toList();
      final statusMessage = 'Implicitly using GPS ping (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';

      // Distances string mapping for cards
      final textResponse = 'Based on your location, I found the nearest pretzel/dining spots. The closest is "${suggested.first.name}" which is only ${sortedStands.first.value.toStringAsFixed(0)} yards away!';

      final assistantMsg = ChatMessage(
        id: DateTime.now().toString(),
        text: textResponse,
        isUser: false,
        timestamp: DateTime.now(),
        suggestedFacilities: suggested,
        statusInfo: statusMessage,
      );

      state = state.copyWith(messages: [...state.messages, assistantMsg]);
    }
    // 2. Planning Itinerary Generative UI
    else if (normalizedQuery.contains('plan') || normalizedQuery.contains('itinerary') || normalizedQuery.contains('day')) {
      final isMK = normalizedQuery.contains('kingdom') || normalizedQuery.contains('mk') || !normalizedQuery.contains('animal');
      final parkId = isMK ? 'p2' : 'p1';
      final parkName = isMK ? 'Magic Kingdom' : 'Animal Kingdom';

      // Pick rides depending on the park
      final rideIds = isMK 
          ? ['a15', 'a21', 'a17', 'a13', 'a16'] // Big Thunder, Haunted Mansion, Castle, small world, Buzz
          : ['a1', 'a3', 'a6', 'a10', 'a5'];   // Flight, Everest, Safaris, Rainforest Cafe, Kali

      // Map time slots
      final times = ['09:00 AM', '11:30 AM', '01:00 PM', '03:30 PM', '06:00 PM'];

      final itineraryItems = <SearchItineraryItem>[];
      for (var i = 0; i < rideIds.length; i++) {
        final rideId = rideIds[i];
        // find facility name
        final facility = _allFacilities.firstWhere(
          (f) => f.id == rideId,
          orElse: () => Facility(
            id: rideId,
            type: 'Facility',
            category: 'Ride',
            name: rideId == 'a15' 
                ? 'Big Thunder Mountain Railroad' 
                : (rideId == 'a1' ? 'Avatar Flight of Passage' : 'Park Attraction'),
          ),
        );

        final coords = knownCoords[rideId] ?? [28.4194, -81.5812];

        itineraryItems.add(
          SearchItineraryItem(
            id: 'itinerary_$i',
            time: times[i],
            title: facility.name,
            facilityId: rideId,
            parkId: parkId,
            latitude: coords[0],
            longitude: coords[1],
            durationMinutes: i == 2 ? 60 : 45, // lunch is 60m
          ),
        );
      }

      final assistantMsg = ChatMessage(
        id: DateTime.now().toString(),
        text: 'I have generated a customized itinerary for your day at $parkName! I laid out optimal showtimes and wait patterns. Use the middle panel to drag-and-drop to adjust times, and watch the map recalculate route routes.',
        isUser: false,
        timestamp: DateTime.now(),
        itinerary: itineraryItems,
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMsg],
        currentItineraryItems: itineraryItems,
      );
    }
    // 3. Fallback Travel Agent response
    else {
      final assistantMsg = ChatMessage(
        id: DateTime.now().toString(),
        text: 'I received your request: "$queryText". As your travel agent, I can help you plan your itinerary or find nearest spots. Try asking me "Find nearest pretzel" or "Help me plan my day at Magic Kingdom".',
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(messages: [...state.messages, assistantMsg]);
    }
  }

  /// Reorder itinerary items when dragged.
  void reorderItinerary(int oldIndex, int newIndex) {
    final items = state.currentItineraryItems;
    if (items == null) return;

    final updated = List<SearchItineraryItem>.from(items);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);

    // Re-assign times sequentially to preserve structured time scheduling
    final times = ['09:00 AM', '11:30 AM', '01:00 PM', '03:30 PM', '06:00 PM'];
    for (var i = 0; i < updated.length; i++) {
      updated[i] = updated[i].copyWith(time: times[i]);
    }

    state = state.copyWith(currentItineraryItems: updated);
  }
}

/// Global provider for the search and AI Assistant state.
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref);
});
