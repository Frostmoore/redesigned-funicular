import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:Assidim/sections/register_form.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'dart:developer';

class LoginForm extends StatefulWidget {
  final data;
  final Function() logParent;

  const LoginForm({super.key, required this.data, required this.logParent});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  var Username;
  var Password;

  @override
  Widget build(BuildContext context) {
    clearAll() async {
      final storage = FlutterSecureStorage();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await storage.deleteAll();
      await prefs.remove('hasGivenPermissionToUseBiometrics');
      await prefs.remove('alreadyLoggedInWithBiometrics');
      await prefs.remove('isAlreadyLogged');
      await prefs.clear();
    }

    // clearAll();
    return Container(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              constants.SPACER,
              const Center(
                child: Text(
                  "ACCESSO UTENTE",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Center(
                child: Text(
                  "Accedi ora alla tua area riservata.",
                  textAlign: TextAlign.center,
                ),
              ),
              constants.SPACER,
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                        onSaved: (value) {
                          Username = value;
                        },
                        decoration: const InputDecoration(
                          labelText: "Username, e-mail o Codice Fiscale",
                          labelStyle: TextStyle(color: Colors.black87, fontSize: 17, fontFamily: 'AvenirLight'),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0)),
                        ),
                        enableSuggestions: true,
                        controller: _username,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Per proseguire, riempi questo campo.';
                          }
                          return null;
                        }),
                    constants.SPACER_MEDIUM,
                    TextFormField(
                        onSaved: (value) {
                          Password = value;
                        },
                        decoration: const InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(color: Colors.black87, fontSize: 17, fontFamily: 'AvenirLight'),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0)),
                        ),
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        controller: _password,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Per proseguire, riempi questo campo.';
                          }
                          return null;
                        }),
                    constants.SPACER_MEDIUM,
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _sendData(context);
                            // constants.userStatus = 1;
                            // widget.logParent();
                          }
                        },
                        style: constants.STILE_BOTTONE,
                        child: const Text(
                          "ACCEDI!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  constants.userStatus = 99;
                  widget.logParent();
                },
                child: const HtmlWidget(
                    "<p style='text-align:center;text-decoration:underline;color:blue;'>Password Dimenticata?</p>"),
              ),
              constants.SPACER_MEDIUM,
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  "Se non l'hai ancora fatto, effettua la registrazione per accedere alle funzionalità avanzate dell'app.",
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  constants.userStatus = 2;
                  widget.logParent();
                },
                style: constants.STILE_BOTTONE,
                child: const Text(
                  "ISCRIVITI!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendData(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final storage = FlutterSecureStorage();
    await storage.write(key: 'username', value: _username.text);
    await storage.write(key: 'password', value: _password.text);
    constants.userStatus = 1;
    widget.logParent();
  }
}
