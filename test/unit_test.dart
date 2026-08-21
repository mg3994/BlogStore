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
      expect(parsed.latitude, 28.4595);
      expect(parsed.longitude, 77.0266);
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

  group('BusinessHoursMatcher tests', () {
    test('returns isOpen true when regular hours match current time', () {
      final seller = {
        'openingHoursSpecification': [
          {
            'dayOfWeek': ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
            'opens': '08:00',
            'closes': '22:00',
          }
        ]
      };

      final mondayAtTen = DateTime(2025, 8, 18, 10, 0); // Monday 10:00
      final result = BusinessHoursMatcher.isBusinessOpen(seller, now: mondayAtTen);
      expect(result.isOpen, isTrue);
    });
  });

  group('Cart & Wishlist Signal State Management tests', () {
    test('LocalCartRepository updates cartSignal reactively', () async {
      final repo = LocalCartRepository();
      final item = CartItem(
        id: 'cart_1',
        postId: 'post_1',
        blogId: '1774904866501098696',
        title: 'Test Item',
        unitPrice: 100.0,
        addedAt: DateTime.now(),
      );

      expect(repo.cartSignal.value, isEmpty);

      await repo.addToCart(item);
      expect(repo.cartSignal.value.length, 1);
      expect(repo.cartItems.first.quantity, 1);
    });
  });
}
