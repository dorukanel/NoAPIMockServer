class Response {
  int statusCode;
  dynamic body;
  Map<String, String>? headers;
  String? errorMessage;
  DateTime? timestamp;

  Response({
    required this.statusCode,
    this.body,
    this.headers,
    this.errorMessage,
    this.timestamp,
  });

  Map<String, dynamic> toJson() {
    final data = {
      'statusCode': statusCode,
      'body': body,
      'headers': headers,
      'errorMessage': errorMessage,
      'timestamp': timestamp?.toIso8601String(),
    };
    return data..removeWhere((key, value) => value == null);
  }

  static Response fromJson(Map<String, dynamic> json) {
    return Response(
      statusCode: json['statusCode'],
      body: json['body'],
      headers: Map<String, String>.from(json['headers']),
      errorMessage: json['errorMessage'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
