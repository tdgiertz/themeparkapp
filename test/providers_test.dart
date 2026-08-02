import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// dart:convert not needed in this test
import 'package:themeparkapp/core/models/enums.dart';
import 'package:themeparkapp/core/models/park.dart';
import 'package:themeparkapp/core/models/park_detail.dart';
import 'package:themeparkapp/core/models/wait_time.dart';
import 'package:themeparkapp/core/providers.dart';

void main() {
  test('counterProvider increments', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(counterProvider), 0);
    container.read(counterProvider.notifier).increment();
    expect(container.read(counterProvider), 1);
  });

  test('detailsProvider returns expected string', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final result = await container.read(detailsProvider.future);
    expect(result, contains('Details loaded'));
  });

  test('themeModeProvider default is system', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.system);
  });

  test('parksProvider loads and can refresh', () async {
    // use a provider override so we don't rely on Flutter asset bundling
    Future<String> loader(String path) async => File(path).readAsString();
    final container = ProviderContainer(
      overrides: [assetLoaderProvider.overrideWithValue(loader)],
    );
    addTearDown(container.dispose);

    final state = container.read(parksProvider);
    expect(state, isA<AsyncLoading<ParksResponse>>());

    // wait for initial load
    await container.read(parksProvider.notifier).refresh();
    final loaded = container.read(parksProvider) as AsyncData<ParksResponse>;
    expect(loaded.value.parks, isNotEmpty);

    // refresh again to ensure refresh path works
    await container.read(parksProvider.notifier).refresh();
    final refreshed = container.read(parksProvider) as AsyncData<ParksResponse>;
    expect(refreshed.value.parks, isNotEmpty);
  });

  test('parkDetailProvider family returns park detail and caches', () async {
    Future<String> loader(String path) async => File(path).readAsString();
    final container = ProviderContainer(
      overrides: [assetLoaderProvider.overrideWithValue(loader)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(parkDetailProvider('p1').notifier);
    await notifier.refresh();

    // wait until AsyncData is available
    Future<ParkDetail> waitForData() async {
      final end = DateTime.now().add(const Duration(seconds: 3));
      while (DateTime.now().isBefore(end)) {
        final s = container.read(parkDetailProvider('p1'));
        if (s is AsyncData<ParkDetail>) return s.value;
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      throw StateError('Timed out waiting for ParkDetail data');
    }

    final result = await waitForData();
    expect(result.name, isNotEmpty);
  });

  test(
    'waitTimesProvider family returns wait times and merges partial updates on refresh',
    () async {
      Future<String> loader(String path) async => File(path).readAsString();
      final container = ProviderContainer(
        overrides: [assetLoaderProvider.overrideWithValue(loader)],
      );
      addTearDown(container.dispose);

      // Initial wait times are loaded from wait_times.json
      Future<WaitTimesResponse> waitForData() async {
        final end = DateTime.now().add(const Duration(seconds: 3));
        while (DateTime.now().isBefore(end)) {
          final s = container.read(waitTimesProvider('p1'));
          if (s is AsyncData<WaitTimesResponse>) return s.value;
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
        throw StateError('Timed out waiting for WaitTimes data');
      }

      final initialResponse = await waitForData();
      // Verify ride a1 exists and has initial wait time (15 mins)
      final initialA1 = initialResponse.waitTimes.firstWhere(
        (e) => e.rideId == 'a1',
      );
      expect(initialA1.waitMinutes, equals(15));
      expect(initialA1.status, equals(WaitTimeStatus.open));

      // Trigger refresh (loads and merges wait_times_update.json)
      final notifier = container.read(waitTimesProvider('p1').notifier);
      await notifier.refresh();

      final updatedResponse = container.read(waitTimesProvider('p1')).value!;
      // Verify ride a1 is updated to 75 mins
      final updatedA1 = updatedResponse.waitTimes.firstWhere(
        (e) => e.rideId == 'a1',
      );
      expect(updatedA1.waitMinutes, equals(75));

      // Verify ride a3 is closed (waitMinutes is null)
      final updatedA3 = updatedResponse.waitTimes.firstWhere(
        (e) => e.rideId == 'a3',
      );
      expect(updatedA3.status, equals(WaitTimeStatus.closed));
      expect(updatedA3.waitMinutes, isNull);

      // Verify ride a2 (which wasn't in partial update) is still 15 mins
      final updatedA2 = updatedResponse.waitTimes.firstWhere(
        (e) => e.rideId == 'a2',
      );
      expect(updatedA2.waitMinutes, equals(15));
    },
  );
}
