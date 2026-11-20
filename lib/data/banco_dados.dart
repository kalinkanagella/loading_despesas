
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/despesa.dart';

class BancoDados {
  static Database? _database;
  static Future<Database>? _databaseFuture;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _databaseFuture ??= _initDB();

    try {
      _database = await _databaseFuture!;
      return _database!;
    } catch (e) {
      _databaseFuture = null;
      rethrow;
    }
  }

  Future<Database> _initDB() async {
    final String path = join(
      await getDatabasesPath(),
      'despesas.db',
    );

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE despesas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            descricao TEXT NOT NULL,
            valor REAL NOT NULL,
            data TEXT NOT NULL,
            categoria TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> inserir(Despesa despesa) async {
    final db = await database;

    return await db.insert(
      'despesas',
      despesa.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<Despesa>> listarPorMes(int ano, int mes) async {
    final db = await database;

    final mesFormatado = mes.toString().padLeft(2, '0');
    final filtro = '$ano-$mesFormatado%';

    final result = await db.query(
      'despesas',
      where: 'data LIKE ?',
      whereArgs: [filtro],
      orderBy: 'data DESC',
    );

    return result.map((json) => Despesa.fromMap(json)).toList();
  }

  Future<int> deletar(int id) async {
    final db = await database;

    return await db.delete(
      'despesas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
