import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert' as convert;

//
// PRINCIPALI
//
const String TITLE = '!NOME_APP';
const String APPID = '!APP_ID';
const Color COLORE_PRINCIPALE = Color(0xffdf842c);
const Color COLORE_SECONDARIO = Color(0xff2b346b);
const Color COLORE_TERZIARIO = Color(0xff2b346b);
const Color BIANCO = Color(0xffffffff);
const Color TRASPARENTE = Color(0x00ffffff);
const String ID = '6'; //!ID_APP
const String TOKEN = 'GwAqon0pX'; //!TOKEN
const String PATH = 'www.hybridandgogsv.it';
const String ENDPOINT = '/res/api.php';
const String ENDPOINT_REG = '/res/api/v1/reg.php';
const String ENDPOINT_LOG = '/res/api/v1/auth.php';
const String ENDPOINT_PASS = '/res/api/v1/pass.php';
const String ENDPOINT_CONS = '/res/api/v1/cons.php';
const String ENDPOINT_PRIV = '/res/api/v1/priv.php';
const String ENDPOINT_NOTI = '/res/api/v1/noti.php';
const String ENDPOINT_SINGLENOT = '/res/api/v1/singlenot.php';
const String ENDPOINT_READNOTI = '/res/api/v1/readnoti.php';
const String IMG_PATH = 'https://' + PATH + '/res/';
const String BASE_ADDR = 'https://' + PATH + '/res/';
int userStatus = 0;
bool isLoggedIn = false;
var dataUtente;
var loginData;

// CHIAMATE POLIZZE
// AssiEasy URLs
var assiEasyPath = 'assidim.assieasy.com'; //!PATH_AGENZIA
var urlAssiEasyLookup = Uri.https(
  assiEasyPath,
  'assieasy/clienti/autenticazione/get_credenziali_utente',
);
var urlAssiEasyLogin = Uri.https(
  assiEasyPath,
  '/assieasy/clienti/autenticazione/login',
);
var urlAssiEasyPolizze = Uri.https(
  assiEasyPath,
  '/assieasy/clienti/polizze/get',
);
var urlAssiEasyLogout = Uri.https(
  assiEasyPath,
  '/assieasy/clienti/autenticazione/logout',
);

var chiaveHi = 'ASSIHI'; //!CHIAVE_HI

Map<String, Uri> assiEasy = {
  'assiEasyLoginUrl': urlAssiEasyLogin,
  'assiEasyPolizzeUrl': urlAssiEasyPolizze,
  'assiEasyLogoutUrl': urlAssiEasyLogout,
};

var assiSecret = 'afb5a9b4916de9d2a371563d40be6f1a'; //!ASSISECRET

//
// CHIAMATE POLIZZE TTYCREO
//
var pathAgenziaTtyCreo = 'uw.'; //!PATH_AGE_TTY
var ttyCreoPath = 'ttycreo.it'; //!PATH_TTY
var ttyCreoEndpoint = '/webservice/gsvhomeinsurance/polizze'; //!ENDPOINT_AGE_TTY
var licenzaClienteId = '105329'; //!LICENZA_CLID_TTY
var aziendaId = '10532902'; //!AZID_TTY
var agenziaId = '05349'; //!AGID_TTY
var ttyCreoApiKey =
    'os34rtk0ywfyfwok6gn1j13omzh9tpx64si30d8kfhkku7jbl3ob46zd2cz5ypi1h2oo84c7o34xtn21fxvcsrf0r4pf8vqwip3p07ki4qj1g6cdtav0k3ll75bqym4d';
var ttyCreoClientId = 'z83v7h2fae8v4l2y085wz6d53foubkr5tb4iwlhvt4tfjqcwlgivvtu22ez1ycwx'; //!API_TTY
var ttyCreoClientSecret =
    '16uclsjcrlrjrdkspweeovvc6ostq2qnm7pv4hqh58xikqity2yl6uf88g045xjhe83m2cdrtzv7h3jj7e2o7qkbi5ow0ks6q0861dkfgd1c3z0i5brq448ynl11hp7i'; //!SECRET_TTY

var urlTtyCreoPolizze = Uri.https(
  pathAgenziaTtyCreo + ttyCreoPath,
  ttyCreoEndpoint,
);

//
// Privacy
//
var privacy2 =
    "Acconsento al trattamento dei miei dati personali di natura comune per finalità di informazione e promozione commerciale di prodotti e/o servizi, a mezzo posta o telefono e/o mediante comunicazioni elettroniche quali e-mail, fax, messaggi del tipo SMS o MMS ovvero con sistemi automatizzati, come specificato ai punti 2a, 2b e 2c dell'informativa.";
var privacy3 =
    "Acconsento al trattamento dei miei dati personali di natura comune per finalità di comunicazione dei dati a soggetti terzi, operanti nel settore assicurativo e nei settori complementari a quello assicurativo, ai fini di informazione e promozione commerciale di prodotti e/o servizi, anche mediante tecniche di comunicazione a distanza, da parte degli stessi, come specificato al punto 2d dell'informativa.";
var privacy4 =
    "Acconsento al trattamento dei miei dati personali di natura comune per finalità di profilazione volta ad analizzare i bisogni e le esigenze assicurative del cliente per l'individuazione, anche attraverso elaborazioni elettroniche, dei possibili prodotti e/o servizi in linea con le preferenze e gli interessi della clientela come specificato al punto 2e dell'informativa.";

//
// STILI
//
const TextStyle EVIDENZA = TextStyle(fontWeight: FontWeight.bold, fontSize: 18);
const TextStyle BOLD = TextStyle(fontWeight: FontWeight.bold);
const TextStyle H1 = TextStyle(fontWeight: FontWeight.bold, fontSize: 22);
final ButtonStyle STILE_BOTTONE = ButtonStyle(
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
    backgroundColor: MaterialStateProperty.all<Color>(COLORE_TERZIARIO),
    foregroundColor: MaterialStateProperty.all<Color>(Colors.white));
final ButtonStyle STILE_NOTIFICA = ButtonStyle(
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
    backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
    surfaceTintColor: MaterialStateProperty.all<Color>(Colors.white),
    foregroundColor: MaterialStateProperty.all<Color>(Colors.black));
final ButtonStyle STILE_BOTTONE_ROSSO = ButtonStyle(
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
    backgroundColor: MaterialStateProperty.all<Color>(Colors.red.shade400),
    foregroundColor: MaterialStateProperty.all<Color>(Colors.white));
const Widget SPACER = SizedBox(height: 25);
const Widget SPACER_MINIMAL = SizedBox(height: 5);
const Widget SPACER_MEDIUM = SizedBox(height: 10);

//
// HEADER
//
final Image HEADER = Image.network('https://picsum.photos/1200/600', height: 200, fit: BoxFit.fitWidth);
const NetworkImage PROFILE_PICTURE = NetworkImage('https://picsum.photos/200');

//
// NOME SOCIAL
//
const String NOME_AGENZIA = 'Soluzioni Assicurative CUDRIG';
final SvgPicture IMAGE_FACEBOOK = SvgPicture.asset('lib/assets/facebook.svg', width: 50);
final SvgPicture IMAGE_GOOGLE = SvgPicture.asset('lib/assets/google.svg', width: 40);
final SvgPicture IMAGE_INSTAGRAM = SvgPicture.asset('lib/assets/instagram.svg', width: 40);
final SvgPicture IMAGE_LINKEDIN = SvgPicture.asset('lib/assets/linkedin.svg', width: 50);
final SvgPicture IMAGE_PINTEREST = SvgPicture.asset('lib/assets/pinterest.svg', width: 50);
final SvgPicture IMAGE_TWITTER = SvgPicture.asset('lib/assets/twitter.svg', width: 50);

final AssetImage IMAGE_BUILDING = AssetImage('lib/assets/agenzia.png');
final Image IMAGE_WEBSITE = Image.asset('lib/assets/website.png', width: 40);

//
// INFO
//
const AssetImage IMAGE_INFO = AssetImage('lib/assets/info.png');
const String TITOLO_SEZIONE_INFO = 'Info e Sedi';
/*const Widget NOTIFICA = Padding(
    padding: EdgeInsets.all(8.0),
    child: Text(NOTIFICA_TEXT,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)));*/
const String NOTIFICA_TEXT = 'Il 24 aprile, la sede di Roma resterà chiusa la mattina';
const String EVIDENZA_ORARI = 'Orari di Apertura';
const String EVIDENZA_INDIRIZZI = 'Indirizzi';
const String TESTO_BOTTONE_GOOGLE_MAPS = 'Guidami alla sede!';
const String TESTO_CONTATTI_TELEFONICI = 'Contatti Telefonici';
//NUOVO
const NetworkImage IMMAGINE_SEDE = NetworkImage('https://picsum.photos/200');
const String NOME_SEDE_UNO = 'Via del Corso';
const String ORARI_SEDE_UNO = 'Lunedì - Venerdì: 8:30/12:30 - 14:30/18:30\nSabato: 8:30/12:30\nDomenica: Chiuso';
const String INDIRIZZO_SEDE_UNO = 'Via del Corso, 142 - 00123 Roma (RM)';
final Uri LINK_SEDE_UNO = Uri.parse('https://www.linkedin.com/company/soluzioni-assicurative-cudrig/');
final Uri RECENSIONE_SEDE_UNO = Uri.parse('https://www.linkedin.com/company/soluzioni-assicurative-cudrig/');
//NUOVISSIMO
final List<Uri> SEDI_LOGO_ARRAY = [
  Uri.parse('https://picsum.photos/200'),
  Uri.parse('https://picsum.photos/180'),
  Uri.parse('https://picsum.photos/210'),
];
final List<String> SEDI_NOMI_ARRAY = [
  'Sede n. 1',
  'Sede n. 2',
  'Sede n. 3',
];
final List<String> SEDI_INDIRIZZI_ARRAY = [
  'Via del casale delle Cornacchiole, 22/b - 00123 Roma (RM), Italia',
  'Via degli Orti di Monterosi, 425 - 00113 Viterbo (VT)',
  'Via de la Resistenza, 148 - 13002 Milano (MI)',
];
final List<String> SEDI_ORARI_ARRAY = [
  'Lunedì - Venerdì: 08:30/12:30 - 14:30/18:30\nSabato: 08:30/12:30\nDomenica: Chiusi',
  'Lunedì - Venerdì: 08:30/12:30 - 15:30/19:00\nSabato: 08:30/12:30\nDomenica: Chiusi',
  'Lunedì - Venerdì: 09:30/14:30 - 16:00/20:80\nSabato e Domenica: Chiusi',
];
final List<Uri> SEDI_MAPS_ARRAY = [
  Uri.parse('https://maps.app.goo.gl/K8PppjCrnrbpwJqW9'),
  Uri.parse('https://maps.app.goo.gl/SsJBduxEK9pxmRaP9'),
  Uri.parse('https://maps.app.goo.gl/shAv4Jh5JfAoecxUA'),
];
final List<Uri> SEDI_TELEFONO_ARRAY = [
  Uri.parse('tel:+393333333333'),
  Uri.parse('tel:+393333333333'),
  Uri.parse('tel:+393333333333'),
];
final List<Uri> SEDI_EMAIL_ARRAY = [
  Uri.parse('mailto:asdfg@gfdsa.fd'),
  Uri.parse('mailto:asdfg@gfdsa.fd'),
  Uri.parse('mailto:asdfg@gfdsa.fd'),
];
final List<Uri> SEDI_SITO_ARRAY = [
  Uri.parse('https://www.smp-digital.it'),
  Uri.parse('https://www.smp-digital.it'),
  Uri.parse('https://www.smp-digital.it'),
];
final List<Uri> SEDI_RECENSIONI_ARRAY = [
  Uri.parse('https://www.smp-digital.it'),
  Uri.parse('https://www.smp-digital.it'),
  Uri.parse('https://www.smp-digital.it'),
];

//
// CONTATTI
//
const AssetImage IMAGE_CONTATTI = AssetImage('lib/assets/contatti.png');
const String TITOLO_SEZIONE_CONTATTI = 'Numeri Utili e Contatti';
const String CONTATTI_TESTO =
    'Sede Principale:\nVia del Corso, 127 - 00123 Roma (RM)\nTelefono: +39 06 789456\ne-mail: info@cudrig.it';

//
// SINISTRO
//
const AssetImage IMAGE_CRASH = AssetImage('lib/assets/crash.png');
const String TITOLO_SEZIONE_DENUNCIA = 'Denuncia un sinistro';
const String SINISTRO_EVIDENZA = 'Denunciare un sinistro non è mai stato così facile:';
const String SINISTRO_TEXT =
    'Clicca sul tasto qui sotto per compilare il modulo online, allegando il tuo CAI (vecchio CID) compilato e le foto dei veicoli!';
const String SINISTRO_TESTO_BOTTONE = 'Denuncia un Sinistro!';

//
// CAI
//
const String TESTOCAI =
    'Hai smarrito il tuo modello CAI (Vecchio CID)? Non c\'è problema, ti basterà cliccare qui sotto per scaricarlo e stamparlo!';
const String LABEL_BOTTONE_CAI = 'CAI';

//
// WEBVIEW
//
const String TITOLO_FORM_DENUNCIA = 'Denuncia un sinistro';

//
// CHIAMATA RAPIDA
//
const String CHIAMATA_RAPIDA_TOOLTIP = 'Chiamaci Ora!';

//
// METODI
//
const String ERRORE = 'Impossibile effettuare l\'operazione. Contatta l\'amministrazione';
void openUrl(Uri uri) async {
  if (!await launchUrl(uri)) {
    throw Exception(ERRORE);
  }
}

//
// LINK
//
final Uri EMAIL_LINK = Uri.parse('mailto:info@roba.it');
final Uri TELEFONO_LINK = Uri.parse('tel:+393333333333');
final Uri MAPPA_LINK = Uri.parse(
    'https://www.google.com/maps/place/25062+Concesio+BS/@45.6029892,10.1964036,14z/data=!3m1!4b1!4m6!3m5!1s0x478179d4beb328ef:0x862df3996374faf1!8m2!3d45.5998218!4d10.22268!16zL20vMDQxd2hs?hl=it&entry=ttu');
final Uri FACEBOOK_LINK = Uri.parse('https://www.facebook.com/cudrigassicurazioni');
final Uri INSTAGRAM_LINK = Uri.parse('https://www.instagram.com/soluzioni_assicurative_cudrig');
final Uri LINKEDIN_LINK = Uri.parse('https://www.linkedin.com/company/soluzioni-assicurative-cudrig/');
final Uri PINTEREST_LINK = Uri.parse('https://www.pinterest.com');
final Uri TWITTER_LINK = Uri.parse('https://www.twitter.com');
final Uri GOOGLE_LINK = Uri.parse('https://maps.app.goo.gl/nv921bgSKNR7GPys9');
final Uri SITO_LINK = Uri.parse('https://www.google.com/reviews');
final Uri CAI_LINK = Uri.parse('https://www.documenti.it/cidonline.pdf');
final Uri URL_FORM_DENUNCIA = Uri.parse('https://www.seemypage.it');
final Uri REVIEW_LINK = Uri.parse('https://g.page/r/CdRhtF4CB0MfEBM/review');

// RANDOM

const String MESSAGGIO = 'Contenuto';

// CHIAMATE RAPIDE
const String CHIAMATA_RAPIDA_UNO = 'Chiamata Rapida';
const String CHIAMATA_RAPIDA_DUE = 'Whatsapp';
const String CHIAMATA_RAPIDA_TRE = 'e-mail Rapida';
final Uri LINK_CHIAMATA_RAPIDA_UNO = Uri.parse('tel:');
final Uri LINK_CHIAMATA_RAPIDA_DUE = Uri.parse('https://wa.me/');
final Uri LINK_CHIAMATA_RAPIDA_TRE = Uri.parse('mailto:');
