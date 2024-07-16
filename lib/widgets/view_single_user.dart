import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SingleUserView extends StatelessWidget {
  final String userId;

  SingleUserView({required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }
        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist");
        }

        Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
        return Card(
          child: ListTile(
            title: Text(userData['name'] ?? 'No name'),
            subtitle: Text(userData['email'] ?? 'No email'),
          ),
        );
      },
    );
  }
}
