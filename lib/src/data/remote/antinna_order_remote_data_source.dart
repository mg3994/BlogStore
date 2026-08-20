import 'package:dio/dio.dart';
import '../../domain/models/order_model.dart';
import '../../domain/models/payment_record.dart';

class AntinnaOrderRemoteDataSource {
  final Dio dio;
  static const String baseUrl = 'https://api.antinna.in';

  AntinnaOrderRemoteDataSource({required this.dio});

  Future<OrderModel> createOrder(OrderModel order, {String? idToken}) async {
    final url = '$baseUrl/orders';
    final res = await dio.post(
      url,
      data: order.toJson(),
      options: idToken != null && idToken.isNotEmpty
          ? Options(headers: {'Authorization': 'Bearer $idToken'})
          : null,
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
        options: idToken != null && idToken.isNotEmpty
            ? Options(headers: {'Authorization': 'Bearer $idToken'})
            : null,
      );

      if (res.data is Map<String, dynamic>) {
        return OrderModel.fromJson(res.data);
      }
    } catch (_) {}
    return null;
  }

  Future<PaymentRecordResponse> recordPayment(
    PaymentRecordRequest payment, {
    String? idToken,
  }) async {
    final url = '$baseUrl/payments';
    final res = await dio.post(
      url,
      data: payment.toJson(),
      options: idToken != null && idToken.isNotEmpty
          ? Options(headers: {'Authorization': 'Bearer $idToken'})
          : null,
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
