class ToDoItem {
  final int id;
  final String title;
  final String? description;
  final DateTime? initDate;
  final DateTime? finalDate;
  final bool completed;
  final int userId;
  final int? idGroupTodo;

  ToDoItem({
    required this.id,
    required this.title,
    this.description,
    this.initDate,
    this.finalDate,
    required this.completed,
    required this.userId,
    this.idGroupTodo,
  });

  factory ToDoItem.fromJson(Map<String, dynamic> json) {
    return ToDoItem(
      id: json['id'],
      title: json['Title'],
      description: json['Description'],
      initDate: json['InitDate'] != null ? DateTime.parse(json['InitDate']) : null,
      finalDate: json['FinalDate'] != null ? DateTime.parse(json['FinalDate']) : null,
      completed: json['Completed'],
      userId: json['User'],
      idGroupTodo: json['idGroupTodo'],
    );
  }
}
