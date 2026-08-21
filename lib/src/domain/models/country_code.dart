class CountryCodeModel {
  final String code;
  final String flag;
  final String name;

  const CountryCodeModel({
    required this.code,
    required this.flag,
    required this.name,
  });

  static const List<CountryCodeModel> supportedCountries = [
    CountryCodeModel(code: '+91', flag: '🇮🇳', name: 'India'),
    CountryCodeModel(code: '+1', flag: '🇺🇸', name: 'USA'),
    CountryCodeModel(code: '+44', flag: '🇬🇧', name: 'UK'),
    CountryCodeModel(code: '+971', flag: '🇦🇪', name: 'UAE'),
    CountryCodeModel(code: '+1', flag: '🇨🇦', name: 'Canada'),
    CountryCodeModel(code: '+61', flag: '🇦🇺', name: 'Australia'),
  ];

  static const CountryCodeModel defaultCountry = CountryCodeModel(
    code: '+91',
    flag: '🇮🇳',
    name: 'India',
  );
}
