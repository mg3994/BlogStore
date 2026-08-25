import 'package:exports/exports.dart';

void main() async {
  print('=== Blog Store Clean Architecture Core Demo ===');

  print('\n[1] Environment Config:');
  print('Default Blog ID: ${EnvConfig.defaultBlogId}');
  print('Blogger Feeds URL: ${EnvConfig.bloggerFeedsBaseUrl}');

  print('\n[2] Power Search Parser:');
  const loc = LocationModel(city: 'Gurugram', postalCode: '122001');
  final searchResult = PowerSearchParser.parse(
    'label:electronics|label:sale smartphone',
    location: loc,
  );
  print('Parsed Labels: ${searchResult.labels}');
  print('Parsed Query with Location: ${searchResult.textQuery}');

  print('\n[3] JSON-LD Schema Extraction & I18n:');
  final service = BloggerDataService();
  const sampleContent = '''
    <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "Product",
      "name": [
        {"@value": "Smart Thermostat Series", "@language": "en"},
        {"@value": "स्मार्ट थर्मोस्टेट श्रृंखला", "@language": "hi"}
      ],
      "offers": {
        "@type": "Offer",
        "price": "4999",
        "priceCurrency": "INR",
        "availability": "https://schema.org/InStock"
      }
    }
    </script>
  ''';
  final schema = service.extractJsonLd(sampleContent);
  final englishName = SchemaI18nResolver.resolve(schema?['name'], defaultLanguage: 'en');
  final hindiName = SchemaI18nResolver.resolve(schema?['name'], defaultLanguage: 'hi');

  print('Extracted English Title: $englishName');
  print('Extracted Hindi Title: $hindiName');

  print('\n[4] Geo-Location Serviceability Matching:');
  final isServiceable = AreaServedMatcher.isServiceable(
    areaServed: const {'@type': 'City', 'name': 'Gurugram'},
    userLocation: loc,
  );
  print('Is Gurugram serviceable: $isServiceable');

  print('\n[5] Google Pay UPI Payment URI Builder:');
  final upiUri = GooglePayUpiService.buildUpiUri(
    orderId: 'ORD_1001',
    amount: 4999.00,
  );
  print('UPI URI: $upiUri');

  print('\n=== Core Initialization Complete ===');
}
