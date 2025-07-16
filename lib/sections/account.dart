// account.dart

import 'dart:convert';
import 'package:Assidim/sections/account/gestione_consensi.dart';
import 'package:Assidim/sections/login_form.dart';
import 'package:Assidim/sections/responses/login_fallito.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:Assidim/sections/account/account_header.dart';
import 'package:Assidim/sections/account/account_polizze.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class AccountPage extends StatefulWidget {
  final data;
  final Function() logParent;
  const AccountPage({super.key, required this.data, required this.logParent});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final LocalAuthentication auth = LocalAuthentication();
  late SharedPreferences prefs;
  final storage = FlutterSecureStorage();
  late Future<Map> _getAuthentication;

  @override
  void initState() {
    super.initState();
    _getAuthentication = _initPrefsAndAuthenticate();
  }

  void refresh() {
    setState(() {
      _getAuthentication = _initPrefsAndAuthenticate();
    });
  }

  Future<Map> _initPrefsAndAuthenticate() async {
    prefs = await SharedPreferences.getInstance();
    // Qui proviamo sempre a loggare, anche se non sei loggato.
    return await authenticate();
  }

  Future<bool> didAuthenticate() async {
    if (!await auth.canCheckBiometrics) return false;
    bool canAuthenticate =
        await auth.isDeviceSupported() && await auth.canCheckBiometrics;

    if (!canAuthenticate) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Biometria non disponibile'),
          content: Text(
              'Sul tuo dispositivo non è configurata un\'autenticazione biometrica.'),
          actions: [
            TextButton(
              child: Text('Ok'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return false;
    }
    return await auth.authenticate(
      localizedReason:
          'Accedi con i tuoi dati biometrici per semplificare il processo di login.',
      options: const AuthenticationOptions(biometricOnly: true),
    );
  }

  Future<Map> login() async {
    // Leggi le credenziali
    var username = await storage.read(key: 'username');
    var password = await storage.read(key: 'password');

    // Se mancano, login impossibile
    if (username == null ||
        username.isEmpty ||
        password == null ||
        password.isEmpty) {
      return {'result': 'error', 'data': null, 'userStatus': 98};
    }

    var url = Uri.https(constants.PATH, constants.ENDPOINT_LOG);
    var request = {
      'id': constants.ID,
      'token': constants.TOKEN,
      'username': username,
      'password': password,
    };

    var response = await http.post(
      url,
      headers: {'Content-Type': 'Application/json'},
      body: jsonEncode(request),
    );

    var responseParsed = jsonDecode(response.body) as Map;
    var userStatus = responseParsed['http_response_code'];

    if (userStatus == '1') {
      final externalUserId = responseParsed['playerid'];

      try {
        print('🔄 Login OneSignal con externalUserId: $externalUserId');
        await OneSignal.login(externalUserId);
        await Future.delayed(Duration(milliseconds: 500));

        final sub = OneSignal.User.pushSubscription;
        final token = sub.token;
        final currentPlayerId = sub.id;
        final optedIn = sub.optedIn;

        if (token == null || currentPlayerId == null || optedIn == false) {
          print(
              '❌ OneSignal non attivo: token=$token, id=$currentPlayerId, optedIn=$optedIn');
          print('🔁 Eseguo logout e nuovo login...');
          await OneSignal.logout();
          await Future.delayed(Duration(milliseconds: 500));
          await OneSignal.login(externalUserId);
        } else {
          print(
              '✅ OneSignal attivo: token=$token | playerId=$currentPlayerId | optedIn=$optedIn');
        }
      } catch (e) {
        print('💥 Errore OneSignal: $e');
      }

      return {'result': 'ok', 'data': responseParsed, 'userStatus': 1};
    } else {
      constants.userStatus = userStatus;
      widget.logParent();
      return {'result': 'error', 'data': responseParsed, 'userStatus': 100};
    }
  }

  Future<Map> authenticate() async {
    // Se non sei loggato, mostra il form di login.
    final prefs = await SharedPreferences.getInstance();
    var username = await storage.read(key: 'username');
    var password = await storage.read(key: 'password');

    if (!(prefs.getBool('isAlreadyLogged') ?? false) ||
        username == null ||
        username.isEmpty ||
        password == null ||
        password.isEmpty) {
      // Non autenticato, niente login automatico
      return {};
    }

    // Se c'è consenso biometrico, segui la trafila biometrica
    if (prefs.containsKey('hasGivenPermissionToUseBiometrics')) {
      if (prefs.getBool('hasGivenPermissionToUseBiometrics') == true) {
        if (prefs.containsKey('alreadyLoggedInWithBiometrics')) {
          if (await didAuthenticate()) {
            Map userData = await login();
            return {'result': 'ok', 'userData': userData};
          } else {
            Map userData = await login();
            await storage.deleteAll();
            clearAll();
            return {'result': 'error', 'userData': userData};
          }
        } else {
          Map userData = await login();
          if (await didAuthenticate()) {
            prefs.setBool('alreadyLoggedInWithBiometrics', true);
          } else {
            await storage.deleteAll();
            clearAll();
            return {'result': 'error', 'userData': userData};
          }
          return {
            'result': 'ok',
            'userData': {'http_status_code': 100}
          };
        }
      } else {
        Map userData = await login();
        return {'result': 'ok', 'userData': userData};
      }
    } else {
      Map userData = await login();
      showDialog(
        context: context,
        builder: (context) {
          return Theme(
            data:
                Theme.of(context).copyWith(dialogBackgroundColor: Colors.white),
            child: AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              title: Text('Autenticazione Biometrica'),
              content: HtmlWidget(
                  '<p style="text-align:center;">Vuoi consentire a questa app di autenticarti tramite <strong>impronta digitale</strong> o <strong>riconoscimento facciale</strong> per semplificare il procedimento di log-in?<br>I tuoi dati non verranno <strong>mai trasmessi</strong> fuori dal tuo dispositivo.</p>'),
              actions: [
                ElevatedButton(
                  style: constants.STILE_BOTTONE,
                  onPressed: () async {
                    prefs.setBool('hasGivenPermissionToUseBiometrics', true);
                    Navigator.of(context).pop();
                    final success = await didAuthenticate();
                    if (success) {
                      await login();
                      prefs.setBool('alreadyLoggedInWithBiometrics', true);
                      prefs.setBool('isAlreadyLogged', true);
                      refresh();
                    }
                  },
                  child: Text('Sì, Acconsento'),
                ),
                ElevatedButton(
                  style: constants.STILE_BOTTONE_ROSSO,
                  onPressed: () async {
                    await prefs.setBool(
                        'hasGivenPermissionToUseBiometrics', false);
                    await prefs.setBool('isAlreadyLogged', true);
                    Navigator.of(context).pop();
                    refresh();
                  },
                  child: Text('No, non mostrare più'),
                ),
              ],
            ),
          );
        },
      );
      return {'result': 'ok', 'userData': userData};
    }
  }

  clearAll() async {
    await storage.deleteAll();
    await prefs.remove('isAlreadyLogged');
    await prefs.remove('hasGivenPermissionToUseBiometrics');
    await prefs.remove('alreadyLoggedInWithBiometrics');
    await prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Image.asset('lib/assets/polizze_header.jpg',
                fit: BoxFit.fitWidth),
          ),
          FutureBuilder<Map>(
            future: _getAuthentication,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: constants.COLORE_PRINCIPALE,
                  ),
                );
              }

              // Se non ci sono dati → mostra il login form
              final raw = snapshot.data ?? {};
              final Map<String, dynamic> userInfo = (raw['userData']?['data']
                      ?['result'] is Map)
                  ? Map<String, dynamic>.from(raw['userData']['data']['result'])
                  : <String, dynamic>{};

              if (userInfo.isEmpty) {
                // Passa la funzione "refresh" per forzare il reload dopo login
                return LoginForm(
                  data: widget.data,
                  logParent: refresh,
                );
              }

              // Altrimenti, sei loggato: mostra la pagina utente
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    AccountHeader(data: widget.data, userData: userInfo),
                    constants.SPACER,
                    AccountPolizze(data: widget.data, userData: userInfo),
                    constants.SPACER,
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
