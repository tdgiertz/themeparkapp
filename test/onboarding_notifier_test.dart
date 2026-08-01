import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:themeparkapp/core/onboarding_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('OnboardingNotifier initial state is false', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(onboardingProvider);
    expect(state, isFalse);
  });

  test(
    'OnboardingNotifier complete() sets state true and persists to SharedPreferences',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(onboardingProvider.notifier);
      await notifier.complete();
      expect(container.read(onboardingProvider), isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('onboarding_completed'), isTrue);
    },
  );

  test('OnboardingNotifier reset() clears prefs and resets to false', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(onboardingProvider.notifier);
    await notifier.complete();
    expect(container.read(onboardingProvider), isTrue);

    await notifier.reset();
    expect(container.read(onboardingProvider), isFalse);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('onboarding_completed'), isNull);
  });

  test(
    'Onboarding re-instantiation after complete() reads back true from prefs',
    () async {
      SharedPreferences.setMockInitialValues({'onboarding_completed': true});

      final container2 = ProviderContainer();
      addTearDown(container2.dispose);

      // Listen to onboardingProvider to ensure state listener updates
      container2.listen(onboardingProvider, (_, __) {});
      
      // Allow async _load to finish
      await Future<void>.delayed(Duration.zero);
      expect(container2.read(onboardingProvider), isTrue);
    },
  );
}
