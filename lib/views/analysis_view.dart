import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/financial_viewmodel.dart';

class AnalysisView extends StatelessWidget {
  const AnalysisView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FinancialViewModel>();
    final percentage = viewModel.budgetUsagePercentage;

    return Scaffold(
      appBar: AppBar(title: const Text("Análise de Gastos")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pie_chart, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 24),
              const Text("Uso do Orçamento Disponível", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: percentage,
                minHeight: 12,
                backgroundColor: Colors.grey.shade300,
                color: percentage > 0.8 ? Colors.red : Colors.deepPurple,
              ),
              const SizedBox(height: 16),
              Text(
                "${(percentage * 100).toStringAsFixed(0)}% das suas receitas foram consumidas.",
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Voltar para Dashboard"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}