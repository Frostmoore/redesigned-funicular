import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:Assidim/assets/constants.dart' as constants;

class NotificaSingle extends StatefulWidget {
  final data;
  final userId;
  const NotificaSingle({super.key, required this.data, required this.userId});

  @override
  State<NotificaSingle> createState() => _NotificaSingleState();
}

class _NotificaSingleState extends State<NotificaSingle> {
  Future<Map> _getNotifica() async {
    // print(widget.data);
    // print(widget.userId);
    final getNotifica = await http.post(
      // Uri.parse('https://' + constants.PATH + constants.ENDPOINT_SINGLENOT),
      Uri.parse("https://${constants.PATH}${constants.ENDPOINT_SINGLENOT}"),
      body: {
        'id': widget.data,
        'user': widget.userId,
      },
    );
    return jsonDecode(getNotifica.body) as Map;
  }

  Future<Map> _markAsRead(id, user) async {
    final gigi = await http.post(
      // Uri.parse('https://' + constants.PATH + constants.ENDPOINT_READNOTI),
      Uri.parse("https://${constants.PATH}${constants.ENDPOINT_READNOTI}"),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'id': id, 'user': user}),
    );
    print(gigi.body);
    return jsonDecode(gigi.body);
  }

  cleanNotifica(dati, user) {
    // TODO
    var pippa = {};
    var n = dati['data'];
    pippa['id'] = n['id'];
    pippa['titolo'] = n['titolo'];
    pippa['contenuto'] = n['contenuto'];
    pippa['immagine'] = n['immagine'];
    pippa['letta_da'] = n['letta_da'];
    pippa['link'] = n['link'];
    pippa['testolink'] = n['testolink'];
    pippa['dataora'] = n['dataora'];
    return pippa;
  }

  refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Future notifica = _getNotifica();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(''),
          ],
        ),
      ),
      body: FutureBuilder(
        future: notifica,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var user = widget.userId;
            if (snapshot.hasData) {
              Map notificaClean = cleanNotifica(snapshot.data, user);
              var pippano = _markAsRead(notificaClean['id'], user);
              // print(pippano);
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        notificaClean['titolo'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      if (notificaClean['immagine'] != null) ...[
                        constants.SPACER_MEDIUM,
                        Image.network(notificaClean['immagine']),
                        constants.SPACER_MEDIUM,
                      ],
                      HtmlWidget(
                        notificaClean['contenuto'],
                      ),
                      if (notificaClean['link'] != null) ...[
                        constants.SPACER_MEDIUM,
                        ElevatedButton(
                          onPressed: () {
                            constants.openUrl(
                              Uri.parse(notificaClean['link']),
                            );
                          },
                          style: constants.STILE_BOTTONE,
                          child: Text(
                            notificaClean['testolink'],
                          ),
                        ),
                        constants.SPACER_MEDIUM,
                      ],
                    ],
                  ),
                ),
              );
            } else {
              return Placeholder();
            }
          } else {
            return Center(
              child: const CircularProgressIndicator(
                color: constants.COLORE_PRINCIPALE,
              ),
            );
          }
        },
      ),
    );
  }
}
