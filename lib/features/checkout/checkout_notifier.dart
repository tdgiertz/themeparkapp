import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lightweight checkout state representing processing and result.
class CheckoutState {
  /// Creates a fully-customized [CheckoutState].
  const CheckoutState({
    required this.processing,
    required this.success,
    this.message,
  });

  /// Initial (idle) state.
  const CheckoutState.initial()
    : processing = false,
      success = false,
      message = null;

  /// Processing state.
  const CheckoutState.loading()
    : processing = true,
      success = false,
      message = null;

  /// Success state with optional message.
  const CheckoutState.success([String? msg])
    : processing = false,
      success = true,
      message = msg;

  /// Failure state with optional message.
  const CheckoutState.failure([String? msg])
    : processing = false,
      success = false,
      message = msg;

  /// Whether a checkout is currently being processed.
  final bool processing;

  /// Whether the checkout finished successfully.
  final bool success;

  /// Optional human-readable message for result or error.
  final String? message;
}

/// An AsyncNotifier that performs a mock checkout flow.
class CheckoutNotifier extends AsyncNotifier<CheckoutState> {
  @override
  Future<CheckoutState> build() async {
    return const CheckoutState.initial();
  }

  /// Starts a simulated checkout process and updates state accordingly.
  Future<void> startCheckout() async {
    state = const AsyncValue.loading();
    try {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      state = const AsyncValue.data(CheckoutState.success('Order placed'));
    } catch (e) {
      state = AsyncValue.data(CheckoutState.failure(e.toString()));
    }
  }
}

/// Provider for the [CheckoutNotifier].
/// Provider for the [CheckoutNotifier].
final checkoutNotifierProvider =
    AsyncNotifierProvider<CheckoutNotifier, CheckoutState>(
      CheckoutNotifier.new,
    );
