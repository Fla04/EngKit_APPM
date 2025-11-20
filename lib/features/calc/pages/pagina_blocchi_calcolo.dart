import 'package:flutter/material.dart';

import 'package:engkit/features/calc/widgets/scheda_blocco_calcolo.dart';
import 'package:engkit/features/calc/widgets/custom_math_keyboard.dart';
import 'package:engkit/ui/pages/Drawer.dart'; // <-- sistema il path al tuo Drawer

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

  bool get _tastieraVisibile => _controllerAttivo != null;

  /// Viene chiamato da ogni SchedaBloccoCalcolo quando l'utente
  /// tocca il campo espressione.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(    // o MyDrawer, usa il tuo widget reale
        onThemeModeChanged: widget.onThemeModeChanged,
        currentThemeMode: widget.currentThemeMode,
      ),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          // Contenuto principale scrollabile
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SchedaBloccoCalcolo(
                titolo: 'Blocco di calcolo',
                onApriTastiera: _apriTastiera,
              ),
              const SizedBox(height: 16),
              // aggiungi altri blocchi se ti servono
              const SizedBox(height: 80), // un po' di spazio sotto
            ],
          ),

          // Tastiera appiccicata in basso, visibile solo se c'è un blocco attivo
          if (_tastieraVisibile && _controllerAttivo != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: CustomMathKeyboard(
                controller: _controllerAttivo!,
                onClose: _chiudiTastiera,
                onEvaluate: _valutaAttivo,
              ),
            ),
        ],
      ),
    );
  }
}
