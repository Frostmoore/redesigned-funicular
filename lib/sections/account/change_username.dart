// change_username.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;

import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/models/user_data.dart';

class ChangeUsername extends StatefulWidget {
  const ChangeUsername({super.key, required this.userData});

  final UserData userData;

  @override
  State<ChangeUsername> createState() => _ChangeUsernameState();
}

class _ChangeUsernameState extends State<ChangeUsername> {
  final _formKey = GlobalKey<FormState>();
  final _uCtrl = TextEditingController();
  final _mCtrl = TextEditingController();
  final _store = const FlutterSecureStorage();

  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _uCtrl.text = widget.userData.username;
    _mCtrl.text = widget.userData.email;
  }

  @override
  void dispose() {
    _uCtrl.dispose();
    _mCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _busy = true);

    final url =
        Uri.parse('https://hybridandgogsv.it/res/api/v1/change_username.php');

    final payload = jsonEncode({
      'id': widget.userData.id,
      'username': _uCtrl.text.trim(),
      'email': _mCtrl.text.trim(),
    });

    debugPrint('[CHANGE] → POST $url  $payload');

    try {
      final res = await http.post(url,
          headers: {'Content-Type': 'application/json'}, body: payload);

      debugPrint('[CHANGE] ← ${res.statusCode}  ${res.body}');

      final ok = res.statusCode == 200 &&
          (jsonDecode(res.body)['http_response_code'] == '1');

      if (ok) {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const HtmlWidget(
          "<h2 style='text-align:center;'>Modifica Credenziali</h2>",
        ),
        if (_busy) const LinearProgressIndicator(),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _uCtrl,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _mCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Email non valida' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _busy ? null : _submit,
                style: constants.STILE_BOTTONE,
                child: const Text('Salva'),
              ),
              constants.SPACER,
            ],
          ),
        ),
      ],
    );
  }
}
