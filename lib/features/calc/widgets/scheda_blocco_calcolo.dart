import 'package:flutter/material.dart';
import 'package:math_keyboard/math_keyboard.dart';

/// Widget che rappresenta graficamente un BloccoCalcolo.
class SchedaBloccoCalcolo extends StatefulWidget {
  final String titolo;

  const SchedaBloccoCalcolo({
    super.key,
    required this.titolo,
  });

  @override
  State<SchedaBloccoCalcolo> createState() => _SchedaBloccoCalcoloState();
}

class _SchedaBloccoCalcoloState extends State<SchedaBloccoCalcolo> {
  // Controller opzionale per il MathField (Valutare implementazione?)
  final MathFieldEditingController _controller = MathFieldEditingController();

  @override
  void dispose() { //Rilascia il widget quando non serve più
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titolo
            Text(
              widget.titolo,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            // Campo di input matematico
            MathField(
              controller: _controller,
              keyboardType: MathKeyboardType.expression,
              variables: const ['x', 'y', 'z'], //Variabili che verranno interpretate come tali. Aggiungere?
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Inserisci espressione',
              ),
              onChanged: (tex) {
                // stato in tempo reale del blocco di calcolo
              },
              onSubmitted: (tex) {
                //final risultato = ValutaEspressione()(tex);
                //setState(() => _ultimoRisultato = risultato);
              },
            ),
          ],
        ),
      ),
    );
  }
}