import 'package:flutter/material.dart';
import '../viewmodels/financial_viewmodel.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = FinancialViewModel();

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text("Saldo Atual"),
              subtitle: Text(viewModel.currentBalance, 
                  style: const TextStyle(fontSize: 20, color: Colors.green)),
            ),
          ),
          const Divider(),
          const Text("Transações Recentes", style: TextStyle(fontWeight: FontWeight.bold)),
          ...viewModel.transactions.map((t) => ListTile(
                leading: Icon(t.icon),
                title: Text(t.title),
                trailing: Text(t.value),
              )),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/analise'),
            child: const Text("Ver Análise Detalhada"),
          ),
        ],
      ),
    );
  }
}