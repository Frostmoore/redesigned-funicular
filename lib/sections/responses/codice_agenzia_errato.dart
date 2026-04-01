import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';

class CodiceAgenziaErrato extends StatelessWidget {
  const CodiceAgenziaErrato({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const HtmlWidget(
          "<h2 style='text-align:center;font-weight:bold;'>ATTENZIONE!</h2>"
          "<p style='text-align:center;'>Il Codice Agenzia che hai inserito non "
          "risulta corretto.</p>"
          "<p style='text-align:center;'>Contatta la tua Agenzia per riceverne uno valido.</p>",
        ),
        constants.SPACER_MEDIUM,
        ElevatedButton(
          style: constants.STILE_BOTTONE,
          onPressed: context.read<AppProvider>().goToLogin,
          child: const Text('INDIETRO'),
        ),
      ],
    );
  }
}
