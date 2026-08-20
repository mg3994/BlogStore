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

      final resEn = SchemaI18nResolver.resolve(
        arrayValue,
        preferredLocales: [const Locale('en')],
      );
      expect(resEn, 'The Count of Monte Cristo');
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
              'nestedAddOnGroups': [
                {
                  'id': 'extra_cheese',
                  'name': 'Cheese Type',
                  'isRequired': false,
                  'options': [
                    {
                      'id': 'mozzarella',
                      'name': 'Double Mozzarella',
                      'priceAdjustment': 30.0,
                    }
                  ]
                }
              ]
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

      final cheeseBurst = groups.first.options.last;
      expect(cheeseBurst.name, 'Cheese Burst');
      expect(cheeseBurst.priceAdjustment, 99.0);
      expect(cheeseBurst.nestedGroups.length, 1);
      expect(cheeseBurst.nestedGroups.first.title, 'Cheese Type');
    });

    test('calculates recursive total unit price and total price', () {
      const selected = [
        SelectedAddOn(
          groupId: 'crust_group',
          optionId: 'cheese_burst',
          optionName: 'Cheese Burst',
          priceAdjustment: 99.0,
          selectedSubAddOns: [
            SelectedAddOn(
              groupId: 'extra_cheese',
              optionId: 'mozzarella',
              optionName: 'Double Mozzarella',
              priceAdjustment: 30.0,
            )
          ],
        )
      ];

      final unitPrice = AddOnPriceCalculator.calculateUnitPrice(
        basePrice: 299.0,
        selectedAddOns: selected,
      );
      // 299 + 99 + 30 = 428
      expect(unitPrice, 428.0);

      final totalPrice = AddOnPriceCalculator.calculateTotalPrice(
        basePrice: 299.0,
        selectedAddOns: selected,
        quantity: 2,
      );
      // 428 * 2 = 856
      expect(totalPrice, 856.0);
    });

    test('validates selection errors for required groups', () {
      final groups = ProductAddOnParser.parseGroups(sampleSchema);

      // No selections -> should fail for required crust group
      final errors = AddOnPriceCalculator.validateGroupSelections(
        groups: groups,
        selectedAddOns: const [],
      );

      expect(errors.containsKey('crust_group'), isTrue);
    });
  });

  group('BloggerDataService tests', () {
    final service = BloggerDataService();

    test('decodeEntities decodes HTML entities correctly', () {
      const text = '&quot;hello&quot; &amp; &lt;world&gt; &#39;test&#39;';
      expect(BloggerDataService.decodeEntities(text), '"hello" & <world> \'test\'');
    });

    test('extractJsonLd extracts JSON from script tags', () {
      const content = '''
        <div>Some blog post content</div>
        <script type="application/ld+json">
          {
            "@context": "https://schema.org",
            "@type": "Product",
            "name": "Test Shirt",
            "offers": {
              "@type": "Offer",
              "price": "499"
            }
          }
        </script>
      ''';

      final schema = service.extractJsonLd(content);
      expect(schema, isNotNull);
      expect(schema!['@type'], 'Product');
      expect(schema['name'], 'Test Shirt');
      expect(schema['offers']['price'], '499');
    });

    test('extractJsonLd extracts raw JSON string', () {
      const content = '{"@context": "https://schema.org", "@type": "Product", "name": "Raw Shirt"}';
      final schema = service.extractJsonLd(content);
      expect(schema, isNotNull);
      expect(schema!['name'], 'Raw Shirt');
    });
  });

  group('AreaServedMatcher tests', () {
    const gurugramLocation = LocationModel(
      city: 'Gurugram',
      state: 'Haryana',
      country: 'India',
      postalCode: '122001',
    );

    test('returns true when areaServed is null', () {
      expect(
        AreaServedMatcher.isServiceable(
          areaServed: null,
          userLocation: gurugramLocation,
        ),
        isTrue,
      );
    });

    test('matches City object', () {
      final areaServed = {'@type': 'City', 'name': 'Gurugram'};
      expect(
        AreaServedMatcher.isServiceable(
          areaServed: areaServed,
          userLocation: gurugramLocation,
        ),
        isTrue,
      );
    });
  });

  group('PowerSearchParser tests', () {
    test('parses label: filters separated by pipe', () {
      final res = PowerSearchParser.parse('label:electronics|label:fashion shoes');
      expect(res.labels, containsAll(['electronics', 'fashion']));
      expect(res.textQuery, 'shoes');
    });

    test('appends user primary location (city or postal code) to search query', () {
      const loc = LocationModel(city: 'Gurugram');
      final res = PowerSearchParser.parse('label:clothing jacket', location: loc);
      expect(res.labels, ['clothing']);
      expect(res.textQuery, 'jacket Gurugram');
    });
  });
}
