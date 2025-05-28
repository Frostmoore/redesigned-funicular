import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:Assidim/sections/account/notifica_single.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:Assidim/assets/constants.dart' as constants;

class ShowNotifiche extends StatefulWidget {
  final data;
  const ShowNotifiche({super.key, required this.data});

  @override
  State<ShowNotifiche> createState() => _ShowNotificheState();
}

class _ShowNotificheState extends State<ShowNotifiche> {
  Future<Map> _getNotifiche() async {
    final getNotifiche = await http.post(
      Uri.parse('https://${constants.PATH}${constants.ENDPOINT_NOTI}'),
      body: {
        'username': widget.data['userData']['data']['result']['username'],
      },
    );
    return jsonDecode(getNotifiche.body) as Map;
  }

  cleanNotifiche(dati, user) {
    var datiNotifiche = dati['data'];
    List pippo = [];
    for (var n in datiNotifiche) {
      var destinatari =
          n['destinatari'] == null ? [] : n['destinatari'].split(',');
      var lettada = n['letta_da'] == null ? [] : n['letta_da'].split(',');
      if (destinatari.contains(user)) {
        pippo.add({
          'id': n['id'],
          'titolo': n['titolo'],
          'contenuto': n['contenuto'],
          'immagine': n['immagine'],
          'destinatari': 'y',
          'letta_da': !lettada.contains(user) ? false : true,
          'link': n['link'],
          'testolink': n['testolink'],
          'dataora': n['dataora'],
        });
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
      body: FutureBuilder(
        future: notifiche,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var user = widget.data['userData']['data']['result']['username'];
            if (snapshot.hasData) {
              List notificheClean = cleanNotifiche(snapshot.data, user);

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notificheClean.length,
                itemBuilder: (context, i) {
                  var notifica = notificheClean[i];
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 0.3, color: Colors.grey),
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificaSingle(
                              data: notifica['id'],
                              userId: user,
                            ),
                          ),
                        ).then((value) => setState(() {}));
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                            child: Icon(
                              notifica['letta_da'] == false
                                  ? Icons.mail
                                  : Icons.mark_email_read,
                              color: notifica['letta_da'] == true
                                  ? Colors.grey
                                  : constants.COLORE_PRINCIPALE,
                              size: 35,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15.0, 8, 8, 8),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width - 90,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notifica['dataora'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    notifica['titolo'] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: notifica['letta_da'] == false
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    notifica['contenuto'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                      fontWeight: notifica['letta_da'] == false
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
                  );
                },
              );
            } else {
              return const Center(child: Text("Nessuna notifica disponibile."));
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(
                color: constants.COLORE_PRINCIPALE,
              ),
            );
          }
        },
      ),
    );
  }
}
