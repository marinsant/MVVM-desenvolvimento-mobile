import 'package:flutter/material.dart';
import '../viewmodels/financial_viewmodel.dart';

class AnalysisView extends StatelessWidget {
  const AnalysisView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = FinancialViewModel();

    return Scaffold(
      appBar: AppBar(title: const Text("Análise Financeira")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Uso do Orçamento"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: LinearProgressIndicator(
                value: viewModel.budgetUsage, 
                minHeight: 10,
              ),
            ),
            Text("${(viewModel.budgetUsage * 100).toInt()}% do limite atingido"),
            const SizedBox(height: 20),
            IconButton(
              onPressed: () => Navigator.pop(context), 
              icon: const Icon(Icons.arrow_back)
            ),
          ],
        ),
      ),
    );
  }
}