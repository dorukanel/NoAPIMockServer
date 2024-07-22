class Request {
  String? uid;
  String method;
  String endpoint;
  Map<String, dynamic>? queryParams;
  dynamic body;
  String? environment;

  Request({
    this.uid,
    required this.method,
    required this.endpoint,
    this.queryParams,
    this.body,
    this.environment,
  });

  Map<String, dynamic> toJson() {
    final data = {
      'uid': uid,
      'method': method,
      'endpoint': endpoint,
      'queryParams': queryParams,
      'body': body,
      'environment': environment,
    };
    return data..removeWhere((key, value) => value == null);
  }

  static Request fromJson(Map<String, dynamic> json) {
    return Request(
      uid: json['uid'],
      method: json['method'],
      endpoint: json['endpoint'],
      queryParams: json['queryParams'],
      body: json['body'],
      environment: json['environment'],
    );
  }
}
class RequestConfig {
  String method;
  String url;
  int responseCode;
  String responseBody;
  Map<String, dynamic>? queryParams;
  String? environment;

  RequestConfig({
    this.method = 'POST',
    this.url = '',
    this.responseCode = 200,
    this.responseBody = '',
    this.queryParams,
    this.environment,
  });
}
