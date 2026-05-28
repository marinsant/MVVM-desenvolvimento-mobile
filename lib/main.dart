import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/financial_viewmodel.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/dashboard_view.dart';
import 'views/analysis_view.dart';

void main() {
  runApp(
    
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => FinancialViewModel()),
      ],
      child: const FinancialApp(),
    ),
  );
}

class FinancialApp extends StatelessWidget {
  const FinancialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Controle Financeiro Pro',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/home': (context) => const DashboardView(),
        '/analise': (context) => const AnalysisView(),
      },
    );
  }
}