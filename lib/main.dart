import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/sections/account/gestione_consensi.dart';
import 'package:Assidim/sections/account/show_notifiche.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:io';
import 'package:Assidim/firebase_options.dart';
import 'package:Assidim/home.dart';
// import 'package:Assidim/sections/web_view_container.dart';
// import 'package:Assidim/sections/login_form.dart';
// import 'package:Assidim/sections/register_form.dart';
// import 'package:Assidim/sections/account.dart';
import 'package:Assidim/sections/accountcontainer.dart';
import 'package:Assidim/sections/chiamata_rapida.dart';
import 'package:flutter/material.dart';
// import 'package:Assidim/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'dart:developer';
// import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//import 'package:notification_permissions/notification_permissions.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> _messageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  RemoteNotification? notification = message.notification;
  if (notification != null) {}
}
//test

void main() async {
  //WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides(); // Remove in Production
  await Firebase.initializeApp(
    name: constants.TITLE,
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await Permission.notification.isDenied.then((value) {
  //   if (value) {
  //     Permission.notification.request();
  //     Permission.location.request();
  //     //print(Permission.notification.status);
  //   }
  // });
  // print(Permission.location.status);
  /*await Permission.location.isDenied.then((value) {
    if (value) {
      Permission.location.request();
      print(Permission.notification.status);
    }
  });*/
  Map<Permission, PermissionStatus> statuses = await [
    Permission.locationWhenInUse,
    Permission.notification,
  ].request();
  print(statuses[Permission.location]);
  // print(statuses[Permission.notification]);
  //var gigi = await Permission.camera.status;
  /*if (await Permission.photos.status == PermissionStatus.denied) {
    Permission.photos.request();
  }
  if (await Permission.camera.status == PermissionStatus.denied) {
    Permission.camera.request();
  }*/

  FirebaseMessaging.onBackgroundMessage(_messageHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Return app
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {'/': (context) => const MyHomePage(title: constants.TITLE)},
      title: constants.TITLE,
      theme: ThemeData(
        colorScheme: const ColorScheme.highContrastLight(),
        useMaterial3: true,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  Future getData() async {
    var url = Uri.https(
      constants.PATH,
      constants.ENDPOINT,
      {
        'id': constants.ID,
        'token': constants.TOKEN,
      },
    );
    // print(url); // Remove in Production
    var response = await http.get(url);
    // print(response); // Remove in production
    var responseBody = convert.jsonDecode(response.body) as Map;
    // print(responseBody); // Remove in production
    return responseBody;
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(constants.TITLE),
                  ],
                ),
              ),
              body: _selectedIndex == 0
                  ? HomePage(data: snapshot.data)
                  : _selectedIndex == 1
                      ? AccountContainer(data: snapshot.data)
                      : GestioneConsensi(data: snapshot.data),
              floatingActionButton: ChiamataRapida(data: snapshot.data),
              bottomNavigationBar: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Agenzia',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.account_box),
                    label: 'Account',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Impostazioni',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: constants.COLORE_PRINCIPALE,
                unselectedItemColor: constants.COLORE_PRINCIPALE,
                unselectedLabelStyle: const TextStyle(color: constants.COLORE_PRINCIPALE),
                onTap: _onItemTapped,
              ),
            );
          } else {
            return Center(
              child: Text(
                'Non è stato possibile contattare il server di destinazione. Controlla la tua connessione o Riprova più tardi.',
                textAlign: TextAlign.center,
              ),
            );
          }
        } else {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(constants.COLORE_PRINCIPALE),
              ),
            ),
          );
        }
      },
    );
  }
}
