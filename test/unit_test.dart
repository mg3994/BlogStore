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

  group('SessionManagerService tests', () {
    test('manages login, guest, and logout signal state', () {
      final session = SessionManagerService(initialClientId: 'client_1001');

      expect(session.clientId, 'client_1001');
      expect(session.isLoggedIn, isFalse);
      expect(session.sessionSignal.value.isGuest, isTrue);

      session.login(
        idToken: 'token_xyz',
        uid: 'user_123',
        email: 'user@example.com',
      );

      expect(session.isLoggedIn, isTrue);
      expect(session.idToken, 'token_xyz');
      expect(session.sessionSignal.value.uid, 'user_123');

      session.logout();
      expect(session.isLoggedIn, isFalse);
      expect(session.idToken, 'guest_session');
      expect(session.sessionSignal.value.isGuest, isTrue);
    });
  });

  group('FirebaseTokenVerifier & FCM Builder tests', () {
    test('decodes and validates synthetic Firebase JWT token payload', () {
      final header = base64Url.encode(utf8.encode('{"alg":"RS256","typ":"JWT"}')).replaceAll('=', '');
      final payload = base64Url.encode(utf8.encode('''
        {
          "iss": "https://securetoken.google.com/antinnamain",
          "aud": "antinnamain",
          "sub": "user_uid_123",
          "email": "user@example.com",
          "name": "Test User",
          "exp": ${Math.floor(DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch / 1000)}
        }
      ''')).replaceAll('=', '');
      final signature = base64Url.encode(utf8.encode('signature')).replaceAll('=', '');

      final mockToken = '$header.$payload.$signature';

      final decoded = FirebaseTokenVerifier.verifyTokenClaims(
        mockToken,
        projectId: 'antinnamain',
      );

      expect(decoded.isValid, isTrue);
      expect(decoded.uid, 'user_uid_123');
      expect(decoded.email, 'user@example.com');
      expect(decoded.displayName, 'Test User');
    });

    test('FcmNotificationBuilder generates correct HTTP v1 payload structure', () {
      final payload = FcmNotificationBuilder.buildMessagePayload(
        deviceToken: 'device_token_abc',
        title: 'Order Confirmed',
        body: 'Your order #123 has been placed.',
        data: {'orderId': '123'},
      );

      expect(payload['message']['token'], 'device_token_abc');
      expect(payload['message']['notification']['title'], 'Order Confirmed');
      expect(payload['message']['data']['orderId'], '123');
    });
  });
}

class Math {
  static int floor(double d) => d.floor();
}
