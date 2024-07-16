import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class UpdateUserForm extends StatefulWidget {
  @override
  _UpdateUserFormState createState() => _UpdateUserFormState();
}

class _UpdateUserFormState extends State<UpdateUserForm> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  void _handleUpdateUser() {
    String userId = _userIdController.text;
    Map<String, dynamic> newData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'age': int.tryParse(_ageController.text) ?? 0,
    };
    _firestoreService.updateUser(userId, newData).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User successfully updated!")),
      );
      _userIdController.clear();
      _nameController.clear();
      _emailController.clear();
      _ageController.clear();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update user: $error")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update User'),
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
                hintText: 'Enter the user ID to update',
              ),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(labelText: 'Age'),
            ),
            ElevatedButton(
              onPressed: _handleUpdateUser,
              child: Text('Update User'),
            ),
          ],
        ),
      ),
    );
  }
}
