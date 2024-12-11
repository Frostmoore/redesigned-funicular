import 'package:flutter/material.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:accordion/accordion.dart';

class Preventivo extends StatefulWidget {
  final data;
  const Preventivo({super.key, required this.data});

  @override
  State<Preventivo> createState() => _PreventivoState();
}

class _PreventivoState extends State<Preventivo> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var preventivo_immagine_dirty = widget.data['preventivo_immagine'];
    var preventivo_immagine = 'lib/assets/preventivo_immagine.png';
    var preventivo_titolo = widget.data['preventivo_titolo'];
    var preventivo_testo_grassetto = widget.data['preventivo_testo_grassetto'];
    //var denuncia_testo = widget.data['denuncia_testo'];
    var baseAddr = 'https://' + constants.PATH + '/preventivo.php?id=';
    var id = constants.ID;
    //var token = '&token=' + constants.TOKEN;
    var todo = baseAddr + id; // + token;
    var url_preventivo = Uri.parse(todo);
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
                  image: AssetImage(preventivo_immagine),
                  fit: BoxFit.contain,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Text(
                  preventivo_titolo,
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
                      preventivo_testo_grassetto,
                      textAlign: TextAlign.center,
                      style: constants.EVIDENZA,
                    ),
                    // constants.SPACER,
                    // Text(
                    //   preventivo_testo,
                    //   textAlign: TextAlign.center,
                    // ),
                    // constants.SPACER,
                    SizedBox(
                      width: width,
                      child: ElevatedButton.icon(
                        onPressed: () => constants.openUrl(url_preventivo),
                        label: const Text('Vai al Modulo'),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(colore_terziario),
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
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
