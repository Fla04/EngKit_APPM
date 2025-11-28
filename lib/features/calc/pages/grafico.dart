import 'package:flutter/material.dart';
import 'package:engkit/ui/pages/Drawer.dart';
import 'package:engkit/features/calc/widgets/custom_math_keyboard.dart';

class Grafico extends StatefulWidget {
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
  State<Grafico> createState() => _GraficoState();
}

class _GraficoState extends State<Grafico> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: 'f(x) = ');
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _chiudiTastiera() {
    _focusNode.unfocus();
  }

  // Qui in futuro potrai agganciare la generazione del grafico
  void _disegnaGrafico() {
    // TODO: prendi _controller.text e passalo al motore di grafico
    // per ora non fa nulla
  }

  @override
  Widget build(BuildContext context) {
    final tastieraVisibile = _focusNode.hasFocus;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      drawer: MyDrawer(
        onThemeModeChanged: widget.onThemeModeChanged,
        currentThemeMode: widget.currentThemeMode,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                readOnly: true,
                showCursor: true,
                onTap: () {
                  _focusNode.requestFocus();
                },
                decoration: const InputDecoration(
                  labelText: 'Funzione da rappresentare (es. f(x) = x^2)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Qui più avanti potrai mettere il widget che mostra il grafico
              Container(
                height: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Area grafico (TODO)'),
              ),

              const SizedBox(height: 120),
            ],
          ),

          if (tastieraVisibile)
            Align(
              alignment: Alignment.bottomCenter,
              child: CustomMathKeyboard(
                controller: _controller,
                onClose: _chiudiTastiera,
                onEvaluate: _disegnaGrafico,
                profile: MathKeyboardProfile.grafico, // 👈 profilo grafico
              ),
            ),
        ],
      ),
    );
  }
}
