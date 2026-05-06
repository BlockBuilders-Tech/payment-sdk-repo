import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:payment_sdk/payment_config.dart';
import 'payment_sdk_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final routeString = ui.PlatformDispatcher.instance.defaultRouteName;
  final uri = Uri.parse(routeString);
  final params = uri.queryParameters;

  debugPrint('PaymentSDK routeString: $routeString');
  debugPrint('PaymentSDK params: $params');

  final config = params.isNotEmpty
      ? PaymentConfig(
    ereference: params['ereference'] ?? '',
    token: params['token'] ?? '',
    url: params['url'] ?? '',
    lang: params['lang'] ?? 'en',
  )
      : const PaymentConfig(
    ereference: '',
    token: '',
    url: '',
    lang: 'en',
  );

  final validationError = config.validate();

  if (validationError != null) {
    debugPrint('PaymentSDK validation error: $validationError');

    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Text(
              'Payment SDK Error:\n$validationError',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 18),
            ),
          ),
        ),
      ),
    );
    return;
  }

  runApp(PaymentSdkApp(config: config));
}