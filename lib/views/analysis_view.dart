import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

class AnalysisView extends ConsumerWidget {
  const AnalysisView({super.key});

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Mercado': return Icons.shopping_basket_outlined;
      case 'Lazer': return Icons.sports_esports_outlined;
      case 'Transporte': return Icons.directions_car_outlined;
      case 'Salário': return Icons.monetization_on_outlined;
      case 'Contas': return Icons.receipt_long_outlined;
      default: return Icons.category_outlined;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Mercado': return const Color(0xFFFF9800);
      case 'Lazer': return const Color(0xFF9C27B0);
      case 'Transporte': return const Color(0xFF2196F3);
      case 'Salário': return const Color(0xFF4CAF50);
      case 'Contas': return const Color(0xFFE91E63);
      default: return const Color(0xFF607D8B);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fViewModel = ref.watch(financialProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Análise Orçamentária", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Builder(
        builder: (context) {
          // Se você adicionou o getter isLoading no seu FinancialState, este bloco funcionará perfeitamente
          if (fViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF0F2C3D)));
          }

          double totalEntradas = 0.0;
          double totalSaidas = 0.0;
          Map<String, double> gastosPorCategoria = {};
          int transacoesDoMesCount = 0;

          // Processa as transações aplicando as regras do modelo unificado e filtrando pelo mês selecionado
          for (var tx in fViewModel.transactions) {
            final tMonth = "${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}";
            
            if (tMonth == fViewModel.selectedMonth) {
              transacoesDoMesCount++;
              
              if (tx.amount > 0) {
                // É uma Entrada/Receita
                totalEntradas += tx.amount;
              } else {
                // É uma Saída/Despesa (convertida para positivo via .abs() para somas de exibição)
                final valorAbsoluto = tx.amount.abs();
                totalSaidas += valorAbsoluto;
                gastosPorCategoria[tx.category] = (gastosPorCategoria[tx.category] ?? 0.0) + valorAbsoluto;
              }
            }
          }

          if (transacoesDoMesCount == 0) {
            return Center(
              child: Text("Sem dados para analisar neste mês.", style: TextStyle(color: Colors.grey.shade500)),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 768) {
                return _buildWideLayout(totalEntradas, totalSaidas, gastosPorCategoria);
              } else {
                return _buildMobileLayout(totalEntradas, totalSaidas, gastosPorCategoria);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildWideLayout(double entradas, double saidas, Map<String, double> categorias) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Resumo do Fluxo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F2C3D))),
                    const SizedBox(height: 16),
                    _buildSummaryCard("Total de Entradas", entradas, const Color(0xFF4CAF50), Icons.arrow_upward_rounded),
                    const SizedBox(height: 16),
                    _buildSummaryCard("Total de Despesas", saidas, const Color(0xFFE91E63), Icons.arrow_downward_rounded),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Divisão por Categorias de Gasto", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F2C3D))),
                    const SizedBox(height: 16),
                    Expanded(child: _buildCategoryList(categorias, saidas)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(double entradas, double saidas, Map<String, double> categorias) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Resumo Geral", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F2C3D))),
          const SizedBox(height: 12),
          _buildSummaryCard("Total de Entradas", entradas, const Color(0xFF4CAF50), Icons.arrow_upward_rounded),
          const SizedBox(height: 12),
          _buildSummaryCard("Total de Despesas", saidas, const Color(0xFFE91E63), Icons.arrow_downward_rounded),
          const SizedBox(height: 24),
          const Text("Gastos por Categoria", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F2C3D))),
          const SizedBox(height: 12),
          ...categorias.entries.map((entry) {
            final percent = saidas > 0 ? (entry.value / saidas) : 0.0;
            return _buildCategoryRow(entry.key, entry.value, percent);
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, double value, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(
                "R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F2C3D)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCategoryList(Map<String, double> categorias, double totalSaidas) {
    if (categorias.isEmpty) {
      return Center(child: Text("Nenhuma despesa registrada.", style: TextStyle(color: Colors.grey.shade400)));
    }

    final listaOrdenada = categorias.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return ListView.builder(
      itemCount: listaOrdenada.length,
      itemBuilder: (context, index) {
        final entry = listaOrdenada[index];
        final percent = totalSaidas > 0 ? (entry.value / totalSaidas) : 0.0;
        return _buildCategoryRow(entry.key, entry.value, percent);
      },
    );
  }

  Widget _buildCategoryRow(String category, double value, double percent) {
    final cor = _getCategoryColor(category);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(_getCategoryIcon(category), color: cor, size: 20),
                  const SizedBox(width: 8),
                  Text(category, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2C3D))),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2C3D))),
                  Text("${(percent * 100).toStringAsFixed(1)}%", style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ],
              )
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(cor),
              minHeight: 8,
            ),
          )
        ],
      ),
    );
  }
}