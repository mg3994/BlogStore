class GooglePayUpiService {
  static const String merchantVpa = 'manishsharma3994@okhdfcbank';
  static const String merchantName = 'Antinna';
  static const String merchantCode = '5251';

  /// Generates a standard UPI deep link string for Google Pay UPI transactions.
  static String buildUpiUri({
    required String orderId,
    required double amount,
    String currency = 'INR',
    String? note,
  }) {
    final tr = 'TR${DateTime.now().millisecondsSinceEpoch}';
    final tn = Uri.encodeComponent(note ?? 'Order $orderId from $merchantName');
    final formattedAmount = amount.toStringAsFixed(2);

    return 'upi://pay?'
        'pa=$merchantVpa&'
        'pn=${Uri.encodeComponent(merchantName)}&'
        'tr=$tr&'
        'mc=$merchantCode&'
        'am=$formattedAmount&'
        'cu=$currency&'
        'tn=$tn';
  }

  /// Builds Google Pay payment instrument data map for native Payment Request API.
  static Map<String, dynamic> buildPaymentInstrumentsData({
    required String orderId,
    required double totalAmount,
    String currency = 'INR',
  }) {
    final tr = 'TR${DateTime.now().millisecondsSinceEpoch}';

    return {
      'googlePayUPI': {
        'supportedMethods': 'https://tez.google.com/pay',
        'data': {
          'pa': merchantVpa,
          'pn': merchantName,
          'tr': tr,
          'mc': merchantCode,
          'tn': 'Order $orderId from $merchantName',
        },
      },
      'googlePayGlobal': {
        'supportedMethods': 'https://google.com/pay',
        'data': {
          'environment': 'PRODUCTION',
          'apiVersion': 2,
          'apiVersionMinor': 0,
          'merchantInfo': {
            'merchantId': 'BCR2DN5TVPLKL4KZ',
            'merchantName': merchantName,
          },
          'allowedPaymentMethods': [
            {
              'type': 'CARD',
              'parameters': {
                'allowedAuthMethods': ['PAN_ONLY', 'CRYPTOGRAM_3DS'],
                'allowedCardNetworks': ['MASTERCARD', 'VISA'],
              },
            },
          ],
        },
      },
      'total': {
        'currency': currency,
        'value': totalAmount.toStringAsFixed(2),
      },
    };
  }
}
