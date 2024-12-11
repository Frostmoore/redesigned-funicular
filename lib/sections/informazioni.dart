import 'package:flutter/material.dart';
import 'package:Assidim/assets/constants.dart' as constants;

class InformazioniAgenzie extends StatefulWidget {
  final data;

  const InformazioniAgenzie({super.key, required this.data});

  @override
  State<InformazioniAgenzie> createState() => _InformazioniAgenzieState();
}

class _InformazioniAgenzieState extends State<InformazioniAgenzie> {
  @override
  Widget build(BuildContext context) {
    //Map arrayNomi = constants.SEDI_NOMI_ARRAY.asMap();

    var listaNomi = widget.data['info_nomi_sedi'];
    var listaIndirizzi = widget.data['info_indirizzi_sedi'];
    var listaTestoOrari = widget.data['info_testo_orari'];
    var listaOrariSedi = widget.data['info_orari_sedi'];
    var listaRecensioniSedi = widget.data['info_recensioni_sedi'];
    var listaTelefonoSedi = widget.data['info_telefono_sedi'];
    var listaEmailSedi = widget.data['info_email_sedi'];
    var listaMappaSedi = widget.data['info_mappa_sedi'];
    var listaSitoSedi = widget.data['info_sito_sedi'];
    //var gigi = 'stronzo';

    // Create lists
    var info_nomi_sedi = listaNomi.split('|');
    var info_indirizzi_sedi = listaIndirizzi.split('|');
    var info_testo_orari = listaTestoOrari.split('|');
    var info_orari_sedi = listaOrariSedi.split('|');
    var info_recensioni_sedi = listaRecensioniSedi.split('|');
    var info_telefono_sedi = listaTelefonoSedi.split('|');
    var info_email_sedi = listaEmailSedi.split('|');
    var info_mappa_sedi = listaMappaSedi.split('|');
    var info_sito_sedi = listaSitoSedi.split('|');
    var colori = widget.data['colori'].split('|');
    var colore_secondario = int.parse(colori[1]);
    var colore_terziario = int.parse(colori[2]);

    return Column(
      children: [
        for (var index = 0; index < info_nomi_sedi.length; index++)
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black38),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image(image: constants.IMAGE_BUILDING, height: 80),
                        ),
                      ],
                    ),
                    Text(
                      info_nomi_sedi[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    Text(
                      info_indirizzi_sedi[index].replaceAll('\\n', '\n'),
                      textAlign: TextAlign.center,
                    ),
                    constants.SPACER,
                    Text(
                      info_testo_orari[index], // COPIARE QUI
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      info_orari_sedi[index].replaceAll('\\n', '\n'),
                      textAlign: TextAlign.center,
                    ),
                    constants.SPACER,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (info_telefono_sedi[index] != '')
                          IconButton(
                            icon: const Icon(Icons.phone),
                            onPressed: () => constants.openUrl(
                                Uri.parse('tel:' + info_telefono_sedi[index])),
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Color(colore_terziario)),
                              foregroundColor:
                                  const MaterialStatePropertyAll(Colors.white),
                            ),
                          ),
                        if (info_email_sedi[index] != '')
                          IconButton(
                            icon: const Icon(Icons.email),
                            onPressed: () => constants.openUrl(
                                Uri.parse('mailto:' + info_email_sedi[index])),
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Color(colore_terziario)),
                              foregroundColor:
                                  const MaterialStatePropertyAll(Colors.white),
                            ),
                          ),
                        if (info_mappa_sedi[index] != '')
                          IconButton(
                            icon: const Icon(Icons.pin_drop),
                            onPressed: () => constants
                                .openUrl(Uri.parse(info_mappa_sedi[index])),
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Color(colore_terziario)),
                              foregroundColor:
                                  const MaterialStatePropertyAll(Colors.white),
                            ),
                          ),
                        if (info_sito_sedi[index] != '')
                          IconButton(
                            icon: const Icon(Icons.language),
                            onPressed: () => constants
                                .openUrl(Uri.parse(info_sito_sedi[index])),
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Color(colore_terziario)),
                              foregroundColor:
                                  const MaterialStatePropertyAll(Colors.white),
                            ),
                          ),
                      ],
                    ),
                    constants.SPACER_MEDIUM,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (info_recensioni_sedi[index] != '')
                          ElevatedButton.icon(
                            onPressed: () => constants.openUrl(
                                Uri.parse(info_recensioni_sedi[index])),
                            icon: const Icon(Icons.reviews),
                            label: const Text(
                              'Lasciaci una Recensione!',
                              textAlign: TextAlign.center,
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Color(colore_secondario)),
                              foregroundColor:
                                  const MaterialStatePropertyAll(Colors.white),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5))),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
      ],
    );
  }
}
