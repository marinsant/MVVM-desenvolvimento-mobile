class TransactionModel {
  final int? id;
  final String title;
  final double value;
  final String date;
  final String type; // 'Entrada' ou 'Saída'

  TransactionModel({this.id, required this.title, required this.value, required this.date, required this.type});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'value': value, 'date': date, 'type': type};
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      value: (map['value'] as num).toDouble(),
      date: map['date'],
      type: map['type'],
    );
  }
}