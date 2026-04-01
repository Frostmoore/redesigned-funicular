import 'package:Assidim/sections/contatti.dart';
import 'package:Assidim/sections/documento.dart';
import 'package:Assidim/sections/header.dart';
import 'package:Assidim/sections/info.dart';
import 'package:Assidim/sections/nome_social.dart';
import 'package:Assidim/sections/preventivo.dart';
import 'package:Assidim/sections/sinistro.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          Header(),
          constants.SPACER,
          NomeSocial(),
          Info(),
          Contatti(),
          Sinistro(),
          Preventivo(),
          Documento(),
          constants.SPACER,
          constants.SPACER,
        ],
      ),
    );
  }
}
