/// Modello che rappresenta un singolo blocco di calcolo (na botta e via) dell'app.
class BloccoCalcolo {
  final String id; //identificatore univoco
  final String titolo; //testo mostrato all'utente
  final String espressioneTeX; //espressione matematica
  final double? ultimoRisultato; //ultimo valore calcolato

  const BloccoCalcolo({
    required this.id,
    required this.titolo,
    required this.espressioneTeX,
    this.ultimoRisultato,
  });

  /// Crea una copia (non modificabile) del blocco con eventuali campi modificati.
  BloccoCalcolo copyWith({
    String? titolo,
    String? espressioneTeX,
    double? ultimoRisultato,
  }) {
    return BloccoCalcolo(
      id: id, // l'id resta invariato: rappresenta lo stesso blocco
      titolo: titolo ?? this.titolo,
      espressioneTeX: espressioneTeX ?? this.espressioneTeX,
      ultimoRisultato: ultimoRisultato ?? this.ultimoRisultato,
    );
  }
}