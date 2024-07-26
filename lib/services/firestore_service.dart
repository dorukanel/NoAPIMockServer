import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createMockServer(String uid, String mockServerName, String ownerId) async {
    await _db.collection('mockServers').doc(uid).set({
      'uid': uid,
      'mockServerName': mockServerName,
      'ownerId': ownerId,
      'members': [ownerId],
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> addMockData(String mockServerId, String mockDataName, List<Map<String, dynamic>> mockData) async {
    var batch = _db.batch();
    for (var data in mockData) {
      var docRef = _db.collection('mockServers').doc(mockServerId).collection(mockDataName).doc();
      batch.set(docRef, data);
    }
    await batch.commit();
  }

  Future<Map<String, dynamic>?> getDocument(String collectionPath, String docId) async {
    print("Fetching document from path: $collectionPath/$docId");
    var doc = await _db.collection(collectionPath).doc(docId).get();
    return _convertDocumentToJson(doc);
  }

  Future<List<Map<String, dynamic>>> getCollection(String collectionPath) async {
    print("Fetching collection from path: $collectionPath");
    var snapshot = await _db.collection(collectionPath).get();
    return snapshot.docs.map((doc) => _convertDocumentToJson(doc)!).toList();
  }

  Future<void> createDocument(String collectionPath, Map<String, dynamic> data) async {
    await _db.collection(collectionPath).add(data);
  }

  Future<void> deleteDocument(String collectionPath, String docId) async {
    await _db.collection(collectionPath).doc(docId).delete();
  }

  Future<void> deleteCollection(String collectionPath) async {
    var snapshot = await _db.collection(collectionPath).get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Map<String, dynamic>? _convertDocumentToJson(DocumentSnapshot doc) {
    if (!doc.exists) return null;
    var data = doc.data() as Map<String, dynamic>;

    data.forEach((key, value) {
      if (value is Timestamp) {
        data[key] = value.toDate().toIso8601String();
      }
    });

    return data;
  }
}
