import 'package:flutter/material.dart';
import '../widgets/update_user_form.dart';
import '../widgets/delete_user_form.dart';
import '../widgets/user_form.dart';
import '../widgets/view_single_user.dart'; // Tek kullanıcıyı göstermek için
import '../widgets/view_all_users.dart'; // Tüm kullanıcıları listelemek için

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _navigateToAddUser(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const UserForm()),
    );
  }

  void _navigateToDeleteUser(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => DeleteUserForm()),
    );
  }

  void _navigateToUpdateUser(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => UpdateUserForm()),
    );
  }

  void _navigateToShowUserData(BuildContext context) {
    // Tüm kullanıcıları listelemek için sayfaya yönlendirme
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => UsersListView()),
    );
  }

  void _promptForUserId(BuildContext context) {
    // Kullanıcıdan tek bir kullanıcı ID alıp göstermek için dialog açma
    TextEditingController _userIdController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter User ID"),
          content: TextField(
            controller: _userIdController,
            decoration: InputDecoration(hintText: "User ID"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SingleUserView(userId: _userIdController.text),
                  ),
                );
              },
              child: Text('Show User'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _navigateToAddUser(context),
              child: const Text('Add User'),
            ),
            ElevatedButton(
              onPressed: () => _navigateToDeleteUser(context),
              child: const Text('Delete User'),
            ),
            ElevatedButton(
              onPressed: () => _navigateToUpdateUser(context),
              child: const Text('Update User'),
            ),
            ElevatedButton(
              onPressed: () => _promptForUserId(context),
              child: const Text('Show Single User Data'),
            ),
            ElevatedButton(
              onPressed: () => _navigateToShowUserData(context),
              child: const Text('Show All User Data'),
            ),
          ],
        ),
      ),
    );
  }
}