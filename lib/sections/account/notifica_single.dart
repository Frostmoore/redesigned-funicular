import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/models/notifica.dart';
import 'package:Assidim/core/providers/app_provider.dart';

class NotificaSingle extends StatefulWidget {
  final String id;

  const NotificaSingle({super.key, required this.id});

  @override
  State<NotificaSingle> createState() => _NotificaSingleState();
}

class _NotificaSingleState extends State<NotificaSingle> {
  late Future<Notifica?> _future;
  late String _username;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    _username = provider.currentUser!.username;
    _future = provider.notificheService.fetchSingle(widget.id, _username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [Text('')],
        ),
      ),
      body: FutureBuilder<Notifica?>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(
                color: constants.COLORE_PRINCIPALE,
              ),
            );
          }

          final n = snap.data;
          if (n == null) {
            return const Center(child: Text('Nessun dato disponibile'));
          }

          // Mark as read — fire and forget
          context
              .read<AppProvider>()
              .notificheService
              .markAsRead(n.id, _username);

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (n.titolo.isNotEmpty)
                    Text(
                      n.titolo,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  if (n.immagine != null && n.immagine!.isNotEmpty) ...[
                    constants.SPACER_MEDIUM,
                    Image.network(n.immagine!),
                    constants.SPACER_MEDIUM,
                  ],
                  if (n.contenuto.isNotEmpty) HtmlWidget(n.contenuto),
                  if (n.link != null &&
                      n.link!.isNotEmpty &&
                      n.testolink != null &&
                      n.testolink!.isNotEmpty) ...[
                    constants.SPACER_MEDIUM,
                    ElevatedButton(
                      onPressed: () =>
                          constants.openUrl(Uri.parse(n.link!)),
                      style: constants.STILE_BOTTONE,
                      child: Text(n.testolink!),
                    ),
                    constants.SPACER_MEDIUM,
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
