import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:Assidim/assets/constants.dart' as constants;
import 'dart:convert' as convert;
import 'package:Assidim/sections/liberatoria.dart';

class SinistroForm extends StatefulWidget {
  @override
  _SinistroFormState createState() => _SinistroFormState();
}

class _SinistroFormState extends State<SinistroForm> {
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
  XFile? fotoCAI;
  XFile? fronteDoc;
  XFile? retroDoc;

  // Controllers for Option 2 fields
  TextEditingController luogoIncidenteController = TextEditingController();
  bool feriti = false;
  DateTime? dataOraIncidente;
  TextEditingController dataOraIncidenteController = TextEditingController();
  TextEditingController descrizione2Controller = TextEditingController();

  // Controllers for Contraente / Assicurato Veicolo A
  TextEditingController cognomeAController = TextEditingController();
  TextEditingController nomeAController = TextEditingController();
  TextEditingController codiceFiscaleAController = TextEditingController();
  TextEditingController indirizzoAController = TextEditingController();
  TextEditingController capAController = TextEditingController();
  TextEditingController statoAController = TextEditingController();
  TextEditingController telefonoAController = TextEditingController();
  TextEditingController emailAController = TextEditingController();

  // Controllers for Veicolo A
  TextEditingController marcaVeicoloAController = TextEditingController();
  TextEditingController targaTelaioAController = TextEditingController();
  TextEditingController statoImmatricolazioneController =
      TextEditingController();

  // Controllers for Conducente Veicolo A
  TextEditingController cognomeConducenteController = TextEditingController();
  TextEditingController nomeConducenteController = TextEditingController();
  DateTime? dataNascitaConducente;
  TextEditingController dataNascitaConducenteController =
      TextEditingController();
  TextEditingController codiceFiscaleConducenteController =
      TextEditingController();
  TextEditingController indirizzoConducenteController = TextEditingController();
  TextEditingController capConducenteController = TextEditingController();
  TextEditingController telefonoConducenteController = TextEditingController();
  TextEditingController numeroPatenteController = TextEditingController();
  TextEditingController categoriaPatenteController = TextEditingController();
  DateTime? validitaPatente;
  TextEditingController validitaPatenteController = TextEditingController();

  // Controllers for Veicolo B
  TextEditingController targaTelaioBController = TextEditingController();

  // Controllers for Option 3
  TextEditingController nome3Controller = TextEditingController();
  TextEditingController cognome3Controller = TextEditingController();
  TextEditingController indirizzo3Controller = TextEditingController();
  TextEditingController email3Controller = TextEditingController();
  TextEditingController telefono3Controller = TextEditingController();
  TextEditingController descrizione3Controller = TextEditingController();
  TextEditingController dataIncidente3Controller = TextEditingController();
  DateTime? dataIncidente3;
  XFile? documentazione;

  // Circostanze dell'Incidente
  Map<String, bool> circostanze = {
    'fermataA': false,
    'fermataB': false,
    'ripartenzaA': false,
    'ripartenzaB': false,
    'parcheggioA': false,
    'parcheggioB': false,
    'uscitaA': false,
    'uscitaB': false,
    'entrataA': false,
    'entrataB': false,
    'immissioneRotatoriaA': false,
    'immissioneRotatoriaB': false,
    'circolazioneRotatoriaA': false,
    'circolazioneRotatoriaB': false,
    'tamponamentoA': false,
    'tamponamentoB': false,
    'filaDiversaA': false,
    'filaDiversaB': false,
    'cambioFilaA': false,
    'cambioFilaB': false,
    'sorpassoA': false,
    'sorpassoB': false,
    'destraA': false,
    'destraB': false,
    'sinistraA': false,
    'sinistraB': false,
    'retromarciaA': false,
    'retromarciaB': false,
    'contromanoA': false,
    'contromanoB': false,
    'provenienzaDestraA': false,
    'provenienzaDestraB': false,
    'precedenzaA': false,
    'precedenzaB': false,
  };

  Map<String, bool> uploadStatus = {
    'fotoCAI': false,
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

  void pickImage(ImageSource source, String key) async {
    final pickedFile = await _picker.pickImage(source: source);
    setState(() {
      if (key == 'fotoCAI') {
        fotoCAI = pickedFile;
      } else if (key == 'fronteDoc') {
        fronteDoc = pickedFile;
      } else if (key == 'retroDoc') {
        retroDoc = pickedFile;
      } else if (key == 'documentazione') {
        documentazione = pickedFile;
      }
      uploadStatus[key] = pickedFile != null;
    });
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (time != null) {
        setState(() {
          dataOraIncidente =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
          dataOraIncidenteController.text =
              "${dataOraIncidente!.day}/${dataOraIncidente!.month}/${dataOraIncidente!.year} ${dataOraIncidente!.hour}:${dataOraIncidente!.minute}";
        });
      }
    }
  }

  Future<void> _selectDateTimeBirth(BuildContext context,
      {required TextEditingController controller,
      required Function(DateTime) onDateSelected}) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );

    if (date != null) {
      setState(() {
        onDateSelected(date);
        controller.text = "${date.day}/${date.month}/${date.year}";
      });
    }
  }

  Future<void> _selectDateTimeLicense(BuildContext context,
      {required TextEditingController controller,
      required Function(DateTime) onDateSelected}) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );

    if (date != null) {
      setState(() {
        onDateSelected(date);
        controller.text = "${date.day}/${date.month}/${date.year}";
      });
    }
  }

  Future<void> _selectDateTimeSinistro(BuildContext context,
      {required TextEditingController controller,
      required Function(DateTime) onDateSelected}) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );

    if (date != null) {
      setState(() {
        onDateSelected(date);
        controller.text = "${date.day}/${date.month}/${date.year}";
      });
    }
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (uploadStatus['fronteDoc'] == true &&
          uploadStatus['retroDoc'] == true) {
        setState(() {
          isLoading = true;
        });

        final requestData;

        if (selectedOption == 1) {
          requestData = {
            'id': constants.ID,
            'option': 1,
            'nome': nomeController.text,
            'cognome': cognomeController.text,
            'indirizzo': indirizzoController.text,
            'email': emailController.text,
            'telefono': telefonoController.text,
            'privacy': privacy,
            'descrizione': descrizione1Controller.text,
            'dataSinistro': dataIncidente3?.toIso8601String(),
          };
        } else if (selectedOption == 2) {
          requestData = {
            'id': constants.ID,
            'option': 2,
            'dataOraIncidente': dataOraIncidente?.toIso8601String(),
            'luogoIncidente': luogoIncidenteController.text,
            'descrizione': descrizione2Controller.text,
            'feriti': feriti,
            'contraente': {
              'cognome': cognomeAController.text,
              'nome': nomeAController.text,
              'codiceFiscale': codiceFiscaleAController.text,
              'indirizzo': indirizzoAController.text,
              'cap': capAController.text,
              'stato': statoAController.text,
              'telefono': telefonoAController.text,
              'email': emailAController.text,
            },
            'veicoloA': {
              'marca': marcaVeicoloAController.text,
              'targaTelaio': targaTelaioAController.text,
              'statoImmatricolazione': statoImmatricolazioneController.text,
            },
            'conducente': {
              'cognome': cognomeConducenteController.text,
              'nome': nomeConducenteController.text,
              'dataNascita': dataNascitaConducente?.toIso8601String(),
              'codiceFiscale': codiceFiscaleConducenteController.text,
              'indirizzo': indirizzoConducenteController.text,
              'cap': capConducenteController.text,
              'telefono': telefonoConducenteController.text,
              'numeroPatente': numeroPatenteController.text,
              'categoriaPatente': categoriaPatenteController.text,
              'validitaPatente': validitaPatente?.toIso8601String(),
            },
            'veicoloB': {
              'targaTelaio': targaTelaioBController.text,
            },
            'circostanze': circostanze,
            'privacy': privacy,
          };
        } else {
          requestData = {
            'id': constants.ID,
            'option': 3,
            'nome': nome3Controller.text,
            'cognome': cognome3Controller.text,
            'indirizzo': indirizzo3Controller.text,
            'email': email3Controller.text,
            'telefono': telefono3Controller.text,
            'descrizione': descrizione3Controller.text,
            'privacy': privacy,
            'dataSinistro': dataIncidente3?.toIso8601String(),
          };
        }

        // final requestData = selectedOption == 1
        //     ? {
        //         'id': constants.ID,
        //         'option': 1,
        //         'nome': nomeController.text,
        //         'cognome': cognomeController.text,
        //         'indirizzo': indirizzoController.text,
        //         'email': emailController.text,
        //         'telefono': telefonoController.text,
        //         'privacy': privacy,
        //       }
        //     : {
        //         'id': constants.ID,
        //         'option': 2,
        //         'dataOraIncidente': dataOraIncidente?.toIso8601String(),
        //         'luogoIncidente': luogoIncidenteController.text,
        //         'feriti': feriti,
        //         'contraente': {
        //           'cognome': cognomeAController.text,
        //           'nome': nomeAController.text,
        //           'codiceFiscale': codiceFiscaleAController.text,
        //           'indirizzo': indirizzoAController.text,
        //           'cap': capAController.text,
        //           'stato': statoAController.text,
        //           'telefono': telefonoAController.text,
        //           'email': emailAController.text,
        //         },
        //         'veicoloA': {
        //           'marca': marcaVeicoloAController.text,
        //           'targaTelaio': targaTelaioAController.text,
        //           'statoImmatricolazione': statoImmatricolazioneController.text,
        //         },
        //         'conducente': {
        //           'cognome': cognomeConducenteController.text,
        //           'nome': nomeConducenteController.text,
        //           'dataNascita': dataNascitaConducente?.toIso8601String(),
        //           'codiceFiscale': codiceFiscaleConducenteController.text,
        //           'indirizzo': indirizzoConducenteController.text,
        //           'cap': capConducenteController.text,
        //           'telefono': telefonoConducenteController.text,
        //           'numeroPatente': numeroPatenteController.text,
        //           'categoriaPatente': categoriaPatenteController.text,
        //           'validitaPatente': validitaPatente?.toIso8601String(),
        //         },
        //         'veicoloB': {
        //           'targaTelaio': targaTelaioBController.text,
        //         },
        //         'circostanze': circostanze,
        //         'privacy': privacy,
        //       };

        final request = http.MultipartRequest(
          'POST',
          Uri.parse('https://www.hybridandgogsv.it/res/api/v1/sinistro.php'),
        );

        request.fields['data'] = jsonEncode(requestData);

        if (fotoCAI != null) {
          request.files
              .add(await http.MultipartFile.fromPath('fotoCAI', fotoCAI!.path));
        }

        if (fronteDoc != null) {
          request.files.add(
              await http.MultipartFile.fromPath('fronteDoc', fronteDoc!.path));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Carica la foto del documento!')),
          );
        }

        if (retroDoc != null) {
          request.files.add(
              await http.MultipartFile.fromPath('retroDoc', retroDoc!.path));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Carica la foto del documento!')),
          );
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
          print(responseData);
          final responseJson = jsonDecode(responseData);
          // Handle success
          // print('Success: $responseJson');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Dati inviati con successo!')),
          );
          Navigator.of(context).pop();
        } else {
          // Handle error
          // print('Error: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore nell\'invio dei dati!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Carica le foto dei documenti e accetta la Liberatoria Privacy!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Modulo Sinistro')),
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
                        DropdownButton<int>(
                          value: selectedOption,
                          hint: Text('Seleziona un\'opzione'),
                          onChanged: (value) =>
                              setState(() => selectedOption = value),
                          items: [
                            DropdownMenuItem(
                                value: 1,
                                child:
                                    Text('Auto: Ho compilato il modulo CAI')),
                            DropdownMenuItem(
                                value: 2,
                                child: Text(
                                    'Auto: NON ho compilato il modulo CAI')),
                            DropdownMenuItem(
                                value: 3, child: Text('Sinistro NON Auto')),
                          ],
                        ),
                        constants.SPACER,
                        if (selectedOption == 1) _buildOption1Form(),
                        if (selectedOption == 2) _buildOption2Form(),
                        if (selectedOption == 3) _buildOption3Form(),
                        if (selectedOption == 1 ||
                            selectedOption == 2 ||
                            selectedOption == 3)
                          constants.SPACER,
                        if (selectedOption == 1 ||
                            selectedOption == 2 ||
                            selectedOption == 3)
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
                        if (selectedOption == 1 ||
                            selectedOption == 2 ||
                            selectedOption == 3)
                          _liberatoria(),
                        if (selectedOption == 1 ||
                            selectedOption == 2 ||
                            selectedOption == 3)
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
              validator: (value) =>
                  value!.isEmpty ? 'Campo obbligatorio' : null,
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
              controller: dataIncidente3Controller,
              readOnly: true,
              onTap: () => _selectDateTimeSinistro(context,
                  controller: dataIncidente3Controller,
                  onDateSelected: (date) => dataIncidente3 = date),
              decoration: InputDecoration(labelText: 'Data del Sinistro'),
              validator: (value) =>
                  value!.isEmpty ? 'Campo obbligatorio' : null,
            ),
            TextFormField(
              controller: descrizione1Controller,
              decoration:
                  InputDecoration(labelText: 'Descrizione del Sinistro'),
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
              onPressed: () => pickImage(ImageSource.gallery, 'fotoCAI'),
              style: constants.STILE_BOTTONE,
              child: Column(
                children: [
                  Text('Carica Foto Modulo CAI'),
                  if (uploadStatus['fotoCAI'] == true)
                    Text('Caricato', style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => pickImage(ImageSource.gallery, 'fronteDoc'),
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
              onPressed: () => pickImage(ImageSource.gallery, 'retroDoc'),
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

  Widget _buildOption2Form() {
    return Center(
      child: Column(
        children: [
          Text(
            "Sezione Dettagli Incidente",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            "Compila con i dettagli dell'incidente",
            style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
          ),
          constants.SPACER_MEDIUM,
          TextFormField(
            controller: luogoIncidenteController,
            decoration: InputDecoration(labelText: 'Luogo dell\'Incidente'),
            validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          TextFormField(
            controller: dataOraIncidenteController,
            readOnly: true,
            onTap: () => _selectDateTime(context),
            decoration:
                InputDecoration(labelText: 'Data e Ora dell\'Incidente'),
            validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          CheckboxListTile(
            title: Text('Feriti'),
            value: feriti,
            onChanged: (value) => setState(() => feriti = value!),
          ),
          TextFormField(
            controller: descrizione2Controller,
            decoration: InputDecoration(labelText: 'Descrizione del Sinistro'),
            maxLines: 8,
            validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          constants.SPACER,
          Text(
            "Sezione Dettagli Contraente / Assicurato Veicolo A",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            "Compila con i dettagli del Contraente / Assicurato del Veicolo A",
            style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
          ),
          constants.SPACER_MEDIUM,
          TextFormField(
            controller: cognomeAController,
            decoration: InputDecoration(labelText: 'Cognome'),
            validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          TextFormField(
            controller: nomeAController,
            decoration: InputDecoration(labelText: 'Nome'),
            validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          TextFormField(
            controller: codiceFiscaleAController,
            decoration:
                InputDecoration(labelText: 'Codice Fiscale o Partita IVA'),
            validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          TextFormField(
            controller: indirizzoAController,
            decoration: InputDecoration(labelText: 'Indirizzo'),
            validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          TextFormField(
            controller: capAController,
            decoration: InputDecoration(labelText: 'CAP'),
            validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          TextFormField(
            controller: statoAController,
            decoration: InputDecoration(labelText: 'Stato'),
            validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          TextFormField(
            controller: telefonoAController,
            decoration: InputDecoration(labelText: 'Telefono'),
            validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          TextFormField(
            controller: emailAController,
            decoration: InputDecoration(labelText: 'Email'),
            validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          constants.SPACER,
          Text(
            "Sezione Dettagli Veicolo A",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            "Compila con i dettagli del Veicolo A",
            style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
          ),
          constants.SPACER_MEDIUM,
          TextFormField(
            controller: marcaVeicoloAController,
            decoration: InputDecoration(labelText: 'Marca e Modello'),
            validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          TextFormField(
            controller: targaTelaioAController,
            decoration: InputDecoration(labelText: 'N. di Targa o Telaio'),
            validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          TextFormField(
            controller: statoImmatricolazioneController,
            decoration: InputDecoration(labelText: 'Stato di Immatricolazione'),
            validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          constants.SPACER,
          Text(
            "Sezione Dettagli Conducente Veicolo A",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            "Compila con i dettagli del Conducente del Veicolo A",
            style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
          ),
          constants.SPACER_MEDIUM,
          TextFormField(
            controller: cognomeConducenteController,
            decoration: InputDecoration(labelText: 'Cognome'),
            validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          TextFormField(
            controller: nomeConducenteController,
            decoration: InputDecoration(labelText: 'Nome'),
            validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          TextFormField(
            controller: dataNascitaConducenteController,
            readOnly: true,
            onTap: () => _selectDateTimeBirth(context,
                controller: dataNascitaConducenteController,
                onDateSelected: (date) => dataNascitaConducente = date),
            decoration:
                InputDecoration(labelText: 'Data di Nascita del Conducente'),
            validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          TextFormField(
            controller: codiceFiscaleConducenteController,
            decoration: InputDecoration(labelText: 'Codice Fiscale'),
            validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          TextFormField(
            controller: indirizzoConducenteController,
            decoration: InputDecoration(labelText: 'Indirizzo'),
            validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          TextFormField(
            controller: capConducenteController,
            decoration: InputDecoration(labelText: 'CAP'),
            validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          TextFormField(
            controller: telefonoConducenteController,
            decoration: InputDecoration(labelText: 'Telefono'),
            validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          TextFormField(
            controller: numeroPatenteController,
            decoration: InputDecoration(labelText: 'N. Patente'),
            validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          TextFormField(
            controller: categoriaPatenteController,
            decoration:
                InputDecoration(labelText: 'Categoria Patente (A, B...)'),
            validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          TextFormField(
            controller: validitaPatenteController,
            readOnly: true,
            onTap: () => _selectDateTimeLicense(context,
                controller: validitaPatenteController,
                onDateSelected: (date) => dataNascitaConducente = date),
            decoration: InputDecoration(labelText: 'Data Validità Patente'),
            validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          constants.SPACER,
          Text(
            "Sezione Dettagli Veicolo B",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            "Compila con i dettagli del Veicolo B",
            style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
          ),
          constants.SPACER_MEDIUM,
          TextFormField(
            controller: targaTelaioBController,
            decoration: InputDecoration(labelText: 'N. di Targa o Telaio'),
            validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          constants.SPACER,
          constants.SPACER,
          Text(
            "Sezione Circostanze dell'Incidente",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            "Seleziona se e quale veicolo era in una delle seguenti circostanze:",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
          constants.SPACER,
          Text(
            "Era in Fermata o in Sosta",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Veicolo A"),
              Checkbox(
                  value: circostanze["fermataA"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["fermataA"] = value as bool;
                    });
                  }),
              Text("Veicolo B"),
              Checkbox(
                  value: circostanze["fermataB"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["fermataB"] = value as bool;
                    });
                  }),
            ],
          ),
          constants.SPACER,
          Text(
            "Ripartiva dopo una sosta o apriva una portiera",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Veicolo A"),
              Checkbox(
                  value: circostanze["ripartenzaA"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["ripartenzaA"] = value as bool;
                    });
                  }),
              Text("Veicolo B"),
              Checkbox(
                  value: circostanze["ripartenzaB"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["ripartenzaB"] = value as bool;
                    });
                  }),
            ],
          ),
          constants.SPACER,
          Text(
            "Stava parcheggiando",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Veicolo A"),
              Checkbox(
                  value: circostanze["parcheggioA"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["parcheggioA"] = value as bool;
                    });
                  }),
              Text("Veicolo B"),
              Checkbox(
                  value: circostanze["parcheggioB"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["parcheggioB"] = value as bool;
                    });
                  }),
            ],
          ),
          constants.SPACER,
          Text(
            "Usciva da un parcheggio, da un luogo privato, da una strada vicinale",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Veicolo A"),
              Checkbox(
                  value: circostanze["uscitaA"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["uscitaA"] = value as bool;
                    });
                  }),
              Text("Veicolo B"),
              Checkbox(
                  value: circostanze["uscitaB"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["uscitaB"] = value as bool;
                    });
                  }),
            ],
          ),
          constants.SPACER,
          Text(
            "Entrava in un parcheggio, in un luogo privato, in una strada vicinale",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Veicolo A"),
              Checkbox(
                  value: circostanze["entrataA"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["entrataA"] = value as bool;
                    });
                  }),
              Text("Veicolo B"),
              Checkbox(
                  value: circostanze["entrataB"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["entrataB"] = value as bool;
                    });
                  }),
            ],
          ),
          constants.SPACER,
          Text(
            "Si immetteva in una piazza a senso rotatorio",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Veicolo A"),
              Checkbox(
                  value: circostanze["immissioneRotatoriaA"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["immissioneRotatoriaA"] = value as bool;
                    });
                  }),
              Text("Veicolo B"),
              Checkbox(
                  value: circostanze["immissioneRotatoriaB"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["immissioneRotatoriaB"] = value as bool;
                    });
                  }),
            ],
          ),
          constants.SPACER,
          Text(
            "Circolava su una piazza a senso rotatorio",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Veicolo A"),
              Checkbox(
                  value: circostanze["circolazioneRotatoriaA"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["circolazioneRotatoriaA"] = value as bool;
                    });
                  }),
              Text("Veicolo B"),
              Checkbox(
                  value: circostanze["circolazioneRotatoriaB"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["circolazioneRotatoriaB"] = value as bool;
                    });
                  }),
            ],
          ),
          constants.SPACER,
          Text(
            "Tamponava, procedendo nello stesso senso di marcia e nella stessa fila",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Veicolo A"),
              Checkbox(
                  value: circostanze["tamponamentoA"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["tamponamentoA"] = value as bool;
                    });
                  }),
              Text("Veicolo B"),
              Checkbox(
                  value: circostanze["tamponamentoB"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["tamponamentoB"] = value as bool;
                    });
                  }),
            ],
          ),
          constants.SPACER,
          Text(
            "Procedeva nello stesso senso di marcia ma in una fila diversa",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Veicolo A"),
              Checkbox(
                  value: circostanze["filaDiversaA"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["filaDiversaA"] = value as bool;
                    });
                  }),
              Text("Veicolo B"),
              Checkbox(
                  value: circostanze["filaDiversaB"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["filaDiversaB"] = value as bool;
                    });
                  }),
            ],
          ),
          constants.SPACER,
          Text(
            "Cambiava fila",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Veicolo A"),
              Checkbox(
                  value: circostanze["cambioFilaA"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["cambioFilaA"] = value as bool;
                    });
                  }),
              Text("Veicolo B"),
              Checkbox(
                  value: circostanze["cambioFilaB"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["cambioFilaB"] = value as bool;
                    });
                  }),
            ],
          ),
          constants.SPACER,
          Text(
            "Sorpassava",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Veicolo A"),
              Checkbox(
                  value: circostanze["sorpassoA"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["sorpassoA"] = value as bool;
                    });
                  }),
              Text("Veicolo B"),
              Checkbox(
                  value: circostanze["sorpassoB"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["sorpassoB"] = value as bool;
                    });
                  }),
            ],
          ),
          constants.SPACER,
          Text(
            "Girava a destra",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Veicolo A"),
              Checkbox(
                  value: circostanze["destraA"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["destraA"] = value as bool;
                    });
                  }),
              Text("Veicolo B"),
              Checkbox(
                  value: circostanze["destraB"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["destraB"] = value as bool;
                    });
                  }),
            ],
          ),
          constants.SPACER,
          Text(
            "Girava a sinistra",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Veicolo A"),
              Checkbox(
                  value: circostanze["sinistraA"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["sinistraA"] = value as bool;
                    });
                  }),
              Text("Veicolo B"),
              Checkbox(
                  value: circostanze["sinistraB"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["sinistraB"] = value as bool;
                    });
                  }),
            ],
          ),
          constants.SPACER,
          Text(
            "Retrocedeva",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Veicolo A"),
              Checkbox(
                  value: circostanze["retromarciaA"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["retromarciaA"] = value as bool;
                    });
                  }),
              Text("Veicolo B"),
              Checkbox(
                  value: circostanze["retromarciaB"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["retromarciaB"] = value as bool;
                    });
                  }),
            ],
          ),
          constants.SPACER,
          Text(
            "Invadeva la sede stradale riservata alla circolazione in senso inverso",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Veicolo A"),
              Checkbox(
                  value: circostanze["contromanoA"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["contromanoA"] = value as bool;
                    });
                  }),
              Text("Veicolo B"),
              Checkbox(
                  value: circostanze["contromanoB"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["contromanoB"] = value as bool;
                    });
                  }),
            ],
          ),
          constants.SPACER,
          Text(
            "Proveniva da destra",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Veicolo A"),
              Checkbox(
                  value: circostanze["provenienzaDestraA"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["provenienzaDestraA"] = value as bool;
                    });
                  }),
              Text("Veicolo B"),
              Checkbox(
                  value: circostanze["provenienzaDestraB"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["provenienzaDestraB"] = value as bool;
                    });
                  }),
            ],
          ),
          constants.SPACER,
          Text(
            "Non aveva osservato il segnale di precedenza o di semaforo rosso",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Veicolo A"),
              Checkbox(
                  value: circostanze["precedenzaA"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["precedenzaA"] = value as bool;
                    });
                  }),
              Text("Veicolo B"),
              Checkbox(
                  value: circostanze["precedenzaB"],
                  onChanged: (bool? value) {
                    setState(() {
                      circostanze["precedenzaB"] = value as bool;
                    });
                  }),
            ],
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
            onPressed: () => pickImage(ImageSource.gallery, 'fronteDoc'),
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
            onPressed: () => pickImage(ImageSource.gallery, 'retroDoc'),
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
    );
  }

  Widget _buildOption3Form() {
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
              controller: nome3Controller,
              decoration: InputDecoration(labelText: 'Nome'),
              validator: (value) =>
                  value!.isEmpty ? 'Campo obbligatorio' : null,
            ),
            TextFormField(
              controller: cognome3Controller,
              decoration: InputDecoration(labelText: 'Cognome'),
              validator: (value) =>
                  value!.isEmpty ? 'Campo obbligatorio' : null,
            ),
            TextFormField(
              controller: email3Controller,
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) =>
                  value!.isEmpty ? 'Campo obbligatorio' : null,
            ),
            TextFormField(
              controller: indirizzo3Controller,
              decoration: InputDecoration(labelText: 'Indirizzo'),
              validator: (value) =>
                  value!.isEmpty ? 'Campo obbligatorio' : null,
            ),
            TextFormField(
              controller: telefono3Controller,
              decoration: InputDecoration(labelText: 'Telefono'),
              validator: (value) =>
                  value!.isEmpty ? 'Campo obbligatorio' : null,
            ),
            TextFormField(
              controller: dataIncidente3Controller,
              readOnly: true,
              onTap: () => _selectDateTimeSinistro(context,
                  controller: dataIncidente3Controller,
                  onDateSelected: (date) => dataIncidente3 = date),
              decoration: InputDecoration(labelText: 'Data del Sinistro'),
              validator: (value) =>
                  value!.isEmpty ? 'Campo obbligatorio' : null,
            ),
            TextFormField(
              controller: descrizione3Controller,
              decoration:
                  InputDecoration(labelText: 'Descrizione del Sinistro'),
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
              onPressed: () => pickImage(ImageSource.gallery, 'documentazione'),
              style: constants.STILE_BOTTONE,
              child: Column(
                children: [
                  Text('Carica Documento rilevante per il sinistro'),
                  if (uploadStatus['documentazione'] == true)
                    Text('Caricato', style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => pickImage(ImageSource.gallery, 'fronteDoc'),
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
              onPressed: () => pickImage(ImageSource.gallery, 'retroDoc'),
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
