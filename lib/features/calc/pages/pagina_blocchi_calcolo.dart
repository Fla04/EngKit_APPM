import 'package:flutter/material.dart';

import 'package:engkit/features/calc/widgets/scheda_blocco_calcolo.dart';
import 'package:engkit/features/calc/widgets/custom_math_keyboard.dart';
import 'package:engkit/ui/pages/Drawer.dart';

class PaginaBlocchiCalcolo extends StatefulWidget {
  final String title;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ThemeMode currentThemeMode;

  const PaginaBlocchiCalcolo({
    super.key,
    required this.title,
    required this.onThemeModeChanged,
    required this.currentThemeMode,
  });

  @override
  State<PaginaBlocchiCalcolo> createState() => _PaginaBlocchiCalcoloState();
}

class _PaginaBlocchiCalcoloState extends State<PaginaBlocchiCalcolo> {
  TextEditingController? _controllerAttivo;
  VoidCallback? _valutaAttivo;

  /// Semplice lista di titoli per i blocchi.
  /// In un secondo momento puoi sostituirla con un modello più complesso.
  final List<String> _blocchiTitoli = ['Blocco 1'];

  bool get _tastieraVisibile => _controllerAttivo != null;

  /// Chiamato da ogni SchedaBloccoCalcolo quando l'utente tocca il campo espressione.
  void _apriTastiera(
      TextEditingController controller,
      VoidCallback onEvaluate,
      ) {
    setState(() {
      _controllerAttivo = controller;
      _valutaAttivo = onEvaluate;
    });
  }

  void _chiudiTastiera() {
    setState(() {
      _controllerAttivo = null;
      _valutaAttivo = null;
    });
    FocusScope.of(context).unfocus();
  }

  void _aggiungiBlocco() {
    setState(() {
      final index = _blocchiTitoli.length + 1;
      _blocchiTitoli.add('Blocco $index');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tastieraVisibile = _tastieraVisibile && _controllerAttivo != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: MyDrawer(
        onThemeModeChanged: widget.onThemeModeChanged,
        currentThemeMode: widget.currentThemeMode,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _aggiungiBlocco,
        icon: const Icon(Icons.add),
        label: const Text('Nuovo blocco'),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // HEADER tipo "workspace"
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer,
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
                      Icons.apps,
                      size: 40,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Blocchi di calcolo',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Crea una sequenza di blocchi per calcoli complessi: '
                                'matrici, integrali, formule di sconto e altro.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer
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

              // Pillole info sui blocchi
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: const Icon(Icons.apps, size: 18),
                    label: Text('Blocchi: ${_blocchiTitoli.length}'),
                  ),
                  const Chip(
                    avatar: Icon(Icons.info_outline, size: 18),
                    label: Text('Tocca un blocco per aprire la tastiera'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Lista dei blocchi
              ..._blocchiTitoli.map(
                    (titolo) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SchedaBloccoCalcolo(
                    titolo: titolo,
                    onApriTastiera: _apriTastiera,
                  ),
                ),
              ),

              const SizedBox(height: 120),
            ],
          ),

          // Tastiera animata in basso
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
                  child: _controllerAttivo == null
                      ? const SizedBox.shrink()
                      : CustomMathKeyboard(
                    controller: _controllerAttivo!,
                    onClose: _chiudiTastiera,
                    onEvaluate: _valutaAttivo,
                    profile: MathKeyboardProfile.blocchi,
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
