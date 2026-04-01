import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/models/app_config.dart';
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/sections/indirizzo.dart';
import 'package:accordion/accordion.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Contatti extends StatelessWidget {
  const Contatti({super.key});

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
      contentHorizontalPadding: 0,
      disableScrolling: true,
      headerPadding: EdgeInsets.zero,
      children: [
        AccordionSection(
          rightIcon: const Icon(Icons.arrow_drop_down_rounded, size: 45),
          header: SizedBox(
            height: 70,
            width: width - 16,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/assets/contatti_immagine.png'),
                  fit: BoxFit.contain,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Text(config.contattiTitolo, style: constants.H1),
              ),
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Column(
              children: [
                if (config.numeriUtiliLabels.isNotEmpty &&
                    config.numeriUtiliLabels[0].isNotEmpty)
                  _NumeriUtiliGroup(
                    label: config.numeriUtiliLabels[0],
                    color: config.numeriUtiliColori[0],
                    entries: config.numeriUtiliSalute,
                  ),
                if (config.numeriUtiliLabels.length > 1 &&
                    config.numeriUtiliLabels[1].isNotEmpty)
                  _NumeriUtiliGroup(
                    label: config.numeriUtiliLabels[1],
                    color: config.numeriUtiliColori[1],
                    entries: config.numeriUtiliAssistenza,
                  ),
                if (config.numeriUtiliLabels.length > 2 &&
                    config.numeriUtiliLabels[2].isNotEmpty)
                  _NumeriUtiliGroup(
                    label: config.numeriUtiliLabels[2],
                    color: config.numeriUtiliColori[2],
                    entries: config.numeriUtiliNoleggio,
                  ),
                _DoveMiTrovo(color: config.tertiaryColor),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Gruppo numeri utili ─────────────────────────────────────────────────────

class _NumeriUtiliGroup extends StatelessWidget {
  final String label;
  final Color color;
  final List<ContactEntry> entries;

  const _NumeriUtiliGroup({
    required this.label,
    required this.color,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    return Accordion(
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
          header: _coloredHeader(label, color),
          content: Column(
            children: [
              for (final entry in entries)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        constants.openUrl(Uri.parse('tel:${entry.number}')),
                    icon: const Icon(Icons.phone),
                    label: Text(entry.label),
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      backgroundColor: WidgetStateProperty.all(color),
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Dove mi Trovo ───────────────────────────────────────────────────────────

class _DoveMiTrovo extends StatelessWidget {
  final Color color;
  const _DoveMiTrovo({required this.color});

  @override
  Widget build(BuildContext context) {
    return Accordion(
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
          header: _coloredHeader('Dove mi Trovo', color),
          content: Padding(
            padding: const EdgeInsets.all(8),
            child: Indirizzo(),
          ),
        ),
      ],
    );
  }
}

// ─── Helper ──────────────────────────────────────────────────────────────────

Widget _coloredHeader(String label, Color color) => Row(
  children: [
    Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    ),
  ],
);
