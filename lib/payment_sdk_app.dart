import 'package:flutter/material.dart';
import 'package:payment_sdk/payment_config.dart';
import 'package:payment_sdk/payment_screen.dart';


class PaymentSdkApp extends StatelessWidget {
  final PaymentConfig config;

  const PaymentSdkApp({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Payment SDK',
      home: PaymentScreen(config: config),
    );
  }
}