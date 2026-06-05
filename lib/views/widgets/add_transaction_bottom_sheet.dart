import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/transaction_model.dart';
import '../../providers/app_providers.dart';

class AddTransactionBottomSheet extends ConsumerStatefulWidget {
  final List<String> categories;

  const AddTransactionBottomSheet({super.key, required this.categories});

  @override
  ConsumerState<AddTransactionBottomSheet> createState() => _AddTransactionBottomSheetState();
}

class _AddTransactionBottomSheetState extends ConsumerState<AddTransactionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  
  late String _selectedCategory;
  String _transactionType = 'Saída'; // Padrão começa como Despesa/Saída

  @override
  void initState() {
    super.initState();
    // Garante que a categoria inicial exista dentro da lista fornecida para evitar erros no Dropdown
    if (widget.categories.contains('Mercado')) {
      _selectedCategory = 'Mercado';
    } else {
      _selectedCategory = widget.categories.isNotEmpty ? widget.categories.first : '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitData() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    
    // Remove os pontos de milhar e substitui a vírgula decimal por ponto para o double.parse
    final cleanAmountText = _amountController.text.replaceAll('.', '').replaceAll(',', '.');
    final parsedAmount = double.parse(cleanAmountText);
    
    // Se for 'Saída', o valor é salvo como negativo para bater com as contas do Dashboard
    final finalAmount = _transactionType == 'Saída' ? -parsedAmount : parsedAmount;

    // Criando o modelo unificado
    final novaTransacao = TransactionModel(
      title: title,
      amount: finalAmount,
      date: DateTime.now(),
      category: _selectedCategory,
      isSynced: 0, // Começa como 0 (não sincronizado) até o repositório avaliar a conexão
    );

    HapticFeedback.vibrate();

    // ATUALIZADO: Com o NotifierProvider, acessamos as funções usando o '.notifier'
    ref.read(financialProvider.notifier).addTransaction(novaTransacao);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Garante que o modal suba junto com o teclado na tela do celular
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nova Transação',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F2C3D)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Seletor de Tipo (Entrada ou Saída)
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Saída (Despesa)')),
                      selected: _transactionType == 'Saída',
                      selectedColor: Colors.red.shade100,
                      labelStyle: TextStyle(
                        color: _transactionType == 'Saída' ? Colors.red.shade700 : Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) => setState(() => _transactionType = 'Saída'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Entrada (Receita)')),
                      selected: _transactionType == 'Entrada',
                      selectedColor: Colors.green.shade100,
                      labelStyle: TextStyle(
                        color: _transactionType == 'Entrada' ? Colors.green.shade700 : Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) => setState(() => _transactionType = 'Entrada'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Campo de Título
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Descrição / Título',
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Insira uma descrição' : null,
              ),
              const SizedBox(height: 16),

              // Campo de Valor
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Valor (R\$)',
                  prefixIcon: const Icon(Icons.attach_money_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: '0,00',
                ),
                validator: (val) {
                  if (val == null || val.isEmpty || val == '0,00') return 'Insira um valor';
                  
                  final cleanText = val.replaceAll('.', '').replaceAll(',', '.');
                  final parsedValue = double.tryParse(cleanText);
                  
                  if (parsedValue == null) return 'Valor inválido';
                  if (parsedValue <= 0) return 'O valor deve ser maior que zero';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Seletor de Categorias
              if (widget.categories.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Categoria',
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: widget.categories.map((String categoria) {
                    return DropdownMenuItem<String>(
                      value: categoria,
                      child: Text(categoria),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() => _selectedCategory = newValue);
                    }
                  },
                ),
              const SizedBox(height: 24),

              // Botão de Confirmar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F2C3D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: _submitData,
                  child: const Text(
                    'Adicionar Registro',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// FORMATADOR DE MOEDA EXECUTADO EM TEMPO REAL
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '0,00', selection: const TextSelection.collapsed(offset: 4));
    }

    String apenasDigitos = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    double valorDouble = double.parse(apenasDigitos) / 100.0;
    String textoFormatado = valorDouble.toStringAsFixed(2).replaceAll('.', ',');

    List<String> partes = textoFormatado.split(',');
    String parteInteira = partes[0];
    String parteDecimal = partes[1];

    final RegExp regMilhar = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    parteInteira = parteInteira.replaceAllMapped(regMilhar, (Match match) => '${match[1]}.');

    textoFormatado = '$parteInteira,$parteDecimal';

    return newValue.copyWith(
      text: textoFormatado,
      selection: TextSelection.collapsed(offset: textoFormatado.length),
    );
  }
}