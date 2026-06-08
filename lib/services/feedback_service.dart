import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/feedback_model.dart';

class FeedbackService {
  // SUBSTITUA com a URL que o site MockAPI gerou para você!
  final String _baseUrl = 'https://6a24b261420469ff067b2ab8.mockapi.io/api/v1/feedbacks';

  // 1. MÉTODO POST: Enviar dados do formulário para a API
  Future<bool> enviarFeedback(FeedbackModel feedback) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(feedback.toJson()),
      ).timeout(const Duration(seconds: 10)); // Tratamento de lentidão

      // Código 201 significa que o recurso foi criado com sucesso na API
      if (response.statusCode == 201) {
        return true;
      } else {
        // Tratamento de erro do servidor
        throw Exception('Erro no servidor: ${response.statusCode}');
      }
    } catch (e) {
      // Tratamento de erro de conexão/internet
      print("Erro ao fazer POST: $e");
      return false;
    }
  }

  // 2. MÉTODO GET: Buscar os feedbacks já enviados (para listar na tela se quiser)
  Future<List<FeedbackModel>> buscarFeedbacks() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        List<dynamic> listaJson = jsonDecode(response.body);
        return listaJson.map((json) => FeedbackModel.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar feedbacks');
      }
    } catch (e) {
      print("Erro ao fazer GET: $e");
      return [];
    }
  }
}