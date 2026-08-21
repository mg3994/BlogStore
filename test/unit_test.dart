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

    test('builds Google Pay payment instrument data map', () {
      final data = GooglePayUpiService.buildPaymentInstrumentsData(
        orderId: 'ord_999',
        totalAmount: 499.50,
      );

      expect(data.containsKey('googlePayUPI'), isTrue);
      expect(data.containsKey('googlePayGlobal'), isTrue);
      expect(data['total']['value'], '499.50');
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

    test('returns isOpen false when current time is outside opening hours', () {
      final seller = {
        'openingHoursSpecification': [
          {
            'dayOfWeek': ['Monday'],
            'opens': '09:00',
            'closes': '17:00',
          }
        ]
      };

      final mondayNight = DateTime(2025, 8, 18, 23, 0); // Monday 23:00
      final result = BusinessHoursMatcher.isBusinessOpen(seller, now: mondayNight);
      expect(result.isOpen, isFalse);
      expect(result.message, contains('Closed'));
    });
  });

  group('SchemaExtractorHelpers tests', () {
    test('extracts lead time in minutes fromQuantitativeValue or string', () {
      final schemaHours = {
        'deliveryLeadTime': {'value': 2, 'unitCode': 'HUR'}
      };
      expect(SchemaExtractorHelpers.extractLeadTimeMinutes(schemaHours), 120);

      final schemaString = {'deliveryLeadTime': '35 mins'};
      expect(SchemaExtractorHelpers.extractLeadTimeMinutes(schemaString), 35);
    });

    test('extracts item condition', () {
      final schemaNew = {'itemCondition': 'https://schema.org/NewCondition'};
      expect(SchemaExtractorHelpers.extractItemCondition(schemaNew), 'New');

      final schemaRefurbished = {'itemCondition': 'https://schema.org/RefurbishedCondition'};
      expect(SchemaExtractorHelpers.extractItemCondition(schemaRefurbished), 'Refurbished');
    });

    test('extracts 3D model GLTF content URL', () {
      final schema3d = {
        'subjectOf': [
          {
            '@type': '3DModel',
            'encoding': {'contentUrl': 'https://example.com/model.glb'}
          }
        ]
      };
      expect(SchemaExtractorHelpers.extract3DModelUrl(schema3d), 'https://example.com/model.glb');
    });
  });

  group('AreaServedMatcher GeoCircle tests', () {
    test('matches location within GeoCircle radius', () {
      final area = {
        '@type': 'GeoCircle',
        'geoMidpoint': {'latitude': 28.4595, 'longitude': 77.0266}, // Gurugram center
        'geoRadius': 5000.0, // 5 km
      };

      // 1 km away
      const userLoc = LocationModel(latitude: 28.4600, longitude: 77.0300);
      expect(AreaServedMatcher.isServiceable(areaServed: area, userLocation: userLoc), isTrue);

      // 50 km away
      const farLoc = LocationModel(latitude: 28.9000, longitude: 77.9000);
      expect(AreaServedMatcher.isServiceable(areaServed: area, userLocation: farLoc), isFalse);
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

      await repo.addToCart(item);
      expect(repo.cartSignal.value.first.quantity, 2);

      await repo.removeFromCart('cart_1');
      expect(repo.cartSignal.value, isEmpty);
    });
  });

  group('Order & Payment DTO tests', () {
    test('OrderModel serializes to and from JSON correctly', () {
      final order = OrderModel(
        orderId: 'ord_123',
        blogId: '1774904866501098696',
        customerEmail: 'test@example.com',
        shippingAddress: const {'city': 'Gurugram', 'postalCode': '122001'},
        items: [
          CartItem(
            id: 'c1',
            postId: 'p1',
            blogId: '1774904866501098696',
            title: 'Item 1',
            unitPrice: 150.0,
            addedAt: DateTime.now(),
          )
        ],
        subtotal: 150.0,
        totalAmount: 150.0,
        createdAt: DateTime.now(),
      );

      final json = order.toJson();
      final parsed = OrderModel.fromJson(json);

      expect(parsed.orderId, 'ord_123');
      expect(parsed.customerEmail, 'test@example.com');
      expect(parsed.items.length, 1);
      expect(parsed.totalAmount, 150.0);
    });
  });
}
