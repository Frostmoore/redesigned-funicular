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
    var usernameAe = user['userData']['data']['result']['username'];
    var codiceFiscaleTty = user['userData']['data']['result']['cf'];

    // AssiEasy Request Lookup
    var lookupRequestAe = {
      'username': usernameAe,
      'codicefiscale': codiceFiscaleTty,
    };

    var headersAeLogin = {
      'chiave-hi': constants.chiaveHi,
      'Host': data['assiurl'] as String,
      'assi_secret': data['assisecret'] as String,
    };

    var urlAssieasyLookup = Uri.https(
      data['assiurl'],
      'assieasy/clienti/autenticazione/get_credenziali_utente',
    );

    var urlAssieasyLogin = Uri.https(
      data['assiurl'],
      '/assieasy/clienti/autenticazione/login',
    );

    var urlAssieasyPolizze = Uri.https(
      data['assiurl'],
      '/assieasy/clienti/polizze/get',
    );

    var urlAssieasyLogout = Uri.https(
      data['assiurl'],
      '/assieasy/clienti/autenticazione/logout',
    );

    var lookupAe = await http.post(
      urlAssieasyLookup,
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
      urlAssieasyLogin,
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
    String host = data['assiurl'];
    String secret = data['assisecret'];
    var headersAePolizze = {
      'chiave-hi': constants.chiaveHi,
      'Accept': '*/*',
      'Cache-Control': 'no-cache',
      'Host': host,
      'Accept-Encoding': 'gzip, deflate, br',
      'Connection': 'keep-alive',
      'assi_secret': secret,
      'token': tokenAe,
    };
    var polizzeAe = await http.post(
      urlAssieasyPolizze,
      headers: headersAePolizze,
      body: polizzeRequestAe,
    );
    var polizzeAeParsed = jsonDecode(polizzeAe.body) as Map;
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
  }

  @override
  Widget build(BuildContext context) {
    final Future _polizze = _getPolizze();
    return FutureBuilder(
      future: _polizze,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
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
                                      image: AssetImage(
                                          'lib/assets/polizze_immagine.png'),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 18, 8, 8),
                                    child: Text(
                                      "Polizza n. " +
                                          snapshot.data['data'][i]
                                              ['NUMERO_POLIZZA'],
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
