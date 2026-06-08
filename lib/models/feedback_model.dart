class FeedbackModel {
  final String? id;
  final String nome;
  final String email;
  final String mensagem;

  FeedbackModel({
    this.id,
    required this.nome,
    required this.email,
    required this.mensagem,
  });

  // Converte o objeto Flutter para JSON (usado no POST)
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'email': email,
      'mensagem': mensagem,
    };
  }

  // Converte o JSON recebido da API para o objeto Flutter (usado no GET)
  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'],
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      mensagem: json['mensagem'] ?? '',
    );
  }
}