import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addUser(User user) async {
    await _db.collection('users').add(user.toMap());
  }
  Future<void> deleteUser(String userId) async {
    await _db.collection('users').doc(userId).delete();
  }
  Future<void> updateUser(String userId, Map<String, dynamic> newData) async {
    await _db.collection('users').doc(userId).update(newData);
  }

}
