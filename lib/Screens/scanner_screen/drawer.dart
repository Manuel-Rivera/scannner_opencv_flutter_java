import 'package:flutter/material.dart';

class DocDrawer extends StatelessWidget {
  const DocDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          color: ThemeData.dark().canvasColor,
          child: Image.asset('lib/Model/images/docIcon.png'),
        ),
        const ListTile(
          leading: Icon(Icons.settings),
          title: Text("Settings"),
        ),
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text("About this App"),
        ),
        const ListTile(
          leading: Icon(Icons.share),
          title: Text("Share this App"),
        )
      ],
    );
  }
}
