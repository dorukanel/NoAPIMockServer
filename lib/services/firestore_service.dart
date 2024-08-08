import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createRequest(String mockServerId, RequestModel request) async {
    bool exists = await requestExists(mockServerId, request.url, request.method);
    if (!exists) {
      await _db
          .collection('mockServers')
          .doc(mockServerId)
          .collection('requests')
          .doc(request.uid)
          .set(request.toJson());
    }
  }

  Future<bool> requestExists(String mockServerId, String url, String method) async {
    QuerySnapshot snapshot = await _db
        .collection('mockServers')
        .doc(mockServerId)
        .collection('requests')
        .where('url', isEqualTo: url)
        .where('method', isEqualTo: method)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<List<RequestModel>> getRequests(String mockServerId) async {
    QuerySnapshot snapshot = await _db.collection('mockServers').doc(mockServerId).collection('requests').get();
    return snapshot.docs.map((doc) => RequestModel.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<List<Map<String, dynamic>>> getCollection(String path, Map<String, dynamic>? queryParams) async {
    Query query = _db.collection(path);
    queryParams?.forEach((key, value) {
      query = query.where(key, isEqualTo: value);
    });
    QuerySnapshot snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>?> getDocument(String path, String docId) async {
    DocumentSnapshot doc = await _db.collection(path).doc(docId).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }
  Future<RequestModel?> getRequestByUrlAndMethod(String mockServerId, String url, String method) async {
    QuerySnapshot snapshot = await _db
        .collection('mockServers')
        .doc(mockServerId)
        .collection('requests')
        .where('url', isEqualTo: url)
        .where('method', isEqualTo: method)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return RequestModel.fromJson(snapshot.docs.first.data() as Map<String, dynamic>);
    }
    return null;
  }
}
