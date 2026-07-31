import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themeparkapp/features/auth/auth_notifier.dart';

void main() {
  test('authNotifier login and logout', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(authNotifierProvider), false);

    await container
        .read(authNotifierProvider.notifier)
        .login(username: 'u', password: 'p');
    expect(container.read(authNotifierProvider), true);

    container.read(authNotifierProvider.notifier).logout();
    expect(container.read(authNotifierProvider), false);
  });
}
