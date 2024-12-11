import 'package:flutter/material.dart';
import 'package:Assidim/assets/constants.dart' as constants;

class NomeSocial extends StatefulWidget {
  final data;
  const NomeSocial({super.key, required this.data});

  @override
  State<NomeSocial> createState() => _NomeSocialState();
}

class _NomeSocialState extends State<NomeSocial> {
  @override
  Widget build(BuildContext context) {
    var nome_agenzia = widget.data['nome_agenzia'];
    var facebook_agenzia = widget.data['facebook_agenzia'];
    var instagram_agenzia = widget.data['instagram_agenzia'];
    var linkedin_agenzia = widget.data['linkedin_agenzia'];
    var google_agenzia = widget.data['google_agenzia'];
    var sito_agenzia = widget.data['sito_agenzia'];
    return Container(
      child: Column(
        children: [
          Text(
            nome_agenzia,
            textAlign: TextAlign.center,
            style: constants.H1,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (facebook_agenzia != '')
                  IconButton(
                    onPressed: () =>
                        constants.openUrl(Uri.parse(facebook_agenzia)),
                    icon: constants.IMAGE_FACEBOOK,
                  ),
                if (instagram_agenzia != '')
                  IconButton(
                    onPressed: () =>
                        constants.openUrl(Uri.parse(instagram_agenzia)),
                    icon: constants.IMAGE_INSTAGRAM,
                  ),
                if (linkedin_agenzia != '')
                  IconButton(
                    onPressed: () =>
                        constants.openUrl(Uri.parse(linkedin_agenzia)),
                    icon: constants.IMAGE_LINKEDIN,
                  ),
                if (google_agenzia != '')
                  IconButton(
                    onPressed: () =>
                        constants.openUrl(Uri.parse(google_agenzia)),
                    icon: constants.IMAGE_GOOGLE,
                  ),
                if (sito_agenzia != '')
                  IconButton(
                    onPressed: () => constants.openUrl(Uri.parse(sito_agenzia)),
                    icon: constants.IMAGE_WEBSITE,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
