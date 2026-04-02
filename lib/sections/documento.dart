import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Documento extends StatelessWidget {
  const Documento({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppProvider>().config!;

    final url = Uri.parse(
      'https://${constants.PATH}/documento.php?id=${constants.ID}',
    );

    return SectionCard(
      icon: Icons.folder_open_rounded,
      iconColor: const Color(0xFF1E88E5),
      title: config.documentoTitolo,
      subtitle: config.documentoTesto,
      onTap: () => constants.openUrl(url),
    );
  }
}
