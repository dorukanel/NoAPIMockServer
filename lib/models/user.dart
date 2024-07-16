
// istenilen veri modeline göre güncellenecektir, şimdilik bir örnek olsun diye böyle yaptım

class User {
  final String name;
  final String email;
  final int age;

  User({required this.name, required this.email, required this.age});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'age': age,
    };
  }
}
