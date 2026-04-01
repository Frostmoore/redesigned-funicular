import 'package:Assidim/core/models/notifica.dart';
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/sections/account/show_notifiche.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Assidim/assets/constants.dart' as constants;

class Notifiche extends StatefulWidget {
  const Notifiche({super.key});

  @override
  State<Notifiche> createState() => _NotificheState();
}

class _NotificheState extends State<Notifiche> {
  late Future<List<Notifica>> _future;
  late String _username;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    _username = provider.currentUser!.username;
    _future = provider.notificheService.fetchNotifiche(_username);
  }

  @override
  Widget build(BuildContext context) {
    // Also rebuild when OneSignal triggers a refresh
    context.select<AppProvider, int>((p) => p.notificheTrigger);

    return FutureBuilder<List<Notifica>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator(
            color: constants.COLORE_PRINCIPALE,
          );
        }

        final notifiche = snap.data ?? [];
        final unread = notifiche
            .where((n) => n.isForUser(_username) && n.isUnreadBy(_username))
            .length
            .clamp(0, 99);

        if (!snap.hasData || notifiche.isEmpty) {
          return const Text('Nessuna nuova notifica');
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ShowNotifiche()),
                ).then((_) {
                  if (!mounted) return;
                  setState(() {
                    _future = context
                        .read<AppProvider>()
                        .notificheService
                        .fetchNotifiche(_username);
                  });
                });
              },
              style: constants.STILE_BOTTONE,
              child: const Row(
                children: [
                  Text('Vai alle tue Comunicazioni'),
                ],
              ),
            ),
            if (unread > 0)
              Positioned(
                right: 40,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  constraints: const BoxConstraints(minWidth: 25, minHeight: 25),
                  child: Text(
                    unread.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            const Positioned(
              right: 10,
              child: Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ],
        );
      },
    );
  }
}
