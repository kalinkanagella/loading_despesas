import 'package:flutter_test/flutter_test.dart';
import 'package:controle_despesas/main.dart';

void main() {
  testWidgets('App deve renderizar a tela inicial', (WidgetTester tester) async {
    await tester.pumpWidget(const MeuApp());

    // Verifica se o texto "Loading Despesas" aparece na tela
    expect(find.text('Loading Despesas'), findsOneWidget);
  });
}