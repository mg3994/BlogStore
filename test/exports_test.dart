import 'package:exports/exports.dart';
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

    test('fetchPostSchema uses v3 API when idToken is provided', () async {
      String? requestedUrl;
      Map<String, String>? requestedHeaders;

      final serviceWithMock = BloggerDataService(
        customFetcher: (url, {headers}) async {
          requestedUrl = url;
          requestedHeaders = headers;
          if (url.contains('googleapis.com/blogger/v3')) {
            return '{"content": "<script type=\\"application/ld+json\\">{\\"@type\\": \\"Product\\", \\"name\\": \\"Auth Product\\"}</script>"}';
          }
          return null;
        },
      );

      final schema = await serviceWithMock.fetchPostSchema(
        blogId: '123',
        postId: '456',
        idToken: 'test-token-123',
      );

      expect(requestedUrl, 'https://www.googleapis.com/blogger/v3/blogs/123/posts/456');
      expect(requestedHeaders?['Authorization'], 'Bearer test-token-123');
      expect(schema, isNotNull);
      expect(schema!['name'], 'Auth Product');
    });

    test('fetchPostSchema uses Feeds API when idToken is omitted', () async {
      String? requestedUrl;

      final serviceWithMock = BloggerDataService(
        customFetcher: (url, {headers}) async {
          requestedUrl = url;
          return '{"entry": {"content": {"\$t": "{\\"@type\\": \\"Product\\", \\"name\\": \\"Feed Product\\"}"}}}';
        },
      );

      final schema = await serviceWithMock.fetchPostSchema(
        blogId: '123',
        postId: '456',
      );

      expect(requestedUrl, 'https://www.blogger.com/feeds/123/posts/default/456?alt=json');
      expect(schema, isNotNull);
      expect(schema!['name'], 'Feed Product');
    });

    test('resolveAndLoadSchema resolves and deep merges @id reference', () async {
      final mockDataService = BloggerDataService(
        customFetcher: (url, {headers}) async {
          if (url.contains('555')) {
            return '''
              {
                "entry": {
                  "content": {
                    "\$t": "<script type=\\"application/ld+json\\">{\\"@type\\": \\"Product\\", \\"name\\": \\"Parent Product\\", \\"description\\": \\"Base Description\\", \\"sku\\": \\"123\\"}</script>"
                  }
                }
              }
            ''';
          }
          return null;
        },
      );

      final initialSchema = {
        '@context': 'https://schema.org',
        '@id': '1774904866501098696/555',
        'name': 'Overridden Product Name',
        'price': 299,
      };

      final resolved = await mockDataService.resolveAndLoadSchema(
        initialSchema,
        base: '1774904866501098696/initial',
      );

      expect(resolved['name'], 'Overridden Product Name');
      expect(resolved['description'], 'Base Description');
      expect(resolved['sku'], '123');
      expect(resolved['price'], 299);
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

    test('matches State object', () {
      final areaServed = {'@type': 'State', 'name': 'Haryana'};
      expect(
        AreaServedMatcher.isServiceable(
          areaServed: areaServed,
          userLocation: gurugramLocation,
        ),
        isTrue,
      );
    });

    test('matches Country object for all cities in that country', () {
      final areaServed = {'@type': 'Country', 'name': 'India'};
      expect(
        AreaServedMatcher.isServiceable(
          areaServed: areaServed,
          userLocation: gurugramLocation,
        ),
        isTrue,
      );
    });

    test('fails when location is outside areaServed', () {
      final areaServed = {'@type': 'City', 'name': 'Mumbai'};
      expect(
        AreaServedMatcher.isServiceable(
          areaServed: areaServed,
          userLocation: gurugramLocation,
        ),
        isFalse,
      );
    });

    test('matches list of areas', () {
      final areaServed = [
        {'@type': 'City', 'name': 'Delhi'},
        {'@type': 'City', 'name': 'Gurugram'},
      ];
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

    test('parses space separated labels and text', () {
      final res = PowerSearchParser.parse('label:sale label:electronics summer dress');
      expect(res.labels, containsAll(['sale', 'electronics']));
      expect(res.textQuery, 'summer dress');
    });

    test('appends user primary location (city or postal code) to search query', () {
      const loc = LocationModel(city: 'Gurugram');
      final res = PowerSearchParser.parse('label:clothing jacket', location: loc);
      expect(res.labels, ['clothing']);
      expect(res.textQuery, 'jacket Gurugram');
    });

    test('returns location alone if query string is empty', () {
      const loc = LocationModel(postalCode: '110001');
      final res = PowerSearchParser.parse('', location: loc);
      expect(res.labels, isEmpty);
      expect(res.textQuery, '110001');
    });
  });
}
