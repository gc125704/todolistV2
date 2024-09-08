import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_pagem.dart';
import 'package:todo/models/user.dart';
import 'signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<String?> getCsrfToken() async {
    final url = Uri.parse('http://10.0.2.2:8000/csrf-token/');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      return data['csrfToken'];
    } else {
      print('Failed to get CSRF token: ${response.body}');
      return null;
    }
  }

  Future<void> loginUser(String username, String password) async {
    final csrfToken = await getCsrfToken();
    if (csrfToken == null) {
      print('CSRF token not found');
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8000/login/');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-CSRFToken': csrfToken,
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    //final response = await http.get(url);  // Altere para GET

    if (response.statusCode == 200) {
      // Login bem-sucedido
      print('Login successful');
      print('Response Body: ${response.body}');
      // Parse o JSON e crie o objeto User
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final User user = User.fromJson(responseData);

      // Navegue para a próxima tela e passe o objeto User
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SlidableListScreen(user: user),
        ),
      );
      // Navigator.push(context,MaterialPageRoute(
      //                           builder: (context) => const SlidableListScreen()),);
    } else {
      // Login falhou
      print(
          'Response Status Code: ${response.statusCode}'); // Adicione esta linha para depuração
      print('Response Body: ${response.body}');
      print('Login failed: ');
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
            "Login",
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
              "Digite os dados de acesso nos campos abaixo.",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            CupertinoTextField(
              controller: _emailController,
              cursorColor: Colors.pinkAccent,
              padding: const EdgeInsets.all(15),
              placeholder: "Digite o seu e-mail",
              placeholderStyle:
                  const TextStyle(color: Colors.white70, fontSize: 14),
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
              placeholderStyle:
                  const TextStyle(color: Colors.white70, fontSize: 14),
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
                  "Acessar",
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  final username = _emailController.text;
                  final password = _passwordController.text;
                  loginUser(username, password);
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
                  "Crie sua conta",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignupPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
