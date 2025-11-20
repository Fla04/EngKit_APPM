import 'dart:convert';
import 'package:http/http.dart' as http;

/// Semplice client per Wolfram|Alpha Full Results API (output JSON).
class WolframAlphaApi {
  WolframAlphaApi(this.appId);

  final String appId;

  static const _baseUrl = 'api.wolframalpha.com';

  /// Ritorna una stringa "umana" con il risultato principale,
  /// oppure null se non si riesce a ricavare nulla.
  Future<String?> compute(String input) async {
    final uri = Uri.https(
      _baseUrl,
      '/v2/query',
      {
        'appid': appId,
        'input': input,
        'output': 'json',
        'format': 'plaintext',
      },
    );

    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final queryResult = data['queryresult'] as Map<String, dynamic>?;

    if (queryResult == null || queryResult['success'] != true) {
      return null;
    }

    final pods = (queryResult['pods'] as List?)?.cast<dynamic>() ?? const [];

    // 1. Provo a cercare un pod "Result" o simile
    final preferredIds = <String>{
      'Result',
      'Results',
      'Integral',
      'IndefiniteIntegral',
      'DefiniteIntegral',
      'Limit',
      'Derivative',
      'MatrixOutput',
      'Eigenvalues',
      'Eigenvectors',
      'Determinant',
    };

    Map<String, dynamic>? chosenPod;

    for (final p in pods) {
      final pod = p as Map<String, dynamic>;
      final id = (pod['id'] ?? pod['title'] ?? '').toString();
      if (preferredIds.contains(id)) {
        chosenPod = pod;
        break;
      }
    }

    // 2. Se non ho trovato un pod "preferito", prendo il primo con testo
    chosenPod ??= pods.cast<Map<String, dynamic>?>().firstWhere(
          (p) {
        final subpods = (p?['subpods'] as List?) ?? const [];
        if (subpods.isEmpty) return false;
        final sp = subpods.first as Map<String, dynamic>;
        final text = (sp['plaintext'] ?? '').toString();
        return text.isNotEmpty;
      },
      orElse: () => null,
    );

    if (chosenPod == null) return null;

    final subpods = (chosenPod['subpods'] as List?) ?? const [];
    if (subpods.isEmpty) return null;

    final firstSubpod = subpods.first as Map<String, dynamic>;
    final plaintext = (firstSubpod['plaintext'] ?? '').toString().trim();

    if (plaintext.isEmpty) return null;

    return plaintext;
  }
}
