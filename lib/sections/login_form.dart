import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _passwordVisible = false;
  String? _errorMessage;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final result = await context.read<AppProvider>().login(
          _username.text.trim(),
          _password.text.trim(),
        );

    if (!mounted) return;
    if (!result.success) {
      setState(() {
        _errorMessage = result.errorMessage ?? 'Credenziali non valide.';
        _loading = false;
      });
    }
    // Se success, AppProvider notifica e AccountContainer switcha automaticamente
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
              'REGISTRAZIONE UTENTE',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Center(
            child: Text(
              'Se è il tuo primo accesso, iscriviti ora:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          constants.SPACER_MEDIUM,
          ElevatedButton(
            onPressed: provider.goToRegister,
            style: constants.STILE_BOTTONE,
            child: const Text(
              'ISCRIVITI!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          constants.SPACER,
          constants.SPACER,
          constants.SPACER,
          const Center(
            child: Text(
              'ACCESSO UTENTE',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Center(
            child: Text('Accedi ora alla tua area riservata.', textAlign: TextAlign.center),
          ),
          constants.SPACER_MEDIUM,
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _username,
                  decoration: const InputDecoration(
                    labelText: 'Username, e-mail o Codice Fiscale',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Per proseguire, riempi questo campo.' : null,
                ),
                constants.SPACER_MEDIUM,
                TextFormField(
                  controller: _password,
                  obscureText: !_passwordVisible,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey[700],
                      ),
                      onPressed: () =>
                          setState(() => _passwordVisible = !_passwordVisible),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Per proseguire, riempi questo campo.' : null,
                ),
                constants.SPACER_MEDIUM,
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: _loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _submit,
                          style: constants.STILE_BOTTONE,
                          child: const Text(
                            'ACCEDI!',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: provider.goToForgotPassword,
            child: const HtmlWidget(
              "<p style='text-align:center;text-decoration:underline;color:blue;'>"
              "Password Dimenticata?</p>",
            ),
          ),
          constants.SPACER,
        ],
      ),
    );
  }
}
