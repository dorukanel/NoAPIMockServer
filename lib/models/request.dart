class Request {
  String? uid;
  String method;
  String endpoint;
  Map<String, dynamic>? queryParams;
  dynamic body;
  String? environment;
  int? responseCode;  // Optional field for response code          TODO statusCode
  String? responseBody;  // Optional field for response body

  Request({
    this.uid,
    required this.method,
    required this.endpoint,
    this.queryParams,
    this.body,
    this.environment,
    this.responseCode,
    this.responseBody,
  });

  // Convert a Request instance to a JSON map
  Map<String, dynamic> toJson() {
    final data = {
      'uid': uid,
      'method': method,
      'endpoint': endpoint,
      'queryParams': queryParams,
      'body': body,
      'environment': environment,
      'responseCode': responseCode,
      'responseBody': responseBody,
    };
    return data..removeWhere((key, value) => value == null);
  }

  // Create a Request instance from a JSON map
  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      uid: json['uid'],
      method: json['method'],
      endpoint: json['endpoint'],
      queryParams: json['queryParams'],
      body: json['body'],
      environment: json['environment'],
      responseCode: json['responseCode'],
      responseBody: json['responseBody'],
    );
  }
}
