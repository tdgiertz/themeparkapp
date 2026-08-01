import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/features/search/search_state.dart';

void main() {
  test('SearchNotifier initial state has welcome message', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(searchProvider);
    expect(state.messages.length, 1);
    expect(state.messages.first.isUser, false);
    expect(state.messages.first.text, contains('Welcome!'));
    expect(state.isListening, false);
  });

  test('SearchNotifier responds to general query', () async {
    Future<String> loader(String path) async => File(path).readAsString();
    final container = ProviderContainer(
      overrides: [assetLoaderProvider.overrideWithValue(loader)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(searchProvider.notifier);
    await notifier.submitQuery('Hello agent');

    final state = container.read(searchProvider);
    expect(
      state.messages.length,
      3,
    ); // Initial welcome + User message + Assistant reply
    expect(state.messages.last.isUser, false);
    expect(
      state.messages.last.text,
      contains('I received your request: "Hello agent"'),
    );
  });

  test('SearchNotifier processes nearest pretzel/food search', () async {
    Future<String> loader(String path) async => File(path).readAsString();
    final container = ProviderContainer(
      overrides: [assetLoaderProvider.overrideWithValue(loader)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(searchProvider.notifier);
    await notifier.submitQuery('Where is the nearest pretzel?');

    final state = container.read(searchProvider);
    expect(state.messages.length, 3);
    final reply = state.messages.last;
    expect(reply.isUser, false);
    expect(reply.text, contains('I found the nearest pretzel/dining spots'));
    expect(reply.suggestedFacilities, isNotEmpty);
    expect(reply.statusInfo, contains('Implicitly using GPS ping'));
  });

  test('SearchNotifier generates daily itinerary and reorders', () async {
    Future<String> loader(String path) async => File(path).readAsString();
    final container = ProviderContainer(
      overrides: [assetLoaderProvider.overrideWithValue(loader)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(searchProvider.notifier);
    // Submit plan request
    await notifier.submitQuery('Help me plan my day at Magic Kingdom');

    var state = container.read(searchProvider);
    expect(state.messages.length, 3);
    final reply = state.messages.last;
    expect(reply.itinerary, isNotEmpty);
    expect(state.currentItineraryItems, isNotEmpty);

    final initialFirstItem = state.currentItineraryItems![0];
    final initialSecondItem = state.currentItineraryItems![1];

    // Reorder itinerary
    notifier.reorderItinerary(0, 2);

    state = container.read(searchProvider);
    // The items should be reordered: initial first item should now be at index 1
    // (since 0 was moved to after 1)
    expect(state.currentItineraryItems![1].title, initialFirstItem.title);
    expect(state.currentItineraryItems![0].title, initialSecondItem.title);
    // Times should remain sorted
    expect(state.currentItineraryItems![0].time, '09:00 AM');
    expect(state.currentItineraryItems![1].time, '11:30 AM');
  });
}
