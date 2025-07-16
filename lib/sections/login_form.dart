import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

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
  bool _loading = false;
  bool _passwordVisible = false;
  String? _errorMessage;

  // CONFIGURA QUI I TUOI DATI BASE (token/id/endpoint)
  final String endpoint =
      'https://www.hybridandgogsv.it/res/api/v1/auth.php'; // Cambia!
  final String idAgenzia = constants.ID; // O come preferisci prenderlo
  final String tokenAgenzia = constants.TOKEN; // O come preferisci prenderlo

  Future<void> clearAll() async {
    final storage = FlutterSecureStorage();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await storage.deleteAll();
    await prefs.clear();
  }

  Future<void> _sendData(BuildContext context) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final storage = FlutterSecureStorage();

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id": idAgenzia,
          "token": tokenAgenzia,
          "username": _username.text.trim(),
          "password": _password.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Controllo http_response_code
        final String code = data['http_response_code']?.toString() ?? '';
        if (code == '1' &&
            data['result'] != null &&
            data['result'] is Map<String, dynamic>) {
          final user = data['result'];

          // Questo è il vero username restituito dal backend!
          final String usernameFromApi = user['username'] ?? '';
          print('[USERNAME]' + usernameFromApi);
          await storage.write(key: 'username', value: usernameFromApi);
          await prefs.setString('username', usernameFromApi);
          await prefs.setBool('isAlreadyLogged', true);

          // Salva altri dati, se vuoi:
          await storage.write(key: 'user_id', value: user['id'] ?? '');
          await storage.write(key: 'email', value: user['email'] ?? '');
          await storage.write(key: 'nome', value: user['nome'] ?? '');
          await storage.write(key: 'cognome', value: user['cognome'] ?? '');

          // Player ID, se ti serve
          if (data['playerid'] != null) {
            await storage.write(
                key: 'playerid', value: data['playerid'].toString());
          }

          // (FACOLTATIVO) Salva la password SOLO se ti serve DAVVERO (evita per motivi di sicurezza)
          await storage.write(key: 'password', value: _password.text);

          constants.userStatus = 1;
          widget.logParent();
        } else {
          // Errore backend (username/pass errati, utente non attivo, ecc)
          setState(() {
            _errorMessage = data['result']?.toString() ?? "Errore sconosciuto.";
            _loading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = "Errore HTTP: ${response.statusCode}";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Errore di connessione: $e";
        _loading = false;
      });
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              constants.SPACER,
              const Center(
                child: Text(
                  "REGISTRAZIONE UTENTE",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Center(
                child: Text(
                  "Se è il tuo primo accesso, iscriviti ora:",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              constants.SPACER_MEDIUM,
              ElevatedButton(
                onPressed: () {
                  constants.userStatus = 2;
                  widget.logParent();
                },
                style: constants.STILE_BOTTONE,
                child: const Text(
                  "ISCRIVITI!",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              constants.SPACER,
              constants.SPACER,
              constants.SPACER,
              const Center(
                child: Text(
                  "ACCESSO UTENTE",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Center(
                child: Text(
                  "Accedi ora alla tua area riservata.",
                  textAlign: TextAlign.center,
                ),
              ),
              constants.SPACER_MEDIUM,
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Username, e-mail o Codice Fiscale",
                        labelStyle: TextStyle(
                          color: Colors.black87,
                          fontSize: 17,
                          fontFamily: 'AvenirLight',
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                        ),
                      ),
                      enableSuggestions: true,
                      controller: _username,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Per proseguire, riempi questo campo.';
                        }
                        return null;
                      },
                    ),
                    constants.SPACER_MEDIUM,
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: const TextStyle(
                          color: Colors.black87,
                          fontSize: 17,
                          fontFamily: 'AvenirLight',
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey[700],
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !_passwordVisible,
                      enableSuggestions: false,
                      autocorrect: false,
                      controller: _password,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Per proseguire, riempi questo campo.';
                        }
                        return null;
                      },
                    ),
                    constants.SPACER_MEDIUM,
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: _loading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _sendData(context);
                                }
                              },
                              style: constants.STILE_BOTTONE,
                              child: const Text(
                                "ACCEDI!",
                                style: TextStyle(fontWeight: FontWeight.bold),
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
                  "<p style='text-align:center;text-decoration:underline;color:blue;'>Password Dimenticata?</p>",
                ),
              ),
              constants.SPACER,
            ],
          ),
        ),
      ),
    );
  }
}
