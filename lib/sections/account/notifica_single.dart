import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
    final getNotifica = await http.post(
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
      Uri.parse("https://${constants.PATH}${constants.ENDPOINT_READNOTI}"),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'id': id, 'user': user}),
    );
    return jsonDecode(gigi.body);
  }

  Map<String, dynamic> cleanNotifica(Map dati, user) {
    final n = dati['data'];
    return {
      'id': n['id'],
      'titolo': n['titolo'],
      'contenuto': n['contenuto'],
      'immagine': n['immagine'],
      'letta_da': n['letta_da'],
      'link': n['link'],
      'testolink': n['testolink'],
      'dataora': n['dataora'],
    };
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
              final notificaClean = cleanNotifica(snapshot.data, user);
              print(notificaClean);
              _markAsRead(notificaClean['id'], user);

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (notificaClean['titolo'] != null &&
                          notificaClean['titolo'].toString().isNotEmpty)
                        Text(
                          notificaClean['titolo'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      if (notificaClean['immagine'] != null &&
                          notificaClean['immagine'].toString().isNotEmpty) ...[
                        constants.SPACER_MEDIUM,
                        Image.network(notificaClean['immagine']),
                        constants.SPACER_MEDIUM,
                      ],
                      if (notificaClean['contenuto'] != null &&
                          notificaClean['contenuto'].toString().isNotEmpty)
                        HtmlWidget(notificaClean['contenuto']),
                      if (notificaClean['link'] != null &&
                          notificaClean['link'].toString().isNotEmpty &&
                          notificaClean['testolink'] != null &&
                          notificaClean['testolink'].toString().isNotEmpty) ...[
                        constants.SPACER_MEDIUM,
                        ElevatedButton(
                          onPressed: () {
                            constants.openUrl(Uri.parse(notificaClean['link']));
                          },
                          style: constants.STILE_BOTTONE,
                          child: Text(notificaClean['testolink']),
                        ),
                        constants.SPACER_MEDIUM,
                      ],
                    ],
                  ),
                ),
              );
            } else {
              return const Center(child: Text("Nessun dato disponibile"));
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
