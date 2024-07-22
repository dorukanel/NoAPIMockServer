import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request.dart';
import '../models/response.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createRequest(Request request) async {
    await _db.collection('requests').add(request.toJson());
  }

  Future<List<Request>> getRequests() async {
    var snapshot = await _db.collection('requests').get();
    return snapshot.docs.map((doc) => Request.fromJson(doc.data() as Map<String, dynamic>)).toList();
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

  Future<List<Response>> getResponses() async {
    var snapshot = await _db.collection('responses').get();
    return snapshot.docs.map((doc) => Response.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> updateResponse(String id, Response response) async {
    await _db.collection('responses').doc(id).update(response.toJson());
  }

  Future<void> deleteResponse(String id) async {
    await _db.collection('responses').doc(id).delete();
  }

  Future<Map<String, dynamic>?> getDocument(String collectionPath, String docId) async {
    var doc = await _db.collection(collectionPath).doc(docId).get();
    return doc.exists ? doc.data() : null;
  }

  Future<List<Map<String, dynamic>>> getCollection(String path) async {
    var snapshot = await _db.collection(path).get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<void> createDocument(String collectionPath, Map<String, dynamic> data) async {
    await _db.collection(collectionPath).add(data);
  }
  Future<void> deleteDocument(String collectionPath, String docId) async {
    await _db.collection(collectionPath).doc(docId).delete();
  }
  Future<void> deleteCollection(String collectionPath) async {
    var snapshot = await _db.collection(collectionPath).get();
    for(var doc in snapshot.docs){
      await doc.reference.delete();
    }
  }
}

