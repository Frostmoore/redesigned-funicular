import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/sections/informazioni.dart';
import 'package:Assidim/sections/notifica.dart';
import 'package:accordion/accordion.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Info extends StatelessWidget {
  const Info({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppProvider>().config!;
    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        constants.SPACER,
        const Notifica(),
        Accordion(
          headerBorderWidth: 1,
          headerBorderColor: Colors.transparent,
          headerBorderColorOpened: Colors.transparent,
          headerBackgroundColor: Colors.transparent,
          headerBackgroundColorOpened: Colors.transparent,
          contentBorderColor: Colors.transparent,
          contentBackgroundColor: const Color(0xfff8f9fa),
          contentHorizontalPadding: 0,
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
                      image: AssetImage('lib/assets/info_immagine.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 18, 8, 8),
                    child: Text(config.infoTitolo, style: constants.H1),
                  ),
                ),
              ),
              content: const InformazioniAgenzie(),
            ),
          ],
        ),
      ],
    );
  }
}
