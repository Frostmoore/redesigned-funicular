import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';

class ResetPassword extends StatelessWidget {
  const ResetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const HtmlWidget(
          "<h2 style='text-align:center;font-weight:bold;'>"
          "Hai chiesto la reimpostazione della tua Password!</h2>",
        ),
        constants.SPACER_MEDIUM,
        const HtmlWidget(
          "<p style='text-align:center;'>Ti abbiamo inviato un'email con il link "
          "per la reimpostazione.<br>Controlla anche nella Posta Indesiderata.</p>",
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
