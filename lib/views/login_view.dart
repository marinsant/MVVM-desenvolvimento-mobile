import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // -> Necessário para o HapticFeedback
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Importação do Riverpod
import '../providers/app_providers.dart'; // Provedores de injeção de dependência

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String? _errorMessage;
  bool _obscurePassword = true; // -> REQUISITO 1: Controle de visibilidade da senha

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Escuta de forma reativa o estado do provider de autenticação utilizando Riverpod
    final authViewModel = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_outline_rounded, size: 64, color: Color(0xFF0F2C3D)),
              const SizedBox(height: 16),
              const Text(
                "Controle Financeiro",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F2C3D)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Acesse sua conta financeira",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "E-mail",
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      onChanged: (_) {
                        if (_errorMessage != null) setState(() => _errorMessage = null);
                      },
                      validator: (v) => v == null || v.isEmpty ? "Digite seu e-mail" : null,
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword, // -> Dinâmico baseado no clique
                      decoration: InputDecoration(
                        labelText: "Senha",
                        prefixIcon: const Icon(Icons.lock_clock_outlined),
                        // -> REQUISITO 1: Ícone de olho interativo
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: const Color(0xFF0F2C3D).withOpacity(0.6),
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      onChanged: (_) {
                        if (_errorMessage != null) setState(() => _errorMessage = null);
                      },
                      validator: (v) => v == null || v.isEmpty ? "Digite sua senha" : null,
                    ),
                    
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red.shade800, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: authViewModel.isLoading
                          ? null
                          : () async {
                              // -> REQUISITO 2: Feedback tátil leve ao tocar no botão principal
                              HapticFeedback.lightImpact();

                              if (_formKey.currentState!.validate()) {
                                // Substituído o 'context.read' antigo pelo 'ref.read' do Riverpod
                                final success = await ref.read(authProvider.notifier).login(
                                      _emailController.text,
                                      _passwordController.text,
                                    );
                                if (success) {
                                  if (mounted) {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context, 
                                      '/dashboard', 
                                      (route) => false,
                                    );
                                  }
                                } else {
                                  // Feedback de erro tátil (opcional, duplo impacto sutil)
                                  HapticFeedback.mediumImpact();
                                  setState(() {
                                    _errorMessage = "E-mail ou senha incorretos. Tente novamente.";
                                  });
                                }
                              }
                            },
                      child: authViewModel.isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Entrar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        "Não tem uma conta? Cadastre-se",
                        style: TextStyle(color: Color(0xFF0F2C3D), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}