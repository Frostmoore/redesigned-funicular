import 'package:flutter/material.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// IMPORTA IL NOTIFIER DA main.dart
import 'package:Assidim/main.dart' show notificaAggiornaTrigger;

class Notifica extends StatefulWidget {
  const Notifica({super.key});

  @override
  State<Notifica> createState() => _NotificaState();
}

class _NotificaState extends State<Notifica> with TickerProviderStateMixin {
  List<Map<String, dynamic>> nonViste = [];
  Set<String> viste = {};
  bool loading = false;
  bool _isLoading = false; // FLAG per evitare richieste parallele
  int currentPage = 0;
  int? _cardDismissedIndex; // per animazione eliminazione

  @override
  void initState() {
    super.initState();
    notificaAggiornaTrigger.addListener(_caricaTutto);
    _caricaTutto();
  }

  @override
  void dispose() {
    notificaAggiornaTrigger.removeListener(_caricaTutto);
    super.dispose();
  }

  Future<void> _caricaTutto() async {
    if (_isLoading) {
      print('[NOTIFICA] Skip: chiamata già in corso!');
      return;
    }
    _isLoading = true;
    setState(() => loading = true);

    final prefs = await SharedPreferences.getInstance();
    viste = prefs.getStringList('notifiche_viste')?.toSet() ?? {};
    print('[NOTIFICA] Notifiche già viste: $viste');

    final url = Uri.https(
      constants.PATH,
      'res/api/v1/noti_gene.php',
      {'agenziaid': constants.ID.toString()},
    );
    print('[NOTIFICA] Chiamata API: $url');

    try {
      final response = await http.get(url);

      print('[NOTIFICA] BODY ricevuto dal server:');
      print('<<<INIZIO BODY>>>\n${response.body}\n<<<FINE BODY>>>');

      if (response.statusCode == 200) {
        final List dati = json.decode(response.body);
        print('[NOTIFICA] Ricevute ${dati.length} notifiche dal server');
        List<Map<String, dynamic>> filtrate = [];
        for (final n in dati) {
          final id = n['id'].toString();
          final scadenza = n['notifica_scadenza'] ?? '';
          final oggi = DateTime.now();
          bool isScaduta = false;
          if (scadenza.isNotEmpty) {
            try {
              final dataScad = DateTime.tryParse(scadenza);
              isScaduta = dataScad != null && dataScad.isBefore(oggi);
            } catch (_) {
              print('[NOTIFICA] Errore nel parsing data: $scadenza');
            }
          }
          if (!viste.contains(id) && !isScaduta) {
            filtrate.add(Map<String, dynamic>.from(n));
          }
        }
        setState(() {
          nonViste = filtrate;
          loading = false;
        });
        print(
            '[NOTIFICA] Notifiche NON viste e NON scadute: ${nonViste.map((e) => e['id']).toList()}');
      } else {
        setState(() => loading = false);
        print('[NOTIFICA] Errore HTTP ${response.statusCode}');
      }
    } catch (e) {
      setState(() => loading = false);
      print('[NOTIFICA] Errore: $e');
    }
    _isLoading = false;
  }

  Future<void> _segnaVista(String id) async {
    final prefs = await SharedPreferences.getInstance();
    viste.add(id);
    await prefs.setStringList('notifiche_viste', viste.toList());
    print('[NOTIFICA] Segnata come vista: $id');
    setState(() {
      nonViste.removeWhere((n) => n['id'].toString() == id);
      // Aggiorna currentPage per evitare errori di index!
      if (currentPage >= nonViste.length) currentPage = nonViste.length - 1;
    });
  }

  Widget _notificaCard(Map notifica, VoidCallback onClose) {
    final notifica_titolo = notifica['notifica_titolo'] ?? '';
    final notifica_testo = notifica['notifica_testo'] ?? '';
    final notifica_link = notifica['notifica_link'] ?? '';
    final notifica_immagine = notifica['notifica_immagine'];

    final dynamic coloriRaw = notifica['colori'];
    List<String> colori;
    if (coloriRaw != null && coloriRaw.toString().isNotEmpty) {
      colori = coloriRaw.toString().split('|');
    } else {
      colori = ['0xff0e70b7', '0xffffffff'];
    }

    Color btnColor;
    try {
      btnColor = Color(int.parse(colori[0]));
    } catch (_) {
      btnColor = const Color(0xff0e70b7);
    }

    if (notifica_testo.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (notifica_immagine != null &&
                    notifica_immagine.toString().isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.network(
                      notifica_immagine,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      height: 180,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        notifica_titolo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        notifica_testo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                      ),
                      if (notifica_link != '')
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: btnColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () =>
                                constants.openUrl(Uri.parse(notifica_link)),
                            child: const Text('Scopri di più'),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (nonViste.isEmpty) {
      print('[NOTIFICA] Nessuna notifica non vista!');
      return const SizedBox.shrink();
    }

    final pageController = PageController(
      viewportFraction: 0.92,
      initialPage: currentPage,
    );

    // Altezza massima card: se supera, la card scrolla al suo interno!
    const maxCardHeight = 360.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: maxCardHeight + 24, // un po' di padding, pallini sotto
          child: PageView.builder(
            controller: pageController,
            itemCount: nonViste.length,
            onPageChanged: (idx) {
              setState(() {
                currentPage = idx;
              });
            },
            itemBuilder: (context, idx) {
              final notifica = nonViste[idx];
              final isBeingDismissed = _cardDismissedIndex == idx;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                child: GestureDetector(
                  onVerticalDragEnd: (details) async {
                    // Swipe verso l'alto = elimina la notifica, animazione
                    if (details.primaryVelocity != null &&
                        details.primaryVelocity! < -200) {
                      setState(() => _cardDismissedIndex = idx);
                      await Future.delayed(const Duration(milliseconds: 220));
                      _segnaVista(notifica['id'].toString());
                      setState(() => _cardDismissedIndex = null);
                    }
                  },
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 220),
                    opacity: isBeingDismissed ? 0.0 : 1.0,
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 220),
                      offset: isBeingDismissed
                          ? const Offset(0, -0.13)
                          : Offset.zero,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: maxCardHeight,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: SingleChildScrollView(
                              padding: EdgeInsets.zero,
                              child: _notificaCard(
                                notifica,
                                () async {
                                  setState(() => _cardDismissedIndex = idx);
                                  await Future.delayed(
                                      const Duration(milliseconds: 220));
                                  _segnaVista(notifica['id'].toString());
                                  setState(() => _cardDismissedIndex = null);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Pallini indicatore
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(nonViste.length, (idx) {
            final isActive = idx == currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: isActive ? 18 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xff0e70b7) : Colors.grey[300],
                borderRadius: BorderRadius.circular(6),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}
