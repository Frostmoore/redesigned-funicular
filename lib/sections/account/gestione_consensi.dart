import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:url_launcher/url_launcher.dart';
// import 'package:Assidim/sections/responses/nessun_risultato.dart';
import 'package:Assidim/sections/account/lista_consensi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GestioneConsensi extends StatefulWidget {
  final data;
  const GestioneConsensi({super.key, required this.data});

  @override
  State<GestioneConsensi> createState() => _GestioneConsensiState();
}

class _GestioneConsensiState extends State<GestioneConsensi> {
  Future<Map> _getConsensi() async {
    final storage = FlutterSecureStorage();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = widget.data;
    var consensi;
    var path = constants.PATH;
    var endpoint = constants.ENDPOINT_CONS;
    var isLoggedIn = prefs.getBool('isAlreadyLogged');

    return {'isLoggedIn': isLoggedIn};
  }

  refresh() {
    setState(() {});
  }

  clearAll() async {
    final storage = FlutterSecureStorage();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isAlreadyLogged');
    await storage.deleteAll();
    await prefs.remove('hasGivenPermissionToUseBiometrics');
    await prefs.remove('alreadyLoggedInWithBiometrics');
    await prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    final Future _consensi = _getConsensi();
    return FutureBuilder(
      future: _consensi,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // print(snapshot.data['isLoggedIn']);
          if (snapshot.hasData) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    HtmlWidget(
                      "<h2 style='text-align: center;'>GESTISCI LE IMPOSTAZIONI</h2>",
                    ),
                    constants.SPACER,
                    snapshot.data['isLoggedIn'] == true
                        ? ListaConsensi(data: widget.data)
                        : Container(),
                    constants.SPACER_MEDIUM,
                    HtmlWidget(
                        '<h3 style="text-align:center;">Rimozione dati Applicazione</h3>'),
                    constants.SPACER_MEDIUM,
                    HtmlWidget(
                        '<p style="text-align:center;"><strong>ATTENZIONE:</strong> Cliccando su questo tasto, effettuerai il log-out dal tuo account, e tutte le informazioni che sono state salvate dall\'applicazione verranno cancellate dal tuo dispositivo.</p>'),
                    constants.SPACER_MEDIUM,
                    ElevatedButton(
                      style: constants.STILE_BOTTONE_ROSSO,
                      onPressed: () {
                        constants.userStatus = 0;
                        clearAll();
                        refresh();
                      },
                      child: Text('CANCELLA!'),
                    ),
                    constants.SPACER,
                    ElevatedButton(
                      style: constants.STILE_BOTTONE_ROSSO,
                      onPressed: () {
                        Uri url = Uri.parse(
                            'https://hybridandgogsv.it/delete_account.php');
                        launchUrl(url);
                      },
                      child: Text('Rimuovi il tuo Account!'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    constants.SPACER,
                    HtmlWidget(
                      "<h2 style='text-align: center;'>GESTISCI LE IMPOSTAZIONI</h2>",
                    ),
                    constants.SPACER,
                    snapshot.data['isLoggedIn'] == true
                        ? ListaConsensi(data: widget.data)
                        : Container(),
                    constants.SPACER_MEDIUM,
                    HtmlWidget(
                        '<h3 style="text-align:center;">Rimozione dati Applicazione</h3>'),
                    constants.SPACER_MEDIUM,
                    HtmlWidget(
                        '<p style="text-align:center;"><strong>ATTENZIONE:</strong> Cliccando su questo tasto, effettuerai il log-out dal tuo account, e tutte le informazioni che sono state salvate dall\'applicazione verranno cancellate dal tuo dispositivo.</p>'),
                    constants.SPACER_MEDIUM,
                    constants.SPACER,
                    ElevatedButton(
                      style: constants.STILE_BOTTONE_ROSSO,
                      onPressed: () {
                        constants.userStatus = 0;
                        clearAll();
                        refresh();
                      },
                      child: Text('CANCELLA!'),
                    ),
                    constants.SPACER,
                    ElevatedButton(
                      style: constants.STILE_BOTTONE_ROSSO,
                      onPressed: () {
                        Uri url = Uri.parse(
                            'https://hybridandgogsv.it/delete_account.php');
                        launchUrl(url);
                      },
                      child: Text('Rimuovi il tuo Account!'),
                    ),
                  ],
                ),
              ),
            );
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
