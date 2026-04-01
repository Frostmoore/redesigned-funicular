// gestione_consensi.dart
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/sections/account/change_username.dart';
import 'package:Assidim/sections/account/lista_consensi.dart';

class GestioneConsensi extends StatelessWidget {
  final VoidCallback? goHome;
  const GestioneConsensi({super.key, this.goHome});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const HtmlWidget(
              "<h2 style='text-align:center;'>GESTISCI LE IMPOSTAZIONI</h2>"),
          constants.SPACER,

          if (user != null) ...[
            ChangeUsername(userData: user),
            constants.SPACER_MEDIUM,
            ListaConsensi(userData: user),
            constants.SPACER_MEDIUM,
          ],

          const HtmlWidget(
              '<h3 style="text-align:center;">Rimozione dati Applicazione</h3>'),
          constants.SPACER_MEDIUM,
          const HtmlWidget(
              '<p style="text-align:center;"><strong>ATTENZIONE:</strong> '
              'Cliccando su questo tasto, effettuerai il log-out dal tuo account e '
              'tutte le informazioni salvate verranno eliminate dal dispositivo.</p>'),
          constants.SPACER_MEDIUM,
          ElevatedButton(
            style: constants.STILE_BOTTONE_ROSSO,
            onPressed: () async {
              await context.read<AppProvider>().logout();
              if (goHome != null) goHome!();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dati locali rimossi')),
                );
              }
            },
            child: const Text('CANCELLA!'),
          ),
          constants.SPACER,
          ElevatedButton(
            style: constants.STILE_BOTTONE_ROSSO,
            onPressed: () {
              launchUrl(
                  Uri.parse('https://hybridandgogsv.it/delete_account.php'));
            },
            child: const Text('Rimuovi il tuo Account!'),
          ),
        ],
      ),
    );
  }
}
