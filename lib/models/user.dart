// istenilen veri modeline göre güncellenecektir, şimdilik bir örnek olsun diye böyle yaptım

class User {
  final String name;
  final String email;

  User({required this.name, required this.email});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
    };
  }
}
