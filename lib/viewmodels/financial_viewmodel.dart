import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../repositories/financial_repository.dart';

class FinancialViewModel extends ChangeNotifier {
  final FinancialRepository _repository;
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String _selectedMonth = '2026-05'; // Alinhado com o escopo do seu projeto

  FinancialViewModel(this._repository) {
    _loadTransactions();
  }

  // Getters para a View escutar os estados
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String get selectedMonth => _selectedMonth;

  // Calcula o saldo total automaticamente somando entradas e saídas
  double get totalBalance {
    double balance = 0.0;
    for (var tx in _transactions) {
      balance += tx.amount; 
    }
    return balance;
  }

  // Busca e atualiza a lista de transações do repositório
  Future<void> _loadTransactions() async {
    _isLoading = true;
    notifyListeners();
    try {
      _transactions = await _repository.getTransactions();
    } catch (e) {
      debugPrint("Erro ao carregar transações: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  // Adiciona transação e gera ID se necessário (Garante funcionamento na Web)
  Future<bool> addTransaction(TransactionModel transaction) async {
    try {
      final txComId = transaction.id == null || transaction.id!.isEmpty
          ? transaction.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString())
          : transaction;

      await _repository.saveTransaction(txComId);
      await _loadTransactions(); // Recarrega a lista atualizada
      return true;
    } catch (e) {
      debugPrint("Erro ao adicionar transação: $e");
      return false;
    }
  }

  // Remove a transação e retorna se a operação foi concluída
  Future<bool> removeTransaction(String id) async {
    try {
      await _repository.deleteTransaction(id);
      await _loadTransactions(); // Recarrega a lista e notifica a tela
      return true; // Retorno crucial para disparar o SnackBar de sucesso
    } catch (e) {
      debugPrint("Erro ao remover transação: $e");
      return false; // Retorna falso caso ocorra alguma falha interna
    }
  }

  // Filtro por mês
  void changeMonthFilter(String month) {
    _selectedMonth = month;
    notifyListeners();
  }
}