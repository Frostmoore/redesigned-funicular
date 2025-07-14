// gestione_consensi.dart
import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/sections/account/change_username.dart';
import 'package:Assidim/sections/account/lista_consensi.dart';

/// ════════════════════════════════════════════════════════════════════
///  GESTIONE CONSENSI  –  container
/// ════════════════════════════════════════════════════════════════════
class GestioneConsensi extends StatefulWidget {
  /// Dati di configurazione generali dell’app (colori, testi, ecc.)
  final Map<String, dynamic> data;
  const GestioneConsensi({super.key, required this.data});

  @override
  State<GestioneConsensi> createState() => _GestioneConsensiState();
}

class _GestioneConsensiState extends State<GestioneConsensi> {
  final _storage = const FlutterSecureStorage();
  late Future<Map<String, dynamic>> _futureUserData; // login 1-shot

  /*─────────────────────────────────────────────────────────────────*/
  @override
  void initState() {
    super.initState();
    _futureUserData = _loginOnce();
  }

  /*─────────────────────────────────────────────────────────────────*/
  Future<Map<String, dynamic>> _loginOnce() async {
    final sw = Stopwatch()..start();
    debugPrint('[GC] 0 ms → init login');

    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('isAlreadyLogged') ?? false)) {
      debugPrint('[GC] utente NON loggato (isAlreadyLogged = false)');
      return {};
    }

    final uname = await _storage.read(key: 'username') ?? '';
    final pwd = await _storage.read(key: 'password') ?? '';
    if (uname.isEmpty || pwd.isEmpty) {
      debugPrint('[GC] credenziali mancanti nello storage');
      return {};
    }

    final url = Uri.https(constants.PATH, constants.ENDPOINT_LOG);
    debugPrint('[GC]  → POST $url');

    final res = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': constants.ID,
          'token': constants.TOKEN,
          'username': uname,
          'password': pwd,
        }));

    debugPrint('[GC] ${sw.elapsedMilliseconds} ms ← HTTP ${res.statusCode}');

    if (res.statusCode != 200) return {};

    final Map js = jsonDecode(res.body);
    if (js['http_response_code'] != '1') {
      debugPrint('[GC] login code ${js['http_response_code']}');
      return {};
    }

    debugPrint('[GC] login OK in ${sw.elapsedMilliseconds} ms');
    return Map<String, dynamic>.from(js['result']);
  }

  /*─────────────────────────────────────────────────────────────────*/
  Future<void> _clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await _storage.deleteAll();
    await prefs.clear();
    if (mounted) setState(() {}); // refresh UI
  }

  /*─────────────────────────────────────────────────────────────────*/
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _futureUserData,
      builder: (context, snap) {
        // ───── loader
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final logged = snap.data?.isNotEmpty ?? false;
        final user = snap.data ?? {}; // Map vuota se non loggato

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              HtmlWidget(
                  "<h2 style='text-align:center;'>GESTISCI LE IMPOSTAZIONI</h2>"),
              constants.SPACER,

              /* ───── modifica credenziali ───── */
              if (logged) ...[
                ChangeUsername(userData: user), // usa i dati già presenti
                constants.SPACER_MEDIUM,
              ],

              /* ───── consensi privacy ───── */
              if (logged) ...[
                ListaConsensi(userData: user),
                constants.SPACER_MEDIUM,
              ],

              /* ───── sezione “cancella dati” ───── */
              HtmlWidget(
                  '<h3 style="text-align:center;">Rimozione dati Applicazione</h3>'),
              constants.SPACER_MEDIUM,
              HtmlWidget(
                  '<p style="text-align:center;"><strong>ATTENZIONE:</strong> '
                  'Cliccando su questo tasto, effettuerai il log-out dal tuo account e '
                  'tutte le informazioni salvate verranno eliminate dal dispositivo.</p>'),
              constants.SPACER_MEDIUM,
              ElevatedButton(
                style: constants.STILE_BOTTONE_ROSSO,
                onPressed: () async {
                  await _clearAll();
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dati locali rimossi')));
                },
                child: const Text('CANCELLA!'),
              ),
              constants.SPACER,
              ElevatedButton(
                style: constants.STILE_BOTTONE_ROSSO,
                onPressed: () {
                  launchUrl(Uri.parse(
                      'https://hybridandgogsv.it/delete_account.php'));
                },
                child: const Text('Rimuovi il tuo Account!'),
              ),
            ],
          ),
        );
      },
    );
  }
}
