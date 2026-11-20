
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/despesa.dart';
import '../data/banco_dados.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();

  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();

  DateTime _dataSelecionada = DateTime.now();
  String _categoriaSelecionada = 'Alimentação';

  final List<String> _categorias = [
    'Alimentação',
    'Transporte',
    'Lazer',
    'Saúde',
    'Outros',
  ];

  final Color roxoLoading = const Color(0xFF5E239D);
  final Color roxoNeon = const Color(0xFF8B5CF6);

  final BancoDados _bancoDados = BancoDados();

  bool _salvando = false;

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    if (_salvando) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: roxoLoading,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _dataSelecionada = picked;
      });
    }
  }

  Future<void> _salvarDespesa() async {
    if (_salvando) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final valorTexto = _valorController.text
        .trim()
        .replaceAll(',', '.');

    final valorDouble = double.tryParse(valorTexto);

    if (valorDouble == null || valorDouble <= 0) {
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      final novaDespesa = Despesa(
        descricao: _descricaoController.text.trim(),
        valor: valorDouble,
        data: _dataSelecionada,
        categoria: _categoriaSelecionada,
      );

      await _bancoDados.inserir(novaDespesa);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Despesa salva com sucesso!',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: const Color(0xFF16A37A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e, stackTrace) {
      debugPrint('Erro ao salvar despesa: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível salvar a despesa. Tente novamente.',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark
        ? const Color(0xFF0F111A)
        : const Color(0xFFF7F6FA);

    final surfaceColor = isDark
        ? const Color(0xFF1C1F2E)
        : Colors.white;

    final textColor = isDark
        ? Colors.white
        : const Color(0xFF252333);

    final labelColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF898593);

    final iconColor = isDark ? roxoNeon : roxoLoading;

    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: iconColor),
        title: Text(
          'Nova Despesa',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _descricaoController,
                label: 'Descrição',
                icon: Icons.description_outlined,
                iconColor: iconColor,
                surfaceColor: surfaceColor,
                textColor: textColor,
                labelColor: labelColor,
                validator: (value) {
                  return value == null || value.trim().isEmpty
                      ? 'Por favor, insira uma descrição'
                      : null;
                },
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _valorController,
                label: 'Valor (R\$)',
                icon: Icons.attach_money,
                iconColor: iconColor,
                surfaceColor: surfaceColor,
                textColor: textColor,
                labelColor: labelColor,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Insira o valor';
                  }

                  final valor = double.tryParse(
                    value.trim().replaceAll(',', '.'),
                  );

                  if (valor == null || valor <= 0) {
                    return 'Insira um valor válido maior que zero';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              InkWell(
                onTap: _selecionarData,
                borderRadius: BorderRadius.circular(14),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Data',
                    labelStyle: TextStyle(color: labelColor),
                    prefixIcon: Icon(
                      Icons.calendar_today_outlined,
                      color: iconColor,
                    ),
                    filled: true,
                    fillColor: surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy')
                        .format(_dataSelecionada),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _categoriaSelecionada,
                dropdownColor: surfaceColor,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  labelText: 'Categoria',
                  labelStyle: TextStyle(color: labelColor),
                  prefixIcon: Icon(
                    Icons.category_outlined,
                    color: iconColor,
                  ),
                  filled: true,
                  fillColor: surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _categorias.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(
                      cat,
                      style: TextStyle(color: textColor),
                    ),
                  );
                }).toList(),
                onChanged: _salvando
                    ? null
                    : (novoValor) {
                        if (novoValor != null) {
                          setState(() {
                            _categoriaSelecionada = novoValor;
                          });
                        }
                      },
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _salvando ? null : _salvarDespesa,
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: iconColor.withOpacity(0.6),
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _salvando
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Salvar Despesa',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color surfaceColor,
    required Color textColor,
    required Color labelColor,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: labelColor),
        prefixIcon: Icon(icon, color: iconColor),
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: iconColor,
            width: 1.5,
          ),
        ),
      ),
      validator: validator,
    );
  }
}
