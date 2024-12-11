import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:Assidim/sections/register_form.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class PasswordDimenticata extends StatefulWidget {
  final data;
  final Function() logParent;

  const PasswordDimenticata(
      {super.key, required this.data, required this.logParent});

  @override
  State<PasswordDimenticata> createState() => _PasswordDimenticataState();
}

class _PasswordDimenticataState extends State<PasswordDimenticata> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codiceFiscale = TextEditingController();
  var codiceFiscale;

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
                  "PASSWORD DIMENTICATA",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Center(
                child: HtmlWidget(
                  "<p style='text-align:center;'>Inserisci il tuo Codice Fiscale e ti invieremo un link per reimpostare la tua password.</p>",
                ),
              ),
              constants.SPACER,
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                        onSaved: (value) {
                          codiceFiscale = value;
                        },
                        decoration: const InputDecoration(
                          labelText: "Codice Fiscale",
                          labelStyle: TextStyle(
                              color: Colors.black87,
                              fontSize: 17,
                              fontFamily: 'AvenirLight'),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1.0)),
                        ),
                        controller: _codiceFiscale,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Per proseguire, riempi questo campo.';
                          }
                          final checkCFRegExp = RegExp(
                            r"^(?:[A-Z][AEIOU][AEIOUX]|[AEIOU]X{2}|[B-DF-HJ-NP-TV-Z]{2}[A-Z]){2}(?:[\dLMNP-V]{2}(?:[A-EHLMPR-T](?:[04LQ][1-9MNP-V]|[15MR][\dLMNP-V]|[26NS][0-8LMNP-U])|[DHPS][37PT][0L]|[ACELMRT][37PT][01LM]|[AC-EHLMPR-T][26NS][9V])|(?:[02468LNQSU][048LQU]|[13579MPRTV][26NS])B[26NS][9V])(?:[A-MZ][1-9MNP-V][\dLMNP-V]{2}|[A-M][0L](?:[1-9MNP-V][\dLMNP-V]|[0L][1-9MNP-V]))[A-Z]",
                            caseSensitive: false,
                            multiLine: false,
                          );
                          if (!checkCFRegExp.hasMatch(value)) {
                            return 'Per favore, inserisci un Codice Fiscale valido.';
                          }
                          return null;
                        }),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _sendData(context);
                          }
                          constants.userStatus = 0;
                          widget.logParent();
                        },
                        style: constants.STILE_BOTTONE,
                        child: const Text(
                          "REIMPOSTA PASSWORD!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: ElevatedButton(
                        onPressed: () {
                          widget.logParent();
                          constants.userStatus = 0;
                        },
                        style: constants.STILE_BOTTONE,
                        child: const Text(
                          "INDIETRO",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendData(BuildContext context) async {
    var url = Uri.https(
      constants.PATH,
      constants.ENDPOINT_PASS,
    );
    var request = {
      'id': constants.ID,
      'token': constants.TOKEN,
      'cf': _codiceFiscale.text,
    };
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request),
    );

    if (response.statusCode == 200) {
      var responseParsed = jsonDecode(response.body) as Map;
      constants.userStatus = int.parse(responseParsed['http_response_code']);
      widget.logParent();
    } else {
      constants.userStatus = 100;
      widget.logParent();
    }
  }
}
