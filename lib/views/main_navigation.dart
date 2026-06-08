import 'package:flutter/material.dart';
import 'dashboard_view.dart';
import 'analysis_view.dart';
import 'feedback_view.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _telaAtualIndex = 0;

  // Lista com as telas reais do seu aplicativo integrado
  final List<Widget> _telas = [
    const DashboardView(),
    const AnalysisView(),
    const FeedbackView(),
  ];

  final List<String> _titulos = [
    'Dashboard',
    'Análise de Investimentos',
    'Feedback & Sugestões',
  ];

  @override
  Widget build(BuildContext context) {
    // Cor padrão do seu tema do main.dart
    const brandColor = Color(0xFF0F2C3D); 

    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_telaAtualIndex], style: const TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: brandColor,
        foregroundColor: Colors.white,
      ),
      body: _telas[_telaAtualIndex],
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: brandColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.account_balance_wallet, size: 44, color: Color(0xFF00E676)),
                  SizedBox(height: 12),
                  Text(
                    'Controle Financeiro Pro',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Menu de Funcionalidades',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.analytics_rounded, color: brandColor),
              // CORRIGIDO: Alterado de Pisth.w500 para FontWeight.w500
              title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.w500)), 
              selected: _telaAtualIndex == 0,
              selectedColor: const Color(0xFF00E676),
              onTap: () {
                setState(() => _telaAtualIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart_rounded, color: brandColor),
              title: const Text('Análise Financeira', style: TextStyle(fontWeight: FontWeight.w500)),
              selected: _telaAtualIndex == 1,
              selectedColor: const Color(0xFF00E676),
              onTap: () {
                setState(() => _telaAtualIndex = 1);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.rate_review_rounded, color: brandColor),
              title: const Text('Enviar Feedback', style: TextStyle(fontWeight: FontWeight.w500)),
              selected: _telaAtualIndex == 2,
              selectedColor: const Color(0xFF00E676),
              onTap: () {
                setState(() => _telaAtualIndex = 2);
                Navigator.pop(context);
              },
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Avaliação de Interfaces Web • 2026',
                style: TextStyle(color: Colors.grey, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}