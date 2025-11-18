import 'package:engkit/features/calc/pages/home_calcolo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Widget radice dell'app Engkit.
class EngkitApp extends StatefulWidget {
  const EngkitApp({super.key});

  @override
  State<EngkitApp> createState() => _EngkitAppState();
}

class _EngkitAppState extends State<EngkitApp> {
  /// Tema corrente dell'app (chiaro/scuro/sistema).
  ThemeMode _themeMode = ThemeMode.system;

  /// Callback chiamata dal Drawer (e dalle pagine) per cambiare tema.
  void _onThemeModeChanged(ThemeMode newMode) {
    setState(() {
      _themeMode = newMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Engkit',
      debugShowCheckedModeBanner: false,

      // Temi
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,

      // Localizzazione
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

      // Prima pagina mostrata all'avvio.
      home: HomeCalcolo(
        title: 'Home Calcoli',
        onThemeModeChanged: _onThemeModeChanged,
        currentThemeMode: _themeMode,
      ),
    );
  }
}
