import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

class ChiamataRapida extends StatelessWidget {
  const ChiamataRapida({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppProvider>().config!;
    final primary = config.primaryColor;

    return SpeedDial(
      icon: Icons.phone,
      backgroundColor: primary,
      children: [
        if (config.quickTelefono.isNotEmpty)
          SpeedDialChild(
            child: const Icon(Icons.phone_android_outlined),
            foregroundColor: Colors.white,
            backgroundColor: primary,
            label: constants.CHIAMATA_RAPIDA_UNO,
            shape: const CircleBorder(eccentricity: 0),
            onTap: () => constants.openUrl(
              Uri.parse('tel:${config.quickTelefono}'),
            ),
          ),
        if (config.quickWhatsapp.isNotEmpty)
          SpeedDialChild(
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: constants.svgWhatsapp(),
            ),
            foregroundColor: Colors.white,
            backgroundColor: primary,
            label: constants.CHIAMATA_RAPIDA_DUE,
            shape: const CircleBorder(eccentricity: 0),
            onTap: () => constants.openUrl(Uri.parse(config.quickWhatsapp)),
          ),
        if (config.quickEmail.isNotEmpty)
          SpeedDialChild(
            child: const Icon(Icons.email),
            foregroundColor: Colors.white,
            backgroundColor: primary,
            label: constants.CHIAMATA_RAPIDA_TRE,
            shape: const CircleBorder(eccentricity: 0),
            onTap: () => constants.openUrl(
              Uri.parse('mailto:${config.quickEmail}'),
            ),
          ),
      ],
    );
  }
}
