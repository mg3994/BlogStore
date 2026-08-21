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

  group('CatalogDetails Schema models tests', () {
    test('AmenityFeature serializes and deserializes', () {
      const feature = AmenityFeature(name: 'Free WiFi', value: 'Yes');
      final json = feature.toJson();
      expect(json['name'], 'Free WiFi');

      final parsed = AmenityFeature.fromJson(json);
      expect(parsed.name, 'Free WiFi');
      expect(parsed.value, 'Yes');
    });

    test('Audience, Certification, and OfferCatalog parse JSON correctly', () {
      final audience = Audience.fromJson(const {
        'audienceType': 'Adults',
        'suggestedAge': {'name': '18+'}
      });
      expect(audience.audienceType, 'Adults');
      expect(audience.suggestedAge, '18+');

      final cert = Certification.fromJson(const {'name': 'ISO 9001', 'issuedBy': 'ISO'});
      expect(cert.name, 'ISO 9001');

      final catalog = OfferCatalog.fromJson(const {
        'name': 'Our Services',
        'itemListElement': [
          {'name': 'Car Wash', 'price': '200'}
        ]
      });
      expect(catalog.name, 'Our Services');
      expect(catalog.itemListElement.length, 1);
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
