import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NessunRisultato extends StatefulWidget {
  const NessunRisultato({super.key});

  @override
  State<NessunRisultato> createState() => _NessunRisultatoState();
}

class _NessunRisultatoState extends State<NessunRisultato> {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HtmlWidget(
              "<h2 style='text-align:center;font-weight:bold;'>NESSUNA POLIZZA TROVATA</h2><p style='text-align:center;'>Siamo spiacenti, non siamo riusciti a trovare polizze in base alle credenziali che hai inserito. Se desideri cambiare le tue credenziali, puoi effettuare il log-out e accedere con le credenziali corrette.</p>"),
        ],
      ),
    );
  }
}
