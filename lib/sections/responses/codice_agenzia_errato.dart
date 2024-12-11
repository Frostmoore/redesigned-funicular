import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CodiceAgenziaErrato extends StatefulWidget {
  final data;
  final Function() logParent;
  const CodiceAgenziaErrato(
      {super.key, required this.data, required this.logParent});

  @override
  State<CodiceAgenziaErrato> createState() => _CodiceAgenziaErratoState();
}

class _CodiceAgenziaErratoState extends State<CodiceAgenziaErrato> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const HtmlWidget(
            "<h2 style='text-align:center;font-weight:bold;'>ATTENZIONE!</h2><p style='text-align:center;'>Il Codice Agenzia che hai inserito non risulta corretto.</p><p style='text-align:center;'>Contatta la tua Agenzia per riceverne uno valido.</p>"),
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
          child: const Text("INDIETRO"),
        ),
      ],
    );
  }
}
