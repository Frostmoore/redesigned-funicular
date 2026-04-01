import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/models/notifica.dart';
import 'package:Assidim/core/services/api_service.dart';

/// Gestisce il recupero e la marcatura di lettura delle notifiche in-app.
class NotificheService {
  final ApiService _api;

  const NotificheService(this._api);

  /// Restituisce tutte le notifiche destinate all'utente [username].
  Future<List<Notifica>> fetchNotifiche(String username) async {
    final url = Uri.parse('https://${constants.PATH}${constants.ENDPOINT_NOTI}');
    final data = await _api.postForm(url, fields: {'username': username});

    if (data['status'] != 'ok') return [];

    final rawList = data['data'] as List<dynamic>? ?? [];
    return rawList
        .cast<Map<String, dynamic>>()
        .map(Notifica.fromJson)
        .toList();
  }

  /// Segna la notifica con [notificaId] come letta dall'utente [username].
  Future<void> markAsRead(String notificaId, String username) async {
    final url =
        Uri.parse('https://${constants.PATH}${constants.ENDPOINT_READNOTI}');
    // Original API expects JSON body with 'id' and 'user' keys
    await _api.postJson(url, body: {'id': notificaId, 'user': username});
  }

  /// Recupera i dettagli di una singola notifica.
  Future<Notifica?> fetchSingle(String notificaId, String username) async {
    final url =
        Uri.parse('https://${constants.PATH}${constants.ENDPOINT_SINGLENOT}');
    try {
      final data = await _api.postForm(url, fields: {
        'id': notificaId,
        'user': username,
      });
      if (data['data'] == null) return null;
      return Notifica.fromJson(data['data'] as Map<String, dynamic>);
    } on ApiException {
      return null;
    }
  }
}
