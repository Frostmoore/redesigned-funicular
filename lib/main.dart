import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/sections/account/gestione_consensi.dart';
import 'package:Assidim/sections/account/show_notifiche.dart';
import 'package:Assidim/pages/preventivo.dart';
import 'package:Assidim/pages/sinistro.dart';
import 'package:Assidim/pages/documento.dart';
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
import 'package:onesignal_flutter/onesignal_flutter.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> _messageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  RemoteNotification? notification = message.notification;
  if (notification != null) {}
}
//test

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // HttpOverrides.global = new MyHttpOverrides(); // Remove in Production
  // OneSignal.Debug.setLogLevel(OSLogLevel.verbose); // Remove in Production
  // OneSignal.initialize(constants.APPID); // OneSignal Initialization
  await Firebase.initializeApp(
    name: constants.TITLE,
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Map<Permission, PermissionStatus> statuses = await [
    Permission.locationWhenInUse,
    Permission.notification,
  ].request();

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
      routes: {
        '/': (context) => const MyHomePage(title: constants.TITLE),
        '/sinistro': (context) => SinistroForm(),
        '/preventivo': (context) => PreventivoForm(),
        '/documento': (context) => DocumentoForm(),
      },
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
            // OneSignal.Debug.setLogLevel(
            //     OSLogLevel.verbose); // Remove in Production
            OneSignal.initialize(
                snapshot.data['os_app_id']); // OneSignal Initialization
            // OneSignal.Notifications.requestPermission(true);
            var colori = snapshot.data['colori'].split('|');
            var colore_principale = int.parse(colori[0]);
            var colore_secondario = int.parse(colori[1]);
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
                selectedItemColor: Color(colore_secondario),
                unselectedItemColor: Color(colore_secondario),
                unselectedLabelStyle:
                    TextStyle(color: Color(colore_secondario)),
                onTap: _onItemTapped,
              ),
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Errore'),
                  ],
                ),
              ),
              body: Center(
                child: Text(
                  'Non è stato possibile contattare il server di destinazione. Controlla la tua connessione o Riprova più tardi.',
                  textAlign: TextAlign.center,
                ),
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
                valueColor: AlwaysStoppedAnimation(Colors.teal),
              ),
            ),
          );
        }
      },
    );
  }
}
