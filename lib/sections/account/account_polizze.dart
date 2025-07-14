import 'package:accordion/accordion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/sections/responses/nessun_risultato.dart';

class AccountPolizze extends StatefulWidget {
  final Map<String, dynamic> data;
  final Map userData;

  const AccountPolizze({
    super.key,
    required this.data,
    required this.userData,
  });

  @override
  State<AccountPolizze> createState() => _AccountPolizzeState();
}

class _AccountPolizzeState extends State<AccountPolizze> {
  late final Future<List<Map<String, dynamic>>> _polizzeFuture;

  @override
  void initState() {
    super.initState();
    _polizzeFuture = _getPolizze();
  }

  //───────────────────────────────────────────────────────────────────────────
  //  HTTP + MERGE
  //───────────────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> _getPolizze() async {
    print('POLIZZE_LOG: Inizio chiamata principale');

    try {
      final Map<String, dynamic> data = Map<String, dynamic>.from(widget.data);
      final Map<String, dynamic> user =
          Map<String, dynamic>.from(widget.userData);

      final usernameAe = user['username']?.toString();
      final codiceFiscaleTty = user['cf']?.toString();
      final assiurl = data['assiurl'] as String;
      final assisecret = data['assisecret'] as String;
      // final usernameAe = 'daniel.zanetti18@gmail.com';
      // final codiceFiscaleTty = 'ZNTDNL91S18L378A';
      // final assiurl = 'agenzieriunite.assieasy.com';
      // final assisecret = '7343921cbc2beaf4ba89aecf72d37b75';

      final headersBase = {
        'chiave-hi': constants.chiaveHi,
        'Host': assiurl,
        'assi_secret': assisecret,
      };

      print('POLIZZE_LOG: headersBase = $headersBase');

      final urlLookup = Uri.https(
          assiurl, 'assieasy/clienti/autenticazione/get_credenziali_utente');
      final lookupRes = await http.post(urlLookup, headers: headersBase, body: {
        'username': usernameAe,
        'codicefiscale': codiceFiscaleTty,
      });

      print('POLIZZE_LOG: lookup → status = ${lookupRes.statusCode}');
      print('POLIZZE_LOG: lookup → body = ${lookupRes.body}');

      if (lookupRes.statusCode != 200) throw Exception("Errore lookup");

      final passwordAe =
          jsonDecode(lookupRes.body)['data']['PASSWORD'] as String;

      final urlLogin =
          Uri.https(assiurl, 'assieasy/clienti/autenticazione/login');
      final loginRes = await http.post(urlLogin, headers: headersBase, body: {
        'username': usernameAe,
        'password': passwordAe,
      });

      print('POLIZZE_LOG: login → status = ${loginRes.statusCode}');
      print('POLIZZE_LOG: login → body = ${loginRes.body}');

      if (loginRes.statusCode != 200) throw Exception("Errore login");

      final tokenAe = jsonDecode(loginRes.body)['data']['TOKEN'] as String;

      final headersAuthed = {
        ...headersBase,
        'Accept': '*/*',
        'token': tokenAe,
      };

      final urlPolizze = Uri.https(assiurl, 'assieasy/clienti/polizze/get');
      final polizzeRes =
          await http.post(urlPolizze, headers: headersAuthed, body: {
        'ID_POLIZZA': '0',
        'SOLO_VIVE': '1',
        'sorts[1][column]': 'NUMERO_POLIZZA',
        'sorts[1][order]': 'DESC',
      });

      print('POLIZZE_LOG: polizze → status = ${polizzeRes.statusCode}');
      print('POLIZZE_LOG: polizze → body = ${polizzeRes.body}');

      final polizzeData = jsonDecode(polizzeRes.body)['data'] as List<dynamic>;
      if (polizzeData.isEmpty) throw Exception("Lista polizze vuota");

      final urlTitoli = Uri.https(assiurl, 'assieasy/clienti/titoli/get');
      final titoliRes =
          await http.post(urlTitoli, headers: headersAuthed, body: {
        'STATO_TITOLO': '1',
      });

      print('POLIZZE_LOG: titoli → status = ${titoliRes.statusCode}');
      print('POLIZZE_LOG: titoli → body = ${titoliRes.body}');

      final titoliRaw = jsonDecode(titoliRes.body)['data'] as List<dynamic>;
      final titoliById = <String, String?>{};
      for (final t in titoliRaw) {
        final id = t['ID_POLIZZA']?.toString();
        final dataE = t['DATA_EFFETTO'];
        if (id != null) titoliById[id] = dataE;
      }

      final merged = polizzeData
          .cast<Map<String, dynamic>>()
          .map((p) => {
                ...p,
                'DATA_EFFETTO_TITOLO': titoliById[p['ID_POLIZZA']?.toString()],
              })
          .toList();

      print('POLIZZE_LOG: merge completato → ${merged.length} polizze');
      return merged;
    } catch (e, st) {
      print('POLIZZE_LOG: ERRORE nella chiamata principale: $e\n$st');
      return await _getPolizzeFallbackJWT();
    }
  }

  Future<List<Map<String, dynamic>>> _getPolizzeFallbackJWT() async {
    print('POLIZZE_LOG: Inizio fallback JWT');

    final user = Map<String, dynamic>.from(widget.userData);
    final data = Map<String, dynamic>.from(widget.data);

    final cf = user['cf']?.toString();
    final piva = user['piva']?.toString();
    final aziendaId = data['azienda_id'].toString();
    final licenzaId = data['licenza_id'].toString();
    final agenziaId = data['agenzia_id'].toString();
    final chiavePrivata = data['chiave_privata'] as String;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final payload = {
      'iss': 'GSV',
      'aud': 'Sintesi',
      'jti': const Uuid().v4(),
      'iat': now,
      'nbf': now,
      'exp': now + 300,
      'lic': licenzaId,
      'azi': aziendaId,
      'age': agenziaId,
    };
    final header = {'alg': 'HS256', 'typ': 'JWT'};

    print('POLIZZE_LOG: JWT payload = $payload');

    String encodeBase64Url(Map<String, dynamic> map) =>
        base64UrlEncode(utf8.encode(json.encode(map))).replaceAll('=', '');

    final encodedHeader = encodeBase64Url(header);
    final encodedPayload = encodeBase64Url(payload);

    final toSign = '$encodedHeader.$encodedPayload';
    final hmac = Hmac(sha256, utf8.encode(chiavePrivata));
    final signature = base64UrlEncode(hmac.convert(utf8.encode(toSign)).bytes)
        .replaceAll('=', '');
    final jwt = '$toSign.$signature';

    print('POLIZZE_LOG: JWT token generato → $jwt');

    final uri =
        Uri.https(data['jwturl'], '/webservice/gsvhomeinsurance/polizze', {
      if (cf != null) 'codice_fiscale': cf,
      if (piva != null) 'partita_iva': piva,
    });

    print('POLIZZE_LOG: chiamata fallback → $uri');

    final res = await http.get(uri, headers: {
      'Authorization': 'Bearer $jwt',
      'Accept': 'application/json',
    });

    print('POLIZZE_LOG: fallback → status = ${res.statusCode}');
    print('POLIZZE_LOG: fallback → body = ${res.body}');

    if (res.statusCode != 200) throw Exception("Fallback fallito");

    final list = jsonDecode(res.body)['data'] as List<dynamic>;
    print('POLIZZE_LOG: fallback completato → ${list.length} polizze');
    return list.cast<Map<String, dynamic>>();
  }

  //───────────────────────────────────────────────────────────────────────────
  //  UI
  //───────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _polizzeFuture,
      builder: (context, snap) {
        // 1) stato di caricamento
        if (snap.connectionState != ConnectionState.done) {
          return const Center(
            child:
                CircularProgressIndicator(color: constants.COLORE_PRINCIPALE),
          );
        }

        // 2) nessun risultato
        if (!snap.hasData || snap.data!.isEmpty) return const NessunRisultato();

        // 3) lista polizze
        final polizze = snap.data!;

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: polizze.length,
          shrinkWrap: true, // <- ① usa l'altezza necessaria
          physics:
              const NeverScrollableScrollPhysics(), // <- ② disattiva lo scroll interno
          itemBuilder: (context, i) => _polizzaTile(context, polizze[i]),
        );
      },
    );
  }

  String formatDateIt(String? date) {
    if (date == null || date.isEmpty) return '-';
    try {
      final parts = date.split('-');
      if (parts.length != 3) return date;
      // YYYY-MM-DD → DD/MM/YYYY
      return '${parts[2]}/${parts[1]}/${parts[0]}';
    } catch (_) {
      return date;
    }
  }

  Widget _scadenzaLabel(String? dataEffettoTitoloStr) {
    // Se la data è nulla o vuota → pallino verde
    if (dataEffettoTitoloStr == null || dataEffettoTitoloStr.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(left: 8),
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black26, width: 1),
        ),
      );
    }
    try {
      final DateTime dataScadenza = DateTime.parse(dataEffettoTitoloStr);
      final DateTime oggi = DateTime.now();
      final giorniMancanti = dataScadenza.difference(oggi).inDays;

      Color colore;
      if (giorniMancanti <= 10 && giorniMancanti >= 0) {
        colore = Colors.red;
      } else if (giorniMancanti > 10 && giorniMancanti <= 31) {
        colore = Colors.yellow.shade700;
      } else if (giorniMancanti > 31) {
        colore = Colors.green;
      } else {
        // già scaduta, pallino rosso sbiadito (o niente se preferisci)
        return Container(
          margin: const EdgeInsets.only(left: 8),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.red.shade200,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black26, width: 1),
          ),
        );
      }

      return Container(
        margin: const EdgeInsets.only(left: 8),
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: colore,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black26, width: 1),
        ),
      );
    } catch (_) {
      // Se c'è un errore nel parsing → pallino verde
      return Container(
        margin: const EdgeInsets.only(left: 8),
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black26, width: 1),
        ),
      );
    }
  }

  //───────────────────────────────────────────────────────────────────────────
  //  singola tile
  //───────────────────────────────────────────────────────────────────────────
  Widget _polizzaTile(BuildContext context, Map<String, dynamic> p) {
    return Accordion(
      headerBorderWidth: 1,
      headerBorderColor: Colors.transparent,
      headerBorderColorOpened: Colors.transparent,
      headerBackgroundColor: Colors.transparent,
      headerBackgroundColorOpened: Colors.transparent,
      contentBorderColor: Colors.transparent,
      contentBackgroundColor: Colors.transparent,
      disableScrolling: true,
      headerPadding: EdgeInsets.zero,
      children: [
        AccordionSection(
          rightIcon: const Icon(Icons.arrow_drop_down_rounded, size: 45),
          header: SizedBox(
            height: 70,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/assets/polizze_immagine.png'),
                  fit: BoxFit.contain,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  8,
                  18,
                  MediaQuery.of(context).size.width / 3,
                  8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        (p['TARGA'] != null &&
                                p['TARGA'].toString().trim().isNotEmpty)
                            ? 'Polizza ${p['DESC_RAMO']} - ${p['TARGA']}'
                            : 'Polizza ${p['DESC_RAMO']}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _scadenzaLabel(p['DATA_EFFETTO_TITOLO']),
                  ],
                ),
              ),
            ),
          ),

          // ------------- CONTENUTO -------------
          content: Builder(builder: (_) {
            // ↳ costruiamo dinamicamente la parte “barra di avanzamento”
            final String? dataEffettoTitoloStr = p['DATA_EFFETTO_TITOLO'];
            Widget progressSection = const SizedBox(); // di default niente

            if (dataEffettoTitoloStr != null &&
                dataEffettoTitoloStr.isNotEmpty) {
              // parsing della data (formato YYYY-MM-DD)
              final DateTime dataEffetto = DateTime.parse(dataEffettoTitoloStr);
              final DateTime oggi = DateTime.now();

              // prossima ricorrenza annuale di quella data
              DateTime prossimaRicorrenza = DateTime(
                oggi.year,
                dataEffetto.month,
                dataEffetto.day,
              );
              if (prossimaRicorrenza.isBefore(oggi)) {
                prossimaRicorrenza = DateTime(
                  oggi.year + 1,
                  dataEffetto.month,
                  dataEffetto.day,
                );
              }

              final int giorniTotali = prossimaRicorrenza
                  .subtract(Duration(days: 365))
                  .difference(prossimaRicorrenza)
                  .inDays
                  .abs(); // 365 o 366 in caso di anno bisestile
              final int giorniMancanti =
                  prossimaRicorrenza.difference(oggi).inDays.clamp(0, 365);
              final double progress = 1 - (giorniMancanti / giorniTotali);

              progressSection = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress, // 0 → appena iniziato, 1 → scade domani
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade300,
                    color: constants.COLORE_PRINCIPALE,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Mancano $giorniMancanti giorni alla prossima rata',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }

            // Ritorniamo l’intero contenuto come Column
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HtmlWidget(
                  '''
        <strong>Contraente:</strong> ${p['NOMINATIVO']}<br>
        <strong>N. Polizza:</strong> ${p['NUMERO_POLIZZA']}<br>
        <strong>Compagnia:</strong> ${p['DESC_COMPAGNIA']}<br>
        <strong>Ramo:</strong> ${p['DESC_RAMO']}<br>
        <strong>Prodotto:</strong> ${p['DESC_PRODOTTO']}<br>
        <strong>Frazionamento:</strong> ${p['FRAZIONAMENTO'] ?? '-'}<br>
        <strong>Data Ultima Copertura:</strong> ${formatDateIt(p['DATA_EFFETTO_ULTIMA_COPERTURA'])}<br>
        <strong>Prossima Scadenza:</strong> ${formatDateIt(p['DATA_EFFETTO_TITOLO'])}<br>
        <strong>Data Scadenza Contratto:</strong> ${formatDateIt(p['DATA_SCADENZA_CONTRATTO'])}<br>
        <strong>Stato Polizza:</strong> ${p['DESC_STATO_POLIZZA']}<br>
        ''',
                ),
                progressSection, // aggiunto solo se presente DATA_EFFETTO_TITOLO
              ],
            );
          }),
        ),
      ],
    );
  }
}
