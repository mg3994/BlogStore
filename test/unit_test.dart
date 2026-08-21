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

  group('ToastNotificationService tests', () {
    test('dispatches and clears toast signals reactively', () {
      final toastService = ToastNotificationService();
      expect(toastService.currentToastSignal.value, isNull);

      toastService.showToast('Item added to bag', type: ToastType.success);
      expect(toastService.currentToastSignal.value, isNotNull);
      expect(toastService.currentToastSignal.value!.message, 'Item added to bag');
      expect(toastService.currentToastSignal.value!.type, ToastType.success);

      toastService.clearToast();
      expect(toastService.currentToastSignal.value, isNull);
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

  group('DeliveryTimeCalculator tests', () {
    test('parses travel minutes correctly', () {
      expect(DeliveryTimeCalculator.parseTravelMinutes('25 mins'), 25);
      expect(DeliveryTimeCalculator.parseTravelMinutes('1 hour'), 60);
    });
  });
}
