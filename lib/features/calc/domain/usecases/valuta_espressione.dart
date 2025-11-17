import 'package:math_keyboard/math_keyboard.dart';
import 'package:math_expressions/math_expressions.dart';

class ValutaEspressione {
  double? call(
      String tex, { //Prende in input una stringa in formato TeX
        Map<String, num>? variabili,
      }) {
    try {
      //Converte la stringa TeX in una "Expression" di math_expressions.
      final espressione = TeXParser(tex).parse();

      //Crea un contesto in cui associare eventuali variabili (x, y, t...)
      final contesto = ContextModel();

      //Associa ogni variabile passata alla Expression.
      variabili?.forEach((nome, valore) {
        contesto.bindVariable(
          Variable(nome),
          Number(valore.toDouble()),
        );
      });

      //Valuta l'espressione in campo reale.
      final risultato = espressione.evaluate(
        EvaluationType.REAL,
        contesto,
      );

      //Converte il risultato in double.
      return risultato.toDouble();
    } catch (_) {
      // Se c'è errore mentimu null e queti.
      return null;
    }
  }
}