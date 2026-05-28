import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/financial_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  void _showAddTransactionSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final valueController = TextEditingController();
    String selectedType = 'Entrada';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 24, left: 24, right: 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("Nova Transação", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Título (Ex: Mercado)"),
                  validator: (v) => v == null || v.isEmpty ? "Insira um título" : null,
                ),
                TextFormField(
                  controller: valueController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Valor (R\$)"),
                  validator: (v) => v == null || double.tryParse(v) == null ? "Insira um valor numérico" : null,
                ),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  items: ['Entrada', 'Saída'].map((String type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (v) => selectedType = v!,
                  decoration: const InputDecoration(labelText: "Tipo"),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final today = DateTime.now().toString().split(' ')[0];
                      context.read<FinancialViewModel>().addTransaction(
                            titleController.text,
                            double.parse(valueController.text),
                            today,
                            selectedType,
                          );
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text("Salvar"),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<AuthViewModel>().currentUser?.name ?? "Usuário";
    final financialViewModel = context.watch<FinancialViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Olá, $userName"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthViewModel>().logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            color: Colors.deepPurple.shade50,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text("Saldo Atual", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    "R\$ ${financialViewModel.totalBalance.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: financialViewModel.totalBalance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/analise'),
            icon: const Icon(Icons.bar_chart),
            label: const Text("Ver Análise Orçamentária"),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(alignment: Alignment.centerLeft, child: Text("Suas Transações", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ),
          Expanded(
            child: financialViewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: financialViewModel.transactions.length,
                    itemBuilder: (context, index) {
                      final tx = financialViewModel.transactions[index];
                      return ListTile(
                        leading: Icon(
                          tx.type == 'Entrada' ? Icons.arrow_upward : Icons.arrow_downward,
                          color: tx.type == 'Entrada' ? Colors.green : Colors.red,
                        ),
                        title: Text(tx.title),
                        subtitle: Text(tx.date),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "R\$ ${tx.value.toStringAsFixed(2)}",
                              style: TextStyle(fontWeight: FontWeight.bold, color: tx.type == 'Entrada' ? Colors.green : Colors.red),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.grey),
                              onPressed: () => context.read<FinancialViewModel>().removeTransaction(tx.id!),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}