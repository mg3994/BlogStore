import '../domain/models/parcel_delivery.dart';

enum CheckoutStep {
  loginRequired,
  phoneVerificationRequired,
  geoVerificationRequired,
  orderSummaryReady,
}

class CheckoutFlowResult {
  final CheckoutStep currentStep;
  final String? statusMessage;
  final bool isReadyForPayment;

  const CheckoutFlowResult({
    required this.currentStep,
    this.statusMessage,
    required this.isReadyForPayment,
  });
}

class CheckoutFlowEngine {
  /// Evaluates current user checkout progress and determines the next required step.
  static CheckoutFlowResult evaluateCheckoutStep({
    required bool isAuthenticated,
    required bool hasPhoneLinked,
    required bool hasVerifiedLocation,
    ParcelDelivery? parcelDelivery,
  }) {
    if (!isAuthenticated) {
      return const CheckoutFlowResult(
        currentStep: CheckoutStep.loginRequired,
        statusMessage: 'Please sign in to proceed with your order.',
        isReadyForPayment: false,
      );
    }

    if (!hasPhoneLinked) {
      return const CheckoutFlowResult(
        currentStep: CheckoutStep.phoneVerificationRequired,
        statusMessage: 'Phone number verification is required to continue.',
        isReadyForPayment: false,
      );
    }

    if (!hasVerifiedLocation && parcelDelivery == null) {
      return const CheckoutFlowResult(
        currentStep: CheckoutStep.geoVerificationRequired,
        statusMessage: 'Please confirm your exact delivery destination.',
        isReadyForPayment: false,
      );
    }

    return const CheckoutFlowResult(
      currentStep: CheckoutStep.orderSummaryReady,
      statusMessage: 'Ready for order review and payment.',
      isReadyForPayment: true,
    );
  }
}
