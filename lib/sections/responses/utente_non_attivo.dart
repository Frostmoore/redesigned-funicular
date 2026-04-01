import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';

class UtenteNonAttivo extends StatelessWidget {
  const UtenteNonAttivo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const HtmlWidget(
          "<h2 style='text-align:center;font-weight:bold;'>ATTENZIONE!</h2>"
          "<p style='text-align:center;'>Attiva il tuo account per poter utilizzare "
          "le funzioni avanzate dell'app.<br>In fase di registrazione, ti è stata "
          "inviata un'e-mail con il link di attivazione.<br>Se non hai ricevuto "
          "l'email, controlla anche la cartella Posta Indesiderata, o contatta "
          "la tua Agenzia.</p>",
        ),
        constants.SPACER_MEDIUM,
        ElevatedButton(
          style: constants.STILE_BOTTONE,
          onPressed: context.read<AppProvider>().goToLogin,
          child: const Text('HO CAPITO'),
        ),
      ],
    );
  }
}
