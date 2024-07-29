import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  String uid;
  String requestName;
  String url;
  String method;
  String body;
  Map<String, dynamic> response;
  Map<String, String>? headers;  // New field for headers
  Map<String, dynamic>? queryParams;  // New field for query parameters
  Timestamp createdAt;
  Timestamp updatedAt;


  RequestModel({
    required this.uid,
    required this.requestName,
    required this.url,
    required this.method,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    required this.response,
    this.headers,
    this.queryParams,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'requestName': requestName,
      'url': url,
      'method': method,
      'body': body,
      'created_at': createdAt.toDate().toIso8601String(),
      'updated_at': updatedAt.toDate().toIso8601String(),
      'response': response,
      'headers': headers,
      'queryParams': queryParams,
    };
  }

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      uid: json['uid'] ?? '',
      requestName: json['requestName'] ?? '',
      url: json['url'] ?? '',
      method: json['method'] ?? '',
      body: json['body'] ?? '',
      createdAt: json['createdAt'] ?? Timestamp.now(),
      updatedAt: json['updatedAt'] ?? Timestamp.now(),
      response: json['response'] ?? {'responseStatusCode': 200, 'body': ''},
      headers: Map<String, String>.from(json['headers'] ?? {}),
      queryParams: Map<String, dynamic>.from(json['queryParams'] ?? {}),
    );
  }
}
