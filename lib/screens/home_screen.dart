
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cadastro_screen.dart';
import '../models/despesa.dart';
import '../data/banco_dados.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _mesAtual = DateTime.now();

  // Cores da Loading
  final Color roxoLoading = const Color(0xFF8B5CF6);
  final Color roxoEscuro = const Color(0xFF4A148C);
  final Color lavanda = const Color(0xFFA78BFA);

  final Color textoPrincipalClaro = const Color(0xFF252333);
  final Color textoSecundarioClaro = const Color(0xFF898593);
  final Color verdeReceita = const Color(0xFF16A37A);
  final Color vermelhoDespesa = const Color(0xFFDC626B);

  final BancoDados _bancoDados = BancoDados();

  List<Despesa> _despesas = [];
  double _totalMes = 0.0;

  bool _carregando = true;
  bool _excluindo = false;

  String _nomeUsuario = '';
  bool _ocultarValores = false;

  // Identifica o carregamento mais recente.
  // Evita que uma consulta antiga sobrescreva os dados novos.
  int _versaoCarregamento = 0;

  final NumberFormat _moeda = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  String _fmt(double valor) {
    return _ocultarValores ? 'R\$ ••••' : _moeda.format(valor);
  }

  @override
  void initState() {
    super.initState();

    _carregarNomeUsuario();
    _carregarDespesas();
  }

  // ===================== LÓGICA =====================

  Future<void> _carregarNomeUsuario() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!mounted) return;

      setState(() {
        _nomeUsuario = prefs.getString('nome_usuario') ?? '';
      });

      if (_nomeUsuario.isEmpty) {
        _pedirNome();
      }
    } catch (e) {
      debugPrint('Erro ao carregar nome do usuário: $e');
    }
  }

  void _pedirNome() {
    final TextEditingController nomeController =
        TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF160B24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bem-vindo!',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Como podemos te chamar?',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nomeController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Seu nome',
                  labelStyle: const TextStyle(
                    color: Colors.white54,
                  ),
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: roxoLoading,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF0A0410),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final nome = nomeController.text.trim();

                  if (nome.isEmpty) return;

                  try {
                    final prefs =
                        await SharedPreferences.getInstance();

                    await prefs.setString('nome_usuario', nome);

                    if (!mounted || !context.mounted) return;

                    setState(() {
                      _nomeUsuario = nome;
                    });

                    Navigator.pop(context);
                  } catch (e) {
                    debugPrint('Erro ao salvar nome: $e');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: roxoLoading,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(
                    double.infinity,
                    50,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Começar a usar',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    ).whenComplete(() {
      nomeController.dispose();
    });
  }

  Future<void> _carregarDespesas() async {
    if (!mounted) return;

    final versaoAtual = ++_versaoCarregamento;

    if (!_carregando) {
      setState(() {
        _carregando = true;
      });
    }

    try {
      final lista = await _bancoDados.listarPorMes(
        _mesAtual.year,
        _mesAtual.month,
      );

      if (!mounted || versaoAtual != _versaoCarregamento) {
        return;
      }

      final soma = lista.fold<double>(
        0.0,
        (total, despesa) => total + despesa.valor,
      );

      setState(() {
        _despesas = lista;
        _totalMes = soma;
        _carregando = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Erro ao carregar despesas: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted || versaoAtual != _versaoCarregamento) {
        return;
      }

      setState(() {
        _carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível carregar as despesas.',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: vermelhoDespesa,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
  }

  void _mudarMes(int offset) {
    if (_carregando) return;

    setState(() {
      _mesAtual = DateTime(
        _mesAtual.year,
        _mesAtual.month + offset,
        1,
      );
    });

    _carregarDespesas();
  }

  Future<void> _excluirDespesa(int id) async {
    if (_excluindo) return;

    setState(() {
      _excluindo = true;
    });

    try {
      await _bancoDados.deletar(id);

      if (!mounted) return;

      await _carregarDespesas();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Despesa excluída!',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: vermelhoDespesa,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Erro ao excluir despesa: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível excluir a despesa.',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: vermelhoDespesa,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _excluindo = false;
        });
      }
    }
  }

  Future<void> _abrirCadastro() async {
    if (_carregando) return;

    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const CadastroScreen(),
      ),
    );

    if (!mounted) return;

    // Só atualiza a lista quando uma despesa foi salva.
    if (resultado == true) {
      await _carregarDespesas();
    }
  }

  // ===================== HELPERS DE UI =====================

  IconData _iconeCategoria(String categoria) {
    final c = categoria.toLowerCase();

    if (c.contains('alimenta') ||
        c.contains('comida') ||
        c.contains('mercado') ||
        c.contains('restaurante')) {
      return Icons.restaurant_outlined;
    }

    if (c.contains('transporte') ||
        c.contains('uber') ||
        c.contains('combust')) {
      return Icons.directions_car_outlined;
    }

    if (c.contains('moradia') ||
        c.contains('casa') ||
        c.contains('aluguel')) {
      return Icons.home_outlined;
    }

    if (c.contains('lazer') ||
        c.contains('entretenimento')) {
      return Icons.sports_esports_outlined;
    }

    if (c.contains('saúde') ||
        c.contains('saude') ||
        c.contains('farm')) {
      return Icons.favorite_border;
    }

    if (c.contains('educa') ||
        c.contains('curso') ||
        c.contains('faculdade')) {
      return Icons.school_outlined;
    }

    if (c.contains('compra') || c.contains('roupa')) {
      return Icons.shopping_bag_outlined;
    }

    return Icons.receipt_long_outlined;
  }

  ({Color fg, Color bg}) _corCategoria(String categoria) {
    final c = categoria.toLowerCase();

    if (c.contains('alimenta') ||
        c.contains('comida') ||
        c.contains('mercado')) {
      return (
        fg: const Color(0xFFFF9F43),
        bg: const Color(0xFFFF9F43).withOpacity(0.15),
      );
    }

    if (c.contains('transporte') || c.contains('uber')) {
      return (
        fg: const Color(0xFF54A0FF),
        bg: const Color(0xFF54A0FF).withOpacity(0.15),
      );
    }

    if (c.contains('moradia') || c.contains('casa')) {
      return (
        fg: const Color(0xFF10B981),
        bg: const Color(0xFF10B981).withOpacity(0.15),
      );
    }

    if (c.contains('lazer') ||
        c.contains('entretenimento')) {
      return (
        fg: const Color(0xFFFF6B9D),
        bg: const Color(0xFFFF6B9D).withOpacity(0.15),
      );
    }

    return (
      fg: lavanda,
      bg: lavanda.withOpacity(0.15),
    );
  }

  // ===================== BUILD =====================

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark
        ? const Color(0xFF0A0410)
        : const Color(0xFFF3E8FF);

    final cardColor = isDark
        ? const Color(0xFF160B24)
        : Colors.white;

    final textColor =
        isDark ? Colors.white : textoPrincipalClaro;

    final textSubColor =
        isDark ? Colors.white60 : textoSecundarioClaro;

    final borderColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.grey.shade200;

    String mesFormatado =
        DateFormat('MMMM yyyy', 'pt_BR').format(_mesAtual);

    mesFormatado =
        mesFormatado[0].toUpperCase() +
        mesFormatado.substring(1);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(
        isDark,
        textColor,
        textSubColor,
      ),
      body: Column(
        children: [
          _buildSeletorMes(
            mesFormatado,
            textSubColor,
            textColor,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            child: _buildCardResumo(isDark),
          ),
          const SizedBox(height: 24),
          _buildCabecalhoLista(textColor, roxoLoading),
          Expanded(
            child: _carregando
                ? Center(
                    child: CircularProgressIndicator(
                      color: roxoLoading,
                    ),
                  )
                : _despesas.isEmpty
                    ? _buildEmptyState(
                        textColor,
                        textSubColor,
                      )
                    : _buildLista(
                        isDark,
                        cardColor,
                        borderColor,
                        textColor,
                        textSubColor,
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: roxoLoading,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onPressed: _abrirCadastro,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _buildBottomNav(
        isDark,
        cardColor,
        borderColor,
        textSubColor,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    bool isDark,
    Color textColor,
    Color textSubColor,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 80,
      titleSpacing: 24,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/logonome.png',
            height: 35,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Text(
                'LOADING',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: roxoLoading,
                  letterSpacing: 2,
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          Text(
            _nomeUsuario.isEmpty
                ? 'Olá!'
                : 'Olá, $_nomeUsuario',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: textSubColor,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            isDark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            color: roxoLoading,
          ),
          onPressed: widget.onToggleTheme,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 24),
          child: GestureDetector(
            onTap: () {},
            child: CircleAvatar(
              radius: 18,
              backgroundColor: roxoLoading.withOpacity(0.15),
              child: Icon(
                Icons.person_outline,
                size: 20,
                color: roxoLoading,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeletorMes(
    String mesFormatado,
    Color textSubColor,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              size: 22,
              color: textSubColor,
            ),
            splashRadius: 20,
            onPressed: _carregando
                ? null
                : () => _mudarMes(-1),
          ),
          SizedBox(
            width: 170,
            child: Text(
              mesFormatado,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              size: 22,
              color: textSubColor,
            ),
            splashRadius: 20,
            onPressed: _carregando
                ? null
                : () => _mudarMes(1),
          ),
        ],
      ),
    );
  }

  Widget _buildCardResumo(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            roxoLoading.withOpacity(0.8),
            roxoEscuro.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: roxoLoading.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saldo do mês',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    _ocultarValores = !_ocultarValores;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    _ocultarValores
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white.withOpacity(0.9),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(
              begin: 0,
              end: _totalMes,
            ),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, valor, child) => Text(
              _fmt(valor),
              style: GoogleFonts.inter(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildResumoItem(
                  Icons.arrow_downward_rounded,
                  'Despesas',
                  _totalMes,
                  vermelhoDespesa,
                ),
              ),
              Expanded(
                child: _buildResumoItem(
                  Icons.arrow_upward_rounded,
                  'Receitas',
                  0.0,
                  verdeReceita,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResumoItem(
    IconData icon,
    String label,
    double valor,
    Color cor,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: cor,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Text(
                _fmt(valor),
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCabecalhoLista(
    Color textColor,
    Color roxo,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 24,
        right: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Despesas recentes',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: roxo,
            ),
            child: Text(
              'Ver todas',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLista(
    bool isDark,
    Color cardColor,
    Color borderColor,
    Color textColor,
    Color textSubColor,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: 96,
      ),
      itemCount: _despesas.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final despesa = _despesas[index];
        final cor = _corCategoria(despesa.categoria);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cor.bg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconeCategoria(despesa.categoria),
                  color: cor.fg,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      despesa.descricao,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${DateFormat('dd/MM/yyyy').format(despesa.data)} • ${despesa.categoria}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: textSubColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '- ${_fmt(despesa.valor)}',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: vermelhoDespesa,
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: textSubColor,
                  size: 20,
                ),
                color: cardColor,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onSelected: (value) {
                  if (value == 'excluir' &&
                      despesa.id != null) {
                    _excluirDespesa(despesa.id!);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: 'excluir',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: vermelhoDespesa,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Excluir',
                          style: GoogleFonts.inter(
                            color: vermelhoDespesa,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(
    Color textColor,
    Color textSubColor,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 88,
              color: lavanda.withOpacity(0.45),
            ),
            const SizedBox(height: 16),
            Text(
              'Tudo limpo por aqui!',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione sua primeira despesa',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: textSubColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(
    bool isDark,
    Color cardColor,
    Color borderColor,
    Color textSubColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        border: Border(
          top: BorderSide(
            color: borderColor,
            width: 0.8,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: Colors.transparent,
        selectedItemColor: roxoLoading,
        unselectedItemColor: textSubColor,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
        ),
        onTap: (index) {
          if (index != 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Em breve: ${[
                    'Início',
                    'Despesas',
                    'Relatórios',
                    'Perfil'
                  ][index]}',
                  style: GoogleFonts.inter(),
                ),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Despesas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Relatórios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
