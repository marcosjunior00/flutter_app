import 'package:flutter/material.dart';
import '../services/api.service.dart';
import 'todo.screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  void _handleRegister() async {
    setState(() => _loading = true);

    await ApiService.register(
      _name.text,
      _email.text,
      _password.text,
    );

    setState(() => _loading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const TodoScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Criar conta",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            const Text("Nome"),
            TextField(controller: _name),
            const SizedBox(height: 20),
            const Text("E-mail"),
            TextField(controller: _email),
            const SizedBox(height: 20),
            const Text("Senha"),
            TextField(controller: _password, obscureText: true),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _loading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xFF9C27B0),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Criar conta",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
