import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themeparkapp/core/environment_providers.dart';
import 'package:themeparkapp/core/widgets/adaptive_image.dart';

void main() {
  testWidgets(
    'D. AdaptiveNetworkImage renders high/low resolution and placeholder',
    (WidgetTester tester) async {
      // 1. High Quality
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaQualityProvider.overrideWithValue(MediaQuality.high),
          ],
          child: const MaterialApp(
            home: AdaptiveNetworkImage(
              highResUrl: 'https://example.com/high.jpg',
              lowResUrl: 'https://example.com/low.jpg',
            ),
          ),
        ),
      );

      // Image provider check: we can't easily assert network calls in widget tests out-of-the-box,
      // but we can ensure it tries to load an Image widget.
      expect(find.byType(Image), findsOneWidget);

      final imageWidgetHigh = tester.widget<Image>(find.byType(Image));
      expect(
        (imageWidgetHigh.image as NetworkImage).url,
        'https://example.com/high.jpg',
      );

      // 2. Low Quality
      await tester.pumpWidget(
        ProviderScope(
          overrides: [mediaQualityProvider.overrideWithValue(MediaQuality.low)],
          child: const MaterialApp(
            home: AdaptiveNetworkImage(
              highResUrl: 'https://example.com/high.jpg',
              lowResUrl: 'https://example.com/low.jpg',
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      final imageWidgetLow = tester.widget<Image>(find.byType(Image));
      expect(
        (imageWidgetLow.image as NetworkImage).url,
        'https://example.com/low.jpg',
      );

      // 3. Missing both URLs yields placeholder
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaQualityProvider.overrideWithValue(MediaQuality.high),
          ],
          child: const MaterialApp(
            home: AdaptiveNetworkImage(highResUrl: '', lowResUrl: ''),
          ),
        ),
      );

      expect(find.byType(Image), findsNothing);
      expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
    },
  );
}
