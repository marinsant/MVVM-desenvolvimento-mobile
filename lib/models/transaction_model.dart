class TransactionModel {
  final String? id;
  final String title;
  final double amount; 
  final DateTime date;
  final String category;
  final int isSynced;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.isSynced = 0,
  });

  String get type => amount >= 0 ? 'Entrada' : 'Saída';
  double get value => amount.abs();

  // Métodos universais (Conserta o erro do toMap)
  Map<String, dynamic> toMap() => toSQLiteMap();

  Map<String, dynamic> toSQLiteMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'isSynced': isSynced,
    };
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
    };
  }

  // Factories universais (Conserta o erro do fromMap)
  factory TransactionModel.fromMap(Map<String, dynamic> map) => TransactionModel.fromSQLiteMap(map);

  factory TransactionModel.fromSQLiteMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id']?.toString(),
      title: map['title'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      category: map['category'] ?? '',
      isSynced: map['isSynced'] ?? 0,
    );
  }

  TransactionModel copyWith({String? id, int? isSynced}) {
    return TransactionModel(
      id: id ?? this.id,
      title: this.title,
      amount: this.amount,
      date: this.date,
      category: this.category,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}