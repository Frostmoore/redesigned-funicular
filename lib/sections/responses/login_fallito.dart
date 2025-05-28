import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginFallito extends StatefulWidget {
  final data;
  final Function() logParent;
  const LoginFallito({super.key, required this.data, required this.logParent});

  @override
  State<LoginFallito> createState() => _LoginFallitoState();
}

class _LoginFallitoState extends State<LoginFallito> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const HtmlWidget(
              "<h2 style='text-align:center;font-weight:bold;'>ATTENZIONE!</h2><p style='text-align:center;'>Non siamo riusciti a farti accedere. Assicurati di aver attivato il tuo account tramite il link inviato per mail (Controlla anche la casella di posta indesiderata). <br />Riprova più tardi, contatta la tua agenzia o, se credi di aver dimenticato la password, clicca sul link seguente per reimpostarla.</p>"),
          InkWell(
            onTap: () {
              constants.userStatus = 99;
              widget.logParent();
            },
            child: const HtmlWidget(
                "<p style='text-align:center;text-decoration:underline;color:blue;'>Password Dimenticata?</p>"),
          ),
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
      ),
    );
  }
}
