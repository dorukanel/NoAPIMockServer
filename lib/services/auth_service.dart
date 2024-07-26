import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  Future<UserModel?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = result.user!;
      String uid = _uuid.v4();

      UserModel newUser = UserModel(
        uid: uid,
        email: email,
        role: 'user', // Default role
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await _db.collection('users').doc(uid).set(newUser.toJson());
      return newUser;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = result.user!;
      DocumentSnapshot doc = await _db.collection('users').doc(user.uid).get();
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
