import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import 'package:engkit/features/calc/domain/usecases/valuta_espressione.dart';
import 'package:engkit/util/wolfram_alpha_api.dart';
/// Callback usata per dire alla pagina:
/// "Apri la tastiera per questo blocco" passando controller e callback di valutazione.
typedef ApriTastieraCallback = void Function(
    TextEditingController controller,
    VoidCallback onEvaluate,
    );

/// Widget che rappresenta graficamente un blocco di calcolo (formula + risultato).
class SchedaBloccoCalcolo extends StatefulWidget {
  final String titolo;
  final ApriTastieraCallback onApriTastiera;

  const SchedaBloccoCalcolo({
    super.key,
    required this.titolo,
    required this.onApriTastiera,
  });

  @override
  State<SchedaBloccoCalcolo> createState() => _SchedaBloccoCalcoloState();
}

class _SchedaBloccoCalcoloState extends State<SchedaBloccoCalcolo> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  final _valutaEspressione = ValutaEspressione();

  // Inserisci QUI il tuo AppID di Wolfram|Alpha
  final _wolframApi = WolframAlphaApi('INSERISCI_IL_TUO_APP_ID_WOLFRAM');

  double? _ultimoRisultato;              // risultato locale (math_expressions)
  String? _ultimoRisultatoWolfram;       // risultato testuale da Wolfram
  bool _loadingWolfram = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();

    _controller.addListener(() {
      setState(() {
        // Se il campo diventa vuoto, nascondo i risultati
        if (_controller.text.trim().isEmpty) {
          _ultimoRisultato = null;
          _ultimoRisultatoWolfram = null;
          _loadingWolfram = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Semplice euristica per capire se un'espressione è "avanzata"
  /// e conviene delegarla a Wolfram|Alpha.
  bool _isAdvancedExpression(String tex) {
    const advancedTokens = [
      r'\int',
      r'\sum',
      r'\prod',
      r'\lim',
      r'\frac{d',      // derivate
      r'\begin{bmatrix}',
      r'\det',
      '^T',           // trasposto
    ];
    return advancedTokens.any((t) => tex.contains(t));
  }

  void _valuta() {
    final tex = _controller.text.trim();
    if (tex.isEmpty) return;

    final isAdvanced = _isAdvancedExpression(tex);

    // 1) Provo sempre prima il parser locale
    final local = _valutaEspressione(tex);

    if (!isAdvanced && local != null) {
      // Espressione "semplice": gestita in locale
      setState(() {
        _ultimoRisultato = local;
        _ultimoRisultatoWolfram = null;
        _loadingWolfram = false;
      });
      return;
    }

    // 2) Se è avanzata o locale ha dato null, vado su Wolfram
    _valutaConWolfram(tex);
  }

  Future<void> _valutaConWolfram(String tex) async {
    setState(() {
      _loadingWolfram = true;
      _ultimoRisultato = null;
      _ultimoRisultatoWolfram = null;
    });

    try {
      // Per ora mandiamo direttamente la stringa TeX.
      // In futuro si può fare una conversione in plain English.
      final result = await _wolframApi.compute(tex);

      setState(() {
        _loadingWolfram = false;
        _ultimoRisultatoWolfram = result ?? 'Nessun risultato da Wolfram|Alpha';
      });
    } catch (_) {
      setState(() {
        _loadingWolfram = false;
        _ultimoRisultatoWolfram = 'Errore nella richiesta a Wolfram|Alpha';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceVariant = theme.colorScheme.surfaceVariant;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    // Per la preview TeX: escapare il simbolo % (in TeX è commento)
    final rawTex = _controller.text;
    final texForPreview = rawTex.replaceAll('%', r'\%');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titolo del blocco
            Text(
              widget.titolo,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Campo input della formula (controllato dalla tastiera custom)
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              readOnly: true,        // niente tastiera di sistema
              showCursor: true,      // mostra il cursore
              onTap: () {
                _focusNode.requestFocus();
                widget.onApriTastiera(_controller, _valuta);
              },
              decoration: const InputDecoration(
                labelText: 'Inserisci espressione',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // ---------------- Anteprima TeX renderizzata (ingrandita) ----------------
            if (_controller.text.trim().isNotEmpty)
              GestureDetector(
                onTap: () {
                  // Popup a schermo intero con la formula
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      return Dialog(
                        backgroundColor: Colors.black87,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: InteractiveViewer(
                            minScale: 0.5,
                            maxScale: 3.0,
                            child: Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Math.tex(
                                  texForPreview,
                                  mathStyle: MathStyle.display,
                                  textStyle: const TextStyle(
                                    fontSize: 26,
                                    color: Colors.white,
                                  ),
                                  onErrorFallback: (err) => Text(
                                    'Errore TeX: ${err.message}',
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    minHeight: 80,
                    maxHeight: 160,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: surfaceVariant.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Math.tex(
                        texForPreview,
                        mathStyle: MathStyle.display,
                        textStyle: theme.textTheme.headlineSmall?.copyWith(
                          color: onSurfaceVariant,
                        ),
                        onErrorFallback: (err) => Text(
                          'Errore nella formula: ${err.message}',
                          style: TextStyle(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // ---------------- Risultato locale (ValutaEspressione) ----------------
            if (_ultimoRisultato != null &&
                _controller.text.trim().isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Risultato',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        '$_ultimoRisultato',
                        textAlign: TextAlign.right,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ---------------- Stato "loading" per Wolfram ----------------
            if (_loadingWolfram)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Calcolo con Wolfram|Alpha...',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

            // ---------------- Risultato da Wolfram|Alpha ----------------
            if (_ultimoRisultatoWolfram != null &&
                _controller.text.trim().isNotEmpty)
              GestureDetector(
                onTap: () {
                  // Popup con il risultato Wolfram completo
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      return Dialog(
                        backgroundColor: Colors.black87,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: SingleChildScrollView(
                            child: Text(
                              _ultimoRisultatoWolfram!,
                              style: const TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Risultato (Wolfram|Alpha)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _ultimoRisultatoWolfram!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
