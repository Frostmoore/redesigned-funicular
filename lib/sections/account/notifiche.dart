import 'package:Assidim/sections/account/show_notifiche.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:Assidim/assets/constants.dart' as constants;

class Notifiche extends StatefulWidget {
  final data;
  const Notifiche({super.key, required this.data});

  @override
  State<Notifiche> createState() => _NotificheState();
}

class _NotificheState extends State<Notifiche> {
  Future<Map> _getNotifiche() async {
    // print(widget.data);
    final notifiche = await http.post(
      Uri.parse('https://' + constants.PATH + constants.ENDPOINT_NOTI),
      body: {
        'username': widget.data['userData']['data']['result']['username'],
      },
    );
    // print(notifiche.body);
    return jsonDecode(notifiche.body) as Map;
  }

  refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Future notifiche = _getNotifiche();
    // print(notifiche);
    return FutureBuilder(
      future: notifiche,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            // print(snapshot.data['data']);
            // List<Map> notifiche_personali = [];
            if (snapshot.data['status'] == 'ok') {
              var newNotifiche = 0;
              for (var i = 0; i < snapshot.data['data'].length; i++) {
                List destinatari = snapshot.data['data'][i]['destinatari'].split(',');
                List lettaDa =
                    snapshot.data['data'][i]['letta_da'] == null ? [''] : snapshot.data['data'][i]['letta_da'].split(',');
                if (destinatari.contains(widget.data['userData']['data']['result']['username'])) {
                  //
                  if (!lettaDa.contains(widget.data['userData']['data']['result']['username'])) {
                    newNotifiche++;
                  }
                  // notifiche_personali.add(snapshot.data['data'][i]);
                  newNotifiche = newNotifiche > 99 ? 99 : newNotifiche;
                }
              }

              // return Text(newNotifiche.toString());
              return Stack(
                alignment: Alignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ShowNotifiche(data: widget.data)))
                          .then((value) => setState(() {}));
                    },
                    style: constants.STILE_BOTTONE,
                    child: Row(
                      children: [
                        Text(
                          'Vai alle tue Comunicazioni',
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                  if (newNotifiche > 0)
                    Positioned(
                      right: 40,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 25,
                          minHeight: 25,
                        ),
                        child: Text(
                          newNotifiche.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  Positioned(
                    right: 10,
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            } else {
              return Text('Nessuna nuova notifica');
            }
          } else {
            return Placeholder();
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
