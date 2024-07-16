import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';
import '../validator.dart';

class UserForm extends StatefulWidget {
  const UserForm({Key? key}) : super(key: key);

  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                validator: Validator.validateName,
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                //kullanıcı hangi textformfield üzerindeyse onun hatasını kızartıyor.
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              TextFormField(
                validator: Validator.validateEmail,
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              TextFormField(
                validator: Validator.validateAge,
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addUser,
                child: const Text('ADD'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addUser() {
    if (_formKey.currentState!.validate()) {
      final newUser = User(
        name: _nameController.text,
        email: _emailController.text,
        age: int.parse(_ageController.text),
      );
      _firestoreService.addUser(newUser);
      Navigator.pop(context);  // Form gönderildikten sonra geri dön
    }
  }
}
