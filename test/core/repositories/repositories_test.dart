import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themeparkapp/core/repositories/repositories.dart';

void mockAsset(String path, String content) {
  rootBundle.evict(path);
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (ByteData? message) async {
        final key = utf8.decode(message!.buffer.asUint8List());
        if (key == path) {
          final data = ByteData.view(
            Uint8List.fromList(utf8.encode(content)).buffer,
          );
          return data;
        }
        return null;
      });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  group('FakeParkRepository', () {
    test('fetchParks returns successfully with valid JSON', () async {
      mockAsset(
        'assets/data/parks.json',
        json.encode({
          'data': {
            'parks': [
              {
                'id': 'park1',
                'type': 'ThemePark',
                'name': 'Test Park',
                'operatingHours': {'open': '09:00', 'close': '21:00'},
                'crowdLevel': 'Moderate',
                'children': <Map<String, dynamic>>[],
              },
            ],
          },
        }),
      );

      final repo = FakeParkRepository();
      final parks = await repo.fetchParks();

      expect(parks.length, 1);
      expect(parks.first.id, 'park1');
      expect(parks.first.name, 'Test Park');
    });

    test('fetchParks throws FormatException on malformed JSON', () async {
      mockAsset('assets/data/parks.json', 'invalid json');

      final repo = FakeParkRepository();
      expect(repo.fetchParks, throwsA(isA<FormatException>()));
    });
  });

  group('FakeWaitTimesRepository', () {
    test('fetchWaitTimes returns successfully with valid JSON', () async {
      mockAsset(
        'assets/data/wait_times.json',
        json.encode({
          'waitTimes': [
            {'rideId': 'ride1', 'name': 'Test Ride', 'waitMinutes': 45},
          ],
        }),
      );

      final repo = FakeWaitTimesRepository();
      final waitTimes = await repo.fetchWaitTimes();

      expect(waitTimes.length, 1);
      expect(waitTimes.first.rideId, 'ride1');
      expect(waitTimes.first.waitMinutes, 45);
    });

    test('fetchWaitTimes throws error on missing keys', () async {
      mockAsset(
        'assets/data/wait_times.json',
        json.encode({
          'waitTimes': [
            {
              // Missing rideId
              'waitMinutes': 45,
            },
          ],
        }),
      );

      final repo = FakeWaitTimesRepository();
      expect(repo.fetchWaitTimes, throwsA(isA<TypeError>()));
    });
  });
}
