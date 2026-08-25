class PaymentRecordRequest {
  final String orderId;
  final String paymentMethod; // 'apple_pay', 'google_pay', 'google_pay_upi'
  final String transactionReference;
  final double amount;
  final String currency;

  const PaymentRecordRequest({
    required this.orderId,
    required this.paymentMethod,
    required this.transactionReference,
    required this.amount,
    this.currency = 'INR',
  });

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'paymentMethod': paymentMethod,
        'transactionReference': transactionReference,
        'amount': amount,
        'currency': currency,
      };
}

class PaymentRecordResponse {
  final String paymentId;
  final String orderId;
  final String status; // 'success', 'pending', 'failed'
  final DateTime recordedAt;

  const PaymentRecordResponse({
    required this.paymentId,
    required this.orderId,
    required this.status,
    required this.recordedAt,
  });

  factory PaymentRecordResponse.fromJson(Map<String, dynamic> json) => PaymentRecordResponse(
        paymentId: json['paymentId'] as String? ?? '',
        orderId: json['orderId'] as String? ?? '',
        status: json['status'] as String? ?? 'pending',
        recordedAt: DateTime.tryParse(json['recordedAt'] as String? ?? '') ?? DateTime.now(),
      );
}
