import 'package:flutter/material.dart';
import '../viewmodels/feedback_viewmodel.dart';

class FeedbackView extends StatefulWidget {
  const FeedbackView({super.key});

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  // Chave global para validação do formulário
  final _formKey = GlobalKey<FormState>();

  // Controladores para capturar o texto dos inputs
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mensagemController = TextEditingController();

  // Instância da ViewModel que gerencia a lógica desta tela
  final FeedbackViewModel _viewModel = FeedbackViewModel();

  @override
  void dispose() {
    // Limpeza dos controladores ao fechar a tela para evitar vazamento de memória
    _nomeController.dispose();
    _emailController.dispose();
    _mensagemController.dispose();
    super.dispose();
  }

  // Função interna que valida os campos e dispara o envio
  void _submeterFormulario() async {
    // Verifica se todos os campos passaram pelas validações de texto
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus(); // Fecha o teclado numérico/virtual se estiver aberto

      // Chama a ViewModel para processar o POST na API
      bool enviouComSucesso = await _viewModel.enviarFormulario(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        mensagem: _mensagemController.text.trim(),
      );

      // Verifica se o componente ainda está ativo na tela antes de exibir o SnackBar
      if (!mounted) return;

      if (enviouComSucesso) {
        // Feedback visual positivo (Sucesso)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Formulário enviado com sucesso'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Limpa os campos do formulário após o sucesso
        _nomeController.clear();
        _emailController.clear();
        _mensagemController.clear();
      } else {
        // Feedback visual negativo (Tratamento de Erro)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Falha ao enviar. Verifique a conexão com a API.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500), // Mantém o layout elegante no navegador web
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Sua opinião é importante',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Preencha os campos abaixo para enviar dados via POST.',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // CAMPO: NOME
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Completo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, insira seu nome.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // CAMPO: E-MAIL
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail Institucional',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, insira seu e-mail.';
                      }
                      if (!value.contains('@')) {
                        return 'Insira um e-mail válido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // CAMPO: MENSAGEM
                  TextFormField(
                    controller: _mensagemController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Sua Mensagem / Sugestão',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.chat_bubble),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'O campo de mensagem não pode ficar vazio.';
                      }
                      if (value.trim().length < 10) {
                        return 'A mensagem deve ter pelo menos 10 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // ÁREA DINÂMICA: BOTÃO OU LOADING (Gerenciado via MVVM)
                  ListenableBuilder(
                    listenable: _viewModel,
                    builder: (context, child) {
                      // Se a ViewModel avisar que está processando, mostra o indicador de carregamento
                      if (_viewModel.isLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      // Se não estiver carregando, exibe o botão funcional para clique
                      return ElevatedButton(
                        onPressed: _submeterFormulario,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Enviar Feedback (POST)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}