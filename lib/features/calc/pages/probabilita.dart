import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import 'package:engkit/ui/pages/Drawer.dart';
import 'package:engkit/features/calc/widgets/custom_math_keyboard.dart';
import 'package:engkit/features/calc/domain/usecases/valuta_espressione.dart';
import 'package:engkit/util/wolfram_alpha_api.dart';

class CalcoloProbItem {
  final String espressione;
  final String risultato;
  final DateTime timestamp;
  final bool fromWolfram;

  CalcoloProbItem({
    required this.espressione,
    required this.risultato,
    required this.timestamp,
    required this.fromWolfram,
  });
}

enum ProbResultSource { local, wolfram }

class Probabilita extends StatefulWidget {
  final String title;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ThemeMode currentThemeMode;

  const Probabilita({
    super.key,
    required this.title,
    required this.onThemeModeChanged,
    required this.currentThemeMode,
  });

  @override
  State<Probabilita> createState() => _ProbabilitaState();
}

class _ProbabilitaState extends State<Probabilita> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  final _valutaEspressione = ValutaEspressione();
  final _wolframApi = WolframAlphaApi('INSERISCI_IL_TUO_APP_ID_WOLFRAM');

  final List<CalcoloProbItem> _storico = [];
  String? _ultimoErrore;
  String? _ultimoRisultato;
  ProbResultSource? _ultimoSource;
  bool _loadingWolfram = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode()
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _chiudiTastiera() {
    _focusNode.unfocus();
  }

  bool _isAdvancedExpression(String tex) {
    const advancedTokens = [
      r'\int',
      r'\sum',
      r'\prod',
      r'\lim',
      r'\Phi',
      r'\Pr',
      r'\mathrm{P}',
      r'\mathcal{N}',
    ];
    return advancedTokens.any((t) => tex.contains(t));
  }

  String? _validaEspressione(String inputRaw) {
    final input = inputRaw.trim();
    if (input.isEmpty) {
      return 'Inserisci un\'espressione o seleziona un template.';
    }

    int countPar = 0;
    for (final ch in input.split('')) {
      if (ch == '(') countPar++;
      if (ch == ')') countPar--;
      if (countPar < 0) {
        return 'Parentesi chiuse in eccesso.';
      }
    }
    if (countPar > 0) {
      return 'Parentesi aperte non chiuse.';
    }

    return null;
  }

  void _aggiungiStorico(
      String expr,
      String risultato, {
        required bool fromWolfram,
      }) {
    _storico.insert(
      0,
      CalcoloProbItem(
        espressione: expr,
        risultato: risultato,
        timestamp: DateTime.now(),
        fromWolfram: fromWolfram,
      ),
    );
    if (_storico.length > 20) {
      _storico.removeRange(20, _storico.length);
    }
  }

  Future<void> _valuta() async {
    final tex = _controller.text;
    final errore = _validaEspressione(tex);

    if (errore != null) {
      setState(() {
        _ultimoErrore = errore;
        _ultimoRisultato = null;
        _ultimoSource = null;
        _loadingWolfram = false;
      });
      return;
    }

    final trimmed = tex.trim();
    final isAdvanced = _isAdvancedExpression(trimmed);

    setState(() {
      _ultimoErrore = null;
      _ultimoRisultato = null;
      _ultimoSource = null;
    });

    // 1) Provo locale se non è avanzata
    if (!isAdvanced) {
      try {
        final local = _valutaEspressione(trimmed);
        if (local != null) {
          final risultatoString = local.toString();
          setState(() {
            _ultimoRisultato = risultatoString;
            _ultimoSource = ProbResultSource.local;
            _loadingWolfram = false;
            _ultimoErrore = null;
            _aggiungiStorico(trimmed, risultatoString, fromWolfram: false);
          });
          return;
        }
      } catch (_) {}
    }

    // 2) Avanzata o locale fallito: Wolfram|Alpha
    setState(() {
      _loadingWolfram = true;
      _ultimoRisultato = null;
      _ultimoSource = null;
    });

    try {
      final result = await _wolframApi.compute(trimmed);

      if (!mounted) return;

      if (result == null || result.trim().isEmpty) {
        setState(() {
          _loadingWolfram = false;
          _ultimoErrore =
          'Nessun risultato da Wolfram|Alpha.\n'
              'Prova a specificare meglio l\'evento o la distribuzione.';
          _ultimoRisultato = null;
          _ultimoSource = null;
        });
        return;
      }

      setState(() {
        _loadingWolfram = false;
        _ultimoErrore = null;
        _ultimoRisultato = result;
        _ultimoSource = ProbResultSource.wolfram;
        _aggiungiStorico(trimmed, result, fromWolfram: true);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingWolfram = false;
        _ultimoErrore =
        'Errore nella richiesta a Wolfram|Alpha.\n'
            'Controlla la connessione o riprova più tardi.';
        _ultimoRisultato = null;
        _ultimoSource = null;
      });
    }
  }

  void _setTemplate(String texTemplate) {
    setState(() {
      _controller.text = texTemplate;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
      _ultimoErrore = null;
    });
  }

  Future<void> _copiaRisultato() async {
    final text = _ultimoRisultato;
    if (text == null) return;

    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Risultato copiato negli appunti')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tastieraVisibile = _focusNode.hasFocus;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      drawer: MyDrawer(
        onThemeModeChanged: widget.onThemeModeChanged,
        currentThemeMode: widget.currentThemeMode,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // HEADER "statistico"
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.secondaryContainer,
                      theme.colorScheme.surface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_graph,
                      size: 40,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Probabilità & Statistica',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lavora con distribuzioni, eventi e probabilità,\n'
                                'con template guidati e supporto Wolfram|Alpha.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer
                                  .withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // TEMPLATE DISTRIBUZIONI
              Text(
                'Template distribuzioni',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Discrete',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ActionChip(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    avatar: const Icon(Icons.blur_circular, size: 18),
                    label: const Text('Bernoulli'),
                    onPressed: () =>
                        _setTemplate(r'X \sim \mathrm{Bernoulli}(p)'),
                  ),
                  ActionChip(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    avatar: const Icon(Icons.view_module, size: 18),
                    label: const Text('Binomiale'),
                    onPressed: () =>
                        _setTemplate(r'X \sim \mathrm{Binomiale}(n, p)'),
                  ),
                  ActionChip(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    avatar: const Icon(Icons.brightness_auto, size: 18),
                    label: const Text('Poisson'),
                    onPressed: () =>
                        _setTemplate(r'X \sim \mathrm{Poisson}(\lambda)'),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                'Continue',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ActionChip(
                    backgroundColor: theme.colorScheme.tertiaryContainer,
                    avatar: const Icon(Icons.timeline, size: 18),
                    label: const Text('Normale'),
                    onPressed: () =>
                        _setTemplate(r'X \sim \mathcal{N}(\mu, \sigma^2)'),
                  ),
                  ActionChip(
                    backgroundColor: theme.colorScheme.tertiaryContainer,
                    avatar: const Icon(Icons.timeline, size: 18),
                    label: const Text('Uniforme'),
                    onPressed: () =>
                        _setTemplate(r'X \sim \mathrm{Uniform}(a, b)'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Preview TeX
              if (_controller.text.trim().isNotEmpty)
                Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Math.tex(
                      _controller.text.trim(),
                      mathStyle: MathStyle.display,
                      textStyle: theme.textTheme.titleMedium,
                      onErrorFallback: (e) => Text(
                        'Errore nella formula: ${e.message}',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ),
                ),

              // TextField adattivo
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 56,
                  maxHeight: 140,
                ),
                child: Scrollbar(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    readOnly: true,
                    showCursor: true,
                    maxLines: null,
                    minLines: 1,
                    onTap: () {
                      _focusNode.requestFocus();
                    },
                    decoration: InputDecoration(
                      labelText:
                      'Espressione di probabilità/statistica (TeX Engkit)',
                      border: const OutlineInputBorder(),
                      errorText: _ultimoErrore,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              if (_loadingWolfram)
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Richiesta a Wolfram|Alpha in corso...',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),

              const SizedBox(height: 8),

              // Pannello risultato estetico
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _ultimoRisultato != null && !_loadingWolfram
                    ? Container(
                  key: const ValueKey('probResultPanel'),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border(
                      left: BorderSide(
                        color: _ultimoSource == ProbResultSource.local
                            ? theme.colorScheme.primary
                            : theme.colorScheme.tertiary,
                        width: 4,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        _ultimoSource == ProbResultSource.local
                            ? Icons.calculate
                            : Icons.cloud_outlined,
                        color: _ultimoSource == ProbResultSource.local
                            ? theme.colorScheme.primary
                            : theme.colorScheme.tertiary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            _ultimoRisultato ?? '',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_ultimoSource != null)
                        Chip(
                          label: Text(
                            _ultimoSource == ProbResultSource.local
                                ? 'Locale'
                                : 'Wolfram|Alpha',
                          ),
                        ),
                      IconButton(
                        onPressed: _copiaRisultato,
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copia risultato',
                      ),
                    ],
                  ),
                )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 16),

              if (_storico.isNotEmpty)
                Text(
                  'Storico',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

              if (_storico.isNotEmpty) const SizedBox(height: 8),

              if (_storico.isNotEmpty)
                ..._storico.map(
                      (item) => Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: Icon(
                        item.fromWolfram
                            ? Icons.cloud_outlined
                            : Icons.casino_outlined,
                        color: item.fromWolfram
                            ? theme.colorScheme.tertiary
                            : theme.colorScheme.primary,
                      ),
                      title: Text(
                        item.espressione,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text('= ${item.risultato}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${item.timestamp.hour.toString().padLeft(2, '0')}:'
                                '${item.timestamp.minute.toString().padLeft(2, '0')}',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Icon(
                            Icons.chevron_left,
                            size: 18,
                            color:
                            theme.textTheme.bodySmall?.color?.withOpacity(
                              0.6,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          _controller.text = item.espressione;
                          _controller.selection = TextSelection.collapsed(
                            offset: _controller.text.length,
                          );
                        });
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 120),
            ],
          ),

          // Tastiera animata
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              offset: tastieraVisibile ? Offset.zero : const Offset(0, 1),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: tastieraVisibile ? 1 : 0,
                child: IgnorePointer(
                  ignoring: !tastieraVisibile,
                  child: CustomMathKeyboard(
                    controller: _controller,
                    onClose: _chiudiTastiera,
                    onEvaluate: _valuta,
                    profile: MathKeyboardProfile.probabilita,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
