import 'package:exports/exports.dart';
import 'package:flutter/widgets.dart';
import 'package:test/test.dart';

void main() {
  group('SchemaOverride tests', () {
    test('resolveId resolves absolute URLs', () {
      final resolved = SchemaOverride.resolveId('123/456', 'https://example.com/schema.json');
      expect(resolved.url, 'https://example.com/schema.json');
      expect(resolved.blogId, null);
      expect(resolved.postId, null);
    });

    test('resolveId resolves direct blogId/postId string', () {
      final resolved = SchemaOverride.resolveId('123/456', '789/1011');
      expect(resolved.blogId, '789');
      expect(resolved.postId, '1011');
      expect(resolved.url, null);
    });

    test('resolveId resolves relative postId against base context', () {
      final resolved = SchemaOverride.resolveId('1774904866501098696/5522904867501094455', '9999');
      expect(resolved.blogId, '1774904866501098696');
      expect(resolved.postId, '9999');
    });

    test('deepMerge overrides target with source properties', () {
      final target = {
        'name': 'Product A',
        'price': 100,
        'offers': {'price': 100, 'currency': 'INR'},
      };
      final source = {
        'price': 80,
        'offers': {'price': 80},
      };

      final merged = SchemaOverride.deepMerge(target, source);
      expect(merged['name'], 'Product A');
      expect(merged['price'], 80);
      expect(merged['offers']['price'], 80);
      expect(merged['offers']['currency'], 'INR');
    });
  });

  group('CheckoutFlowEngine tests', () {
    test('requires login when unauthenticated', () {
      final result = CheckoutFlowEngine.evaluateCheckoutStep(
        isAuthenticated: false,
        hasPhoneLinked: false,
        hasVerifiedLocation: false,
      );

      expect(result.currentStep, CheckoutStep.loginRequired);
      expect(result.isReadyForPayment, isFalse);
    });

    test('requires phone verification when phone is unlinked', () {
      final result = CheckoutFlowEngine.evaluateCheckoutStep(
        isAuthenticated: true,
        hasPhoneLinked: false,
        hasVerifiedLocation: false,
      );

      expect(result.currentStep, CheckoutStep.phoneVerificationRequired);
      expect(result.isReadyForPayment, isFalse);
    });

    test('requires geo verification when location is unverified', () {
      final result = CheckoutFlowEngine.evaluateCheckoutStep(
        isAuthenticated: true,
        hasPhoneLinked: true,
        hasVerifiedLocation: false,
      );

      expect(result.currentStep, CheckoutStep.geoVerificationRequired);
      expect(result.isReadyForPayment, isFalse);
    });

    test('is ready for payment when all steps completed', () {
      final result = CheckoutFlowEngine.evaluateCheckoutStep(
        isAuthenticated: true,
        hasPhoneLinked: true,
        hasVerifiedLocation: true,
      );

      expect(result.currentStep, CheckoutStep.orderSummaryReady);
      expect(result.isReadyForPayment, isTrue);
    });
  });

  group('CatalogDetails Schema models tests', () {
    test('AmenityFeature serializes and deserializes', () {
      const feature = AmenityFeature(name: 'Free WiFi', value: 'Yes');
      final json = feature.toJson();
      expect(json['name'], 'Free WiFi');

      final parsed = AmenityFeature.fromJson(json);
      expect(parsed.name, 'Free WiFi');
      expect(parsed.value, 'Yes');
    });
  });

  group('PhoneValidator tests', () {
    test('sanitizes and formats E.164 phone string', () {
      final formatted = PhoneValidator.formatE164(
        rawPhone: '98765 43210',
        country: CountryCodeModel.defaultCountry,
      );
      expect(formatted, '+919876543210');
    });
  });
}
