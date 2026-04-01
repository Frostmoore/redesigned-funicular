import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/models/app_config.dart';
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InformazioniAgenzie extends StatelessWidget {
  const InformazioniAgenzie({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppProvider>().config!;

    return Column(
      children: [
        for (final sede in config.sedi)
          _SedeCard(sede: sede, config: config),
      ],
    );
  }
}

class _SedeCard extends StatelessWidget {
  final Sede sede;
  final AppConfig config;

  const _SedeCard({required this.sede, required this.config});

  @override
  Widget build(BuildContext context) {
    final terziario = config.tertiaryColor;
    final secondario = config.secondaryColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black38),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.5),
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
                    padding: const EdgeInsets.all(10),
                    child: Image(image: constants.IMAGE_BUILDING, height: 80),
                  ),
                ],
              ),
              Text(
                sede.nome,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              Text(
                sede.indirizzo.replaceAll('\\n', '\n'),
                textAlign: TextAlign.center,
              ),
              constants.SPACER,
              Text(
                sede.testoOrari,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                sede.orari.replaceAll('\\n', '\n'),
                textAlign: TextAlign.center,
              ),
              constants.SPACER,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (sede.telefono.isNotEmpty)
                    _iconBtn(Icons.phone, terziario,
                        () => constants.openUrl(Uri.parse('tel:${sede.telefono}'))),
                  if (sede.email.isNotEmpty)
                    _iconBtn(Icons.email, terziario,
                        () => constants.openUrl(Uri.parse('mailto:${sede.email}'))),
                  if (sede.mappa.isNotEmpty)
                    _iconBtn(Icons.pin_drop, terziario,
                        () => constants.openUrl(Uri.parse(sede.mappa))),
                  if (sede.sito.isNotEmpty)
                    _iconBtn(Icons.language, terziario,
                        () => constants.openUrl(Uri.parse(sede.sito))),
                ],
              ),
              constants.SPACER_MEDIUM,
              if (sede.recensioni.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => constants.openUrl(Uri.parse(sede.recensioni)),
                      icon: const Icon(Icons.reviews),
                      label: const Text('Lasciaci una Recensione!'),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(secondario),
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) => IconButton(
    icon: Icon(icon),
    onPressed: onTap,
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(color),
      foregroundColor: WidgetStateProperty.all(Colors.white),
    ),
  );
}
