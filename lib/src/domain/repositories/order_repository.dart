import '../models/order_model.dart';

abstract class IOrderRepository {
  Future<OrderModel> createOrder(OrderModel order, {String? idToken});
  Future<OrderModel?> getOrderById(String orderId, {String? idToken});
}
