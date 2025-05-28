// import 'dart:developer';
// import 'package:accordion/accordion.dart';
import 'dart:convert';

import 'package:Assidim/sections/account/gestione_consensi.dart';
import 'package:Assidim/sections/responses/login_fallito.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
// import 'package:Assidim/sections/chiamata_rapida.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:intl/intl.dart';import 'package:Assidim/assets/constants.dart' as constants;
import 'package:http/http.dart' as http;
// import 'dart:convert' as convert;
//import 'package:notification_permissions/notification_permissions.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:developer';
import 'package:Assidim/sections/account/account_header.dart';
import 'package:Assidim/sections/account/account_polizze.dart';
import 'package:Assidim/sections/account/gear_menu.dart';
import 'package:Assidim/assets/constants.dart' as constants;
// import 'package:http/http.dart' as http;
// import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
// import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class AccountPage extends StatefulWidget {
  final data;
  final Function() logParent;
  const AccountPage({
    super.key,
    required this.data,
    required this.logParent,
  });

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> didAuthenticate() async {
    bool _canCheckBiometrics = await auth.canCheckBiometrics;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var storage = FlutterSecureStorage();
    if (_canCheckBiometrics) {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Accedi con i tuoi dati biometrici per semplificare il processo di login.',
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );
      if (didAuthenticate) {
        await prefs.setBool('isAlreadyLogged', true);
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var storage = FlutterSecureStorage();
    if (await storage.containsKey(key: 'username')) {
      var username = await storage.read(key: 'username');
      var password = await storage.read(key: 'password');
      // LOGIN
      var url = Uri.https(
        constants.PATH,
        constants.ENDPOINT_LOG,
      );

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
      // inspect(response);
      // print(response.statusCode);
      // print(responseParsed['http_response_code']);
      var userStatus = responseParsed['http_response_code'];
      if (userStatus == '1') {
        // print(responseParsed['http_response_code']);
        OneSignal.login(responseParsed['playerid']);
        return {'result': 'ok', 'data': responseParsed, 'userStatus': 1};
      } else {
        constants.userStatus = userStatus;
        widget.logParent();
        return {'result': 'error', 'data': responseParsed, 'userStatus': 100};
      }
    } else {
      // constants.userStatus = 0;
      // widget.logParent();
      return {'result': 'error', 'data': null, 'userStatus': 98};
    }
  }

  Future<Map> authenticate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final storage = FlutterSecureStorage();
    if (prefs.containsKey('hasGivenPermissionToUseBiometrics')) {
      if (prefs.getBool('hasGivenPermissionToUseBiometrics') == true) {
        if (prefs.containsKey('alreadyLoggedInWithBiometrics')) {
          // ASK FOR LOCAL AUTHENTICATION, NOT FOR PERMISSION
          if (await didAuthenticate()) {
            Map userData = await login();
            return {'result': 'ok', 'userData': userData};
          } else {
            Map userData = await login();
            storage.deleteAll();
            clearAll();
            return {'result': 'error', 'userData': userData};
          }
        } else {
          Map userData = await login();
          if (await didAuthenticate()) {
            Map userData = await login();
            prefs.setBool('alreadyLoggedInWithBiometrics', true);
          } else {
            Map userData = await login();
            storage.deleteAll();
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
        // storage.deleteAll();
        // clearAll();
        return {'result': 'ok', 'userData': userData};
      }
    } else {
      Map userData = await login();
      // ASK FOR PERMISSION
      showDialog(
        context: context,
        builder: (context) {
          return Theme(
            data: Theme.of(context).copyWith(dialogBackgroundColor: Colors.white),
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
                    Map userData = await login();
                    Navigator.of(context).pop();
                    auth.authenticate(
                      localizedReason: 'Accedi con i tuoi dati biometrici per semplificare il processo di login.',
                      options: AuthenticationOptions(
                        biometricOnly: true,
                      ),
                    );
                    await prefs.setBool('isAlreadyLogged', true);
                    prefs.setBool('alreadyLoggedInWithBiometrics', true);
                  },
                  child: Text('Sì, Acconsento'),
                ),
                ElevatedButton(
                  style: constants.STILE_BOTTONE_ROSSO,
                  onPressed: () async {
                    await prefs.setBool('hasGivenPermissionToUseBiometrics', false);
                    await prefs.setBool('isAlreadyLogged', true);
                    // Map userData = await login();
                    // storage.deleteAll();
                    // clearAll();
                    Navigator.of(context).pop();
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
    final storage = FlutterSecureStorage();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await storage.deleteAll();
    await prefs.remove('isAlreadyLogged');
    await prefs.remove('hasGivenPermissionToUseBiometrics');
    await prefs.remove('alreadyLoggedInWithBiometrics');
    await prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    // clearAll();
    final Future _getAuthentication = authenticate();
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Image(
              image: AssetImage('lib/assets/polizze_header.jpg'),
              fit: BoxFit.fitWidth,
            ),
          ),
          FutureBuilder(
            future: _getAuthentication,
            builder: (context, snapshot) {
              // print(snapshot);
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          AccountHeader(data: widget.data, userData: snapshot.data),
                          constants.SPACER,
                          AccountPolizze(data: widget.data, userData: snapshot.data),
                          constants.SPACER,
                          // ElevatedButton(
                          //   style: constants.STILE_BOTTONE,
                          //   onPressed: () {
                          //     widget.logParent();
                          //     constants.userStatus = 0;
                          //     clearAll();
                          //   },
                          //   child: Text('Log-Out'),
                          // ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return LoginFallito(data: widget.data, logParent: widget.logParent);
                }
              } else {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: constants.COLORE_PRINCIPALE),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
