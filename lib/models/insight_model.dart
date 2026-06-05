// lib/models/insight_model.dart

class InsightModel {
  final String source;
  final String title;
  final String description;

  InsightModel({
    required this.source,
    required this.title,
    required this.description,
  });

  // Fábrica para caso você decida mudar para uma API real no futuro
  factory InsightModel.fromJson(Map<String, dynamic> json) {
    return InsightModel(
      source: json['source'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}