class FcmNotificationBuilder {
  /// Builds an FCM HTTP v1 JSON notification payload for a target device token.
  static Map<String, dynamic> buildMessagePayload({
    required String deviceToken,
    required String title,
    required String body,
    Map<String, String>? data,
  }) {
    return {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': title,
          'body': body,
        },
        if (data != null && data.isNotEmpty) 'data': data,
      }
    };
  }

  /// Builds an FCM HTTP v1 JSON notification payload for a target FCM topic.
  static Map<String, dynamic> buildTopicMessagePayload({
    required String topic,
    required String title,
    required String body,
    Map<String, String>? data,
  }) {
    return {
      'message': {
        'topic': topic,
        'notification': {
          'title': title,
          'body': body,
        },
        if (data != null && data.isNotEmpty) 'data': data,
      }
    };
  }
}
