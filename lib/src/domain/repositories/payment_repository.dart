import '../models/payment_record.dart';

abstract class IPaymentRepository {
  Future<PaymentRecordResponse> recordPayment(PaymentRecordRequest payment, {String? idToken});
}
