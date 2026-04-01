import 'package:accordion/accordion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';

import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/models/polizza.dart';
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/sections/responses/nessun_risultato.dart';

class AccountPolizze extends StatefulWidget {
  const AccountPolizze({super.key});

  @override
  State<AccountPolizze> createState() => _AccountPolizzeState();
}

class _AccountPolizzeState extends State<AccountPolizze> {
  late Future<List<Polizza>> _polizzeFuture;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    _polizzeFuture = provider.polizzeService.fetchPolizze(
      config: provider.config!,
      user: provider.currentUser!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Polizza>>(
      future: _polizzeFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(
              color: constants.COLORE_PRINCIPALE,
            ),
          );
        }

        if (!snap.hasData || snap.data!.isEmpty) return const NessunRisultato();

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snap.data!.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, i) => _polizzaTile(context, snap.data![i]),
        );
      },
    );
  }

  Widget _scadenzaLabel(String? dataEffettoTitoloStr) {
    if (dataEffettoTitoloStr == null || dataEffettoTitoloStr.isEmpty) {
      return _dot(Colors.green);
    }
    try {
      final dataScadenza = DateTime.parse(dataEffettoTitoloStr);
      final giorniMancanti = dataScadenza.difference(DateTime.now()).inDays;

      if (giorniMancanti < 0) return _dot(Colors.red.shade200);
      if (giorniMancanti <= 10) return _dot(Colors.red);
      if (giorniMancanti <= 31) return _dot(Colors.yellow.shade700);
      return _dot(Colors.green);
    } catch (_) {
      return _dot(Colors.green);
    }
  }

  Widget _dot(Color color) => Container(
        margin: const EdgeInsets.only(left: 8),
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black26),
        ),
      );

  Widget _polizzaTile(BuildContext context, Polizza p) {
    return Accordion(
      headerBorderWidth: 1,
      headerBorderColor: Colors.transparent,
      headerBorderColorOpened: Colors.transparent,
      headerBackgroundColor: Colors.transparent,
      headerBackgroundColorOpened: Colors.transparent,
      contentBorderColor: Colors.transparent,
      contentBackgroundColor: Colors.transparent,
      disableScrolling: true,
      headerPadding: EdgeInsets.zero,
      children: [
        AccordionSection(
          rightIcon: const Icon(Icons.arrow_drop_down_rounded, size: 45),
          header: SizedBox(
            height: 70,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/assets/polizze_immagine.png'),
                  fit: BoxFit.contain,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  8,
                  18,
                  MediaQuery.of(context).size.width / 3,
                  8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        p.titolo,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _scadenzaLabel(p.dataEffettoTitolo),
                  ],
                ),
              ),
            ),
          ),
          content: Builder(builder: (_) {
            Widget progressSection = const SizedBox();

            if (p.dataEffettoTitolo != null && p.dataEffettoTitolo!.isNotEmpty) {
              final dataEffetto = DateTime.parse(p.dataEffettoTitolo!);
              final oggi = DateTime.now();

              DateTime prossimaRicorrenza = DateTime(
                oggi.year,
                dataEffetto.month,
                dataEffetto.day,
              );
              if (prossimaRicorrenza.isBefore(oggi)) {
                prossimaRicorrenza = DateTime(
                  oggi.year + 1,
                  dataEffetto.month,
                  dataEffetto.day,
                );
              }

              final giorniTotali = prossimaRicorrenza
                  .subtract(const Duration(days: 365))
                  .difference(prossimaRicorrenza)
                  .inDays
                  .abs();
              final giorniMancanti =
                  prossimaRicorrenza.difference(oggi).inDays.clamp(0, 365);
              final progress = 1 - (giorniMancanti / giorniTotali);

              progressSection = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade300,
                    color: constants.COLORE_PRINCIPALE,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Mancano $giorniMancanti giorni alla prossima rata',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HtmlWidget(
                  '''
<strong>Contraente:</strong> ${p.nominativo ?? '-'}<br>
<strong>N. Polizza:</strong> ${p.numeroPolizza ?? '-'}<br>
<strong>Compagnia:</strong> ${p.descCompagnia ?? '-'}<br>
<strong>Ramo:</strong> ${p.descRamo ?? '-'}<br>
<strong>Prodotto:</strong> ${p.descProdotto ?? '-'}<br>
<strong>Frazionamento:</strong> ${p.frazionamento ?? '-'}<br>
<strong>Data Ultima Copertura:</strong> ${Polizza.formatDateIt(p.dataEffettoUltimaCopertura)}<br>
<strong>Prossima Scadenza:</strong> ${Polizza.formatDateIt(p.dataEffettoTitolo)}<br>
<strong>Data Scadenza Contratto:</strong> ${Polizza.formatDateIt(p.dataScadenzaContratto)}<br>
<strong>Stato Polizza:</strong> ${p.descStatoPolizza ?? '-'}<br>
''',
                ),
                progressSection,
              ],
            );
          }),
        ),
      ],
    );
  }
}
