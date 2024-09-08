

class User {
  final int id;
  final String name;
  final String email;
  
  User({
    required this.name,
    required this.id,
    required this.email
  });


  // Factory method para criar um User a partir de um JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['username'],
      email: json['email'],
      id: json['id'], // Ajuste conforme necessário
    );
  }
}
