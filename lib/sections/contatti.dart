import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/models/app_config.dart';
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/sections/indirizzo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Contatti extends StatelessWidget {
  const Contatti({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppProvider>().config!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 0,
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          childrenPadding: EdgeInsets.zero,
          shape: const Border(),
          collapsedShape: const Border(),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF26A69A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.contacts_rounded,
              color: Color(0xFF26A69A),
              size: 22,
            ),
          ),
          title: Text(
            config.contattiTitolo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
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
          ],
        ),
      ),
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
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 8),
      childrenPadding: EdgeInsets.zero,
      shape: const Border(),
      collapsedShape: const Border(),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.phone_in_talk_rounded, color: color, size: 18),
      ),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      children: [
        for (final entry in entries)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    constants.openUrl(Uri.parse('tel:${entry.number}')),
                icon: const Icon(Icons.phone, size: 18),
                label: Text(entry.label),
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.all(color),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                  elevation: WidgetStateProperty.all(0),
                ),
              ),
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
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 8),
      childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      shape: const Border(),
      collapsedShape: const Border(),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.location_on_rounded, color: color, size: 18),
      ),
      title: const Text(
        'Dove mi Trovo',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      children: [
        Indirizzo(),
      ],
    );
  }
}
