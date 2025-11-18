import 'package:flutter/material.dart';
import 'package:math_keyboard/math_keyboard.dart';
import 'package:engkit/features/calc/widgets/scheda_blocco_calcolo.dart';
import 'package:engkit/ui/pages/Drawer.dart';

class PaginaBlocchiCalcolo extends StatelessWidget {
  final String title;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ThemeMode currentThemeMode;

  const PaginaBlocchiCalcolo({
    super.key,
    required this.title,
    required this.onThemeModeChanged,
    required this.currentThemeMode,
});


  /*
  Crea una vista MathKeyboardViewInsets (della libreria) per fare in modo
  che la tastiera di math_keyboard, inserisca correttamente il contenuto digitato,
  nella pagina
   */
  @override
  Widget build(BuildContext context) {
    //Struttura del build tramite tastiera math_kaybord (di defulat)
    return MathKeyboardViewInsets(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        drawer: MyDrawer(
          onThemeModeChanged: onThemeModeChanged,
          currentThemeMode: currentThemeMode,
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