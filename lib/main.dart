import 'package:flutter/material.dart';
import 'views/login_view.dart';
import 'views/dashboard_view.dart';
import 'views/analysis_view.dart';

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