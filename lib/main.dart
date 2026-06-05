import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Adicionado para o gerenciamento de estado avançado
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/dashboard_view.dart';
import 'views/analysis_view.dart';

void main() {
  runApp(
    // O ProviderScope inicializa o Riverpod e gerencia a Injeção de Dependência globalmente
    const ProviderScope(
      child: FinancialApp(),
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
        useMaterial3: true,
        brightness: Brightness.light,
        
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F2C3D),
          primary: const Color(0xFF0F2C3D),
          secondary: const Color(0xFF00E676),
          background: const Color(0xFFF4F7F6),
          surface: Colors.white,
        ),

        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F2C3D),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          labelStyle: const TextStyle(color: Color(0xFF0F2C3D)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF0F2C3D), width: 2),
          ),
        ),
      ),
      initialRoute: '/',
      // Mantido o gerenciador de rotas dinâmicas com animação fluida de Slide (Requisito de UX Superior)
      onGenerateRoute: (settings) {
        Widget page;
        
        switch (settings.name) {
          case '/':
            page = const LoginView(); // Lembre-se de refatorar as views para herdar de ConsumerWidget/ConsumerStatefulWidget
            break;
          case '/register':
            page = const RegisterView();
            break;
          case '/dashboard':
            page = const DashboardView();
            break;
          case '/analise':
            page = const AnalysisView();
            break;
          default:
            page = const LoginView();
        }

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeOutCubic));
            
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      },
    );
  }
}