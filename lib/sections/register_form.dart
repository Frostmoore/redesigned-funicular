import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:Assidim/sections/liberatoria.dart';
import 'dart:math';

class RegisterForm extends StatefulWidget {
  final data;
  final Function() logParent;
  const RegisterForm({super.key, required this.data, required this.logParent});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nome = TextEditingController();
  final TextEditingController _cognome = TextEditingController();
  final TextEditingController _codiceFiscale = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _repeatPassword = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _codAgenzia = TextEditingController();
  final TextEditingController _telefono = TextEditingController();

  double _passwordStrength = 0;
  String _passwordStrengthLabel = '';
  Color _passwordStrengthColor = Colors.red;

  var Nome;
  var Cognome;
  var _dataDiNascita;
  var CodiceFiscale;
  var Username;
  var Password;
  var RepeatPassword;
  var CodAgenzia;
  var Email;
  bool Privacy = false;
  var _isChecked1 = false;
  var _isChecked2 = false;
  var _isChecked3 = false;
  var _isChecked4 = false;
  var _isCheckedTutti = false;

  // --- Variabili per gestire l'avviso globale sotto il pulsante
  bool _formError = false;
  String _formErrorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              constants.SPACER,
              const Center(
                child: Text(
                  "REGISTRAZIONE UTENTE",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Center(
                child: Text(
                  "Compila il form e accetta l'informativa sulla privacy per avere accesso alle funzionalità avanzate dell'App.",
                  textAlign: TextAlign.center,
                ),
              ),
              constants.SPACER,
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                        onSaved: (value) {
                          Username = value;
                        },
                        decoration: const InputDecoration(
                          labelText: "Username",
                          labelStyle: TextStyle(
                              color: Colors.black87,
                              fontSize: 17,
                              fontFamily: 'AvenirLight'),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1.0)),
                        ),
                        controller: _username,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Per proseguire, compila questo campo.';
                          }
                          return null;
                        }),
                    constants.SPACER_MEDIUM,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          onSaved: (value) {
                            Password = value;
                          },
                          decoration: const InputDecoration(
                            labelText: "Password",
                            labelStyle: TextStyle(
                                color: Colors.black87,
                                fontSize: 17,
                                fontFamily: 'AvenirLight'),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.purple),
                            ),
                            enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1.0)),
                          ),
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          controller: _password,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Per proseguire, compila questo campo.';
                            }
                            if (value.length < 8) {
                              return 'La Password deve essere lunga almeno 8 caratteri!';
                            }
                            if (_passwordStrength < 0.7) {
                              return 'La password è troppo debole!';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _checkPasswordStrength(value);
                          },
                        ),
                        SizedBox(height: 8),
                        LinearProgressIndicator(
                          minHeight: 8,
                          value: _passwordStrength,
                          backgroundColor: Colors.grey.shade300,
                          color: _passwordStrengthColor,
                        ),
                        SizedBox(height: 4),
                        Text(
                          _passwordStrengthLabel.isNotEmpty
                              ? 'Forza password: ${_passwordStrengthLabel}'
                              : '',
                          style: TextStyle(
                            color: _passwordStrengthColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    constants.SPACER_MEDIUM,
                    TextFormField(
                        onSaved: (value) {
                          RepeatPassword = value;
                        },
                        decoration: const InputDecoration(
                          labelText: "Ripeti la Password",
                          labelStyle: TextStyle(
                              color: Colors.black87,
                              fontSize: 17,
                              fontFamily: 'AvenirLight'),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1.0)),
                        ),
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        controller: _repeatPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Per proseguire, compila questo campo.';
                          }
                          if (value != _password.text) {
                            return "Le Password non combaciano";
                          }
                          return null;
                        }),
                    constants.SPACER_MEDIUM,
                    TextFormField(
                        onSaved: (value) {
                          Email = value;
                        },
                        decoration: const InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(
                              color: Colors.black87,
                              fontSize: 17,
                              fontFamily: 'AvenirLight'),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1.0)),
                        ),
                        controller: _email,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Per proseguire, compila questo campo.';
                          }
                          final checkEmailRegExp = RegExp(
                              r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$");
                          if (!checkEmailRegExp.hasMatch(value)) {
                            return 'Per favore, inserisci un indirizzo e-mail valido.';
                          }
                          return null;
                        }),
                    constants.SPACER_MEDIUM,
                    TextFormField(
                      onSaved: (value) {
                        // Puoi anche usare direttamente _telefono.text, ma se vuoi assegnare:
                        // Telefono = value;
                      },
                      decoration: const InputDecoration(
                        labelText: "Telefono Cellulare",
                        labelStyle: TextStyle(
                            color: Colors.black87,
                            fontSize: 17,
                            fontFamily: 'AvenirLight'),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple),
                        ),
                        enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0)),
                      ),
                      controller: _telefono,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Per proseguire, compila questo campo.';
                        }
                        final checkPhone = RegExp(r'^[0-9]{7,15}$');
                        if (!checkPhone.hasMatch(value)) {
                          return 'Numero non valido. Inserisci solo cifre (minimo 7).';
                        }
                        return null;
                      },
                    ),

                    constants.SPACER_MEDIUM,
                    TextFormField(
                        onSaved: (value) {
                          Nome = value;
                        },
                        decoration: const InputDecoration(
                          labelText: "Nome",
                          labelStyle: TextStyle(
                              color: Colors.black87,
                              fontSize: 17,
                              fontFamily: 'AvenirLight'),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1.0)),
                        ),
                        controller: _nome,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Per proseguire, compila questo campo.';
                          }
                          return null;
                        }),
                    constants.SPACER_MEDIUM,
                    TextFormField(
                        onSaved: (value) {
                          Cognome = value;
                        },
                        decoration: const InputDecoration(
                          labelText: "Cognome",
                          labelStyle: TextStyle(
                              color: Colors.black87,
                              fontSize: 17,
                              fontFamily: 'AvenirLight'),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1.0)),
                        ),
                        controller: _cognome,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Per proseguire, compila questo campo.';
                          }
                          return null;
                        }),
                    constants.SPACER_MEDIUM,
                    TextFormField(
                        onSaved: (value) {
                          CodiceFiscale = value;
                        },
                        decoration: const InputDecoration(
                          labelText: "Codice Fiscale",
                          labelStyle: TextStyle(
                              color: Colors.black87,
                              fontSize: 17,
                              fontFamily: 'AvenirLight'),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1.0)),
                        ),
                        controller: _codiceFiscale,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Per proseguire, compila questo campo.';
                          }
                          final checkCFRegExp = RegExp(
                            r"^(?:[A-Z][AEIOU][AEIOUX]|[AEIOU]X{2}|[B-DF-HJ-NP-TV-Z]{2}[A-Z]){2}(?:[\dLMNP-V]{2}(?:[A-EHLMPR-T](?:[04LQ][1-9MNP-V]|[15MR][\dLMNP-V]|[26NS][0-8LMNP-U])|[DHPS][37PT][0L]|[ACELMRT][37PT][01LM]|[AC-EHLMPR-T][26NS][9V])|(?:[02468LNQSU][048LQU]|[13579MPRTV][26NS])B[26NS][9V])(?:[A-MZ][1-9MNP-V][\dLMNP-V]{2}|[A-M][0L](?:[1-9MNP-V][\dLMNP-V]|[0L][1-9MNP-V]))[A-Z]",
                            caseSensitive: false,
                            multiLine: false,
                          );
                          if (!checkCFRegExp.hasMatch(value)) {
                            return 'Per favore, inserisci un Codice Fiscale valido.';
                          }
                          return null;
                        }),
                    constants.SPACER_MEDIUM,
                    TextFormField(
                      controller: TextEditingController(
                          text: _dataDiNascita?.toString().substring(0, 10) ??
                              'Non Selezionata'),
                      validator: (value) {
                        if (value == null || value == 'Non Selezionata') {
                          return 'Per proseguire, compila questo campo.';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Data di Nascita',
                        labelStyle: TextStyle(
                            color: Colors.black87,
                            fontSize: 17,
                            fontFamily: 'AvenirLight'),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple),
                        ),
                        enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0)),
                      ),
                      onTap: () {
                        _selectDate(context);
                      },
                      readOnly: true,
                    ),
                    constants.SPACER,
                    constants.SPACER_MEDIUM,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: Column(
                          children: [
                            const Text(
                              'Informativa Privacy',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 21,
                              ),
                            ),
                            constants.SPACER_MEDIUM,
                            Ink(
                              child: InkWell(
                                onTap: () =>
                                    _dialogBuilder(context, widget.data),
                                child: const HtmlWidget(
                                  "<p style='text-align:center;'>Prima di registrarti, assicurati di aver letto la nostra <span style='text-decoration:underline;color:blue;'>Informativa Privacy</span> e di assegnare i tuoi consensi.</p>",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    constants.SPACER,
                    Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: constants.COLORE_PRINCIPALE,
                      ),
                      child: InkWell(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 16, 5),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _isCheckedTutti,
                                activeColor: constants.COLORE_TERZIARIO,
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (_isCheckedTutti == false) {
                                      _isCheckedTutti = true;
                                      if (_isChecked1 == false) {
                                        _isChecked1 = true;
                                      }
                                      if (_isChecked2 == false) {
                                        _isChecked2 = true;
                                      }
                                      if (_isChecked3 == false) {
                                        _isChecked3 = true;
                                      }
                                      if (_isChecked4 == false) {
                                        _isChecked4 = true;
                                      }
                                    } else {
                                      _isCheckedTutti = false;
                                      if (_isChecked1 == true) {
                                        _isChecked1 = false;
                                      }
                                      if (_isChecked2 == true) {
                                        _isChecked2 = false;
                                      }
                                      if (_isChecked3 == true) {
                                        _isChecked3 = false;
                                      }
                                      if (_isChecked4 == true) {
                                        _isChecked4 = false;
                                      }
                                    }
                                  });
                                },
                              ),
                              const Flexible(
                                child: HtmlWidget(
                                    "<p style='color: white;'>Acconsento ad ogni trattamento dei miei dati come indicato di seguito.</p>"),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            if (_isCheckedTutti == false) {
                              _isCheckedTutti = true;
                              if (_isChecked1 == false) {
                                _isChecked1 = true;
                              }
                              if (_isChecked2 == false) {
                                _isChecked2 = true;
                              }
                              if (_isChecked3 == false) {
                                _isChecked3 = true;
                              }
                              if (_isChecked4 == false) {
                                _isChecked4 = true;
                              }
                            } else {
                              _isCheckedTutti = false;
                              if (_isChecked1 == true) {
                                _isChecked1 = false;
                              }
                              if (_isChecked2 == true) {
                                _isChecked2 = false;
                              }
                              if (_isChecked3 == true) {
                                _isChecked3 = false;
                              }
                              if (_isChecked4 == true) {
                                _isChecked4 = false;
                              }
                            }
                          });
                        },
                      ),
                    ),
                    constants.SPACER,
                    InkWell(
                      child: Row(
                        children: [
                          Checkbox(
                            value: _isChecked1,
                            activeColor: constants.COLORE_TERZIARIO,
                            onChanged: (bool? value) {
                              setState(() {
                                if (_isChecked1 == false) {
                                  _isChecked1 = true;
                                  if (_isChecked2 &&
                                      _isChecked3 &&
                                      _isChecked4) {
                                    _isCheckedTutti = true;
                                  }
                                } else {
                                  _isChecked1 = false;
                                  _isCheckedTutti = false;
                                }
                              });
                            },
                          ),
                          const Flexible(
                            child: HtmlWidget(
                                "<p><span style='color:red'>* </span> Acconsento al trattamento dei dati particolari per le finalità indicate al punto 1 dell'informativa.</p>"),
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          if (_isChecked1 == false) {
                            _isChecked1 = true;
                            if (_isChecked2 && _isChecked3 && _isChecked4) {
                              _isCheckedTutti = true;
                            }
                          } else {
                            _isChecked1 = false;
                            _isCheckedTutti = false;
                          }
                        });
                      },
                    ),
                    constants.SPACER,
                    InkWell(
                      child: Row(
                        children: [
                          Checkbox(
                            value: _isChecked2,
                            activeColor: constants.COLORE_TERZIARIO,
                            onChanged: (bool? value) {
                              setState(() {
                                if (_isChecked2 == false) {
                                  _isChecked2 = true;
                                  if (_isChecked1 &&
                                      _isChecked3 &&
                                      _isChecked4) {
                                    _isCheckedTutti = true;
                                  }
                                } else {
                                  _isChecked2 = false;
                                  _isCheckedTutti = false;
                                }
                              });
                            },
                          ),
                          const Flexible(
                            child: Text(
                                "Acconsento al trattamento dei miei dati personali di natura comune per finalità di informazione e promozione commerciale di prodotti e/o servizi, a mezzo posta o telefono e/o mediante comunicazioni elettroniche quali e-mail, fax, messaggi del tipo SMS o MMS ovvero con sistemi automatizzati, come specificato ai punti 2a, 2b e 2c dell'informativa."),
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          if (_isChecked2 == false) {
                            _isChecked2 = true;
                            if (_isChecked1 && _isChecked3 && _isChecked4) {
                              _isCheckedTutti = true;
                            }
                          } else {
                            _isChecked2 = false;
                            _isCheckedTutti = false;
                          }
                        });
                      },
                    ),
                    constants.SPACER,
                    InkWell(
                      child: Row(
                        children: [
                          Checkbox(
                            value: _isChecked3,
                            activeColor: constants.COLORE_TERZIARIO,
                            onChanged: (bool? value) {
                              setState(() {
                                if (_isChecked3 == false) {
                                  _isChecked3 = true;
                                  if (_isChecked1 &&
                                      _isChecked2 &&
                                      _isChecked4) {
                                    _isCheckedTutti = true;
                                  }
                                } else {
                                  _isChecked3 = false;
                                  _isCheckedTutti = false;
                                }
                              });
                            },
                          ),
                          const Flexible(
                            child: Text(
                                "Acconsento al trattamento dei miei dati personali di natura comune per finalità di comunicazione dei dati a soggetti terzi, operanti nel settore assicurativo e nei settori complementari a quello assicurativo, ai fini di informazione e promozione commerciale di prodotti e/o servizi, anche mediante tecniche di comunicazione a distanza, da parte degli stessi, come specificato al punto 2d dell'informativa."),
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          if (_isChecked3 == false) {
                            _isChecked3 = true;
                            if (_isChecked1 && _isChecked2 && _isChecked4) {
                              _isCheckedTutti = true;
                            }
                          } else {
                            _isChecked3 = false;
                            _isCheckedTutti = false;
                          }
                        });
                      },
                    ),
                    constants.SPACER,
                    InkWell(
                      child: Row(
                        children: [
                          Checkbox(
                            value: _isChecked4,
                            activeColor: constants.COLORE_TERZIARIO,
                            onChanged: (bool? value) {
                              setState(() {
                                if (_isChecked4 == false) {
                                  _isChecked4 = true;
                                  if (_isChecked1 &&
                                      _isChecked2 &&
                                      _isChecked3) {
                                    _isCheckedTutti = true;
                                  }
                                } else {
                                  _isChecked4 = false;
                                  _isCheckedTutti = false;
                                }
                              });
                            },
                          ),
                          const Flexible(
                            child: Text(
                                "Acconsento al trattamento dei miei dati personali di natura comune per finalità di profilazione volta ad analizzare i bisogni e le esigenze assicurative del cliente per l'individuazione, anche attraverso elaborazioni elettroniche, dei possibili prodotti e/o servizi in linea con le preferenze e gli interessi della clientela come specificato al punto 2e dell'informativa."),
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          if (_isChecked4 == false) {
                            _isChecked4 = true;
                            if (_isChecked1 && _isChecked2 && _isChecked3) {
                              _isCheckedTutti = true;
                            }
                          } else {
                            _isChecked4 = false;
                            _isCheckedTutti = false;
                          }
                        });
                      },
                    ),
                    constants.SPACER,

                    // ======= IL BOTTONE REGISTRAZIONE con gestione errore ======
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _formError = false;
                            _formErrorMessage = '';
                          });

                          if (!_isChecked1) {
                            setState(() {
                              _formError = true;
                              _formErrorMessage =
                                  "È obbligatorio acconsentire almeno al primo punto della liberatoria.";
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_formErrorMessage),
                              ),
                            );
                            return;
                          }

                          if (!_formKey.currentState!.validate()) {
                            setState(() {
                              _formError = true;
                              _formErrorMessage =
                                  "Controlla tutti i campi, alcuni non sono validi o mancanti.";
                            });
                            return;
                          }

                          _sendData(context);
                        },
                        style: constants.STILE_BOTTONE,
                        child: const Text(
                          "REGISTRATI!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (_formError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _formErrorMessage,
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    constants.SPACER_MEDIUM,
                    Text("Sei già registrato?"),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      child: ElevatedButton(
                        onPressed: () {
                          constants.userStatus = 0;
                          widget.logParent();
                        },
                        style: constants.STILE_BOTTONE,
                        child: const Text(
                          "ACCEDI!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _dialogBuilder(BuildContext context, data) {
    data = widget.data;
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return Theme(
            data:
                Theme.of(context).copyWith(dialogBackgroundColor: Colors.white),
            child: AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              title: const Text("Informativa Privacy"),
              content: Liberatoria(data: data),
              actions: <Widget>[
                TextButton(
                  style: constants.STILE_BOTTONE,
                  child: const Text("Chiudi"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );
        });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dataDiNascita) {
      setState(() {
        String formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(picked);
        _dataDiNascita = formattedDate;
      });
    }
  }

  void _checkPasswordStrength(String password) {
    double strength = 0;
    String label = '';
    Color color = Colors.red;

    if (password.isEmpty) {
      strength = 0;
      label = '';
      color = Colors.transparent;
    } else {
      // Lunghezza
      if (password.length >= 8) strength += 0.25;
      if (password.length >= 12) strength += 0.15;

      // Numeri
      if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;

      // Maiuscole e minuscole
      if (password.contains(RegExp(r'[A-Z]')) &&
          password.contains(RegExp(r'[a-z]'))) strength += 0.2;

      // Simboli
      if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;

      if (strength < 0.4) {
        label = 'Debole';
        color = Colors.red;
      } else if (strength < 0.7) {
        label = 'Media';
        color = Colors.orange;
      } else if (strength < 1) {
        label = 'Forte';
        color = Colors.lightGreen;
      } else {
        label = 'Molto Forte';
        color = Colors.green;
      }
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthLabel = label;
      _passwordStrengthColor = color;
    });
  }

  String randomNumbers(int _length) {
    final Random random = Random();
    int length = _length;
    String randomString = '';

    for (int i = 0; i < length; i++) {
      randomString +=
          random.nextInt(10).toString(); // Genera un numero tra 0 e 9
    }
    return randomString;
  }

  Future<void> _sendData(BuildContext context) async {
    var url = Uri.https(
      constants.PATH,
      constants.ENDPOINT_REG,
    );
    var playerId = "${_username.text}_${randomNumbers(5)}";
    var request = {
      'id': constants.ID,
      'token': constants.TOKEN,
      'username': _username.text,
      'password': _password.text,
      'nome': _nome.text,
      'cognome': _cognome.text,
      'email': _email.text,
      'telefono': _telefono.text,
      'cf': _codiceFiscale.text,
      'datadinascita': _dataDiNascita,
      'privacy1': _isChecked1,
      'privacy2': _isChecked2,
      'privacy3': _isChecked3,
      'privacy4': _isChecked4,
      'playerid': playerId,
    };
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request),
    );

    if (response.statusCode == 200) {
      print(response.body);
      var responseParsed = jsonDecode(response.body) as Map;
      constants.userStatus = int.parse(responseParsed['http_response_code']);
      widget.logParent();
    } else {
      constants.userStatus = 100;
      widget.logParent();
    }
  }
}
