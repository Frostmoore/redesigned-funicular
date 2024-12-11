import 'package:Assidim/sections/register_form.dart';
import 'package:flutter/material.dart';
import 'package:Assidim/sections/account.dart';
import 'package:Assidim/sections/login_form.dart';
import 'package:Assidim/sections/responses/password_dimenticata.dart';
import 'package:Assidim/sections/responses/register_success.dart';
import 'package:Assidim/sections/responses/user_already_exists.dart';
import 'package:Assidim/sections/responses/codice_agenzia_errato.dart';
import 'package:Assidim/sections/responses/general_error.dart';
import 'package:Assidim/sections/responses/reset_password.dart';
import 'package:Assidim/sections/responses/login_fallito.dart';
import 'package:Assidim/sections/responses/utente_non_attivo.dart';
import 'package:Assidim/sections/account/gestione_consensi.dart';
import 'package:Assidim/assets/constants.dart' as constants;
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

class AccountContainer extends StatefulWidget {
  final data;
  const AccountContainer({super.key, required this.data});

  @override
  State<AccountContainer> createState() => _AccountContainerState();
}

class _AccountContainerState extends State<AccountContainer> {
  refresh() {
    setState(() {});
  }

  Future<bool> isAlreadyLogged() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('isAlreadyLogged') && prefs.getBool('isAlreadyLogged') == true) {
      return true;
    } else {
      return false;
    }
  }

  clearAll() async {
    final storage = FlutterSecureStorage();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await storage.deleteAll();
    await prefs.remove('hasGivenPermissionToUseBiometrics');
    await prefs.remove('alreadyLoggedInWithBiometrics');
    await prefs.remove('isAlreadyLogged');
    await prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    // clearAll();
    // print('cai');
    return FutureBuilder(
      future: isAlreadyLogged(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // print(snapshot.data);
          if (snapshot.data == true) {
            return AccountPage(data: widget.data, logParent: refresh);
          } else {
            switch (constants.userStatus) {
              case 0:
                return LoginForm(data: widget.data, logParent: refresh);
              case 1:
                return AccountPage(data: widget.data, logParent: refresh);
              case 2:
                return RegisterForm(data: widget.data, logParent: refresh);
              case 3:
                return UserAlreadyExists(data: widget.data, logParent: refresh);
              case 4:
                return CodiceAgenziaErrato(data: widget.data, logParent: refresh);
              case 5:
                return RegisterSuccess(data: widget.data, logParent: refresh);
              case 6:
                return ResetPassword(data: widget.data, logParent: refresh);
              case 97:
                return UtenteNonAttivo(data: widget.data, logParent: refresh);
              case 98:
                return LoginFallito(data: widget.data, logParent: refresh);
              case 99:
                return PasswordDimenticata(data: widget.data, logParent: refresh);
              case 100:
                return GeneralError(data: widget.data, logParent: refresh);
              default:
                return Placeholder();
            }
          }
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
