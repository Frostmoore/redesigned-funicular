import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:Assidim/assets/constants.dart' as constants;
import 'dart:convert' as convert;
import 'package:Assidim/sections/liberatoria.dart';

class PreventivoForm extends StatefulWidget {
  @override
  _PreventivoFormState createState() => _PreventivoFormState();
}

class _PreventivoFormState extends State<PreventivoForm> {
  int? selectedOption;
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  bool isLoading = false;
  late Future<Map> _ageData;

  void initState() {
    super.initState();
    _ageData = getData();
  }

  // Controllers for Option 1 fields
  TextEditingController nomeController = TextEditingController();
  TextEditingController cognomeController = TextEditingController();
  TextEditingController indirizzoController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController telefonoController = TextEditingController();
  TextEditingController descrizione1Controller = TextEditingController();
  bool privacy = false;
  XFile? fronteDoc;
  XFile? retroDoc;
  XFile? documentazione;

  Map<String, bool> uploadStatus = {
    'fronteDoc': false,
    'retroDoc': false,
  };

  Future<Map> getData() async {
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

  void scegliFonteECarica(String key) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Scatta con Fotocamera'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera, key);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Scegli dalla Galleria'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery, key);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void pickImage(ImageSource source, String key) async {
    final pickedFile = await _picker.pickImage(source: source);
    setState(() {
      if (key == 'fronteDoc') {
        fronteDoc = pickedFile;
      } else if (key == 'retroDoc') {
        retroDoc = pickedFile;
      } else if (key == 'documentazione') {
        documentazione = pickedFile;
      }
      uploadStatus[key] = pickedFile != null;
    });
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      final requestData = {
        'id': constants.ID,
        'nome': nomeController.text,
        'cognome': cognomeController.text,
        'indirizzo': indirizzoController.text,
        'email': emailController.text,
        'telefono': telefonoController.text,
        'privacy': privacy,
        'descrizione': descrizione1Controller.text,
      };

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://www.hybridandgogsv.it/res/api/v1/preventivo.php'),
      );

      request.fields['data'] = jsonEncode(requestData);

      if (fronteDoc != null) {
        request.files.add(
            await http.MultipartFile.fromPath('fronteDoc', fronteDoc!.path));
      }

      if (retroDoc != null) {
        request.files
            .add(await http.MultipartFile.fromPath('retroDoc', retroDoc!.path));
      }

      if (documentazione != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'documentazione', documentazione!.path));
      }

      final response = await request.send();

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final responseJson = jsonDecode(responseData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dati inviati con successo!')),
        );
        Navigator.of(context).pop();
      } else {
        final responseData = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nell\'invio dei dati!')),
        );
        print('Errore HTTP ${response.statusCode}: $responseData');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Richiesta Preventivo')),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      constants.COLORE_PRINCIPALE)),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildOption1Form(),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                  'Acconsento al trattamento dei miei dati personali, così come esposto nella liberatoria Privacy'),
                            ),
                            Checkbox(
                              value: privacy,
                              onChanged: (value) =>
                                  setState(() => privacy = value!),
                            ),
                          ],
                        ),
                        _liberatoria(),
                        ElevatedButton(
                          onPressed: submitForm,
                          style: constants.STILE_BOTTONE_ALT,
                          child: Text('Invia il Modulo'),
                        ),
                        constants.SPACER,
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildOption1Form() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              "Dati dell'Interessato",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "Compila con i dati dell'interessato",
              style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
            ),
            constants.SPACER_MEDIUM,
            TextFormField(
              controller: nomeController,
              decoration: InputDecoration(labelText: 'Nome'),
              validator: (value) =>
                  value!.isEmpty ? 'Campo obbligatorio' : null,
            ),
            TextFormField(
              controller: cognomeController,
              decoration: InputDecoration(labelText: 'Cognome'),
              validator: (value) =>
                  value!.isEmpty ? 'Campo obbligatorio' : null,
            ),
            TextFormField(
              controller: indirizzoController,
              decoration: InputDecoration(labelText: 'Indirizzo'),
            ),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) =>
                  value!.isEmpty ? 'Campo obbligatorio' : null,
            ),
            TextFormField(
              controller: telefonoController,
              decoration: InputDecoration(labelText: 'Telefono'),
              validator: (value) =>
                  value!.isEmpty ? 'Campo obbligatorio' : null,
            ),
            TextFormField(
              controller: descrizione1Controller,
              decoration:
                  InputDecoration(labelText: 'Descrizione della Richiesta'),
              maxLines: 8,
              validator: (value) =>
                  value!.isEmpty ? 'Campo obbligatorio' : null,
            ),
            constants.SPACER,
            Text(
              "Sezione Documenti",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Ricordati di caricare foto LEGGIBILI di tutti i documenti richiesti",
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
            ElevatedButton(
              onPressed: () => scegliFonteECarica('documentazione'),
              style: constants.STILE_BOTTONE,
              child: Column(
                children: [
                  Text('Carica Documento Rilevante (opzionale)'),
                  if (uploadStatus['documentazione'] == true)
                    Text('Caricato', style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => scegliFonteECarica('fronteDoc'),
              style: constants.STILE_BOTTONE,
              child: Column(
                children: [
                  Text('Carica Fronte Documento di Identità'),
                  if (uploadStatus['fronteDoc'] == true)
                    Text('Caricato', style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => scegliFonteECarica('retroDoc'),
              style: constants.STILE_BOTTONE,
              child: Column(
                children: [
                  Text('Carica Retro Documento di Identità'),
                  if (uploadStatus['retroDoc'] == true)
                    Text('Caricato', style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _liberatoria() {
    return FutureBuilder(
      future: _ageData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: constants.COLORE_PRINCIPALE,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Errore: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('Nessun dato disponibile'));
        } else {
          return Column(
            children: [
              ElevatedButton(
                onPressed: () => _dialogBuilder(context, snapshot.data),
                child: Text("Vedi la Liberatoria Privacy"),
              ),
              constants.SPACER,
            ],
          );
        }
      },
    );
  }

  Future<void> _dialogBuilder(BuildContext context, data) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return Theme(
            data:
                Theme.of(context).copyWith(dialogBackgroundColor: Colors.white),
            child: AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              title: const Text("Informativa Privacy"),
              content: Liberatoria(data: data),
              actions: <Widget>[
                TextButton(
                  style: constants.STILE_BOTTONE,
                  child: const Text("Chiudi"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );
        });
  }
}
