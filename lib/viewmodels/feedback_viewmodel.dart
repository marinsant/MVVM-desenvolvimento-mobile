import 'package:flutter/material.dart';
import '../models/feedback_model.dart';
import '../services/feedback_service.dart';

class FeedbackViewModel extends ChangeNotifier {
  final FeedbackService _service = FeedbackService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Função que a View vai chamar quando o usuário clicar no botão
  Future<bool> enviarFormulario({
    required String nome,
    required String email,
    required String mensagem,
  }) async {
    // Ativa o estado de loading e avisa a interface para se atualizar
    _isLoading = true;
    notifyListeners();

    // Cria o modelo com os dados recebidos da tela
    FeedbackModel novoFeedback = FeedbackModel(
      nome: nome,
      email: email,
      mensagem: mensagem,
    );

    // Dispara o POST para o MockAPI
    bool sucesso = await _service.enviarFeedback(novoFeedback);

    // Desativa o loading e avisa a interface
    _isLoading = false;
    notifyListeners();

    return sucesso;
  }
}