import 'package:engkit/ui/pages/Drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Grafico extends StatelessWidget {
  final String title;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ThemeMode currentThemeMode;

  const Grafico({
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
      body: const Center(child: Text("Nto culu a tutti, merdi!")),
    );
  }
}