import 'package:flutter/material.dart';
// import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum UserMenuItems { itemOne, itemTwo, itemThree }

class GearMenu extends StatefulWidget {
  final data;
  final userData;
  final Function() logParent;
  const GearMenu({super.key, required this.data, required this.logParent, required this.userData});

  @override
  State<GearMenu> createState() => _GearMenuState();
}

class _GearMenuState extends State<GearMenu> {
  UserMenuItems? selectedItem;

  @override
  Widget build(BuildContext context) {
    print(widget.userData); // privacy1, privacy2, privacy3
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: const HtmlWidget('<h1 style="text-align:left;">IL MIO ACCOUNT</h1>'),
          ),
          flex: 2,
        ),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerRight,
            child: PopupMenuButton(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                child: Icon(Icons.settings),
              ),
              itemBuilder: (BuildContext bc) {
                return [
                  PopupMenuItem(
                    value: 'Item 1',
                    onTap: () {
                      constants.userStatus = 7;
                      widget.logParent();
                    },
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                          child: Icon(Icons.privacy_tip_outlined),
                        ),
                        const Text('Gestisci Consensi'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'Item 2',
                    onTap: () async {
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
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                          child: Icon(Icons.logout),
                        ),
                        Text('Log-out'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ),
        ),
      ],
    );
  }
}
