import 'package:flutter/material.dart';
import 'payment_config.dart';
import 'payment_result.dart';
import 'payment_screen.dart';

/// The main entry point for the Payment SDK.
///
/// Usage from a host app:
/// ```dart
/// final result = await PaymentWidget.startPayment(
///   context: context,
///   config: PaymentConfig(
///     ereference: 'ORDER_123',
///     token: 'your_token',
///     url: 'https://your-callback.com',
///   ),
/// );
///
/// if (result.isSuccess) { /* handle success */ }
/// ```
class PaymentWidget {
  PaymentWidget._(); // prevent instantiation

  /// Launches the payment screen and returns a [PaymentResult]
  /// when the user completes, cancels, or encounters an error.
  static Future<PaymentResult> startPayment({
    required BuildContext context,
    required PaymentConfig config,
  }) async {
    // Validate config before navigating.
    final validationError = config.validate();
    if (validationError != null) {
      return PaymentResult.error(message: 'Invalid config: $validationError');
    }

    final result = await Navigator.of(context).push<PaymentResult>(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(config: config),
        fullscreenDialog: true,
      ),
    );

    // If the user pops via system back button, treat as cancel.
    return result ?? PaymentResult.cancel();
  }
}