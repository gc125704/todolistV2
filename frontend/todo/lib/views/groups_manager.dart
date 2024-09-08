import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:todo/models/user.dart';
import 'package:todo/models/userGroup.dart';
import 'package:todo/models/toDo.dart';
import 'home_pagem.dart';

class GroupTodo {
  final int id;
  final String description;
  List<User>? users;

  GroupTodo({
    required this.id,
    required this.description,
    this.users = const [],
  });

  factory GroupTodo.fromJson(Map<String, dynamic> json) {
    return GroupTodo(
      id: json['id_groupTodo'],
      description: json['Description'],
    );
  }
}

class GroupTodoUser {
  final int id_GroupTodoUser;
  final int idGroupTodo;
  List<User>? users;

  GroupTodoUser({
    required this.id_GroupTodoUser,
    required this.idGroupTodo,
    this.users = const [],
  });

  factory GroupTodoUser.fromJson(Map<String, dynamic> json) {
    return GroupTodoUser(
      id_GroupTodoUser: json['id_GroupTodoUser'],
      idGroupTodo: json['idGroupTodo'],
    );
  }
}

class GroupManagerApp extends StatelessWidget {
  final User user;

  const GroupManagerApp({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Group Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GroupManagerScreen(user: user),
    );
  }
}

class GroupManagerScreen extends StatefulWidget {
  final User user;

  const GroupManagerScreen({super.key, required this.user});

  @override
  _GroupManagerScreenState createState() => _GroupManagerScreenState();
}

class _GroupManagerScreenState extends State<GroupManagerScreen>
    with SingleTickerProviderStateMixin {
  Map<int, String> _userNames = {};
  late Future<List<GroupTodo>> _userGroups;
  late UserGroup userGroup;
  late Future<List<ToDoItem>> _toDoItems;

  @override
  void initState() {
    super.initState();
    _userGroups = fetchUserGroups(widget.user.id);
  }

  Future<List<GroupTodo>> fetchUserGroups(int userId) async {
    final response = await http.get(
      Uri.parse(
          'http://10.0.2.2:8000/group/get_groups_by_user_owner?userId=$userId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['grupos'];
      return data.map((json) => GroupTodo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load user groups');
    }
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

  Future<List<User>> fetchUsersInGroup(int groupId) async {
    final response = await http.get(
      Uri.parse(
          'http://10.0.2.2:8000/users/listar_grupos_usuario_por_grupo?group_id=$groupId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['usuarios'];
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users in group');
    }
  }

  Future<void> _editGroup(int groupId, String description) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:8000/group/$groupId/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Description': description,
      }),
    );

    if (response.statusCode == 200) {
      // Atualiza a lista de grupos
      setState(() {
        _userGroups = fetchUserGroups(widget.user.id);
      });
    } else {
      throw Exception('Falha ao atualizar o grupo');
    }
  }

  Future<void> _addUserToGroup(int? groupId, int userId) async {
    print(
        "variaveis que foram para a função, grupo ${groupId}, usuario ${userId}");
    if (groupId != null) {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/userGroup/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idGroupTodo': groupId,
          'User': userId,
        }),
      );
      print(response.body);
      // Atualiza a UI ou realiza outras ações após a adição do usuário]
      if (response.statusCode == 201) {
        setState(() {
          _userGroups = fetchUserGroups(widget.user.id);
        });
      } else {
        throw Exception('falha ao tentar inserir o usergrupo');
      }
    }
  }

  Future<void> _showAddUserGroupDialog(int group) async {
    // Função para buscar todos os usuários disponíveis
    Future<List<User>> fetchAllUsers() async {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/users/'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users');
      }
    }

    return showDialog<void>(
      context: context,
      barrierDismissible:
          true, // Usuário pode dispensar tocando fora do diálogo
      builder: (BuildContext context) {
        return FutureBuilder<List<User>>(
          future: fetchAllUsers(), // Carrega todos os usuários
          builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                title: const Text('Carregando...'),
                content: const Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: const Text('Erro'),
                content: Text('Erro ao carregar usuários: ${snapshot.error}'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return AlertDialog(
                title: const Text('Nenhum usuário encontrado'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            } else {
              List<User> users = snapshot.data!;

              // Configura a ComboBox
              String? selectedUserId;

              return AlertDialog(
                title: const Text('Adicionar Usuário ao Grupo'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedUserId,
                      hint: const Text('Selecione um usuário'),
                      items: users.map((User user) {
                        return DropdownMenuItem<String>(
                          value: user.id.toString(),
                          child: Text(user.name),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedUserId = newValue;
                        });
                      },
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancelar'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton(
                    child: const Text('Adicionar'),
                    onPressed: () {
                      if (selectedUserId != null) {
                        // Adiciona o usuário ao grupo
                        _addUserToGroup(group, int.parse(selectedUserId!));
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  Future<void> _showAddGroupDialog({GroupTodo? group}) async {
    final TextEditingController _controller = TextEditingController(
      text: group != null ? group.description : '', // Preenche se for edição
    );

    return showDialog<void>(
      context: context,
      barrierDismissible: true, // User can dismiss by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(group == null ? 'Adicionar Novo Grupo' : 'Editar Grupo'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'Nome do grupo'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text(group == null ? 'Salvar' : 'Editar'),
              onPressed: () async {
                final String groupName = _controller.text;
                if (groupName.isNotEmpty) {
                  if (group == null) {
                    // Criar novo grupo
                    await _createGroup(groupName, widget.user.id);
                  } else {
                    // Editar grupo existente
                    await _editGroup(group.id, groupName);
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> createUserGroup(int groupId) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/userGroup/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'idGroupTodo': groupId,
        'User': widget.user.id,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create user group');
    }
  }

  Future<void> _createGroup(String description, int userId) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/group/create'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'Description': description,
        'UserOwner': userId,
      }),
    );

    if (response.statusCode == 201) {
      // Refresh the list of groups
      setState(() {
        _userGroups = fetchUserGroups(userId);
        
      });
      final groupData = jsonDecode(response.body);
      final groupId = groupData['id_groupTodo'];
      // print(' id do group adiciona agora: $groupId');
      createUserGroup(groupId);
    } else {
      throw Exception('Failed to create group');
    }
  }

  Future<void> deleteGroup(GroupTodo group) async {
    int contUsers = group.users!.length;
    print('numero usuários do grupo $contUsers');
    if (contUsers <= 1) {
      _toDoItems = fetchToDoItemsGroup(group.id);
      await _removeUserFromGroup(group.id, widget.user.id);
      await _updateToDoItems(_toDoItems);
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8000/group/delete/${group.id}/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 204) {
        setState(() {
          _userGroups = fetchUserGroups(widget.user.id);
        });
      } else {
        throw Exception('Failed to delete group');
      }
    }else{
      print('deleter os usuários do grupo');
    }
  }


Future<void> _updateToDoItems(Future<List<ToDoItem>> todoItemsFuture) async {
  List<ToDoItem> todoItems = await todoItemsFuture;
  for (var item in todoItems) {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:8000/${item.id}/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'Title': item.title,
        'InitDate': item.initDate!.toIso8601String().substring(0, 10),
        'FinalDate': item.finalDate!.toIso8601String().substring(0, 10),
        'User': item.userId,
        'Description': item.description,
        'idGroupTodo': null,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update task with id ${item.id}');
    }
  }

  // Atualize a lista de tarefas após as atualizações, se necessário
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SlidableListScreen(user: widget.user),
              ),
            );
          },
        ),
        title: const Text('Meus Grupos'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16.0), // Espaçamento horizontal
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<GroupTodo>>(
                future: _userGroups,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Nenhum grupo encontrado'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final group = snapshot.data![index];

                        return Column(
                          children: [
                            Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Column(
                                children: [
                                  ListTile(
                                    tileColor: Colors.grey[200],
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(group.description),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.add,
                                              color: Colors.green),
                                          onPressed: () {
                                            print(
                                                'id do grupo clicado ${group.id}');
                                            _showAddUserGroupDialog(group.id);
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              color: Colors.yellow),
                                          onPressed: () {
                                            // Abrir o diálogo de edição com os dados do grupo
                                            _showAddGroupDialog(group: group);
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () async {
                                            bool confirmDelete =
                                                await _showConfirmDeleteDialog();
                                            if (confirmDelete) {
                                              await deleteGroup(group);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    onTap: () async {
                                      setState(() {
                                        if (group.users!.isNotEmpty) {
                                          // Recolhe a lista de usuários
                                          group.users = [];
                                        } else {
                                          // Expande a lista de usuários
                                          fetchUsersInGroup(group.id)
                                              .then((users) {
                                            setState(() {
                                              group.users = users;
                                            });
                                          });
                                        }
                                      });
                                    },
                                  ),
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    child: Column(
                                      children: group.users!.map((user) {
                                        bool isCurrentUser =
                                            user.id == widget.user.id;
                                        return ListTile(
                                          tileColor: Colors.grey[100],
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                          leading: Icon(Icons
                                              .person), // Ícone de usuário antes do nome
                                          title: Text(user.name),
                                          trailing: IconButton(
                                            icon: Icon(Icons.delete,
                                                color: isCurrentUser
                                                    ? Colors.grey
                                                    : Colors.red),
                                            onPressed: isCurrentUser
                                                ? null // Desabilita o botão se o usuário for o logado
                                                : () {
                                                    //  print("${_userGroups.id}");
                                                    _removeUserFromGroup(
                                                        group.id, user.id);
                                                  },
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
            ElevatedButton(
              onPressed: _showAddGroupDialog,
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showConfirmDeleteDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmar Exclusão'),
              content:
                  const Text('Você tem certeza que deseja excluir este grupo?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                ElevatedButton(
                  child: const Text('Excluir'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<int?> listUserGroup(int groupId, int userId) async {
    final response = await http.get(
        Uri.parse(
            'http://10.0.2.2:8000/userGroup/GetGroupTodoUser?userId=${userId}&groupId=${groupId}'),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      //print(data);
      return data['id_GroupTodoUser'];
    } else {
      return null;
    }
  }

  Future<void> _removeUserFromGroup(int groupId, int userId) async {
    // Aguarda a função listUserGroup para obter o id_GroupTodoUser
    int? id_GroupTodoUser = await listUserGroup(groupId, userId);

    if (id_GroupTodoUser != null) {
      // Se id_GroupTodoUser for obtido, realiza a requisição DELETE
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8000/userGroup/delete/$id_GroupTodoUser/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 204) {
        // Atualiza o estado após a remoção
        setState(() {
          _userGroups = fetchUserGroups(widget.user.id);
        });
      } else {
        throw Exception('Failed to remove user from group');
      }
    } else {
      // Se id_GroupTodoUser for null, lança uma exceção
      throw Exception('Failed to get id_GroupTodoUser');
    }
  }

  // Future<bool> _showConfirmDeleteUserDialog(User user) async {
  //   return await showDialog<bool>(
  //         context: context,
  //         barrierDismissible: false,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: const Text('Confirmação'),
  //             content: Text(
  //                 'Você tem certeza que deseja remover o usuário ${user.name} do grupo?'),
  //             actions: <Widget>[
  //               TextButton(
  //                 child: const Text('Cancelar'),
  //                 onPressed: () {
  //                   Navigator.of(context).pop(false);
  //                 },
  //               ),
  //               ElevatedButton(
  //                 child: const Text('Remover'),
  //                 onPressed: () {
  //                   Navigator.of(context).pop(true);
  //                 },
  //               ),
  //             ],
  //           );
  //         },
  //       ) ??
  //       false;
  // }
}
