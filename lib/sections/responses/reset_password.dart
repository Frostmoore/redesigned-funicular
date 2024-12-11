import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ResetPassword extends StatefulWidget {
  final data;
  final Function() logParent;
  const ResetPassword({super.key, required this.data, required this.logParent});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const HtmlWidget(
            "<h2 style='text-align:center;font-weight:bold;'>Hai chiesto la reimpostazione della tua Password!</h2>"),
        constants.SPACER_MEDIUM,
        const HtmlWidget(
            "<p style='text-align:center;'>Ti abbiamo inviato un'email con il link per la reimpostazione.<br>Controlla anche nella casella di Posta Indesiderata.</p>"),
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
