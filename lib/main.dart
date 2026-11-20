// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  runApp(const MeuApp());
}

class MeuApp extends StatefulWidget {
  const MeuApp({super.key});

  @override
  State<MeuApp> createState() => _MeuAppState();
}

class _MeuAppState extends State<MeuApp> {
  // Agora começa no MODO ESCURO (para manter a identidade tech)
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color roxoPrincipal = Color(0xFF8B5CF6); // Roxo neon da Loading

    return MaterialApp(
      title: 'Loading Despesas',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      
      // TEMA CLARO (Opcional para o usuário)
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: GoogleFonts.inter().fontFamily,
        primaryColor: const Color(0xFF5E239D),
        scaffoldBackgroundColor: const Color(0xFFF7F6FA),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5E239D), brightness: Brightness.light),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F6FA),
          foregroundColor: Color(0xFF252333),
          elevation: 0,
        ),
      ),

      // TEMA ESCURO (Padrão - Igual ao site da Loading)
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: GoogleFonts.inter().fontFamily,
        primaryColor: roxoPrincipal,
        scaffoldBackgroundColor: const Color(0xFF0A0410), // Fundo quase preto com tom roxo
        colorScheme: ColorScheme.fromSeed(
          seedColor: roxoPrincipal, 
          brightness: Brightness.dark,
          surface: const Color(0xFF160B24), // Superfície roxa escura
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0410),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      
      home: HomeScreen(onToggleTheme: _toggleTheme),
    );
  }
}