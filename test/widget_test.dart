import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:controle_despesas/models/despesa.dart';
import 'package:controle_despesas/data/banco_dados.dart';

void main() {
  // Inicializa o banco de dados para rodar no terminal (FFI)
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Grupo de testes
  group('Testes do Banco de Dados', () {
    late BancoDados bancoDados;

    // Roda antes de cada teste para ter um banco limpo
    setUp(() async {
      bancoDados = BancoDados();
      // Limpa o banco antes de cada teste (deletando e recriando)
      final db = await bancoDados.database;
      await db.delete('despesas');
    });

    test('Deve inserir uma despesa e listar no mês correto', () async {
      // 1. Cria uma despesa de teste
      final despesaTeste = Despesa(
        descricao: 'Almoço de teste',
        valor: 50.0,
        data: DateTime(2026, 11, 20), // Novembro de 2026
        categoria: 'Alimentação',
      );

      // 2. Insere no banco
      final id = await bancoDados.inserir(despesaTeste);
      expect(id, greaterThan(0)); // Verifica se gerou um ID

      // 3. Tenta listar as despesas de Novembro/2026
      final lista = await bancoDados.listarPorMes(2026, 11);

      // 4. Verifica se a despesa foi encontrada
      expect(lista.length, 1);
      expect(lista.first.descricao, 'Almoço de teste');
      expect(lista.first.valor, 50.0);
    });

    test('Deve excluir uma despesa corretamente', () async {
      // 1. Insere uma despesa
      final despesaTeste = Despesa(
        descricao: 'Uber',
        valor: 20.0,
        data: DateTime.now(),
        categoria: 'Transporte',
      );
      final id = await bancoDados.inserir(despesaTeste);

      // 2. Exclui a despesa
      final deletados = await bancoDados.deletar(id);
      expect(deletados, 1); // Verifica se 1 linha foi deletada

      // 3. Tenta listar e verifica se a lista está vazia
      final lista = await bancoDados.listarPorMes(DateTime.now().year, DateTime.now().month);
      expect(lista.isEmpty, true);
    });
  });
}