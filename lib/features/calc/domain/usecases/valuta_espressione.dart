import 'package:math_expressions/math_expressions.dart';

/// Converte una stringa TeX (quella che usi per mostrare la formula)
/// in una espressione numerica valutabile con `math_expressions`.
///
/// Supporta:
///   - +, -, *, /, %
///   - potenze con ^
///   - \sqrt{...}, \sqrt[n]{...}
///   - \ln(...), \log(...), \log_{10}(...), \log_{b}(...)
///   - funzioni trigonometriche: \sin, \cos, \tan, \arcsin, \arccos, \arctan
///   - costante \pi
///   - operatori di confronto: <, >, <=, >= (anche da \le, \ge, \leq, \geq)
///
/// Gli operatori di confronto vengono valutati come:
///   true  -> 1.0
///   false -> 0.0
class ValutaEspressione {
  ValutaEspressione() : _parser = GrammarParser();

  final GrammarParser _parser;

  double? call(
      String tex, {
        Map<String, num>? variabili,
      }) {
    final input = _convertTeXToExpression(tex);
    if (input.trim().isEmpty) return null;

    // 1) Prima provo a vedere se è un confronto (<, >, <=, >=)
    final confronto = _tryEvaluateComparison(input, variabili);
    if (confronto != null) return confronto;

    // 2) Provo la via "normale" con il parser.
    try {
      final espressione = _parser.parse(input);
      final contesto = _buildContext(variabili);

      final risultato = espressione.evaluate(
        EvaluationType.REAL,
        contesto,
      );

      if (risultato is num) {
        return risultato.toDouble();
      }
      return null;
    } catch (_) {
      // 3) Se il parser fallisce (es. problemi con % su alcune versioni),
      //    provo una valutazione di fallback per il modulo.
      final modulo = _tryEvaluateModulo(input, variabili);
      if (modulo != null) {
        return modulo;
      }
      // nient'altro da fare
      return null;
    }
  }

  ContextModel _buildContext(Map<String, num>? variabili) {
    final contesto = ContextModel();

    variabili?.forEach((nome, valore) {
      contesto.bindVariable(
        Variable(nome),
        Number(valore.toDouble()),
      );
    });

    return contesto;
  }

  // ---------------------------------------------------------------------------
  //  GESTIONE OPERATORI DI CONFRONTO: <, >, <=, >=
  // ---------------------------------------------------------------------------

  /// Riconosce espressioni del tipo:
  ///   "a < b", "x >= 2", "3\sqrt{2} <= 10", ecc.
  ///
  /// Supporta un solo operatore di confronto per espressione:
  ///   - "<"
  ///   - ">"
  ///   - "<="
  ///   - ">="
  ///
  /// Se non viene trovato alcun confronto, restituisce null.
  double? _tryEvaluateComparison(
      String input,
      Map<String, num>? variabili,
      ) {
    int depth = 0;
    for (int i = 0; i < input.length; i++) {
      final c = input[i];
      if (c == '(') {
        depth++;
      } else if (c == ')') {
        depth--;
      } else if (depth == 0 && (c == '<' || c == '>')) {
        // Controllo se c'è un '=' subito dopo -> <= o >=
        String op;
        int endIndex = i + 1;
        if (endIndex < input.length && input[endIndex] == '=') {
          op = c == '<' ? '<=' : '>=';
          endIndex++;
        } else {
          op = c.toString(); // "<" oppure ">"
        }

        final leftStr = input.substring(0, i);
        final rightStr = input.substring(endIndex);

        if (leftStr.trim().isEmpty || rightStr.trim().isEmpty) {
          return null;
        }

        try {
          final leftExpr = _parser.parse(leftStr);
          final rightExpr = _parser.parse(rightStr);

          final ctx = _buildContext(variabili);

          final lv = leftExpr.evaluate(EvaluationType.REAL, ctx);
          final rv = rightExpr.evaluate(EvaluationType.REAL, ctx);

          if (lv is! num || rv is! num) return null;

          final ld = lv.toDouble();
          final rd = rv.toDouble();

          bool res;
          switch (op) {
            case '<':
              res = ld < rd;
              break;
            case '>':
              res = ld > rd;
              break;
            case '<=':
              res = ld <= rd;
              break;
            case '>=':
              res = ld >= rd;
              break;
            default:
              return null;
          }

          // true -> 1.0, false -> 0.0
          return res ? 1.0 : 0.0;
        } catch (_) {
          return null;
        }
      }
    }

    return null; // nessun confronto trovato
  }

  // ---------------------------------------------------------------------------
  //  GESTIONE MODULO (%) DI FALLBACK
  // ---------------------------------------------------------------------------

  /// Prova a valutare espressioni che contengono l'operatore `%`
  /// nel caso in cui il parser non lo supporti/mandi eccezione.
  ///
  /// Esempio: "3%1", "10%4", ecc.
  ///
  /// Per non interferire con il parser:
  ///  - viene chiamata SOLO se il parser ha già lanciato un'eccezione.
  ///  - cerca un singolo `%` a "livello 0" di parentesi.
  ///  - valuta separatamente parte sinistra e destra con il parser.
  double? _tryEvaluateModulo(
      String input,
      Map<String, num>? variabili,
      ) {
    int depth = 0;
    int index = -1;

    for (int i = 0; i < input.length; i++) {
      final c = input[i];
      if (c == '(') {
        depth++;
      } else if (c == ')') {
        depth--;
      } else if (depth == 0 && c == '%') {
        index = i;
        break;
      }
    }

    if (index == -1) return null; // niente %

    final leftStr = input.substring(0, index);
    final rightStr = input.substring(index + 1);

    if (leftStr.trim().isEmpty || rightStr.trim().isEmpty) return null;

    try {
      final ctx = _buildContext(variabili);

      final leftExpr = _parser.parse(leftStr);
      final rightExpr = _parser.parse(rightStr);

      final lv = leftExpr.evaluate(EvaluationType.REAL, ctx);
      final rv = rightExpr.evaluate(EvaluationType.REAL, ctx);

      if (lv is! num || rv is! num) return null;

      final ld = lv.toDouble();
      final rd = rv.toDouble();

      if (rd == 0) {
        // modulo per 0: puoi decidere se restituire null o NaN
        return double.nan;
      }

      return ld % rd;
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  //  CONVERSIONE TeX -> stringa per math_expressions
  // ---------------------------------------------------------------------------

  /// Converte una stringa TeX (quella del mathfield) in una stringa
  /// compatibile con il parser di math_expressions.
  ///
  /// Esempi:
  ///   \sqrt{9}           -> sqrt(9)
  ///   \frac{1}{2}        -> (1)/(2)
  ///   \log_{10}(100)     -> (ln(100)/ln(10))
  ///   \le, \leq, \ge, \geq -> <=, >=
  ///   \cdot, \times      -> *
  ///   \div, ÷            -> /
  ///   %                  -> %  (modulo, gestito direttamente o da fallback)
  String _convertTeXToExpression(String tex) {
    var s = tex.trim();
    if (s.isEmpty) return s;

    // 1) togli spazi
    s = s.replaceAll(RegExp(r'\s+'), '');

    // 2) rimuovi \left e \right (non servono per il calcolo)
    s = s.replaceAll(r'\left', '').replaceAll(r'\right', '');

    // 3) LOGARITMI CON BASE: \log_{b}(x) -> ln(x)/ln(b)
    final logBaseRegex = RegExp(r'\\log_?\{([^{}]+)\}\(([^()]+)\)');
    while (logBaseRegex.hasMatch(s)) {
      s = s.replaceAllMapped(logBaseRegex, (m) {
        final base = m.group(1);
        final arg = m.group(2);
        return '(ln($arg)/ln($base))';
      });
    }

    // 4) \ln(x) e \log(x) (senza base) -> funzioni "ln" del parser
    s = s.replaceAll(r'\ln', 'ln');
    // qualunque \log(...) rimasto lo tratto come ln(...)
    s = s.replaceAll(r'\log', 'ln');

    // 5) FRAZIONI: \frac{a}{b} -> (a)/(b)
    final fracRegex = RegExp(r'\\frac\{([^{}]+)\}\{([^{}]+)\}');
    while (fracRegex.hasMatch(s)) {
      s = s.replaceAllMapped(
        fracRegex,
            (m) => '(${m.group(1)})/(${m.group(2)})',
      );
    }

    // 6) RADICI:
    //    \sqrt[n]{x} -> (x)^(1/n)
    final nthRootRegex = RegExp(r'\\sqrt\[(.+?)\]\{([^{}]+)\}');
    while (nthRootRegex.hasMatch(s)) {
      s = s.replaceAllMapped(
        nthRootRegex,
            (m) => '(${m.group(2)})^(1/(${m.group(1)}))',
      );
    }

    //    \sqrt{x} -> sqrt(x)
    final sqrtRegex = RegExp(r'\\sqrt\{([^{}]+)\}');
    while (sqrtRegex.hasMatch(s)) {
      s = s.replaceAllMapped(
        sqrtRegex,
            (m) => 'sqrt(${m.group(1)})',
      );
    }

    // 7) TRIGONOMETRIA: rimuovo il backslash
    s = s
        .replaceAll(r'\sin', 'sin')
        .replaceAll(r'\cos', 'cos')
        .replaceAll(r'\tan', 'tan')
        .replaceAll(r'\arcsin', 'asin')
        .replaceAll(r'\arccos', 'acos')
        .replaceAll(r'\arctan', 'atan');

    // 8) COSTANTE π
    s = s.replaceAll(r'\pi', 'pi');

    // 9) OPERATORI DI CONFRONTO TeX -> ASCII
    s = s
        .replaceAll(r'\leq', '<=')
        .replaceAll(r'\le', '<=')
        .replaceAll(r'\geq', '>=')
        .replaceAll(r'\ge', '>=')
        .replaceAll(r'\lt', '<')
        .replaceAll(r'\gt', '>');

    // 9-bis) MODULO TEX \% -> %
    // (così, se per qualche motivo arriva \%, lo trattiamo come % numerico)
    s = s.replaceAll(r'\%', '%');

    // 9-ter) VALORE ASSOLUTO: |...| -> abs(...)
    //
    // Dopo aver tolto \left e \right, \left|x+1\right| diventa |x+1|.
    // Gestiamo pattern semplici senza annidamento di barre verticali.
    final absRegex = RegExp(r'\|([^|]+)\|');
    while (absRegex.hasMatch(s)) {
      s = s.replaceAllMapped(
        absRegex,
            (m) => 'abs(${m.group(1)})',
      );
    }

    // 10) OPERATORI di moltiplicazione/divisione dalla tastiera custom
    //     Normalizziamo tutto a * e / (che il parser capisce).
    //     NOTA: lasciamo il simbolo % intatto, lo gestisce il parser
    //           o il fallback modulo.
    s = s
        .replaceAll('×', '*')
        .replaceAll('·', '*')
        .replaceAll(r'\cdot', '*')
        .replaceAll(r'\times', '*')
        .replaceAll('÷', '/')
        .replaceAll(r'\div', '/');

    // 11) eventuali parentesi graffe usate come raggruppamento
    //     (dopo aver gestito sqrt, frac, log ecc.) -> parentesi tonde.
    s = s.replaceAll('{', '(').replaceAll('}', ')');

    return s;
  }
}
