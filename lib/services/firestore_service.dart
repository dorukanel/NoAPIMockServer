import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createRequest(String mockServerId, RequestModel request) async {
    await _db.collection('mockServers').doc(mockServerId).collection('requests').doc(request.uid).set(request.toJson());
  }

  Future<List<RequestModel>> getRequests(String mockServerId) async {
    QuerySnapshot snapshot = await _db.collection('mockServers').doc(mockServerId).collection('requests').get();
    return snapshot.docs.map((doc) => RequestModel.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<List<Map<String, dynamic>>> getCollection(String path, Map<String, dynamic>? queryParams) async {
    print("Fetching collection from path: $path with queryParams: $queryParams");
    Query query = _db.collection(path);
    queryParams?.forEach((key, value) {
      query = query.where(key, isEqualTo: value);
    });
    QuerySnapshot snapshot = await query.get();
    print("Fetched collection data: ${snapshot.docs.map((doc) => doc.data()).toList()}");
    return snapshot.docs.map((doc) => {
      'body': doc['body'],
      'response': doc['response'],
    }).toList();
  }

  Future<Map<String, dynamic>?> getDocument(String path, String docId) async {
    print("Fetching document from path: $path with docId: $docId");
    DocumentSnapshot doc = await _db.collection(path).doc(docId).get();
    if (doc.exists) {
      print("Fetched document data: ${doc.data()}");
      return {
        'body': doc['body'],
        'response': doc['response'],
      };
    }
    print("Document not found");
    return null;
  }
}
