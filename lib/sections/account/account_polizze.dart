import 'package:accordion/accordion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:developer';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/sections/responses/nessun_risultato.dart';

class AccountPolizze extends StatefulWidget {
  final data;
  final userData;
  const AccountPolizze({super.key, required this.data, required this.userData});

  @override
  State<AccountPolizze> createState() => _AccountPolizzeState();
}

class _AccountPolizzeState extends State<AccountPolizze> {
  Future _getPolizze() async {
    //
    var data = widget.data;
    var user = widget.userData;

    // AssiEasy Data
    // inspect(user);
    var usernameAe = user['userData']['data']['result']['email'];
    // var passwordAe = user['userData']['data']['result']['password'];
    var codiceFiscaleTty = user['userData']['data']['result']['cf'];
    //var usernameAe = 'giovannimoncelsi@gmail.com';
    //var passwordAe = 'test';

    // AssiEasy Request Lookup
    var lookupRequestAe = {
      'username': usernameAe,
      'codicefiscale': codiceFiscaleTty,
    };

    var headersAeLogin = {
      'chiave-hi': constants.chiaveHi,
      'Host': constants.assiEasyPath,
      'assi_secret': constants.assiSecret,
    };

    var lookupAe = await http.post(
      constants.urlAssiEasyLookup,
      headers: headersAeLogin,
      body: lookupRequestAe,
    );

    var lookupAeParsed = jsonDecode(lookupAe.body) as Map;
    // print(lookupAeParsed);
    var passwordAe = lookupAeParsed['data']['PASSWORD'] as String;

    // AssiEasy Request Login
    var loginRequestAe = {
      'username': usernameAe,
      'password': passwordAe,
    };

    // print(headersAeLogin);
    // print(loginRequestAe);
    var loginAe = await http.post(
      constants.urlAssiEasyLogin,
      headers: headersAeLogin,
      body: loginRequestAe,
    );
    // inspect(loginAe.body);
    var loginAeParsed = jsonDecode(loginAe.body) as Map;
    var tokenAe = loginAeParsed['data']['TOKEN'] as String;
    var refreshTokenAe = loginAeParsed['data']['REFRESH_TOKEN'];

    // AssiEasy Request Polizze
    var polizzeRequestAe = {
      'ID_POLIZZA': '0',
      'SOLO_VIVE': '1',
      'sorts[1][column]': 'NUMERO_POLIZZA',
      'sorts[1][order]': 'DESC',
    };
    var headersAePolizze = {
      'chiave-hi': constants.chiaveHi,
      'Accept': '*/*',
      'Cache-Control': 'no-cache',
      'Host': 'assidim.assieasy.com',
      'Accept-Encoding': 'gzip, deflate, br',
      'Connection': 'keep-alive',
      'assi_secret': constants.assiSecret,
      'assi_secret_ics': 'a0ceef94baee08287e267b4f4037b681',
      'token': tokenAe,
    };
    var polizzeAe = await http.post(
      constants.urlAssiEasyPolizze,
      headers: headersAePolizze,
      body: polizzeRequestAe,
    );
    var polizzeAeParsed = jsonDecode(polizzeAe.body) as Map;
    // inspect(polizzeAe);
    // print(polizzeAeParsed);
    return polizzeAeParsed;

    // TTY CREO
    String getHashOfNow() {
      final unixTimestamp = DateTime.now().millisecondsSinceEpoch;
      final timestampString = unixTimestamp.toString();
      final bytes = utf8.encode(timestampString);
      final digest = sha512.convert(bytes);
      return digest.toString();
    }

    var requestTty = {
      'codice_fiscale': codiceFiscaleTty,
      'licenza_cliente_id': constants.licenzaClienteId,
      'azienda_id': constants.aziendaId,
      'agenzia_id': constants.agenziaId,
    };

    var headersTty = {
      'X-Sintesi-ClientId': constants.ttyCreoClientId,
      'X-Sintesi-ClientSecret': constants.ttyCreoClientSecret,
      'X-Sintesi-Apikey': constants.ttyCreoApiKey + getHashOfNow(),
    };

    // print('ciao');
    var responseTty = await http.post(
      constants.urlTtyCreoPolizze,
      headers: headersTty,
      body: jsonEncode(requestTty),
    );

    var polizzeTtyParsed = jsonDecode(responseTty.body) as Map;
    // inspect(polizzeTtyParsed);
    // return polizzeTtyParsed;
  }

  @override
  Widget build(BuildContext context) {
    final Future _polizze = _getPolizze();
    return FutureBuilder(
      future: _polizze,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // inspect(snapshot);
          // inspect(snapshot.error);
          // print(snapshot.data);
          if (snapshot.hasData) {
            // print(snapshot.data['data'][0]['ID_POLIZZA']);
            // print(snapshot.data['totalCount']);
            return Column(
              children: [
                for (var i = 0; i < snapshot.data['totalCount']; i++)
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Accordion(
                          headerBorderWidth: 1,
                          headerBorderColor: Colors.transparent,
                          headerBorderColorOpened: Colors.transparent,
                          headerBackgroundColor: Colors.transparent,
                          headerBackgroundColorOpened: Colors.transparent,
                          contentBorderColor: Colors.transparent,
                          contentBackgroundColor: Colors.transparent,
                          contentHorizontalPadding: 0,
                          disableScrolling: true,
                          headerPadding: const EdgeInsets.all(0),
                          children: [
                            AccordionSection(
                              rightIcon: const Icon(
                                Icons.arrow_drop_down_rounded,
                                size: 45,
                              ),
                              header: SizedBox(
                                // width: width - 16,
                                height: 70,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage('lib/assets/polizze_immagine.png'),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(8, 18, 8, 8),
                                    child: Text(
                                      "Polizza n. " + snapshot.data['data'][i]['NUMERO_POLIZZA'],
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              content: Column(
                                children: [
                                  HtmlWidget(
                                    """
                                    <strong>Contraente:</strong> ${snapshot.data['data'][i]['NOMINATIVO']}<br>
                                    <strong>Compagnia:</strong> ${snapshot.data['data'][i]['DESC_COMPAGNIA']}<br>
                                    <strong>Ramo:</strong> ${snapshot.data['data'][i]['DESC_RAMO']}<br>
                                    <strong>Prodotto:</strong> ${snapshot.data['data'][i]['DESC_PRODOTTO']}<br>
                                    <strong>Frazionamento:</strong> ${snapshot.data['data'][i]['FRAZIONAMENTO']}<br>
                                    <strong>Data Decorrenza:</strong> ${snapshot.data['data'][i]['DATA_EFFETTO_ULTIMA_COPERTURA']}<br>
                                    <strong>Data Scadenza:</strong> ${snapshot.data['data'][i]['DATA_SCADENZA_CONTRATTO']}<br>
                                    <strong>Stato Polizza:</strong> ${snapshot.data['data'][i]['DESC_STATO_POLIZZA']}<br>
                                    """,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // child: Container(
                    //   decoration: BoxDecoration(
                    //     border: Border.all(color: Colors.black45),
                    //     borderRadius: const BorderRadius.all(Radius.circular(5)),
                    //   ),
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(16.0),
                    //     child: Column(
                    //       children: [
                    //         Text("Compagnia: " + snapshot.data['data'][i]['DESC_COMPAGNIA']),
                    //         Text("Numero Polizza: " + snapshot.data['data'][i]['ID_POLIZZA']),
                    //         Text("Scadenza: " + snapshot.data['data'][i]['DATA_SCADENZA_CONTRATTO']),
                    //         Text("Ramo: " + snapshot.data['data'][i]['DESC_RAMO']),
                    //         Text("Frazionamento: " + snapshot.data['data'][i]['FRAZIONAMENTO']),
                    //         Text("Premio: " + snapshot.data['data'][i]['PREMIO_NETTO']),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ),
              ],
            );
          } else {
            return const NessunRisultato();
          }
        } else {
          return const CircularProgressIndicator(
            color: constants.COLORE_PRINCIPALE,
          );
        }
      },
    );
  }
}
