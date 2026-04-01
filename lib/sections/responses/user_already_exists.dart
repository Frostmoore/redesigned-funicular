import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';

class UserAlreadyExists extends StatelessWidget {
  const UserAlreadyExists({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const HtmlWidget(
          "<h2 style='text-align:center;font-weight:bold;'>ATTENZIONE!</h2>"
          "<p style='text-align:center;'>Un utente con il Codice Fiscale che hai "
          "inserito è già esistente tra i nostri clienti. Accedi con le tue credenziali.</p>",
        ),
        constants.SPACER_MEDIUM,
        ElevatedButton(
          style: constants.STILE_BOTTONE,
          onPressed: provider.goToLogin,
          child: const Text('ACCEDI!'),
        ),
        constants.SPACER_MEDIUM,
        const Text('Hai dimenticato la tua Password?', textAlign: TextAlign.center),
        ElevatedButton(
          style: constants.STILE_BOTTONE,
          onPressed: provider.goToForgotPassword,
          child: const Text('Recupera Password!'),
        ),
      ],
    );
  }
}
