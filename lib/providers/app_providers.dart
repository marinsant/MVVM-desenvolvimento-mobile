import 'dart:convert'; // Necessário para converter o JSON da API
import 'dart:io';      // 👈 ADICIONADO: Necessário para interceptar o SocketException
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http; // Importa o pacote HTTP

import '../models/insight_model.dart';
import '../models/currency_model.dart'; // Importa o modelo de moedas
import '../models/transaction_model.dart';

// ==========================================================================
// 1. PROVIDER DE INFORMAÇÕES E INSIGHTS (MOCK)
// ==========================================================================
final newsFutureProvider = FutureProvider<List<InsightModel>>((ref) async {
  await Future.delayed(const Duration(seconds: 2));
  return [
    InsightModel(
      source: 'EcoCondomínio',
      title: 'Gestão de Água da Chuva',
      description: 'A captação de água pluvial para a limpeza das áreas comuns e irrigação reduz em até 30% a conta de consumo geral.',
    ),
    InsightModel(
      source: 'Finanças',
      title: 'Fundo de Reserva Saudável',
      description: 'Manter a retenção de 5% a 10% da taxa condominial previne a necessidade de rateios extras para manutenções urgentes.',
    ),
    InsightModel(
      source: 'Energia',
      title: 'Iluminação Inteligente',
      description: 'A substituição de lâmpadas comuns por LED combinada com sensores de presença gera economia imediata no fluxo de caixa.',
    ),
  ];
});

// ==========================================================================
// 2. PROVIDER DA API DE COTAÇÕES REAL (AWESOMEAPI)
// ==========================================================================
final currencyFutureProvider = FutureProvider<List<CurrencyModel>>((ref) async {
  final url = Uri.parse('https://economia.awesomeapi.com.br/json/last/USD-BRL,EUR-BRL');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      List<CurrencyModel> listaDeCotacoes = [];

      if (data.containsKey('USDBRL')) {
        listaDeCotacoes.add(CurrencyModel.fromJson(data['USDBRL']));
      }
      if (data.containsKey('EURBRL')) {
        listaDeCotacoes.add(CurrencyModel.fromJson(data['EURBRL']));
      }

      return listaDeCotacoes;
    } else {
      throw Exception('Erro ao carregar dados da API: ${response.statusCode}');
    }
  } on SocketException catch (_) {
    // 👈 ADICIONADO: Tratamento de erro elegante para interceptar queda ou ausência de rede
    throw const SocketException('Sem conexão com a internet. Verifique sua rede e tente novamente.');
  } catch (e) {
    throw Exception('Falha na conexão com a AwesomeAPI: $e');
  }
});

// ==========================================================================
// 3. CLASSES DE ESTADO IMUTÁVEL (ESSENCIAIS PARA O NOTIFIER)
// ==========================================================================

class AuthState {
  final bool isLoading;
  final Map<String, dynamic>? currentUser;

  AuthState({required this.isLoading, this.currentUser});

  AuthState copyWith({bool? isLoading, Map<String, dynamic>? currentUser, bool clearUser = false}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
    );
  }
}

class FinancialState {
  final List<TransactionModel> transactions;
  final String selectedMonth;
  final String selectedTypeFilter;
  final bool isLoading; 

  FinancialState({
    required this.transactions,
    required this.selectedMonth,
    required this.selectedTypeFilter,
    this.isLoading = false,
  });

  List<TransactionModel> get filteredTransactions {
    return transactions.where((t) {
      if (selectedTypeFilter == 'Entrada' && t.amount < 0) return false;
      if (selectedTypeFilter == 'Saída' && t.amount > 0) return false;

      final tMonth = "${t.date.year}-${t.date.month.toString().padLeft(2, '0')}";
      return tMonth == selectedMonth;
    }).toList();
  }

  double get totalBalance {
    return transactions.fold(0.0, (sum, item) => sum + item.amount);
  }

  FinancialState copyWith({
    List<TransactionModel>? transactions,
    String? selectedMonth,
    String? selectedTypeFilter,
    bool? isLoading,
  }) {
    return FinancialState(
      transactions: transactions ?? this.transactions,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedTypeFilter: selectedTypeFilter ?? this.selectedTypeFilter,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ==========================================================================
// 4. PROVIDERS REATIVOS MODERNOS (NOTIFIERS)
// ==========================================================================

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // MANTIDO: Mantém o estado flexível para login e cadastro dinâmicos
    return AuthState(
      isLoading: false,
      currentUser: null, 
    );
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    
    await Future.delayed(const Duration(seconds: 1));
    
    final nomeExtraido = email.split('@').first;
    final nomeFormatado = nomeExtraido[0].toUpperCase() + nomeExtraido.substring(1);

    state = state.copyWith(
      isLoading: false,
      currentUser: {'nome': nomeFormatado, 'email': email},
    );
    return true;
  }

  Future<bool> register(dynamic usuario) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));

    if (usuario is Map<String, dynamic>) {
      state = state.copyWith(isLoading: false, currentUser: usuario);
    } else {
      state = state.copyWith(isLoading: false);
    }
    return true;
  }

  void logout() {
    state = state.copyWith(clearUser: true);
  }
}

final financialProvider = NotifierProvider<FinancialNotifier, FinancialState>(FinancialNotifier.new);

class FinancialNotifier extends Notifier<FinancialState> {
  @override
  FinancialState build() {
    return FinancialState(
      transactions: [],
      selectedMonth: '2026-06',
      selectedTypeFilter: 'Todos',
      isLoading: false,
    );
  }

  void changeMonthFilter(String month) {
    state = state.copyWith(selectedMonth: month);
  }

  void changeTypeFilter(String filter) {
    state = state.copyWith(selectedTypeFilter: filter);
  }

  void addTransaction(TransactionModel transaction) {
    state = state.copyWith(
      transactions: [...state.transactions, transaction],
    );
  }

  Future<bool> removeTransaction(dynamic transactionId) async {
    state = state.copyWith(isLoading: true);
    
    final listaAtualizada = state.transactions.where((t) {
      // MANTIDO: Lógica de fallback para bater perfeitamente com os IDs temporários da View
      final idDoItem = t.id ?? t.date.millisecondsSinceEpoch.toString();
      return idDoItem != transactionId.toString();
    }).toList();

    state = state.copyWith(
      transactions: listaAtualizada,
      isLoading: false,
    );
    return true;
  }
}