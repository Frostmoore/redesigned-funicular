import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UtenteNonAttivo extends StatefulWidget {
  final data;
  final Function() logParent;
  const UtenteNonAttivo(
      {super.key, required this.data, required this.logParent});

  @override
  State<UtenteNonAttivo> createState() => _UtenteNonAttivoState();
}

class _UtenteNonAttivoState extends State<UtenteNonAttivo> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const HtmlWidget(
            "<h2 style='text-align:center;font-weight:bold;'>ATTENZIONE!</h2><p style='text-align:center;'>Attiva il tuo account per poter utilizzare le funzioni avanzate dell'app.<br>In fase di registrazione, ti è stata inviata un'e-mail con il link di attivazione.<br>Se non hai ricevuto l'email, assicurati di controllare anche nella casella di Posta Indesiderata, o contatta la tua Agenzia.</p>"),
        constants.SPACER_MEDIUM,
        ElevatedButton(
          style: constants.STILE_BOTTONE,
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            FlutterSecureStorage storage = const FlutterSecureStorage();
            // print(await prefs.getString('gavePermissionToUseBiometrics'));
            if (await prefs.containsKey('gavePermissionToUseBiometrics')) {
              await prefs.remove('authenticatedWithBiometrics');
              await prefs.remove('gavePermissionToUseBiometrics');
              await storage.deleteAll();
            }
            constants.userStatus = 0;
            widget.logParent();
          },
          child: const Text("HO CAPITO"),
        ),
      ],
    );
  }
}
