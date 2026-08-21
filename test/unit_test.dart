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

  group('PhoneValidator tests', () {
    test('sanitizes and formats E.164 phone string', () {
      final formatted = PhoneValidator.formatE164(
        rawPhone: '98765 43210',
        country: CountryCodeModel.defaultCountry,
      );
      expect(formatted, '+919876543210');
    });

    test('validates phone number and OTP code', () {
      expect(PhoneValidator.isValidPhoneNumber('9876543210'), isTrue);
      expect(PhoneValidator.isValidPhoneNumber('123'), isFalse);

      expect(PhoneValidator.isValidOtpCode('123456'), isTrue);
      expect(PhoneValidator.isValidOtpCode('1234'), isFalse);
    });
  });

  group('DeliveryTimeCalculator tests', () {
    test('parses travel minutes correctly', () {
      expect(DeliveryTimeCalculator.parseTravelMinutes('25 mins'), 25);
      expect(DeliveryTimeCalculator.parseTravelMinutes('1 hour'), 60);
    });

    test('calculates and formats total estimated delivery duration', () {
      final totalMins = DeliveryTimeCalculator.calculateTotalMinutes(
        travelMinutes: 20,
        maxLeadTimeMinutes: 55,
      );

      expect(totalMins, 75);
      expect(DeliveryTimeCalculator.formatDuration(totalMins), '1h 15m');
    });
  });

  group('ParcelDelivery & PostalAddress Schema tests', () {
    test('ParcelDelivery serializes and deserializes correctly', () {
      const delivery = ParcelDelivery(
        deliveryAddress: PostalAddress(
          extendedAddress: 'Apt 4B',
          streetAddress: 'Golf Course Road',
          addressLocality: 'Gurugram',
          addressRegion: 'HR',
          postalCode: '122001',
        ),
        latitude: 28.4595,
        longitude: 77.0266,
      );

      final json = delivery.toJson();
      expect(json['@type'], 'ParcelDelivery');
      expect(json['deliveryAddress']['addressLocality'], 'Gurugram');

      final parsed = ParcelDelivery.fromJson(json);
      expect(parsed.deliveryAddress.addressLocality, 'Gurugram');
    });
  });

  group('GooglePayUpiService tests', () {
    test('builds standard UPI payment URI string', () {
      final uri = GooglePayUpiService.buildUpiUri(
        orderId: 'ord_999',
        amount: 499.50,
      );

      expect(uri, contains('upi://pay?'));
      expect(uri, contains('pa=manishsharma3994@okhdfcbank'));
      expect(uri, contains('pn=Antinna'));
      expect(uri, contains('mc=5251'));
      expect(uri, contains('am=499.50'));
    });
  });
}
