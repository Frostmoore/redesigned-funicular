import 'package:flutter/material.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:accordion/accordion.dart';

class Sinistro extends StatefulWidget {
  final data;
  const Sinistro({super.key, required this.data});

  @override
  State<Sinistro> createState() => _SinistroState();
}

class _SinistroState extends State<Sinistro> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var denuncia_immagine_dirty = widget.data['denuncia_immagine'];
    var denuncia_immagine = 'lib/assets/denuncia_immagine.png';
    var denuncia_titolo = widget.data['denuncia_titolo'];
    var denuncia_testo_grassetto = widget.data['denuncia_testo_grassetto'];
    //var denuncia_testo = widget.data['denuncia_testo'];
    var baseAddr = 'https://' + constants.PATH + '/denuncia_sinistro.php?id=';
    var id = constants.ID;
    //var token = '&token=' + constants.TOKEN;
    var todo = baseAddr + id; // + token;
    var url_denuncia = Uri.parse(todo);
    var colori = widget.data['colori'].split('|');
    var colore_terziario = Color(int.parse(colori[2]));

    return Accordion(
      headerBorderWidth: 1,
      headerBorderColor: Colors.transparent,
      headerBorderColorOpened: Colors.transparent,
      headerBackgroundColor: Colors.transparent,
      headerBackgroundColorOpened: Colors.transparent,
      contentBorderColor: Colors.transparent,
      contentBackgroundColor: Colors.transparent,
      contentHorizontalPadding: 8,
      disableScrolling: true,
      headerPadding: const EdgeInsets.all(0),
      children: [
        AccordionSection(
          rightIcon: const Icon(
            Icons.arrow_drop_down_rounded,
            size: 45,
          ),
          header: SizedBox(
            width: width - 16,
            height: 70,
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(denuncia_immagine),
                  fit: BoxFit.contain,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(8, 18, 8, 8),
                child: Text(
                  denuncia_titolo,
                  style: constants.H1,
                ),
              ),
            ),
          ),
          content: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      denuncia_testo_grassetto,
                      textAlign: TextAlign.center,
                      style: constants.EVIDENZA,
                    ),
                    // constants.SPACER,
                    // Text(
                    //   denuncia_testo,
                    //   textAlign: TextAlign.center,
                    // ),
                    // constants.SPACER,
                    SizedBox(
                      width: width,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/sinistro',
                            arguments: widget.data,
                          );
                        },
                        label: const Text(constants.SINISTRO_TESTO_BOTTONE),
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              colore_terziario),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                        ),
                        icon: const Icon(Icons.web),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
