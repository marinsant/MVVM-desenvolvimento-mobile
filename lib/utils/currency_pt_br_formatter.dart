import 'package:flutter/services.dart';

class CurrencyPtBrFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();
    double value = double.parse(digits) / 100;
    String newText = "R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}";
    if (digits.length > 5) {
      final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      newText = newText.replaceAllMapped(reg, (Match match) => '${match[1]}.');
    }
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}