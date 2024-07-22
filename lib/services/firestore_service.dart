import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/request.dart';
import '../models/response.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createRequest(Request request) async {
    await _db.collection('requests').add(request.toJson());
  }

  Stream<List<Request>> getRequests() {
    return _db.collection('requests').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Request.fromJson(doc.data())).toList());
  }

  Future<void> updateRequest(String id, Request request) async {
    await _db.collection('requests').doc(id).update(request.toJson());
  }

  Future<void> deleteRequest(String id) async {
    await _db.collection('requests').doc(id).delete();
  }

  Future<void> createResponse(Response response) async {
    await _db.collection('responses').add(response.toJson());
  }

  Stream<List<Response>> getResponses() {
    return _db.collection('responses').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Response.fromJson(doc.data())).toList());
  }

  Future<void> updateResponse(String id, Response response) async {
    await _db.collection('responses').doc(id).update(response.toJson());
  }

  Future<void> deleteResponse(String id) async {
    await _db.collection('responses').doc(id).delete();
  }

  Future<Response> getRequest(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return Response(
          statusCode: response.statusCode,
          body: json.decode(response.body),
          headers: response.headers,
        );
      } else {
        return Response(
          statusCode: response.statusCode,
          errorMessage: 'Failed to load document',
        );
      }
    } catch (e) {
      return Response(
        statusCode: 500,
        errorMessage: e.toString(),
      );
    }
  }
}
