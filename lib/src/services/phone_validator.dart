import '../domain/models/country_code.dart';

class PhoneValidator {
  /// Strips non-digit characters from phone input string.
  static String sanitizePhoneNumber(String rawPhone) {
    return rawPhone.replaceAll(RegExp(r'\D'), '').trim();
  }

  /// Formats sanitized phone number into full E.164 format (e.g. `+919876543210`).
  static String formatE164({
    required String rawPhone,
    CountryCodeModel country = CountryCodeModel.defaultCountry,
  }) {
    final sanitized = sanitizePhoneNumber(rawPhone);
    final countryCode = country.code.startsWith('+') ? country.code : '+${country.code}';
    return '$countryCode$sanitized';
  }

  /// Validates whether a phone number string meets minimum length requirements (7 to 15 digits).
  static bool isValidPhoneNumber(String rawPhone) {
    final sanitized = sanitizePhoneNumber(rawPhone);
    return sanitized.length >= 7 && sanitized.length <= 15;
  }

  /// Validates 6-digit OTP code string.
  static bool isValidOtpCode(String otp) {
    final sanitized = sanitizePhoneNumber(otp);
    return sanitized.length == 6;
  }
}
