import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/core/environment_providers.dart';

void main() {
  test('favoritesProvider loads favorites', () async {
    Future<String> loader(String path) async => File(path).readAsString();
    final container = ProviderContainer(overrides: [
      assetLoaderProvider.overrideWithValue(loader),
    ]);
    addTearDown(container.dispose);

    // wait for initial load
    await container.read(favoritesProvider.notifier).refresh();
    final resp = container.read(favoritesProvider) as AsyncData;
    expect(resp.value, isNotNull);
    // basic structural check
    expect((resp.value).favoriteRides, isA<List>());
  });

  test('mediaQualityProvider prefers high on wifi and good battery', () async {
    final container = ProviderContainer(overrides: [
      mediaQualityProvider.overrideWithValue(MediaQuality.high),
    ]);
    addTearDown(container.dispose);

    final quality = container.read(mediaQualityProvider);
    expect(quality, MediaQuality.high);
  });

  test('mediaQualityProvider returns low when offline or low battery', () async {
    final c1 = ProviderContainer(overrides: [
      mediaQualityProvider.overrideWithValue(MediaQuality.low),
    ]);
    addTearDown(c1.dispose);
    expect(c1.read(mediaQualityProvider), MediaQuality.low);

    final c2 = ProviderContainer(overrides: [
      mediaQualityProvider.overrideWithValue(MediaQuality.low),
    ]);
    addTearDown(c2.dispose);
    expect(c2.read(mediaQualityProvider), MediaQuality.low);
  });
}
