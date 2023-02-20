class KStrings {
  // APP
  static Map<String, dynamic> headers(String token) => {
        'Content-Type': 'application/json',
        'X-Android-Package': "com.rw.blogman",
        'X-Android-Cert':
            "DB:29:50:F4:B8:BD:54:61:B7:1C:16:60:06:70:B2:3B:DA:7D:25:01",
        "Authorization": "Bearer $token"
      };
  static const List<String> scopes = [
    "https://www.googleapis.com/auth/blogger",
    "https://www.googleapis.com/auth/blogger.readonly"
  ];

}
