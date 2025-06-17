import 'package:accordion/accordion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    final Map<String, dynamic> data = Map<String, dynamic>.from(widget.data);
    final Map<String, dynamic> user =
        Map<String, dynamic>.from(widget.userData);

    final usernameAe = user['username']?.toString();
    final codiceFiscaleTty = user['cf']?.toString();

    /* const usernameAe = 'chiarapazzelli6212@gmail.com';
    const codiceFiscaleTty = 'PZZCHR01B46I156G'; */

    final assiurl = data['assiurl'] as String;
    final assisecret = data['assisecret'] as String;

    // header base
    final Map<String, String> headersBase = {
      'chiave-hi': constants.chiaveHi,
      'Host': assiurl,
      'assi_secret': assisecret,
    };

    // URL
    final urlLookup = Uri.https(
        assiurl, 'assieasy/clienti/autenticazione/get_credenziali_utente');
    final urlLogin =
        Uri.https(assiurl, 'assieasy/clienti/autenticazione/login');
    final urlPolizze = Uri.https(assiurl, 'assieasy/clienti/polizze/get');
    final urlTitoli = Uri.https(assiurl, 'assieasy/clienti/titoli/get');

    // 1) lookup → password
    final lookupRes = await http.post(urlLookup,
        headers: headersBase,
        body: {'username': usernameAe, 'codicefiscale': codiceFiscaleTty});
    final passwordAe = jsonDecode(lookupRes.body)['data']['PASSWORD'] as String;

    // 2) login → token
    final loginRes = await http.post(urlLogin,
        headers: headersBase,
        body: {'username': usernameAe, 'password': passwordAe});
    final tokenAe = jsonDecode(loginRes.body)['data']['TOKEN'] as String;

    // header autenticato
    final headersAuthed = {
      ...headersBase,
      'Accept': '*/*',
      'token': tokenAe,
    };

    // 3) polizze
    final polizzeRes =
        await http.post(urlPolizze, headers: headersAuthed, body: {
      'ID_POLIZZA': '0',
      'SOLO_VIVE': '1',
      'sorts[1][column]': 'NUMERO_POLIZZA',
      'sorts[1][order]': 'DESC',
    });
    final polizzeRaw = (jsonDecode(polizzeRes.body)['data'] as List<dynamic>);
    final polizzeList = polizzeRaw.cast<Map<String, dynamic>>();

    // 4) titoli (solo DATA_EFFETTO, filtrati per ID_POLIZZA)
    final titoliRes = await http
        .post(urlTitoli, headers: headersAuthed, body: {'STATO_TITOLO': '1'});
    final titoliRaw = (jsonDecode(titoliRes.body)['data'] as List<dynamic>);
    final titoliById = <String, String?>{};
    for (final t in titoliRaw) {
      final id = t['ID_POLIZZA']?.toString();
      final dataE = t['DATA_EFFETTO'];
      if (id != null) titoliById[id] = dataE;
    }

    // 5) merge
    return polizzeList.map((p) {
      final idPol = p['ID_POLIZZA']?.toString();
      return {...p, 'DATA_EFFETTO_TITOLO': titoliById[idPol]};
    }).toList();
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
    if (dataEffettoTitoloStr == null || dataEffettoTitoloStr.isEmpty) {
      return const SizedBox();
    }
    try {
      final DateTime dataScadenza = DateTime.parse(dataEffettoTitoloStr);
      final DateTime oggi = DateTime.now();
      final giorniMancanti = dataScadenza.difference(oggi).inDays;
      if (giorniMancanti <= 10 && giorniMancanti >= 0) {
        return Container(
          margin: const EdgeInsets.only(left: 6),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'In scadenza',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        );
      }
    } catch (_) {}
    return const SizedBox();
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
        <strong>Data Decorrenza:</strong> ${formatDateIt(p['DATA_EFFETTO_ULTIMA_COPERTURA'])}<br>
        <strong>Data Scadenza Titolo:</strong> ${formatDateIt(p['DATA_EFFETTO_TITOLO'])}<br>
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
