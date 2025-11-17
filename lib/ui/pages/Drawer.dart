import 'package:flutter/material.dart';
import 'package:engkit/features/calc/pages/home_calcolo.dart';

class MyDrawer extends StatelessWidget {
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ThemeMode currentThemeMode;

  const MyDrawer({
    super.key,
    required this.onThemeModeChanged,
    required this.currentThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.red),
            child: Text(
              'EngKit',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),

          // Home del calcolo
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home Calcoli'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => HomeCalcolo(
                    title: 'Home Calcoli',
                    onThemeModeChanged: onThemeModeChanged,
                    currentThemeMode: currentThemeMode,
                  ),
                ),
              );
            },
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17.0, vertical: 12),
            child: const Text(
              'Tema',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),

          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.light, label: Text("Chiaro"), icon: Icon(Icons.light_mode)),
              ButtonSegment(value: ThemeMode.dark, label: Text("Scuro"), icon: Icon(Icons.dark_mode)),
              ButtonSegment(value: ThemeMode.system, label: Text("Sistema"), icon: Icon(Icons.settings)),
            ],
            selected: {currentThemeMode},
            onSelectionChanged: (selection) {
              onThemeModeChanged(selection.first);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}