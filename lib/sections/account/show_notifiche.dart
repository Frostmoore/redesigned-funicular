import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:Assidim/sections/account/notifica_single.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:Assidim/assets/constants.dart' as constants;

class ShowNotifiche extends StatefulWidget {
  final data;
  const ShowNotifiche({super.key, required this.data});

  @override
  State<ShowNotifiche> createState() => _ShowNotificheState();
}

class _ShowNotificheState extends State<ShowNotifiche> {
  Future<Map> _getNotifiche() async {
    // print(widget.data);
    final getNotifiche = await http.post(
      Uri.parse('https://' + constants.PATH + constants.ENDPOINT_NOTI),
      body: {
        'username': widget.data['userData']['data']['result']['username'],
      },
    );
    // print(notifiche.body);
    // final notifiche_json = jsonDecode(getNotifiche.body) as Map;
    // final status = notifiche_json['status'];
    // final datiNotifiche = notifiche_json['data'];
    // print(datiNotifiche);
    return jsonDecode(getNotifiche.body) as Map;
  }

  cleanNotifiche(dati, user) {
    // TODO
    var datiNotifiche = dati['data'];
    // print(datiNotifiche);
    List pippo = [];
    for (var i = 0; i < datiNotifiche.length; i++) {
      var destinatari = datiNotifiche[i]['destinatari'] == null
          ? ''
          : datiNotifiche[i]['destinatari'].split(',');
      var lettada = datiNotifiche[i]['letta_da'] == null
          ? ''
          : datiNotifiche[i]['letta_da'].split(',');
      var n = datiNotifiche[i];
      if (destinatari.contains(user)) {
        if (!lettada.contains(user)) {
          Map<String, dynamic> pippa = {};
          pippa['id'] = n['id'];
          pippa['titolo'] = n['titolo'];
          pippa['contenuto'] = n['contenuto'];
          pippa['immagine'] = n['immagine'];
          pippa['destinatari'] = 'y';
          pippa['letta_da'] = false;
          pippa['link'] = n['link'];
          pippa['testolink'] = n['testolink'];
          pippa['dataora'] = n['dataora'];
          pippo.add(pippa);
        } else {
          Map<String, dynamic> pippa = {};
          pippa['id'] = n['id'];
          pippa['titolo'] = n['titolo'];
          pippa['contenuto'] = n['contenuto'];
          pippa['immagine'] = n['immagine'];
          pippa['destinatari'] = 'y';
          pippa['letta_da'] = true;
          pippa['link'] = n['link'];
          pippa['testolink'] = n['testolink'];
          pippa['dataora'] = n['dataora'];
          pippo.add(pippa);
        }
      }
    }
    return pippo;
  }

  refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Future notifiche = _getNotifiche();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Comunicazioni'),
          ],
        ),
      ),
      body: Center(
        child: FutureBuilder(
          future: notifiche,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              var user = widget.data['userData']['data']['result']['username'];
              // inspect(snapshot);
              if (snapshot.hasData) {
                List notificheClean = cleanNotifiche(snapshot.data, user);
                // print(notificheClean);
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (var i = 0; i < notificheClean.length; i++)
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 0.3,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            child: SingleChildScrollView(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NotificaSingle(
                                        data: notificheClean[i]['id'],
                                        userId: user,
                                      ),
                                    ),
                                  ).then((value) => setState(() {}));
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 8, 0, 0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            notificheClean[i]['letta_da'] ==
                                                    false
                                                ? Icons.mail
                                                : Icons.mark_email_read,
                                            color: notificheClean[i]
                                                        ['letta_da'] ==
                                                    true
                                                ? Colors.grey
                                                : constants.COLORE_PRINCIPALE,
                                            size: 35,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15.0, 8, 8, 8),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                90,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              notificheClean[i]['dataora'],
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontStyle: FontStyle.italic,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              notificheClean[i]['titolo'],
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontWeight: notificheClean[i]
                                                            ['letta_da'] ==
                                                        false
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                fontSize: 20,
                                              ),
                                            ),
                                            Text(
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              notificheClean[i]['contenuto'],
                                              textAlign: TextAlign.justify,
                                              style: TextStyle(
                                                fontWeight: notificheClean[i]
                                                            ['letta_da'] ==
                                                        false
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              } else {
                return Placeholder();
              }
            } else {
              return const CircularProgressIndicator(
                color: constants.COLORE_PRINCIPALE,
              );
            }
          },
        ),
      ),
    );
  }
}
