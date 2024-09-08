import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_pagem.dart'; // Importe a página para onde você deseja redirecionar após o cadastro
import 'package:todo/models/user.dart'; // Importe o modelo de usuário se necessário

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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
      // Cadastro bem-sucedido
      print('Signup successful');
      print('Response Body: ${response.body}');
      // Navegue para a próxima tela ou faça o login automático, se necessário
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SlidableListScreen(user: User.fromJson(jsonDecode(response.body))),
        ),
      );
    } else {
      // Cadastro falhou
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('Signup failed: ');
      print(csrfToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Cadastro",
            style: TextStyle(
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
            const Text(
              "Preencha os campos abaixo para criar uma conta.",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            CupertinoTextField(
              controller: _usernameController,
              cursorColor: Colors.pinkAccent,
              padding: const EdgeInsets.all(15),
              placeholder: "Digite o seu nome de usuário",
              placeholderStyle: const TextStyle(color: Colors.white70, fontSize: 14),
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
              placeholderStyle: const TextStyle(color: Colors.white70, fontSize: 14),
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
              placeholder: "Digite sua senha",
              obscureText: true,
              placeholderStyle: const TextStyle(color: Colors.white70, fontSize: 14),
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
              controller: _confirmPasswordController,
              padding: const EdgeInsets.all(15),
              cursorColor: Colors.pinkAccent,
              placeholder: "Confirme sua senha",
              obscureText: true,
              placeholderStyle: const TextStyle(color: Colors.white70, fontSize: 14),
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
                child: const Text(
                  "Cadastrar",
                  style: TextStyle(
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

                  if (password == confirmPassword) {
                    signupUser(username, email, password);
                  } else {
                    // Exibir um alerta ou mensagem de erro informando que as senhas não coincidem
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
            const SizedBox(height: 7),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white70, width: 0.8),
                borderRadius: BorderRadius.circular(7),
              ),
              child: CupertinoButton(
                child: const Text(
                  "Já possui uma conta? Faça login",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
