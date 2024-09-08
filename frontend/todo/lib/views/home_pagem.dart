import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:todo/models/user.dart';
import 'package:todo/models/todo.dart'; // Certifique-se de que o caminho está correto
import 'package:todo/views/login.dart';
import 'groups_manager.dart';

class GroupTodo {
  final int id;
  final String description;

  GroupTodo({required this.id, required this.description});

  factory GroupTodo.fromJson(Map<String, dynamic> json) {
    return GroupTodo(
      id: json['id'],
      description: json['Description'],
    );
  }
}

class MyApp extends StatelessWidget {
  final User user;

  const MyApp({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Slidable ListView',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SlidableListScreen(user: user),
    );
  }
}

class SlidableListScreen extends StatefulWidget {
  final User user;

  const SlidableListScreen({super.key, required this.user});

  @override
  _SlidableListScreenState createState() => _SlidableListScreenState();
}

class _SlidableListScreenState extends State<SlidableListScreen> {
  late Future<List<GroupTodo>> _userGroups;
  late Future<List<ToDoItem>> _toDoItems;
  Map<int, String> _userNames = {}; // Mapa para armazenar os nomes dos usuários

  Future<List<GroupTodo>> fetchUserGroups(int userId) async {
    final response = await http.get(
      Uri.parse(
          'http://10.0.2.2:8000/users/listar_grupos_usuario?user_id=$userId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['grupos'];

      return data.map((json) => GroupTodo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load user groups');
    }
  }

  Future<void> _createToDoItem(
    String title,
    String? description, // Pode ser nulo
    DateTime initDate,
    DateTime finalDate,
    int userId,
    int idGroupTodo,
  ) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/create'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'Title': title,
        'InitDate': initDate.toIso8601String().substring(0, 10),
        'FinalDate': finalDate.toIso8601String().substring(0, 10),
        'User': userId,
        'description': description,
        'idGroupTodo': idGroupTodo
        // Adicione outros campos necessários aqui
      }),
    );

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 201) {
      throw Exception('Failed to create task');
    }

    // Atualize a lista de tarefas após a criação
    setState(() {
      _toDoItems = fetchToDoItems(widget.user.id);
    });
  }

  Future<void> _updateToDoItem(
    int id,
    String title,
    String? description, // Pode ser nulo
    DateTime initDate,
    DateTime finalDate,
    int userId,
    int? idGroupTodo,
  ) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:8000/$id/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'Title': title,
        'InitDate': initDate.toIso8601String().substring(0, 10),
        'FinalDate': finalDate.toIso8601String().substring(0, 10),
        'User': userId,
        'Description': description,
        'idGroupTodo': idGroupTodo
        // Adicione outros campos necessários aqui
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update task');
    }

    // Atualize a lista de tarefas após a criação
    setState(() {
      _toDoItems = fetchToDoItems(widget.user.id);
    });
  }

  Future<void> fetchUserName(int userId) async {
    if (!_userNames.containsKey(userId)) {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:8000/users/$userId/'));
      if (response.statusCode == 200) {
        final user = jsonDecode(response.body);
        setState(() {
          _userNames[userId] = user['username'];
        });
      } else {
        throw Exception('Failed to load user name');
      }
    }
  }

  Future<List<ToDoItem>> fetchToDoItems(int userId) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/get_todos_by_user?user_id=$userId'),
    );

    print(jsonDecode(response.body));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['items'];
      print('Resposta da API: ${response.body}');
      return data.map((json) => ToDoItem.fromJson(json)).toList();
    } else {
      print('Resposta da API: ${response.body}');
      throw Exception('Failed to load to-do items');
    }
  }

  Future<List<ToDoItem>> fetchToDoItemsGroup(int groupId) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/get_todos_by_group?group_id=$groupId'),
    );

    print(jsonDecode(response.body));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['items'];
      print('Resposta da API: ${response.body}');
      return data.map((json) => ToDoItem.fromJson(json)).toList();
    } else {
      print('Resposta da API: ${response.body}');
      throw Exception('Failed to load to-do items');
    }
  }

  @override
  void initState() {
    super.initState();
    _userGroups = fetchUserGroups(widget.user.id);
    _toDoItems = fetchToDoItems(widget.user.id);
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/users'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((user) => user as Map<String, dynamic>).toList();
    } else {
      throw Exception('Falha ao carregar usuários');
    }
  }

  Future<void> _marcarComoConcluido(int todoId) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/marcar_como_concluido?id=$todoId'),
    );

    if (response.statusCode == 200) {
      // Atualiza a lista de tarefas após marcar como concluída
      setState(() {
        _toDoItems = fetchToDoItems(widget.user.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarefa marcada como concluída!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao marcar tarefa como concluída')),
      );
    }
    setState(() {
      _toDoItems = fetchToDoItems(widget.user.id);
    });
  }

  Future<void> _desmarcarComoConcluido(int todoId) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/desmarcar_como_concluido?id=$todoId'),
    );

    if (response.statusCode == 200) {
      // Atualiza a lista de tarefas após marcar como concluída
      setState(() {
        _toDoItems = fetchToDoItems(widget.user.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarefa reaberta!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao marcar tarefa como concluída')),
      );
    }
    setState(() {
      _toDoItems = fetchToDoItems(widget.user.id);
    });
  }

  Future<void> deleteTodoItem(int todoId) async {
    final url =
        'http://10.0.2.2:8000/delete/$todoId'; // Substitua com a URL da sua API

    final response = await http.delete(
      Uri.parse(url),
    );

    if (response.statusCode == 204) {
      print('Tarefa deletada com sucesso');
      setState(() {
        _toDoItems = fetchToDoItems(widget.user.id);
      });
    } else {
      print('Falha ao deletar tarefa: ${response.statusCode}');
    }
  }

  Future<void> _showToDoDialog({ToDoItem? item}) async {
    final bool isEditing = item != null;
    String taskTitle = isEditing ? item.title : '';
    String? taskDescription =
        isEditing ? item.description : null; // Pode ser nulo
    DateTime? initDate = isEditing ? item.initDate : null;
    DateTime? finalDate = isEditing ? item.finalDate : null;
    String? selectedUserId = isEditing ? item.userId.toString() : null;
    int? selectedGroupId = isEditing
        ? item.idGroupTodo
        : null; // Para armazenar o grupo selecionado
    final _formKey = GlobalKey<FormState>();

    List<Map<String, dynamic>> users = await _fetchUsers();
    List<GroupTodo> userGroups =
        await _userGroups; // Carrega os grupos do usuário

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title:
                  Text(isEditing ? 'Editar Tarefa' : 'Adicionar Nova Tarefa'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Campo para o título da tarefa.
                      TextFormField(
                        initialValue: taskTitle,
                        decoration: const InputDecoration(
                          labelText: 'Título da Tarefa',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o título da tarefa';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          taskTitle = value!;
                        },
                      ),
                      const SizedBox(height: 10),
                      // Campo para a descrição da tarefa.
                      TextFormField(
                        initialValue: taskDescription,
                        decoration: const InputDecoration(
                          labelText: 'Descrição da Tarefa',
                        ),
                        maxLines: 3,
                        onSaved: (value) {
                          taskDescription = value; // Pode ser nulo
                        },
                      ),
                      const SizedBox(height: 10),
                      // Seleção da data de início.
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              initDate == null
                                  ? 'Data de Início: Não selecionada'
                                  : 'Data de Início: ${DateFormat('dd/MM/yyyy').format(initDate!)}',
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: initDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (picked != null) {
                                setStateDialog(() {
                                  initDate = picked;
                                });
                              }
                            },
                            child: const Text('Selecionar'),
                          ),
                        ],
                      ),
                      // Seleção da data de fim.
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              finalDate == null
                                  ? 'Data de Fim: Não selecionada'
                                  : 'Data de Fim: ${DateFormat('dd/MM/yyyy').format(finalDate!)}',
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate:
                                    finalDate ?? initDate ?? DateTime.now(),
                                firstDate: initDate ?? DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (picked != null) {
                                setStateDialog(() {
                                  finalDate = picked;
                                });
                              }
                            },
                            child: const Text('Selecionar'),
                          ),
                        ],
                      ),
                      // Combobox para o usuário responsável.
                      DropdownButtonFormField<String>(
                        value: selectedUserId,
                        decoration: const InputDecoration(
                          labelText: 'Usuário Responsável',
                        ),
                        items: users.map((user) {
                          return DropdownMenuItem<String>(
                            value: user['id'].toString(),
                            child: Text(user['username']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setStateDialog(() {
                            selectedUserId = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, selecione um usuário responsável';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      // Combobox para o grupo.
                      DropdownButtonFormField<int>(
                        value: selectedGroupId,
                        decoration: const InputDecoration(
                          labelText: 'Grupo',
                        ),
                        items: userGroups.map((group) {
                          return DropdownMenuItem<int>(
                            value: group.id,
                            child: Text(group.description),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setStateDialog(() {
                            selectedGroupId = value!;
                          });
                        },
                        // validator: (value) {
                        //   if (value == null) {
                        //     return 'Por favor, selecione um grupo';
                        //   }
                        //   return null;
                        // },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Fecha o diálogo sem salvar.
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (initDate == null || finalDate == null) {
                        // Exibe um erro se as datas não forem selecionadas.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Por favor, selecione as datas')),
                        );
                        return;
                      }
                      _formKey.currentState!.save();
                      if (isEditing) {
                        // Atualiza a tarefa existente.
                        _updateToDoItem(
                          item.id,
                          taskTitle,
                          taskDescription, // Pode ser nulo
                          initDate!,
                          finalDate!,
                          int.parse(selectedUserId!),
                          selectedGroupId, // Adiciona o grupo ao qual a tarefa pertence
                        ).then((_) {
                          setState(() {});
                          Navigator.of(context)
                              .pop(); // Fecha o diálogo após salvar.
                        });
                      } else {
                        // Adiciona uma nova tarefa.
                        _createToDoItem(
                          taskTitle,
                          taskDescription, // Pode ser nulo
                          initDate!,
                          finalDate!,
                          int.parse(selectedUserId!),
                          selectedGroupId!, // Adiciona o grupo ao qual a tarefa pertence
                        ).then((_) {
                          setState(() {});
                          Navigator.of(context)
                              .pop(); // Fecha o diálogo após salvar.
                        });
                      }
                    }
                  },
                  child: Text(isEditing ? 'Salvar' : 'Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
      (Route<dynamic> route) => false,  // Remove a página atual da pilha
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Slidable ListView'),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.user.name),
              accountEmail: Text(widget.user.email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(widget.user.name[0]),
              ),
              otherAccountsPictures: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupManagerApp(user: widget.user),
                      ),
                    );
                  },
                  icon: Icon(Icons.group),
                  tooltip: 'Meus Grupos',
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _logout,
                ),
              ],
            ),
            Expanded(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Minha Lista'),
                    onTap: () {
                      setState(() {
                        _toDoItems = fetchToDoItems(widget.user.id);
                      });
                      Navigator.pop(context);
                    },
                  ),
                  FutureBuilder<List<GroupTodo>>(
                    future: _userGroups,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const ListTile(
                          title: Text('Carregando grupos...'),
                        );
                      } else if (snapshot.hasError) {
                        return const ListTile(
                          title: Text('Erro ao carregar grupos'),
                        );
                      } else if (snapshot.hasData) {
                        final groups = snapshot.data!;
                        return Column(
                          children: groups.map((group) {
                            return ListTile(
                              title: Text(group.description),
                              onTap: () {
                                setState(() {
                                  _toDoItems = fetchToDoItemsGroup(group.id);
                                });
                                Navigator.pop(context);
                              },
                            );
                          }).toList(),
                        );
                      } else {
                        return const ListTile(
                          title: Text('Nenhum grupo encontrado'),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<ToDoItem>>(
        future: _toDoItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar tarefas.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhuma tarefa encontrada.'));
          } else {
            return ListView.separated(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: snapshot.data!.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8.0),
              itemBuilder: (context, index) {
                final item = snapshot.data![index];
                final userId = item.userId;

                // Buscar nome do usuário se ainda não estiver no mapa
                if (!_userNames.containsKey(userId)) {
                  fetchUserName(userId);
                }

                // Determina a cor de fundo com base no status de conclusão
                final backgroundColor =
                    item.completed ? Colors.green.shade100 : Colors.white;

                return Slidable(
                  key: ValueKey(item.id), // Usar ID como chave
                  startActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          _showToDoDialog(item: item);
                        },
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Editar',
                      ),
                      if (!item.completed)
                        SlidableAction(
                          onPressed: (context) {
                            _marcarComoConcluido(item.id);
                          },
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          icon: Icons.check,
                          label: 'Concluir',
                        ),
                      if (item.completed)
                        SlidableAction(
                          onPressed: (context) {
                            _desmarcarComoConcluido(item.id);
                          },
                          backgroundColor: Colors.yellow,
                          foregroundColor: Colors.white,
                          icon: Icons.update_outlined,
                          label: 'Reabrir',
                        ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) async {
                          await deleteTodoItem(item.id);
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Deletar',
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          item.title.isNotEmpty ? item.title : 'Sem título',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Data de Início: ${item.initDate != null ? DateFormat('dd/MM/yyyy').format(item.initDate!) : 'Não definida'}',
                            ),
                            Text(
                              'Data de Fim: ${item.finalDate != null ? DateFormat('dd/MM/yyyy').format(item.finalDate!) : 'Não definida'}',
                            ),
                            Text(
                              'Responsável: ${_userNames[userId] ?? 'Carregando...'}',
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Descrição: ${item.description?.isNotEmpty == true ? item.description! : 'Nenhuma descrição'}',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showToDoDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
