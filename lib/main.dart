import 'package:flutter/material.dart';

void main() => runApp(const FinancialApp());

class FinancialApp extends StatelessWidget {
  const FinancialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Controle Financeiro',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginView(),
        '/home': (context) => const DashboardView(),
        '/analise': (context) => const AnalysisView(),
      },
    );
  }
}

// --- TELA DE LOGIN ---
class LoginView extends StatelessWidget {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Login Financeiro", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const TextField(decoration: InputDecoration(labelText: "E-mail")),
            const TextField(decoration: InputDecoration(labelText: "Senha"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/home'),
              child: const Text("Entrar"),
            ),
          ],
        ),
      ),
    );
  }
}

// --- TELA DASHBOARD (HOME) ---
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: ListTile(title: Text("Saldo Atual"), subtitle: Text("R$ 2.500,00", style: TextStyle(fontSize: 20, color: Colors.green))),
          ),
          const Divider(),
          const Text("Transações Recentes", style: TextStyle(fontWeight: FontWeight.bold)),
          const ListTile(leading: Icon(Icons.shopping_cart), title: Text("Mercado"), trailing: Text("- R$ 150,00")),
          const ListTile(leading: Icon(Icons.work), title: Text("Salário"), trailing: Text("+ R$ 3.000,00")),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/analise'),
            child: const Text("Ver Análise Detalhada"),
          ),
        ],
      ),
    );
  }
}

// --- TELA DE ANÁLISE ---
class AnalysisView extends StatelessWidget {
  const AnalysisView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Análise Financeira")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Uso do Orçamento"),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: LinearProgressIndicator(value: 0.7, minHeight: 10),
            ),
            const Text("70% do limite atingido"),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
          ],
        ),
      ),
    );
  }
}
}