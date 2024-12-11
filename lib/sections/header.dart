import 'package:flutter/material.dart';
import 'package:Assidim/assets/constants.dart' as constants;

class Header extends StatefulWidget {
  final data;
  Header({super.key, required this.data});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var header_dirty = widget.data['header_agenzia'];
    var header = header_dirty.replaceAll('\\', '/');
    var logo_dirty = widget.data['logo_agenzia'];
    var logo = logo_dirty.replaceAll('\\', '/');

    return SizedBox(
      height: 270,
      child: Stack(
        alignment: const Alignment(-1, -1),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Image.network(constants.IMG_PATH + header,
                        height: 200, fit: BoxFit.fitWidth),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 130,
            left: (width / 2 - 70),
            child: CircleAvatar(
              radius: 70,
              backgroundColor: Colors.white,
              child: Material(
                elevation: 10,
                borderRadius: const BorderRadius.all(Radius.circular(100)),
                child: CircleAvatar(
                  radius: 68,
                  backgroundImage: NetworkImage(constants.IMG_PATH + logo),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
