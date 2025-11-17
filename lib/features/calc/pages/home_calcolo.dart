import 'package:flutter/material.dart';
import 'package:engkit/ui/pages/Drawer.dart';


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
      body: const Center(child: Text("Contenuto di Page 2")),
    );
  }
}