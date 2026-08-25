import 'dart:convert';
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

  group('DimensionsModel & AdvanceBookingRequirement tests', () {
    test('DimensionsModel parses physical dimensions from JSON', () {
      final json = {
        'weight': {'value': '0.35', 'unitCode': 'KGM'},
        'height': {'value': '75', 'unitCode': 'CMT'},
        'width': {'value': '55', 'unitCode': 'CMT'},
      };

      final dims = DimensionsModel.fromJson(json);
      expect(dims.weight, 0.35);
      expect(dims.height, 75.0);
      expect(dims.width, 55.0);
    });

    test('extractAdvanceBookingRequirement and accepted payment methods', () {
      final schema = {
        'advanceBookingRequirement': {'value': '24', 'unitCode': 'HUR'},
        'acceptedPaymentMethod': [
          'https://schema.org/CreditCard',
          'https://schema.org/Cash'
        ]
      };

      final abr = SchemaExtractorHelpers.extractAdvanceBookingRequirement(schema);
      expect(abr, '24 Hours');

      final payments = SchemaExtractorHelpers.extractAcceptedPaymentMethods(schema);
      expect(payments, containsAll(['CreditCard', 'Cash']));
    });
  });

  group('ItemAvailability tests', () {
    test('parses Schema.org availability URLs and strings', () {
      expect(ItemAvailability.parse('https://schema.org/InStock').isAvailable, isTrue);
      expect(ItemAvailability.parse('https://schema.org/OutOfStock').isAvailable, isFalse);
    });
  });

  group('UserProfileModel & DeviceSyncPayload tests', () {
    test('UserProfileModel serializes and checks phone linking', () {
      const user = UserProfileModel(
        uid: 'user_123',
        displayName: 'John Doe',
        email: 'john@example.com',
        phoneNumber: '+919876543210',
      );

      expect(user.hasPhoneLinked, isTrue);

      final json = user.toJson();
      final parsed = UserProfileModel.fromJson(json);

      expect(parsed.uid, 'user_123');
      expect(parsed.displayName, 'John Doe');
      expect(parsed.hasPhoneLinked, isTrue);
    });
  });
}
