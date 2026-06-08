import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import 'analysis_view.dart';
import 'widgets/skeleton_loader.dart';
import 'widgets/add_transaction_bottom_sheet.dart';
import '../models/transaction_model.dart';
import 'dart:async';
import 'dart:ui'; // IMPORTANTE: Necessário para o efeito de Blur (ImageFilter)

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  static const List<String> categories = ['Mercado', 'Lazer', 'Transporte', 'Salário', 'Contas', 'Outros'];
  String _statusFilter = 'Todos';
  
  // VARIÁVEIS PARA O MOVIMENTO AUTOMÁTICO
  late PageController _pageController;
  Timer? _carouselTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

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

  String _formatTransactionDate(DateTime date) {
    try {
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (_) {
      return date.toString();
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFF0F2C3D)),
            SizedBox(width: 10),
            Text("Encerrar Sessão", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text("Você tem certeza que deseja sair da sua conta?"),
        actionsPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ref.read(authProvider.notifier).logout();
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  child: const Text("Sair", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("Cancelar", style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String transactionId) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Text("Excluir Transação?", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text("Você tem certeza? Esta ação removerá o registro permanentemente."),
        actionsPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent, 
                    foregroundColor: Colors.white, 
                    padding: const EdgeInsets.symmetric(vertical: 14), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
                    elevation: 0
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    HapticFeedback.mediumImpact();
                    
                    final sucesso = await ref.read(financialProvider.notifier).removeTransaction(transactionId);
                    
                    if (sucesso && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transação removida com sucesso!'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text("Excluir", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300), 
                    padding: const EdgeInsets.symmetric(vertical: 14), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("Cancelar", style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // CORRIGIDO: Agora intercepta erros de rede elegantemente em vez de sumir da árvore de componentes
  Widget _buildCurrencyRates() {
    final currencyAsync = ref.watch(currencyFutureProvider);

    return currencyAsync.when(
      data: (currencies) {
        if (currencies.isEmpty) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: currencies.map((currency) {
              final isPositive = !currency.pctChange.startsWith('-');
              return Row(
                children: [
                  Icon(
                    currency.code == 'USD' ? Icons.attach_money_rounded : Icons.euro_rounded,
                    color: const Color(0xFF0F2C3D),
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currency.code,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F2C3D)),
                      ),
                      Text(
                        "R\$ ${currency.bid.toStringAsFixed(2).replaceAll('.', ',')}",
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isPositive ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "${isPositive ? '+' : ''}${currency.pctChange}%",
                      style: TextStyle(
                        color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
      loading: () => Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F2C3D)),
          ),
        ),
      ),
      error: (err, stack) {
        // Identifica se o erro disparado foi o SocketException mapeado no provider
        final isNoInternet = err.toString().contains('SocketException');

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.shade100),
          ),
          child: Row(
            children: [
              Icon(
                isNoInternet ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                color: Colors.orange.shade800,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isNoInternet ? 'Sem Internet' : 'Erro de Cotação',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange.shade900),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      isNoInternet ? 'Verifique sua conexão de rede.' : 'Falha ao buscar dados na API.',
                      style: TextStyle(fontSize: 11, color: Colors.orange.shade700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh_rounded, color: Colors.orange.shade900, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Tentar Novamente',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // Força a reinicialização e reexecução limpa do FutureProvider
                  ref.invalidate(currencyFutureProvider);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNewsCarousel() {
    final newsAsync = ref.watch(newsFutureProvider);

    return newsAsync.when(
      data: (newsList) {
        if (newsList.isEmpty) return const SizedBox.shrink();
        
        return Container(
          height: 125,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final item = newsList[index % newsList.length];
              return Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F2C3D).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.source.toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF0F2C3D),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5
                              ),
                            ),
                          ),
                          const Icon(Icons.lightbulb_outline_rounded, color: Colors.amber, size: 18),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F2C3D)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.3),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => Container(
        height: 125,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(color: Color(0xFF0F2C3D), strokeWidth: 2),
          ),
        ),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fViewModel = ref.watch(financialProvider);
    final authViewModel = ref.watch(authProvider);

    final List<Map<String, String>> mesesFiltro = [
      {'label': 'Jan', 'value': '2026-01'},
      {'label': 'Fev', 'value': '2026-02'},
      {'label': 'Mar', 'value': '2026-03'},
      {'label': 'Abr', 'value': '2026-04'},
      {'label': 'Mai', 'value': '2026-05'},
      {'label': 'Jun', 'value': '2026-06'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Olá, 👋",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
            ),
            Text(
authViewModel.currentUser?['nome'] ?? authViewModel.currentUser?['name'] ?? 'Mário',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF0F2C3D)),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
              tooltip: 'Sair da Conta',
              onPressed: () => _showLogoutConfirmation(context),
            ),
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return _buildWideLayout(mesesFiltro, fViewModel);
          } else {
            return _buildMobileLayout(mesesFiltro, fViewModel);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0F2C3D),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () {
          HapticFeedback.lightImpact();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            barrierColor: Colors.black.withOpacity(0.3),
            builder: (ctx) => BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: AddTransactionBottomSheet(categories: categories),
            ),
          );
        },
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildWideLayout(List<Map<String, String>> mesesFiltro, dynamic fViewModel) {
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
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), 
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Filtro por Mês", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F2C3D))),
                          const SizedBox(height: 8),
                          _buildMonthSelector(mesesFiltro, fViewModel),
                          const SizedBox(height: 12),
                          _buildBalanceCard(fViewModel),
                          _buildCurrencyRates(),
                          _buildNewsCarousel(),
                          const SizedBox(height: 16),
                          _buildAnalysisButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Histórico Filtrado", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F2C3D))),
                        _buildStatusFilters(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(child: _buildTransactionList(fViewModel)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(List<Map<String, String>> mesesFiltro, dynamic fViewModel) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              _buildMonthSelector(mesesFiltro, fViewModel),
              _buildBalanceCard(fViewModel),
              _buildCurrencyRates(), 
              _buildNewsCarousel(),
              _buildAnalysisButton(),
              const SizedBox(height: 4),
            ],
          ),
        ),
        _buildStatusFilters(),
        const Padding(
          padding: EdgeInsets.only(left: 20, top: 12, bottom: 8),
          child: Align(
            alignment: Alignment.centerLeft, 
            child: Text("Histórico Filtrado", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F2C3D)))
          ),
        ),
        Expanded(child: _buildTransactionList(fViewModel)),
      ],
    );
  }

  Widget _buildMonthSelector(List<Map<String, String>> mesesFiltro, dynamic fViewModel) {
    return Container(
      height: 46,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: mesesFiltro.length,
        itemBuilder: (context, index) {
          final mes = mesesFiltro[index];
          final isSelected = fViewModel.selectedMonth == mes['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                mes['label']!, 
                style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF0F2C3D), fontWeight: FontWeight.bold, fontSize: 13)
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF0F2C3D),
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade200)),
              showCheckmark: false,
              onSelected: (_) {
                HapticFeedback.selectionClick();
                ref.read(financialProvider.notifier).changeMonthFilter(mes['value']!);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(dynamic fViewModel) {
    final List<TransactionModel> txList = List<TransactionModel>.from(fViewModel.transactions);
    final selectedMonth = fViewModel.selectedMonth;

    final filteredMonthList = txList.where((t) {
      final txMonthStr = "${t.date.year}-${t.date.month.toString().padLeft(2, '0')}";
      return txMonthStr == selectedMonth;
    }).toList();
    
    final entradas = filteredMonthList.where((t) => t.amount > 0).fold(0.0, (sum, item) => sum + item.amount);
    final saidas = filteredMonthList.where((t) => t.amount < 0).fold(0.0, (sum, item) => sum + item.amount.abs());
    final saldoMes = entradas - saidas;
    final totalGeral = entradas + saidas;
    final percentGasto = totalGeral > 0 ? (saidas / totalGeral) : 0.0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2C3D), Color(0xFF1E4E6D)], 
          begin: Alignment.topLeft, 
          end: Alignment.bottomRight
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F2C3D).withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Saldo no Mês Selecionado", style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
              Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF00E676), size: 22),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "R\$ ${saldoMes.toStringAsFixed(2).replaceAll('.', ',')}", 
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Uso das despesas: ${(percentGasto * 100).toStringAsFixed(0)}%", style: const TextStyle(color: Colors.white60, fontSize: 11)),
              Text("Despesas: R\$ ${saidas.toStringAsFixed(2).replaceAll('.', ',')}", style: const TextStyle(color: Colors.white60, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentGasto,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(percentGasto > 0.8 ? Colors.redAccent : const Color(0xFF00E676)),
              minHeight: 6,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAnalysisButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(46), 
          side: const BorderSide(color: Color(0xFF0F2C3D), width: 1.2), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white
        ),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalysisView())),
        icon: const Icon(Icons.bar_chart_rounded, color: Color(0xFF0F2C3D), size: 20),
        label: const Text("Ver Análise Orçamentária", style: TextStyle(color: Color(0xFF0F2C3D), fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  Widget _buildStatusFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: ['Todos', 'Entrada', 'Saída'].map((tipo) {
          final isSelected = _statusFilter == tipo;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                tipo == 'Todos' ? 'Todos' : '${tipo}s', 
                style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.bold)
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF194660),
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade200)),
              showCheckmark: false,
              onSelected: (_) => setState(() => _statusFilter = tipo),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionList(dynamic fViewModel) {
    if (fViewModel.isLoading) return const SkeletonLoader();

    final List<TransactionModel> txList = List<TransactionModel>.from(fViewModel.transactions);
    final selectedMonth = fViewModel.selectedMonth;

    final filteredList = txList.where((t) {
      final txMonthStr = "${t.date.year}-${t.date.month.toString().padLeft(2, '0')}";
      if (txMonthStr != selectedMonth) return false; 
      
      if (_statusFilter == 'Todos') return true;
      final isTxEntrada = t.amount > 0;
      return _statusFilter == 'Entrada' ? isTxEntrada : !isTxEntrada;
    }).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text("Nenhuma transação encontrada.", style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredList.length,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
      itemBuilder: (context, index) {
        final tx = filteredList[index];
        final isEntrada = tx.amount > 0;
        final corCategoria = _getCategoryColor(tx.category);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
            ]
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: corCategoria.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(_getCategoryIcon(tx.category), color: corCategoria, size: 22),
            ),
            title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2C3D), fontSize: 15)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                  Text("${_formatTransactionDate(tx.date)}  •  ", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: corCategoria.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
                    child: Text(tx.category, style: TextStyle(color: corCategoria, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    tx.isSynced == 1 ? Icons.cloud_done_rounded : Icons.cloud_queue_rounded,
                    size: 14,
                    color: tx.isSynced == 1 ? Colors.green : Colors.orange,
                  ),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${isEntrada ? '+ ' : '- '}R\$ ${tx.amount.abs().toStringAsFixed(2).replaceAll('.', ',')}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 14, 
                    color: isEntrada ? Colors.green.shade700 : Colors.red.shade700
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, color: Colors.grey.shade400, size: 22),
                  onPressed: () {
                    final idParaDeletar = tx.id ?? tx.date.millisecondsSinceEpoch.toString();
                    _confirmDelete(context, idParaDeletar);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}