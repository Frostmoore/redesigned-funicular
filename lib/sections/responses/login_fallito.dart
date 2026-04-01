import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';

class LoginFallito extends StatelessWidget {
  const LoginFallito({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const HtmlWidget(
            "<h2 style='text-align:center;font-weight:bold;'>ATTENZIONE!</h2>"
            "<p style='text-align:center;'>Non siamo riusciti a farti accedere. "
            "Assicurati di aver attivato il tuo account tramite il link inviato "
            "per mail (Controlla anche la casella di posta indesiderata).<br/>"
            "Riprova più tardi, contatta la tua agenzia o, se credi di aver "
            "dimenticato la password, clicca sul link seguente.</p>",
          ),
          InkWell(
            onTap: provider.goToForgotPassword,
            child: const HtmlWidget(
              "<p style='text-align:center;text-decoration:underline;color:blue;'>"
              "Password Dimenticata?</p>",
            ),
          ),
          constants.SPACER_MEDIUM,
          ElevatedButton(
            style: constants.STILE_BOTTONE,
            onPressed: () async {
              await provider.logout();
              provider.goToLogin();
            },
            child: const Text('INDIETRO'),
          ),
        ],
      ),
    );
  }
}
