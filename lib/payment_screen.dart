import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'payment_config.dart';
import 'payment_result.dart';

class PaymentScreen extends StatefulWidget {
  final PaymentConfig config;

  const PaymentScreen({
    super.key,
    required this.config,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const String paymentServerUrl = 'https://pay.blockbuilders.ps/plugin/';

  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final uri = Uri.parse(paymentServerUrl).replace(
      queryParameters: widget.config.toQueryParams(),
    );

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
    // Register a JS channel so the payment page can send results back.
      ..addJavaScriptChannel(
        'PaymentChannel',
        onMessageReceived: _onJsMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() {
            _isLoading = true;
            _error = null;
          }),
          onPageFinished: (_) {
            setState(() => _isLoading = false);
            // Inject a small JS bridge so the web page can call
            // PaymentChannel.postMessage(JSON.stringify({status, message}))
            _controller.runJavaScript(_bridgeScript);
          },
          onNavigationRequest: (request) {
            // Intercept custom scheme redirects (e.g. payment-callback://…)
            final url = request.url;
            if (url.startsWith('payment-success')) {
              _finishWith(PaymentResult.success(message: 'Payment completed'));
              return NavigationDecision.prevent;
            }
            if (url.startsWith('payment-cancel')) {
              _finishWith(PaymentResult.cancel());
              return NavigationDecision.prevent;
            }
            if (url.startsWith('payment-error')) {
              _finishWith(PaymentResult.error(message: 'Payment failed'));
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (err) => setState(() {
            _isLoading = false;
            _error = err.description;
          }),
        ),
      )
      ..loadRequest(uri);
  }

  /// Handles messages sent from the web page via the JS channel.
  void _onJsMessage(JavaScriptMessage msg) {
    try {
      final json = jsonDecode(msg.message) as Map<String, dynamic>;
      final status = json['status'] as String?;
      final message = json['message'] as String?;

      switch (status) {
        case 'success':
          _finishWith(PaymentResult.success(message: message, data: json));
          break;
        case 'error':
          _finishWith(PaymentResult.error(message: message ?? 'Unknown error'));
          break;
        case 'cancel':
          _finishWith(PaymentResult.cancel());
          break;
        default:
          debugPrint('PaymentSDK: unknown status "$status"');
      }
    } catch (e) {
      debugPrint('PaymentSDK: failed to parse JS message – $e');
    }
  }

  /// Pops this screen and returns the result to the caller.
  void _finishWith(PaymentResult result) {
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop(result);
    }
  }

  /// Small JS snippet injected after page load.
  /// It listens for a custom event the payment page may fire,
  /// and forwards it to the Flutter JS channel.
  static const String _bridgeScript = '''
    (function() {
      window.addEventListener('payment-result', function(e) {
        if (window.PaymentChannel) {
          PaymentChannel.postMessage(JSON.stringify(e.detail));
        }
      });
    })();
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _finishWith(PaymentResult.cancel()),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      'Something went wrong',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _error = null);
                        _initWebView();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}