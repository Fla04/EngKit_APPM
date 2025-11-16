import 'package:flutter/material.dart';
import 'package:math_keyboard/math_keyboard.dart';

import 'package:engkit/features/calc/widgets/scheda_blocco_calcolo.dart';

class PaginaBlocchiCalcolo extends StatelessWidget {
  const PaginaBlocchiCalcolo({super.key});

  /*
  Crea una vista MathKeyboardViewInsets (della libreria) per fare in modo
  che la tastiera di math_keyboard, inserisca correttamente il contenuto digitato,
  nella pagina
   */
  @override
  Widget build(BuildContext context) {
    return MathKeyboardViewInsets(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Blocchi di calcolo'),
        ),
        body: const _CorpoBlocchiCalcolo(),
      ),
    );
  }
}

// Corpo vero e proprio della pagina.
class _CorpoBlocchiCalcolo extends StatelessWidget {
  const _CorpoBlocchiCalcolo();

  @override
  Widget build(BuildContext context) {
    // Per ora mostriamo due blocchi di prova.
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        SchedaBloccoCalcolo(titolo: 'Campo prova 1'),
        SizedBox(height: 16),
        SchedaBloccoCalcolo(titolo: 'Campo prova 2'),
      ],
    );
  }
}
