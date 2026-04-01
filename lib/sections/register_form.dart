import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/sections/liberatoria.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _cognome = TextEditingController();
  final _cf = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _repeatPassword = TextEditingController();
  final _email = TextEditingController();
  final _telefono = TextEditingController();

  DateTime? _dataDiNascita;
  double _passwordStrength = 0;
  String _passwordStrengthLabel = '';
  Color _passwordStrengthColor = Colors.red;

  bool _isChecked1 = false;
  bool _isChecked2 = false;
  bool _isChecked3 = false;
  bool _isChecked4 = false;
  bool _isCheckedTutti = false;
  bool _formError = false;
  String _formErrorMessage = '';

  @override
  void dispose() {
    _nome.dispose();
    _cognome.dispose();
    _cf.dispose();
    _username.dispose();
    _password.dispose();
    _repeatPassword.dispose();
    _email.dispose();
    _telefono.dispose();
    super.dispose();
  }

  void _toggleAll(bool? value) {
    final v = value ?? false;
    setState(() {
      _isCheckedTutti = v;
      _isChecked1 = v;
      _isChecked2 = v;
      _isChecked3 = v;
      _isChecked4 = v;
    });
  }

  void _updateTutti() {
    setState(() {
      _isCheckedTutti = _isChecked1 && _isChecked2 && _isChecked3 && _isChecked4;
    });
  }

  void _checkPasswordStrength(String password) {
    double strength = 0;
    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.15;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[A-Z]')) && password.contains(RegExp(r'[a-z]'))) {
      strength += 0.2;
    }
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;

    setState(() {
      _passwordStrength = strength;
      if (password.isEmpty) {
        _passwordStrengthLabel = '';
        _passwordStrengthColor = Colors.transparent;
      } else if (strength < 0.4) {
        _passwordStrengthLabel = 'Debole';
        _passwordStrengthColor = Colors.red;
      } else if (strength < 0.7) {
        _passwordStrengthLabel = 'Media';
        _passwordStrengthColor = Colors.orange;
      } else if (strength < 1) {
        _passwordStrengthLabel = 'Forte';
        _passwordStrengthColor = Colors.lightGreen;
      } else {
        _passwordStrengthLabel = 'Molto Forte';
        _passwordStrengthColor = Colors.green;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dataDiNascita = picked);
  }

  Future<void> _sendData() async {
    final dataNascitaStr = _dataDiNascita != null
        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(_dataDiNascita!)
        : null;

    await context.read<AppProvider>().register(
          username: _username.text.trim(),
          password: _password.text,
          nome: _nome.text.trim(),
          cognome: _cognome.text.trim(),
          email: _email.text.trim(),
          telefono: _telefono.text.trim(),
          cf: _cf.text.trim(),
          dataDiNascita: dataNascitaStr,
          privacy1: _isChecked1,
          privacy2: _isChecked2,
          privacy3: _isChecked3,
          privacy4: _isChecked4,
        );
  }

  @override
  Widget build(BuildContext context) {
    final config = context.read<AppProvider>().config!;
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
              "Compila il form e accetta l'informativa sulla privacy per avere "
              "accesso alle funzionalità avanzate dell'App.",
              textAlign: TextAlign.center,
            ),
          ),
          constants.SPACER,
          Form(
            key: _formKey,
            child: Column(
              children: [
                _textField(_username, 'Username'),
                constants.SPACER_MEDIUM,
                // Password + strength meter
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: _inputDeco('Password'),
                      onChanged: _checkPasswordStrength,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Per proseguire, compila questo campo.';
                        }
                        if (v.length < 8) return 'Almeno 8 caratteri.';
                        if (_passwordStrength < 0.7) return 'La password è troppo debole!';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      minHeight: 8,
                      value: _passwordStrength,
                      backgroundColor: Colors.grey.shade300,
                      color: _passwordStrengthColor,
                    ),
                    const SizedBox(height: 4),
                    if (_passwordStrengthLabel.isNotEmpty)
                      Text(
                        'Forza password: $_passwordStrengthLabel',
                        style: TextStyle(
                          color: _passwordStrengthColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                constants.SPACER_MEDIUM,
                TextFormField(
                  controller: _repeatPassword,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: _inputDeco('Ripeti la Password'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Per proseguire, compila questo campo.';
                    if (v != _password.text) return 'Le Password non combaciano';
                    return null;
                  },
                ),
                constants.SPACER_MEDIUM,
                TextFormField(
                  controller: _email,
                  decoration: _inputDeco('Email'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Per proseguire, compila questo campo.';
                    final re = RegExp(
                      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$",
                    );
                    if (!re.hasMatch(v)) return 'Inserisci un indirizzo e-mail valido.';
                    return null;
                  },
                ),
                constants.SPACER_MEDIUM,
                TextFormField(
                  controller: _telefono,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDeco('Telefono Cellulare'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Per proseguire, compila questo campo.';
                    if (!RegExp(r'^[0-9]{7,15}$').hasMatch(v)) {
                      return 'Numero non valido (solo cifre, minimo 7).';
                    }
                    return null;
                  },
                ),
                constants.SPACER_MEDIUM,
                _textField(_nome, 'Nome'),
                constants.SPACER_MEDIUM,
                _textField(_cognome, 'Cognome'),
                constants.SPACER_MEDIUM,
                TextFormField(
                  controller: _cf,
                  decoration: _inputDeco('Codice Fiscale'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Per proseguire, compila questo campo.';
                    final re = RegExp(
                      r"^(?:[A-Z][AEIOU][AEIOUX]|[AEIOU]X{2}|[B-DF-HJ-NP-TV-Z]{2}[A-Z]){2}(?:[\dLMNP-V]{2}(?:[A-EHLMPR-T](?:[04LQ][1-9MNP-V]|[15MR][\dLMNP-V]|[26NS][0-8LMNP-U])|[DHPS][37PT][0L]|[ACELMRT][37PT][01LM]|[AC-EHLMPR-T][26NS][9V])|(?:[02468LNQSU][048LQU]|[13579MPRTV][26NS])B[26NS][9V])(?:[A-MZ][1-9MNP-V][\dLMNP-V]{2}|[A-M][0L](?:[1-9MNP-V][\dLMNP-V]|[0L][1-9MNP-V]))[A-Z]",
                      caseSensitive: false,
                    );
                    if (!re.hasMatch(v)) return 'Inserisci un Codice Fiscale valido.';
                    return null;
                  },
                ),
                constants.SPACER_MEDIUM,
                // Data di nascita (read-only, apre date picker)
                TextFormField(
                  controller: TextEditingController(
                    text: _dataDiNascita != null
                        ? DateFormat('dd/MM/yyyy').format(_dataDiNascita!)
                        : 'Non Selezionata',
                  ),
                  readOnly: true,
                  decoration: _inputDeco('Data di Nascita'),
                  onTap: () => _selectDate(context),
                  validator: (v) => (v == null || v == 'Non Selezionata')
                      ? 'Per proseguire, compila questo campo.'
                      : null,
                ),
                constants.SPACER,
                constants.SPACER_MEDIUM,
                // Privacy
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const Text(
                        'Informativa Privacy',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
                      ),
                      constants.SPACER_MEDIUM,
                      Ink(
                        child: InkWell(
                          onTap: () => _showPrivacy(context),
                          child: const HtmlWidget(
                            "<p style='text-align:center;'>Prima di registrarti, "
                            "assicurati di aver letto la nostra "
                            "<span style='text-decoration:underline;color:blue;'>"
                            "Informativa Privacy</span> e di assegnare i tuoi consensi.</p>",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                constants.SPACER,
                // Seleziona tutti
                _PrivacyCheckRow(
                  value: _isCheckedTutti,
                  color: config.primaryColor,
                  label: 'Acconsento ad ogni trattamento dei miei dati come indicato di seguito.',
                  labelColor: Colors.white,
                  onChanged: _toggleAll,
                ),
                constants.SPACER,
                _PrivacyCheckRow(
                  value: _isChecked1,
                  color: null,
                  label: '* Acconsento al trattamento dei dati particolari per le finalità indicate al punto 1 dell\'informativa.',
                  onChanged: (v) => setState(() {
                    _isChecked1 = v ?? false;
                    _updateTutti();
                  }),
                ),
                constants.SPACER,
                _PrivacyCheckRow(
                  value: _isChecked2,
                  color: null,
                  label: constants.PRIVACY_2,
                  onChanged: (v) => setState(() {
                    _isChecked2 = v ?? false;
                    _updateTutti();
                  }),
                ),
                constants.SPACER,
                _PrivacyCheckRow(
                  value: _isChecked3,
                  color: null,
                  label: constants.PRIVACY_3,
                  onChanged: (v) => setState(() {
                    _isChecked3 = v ?? false;
                    _updateTutti();
                  }),
                ),
                constants.SPACER,
                _PrivacyCheckRow(
                  value: _isChecked4,
                  color: null,
                  label: constants.PRIVACY_4,
                  onChanged: (v) => setState(() {
                    _isChecked4 = v ?? false;
                    _updateTutti();
                  }),
                ),
                constants.SPACER,
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ElevatedButton(
                    onPressed: _onRegisterTap,
                    style: constants.STILE_BOTTONE,
                    child: const Text(
                      'REGISTRATI!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (_formError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _formErrorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                constants.SPACER_MEDIUM,
                const Text('Sei già registrato?'),
                ElevatedButton(
                  onPressed: context.read<AppProvider>().goToLogin,
                  style: constants.STILE_BOTTONE,
                  child: const Text('ACCEDI!', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onRegisterTap() {
    setState(() {
      _formError = false;
      _formErrorMessage = '';
    });
    if (!_isChecked1) {
      setState(() {
        _formError = true;
        _formErrorMessage =
            'È obbligatorio acconsentire almeno al primo punto della liberatoria.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_formErrorMessage)),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _formError = true;
        _formErrorMessage = 'Controlla tutti i campi, alcuni non sono validi o mancanti.';
      });
      return;
    }
    _sendData();
  }

  Future<void> _showPrivacy(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => Theme(
        data: Theme.of(ctx).copyWith(dialogBackgroundColor: Colors.white),
        child: AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const Text('Informativa Privacy'),
          content: const Liberatoria(),
          actions: [
            TextButton(
              style: constants.STILE_BOTTONE,
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Chiudi'),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField _textField(TextEditingController ctrl, String label) {
    return TextFormField(
      controller: ctrl,
      decoration: _inputDeco(label),
      validator: (v) =>
          (v == null || v.isEmpty) ? 'Per proseguire, compila questo campo.' : null,
    );
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.black87, fontSize: 17),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.purple),
    ),
    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 1),
    ),
  );
}

// ─── Privacy checkbox row ─────────────────────────────────────────────────────

class _PrivacyCheckRow extends StatelessWidget {
  final bool value;
  final Color? color;
  final String label;
  final Color? labelColor;
  final ValueChanged<bool?> onChanged;

  const _PrivacyCheckRow({
    required this.value,
    required this.color,
    required this.label,
    required this.onChanged,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        Checkbox(
          value: value,
          activeColor: constants.COLORE_TERZIARIO,
          onChanged: onChanged,
        ),
        Flexible(
          child: labelColor != null
              ? HtmlWidget("<p style='color: #ffffff;'>$label</p>")
              : Text(label),
        ),
      ],
    );

    if (color != null) {
      return Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () => onChanged(!value),
          child: Padding(padding: const EdgeInsets.fromLTRB(0, 5, 16, 5), child: row),
        ),
      );
    }

    return InkWell(onTap: () => onChanged(!value), child: row);
  }
}
