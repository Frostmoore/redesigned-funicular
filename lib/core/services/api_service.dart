import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────────────────
//  Eccezioni tipizzate
// ─────────────────────────────────────────────────────────────────────────────

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => statusCode != null
      ? 'ApiException [$statusCode]: $message'
      : 'ApiException: $message';
}

class NetworkException extends ApiException {
  const NetworkException(super.message);
}

class TimeoutException extends ApiException {
  const TimeoutException() : super('Timeout: il server non ha risposto in tempo');
}

// ─────────────────────────────────────────────────────────────────────────────
//  ApiService
// ─────────────────────────────────────────────────────────────────────────────

/// Client HTTP centralizzato con timeout, gestione errori e logging solo in
/// modalità debug. Tutti gli altri service dipendono da questo.
class ApiService {
  static const Duration _timeout = Duration(seconds: 20);

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // ─── GET ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> get(Uri url) async {
    debugPrint('[API] GET $url');
    try {
      final response = await _client.get(url).timeout(_timeout);
      return _parse(response);
    } on SocketException catch (e) {
      throw NetworkException('Nessuna connessione: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Errore di rete: ${e.message}');
    } on TimeoutException {
      rethrow;
    } catch (_) {
      throw const TimeoutException();
    }
  }

  // ─── POST (JSON body) ─────────────────────────────────────────────────────

  Future<Map<String, dynamic>> postJson(
    Uri url, {
    required Map<String, dynamic> body,
    Map<String, String>? extraHeaders,
  }) async {
    debugPrint('[API] POST $url');
    try {
      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              ...?extraHeaders,
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _parse(response);
    } on SocketException catch (e) {
      throw NetworkException('Nessuna connessione: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Errore di rete: ${e.message}');
    } on TimeoutException {
      rethrow;
    } catch (_) {
      throw const TimeoutException();
    }
  }

  // ─── POST (form body) ─────────────────────────────────────────────────────

  Future<Map<String, dynamic>> postForm(
    Uri url, {
    required Map<String, String> fields,
    Map<String, String>? extraHeaders,
  }) async {
    debugPrint('[API] POST (form) $url');
    try {
      final response = await _client
          .post(
            url,
            headers: extraHeaders,
            body: fields,
          )
          .timeout(_timeout);
      return _parse(response);
    } on SocketException catch (e) {
      throw NetworkException('Nessuna connessione: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Errore di rete: ${e.message}');
    } on TimeoutException {
      rethrow;
    } catch (_) {
      throw const TimeoutException();
    }
  }

  // ─── GET raw (per le chiamate che tornano liste / strutture diverse) ───────

  Future<dynamic> getRaw(Uri url, {Map<String, String>? headers}) async {
    debugPrint('[API] GET raw $url');
    try {
      final response =
          await _client.get(url, headers: headers).timeout(_timeout);
      if (response.statusCode != 200) {
        throw ApiException(
          'HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
      return jsonDecode(response.body);
    } on SocketException catch (e) {
      throw NetworkException('Nessuna connessione: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Errore di rete: ${e.message}');
    } on TimeoutException {
      rethrow;
    } catch (_) {
      throw const TimeoutException();
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Map<String, dynamic> _parse(http.Response response) {
    debugPrint('[API] ← ${response.statusCode}');
    if (response.statusCode != 200) {
      throw ApiException(
        'HTTP ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const ApiException('Risposta non è JSON valido');
    }
  }

  void dispose() => _client.close();
}
