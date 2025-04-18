import 'package:flutter/material.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:accordion/accordion.dart';
import 'package:Assidim/sections/indirizzo.dart';

class Contatti extends StatefulWidget {
  final data;
  const Contatti({super.key, required this.data});

  @override
  State<Contatti> createState() => _ContattiState();
}

class _ContattiState extends State<Contatti> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var contatti_immagine_dirty = widget.data['contatti_immagine'];
    var contatti_immagine = 'lib/assets/contatti_immagine.png';
    var contatti_titolo = widget.data['contatti_titolo'];
    //var contatti_testo = widget.data['contatti_testo'];
    var numeriUtiliLabels = widget.data['numeri_utili_labels'].split('|');
    var numeriUtiliColori = widget.data['numeri_utili_colori'].split('|');
    // Numeri Utili
    var numeriUtiliSalute = widget.data['numeri_utili_salute'].split('|');
    var numeriUtiliAssistenza =
        widget.data['numeri_utili_assistenza'].split('|');
    var numeriUtiliNoleggio = widget.data['numeri_utili_noleggio'].split('|');

    return Accordion(
      headerBorderWidth: 1,
      headerBorderColor: Colors.transparent,
      headerBorderColorOpened: Colors.transparent,
      headerBackgroundColor: Colors.transparent,
      headerBackgroundColorOpened: Colors.transparent,
      contentBorderColor: Colors.transparent,
      contentBackgroundColor: Colors.transparent,
      contentHorizontalPadding: 0,
      disableScrolling: true,
      headerPadding: const EdgeInsets.all(0),
      children: [
        AccordionSection(
          rightIcon: const Icon(
            Icons.arrow_drop_down_rounded,
            size: 45,
          ),
          header: SizedBox(
            height: 70,
            width: width - 16,
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(contatti_immagine),
                  fit: BoxFit.contain,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Text(
                  contatti_titolo,
                  textAlign: TextAlign.start,
                  style: constants.H1,
                ),
              ),
            ),
          ),
          content: Column(
            children: [
              //constants.SPACER,
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
                child: Column(
                  children: [
                    if (numeriUtiliLabels[0] != '')
                      Accordion(
                        headerBorderWidth: 1,
                        headerBorderColor: Colors.transparent,
                        headerBorderColorOpened: Colors.transparent,
                        headerBackgroundColor: Colors.transparent,
                        headerBackgroundColorOpened: Colors.transparent,
                        contentBorderColor: Colors.transparent,
                        contentBackgroundColor: Colors.transparent,
                        contentHorizontalPadding: 0,
                        disableScrolling: true,
                        headerPadding: const EdgeInsets.all(0),
                        children: [
                          AccordionSection(
                            rightIcon: const Icon(
                              Icons.arrow_drop_down_rounded,
                              size: 45,
                            ),
                            header: Row(
                              children: [
                                Expanded(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Color(
                                          int.parse(numeriUtiliColori[0])),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0, vertical: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // const Icon(
                                          //   Icons.monitor_heart,
                                          //   color: Colors.white,
                                          // ),
                                          Text(
                                            numeriUtiliLabels[0],
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            content: Column(
                              children: [
                                for (var i = 0;
                                    i < numeriUtiliSalute.length;
                                    i++)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton.icon(
                                      onPressed: () => constants.openUrl(
                                        Uri.parse('tel:' +
                                            numeriUtiliSalute[i].split('.')[1]),
                                      ),
                                      icon: const Icon(
                                        Icons.phone,
                                      ),
                                      label: Text(
                                        numeriUtiliSalute[i].split('.')[0],
                                      ),
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                          Color(
                                            int.parse(numeriUtiliColori[0]),
                                          ),
                                        ),
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.white),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    if (numeriUtiliLabels[1] != '')
                      Accordion(
                        headerBorderWidth: 1,
                        headerBorderColor: Colors.transparent,
                        headerBorderColorOpened: Colors.transparent,
                        headerBackgroundColor: Colors.transparent,
                        headerBackgroundColorOpened: Colors.transparent,
                        contentBorderColor: Colors.transparent,
                        contentBackgroundColor: Colors.transparent,
                        contentHorizontalPadding: 0,
                        disableScrolling: true,
                        headerPadding: const EdgeInsets.all(0),
                        children: [
                          AccordionSection(
                            rightIcon: const Icon(
                              Icons.arrow_drop_down_rounded,
                              size: 45,
                            ),
                            header: Row(
                              children: [
                                Expanded(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Color(
                                          int.parse(numeriUtiliColori[1])),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0, vertical: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // const Icon(
                                          //   Icons.car_repair,
                                          //   color: Colors.white,
                                          // ),
                                          Text(
                                            numeriUtiliLabels[1],
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            content: Column(
                              children: [
                                for (var k = 0;
                                    k < numeriUtiliAssistenza.length;
                                    k++)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton.icon(
                                      onPressed: () => constants.openUrl(
                                        Uri.parse('tel:' +
                                            numeriUtiliAssistenza[k]
                                                .split('.')[1]),
                                      ),
                                      icon: const Icon(
                                        Icons.phone,
                                      ),
                                      label: Text(
                                        numeriUtiliAssistenza[k].split('.')[0],
                                      ),
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                          Color(
                                            int.parse(numeriUtiliColori[1]),
                                          ),
                                        ),
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.white),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    if (numeriUtiliLabels[2] != '')
                      Accordion(
                        headerBorderWidth: 1,
                        headerBorderColor: Colors.transparent,
                        headerBorderColorOpened: Colors.transparent,
                        headerBackgroundColor: Colors.transparent,
                        headerBackgroundColorOpened: Colors.transparent,
                        contentBorderColor: Colors.transparent,
                        contentBackgroundColor: Colors.transparent,
                        contentHorizontalPadding: 0,
                        disableScrolling: true,
                        headerPadding: const EdgeInsets.all(0),
                        children: [
                          AccordionSection(
                            rightIcon: const Icon(
                              Icons.arrow_drop_down_rounded,
                              size: 45,
                            ),
                            header: Row(
                              children: [
                                Expanded(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Color(
                                          int.parse(numeriUtiliColori[2])),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0, vertical: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // const Icon(
                                          //   Icons.car_rental,
                                          //   color: Colors.white,
                                          // ),
                                          Text(
                                            numeriUtiliLabels[2],
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            content: Column(
                              children: [
                                for (var l = 0;
                                    l < numeriUtiliNoleggio.length;
                                    l++)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton.icon(
                                      onPressed: () => constants.openUrl(
                                        Uri.parse('tel:' +
                                            numeriUtiliNoleggio[l]
                                                .split('.')[1]),
                                      ),
                                      icon: const Icon(
                                        Icons.phone,
                                      ),
                                      label: Text(
                                        numeriUtiliNoleggio[l].split('.')[0],
                                      ),
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                          Color(
                                            int.parse(numeriUtiliColori[2]),
                                          ),
                                        ),
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.white),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    Accordion(
                      headerBorderWidth: 1,
                      headerBorderColor: Colors.transparent,
                      headerBorderColorOpened: Colors.transparent,
                      headerBackgroundColor: Colors.transparent,
                      headerBackgroundColorOpened: Colors.transparent,
                      contentBorderColor: Colors.transparent,
                      contentBackgroundColor: Colors.transparent,
                      contentHorizontalPadding: 0,
                      disableScrolling: true,
                      headerPadding: const EdgeInsets.all(0),
                      children: [
                        AccordionSection(
                          rightIcon: const Icon(
                            Icons.arrow_drop_down_rounded,
                            size: 45,
                          ),
                          header: Row(
                            children: [
                              Expanded(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color:
                                        Color(int.parse(numeriUtiliColori[2])),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5)),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 0, vertical: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Icon(
                                        //   Icons.push_pin,
                                        //   color: Colors.white,
                                        // ),
                                        Text(
                                          'Dove mi Trovo',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          content: Column(
                            children: [
                              // for (var l = 0; l < numeriUtiliNoleggio.length; l++)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Indirizzo(),
                              ),
                            ],
                          ),
                        ),
                      ],
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
