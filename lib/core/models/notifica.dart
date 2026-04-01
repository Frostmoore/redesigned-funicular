/// Comunicazione in-app ricevuta dal backend.
class Notifica {
  final String id;
  final String titolo;
  final String contenuto;
  final List<String> destinatari;
  final List<String> lettaDa;
  final String dataora;
  final String? immagine;
  final String? link;
  final String? testolink;

  const Notifica({
    required this.id,
    required this.titolo,
    required this.contenuto,
    required this.destinatari,
    required this.lettaDa,
    required this.dataora,
    this.immagine,
    this.link,
    this.testolink,
  });

  factory Notifica.fromJson(Map<String, dynamic> json) {
    final dest = json['destinatari']?.toString() ?? '';
    final letta = json['letta_da']?.toString() ?? '';
    return Notifica(
      id: json['id']?.toString() ?? '',
      titolo: json['titolo']?.toString() ?? '',
      contenuto: json['contenuto']?.toString() ?? '',
      destinatari: dest.isEmpty ? [] : dest.split(','),
      lettaDa: letta.isEmpty ? [] : letta.split(','),
      dataora: json['dataora']?.toString() ?? '',
      immagine: json['immagine']?.toString(),
      link: json['link']?.toString(),
      testolink: json['testolink']?.toString(),
    );
  }

  bool isUnreadBy(String username) =>
      destinatari.contains(username) && !lettaDa.contains(username);

  bool isForUser(String username) => destinatari.contains(username);
}
