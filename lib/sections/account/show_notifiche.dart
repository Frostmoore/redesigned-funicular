import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/models/notifica.dart';
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/sections/account/notifica_single.dart';

class ShowNotifiche extends StatefulWidget {
  const ShowNotifiche({super.key});

  @override
  State<ShowNotifiche> createState() => _ShowNotificheState();
}

class _ShowNotificheState extends State<ShowNotifiche> {
  late Future<List<Notifica>> _future;
  late String _username;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    _username = provider.currentUser!.username;
    _future = provider.notificheService.fetchNotifiche(_username);
  }

  void _refresh() {
    setState(() {
      _future = context.read<AppProvider>().notificheService
          .fetchNotifiche(_username);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [Text('Comunicazioni')],
        ),
      ),
      body: FutureBuilder<List<Notifica>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(
                color: constants.COLORE_PRINCIPALE,
              ),
            );
          }

          final all = snap.data ?? [];
          final personal =
              all.where((n) => n.isForUser(_username)).toList();

          if (personal.isEmpty) {
            return const Center(child: Text('Nessuna notifica disponibile.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: personal.length,
            itemBuilder: (context, i) {
              final n = personal[i];
              final unread = n.isUnreadBy(_username);
              return Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 0.3, color: Colors.grey),
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NotificaSingle(id: n.id),
                      ),
                    ).then((_) => _refresh());
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                        child: Icon(
                          unread ? Icons.mail : Icons.mark_email_read,
                          color: unread
                              ? constants.COLORE_PRINCIPALE
                              : Colors.grey,
                          size: 35,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(15.0, 8, 8, 8),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 90,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.dataora,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                n.titolo,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: unread
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                n.contenuto,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                  fontWeight: unread
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
        },
      ),
    );
  }
}
