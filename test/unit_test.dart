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

      // Adding same item increases quantity
      await repo.addToCart(item);
      expect(repo.cartSignal.value.first.quantity, 2);

      await repo.removeFromCart('cart_1');
      expect(repo.cartSignal.value, isEmpty);
    });

    test('LocalWishlistRepository updates wishlistSignal reactively', () async {
      final repo = LocalWishlistRepository();
      final item = WishlistItem(
        id: 'wish_1',
        postId: 'post_1',
        blogId: '1774904866501098696',
        title: 'Wishlist Item',
        addedAt: DateTime.now(),
      );

      expect(repo.wishlistSignal.value, isEmpty);

      await repo.addToWishlist(item);
      expect(repo.wishlistSignal.value.length, 1);
      expect(await repo.isInWishlist('post_1'), isTrue);

      await repo.removeFromWishlist('wish_1');
      expect(repo.wishlistSignal.value, isEmpty);
      expect(await repo.isInWishlist('post_1'), isFalse);
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

    test('PaymentRecordRequest formats JSON payload for api.antinna.in', () {
      const paymentReq = PaymentRecordRequest(
        orderId: 'ord_123',
        paymentMethod: 'google_pay_upi',
        transactionReference: 'upi_ref_9999',
        amount: 150.0,
      );

      final json = paymentReq.toJson();
      expect(json['orderId'], 'ord_123');
      expect(json['paymentMethod'], 'google_pay_upi');
      expect(json['transactionReference'], 'upi_ref_9999');
      expect(json['amount'], 150.0);
    });
  });

  group('SchemaI18nResolver tests', () {
    test('resolves simple string', () {
      expect(SchemaI18nResolver.resolve('Simple Title'), 'Simple Title');
    });

    test('resolves single localized value object', () {
      final value = {'@value': 'French Title', '@language': 'fr'};
      expect(SchemaI18nResolver.resolve(value), 'French Title');
    });

    test('resolves matching language from array of localized values', () {
      final arrayValue = [
        {'@value': 'The Count of Monte Cristo', '@language': 'en'},
        {'@value': 'Le Comte de Monte-Cristo', '@language': 'fr'},
      ];

      final resFr = SchemaI18nResolver.resolve(
        arrayValue,
        preferredLocales: [const Locale('fr')],
      );
      expect(resFr, 'Le Comte de Monte-Cristo');
    });
  });

  group('ProductAddOnParser & AddOnPriceCalculator tests', () {
    final sampleSchema = {
      'name': 'Custom Pizza',
      'price': 299.0,
      'addOn': [
        {
          'id': 'crust_group',
          'name': 'Choose Crust',
          'isRequired': true,
          'minSelect': 1,
          'maxSelect': 1,
          'options': [
            {
              'id': 'pan_crust',
              'name': 'Pan Crust',
              'priceAdjustment': 0.0,
            },
            {
              'id': 'cheese_burst',
              'name': 'Cheese Burst',
              'priceAdjustment': 99.0,
            }
          ]
        }
      ]
    };

    test('parses nested add-on groups and options', () {
      final groups = ProductAddOnParser.parseGroups(sampleSchema);
      expect(groups.length, 1);
      expect(groups.first.title, 'Choose Crust');
      expect(groups.first.options.length, 2);
    });
  });
}
