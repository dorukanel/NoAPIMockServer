import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class DeleteUserForm extends StatefulWidget {
  @override
  _DeleteUserFormState createState() => _DeleteUserFormState();
}

class _DeleteUserFormState extends State<DeleteUserForm> {
  final TextEditingController _userIdController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  void _handleDeleteUser() {
    String userId = _userIdController.text;
    if (userId.isNotEmpty) {
      _firestoreService.deleteUser(userId).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User successfully deleted!")),
        );
        _userIdController.clear();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete user: $error")),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(
                labelText: 'User ID',
                hintText: 'Enter the user ID to delete',
              ),
            ),
            ElevatedButton(
              onPressed: _handleDeleteUser,
              child: Text('Delete User'),
            ),
          ],
        ),
      ),
    );
  }
}