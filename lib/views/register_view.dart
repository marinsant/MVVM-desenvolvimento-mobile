import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Criar Conta")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nome Completo", border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? "Campo obrigatório" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "E-mail", border: OutlineInputBorder()),
                validator: (value) => value == null || !value.contains('@') ? "E-mail inválido" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Senha", border: OutlineInputBorder()),
                validator: (value) => value == null || value.length < 4 ? "Senha muito curta" : null,
              ),
              const SizedBox(height: 24),
              authViewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await context.read<AuthViewModel>().register(
                                _nameController.text,
                                _emailController.text,
                                _passwordController.text,
                              );
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Cadastro realizado com sucesso!")),
                            );
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: const Text("Cadastrar"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}