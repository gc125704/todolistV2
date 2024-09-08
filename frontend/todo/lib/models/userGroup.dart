class UserGroup {
  final int id_GroupTodoUser;
  final int idGroupTodo;
  final int User;
  
  UserGroup({
    required this.id_GroupTodoUser,
    required this.idGroupTodo,
    required this.User
  });


  // Factory method para criar um User a partir de um JSON
  factory UserGroup.fromJson(Map<String, dynamic> json) {
    return UserGroup(
      id_GroupTodoUser: json['id_GroupTodoUser'],
      idGroupTodo: json['idGroupTodo'],
      User: json['User'], // Ajuste conforme necessário
    );
  }
}
