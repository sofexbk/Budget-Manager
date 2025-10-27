import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firstapp/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(BudgetApp());

    // Ici, adapte les tests en fonction de ton app réelle
    // Par exemple, si tu veux tester la présence du texte "Bienvenue !" :
    expect(find.text('Bienvenue !'), findsOneWidget);

    // Et si tu veux tester les boutons ou champs de saisie :
    expect(find.byType(TextField), findsWidgets);
  });
}
