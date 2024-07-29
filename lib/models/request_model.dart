import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  String uid;
  String requestName;
  String url;
  String method;
  String body;
  Timestamp createdAt;
  Timestamp updatedAt;
  Map<String, dynamic> response;

  RequestModel({
    required this.uid,
    required this.requestName,
    required this.url,
    required this.method,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    required this.response,
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
    );
  }
}
