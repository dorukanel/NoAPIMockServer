import 'package:cloud_firestore/cloud_firestore.dart';

class CollectionModel {
  String uid;
  String projectName;
  Timestamp createdAt;
  Timestamp updatedAt;

  CollectionModel({
    required this.uid,
    required this.projectName,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'projectName': projectName,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      uid: json['uid'],
      projectName: json['projectName'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
