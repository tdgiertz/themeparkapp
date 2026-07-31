import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Auth notifier.
class AuthNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Simulates a login flow and sets the authenticated state to `true`.
  Future<void> login({
    required String username,
    required String password,
  }) async {
    // Simulate network latency
    await Future<void>.delayed(const Duration(milliseconds: 250));
    state = true;
  }

  /// Logs the user out immediately.
  void logout() {
    state = false;
  }
}

/// Provider for the [AuthNotifier].
/// Provider for [AuthNotifier].
final authNotifierProvider = NotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);
