import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


enum MathKeyboardProfile {
  blocchi,      // pagina blocchi di calcolo / generico
  algebra,      // pagina algebra
  probabilita,  // pagina probabilità / statistica
  grafico,      // pagina grafico
}

/// Icona per il tasto divisione, stile "a sopra b" con una riga in mezzo.
class FractionIcon extends StatelessWidget {
  const FractionIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '□',
            style: TextStyle(
              fontSize: 12,
              height: 1.0,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 1),
            width: 14,
            height: 1,
            color: Colors.white,
          ),
          const Text(
            '□',
            style: TextStyle(
              fontSize: 12,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tastiera matematica personalizzata per Engkit.
///
/// - Sfondo nero
/// - 3 modalità: [basic] (numeri/operatori),
///               [functions] (funzioni),
///               [advanced] (integrali, matrici, derivate, limiti, somme, prodotti)
/// - Pop-up per log, potenze, radici, trigonometria, integrali, matrici,
///   derivate, limiti, sommatorie, prodotti.
/// - Wrapping automatico della selezione con strutture TeX.
class CustomMathKeyboard extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onClose;
  final VoidCallback? onEvaluate;

  /// Profilo della tastiera: decide quali tasti abilitare / disabilitare.
  final MathKeyboardProfile profile;

  const CustomMathKeyboard({
    super.key,
    required this.controller,
    required this.onClose,
    this.onEvaluate,
    this.profile = MathKeyboardProfile.blocchi, // default: come prima
  });

  @override
  State<CustomMathKeyboard> createState() => _CustomMathKeyboardState();
}


enum _KeyboardMode { basic, functions, advanced }

enum _KeyType { number, operator, function, control }

enum _LogType { base10, ln, custom }

enum _RootType { sqrt, cbrt, custom }

enum _PowType { square, cube, custom }

enum _TrigType { sin, cos, tan, asin, acos, atan }

enum _MatrixType { twoByTwo, threeByThree, custom }

class _CustomMathKeyboardState extends State<CustomMathKeyboard> {
  _KeyboardMode _mode = _KeyboardMode.basic;
  //getter per variazioni di colori in base al tema
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  /// Restituisce true se il tasto con questa [label] è abilitato
  /// nel profilo corrente della tastiera.
  bool _isKeyEnabled(String label) {
    switch (widget.profile) {
      case MathKeyboardProfile.blocchi:
        const disabled = <String>{
          'M',
          '[□]',
          'det',
          'Aᵀ',
        };
        return !disabled.contains(label);

      case MathKeyboardProfile.algebra:
      //Tasti disabilitati nel profilo algebra
        const disabled = <String>{
          '∫',
          '∫ₐᵇ',
          'Σ',
          'Π',
          'lim',
          'd/dx',
          '|□|',
          '∞',
        };
        return !disabled.contains(label);

      case MathKeyboardProfile.probabilita:
      // In probabilità magari non servono derivate e matrici
        const disabled = <String>{
          'd/dx',
          'M',
          'Aᵀ',
          'det',
        };
        return !disabled.contains(label);

      case MathKeyboardProfile.grafico:
      // Nel grafico ti interessano funzioni e operatori base
        const disabled = <String>{
          '∫',
          '∫ₐᵇ',
          'Σ',
          'Π',
          'lim',
          'd/dx',
          'M',
          'det',
          'Aᵀ',
        };
        return !disabled.contains(label);
    }
  }


  Future<void> _showVariableDialog() async {
    final scelta = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          backgroundColor: const Color(0xFF202020),
          title: const Text(
            'Scegli variabile',
            style: TextStyle(color: Colors.white),
          ),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop('x'),
              child: const Text('x', style: TextStyle(color: Colors.white)),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop('y'),
              child: const Text('y', style: TextStyle(color: Colors.white)),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop('z'),
              child: const Text('z', style: TextStyle(color: Colors.white)),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop('t'),
              child: const Text('t', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (scelta != null) {
      _insertText(scelta);
    }
  }


  // ------------------- utility inserimento / wrapping testo -------------------

  /// Inserisce [text] nel punto di inserimento corrente (o sostituisce la selezione).
  /// [cursorOffsetFromEnd] sposta il cursore rispetto alla fine del testo inserito.
  void _insertText(String text, {int cursorOffsetFromEnd = 0}) {
    final value = widget.controller.value;
    final oldText = value.text;
    final selection = value.selection;

    final start = selection.start >= 0 ? selection.start : oldText.length;
    final end = selection.end >= 0 ? selection.end : oldText.length;

    final newText = oldText.replaceRange(start, end, text);

    var newOffset = start + text.length + cursorOffsetFromEnd;
    if (newOffset < 0) newOffset = 0;
    if (newOffset > newText.length) newOffset = newText.length;

    widget.controller.value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
      composing: TextRange.empty,
    );
  }

  /// Se c'è una selezione, la avvolge con [prefix] + selezione + [suffix].
  /// Altrimenti inserisce [prefix][suffix] con il cursore in mezzo.
  void _wrapSelection(String prefix, String suffix) {
    final value = widget.controller.value;
    final text = value.text;
    final sel = value.selection;

    int start = sel.start;
    int end = sel.end;

    if (start < 0 || end < 0) {
      start = end = text.length;
    }

    final hasSelection = start != end;
    final selectedText = hasSelection ? text.substring(start, end) : '';

    final insert = '$prefix$selectedText$suffix';

    final newText = text.replaceRange(start, end, insert);

    final cursorOffset =
    hasSelection ? start + insert.length : start + prefix.length;

    widget.controller.value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorOffset),
      composing: TextRange.empty,
    );
  }

  void _backspace() {
    final value = widget.controller.value;
    final text = value.text;
    final selection = value.selection;

    if (text.isEmpty) return;

    // Cancella selezione se presente.
    if (selection.start != selection.end &&
        selection.start >= 0 &&
        selection.end >= 0) {
      final newText =
      text.replaceRange(selection.start, selection.end, '');
      widget.controller.value = value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start),
      );
      return;
    }

    final index = selection.start >= 0 ? selection.start : text.length;
    if (index == 0) return;

    final newText = text.replaceRange(index - 1, index, '');
    widget.controller.value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: index - 1),
    );
  }

  void _moveCaret(int delta) {
    final value = widget.controller.value;
    final text = value.text;
    var index = value.selection.start;
    if (index < 0) index = text.length;

    var newIndex = index + delta;
    if (newIndex < 0) newIndex = 0;
    if (newIndex > text.length) newIndex = text.length;

    widget.controller.selection = TextSelection.collapsed(offset: newIndex);
  }

  // ----------------------------- stile tasti ----------------------------------

  Color _bgFor(_KeyType type) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = _isDark;

    if (isDark) {
      // PALETTE SCURA: tieni quelli che usi ora
      switch (type) {
        case _KeyType.number:
          return const Color(0xFF111111);
        case _KeyType.operator:
          return const Color(0xFF242424);
        case _KeyType.function:
          return const Color(0xFF1C1C1C);
        case _KeyType.control:
          return const Color(0xFF333333);
      }
    } else {
      // PALETTE CHIARA: sfruttiamo il colorScheme
      switch (type) {
        case _KeyType.number:
          return scheme.surfaceVariant;        // tasti numerici chiari
        case _KeyType.operator:
          return scheme.primaryContainer;      // operatori leggermente evidenziati
        case _KeyType.function:
          return scheme.secondaryContainer;    // funzioni
        case _KeyType.control:
          return scheme.tertiaryContainer;     // tasti speciali (=, frecce, tab)
      }
    }
  }

  Widget _key(
      String label, {
        String? insert,
        _KeyType type = _KeyType.number,
        int flex = 1,
        int cursorFromEnd = 0,
        VoidCallback? onTap,
        VoidCallback? onLongPress,
        Widget? child,
      }) {
    final theme = Theme.of(context);
    final isDark = _isDark;

    // decide se il tasto è abilitato o no in base al profilo
    final enabled = _isKeyEnabled(label);

    final baseBg = _bgFor(type);
    final bgColor = enabled
        ? baseBg
        : baseBg.withOpacity(isDark ? 0.4 : 0.3);

    final fgColor = enabled
        ? (isDark ? Colors.white : theme.colorScheme.onPrimaryContainer)
        : (isDark ? Colors.white38 : theme.disabledColor);

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: FilledButton(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: bgColor,
            foregroundColor: fgColor,
          ),
          onLongPress: !enabled ? null : onLongPress,
          onPressed: !enabled
              ? null
              : () {
            // HAPTIC FEEDBACK: solo per alcuni tasti "forti"
            if (type == _KeyType.control || label == '=' || label == '⌫') {
              HapticFeedback.mediumImpact();
            } else {
              HapticFeedback.selectionClick();
            }

            if (onTap != null) {
              onTap();
            } else if (insert != null) {
              _insertText(insert, cursorOffsetFromEnd: cursorFromEnd);
            }
          },
          child: child ?? Text(label),
        ),
      ),
    );
  }



  // ------------------------- POP-UP: LOGARITMI -------------------------------

  Future<void> _showLogDialog() async {
    final type = await showDialog<_LogType>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          backgroundColor: const Color(0xFF202020),
          title: const Text(
            'Tipo di logaritmo',
            style: TextStyle(color: Colors.white),
          ),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(_LogType.base10),
              child: const Text(
                'log₁₀(□)',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(_LogType.ln),
              child: const Text(
                'ln(□)',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(_LogType.custom),
              child: const Text(
                'logᵦ(□) – base scelta',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (type == null) return;

    if (type == _LogType.base10) {
      _wrapSelection(r'\log_{10}(', ')');
    } else if (type == _LogType.ln) {
      _wrapSelection(r'\ln(', ')');
    } else if (type == _LogType.custom) {
      final baseController = TextEditingController();

      final base = await showDialog<String>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: const Color(0xFF202020),
            title: const Text(
              'Base del logaritmo',
              style: TextStyle(color: Colors.white),
            ),
            content: TextField(
              controller: baseController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Es. 2, 3, 10...',
                hintStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(ctx).pop(baseController.text.trim()),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      if (base != null && base.isNotEmpty) {
        final prefix = '\\log_{${base}}(';
        _wrapSelection(prefix, ')');
      }
    }
  }

  //---------------------------- POP-UP: MAGGIORE/MINORE ------------------------------
  Future<void> _showCompareDialog() async {
    final op = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          backgroundColor: const Color(0xFF202020),
          title: const Text(
            'Operatore di confronto',
            style: TextStyle(color: Colors.white),
          ),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(r'\gt'),
              child: const Text(
                '>',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(r'\lt'),
              child: const Text(
                '<',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(r'\le'),
              child: const Text(
                '≤',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(r'\ge'),
              child: const Text(
                '≥',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (op == null) return;
    _insertText(op);
  }


  // --------------------------- POP-UP: RADICI ---------------------------------

  Future<void> _showRootDialog() async {
    final type = await showDialog<_RootType>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          backgroundColor: const Color(0xFF202020),
          title: const Text(
            'Radice',
            style: TextStyle(color: Colors.white),
          ),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(_RootType.sqrt),
              child: const Text(
                '√x (radice quadrata)',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(_RootType.cbrt),
              child: const Text(
                '³√x (radice cubica)',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(_RootType.custom),
              child: const Text(
                'ⁿ√x – indice scelto',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (type == null) return;

    if (type == _RootType.sqrt) {
      _wrapSelection(r'\sqrt{', '}');
    } else if (type == _RootType.cbrt) {
      _wrapSelection(r'\sqrt[3]{', '}');
    } else if (type == _RootType.custom) {
      final indexController = TextEditingController();

      final index = await showDialog<String>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: const Color(0xFF202020),
            title: const Text(
              'Indice della radice',
              style: TextStyle(color: Colors.white),
            ),
            content: TextField(
              controller: indexController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Es. 2, 3, 4...',
                hintStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(ctx).pop(indexController.text.trim()),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      if (index != null && index.isNotEmpty) {
        final prefix = '\\sqrt[${index}]{';
        _wrapSelection(prefix, '}');
      }
    }
  }

  // --------------------------- POP-UP: POTENZE --------------------------------

  Future<void> _showPowDialog() async {
    final type = await showDialog<_PowType>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          backgroundColor: const Color(0xFF202020),
          title: const Text(
            'Potenza',
            style: TextStyle(color: Colors.white),
          ),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(_PowType.square),
              child: const Text(
                'x²',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(_PowType.cube),
              child: const Text(
                'x³',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(_PowType.custom),
              child: const Text(
                'xⁿ – esponente scelto',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (type == null) return;

    if (type == _PowType.square) {
      _insertText('^2');
    } else if (type == _PowType.cube) {
      _insertText('^3');
    } else if (type == _PowType.custom) {
      final expController = TextEditingController();

      final exp = await showDialog<String>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: const Color(0xFF202020),
            title: const Text(
              'Esponente',
              style: TextStyle(color: Colors.white),
            ),
            content: TextField(
              controller: expController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Es. 2, 3, 4...',
                hintStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(ctx).pop(expController.text.trim()),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      if (exp != null && exp.isNotEmpty) {
        _insertText('^$exp');
      }
    }
  }

  // ------------------------ POP-UP: TRIGONOMETRIA -----------------------------

  Future<void> _showTrigDialog() async {
    final type = await showDialog<_TrigType>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          backgroundColor: const Color(0xFF202020),
          title: const Text(
            'Funzioni trigonometriche',
            style: TextStyle(color: Colors.white),
          ),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(_TrigType.sin),
              child: const Text('sin(x)', style: TextStyle(color: Colors.white)),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(_TrigType.cos),
              child: const Text('cos(x)', style: TextStyle(color: Colors.white)),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(_TrigType.tan),
              child: const Text('tan(x)', style: TextStyle(color: Colors.white)),
            ),
            const Divider(color: Colors.white24),
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(_TrigType.asin),
              child: const Text('sin⁻¹(x)',
                  style: TextStyle(color: Colors.white)),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(_TrigType.acos),
              child: const Text('cos⁻¹(x)',
                  style: TextStyle(color: Colors.white)),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(_TrigType.atan),
              child: const Text('tan⁻¹(x)',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (type == null) return;

    switch (type) {
      case _TrigType.sin:
        _wrapSelection(r'\sin(', ')');
        break;
      case _TrigType.cos:
        _wrapSelection(r'\cos(', ')');
        break;
      case _TrigType.tan:
        _wrapSelection(r'\tan(', ')');
        break;
      case _TrigType.asin:
        _wrapSelection(r'\arcsin(', ')');
        break;
      case _TrigType.acos:
        _wrapSelection(r'\arccos(', ')');
        break;
      case _TrigType.atan:
        _wrapSelection(r'\arctan(', ')');
        break;
    }
  }

  // -------------------------- POP-UP: INTEGRALI -------------------------------

  Future<void> _showIntegralDialog({required bool definite}) async {
    if (!definite) {
      // integrale indefinito: chiedo solo la variabile (default x)
      final varController = TextEditingController(text: 'x');

      final variable = await showDialog<String>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: const Color(0xFF202020),
            title: const Text(
              'Variabile di integrazione',
              style: TextStyle(color: Colors.white),
            ),
            content: TextField(
              controller: varController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Es. x',
                hintStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(ctx).pop(varController.text.trim()),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      if (variable == null) return;

      final v = variable.isEmpty ? 'x' : variable;
      final prefix = '\\int ';
      final suffix = '\\,d$v'.replaceFirst('\$v', v);
      _wrapSelection(prefix, suffix);
    } else {
      // integrale definito: chiedo limiti e variabile
      final lowerController = TextEditingController();
      final upperController = TextEditingController();
      final varController = TextEditingController(text: 'x');

      final values = await showDialog<List<String>>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: const Color(0xFF202020),
            title: const Text(
              'Integrale definito',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: lowerController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Limite inferiore',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white38),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                TextField(
                  controller: upperController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Limite superiore',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white38),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                TextField(
                  controller: varController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Variabile',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white38),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop([
                  lowerController.text.trim(),
                  upperController.text.trim(),
                  varController.text.trim(),
                ]),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      if (values == null) return;

      var lower = values[0].isEmpty ? 'a' : values[0];
      var upper = values[1].isEmpty ? 'b' : values[1];
      var variable = values[2].isEmpty ? 'x' : values[2];

      final prefix = '\\int_{${lower}}^{${upper}} ';
      final suffix = '\\,d$variable';
      _wrapSelection(prefix, suffix);
    }
  }

  // ----------------------------- MATRICI --------------------------------------

  void _insertMatrixSkeleton(int rows, int cols) {
    final buffer = StringBuffer();
    buffer.write(r'\begin{bmatrix}');
    for (var i = 0; i < rows; i++) {
      for (var j = 0; j < cols; j++) {
        buffer.write('0');
        if (j < cols - 1) buffer.write(' & ');
      }
      if (i < rows - 1) buffer.write(r' \\ ');
    }
    buffer.write(r'\end{bmatrix}');
    _insertText(buffer.toString());
  }

  Future<void> _showMatrixDialog() async {
    // primo dialog: scegli tipo di matrice
    final type = await showDialog<_MatrixType>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          backgroundColor: const Color(0xFF202020),
          title: const Text(
            'Matrice',
            style: TextStyle(color: Colors.white),
          ),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(_MatrixType.twoByTwo),
              child: const Text(
                '2 × 2',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(_MatrixType.threeByThree),
              child: const Text(
                '3 × 3',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(_MatrixType.custom),
              child: const Text(
                'Righe / colonne personalizzate',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (type == null) return;

    if (type == _MatrixType.twoByTwo) {
      _insertMatrixSkeleton(2, 2);
    } else if (type == _MatrixType.threeByThree) {
      _insertMatrixSkeleton(3, 3);
    } else {
      // dialog per righe/colonne personalizzate
      final rowsController = TextEditingController(text: '2');
      final colsController = TextEditingController(text: '2');

      final result = await showDialog<List<int>>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: const Color(0xFF202020),
            title: const Text(
              'Dimensione matrice',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: rowsController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Righe',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white38),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                TextField(
                  controller: colsController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Colonne',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white38),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () {
                  var r = int.tryParse(rowsController.text.trim()) ?? 2;
                  var c = int.tryParse(colsController.text.trim()) ?? 2;
                  if (r < 1) r = 1;
                  if (r > 10) r = 10;
                  if (c < 1) c = 1;
                  if (c > 10) c = 10;
                  Navigator.of(ctx).pop([r, c]);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      if (result != null && result.length == 2) {
        _insertMatrixSkeleton(result[0], result[1]);
      }
    }
  }

  // ----------------------- POP-UP: DERIVATE -----------------------------------

  Future<void> _showDerivativeDialog() async {
    final varController = TextEditingController(text: 'x');
    final orderController = TextEditingController(text: '1');

    final result = await showDialog<List<String>>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF202020),
          title: const Text(
            'Derivata',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: varController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Variabile',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              TextField(
                controller: orderController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Ordine (1, 2, ...)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx)
                  .pop([varController.text.trim(), orderController.text.trim()]),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (result == null || result.length != 2) return;

    final variable = (result[0].isEmpty ? 'x' : result[0]);
    final order = int.tryParse(result[1]) ?? 1;

    String prefix;
    if (order <= 1) {
      prefix = '\\frac{d}{d$variable}(';
    } else if (order == 2) {
      prefix = '\\frac{d^2}{d$variable^2}(';
    } else {
      prefix = '\\frac{d^$order}{d$variable^$order}(';
    }

    _wrapSelection(prefix, ')');
  }

  // ----------------------- POP-UP: LIMITE -------------------------------------

  Future<void> _showLimitDialog() async {
    final varController = TextEditingController(text: 'x');
    final targetController = TextEditingController(text: '0');

    final result = await showDialog<List<String>>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF202020),
          title: const Text(
            'Limite',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: varController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Variabile',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              TextField(
                controller: targetController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Tende a (es. 0, +inf, -inf)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop([
                varController.text.trim(),
                targetController.text.trim(),
              ]),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (result == null || result.length != 2) return;

    final variable = (result[0].isEmpty ? 'x' : result[0]);
    var target = result[1];

    final t = target.toLowerCase();
    if (t == 'inf' || t == '+inf' || t == 'infty' || t == '+infty') {
      target = r'\infty';
    } else if (t == '-inf' || t == '-infty') {
      target = r'-\infty';
    } else if (t.isEmpty) {
      target = '0';
    }

    final prefix = '\\lim_{${variable}\\to $target} ';
    _wrapSelection(prefix, '');
  }

  // ----------------------- POP-UP: SOMMATORIA ---------------------------------

  Future<void> _showSumDialog() async {
    final indexController = TextEditingController(text: 'i');
    final lowerController = TextEditingController(text: '1');
    final upperController = TextEditingController(text: 'n');

    final values = await showDialog<List<String>>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF202020),
          title: const Text(
            'Sommatoria',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: indexController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Indice (es. i)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              TextField(
                controller: lowerController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Limite inferiore',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              TextField(
                controller: upperController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Limite superiore',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop([
                indexController.text.trim(),
                lowerController.text.trim(),
                upperController.text.trim(),
              ]),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (values == null || values.length != 3) return;

    final index = values[0].isEmpty ? 'i' : values[0];
    final lower = values[1].isEmpty ? '1' : values[1];
    final upper = values[2].isEmpty ? 'n' : values[2];

    final prefix = '\\sum_{${index}=${lower}}^{${upper}} ';
    _wrapSelection(prefix, '');
  }

  // ----------------------- POP-UP: PRODUTTORIA --------------------------------

  Future<void> _showProdDialog() async {
    final indexController = TextEditingController(text: 'i');
    final lowerController = TextEditingController(text: '1');
    final upperController = TextEditingController(text: 'n');

    final values = await showDialog<List<String>>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF202020),
          title: const Text(
            'Produttoria',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: indexController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Indice (es. i)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              TextField(
                controller: lowerController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Limite inferiore',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              TextField(
                controller: upperController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Limite superiore',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop([
                indexController.text.trim(),
                lowerController.text.trim(),
                upperController.text.trim(),
              ]),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (values == null || values.length != 3) return;

    final index = values[0].isEmpty ? 'i' : values[0];
    final lower = values[1].isEmpty ? '1' : values[1];
    final upper = values[2].isEmpty ? 'n' : values[2];

    final prefix = '\\prod_{${index}=${lower}}^{${upper}} ';
    _wrapSelection(prefix, '');
  }

  // --------------------------- layout: BASIC ----------------------------------

  Widget _buildBasicLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 7 8 9 ÷
        Row(
          children: [
            _key(
              '(□)',
              type: _KeyType.operator,
              onTap: () => _wrapSelection('(', ')'),
            ),
            _key('7', insert: '7', type: _KeyType.number),
            _key('8', insert: '8', type: _KeyType.number),
            _key('9', insert: '9', type: _KeyType.number),
            _key(
              '',
              insert: r'\frac{}{}',
              type: _KeyType.operator,
              child: const FractionIcon(),
            ),
          ],
        ),
        // 4 5 6 ×
        Row(
          children: [
            _key (
              '>',
              type: _KeyType.operator,
              onTap: _showCompareDialog,
            ),
            _key('4', insert: '4', type: _KeyType.number),
            _key('5', insert: '5', type: _KeyType.number),
            _key('6', insert: '6', type: _KeyType.number),
            _key('×', insert: r'\times', type: _KeyType.operator),
          ],
        ),
        // 1 2 3 −
        Row(
          children: [
            _key('%', insert: '%', type: _KeyType.operator),
            _key('1', insert: '1', type: _KeyType.number),
            _key('2', insert: '2', type: _KeyType.number),
            _key('3', insert: '3', type: _KeyType.number),
            _key('−', insert: '-', type: _KeyType.operator),
          ],
        ),
        // 0 , ^ +
        Row(
          children: [
            _key(
              'ƒx',
              type: _KeyType.control,
              onTap: () {
                setState(() => _mode = _KeyboardMode.functions);
              },
            ),
            _key('0', insert: '0', type: _KeyType.number),
            _key(',', insert: '.', type: _KeyType.number),
            _key('^', insert: '^', type: _KeyType.operator),
            _key('+', insert: '+', type: _KeyType.operator),
          ],
        ),
        // controlli in basso: ƒx, ∫Σ, (), frecce, backspace, =
        Row(
          children: [
            _key(
              '∫Σ',
              type: _KeyType.control,
              onTap: () {
                setState(() => _mode = _KeyboardMode.advanced);
              },
            ),
            _key(
              '◀',
              type: _KeyType.control,
              onTap: () => _moveCaret(-1),
            ),
            _key(
              '▶',
              type: _KeyType.control,
              onTap: () => _moveCaret(1),
            ),
            _key('⌫', type: _KeyType.control, onTap: _backspace),
            _key(
              '=',
              flex: 2,
              type: _KeyType.control,
              onTap: widget.onEvaluate,
            ),
          ],
        ),
      ],
    );
  }

  // ------------------------- layout: FUNZIONI ---------------------------------

  Widget _buildFunctionsLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // potenze, radici, trig, pi
        Row(
          children: [
            _key('xⁿ', type: _KeyType.function, onTap: _showPowDialog),
            _key('√', type: _KeyType.function, onTap: _showRootDialog),
            _key('trig', type: _KeyType.function, onTap: _showTrigDialog),
            _key('π', insert: r'\pi', type: _KeyType.function),
          ],
        ),
        // log, e, x, y
        Row(
          children: [
            _key('log', type: _KeyType.function, onTap: _showLogDialog),
            _key('e', insert: 'e', type: _KeyType.function),
            _key('x', insert: 'x', type: _KeyType.function,  onLongPress: _showVariableDialog,),
            _key('y', insert: 'y', type: _KeyType.function,  onLongPress: _showVariableDialog,),
          ],
        ),
        // riga per emergenze Tex
        Row(
          children: [
            _key(
              '{□}',
              type: _KeyType.operator,
              onTap: () => _wrapSelection('{', '}'),
            ),
            _key('&', insert: '&', type: _KeyType.operator),
            _key(r'\', insert: r'\', type: _KeyType.operator),
          ],
        ),
        // riga di controllo in basso: 123, ∫Σ, (), frecce, backspace
        Row(
          children: [
            _key(
              '123',
              type: _KeyType.control,
              onTap: () {
                setState(() => _mode = _KeyboardMode.basic);
              },
            ),
            _key(
              '∫Σ',
              type: _KeyType.control,
              onTap: () {
                setState(() => _mode = _KeyboardMode.advanced);
              },
            ),
            _key(
              '(□)',
              type: _KeyType.operator,
              onTap: () => _wrapSelection('(', ')'),
            ),
            _key(
              '◀',
              type: _KeyType.control,
              onTap: () => _moveCaret(-1),
            ),
            _key(
              '▶',
              type: _KeyType.control,
              onTap: () => _moveCaret(1),
            ),
            _key('⌫', type: _KeyType.control, onTap: _backspace),
          ],
        ),
      ],
    );
  }

  // -------------------------- layout: AVANZATO --------------------------------

  Widget _buildAdvancedLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // integrali, sommatoria, produttoria
        Row(
          children: [
            _key(
              '∫',
              type: _KeyType.function,
              onTap: () => _showIntegralDialog(definite: false),
            ),
            _key(
              '∫ₐᵇ',
              type: _KeyType.function,
              onTap: () => _showIntegralDialog(definite: true),
            ),
            _key(
              'Σ',
              type: _KeyType.function,
              onTap: _showSumDialog,
            ),
            _key(
              'Π',
              type: _KeyType.function,
              onTap: _showProdDialog,
            ),
          ],
        ),
        // limite, derivata, |x|, det
        Row(
          children: [
            _key(
              'lim',
              type: _KeyType.function,
              onTap: _showLimitDialog,
            ),
            _key(
              'd/dx',
              type: _KeyType.function,
              onTap: _showDerivativeDialog,
            ),
            _key(
              '|□|',
              type: _KeyType.function,
              onTap: () => _wrapSelection(r'\left|', r'\right|'),
            ),
            _key('det', insert: r'\det', type: _KeyType.function),
          ],
        ),
        // matrici, parentesi quadre, trasposto, (eventuale ∞)
        Row(
          children: [
            _key(
              'M',
              type: _KeyType.function,
              onTap: _showMatrixDialog,
            ),
            _key(
              '[□]',
              type: _KeyType.function,
              onTap: () => _wrapSelection(r'\left[', r'\right]'),
            ),
            _key(
              'Aᵀ',
              type: _KeyType.function,
              onTap: () => _insertText('^T'),
            ),
            _key(
              '∞',
              type: _KeyType.function,
              onTap: () => _insertText(r'\infty'),
            ),
          ],
        ),
        //riga tool per emergenze Tex
        Row(
          children: [
            _key(
              '{□}',
              type: _KeyType.operator,
              onTap: () => _wrapSelection('{', '}'),
            ),
            _key('&', insert: '&', type: _KeyType.operator),
            _key(r'\', insert: r'\', type: _KeyType.operator),
          ],
        ),

        // riga di controllo: 123, ƒx, (), frecce, backspace
        Row(
          children: [
            _key(
              '123',
              type: _KeyType.control,
              onTap: () {
                setState(() => _mode = _KeyboardMode.basic);
              },
            ),
            _key(
              'ƒx',
              type: _KeyType.control,
              onTap: () {
                setState(() => _mode = _KeyboardMode.functions);
              },
            ),
            _key(
              '(□)',
              type: _KeyType.operator,
              onTap: () => _wrapSelection('(', ')'),
            ),
            _key(
              '◀',
              type: _KeyType.control,
              onTap: () => _moveCaret(-1),
            ),
            _key(
              '▶',
              type: _KeyType.control,
              onTap: () => _moveCaret(1),
            ),
            _key('⌫', type: _KeyType.control, onTap: _backspace),
          ],
        ),
      ],
    );
  }

  // -------------------------------- build ------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = _isDark;
    final bgColor = isDark ? Colors.black : theme.colorScheme.surface;
    final labelColor =
    isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant;

    return Material(
      elevation: 12,
      color: bgColor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // barra superiore
              Row(
                children: [
                  const SizedBox(width: 8),
                  Text(
                    'Tastiera di calcolo',
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.keyboard_hide_rounded,
                      color: labelColor,
                    ),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
              const SizedBox(height: 4),

              if (_mode == _KeyboardMode.basic)
                _buildBasicLayout()
              else if (_mode == _KeyboardMode.functions)
                _buildFunctionsLayout()
              else
                _buildAdvancedLayout(),
            ],
          ),
        ),
      ),
    );
  }
}
