import 'package:engkit/features/calc/pages/pagina_blocchi_calcolo.dart';
import 'package:flutter/material.dart';
import 'package:engkit/ui/pages/Drawer.dart';
import 'package:engkit/features/calc/pages/algebra.dart';
import 'package:engkit/features/calc/pages/probabilita.dart';
import 'package:engkit/features/calc/pages/pagina_blocchi_calcolo.dart';



class HomeCalcolo extends StatelessWidget {
  final String title;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ThemeMode currentThemeMode;

  const HomeCalcolo({
    super.key,
    required this.title,
    required this.onThemeModeChanged,
    required this.currentThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: MyDrawer(
        onThemeModeChanged: onThemeModeChanged,
        currentThemeMode: currentThemeMode,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _HomeCalcoloButton(
                  label: 'Calcolo matrici',
                  icon: Icons.grid_on_outlined,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Algebra(
                          title: 'Calcolo matrici',
                          onThemeModeChanged: onThemeModeChanged,
                          currentThemeMode: currentThemeMode,
                        ),
                        // quando avrai la pagina vera:
                        // builder: (_) => const MatriciPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _HomeCalcoloButton(
                  label: 'Integrali',
                  icon: Icons.functions,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PaginaBlocchiCalcolo(
                          title: 'Integrali',
                          onThemeModeChanged: onThemeModeChanged,
                          currentThemeMode: currentThemeMode,
                        ),
                        // builder: (_) => const IntegraliPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _HomeCalcoloButton(
                  label: 'Formule di sconto',
                  icon: Icons.percent,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Probabilita(
                          title: 'Formule di sconto',
                          onThemeModeChanged: onThemeModeChanged,
                          currentThemeMode: currentThemeMode,
                        ),
                        // builder: (_) => const ScontoPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottone riutilizzabile, largo quanto il contenitore,
/// con icona, testo grande e bordi arrotondati.
class _HomeCalcoloButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _HomeCalcoloButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // il bottone occupa tutta la larghezza
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(label),
        ),
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          // puoi aggiungere anche elevation, padding globale, ecc.
        ),
        onPressed: onPressed,
      ),
    );
  }
}