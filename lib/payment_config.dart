/// Configuration for initiating a payment session.
class PaymentConfig {
  final String ereference;
  final String token;
  final String url;
  final String lang;

  const PaymentConfig({
    required this.ereference,
    required this.token,
    required this.url,
    this.lang = 'en',
  });

  /// Basic validation before launching the payment screen.
  String? validate() {
    if (ereference.trim().isEmpty) return 'ereference is required';
    if (token.trim().isEmpty) return 'token is required';
    if (url.trim().isEmpty) return 'url is required';
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return 'url is not a valid URL';
    return null; // null == valid
  }

  Map<String, String> toQueryParams() {
    return {
      'ereference': ereference,
      'token': token,
      'url': url,
      'lang': lang,
    };
  }
}