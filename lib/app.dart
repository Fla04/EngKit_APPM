import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'router.dart';


class EngkitApp extends StatelessWidget {
  const EngkitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Engkit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),

      // Configurazione del router (go_router).
      routerConfig: routerPrincipale,

      // Lingua di default: italiano.
      locale: const Locale('it', 'IT'),

      // Lingue supportate dall'app.
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('it', 'IT'),
      ],

      // Delegati per le traduzioni di Material, Widgets, Cupertino.
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
