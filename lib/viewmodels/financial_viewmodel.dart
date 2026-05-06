import 'package:flutter/material.dart';
import '../models/transaction.dart';

class FinancialViewModel {
  final String currentBalance = "R\$ 2.500,00";
  final double budgetUsage = 0.7; // 70%

  final List<Transaction> transactions = [
    Transaction(
      title: "Mercado",
      value: "- R\$ 150,00",
      icon: Icons.shopping_cart,
      color: Colors.red,
    ),
    Transaction(
      title: "Salário",
      value: "+ R\$ 3.000,00",
      icon: Icons.work,
      color: Colors.green,
    ),
  ];
}