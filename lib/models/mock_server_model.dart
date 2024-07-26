import 'package:cloud_firestore/cloud_firestore.dart';

class MockServerModel {
  String uid;
  String mockServerName;
  String ownerId;
  List<String> members;
  Timestamp createdAt;
  Timestamp updatedAt;

  MockServerModel({
    required this.uid,
    required this.mockServerName,
    required this.ownerId,
    required this.members,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'mockServerName': mockServerName,
      'ownerId': ownerId,
      'members': members,
      'created_at': createdAt.toDate().toIso8601String(),
      'updated_at': updatedAt.toDate().toIso8601String(),
    };
  }

  factory MockServerModel.fromJson(Map<String, dynamic> json) {
    return MockServerModel(
      uid: json['uid'],
      mockServerName: json['mockServerName'],
      ownerId: json['ownerId'],
      members: List<String>.from(json['members']),
      createdAt: Timestamp.fromDate(DateTime.parse(json['created_at'])),
      updatedAt: Timestamp.fromDate(DateTime.parse(json['updated_at'])),
    );
  }
}
