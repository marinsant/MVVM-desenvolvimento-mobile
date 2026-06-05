// lib/models/currency_model.dart

class CurrencyModel {
  final String code;       // ex: "USD"
  final String name;       // ex: "Dólar Americano/Real Brasileiro"
  final double bid;        // Valor atual de compra (ex: 5.45)
  final String pctChange;  // Porcentagem de variação no dia (ex: "0.25")

  CurrencyModel({
    required this.code,
    required this.name,
    required this.bid,
    required this.pctChange,
  });

  // Converte o JSON que vem da AwesomeAPI para o nosso objeto Flutter
  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      code: json['code'] ?? '',
      name: json['name']?.split('/')[0] ?? '', // Deixa apenas "Dólar Americano" em vez de "Dólar Americano/Real Brasileiro"
      bid: double.tryParse(json['bid'] ?? '0.0') ?? 0.0,
      pctChange: json['pctChange'] ?? '0.0',
    );
  }
}