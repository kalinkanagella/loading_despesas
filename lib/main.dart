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
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color roxoPrincipal = Color(0xFF6D28D9);

    return MaterialApp(
      title: 'Loading Despesas',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: GoogleFonts.inter().fontFamily,
        primaryColor: roxoPrincipal,
        scaffoldBackgroundColor: Colors.transparent, // Deixa o degradê aparecer
        colorScheme: ColorScheme.fromSeed(seedColor: roxoPrincipal, brightness: Brightness.light),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent, // AppBar transparente no modo claro
          foregroundColor: Color(0xFF252333),
          elevation: 0,
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: GoogleFonts.inter().fontFamily,
        primaryColor: const Color(0xFF8B5CF6),
        scaffoldBackgroundColor: const Color(0xFF0F111A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6), 
          brightness: Brightness.dark,
          surface: const Color(0xFF1C1F2E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F111A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      
      home: HomeScreen(onToggleTheme: _toggleTheme),
    );
  }
}