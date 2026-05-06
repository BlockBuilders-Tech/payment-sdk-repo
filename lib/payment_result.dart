enum PaymentStatus {
  success,
  error,
  cancel,
}

class PaymentResult {
  final PaymentStatus status;
  final String? message;
  final Map<String, dynamic>? data;

  const PaymentResult({
    required this.status,
    this.message,
    this.data,
  });

  factory PaymentResult.success({String? message, Map<String, dynamic>? data}) =>
      PaymentResult(status: PaymentStatus.success, message: message, data: data);

  factory PaymentResult.error({String? message}) =>
      PaymentResult(status: PaymentStatus.error, message: message);

  factory PaymentResult.cancel() =>
      const PaymentResult(status: PaymentStatus.cancel, message: 'Payment cancelled by user');

  bool get isSuccess => status == PaymentStatus.success;
  bool get isError => status == PaymentStatus.error;
  bool get isCancelled => status == PaymentStatus.cancel;

  @override
  String toString() => 'PaymentResult(status: $status, message: $message, data: $data)';
}