import 'package:flutter/material.dart';
import 'package:Assidim/assets/constants.dart' as constants;

class Notifica extends StatelessWidget {
  final data;
  const Notifica({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    var notifica_titolo = data['notifica_titolo'];
    var notifica_testo = data['notifica_testo'];
    var notifica_link = data['notifica_link'];

    if (notifica_testo != '') {
      return Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              style: BorderStyle.solid,
              color: Colors.black,
            ),
            color: const Color.fromARGB(25, 255, 0, 0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  notifica_titolo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Color.fromARGB(255, 119, 20, 13),
                  ),
                ),
                Text(
                  notifica_testo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (notifica_link != '')
                  ElevatedButton(
                    onPressed: () =>
                        constants.openUrl(Uri.parse(notifica_link)),
                    child: const Text('Scopri di più'),
                  ),
              ],
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
