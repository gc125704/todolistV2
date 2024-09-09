import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_pagem.dart'; 
import 'package:todo/models/user.dart'; 

class SignupPage extends StatefulWidget {
  final bool isEditing;
  final User? user;

  const SignupPage({super.key, this.isEditing = false, this.user});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.user != null) {
      _usernameController.text = widget.user!.name;
      _emailController.text = widget.user!.email;
    }
  }

  Future<String?> getCsrfToken() async {
    final url = Uri.parse('http://10.0.2.2:8000/csrf-token/');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['csrfToken'];
    } else {
      print('Failed to get CSRF token: ${response.body}');
      return null;
    }
  }

  Future<void> signupUser(String username, String email, String password) async {
    final csrfToken = await getCsrfToken();
    if (csrfToken == null) {
      print('CSRF token not found');
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8000/users/create');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-CSRFToken': csrfToken,
      },
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SlidableListScreen(user: User.fromJson(jsonDecode(response.body))),
        ),
      );
    } else {
      print('Signup failed: ${response.body}');
    }
  }

  Future<void> updateUser(String username, String email, String password) async {
    final csrfToken = await getCsrfToken();
    if (csrfToken == null) {
      print('CSRF token not found');
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8000/users/${widget.user!.id}/');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-CSRFToken': csrfToken,
      },
      body: jsonEncode({
        'username': username,
        'email': email,
        if (password.isNotEmpty) 'password': password,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SlidableListScreen(user: User.fromJson(jsonDecode(response.body))),
        ),
      );
    } else {
      print('Update failed: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Center(
          child: Text(
            widget.isEditing ? "Editar Usuário" : "Cadastro",
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(27),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple,
              Colors.pinkAccent,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            CupertinoTextField(
              controller: _usernameController,
              cursorColor: Colors.pinkAccent,
              padding: const EdgeInsets.all(15),
              placeholder: "Digite o seu nome de usuário",
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.all(
                  Radius.circular(7),
                ),
              ),
            ),
            const SizedBox(height: 5),
            CupertinoTextField(
              controller: _emailController,
              cursorColor: Colors.pinkAccent,
              padding: const EdgeInsets.all(15),
              placeholder: "Digite o seu e-mail",
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.all(
                  Radius.circular(7),
                ),
              ),
            ),
            const SizedBox(height: 5),
            CupertinoTextField(
              controller: _passwordController,
              padding: const EdgeInsets.all(15),
              cursorColor: Colors.pinkAccent,
              placeholder: widget.isEditing ? "Digite uma nova senha (opcional)" : "Digite sua senha",
              obscureText: true,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.all(
                  Radius.circular(7),
                ),
              ),
            ),
            const SizedBox(height: 5),
            if (!widget.isEditing)
              CupertinoTextField(
                controller: _confirmPasswordController,
                padding: const EdgeInsets.all(15),
                cursorColor: Colors.pinkAccent,
                placeholder: "Confirme sua senha",
                obscureText: true,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.all(
                    Radius.circular(7),
                  ),
                ),
              ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                padding: const EdgeInsets.all(17),
                color: Colors.greenAccent,
                child: Text(
                  widget.isEditing ? "Atualizar" : "Cadastrar",
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  final username = _usernameController.text;
                  final email = _emailController.text;
                  final password = _passwordController.text;
                  final confirmPassword = _confirmPasswordController.text;

                  if (widget.isEditing) {
                    updateUser(username, email, password);
                  } else if (password == confirmPassword) {
                    signupUser(username, email, password);
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: const Text('Erro'),
                        content: const Text('As senhas não coincidem.'),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
