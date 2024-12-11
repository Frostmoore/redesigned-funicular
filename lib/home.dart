// import 'package:Assidim/sections/indirizzo.dart';
import 'package:Assidim/sections/preventivo.dart';
import 'package:Assidim/sections/documento.dart';
import 'package:flutter/material.dart';
//import 'package:Assidim/sections/cai.dart';
import 'package:Assidim/sections/contatti.dart';
import 'package:Assidim/sections/info.dart';
import 'package:Assidim/sections/nome_social.dart';
import 'package:Assidim/sections/sinistro.dart';
import 'package:Assidim/sections/header.dart';
import 'package:Assidim/assets/constants.dart' as constants;

class HomePage extends StatefulWidget {
  final data;
  const HomePage({super.key, required this.data});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Header(data: widget.data),
          constants.SPACER,
          NomeSocial(data: widget.data),
          Info(data: widget.data),
          //constants.SPACER,
          Contatti(data: widget.data),
          //constants.SPACER,
          Sinistro(data: widget.data),
          Preventivo(data: widget.data),
          Documento(data: widget.data),
          constants.SPACER,
          constants.SPACER,
          /*Cai(),*/
        ],
      ),
    );
  }
}
