import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:accordion/accordion.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Sinistro extends StatelessWidget {
  const Sinistro({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppProvider>().config!;
    final width = MediaQuery.of(context).size.width;

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
                  image: AssetImage('lib/assets/denuncia_immagine.png'),
                  fit: BoxFit.contain,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 18, 8, 8),
                child: Text(config.denunciaTitolo, style: constants.H1),
              ),
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text(
                  config.denunciaTesto,
                  textAlign: TextAlign.center,
                  style: constants.EVIDENZA,
                ),
                SizedBox(
                  width: width,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/sinistro'),
                    label: const Text(constants.SINISTRO_TESTO_BOTTONE),
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
