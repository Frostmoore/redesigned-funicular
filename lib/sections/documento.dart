import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:accordion/accordion.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Documento extends StatelessWidget {
  const Documento({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppProvider>().config!;
    final width = MediaQuery.of(context).size.width;

    final url = Uri.parse(
      'https://${constants.PATH}/documento.php?id=${constants.ID}',
    );

    return Accordion(
      headerBorderWidth: 1,
      headerBorderColor: Colors.transparent,
      headerBorderColorOpened: Colors.transparent,
      headerBackgroundColor: Colors.transparent,
      headerBackgroundColorOpened: Colors.transparent,
      contentBorderColor: Colors.transparent,
      contentBackgroundColor: const Color(0xfff8f9fa),
      contentHorizontalPadding: 8,
      disableScrolling: true,
      headerPadding: EdgeInsets.zero,
      children: [
        AccordionSection(
          rightIcon: const Icon(Icons.arrow_drop_down_rounded, size: 45),
          header: SizedBox(
            width: width - 16,
            height: 70,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/assets/documento_immagine.png'),
                  fit: BoxFit.contain,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Text(config.documentoTitolo, style: constants.H1),
              ),
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text(
                  config.documentoTesto,
                  textAlign: TextAlign.center,
                  style: constants.EVIDENZA,
                ),
                SizedBox(
                  width: width,
                  child: ElevatedButton.icon(
                    onPressed: () => constants.openUrl(url),
                    label: const Text('Carica un Documento'),
                    icon: const Icon(Icons.web),
                    style: constants.buttonStyle(config.tertiaryColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
