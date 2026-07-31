import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themeparkapp/features/checkout/checkout_notifier.dart';

void main() {
  test('checkoutNotifier starts and completes', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(checkoutNotifierProvider.notifier);
    final initial = await container.read(checkoutNotifierProvider.future);
    expect(initial.processing, false);

    await notifier.startCheckout();
    final after = await container.read(checkoutNotifierProvider.future);
    expect(after.success, true);
  });
}
