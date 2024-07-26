import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String email;
  String role;
  Timestamp createdAt;
  Timestamp updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'created_at': createdAt.toDate().toIso8601String(),
      'updated_at': updatedAt.toDate().toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      role: json['role'],
      createdAt: Timestamp.fromDate(DateTime.parse(json['created_at'])),
      updatedAt: Timestamp.fromDate(DateTime.parse(json['updated_at'])),
    );
  }
}
