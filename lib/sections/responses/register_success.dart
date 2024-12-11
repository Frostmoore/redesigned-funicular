import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:Assidim/assets/constants.dart' as constants;

class RegisterSuccess extends StatefulWidget {
  final data;
  final Function() logParent;
  const RegisterSuccess(
      {super.key, required this.data, required this.logParent});

  @override
  State<RegisterSuccess> createState() => _RegisterSuccessState();
}

class _RegisterSuccessState extends State<RegisterSuccess> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const HtmlWidget(
            "<h2 style='text-align:center;font-weight:bold;'>Complimenti! Ti sei registrato con successo!</h2>"),
        constants.SPACER_MEDIUM,
        ElevatedButton(
          style: constants.STILE_BOTTONE,
          onPressed: () {
            constants.userStatus = 0;
            widget.logParent();
          },
          child: const Text("ACCEDI!"),
        ),
      ],
    );
  }
}
