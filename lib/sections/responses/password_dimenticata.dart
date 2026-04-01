import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';

class PasswordDimenticata extends StatefulWidget {
  const PasswordDimenticata({super.key});

  @override
  State<PasswordDimenticata> createState() => _PasswordDimenticataState();
}

class _PasswordDimenticataState extends State<PasswordDimenticata> {
  final _formKey = GlobalKey<FormState>();
  final _cfController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _cfController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await context.read<AppProvider>().resetPassword(_cfController.text.trim());
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          constants.SPACER,
          const Center(
            child: Text(
              'PASSWORD DIMENTICATA',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Center(
            child: HtmlWidget(
              "<p style='text-align:center;'>Inserisci il tuo Codice Fiscale e "
              "ti invieremo un link per reimpostare la tua password.</p>",
            ),
          ),
          constants.SPACER,
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _cfController,
                  decoration: const InputDecoration(
                    labelText: 'Codice Fiscale',
                    labelStyle: TextStyle(color: Colors.black87, fontSize: 17),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Per proseguire, riempi questo campo.';
                    }
                    final re = RegExp(
                      r"^(?:[A-Z][AEIOU][AEIOUX]|[AEIOU]X{2}|[B-DF-HJ-NP-TV-Z]{2}[A-Z]){2}(?:[\dLMNP-V]{2}(?:[A-EHLMPR-T](?:[04LQ][1-9MNP-V]|[15MR][\dLMNP-V]|[26NS][0-8LMNP-U])|[DHPS][37PT][0L]|[ACELMRT][37PT][01LM]|[AC-EHLMPR-T][26NS][9V])|(?:[02468LNQSU][048LQU]|[13579MPRTV][26NS])B[26NS][9V])(?:[A-MZ][1-9MNP-V][\dLMNP-V]{2}|[A-M][0L](?:[1-9MNP-V][\dLMNP-V]|[0L][1-9MNP-V]))[A-Z]",
                      caseSensitive: false,
                    );
                    if (!re.hasMatch(v)) {
                      return 'Inserisci un Codice Fiscale valido.';
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: _loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _sendReset,
                          style: constants.STILE_BOTTONE,
                          child: const Text(
                            'REIMPOSTA PASSWORD!',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ElevatedButton(
                    onPressed: provider.goToLogin,
                    style: constants.STILE_BOTTONE,
                    child: const Text(
                      'INDIETRO',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
