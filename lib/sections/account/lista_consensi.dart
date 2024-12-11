import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ListaConsensi extends StatefulWidget {
  final data;
  const ListaConsensi({super.key, required this.data});

  @override
  State<ListaConsensi> createState() => _ListaConsensiState();
}

class _ListaConsensiState extends State<ListaConsensi> {
  Future<Map> login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var storage = FlutterSecureStorage();
    if (await storage.containsKey(key: 'username')) {
      var username = storage.read(key: 'username');
      var password = storage.read(key: 'password');
      // LOGIN
      var url = Uri.https(
        constants.PATH,
        constants.ENDPOINT_LOG,
      );

      var request = {
        'id': constants.ID,
        'token': constants.TOKEN,
        'username': await username,
        'password': await password,
      };

      var response = await http.post(
        url,
        headers: {'Content-Type': 'Application/json'},
        body: jsonEncode(request),
        // body: request,
      );

      var responseParsed = jsonDecode(response.body) as Map;
      var userStatus = responseParsed['http_response_code'];
      if (userStatus == '1') {
        return {'result': 'ok', 'data': responseParsed, 'userStatus': 1};
      } else {
        return {'result': 'error', 'data': responseParsed, 'userStatus': 100};
      }
    } else {
      return {'result': 'error', 'data': null, 'userStatus': 98};
    }
  }

  Future<Map> getPrivacy() async {
    final _dataUtente = await login();
    var privacy1_raw = _dataUtente['data']['result']['privacy1'].split('|');
    var privacy2_raw = _dataUtente['data']['result']['privacy2'].split('|');
    var privacy3_raw = _dataUtente['data']['result']['privacy3'].split('|');
    var privacy4_raw = _dataUtente['data']['result']['privacy4'].split('|');
    var privacy1_consent = privacy1_raw[0];
    var privacy2_consent = privacy2_raw[0];
    var privacy3_consent = privacy3_raw[0];
    var privacy4_consent = privacy4_raw[0];
    var privacy1_date = privacy1_raw[1];
    var privacy2_date = privacy2_raw[1];
    var privacy3_date = privacy3_raw[1];
    var privacy4_date = privacy4_raw[1];
    Map datiPrivacy = {
      'privacy1': {
        'consent': privacy1_consent == '1' ? true : false,
        'date': privacy1_date,
      },
      'privacy2': {
        'consent': privacy2_consent == '1' ? true : false,
        'date': privacy2_date,
      },
      'privacy3': {
        'consent': privacy3_consent == '1' ? true : false,
        'date': privacy3_date,
      },
      'privacy4': {
        'consent': privacy4_consent == '1' ? true : false,
        'date': privacy4_date,
      },
    };
    // print(datiPrivacy['privacy1']);
    return datiPrivacy;
  }

  Future<Map> setPrivacy(num, val) async {
    Map datiUtente = await login();
    var url = Uri.https(
      constants.PATH,
      constants.ENDPOINT_PRIV,
    );

    var request = {
      'id': await datiUtente['data']['result']['id'],
      'privacyId': num,
      'privacyStatus': val,
    };

    var response = await http.post(
      url,
      body: jsonEncode(request),
    );

    var responseParsed = jsonDecode(response.body) as Map;
    return responseParsed;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getPrivacy(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            var snata;
            if (snapshot.data != null) {
              snata = snapshot.data;
            } else {
              var snata = {
                'privacy2': {'consent': false},
                'privacy3': {'consent': false},
                'privacy4': {'consent': false},
              };
            }
            bool privacy2 = snata != null ? snata['privacy2']['consent'] : null;
            bool privacy3 = snata != null ? snata['privacy3']['consent'] : null;
            bool privacy4 = snata != null ? snata['privacy4']['consent'] : null;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const HtmlWidget(
                      "<h2 style='text-align:center;'>Gestione Consensi Privacy</h2>",
                    ),
                    constants.SPACER,
                    Row(
                      children: [
                        Expanded(child: Text(constants.privacy2)),
                        Switch(
                          value: privacy2,
                          activeColor: constants.COLORE_PRINCIPALE,
                          onChanged: (bool value2) async {
                            setPrivacy('2', value2).then((_) {
                              setState(() {
                                privacy2 = value2;
                              });
                            });
                          },
                        ),
                      ],
                    ),
                    constants.SPACER,
                    Row(
                      children: [
                        Expanded(child: Text(constants.privacy3)),
                        Switch(
                          value: privacy3,
                          activeColor: constants.COLORE_PRINCIPALE,
                          onChanged: (bool value3) async {
                            setPrivacy('3', value3).then((_) {
                              setState(() {
                                privacy3 = value3;
                              });
                            });
                          },
                        ),
                      ],
                    ),
                    constants.SPACER,
                    Row(
                      children: [
                        Expanded(child: Text(constants.privacy4)),
                        Switch(
                          value: privacy4,
                          activeColor: constants.COLORE_PRINCIPALE,
                          onChanged: (bool value4) async {
                            setPrivacy('4', value4).then((_) {
                              print(value4);
                              setState(() {
                                privacy4 = value4;
                              });
                            });
                          },
                        ),
                      ],
                    ),
                    constants.SPACER,
                  ],
                ),
              ),
            );
          } else {
            return Container();
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(color: constants.COLORE_PRINCIPALE),
          );
        }
      },
    );
  }
}
