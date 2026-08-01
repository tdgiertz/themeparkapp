import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themeparkapp/core/models/favorite.dart';
import 'package:themeparkapp/features/dashboard/widgets/favorite_card_expanded.dart';

void main() {
  Widget buildTestableWidget(Widget child, {Size size = const Size(375, 812)}) {
    return MaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(size: size),
          child: Center(
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'ExpandedFavoriteCard renders ride open status and mobile swipe hints',
    (tester) async {
      final favorite = FavoriteRide(
        rideId: 'pirates',
        name: 'Pirates of the Caribbean',
        parkId: 'mk',
        parkName: 'Magic Kingdom',
        currentWait: {'waitMinutes': 25, 'status': 'Open'},
      );

      await tester.pumpWidget(
        buildTestableWidget(
          SizedBox(
            height: 220,
            child: ExpandedFavoriteCard(favorite: favorite),
          ),
        ),
      );

      expect(find.text('Pirates of the Caribbean'), findsOneWidget);
      expect(find.text('Magic Kingdom'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
      expect(find.text('Swipe Right: Join Queue'), findsOneWidget);
      expect(find.text('Swipe Left: Map'), findsOneWidget);
    },
  );

  testWidgets(
    'ExpandedFavoriteCard renders dining entity with View Menu micro-action',
    (tester) async {
      final favorite = FavoriteRide(
        rideId: 'be_our_guest_restaurant',
        name: 'Be Our Guest Restaurant',
        parkId: 'mk',
        parkName: 'Magic Kingdom',
        currentWait: {'waitMinutes': 10, 'status': 'Open'},
      );

      await tester.pumpWidget(
        buildTestableWidget(
          SizedBox(
            height: 220,
            child: ExpandedFavoriteCard(favorite: favorite),
          ),
        ),
      );

      expect(find.text('Be Our Guest Restaurant'), findsOneWidget);
      expect(find.text('Swipe Right: View Menu'), findsOneWidget);
    },
  );

  testWidgets(
    'ExpandedFavoriteCard renders desktop buttons instead of swipe instructions',
    (tester) async {
      final favorite = FavoriteRide(
        rideId: 'space_mountain',
        name: 'Space Mountain',
        parkId: 'mk',
        parkName: 'Magic Kingdom',
        currentWait: {'waitMinutes': 45, 'status': 'Open'},
      );

      await tester.pumpWidget(
        buildTestableWidget(
          SizedBox(
            height: 220,
            child: ExpandedFavoriteCard(favorite: favorite),
          ),
          size: const Size(1200, 800),
        ),
      );

      expect(find.text('Swipe Right: Join Queue'), findsNothing);
      expect(find.text('Join Queue'), findsOneWidget);
      expect(find.text('Map'), findsOneWidget);
    },
  );

  testWidgets(
    'ExpandedFavoriteCard renders offline closed state contrast container',
    (tester) async {
      final favorite = FavoriteRide(
        rideId: 'hagrid',
        name: "Hagrid's Magical Creatures",
        parkId: 'ioa',
        parkName: 'Islands of Adventure',
        currentWait: {'waitMinutes': 0, 'status': 'Closed'},
      );

      await tester.pumpWidget(
        buildTestableWidget(
          SizedBox(
            height: 220,
            child: ExpandedFavoriteCard(favorite: favorite),
          ),
        ),
      );

      expect(find.text('OFFLINE'), findsOneWidget);
      expect(
        find.text('Temporarily closed for maintenance. Check back soon.'),
        findsOneWidget,
      );
    },
  );
}
