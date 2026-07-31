import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:themeparkapp/core/onboarding_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('OnboardingNotifier initial state is false', () {
    final notifier = OnboardingNotifier();
    expect(notifier.state, isFalse);
  });

  test('OnboardingNotifier complete() sets state true and persists to SharedPreferences', () async {
    final notifier = OnboardingNotifier();
    await notifier.complete();
    expect(notifier.state, isTrue);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('onboarding_completed'), isTrue);
  });

  test('OnboardingNotifier reset() clears prefs and resets to false', () async {
    final notifier = OnboardingNotifier();
    await notifier.complete();
    expect(notifier.state, isTrue);

    await notifier.reset();
    expect(notifier.state, isFalse);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('onboarding_completed'), isNull);
  });

  test('OnboardingNotifier re-instantiation after complete() reads back true from prefs', () async {
    final notifier1 = OnboardingNotifier();
    await notifier1.complete();

    final notifier2 = OnboardingNotifier();
    // Allow async _load to finish
    await Future<void>.delayed(Duration.zero);
    expect(notifier2.state, isTrue);
  });
}
