import 'package:dio/dio.dart';
import '../../domain/models/order_model.dart';
import '../../domain/models/payment_record.dart';

class AntinnaOrderRemoteDataSource {
  final Dio dio;
  final String? clientId;

  static const String baseUrl = 'https://api.antinna.in';

  AntinnaOrderRemoteDataSource({
    required this.dio,
    this.clientId,
  });

  Map<String, String> _buildHeaders({String? idToken}) {
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    if (clientId != null && clientId!.isNotEmpty) {
      headers['X-Antinna-Client-Id'] = clientId!;
    }
    if (idToken != null && idToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $idToken';
    }
    return headers;
  }

  Future<OrderModel> createOrder(OrderModel order, {String? idToken}) async {
    final url = '$baseUrl/orders';
    final res = await dio.post(
      url,
      data: order.toJson(),
      options: Options(headers: _buildHeaders(idToken: idToken)),
    );

    if (res.data is Map<String, dynamic>) {
      return OrderModel.fromJson(res.data);
    }
    return order;
  }

  Future<OrderModel?> getOrderById(String orderId, {String? idToken}) async {
    final url = '$baseUrl/orders/$orderId';
    try {
      final res = await dio.get(
        url,
        options: Options(headers: _buildHeaders(idToken: idToken)),
      );

      if (res.data is Map<String, dynamic>) {
        return OrderModel.fromJson(res.data);
      }
    } catch (_) {}
    return null;
  }

  Future<bool> isOrderPaid(String orderId, {String? idToken}) async {
    final url = '$baseUrl/orders/$orderId/status';
    try {
      final res = await dio.get(
        url,
        options: Options(headers: _buildHeaders(idToken: idToken)),
      );

      if (res.data is Map<String, dynamic>) {
        final status = res.data['status']?.toString().toLowerCase();
        return status == 'paid' || status == 'success' || res.data['isPaid'] == true;
      }
    } catch (_) {}
    return false;
  }

  Future<List<Map<String, dynamic>>> listNotifications({
    int page = 1,
    int pageSize = 20,
    String? idToken,
  }) async {
    final url = '$baseUrl/notifications?page=$page&pageSize=$pageSize';
    try {
      final res = await dio.get(
        url,
        options: Options(headers: _buildHeaders(idToken: idToken)),
      );

      if (res.data is List) {
        return (res.data as List).whereType<Map<String, dynamic>>().toList();
      } else if (res.data is Map<String, dynamic> && res.data['notifications'] is List) {
        return (res.data['notifications'] as List).whereType<Map<String, dynamic>>().toList();
      }
    } catch (_) {}
    return const [];
  }

  Future<PaymentRecordResponse> recordPayment(
    PaymentRecordRequest payment, {
    String? idToken,
  }) async {
    final url = '$baseUrl/payments';
    final res = await dio.post(
      url,
      data: payment.toJson(),
      options: Options(headers: _buildHeaders(idToken: idToken)),
    );

    if (res.data is Map<String, dynamic>) {
      return PaymentRecordResponse.fromJson(res.data);
    }

    return PaymentRecordResponse(
      paymentId: 'pay_${DateTime.now().millisecondsSinceEpoch}',
      orderId: payment.orderId,
      status: 'pending',
      recordedAt: DateTime.now(),
    );
  }
}
