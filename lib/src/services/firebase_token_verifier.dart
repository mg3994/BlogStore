import 'dart:convert';

class DecodedFirebaseToken {
  final bool isValid;
  final String? uid;
  final String? email;
  final String? displayName;
  final String? issuer;
  final String? audience;
  final DateTime? expiration;
  final String? error;

  const DecodedFirebaseToken({
    required this.isValid,
    this.uid,
    this.email,
    this.displayName,
    this.issuer,
    this.audience,
    this.expiration,
    this.error,
  });

  bool get isExpired => expiration != null && DateTime.now().isAfter(expiration!);
}

class FirebaseTokenVerifier {
  /// Decodes and verifies Firebase JWT claims (issuer, audience, subject, expiration).
  static DecodedFirebaseToken verifyTokenClaims(
    String idToken, {
    String? projectId = 'antinnamain',
  }) {
    if (idToken.isEmpty || idToken == 'guest_session') {
      return const DecodedFirebaseToken(
        isValid: false,
        uid: 'guest',
        error: 'Guest session',
      );
    }

    final parts = idToken.split('.');
    if (parts.length != 3) {
      return const DecodedFirebaseToken(
        isValid: false,
        error: 'Invalid JWT format',
      );
    }

    try {
      final headerJson = _decodeJwtPart(parts[0]);
      final payloadJson = _decodeJwtPart(parts[1]);

      final header = jsonDecode(headerJson) as Map<String, dynamic>;
      final payload = jsonDecode(payloadJson) as Map<String, dynamic>;

      if (header['alg'] != 'RS256') {
        return const DecodedFirebaseToken(
          isValid: false,
          error: 'Invalid JWT algorithm',
        );
      }

      final iss = payload['iss'] as String?;
      final aud = payload['aud'] as String?;
      final sub = payload['sub'] as String?;
      final expSeconds = payload['exp'] as int?;

      if (projectId != null) {
        final expectedIssuer = 'https://securetoken.google.com/$projectId';
        if (iss != expectedIssuer) {
          return DecodedFirebaseToken(
            isValid: false,
            error: 'Invalid issuer: $iss',
          );
        }

        if (aud != projectId) {
          return DecodedFirebaseToken(
            isValid: false,
            error: 'Invalid audience: $aud',
          );
        }
      }

      if (sub == null || sub.isEmpty) {
        return const DecodedFirebaseToken(
          isValid: false,
          error: 'Invalid subject in token',
        );
      }

      DateTime? expiration;
      if (expSeconds != null) {
        expiration = DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000);
        if (DateTime.now().isAfter(expiration)) {
          return DecodedFirebaseToken(
            isValid: false,
            expiration: expiration,
            error: 'Token expired',
          );
        }
      }

      final uid = payload['user_id'] as String? ?? sub;
      final email = payload['email'] as String?;
      final name = payload['name'] as String?;

      return DecodedFirebaseToken(
        isValid: true,
        uid: uid,
        email: email,
        displayName: name,
        issuer: iss,
        audience: aud,
        expiration: expiration,
      );
    } catch (e) {
      return DecodedFirebaseToken(
        isValid: false,
        error: 'Failed to decode token: $e',
      );
    }
  }

  static String _decodeJwtPart(String part) {
    String normalized = part.replaceAll('-', '+').replaceAll('_', '/');
    while (normalized.length % 4 != 0) {
      normalized += '=';
    }
    return utf8.decode(base64.decode(normalized));
  }
}
