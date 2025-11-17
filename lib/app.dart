import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'router.dart';

/// Widget radice dell'app Engkit.
class EngkitApp extends StatelessWidget {
  const EngkitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Engkit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      routerConfig: routerPrincipale,
      locale: const Locale('it', 'IT'),
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('it', 'IT'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
