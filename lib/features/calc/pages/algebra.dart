import 'package:engkit/ui/pages/Drawer.dart';
import 'package:flutter/material.dart';

class Algebra extends StatelessWidget {
  final String title;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ThemeMode currentThemeMode;

  const Algebra({
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
          currentThemeMode: currentThemeMode
      ),
      body: const Center(child: Text("Contenuto della pagina.")),
    );
  }
}