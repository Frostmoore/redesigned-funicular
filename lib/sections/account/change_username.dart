// change_username.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:Assidim/assets/constants.dart' as constants;

/// ════════════════════════════════════════════════════════════════════
///  Modifica username / e-mail (senza nuovo login)
/// ════════════════════════════════════════════════════════════════════
class ChangeUsername extends StatefulWidget {
  const ChangeUsername({
    super.key,
    required this.userData, // <─ dati utente già disponibili
  });

  final Map<String, dynamic> userData;

  @override
  State<ChangeUsername> createState() => _ChangeUsernameState();
}

class _ChangeUsernameState extends State<ChangeUsername> {
  final _formKey = GlobalKey<FormState>();
  final _uCtrl = TextEditingController();
  final _mCtrl = TextEditingController();
  final _store = const FlutterSecureStorage();

  bool _busy = false;

  /*─────────────────────────────────────────────────────────────────*/
  @override
  void initState() {
    super.initState();

    // pre-compila campi con i dati ricevuti
    _uCtrl.text = widget.userData['username']?.toString() ?? '';
    _mCtrl.text = widget.userData['email']?.toString() ?? '';
  }

  /*─────────────────────────────────────────────────────────────────*/
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _busy = true);
    final sw = Stopwatch()..start();

    final url =
        Uri.parse('https://hybridandgogsv.it/res/api/v1/change_username.php');

    final payload = jsonEncode({
      'id': widget.userData['id'].toString(),
      'username': _uCtrl.text.trim(),
      'email': _mCtrl.text.trim(),
    });

    debugPrint('[CHANGE] → POST $url  $payload');

    try {
      final res = await http.post(url,
          headers: {'Content-Type': 'application/json'}, body: payload);

      debugPrint('[CHANGE] ← ${res.statusCode}  '
          '(${sw.elapsedMilliseconds} ms)  ${res.body}');

      final ok = res.statusCode == 200 &&
          (jsonDecode(res.body)['http_response_code'] == '1');

      if (ok) {
        // aggiorna secure-storage per i futuri login automatici
        await _store.write(key: 'username', value: _uCtrl.text.trim());
        await _store.write(key: 'email', value: _mCtrl.text.trim());
        _showSnack('Credenziali aggiornate');
      } else {
        _showSnack('Aggiornamento non riuscito');
      }
    } catch (e) {
      debugPrint('[CHANGE] errore: $e');
      _showSnack('Errore di rete');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /*─────────────────────────────────────────────────────────────────*/
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text('Modifica credenziali',
            style: Theme.of(context).textTheme.titleMedium),
        if (_busy) const LinearProgressIndicator(),
        Form(
          key: _formKey,
          child: Column(
            children: [
              // USERNAME
              TextFormField(
                controller: _uCtrl,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Obbligatorio' : null,
              ),
              const SizedBox(height: 12),

              // EMAIL
              TextFormField(
                controller: _mCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Email non valida' : null,
              ),
              const SizedBox(height: 16),

              // CTA
              ElevatedButton(
                onPressed: _busy ? null : _submit,
                child: const Text('Salva'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
