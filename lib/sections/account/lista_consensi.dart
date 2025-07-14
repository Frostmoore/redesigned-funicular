// lista_consensi.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'package:Assidim/assets/constants.dart' as constants;

class ListaConsensi extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ListaConsensi({super.key, required this.userData});

  @override
  State<ListaConsensi> createState() => _ListaConsensiState();
}

class _ListaConsensiState extends State<ListaConsensi> {
  late bool _p2, _p3, _p4;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    bool _raw(dynamic r) => (r?.toString().split('|').first == '1');
    _p2 = _raw(widget.userData['privacy2']);
    _p3 = _raw(widget.userData['privacy3']);
    _p4 = _raw(widget.userData['privacy4']);
  }

  /*──────────────────────────────────────────────────────────────*/
  Future<void> _save(int id, bool optimisticValue) async {
    final url = Uri.https(constants.PATH, constants.ENDPOINT_PRIV);
    final body = jsonEncode({
      'id': widget.userData['id'].toString(),
      'privacyId': id.toString(),
      'privacyStatus': optimisticValue,
    });

    setState(() => _busy = true);
    debugPrint('[PRIV] → $url  $body');

    try {
      final res = await http.post(url,
          headers: {'Content-Type': 'application/json'}, body: body);
      final ok =
          res.statusCode == 200 && (jsonDecode(res.body)['result'] == 'ok');
      debugPrint('[PRIV] ← ${res.statusCode} ok=$ok ${res.body}');
      if (!ok) throw Exception('save failed');
    } catch (e) {
      // ❌ errore → ripristina valore precedente
      debugPrint('[PRIV] errore $e – rollback');
      setState(() {
        if (id == 2) _p2 = !_p2;
        if (id == 3) _p3 = !_p3;
        if (id == 4) _p4 = !_p4;
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Errore salvataggio')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /*──────────────────────────────────────────────────────────────*/
  @override
  Widget build(BuildContext context) => Column(
        children: [
          const HtmlWidget(
            "<h2 style='text-align:center;'>Gestione Consensi Privacy</h2>",
          ),
          if (_busy) const LinearProgressIndicator(),
          constants.SPACER,
          _row(constants.privacy2, _p2, 2),
          constants.SPACER,
          _row(constants.privacy3, _p3, 3),
          constants.SPACER,
          _row(constants.privacy4, _p4, 4),
          constants.SPACER,
        ],
      );

  Widget _row(String label, bool value, int id) => Row(
        children: [
          Expanded(child: Text(label)),
          Switch(
            value: value,
            activeColor: constants.COLORE_PRINCIPALE,
            onChanged: (v) {
              // ◉ aggiorna SUBITO l’interfaccia
              setState(() {
                if (id == 2) _p2 = v;
                if (id == 3) _p3 = v;
                if (id == 4) _p4 = v;
              });
              // ◉ poi chiama l’API (rollback se fallisce)
              _save(id, v);
            },
          ),
        ],
      );
}
