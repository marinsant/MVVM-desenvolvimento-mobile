import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/transaction_model.dart';

class FinancialViewModel extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  // Construtor já busca os dados salvos do banco ao iniciar
  FinancialViewModel() {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();
    _transactions = await DbHelper.instance.getAllTransactions();
    _isLoading = false;
    notifyListeners();
  }

  // CÁLCULO DE SALDO AUTOMÁTICO (Requisito obrigatório)
  double get totalBalance {
    double balance = 0.0;
    for (var tx in _transactions) {
      if (tx.type == 'Entrada') {
        balance += tx.value;
      } else {
        balance -= tx.value;
      }
    }
    return balance;
  }

  // Retorna a porcentagem de uso do orçamento para a tela de análise
  double get budgetUsagePercentage {
    double despesas = 0.0;
    double receitas = 0.0;
    
    for (var tx in _transactions) {
      if (tx.type == 'Saída') despesas += tx.value;
      if (tx.type == 'Entrada') receitas += tx.value;
    }
    
    if (receitas == 0) return despesas > 0 ? 1.0 : 0.0;
    double percentage = despesas / receitas;
    return percentage > 1.0 ? 1.0 : percentage; // Limita em 100%
  }

  // OPERAÇÃO CRUD: Adicionar Transação
  Future<void> addTransaction(String title, double value, String date, String type) async {
    final newTx = TransactionModel(
      title: title,
      value: value,
      date: date,
      type: type,
    );
    await DbHelper.instance.insertTransaction(newTx);
    await loadTransactions(); // Atualiza a lista e o saldo automaticamente
  }

  // OPERAÇÃO CRUD: Excluir Transação
  Future<void> removeTransaction(int id) async {
    await DbHelper.instance.deleteTransaction(id);
    await loadTransactions(); // Atualiza a lista e o saldo automaticamente
  }
}