// lista_consensi.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:Assidim/assets/constants.dart' as constants;

/// ════════════════════════════════════════════════════════════════════
///  Lista consensi privacy
///  – non fa login: riceve già `userData` da GestioneConsensi
///  – mostra 3 switch (privacy 2-3-4)
///  – POST a …/ENDPOINT_PRIV quando l’utente cambia uno switch
/// ════════════════════════════════════════════════════════════════════
class ListaConsensi extends StatefulWidget {
  final Map<String, dynamic> userData; // passato dal container
  const ListaConsensi({super.key, required this.userData});

  @override
  State<ListaConsensi> createState() => _ListaConsensiState();
}

class _ListaConsensiState extends State<ListaConsensi> {
  late Map<String, dynamic> _privacy; // stato corrente
  bool _busy = false; // linea di progresso

  /*─────────────────────────────────────────────────────────────────*/
  @override
  void initState() {
    super.initState();
    _privacy = _parsePrivacy(widget.userData);
  }

  Map<String, dynamic> _parsePrivacy(Map<String, dynamic> user) {
    Map<String, dynamic> out = {};
    for (final k in ['privacy1', 'privacy2', 'privacy3', 'privacy4']) {
      final raw = (user[k] ?? '').toString();
      final parts = raw.split('|');
      out[k] = {
        'consent': parts.isNotEmpty && parts[0] == '1',
        'date': parts.length > 1 ? parts[1] : '',
      };
    }
    return out;
  }

  /*─────────────────────────────────────────────────────────────────*/
  Future<void> _setPrivacy(int id, bool val) async {
    final sw = Stopwatch()..start();
    setState(() => _busy = true);

    try {
      final url = Uri.https(constants.PATH, constants.ENDPOINT_PRIV);
      final body = jsonEncode({
        'id': widget.userData['id'].toString(),
        'privacyId': id.toString(),
        'privacyStatus': val,
      });

      debugPrint('[PRIV] → POST $url  body=$body');
      final res = await http.post(url, body: body);
      debugPrint('[PRIV] ← ${res.statusCode}  '
          '(${sw.elapsedMilliseconds} ms)  ${res.body}');

      if (res.statusCode == 200 &&
          (jsonDecode(res.body)['http_response_code'] == '1')) {
        // aggiorna stato locale
        setState(() {
          _privacy['privacy$id']['consent'] = val;
          _privacy['privacy$id']['date'] =
              DateTime.now().toIso8601String().split('.').first;
        });
      } else {
        _showSnack('Errore salvataggio consenso');
      }
    } catch (e) {
      debugPrint('[PRIV] errore: $e');
      _showSnack('Errore di rete');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showSnack(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  /*─────────────────────────────────────────────────────────────────*/
  @override
  Widget build(BuildContext context) {
    final p2 = _privacy['privacy2']['consent'] as bool;
    final p3 = _privacy['privacy3']['consent'] as bool;
    final p4 = _privacy['privacy4']['consent'] as bool;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HtmlWidget(
          "<h2 style='text-align:center;'>Gestione Consensi Privacy</h2>",
        ),
        if (_busy) const LinearProgressIndicator(),
        constants.SPACER,

        /* privacy 2 */
        Row(
          children: [
            Expanded(child: Text(constants.privacy2)),
            Switch(
              value: p2,
              activeColor: constants.COLORE_PRINCIPALE,
              onChanged: (v) => _setPrivacy(2, v),
            ),
          ],
        ),
        constants.SPACER,

        /* privacy 3 */
        Row(
          children: [
            Expanded(child: Text(constants.privacy3)),
            Switch(
              value: p3,
              activeColor: constants.COLORE_PRINCIPALE,
              onChanged: (v) => _setPrivacy(3, v),
            ),
          ],
        ),
        constants.SPACER,

        /* privacy 4 */
        Row(
          children: [
            Expanded(child: Text(constants.privacy4)),
            Switch(
              value: p4,
              activeColor: constants.COLORE_PRINCIPALE,
              onChanged: (v) => _setPrivacy(4, v),
            ),
          ],
        ),
        constants.SPACER,
      ],
    );
  }
}
