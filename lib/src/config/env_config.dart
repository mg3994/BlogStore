class EnvConfig {
  static const String defaultBlogId = String.fromEnvironment(
    'BLOG_ID',
    defaultValue: '1774904866501098696',
  );

  static const String bloggerFeedsBaseUrl = 'https://www.blogger.com/feeds';
  static const String bloggerV3ApiBaseUrl = 'https://www.googleapis.com/blogger/v3';
}
