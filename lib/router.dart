import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:engkit/features/calc/pages/pagina_blocchi_calcolo.dart';

// Router principale dell'app Engkit. (Prova per vedere com'era)
final GoRouter routerPrincipale = GoRouter(
  // All'avvio l'app apre direttamente la pagina di calcolo.
  initialLocation: '/calc',

  routes: [
    GoRoute(
      path: '/calc',      // URL interno
      name: 'calcolo',    // nome simbolico della route
      builder: (context, state) => const PaginaBlocchiCalcolo(),
    ),
  ],
);
