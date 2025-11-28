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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: MyDrawer(
        onThemeModeChanged: onThemeModeChanged,
        currentThemeMode: currentThemeMode,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;
            final crossAxisCount = isWide ? 3 : 2;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // HEADER
                Text(
                  'Strumenti di calcolo',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Scegli il tipo di operazione: matrici, integrali, formule di sconto...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 24),

                // GRIGLIA DI CARD
                GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _HomeCalcoloCard(
                      title: 'Calcolo matrici',
                      subtitle: 'Prodotti, inversa, determinante…',
                      icon: Icons.grid_on_outlined,
                      color: theme.colorScheme.primaryContainer,
                      iconColor: theme.colorScheme.onPrimaryContainer,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => Algebra(
                              title: 'Calcolo matrici',
                              onThemeModeChanged: onThemeModeChanged,
                              currentThemeMode: currentThemeMode,
                            ),
                            // Quando avrai una pagina dedicata:
                            // builder: (_) => const MatriciPage(),
                          ),
                        );
                      },
                    ),
                    _HomeCalcoloCard(
                      title: 'Integrali',
                      subtitle: 'Definiti, indefiniti, blocchi personalizzati.',
                      icon: Icons.functions,
                      color: theme.colorScheme.secondaryContainer,
                      iconColor: theme.colorScheme.onSecondaryContainer,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PaginaBlocchiCalcolo(
                              title: 'Integrali',
                              onThemeModeChanged: onThemeModeChanged,
                              currentThemeMode: currentThemeMode,
                            ),
                            // In futuro: pagina integrali dedicata
                          ),
                        );
                      },
                    ),
                    _HomeCalcoloCard(
                      title: 'Formule di sconto',
                      subtitle: 'Tassi, montante, sconto commerciale/razionale.',
                      icon: Icons.percent,
                      color: theme.colorScheme.tertiaryContainer,
                      iconColor: theme.colorScheme.onTertiaryContainer,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => Probabilita(
                              title: 'Formule di sconto',
                              onThemeModeChanged: onThemeModeChanged,
                              currentThemeMode: currentThemeMode,
                            ),
                            // In futuro: pagina sconto dedicata
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // SEZIONE OPZIONALE: FAST ACTIONS
                Text(
                  'Accessi rapidi',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      label: const Text('Algebra'),
                      avatar: const Icon(Icons.calculate),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => Algebra(
                              title: 'Algebra',
                              onThemeModeChanged: onThemeModeChanged,
                              currentThemeMode: currentThemeMode,
                            ),
                          ),
                        );
                      },
                    ),
                    ActionChip(
                      label: const Text('Probabilità'),
                      avatar: const Icon(Icons.casino_outlined),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => Probabilita(
                              title: 'Probabilità',
                              onThemeModeChanged: onThemeModeChanged,
                              currentThemeMode: currentThemeMode,
                            ),
                          ),
                        );
                      },
                    ),
                    ActionChip(
                      label: const Text('Blocchi generali'),
                      avatar: const Icon(Icons.apps),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PaginaBlocchiCalcolo(
                              title: 'Blocchi di calcolo',
                              onThemeModeChanged: onThemeModeChanged,
                              currentThemeMode: currentThemeMode,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Card della home calcolo, con icona grande, titolo e sottotitolo.
class _HomeCalcoloCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _HomeCalcoloCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icona in alto a destra
              Align(
                alignment: Alignment.topRight,
                child: Icon(
                  icon,
                  size: 32,
                  color: iconColor,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: iconColor.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
