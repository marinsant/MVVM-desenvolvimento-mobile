import 'package:flutter/material.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Login Financeiro", 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const TextField(decoration: InputDecoration(labelText: "E-mail")),
            const TextField(decoration: InputDecoration(labelText: "Senha"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/home'),
              child: const Text("Entrar"),
            ),
          ],
        ),
      ),
    );
  }
}