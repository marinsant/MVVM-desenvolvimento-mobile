class NewsModel {
  final String title;
  final String description;
  final String source;

  NewsModel({
    required this.title,
    required this.description,
    required this.source,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json['title'] ?? '',
      description: json['body'] ?? '',
      source: 'Radar Econômico',
    );
  }
}