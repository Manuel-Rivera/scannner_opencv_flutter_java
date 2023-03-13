import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Model/docuement_model.dart';
import '../../Providers/document_provider.dart';
import '../scanner_screen/pdf_screen.dart';

//TODO:ARRGELAR PROBLEMA CUANDO HAY CERO DOCUMENTOS

class Search extends SearchDelegate {
  static GlobalKey<AnimatedListState> animatedListKey =
      GlobalKey<AnimatedListState>();
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = "";
          }),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      List<DocumentModel> documentList = getAllDocuments(context);
      return ListView.builder(
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PDFScreen(
                  document: documentList[index],
                ),
              ));
            },
            leading: Image.file(File(documentList[index].documentPath)),
            title: Text(documentList[index].name),
            subtitle: Text(
                "${documentList[index].dateTime.day.toString()}/${documentList[index].dateTime.month.toString()}/${documentList[index].dateTime.year.toString()}"),
          ),
        ),
        itemCount: documentList.length - 1,
      );
    } else {
      List<DocumentModel> documentList = getAllDocuments(context)
          .where((element) => element.name.startsWith(query))
          .toList();
      return ListView.builder(
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PDFScreen(document: documentList[index]),
              ));
            },
            leading: Image.file(File(documentList[index].documentPath)),
            title: RichText(
              text: TextSpan(
                  text: documentList[index].name.substring(0, query.length),
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                        text: documentList[index].name.substring(query.length),
                        style: const TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.normal))
                  ]),
            ),
            subtitle: Text(
                "${documentList[index].dateTime.day.toString()}/${documentList[index].dateTime.month.toString()}/${documentList[index].dateTime.year.toString()}"),
          ),
        ),
        itemCount: documentList.length,
      );
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      List<DocumentModel> documentList = getAllDocuments(context);
      return ListView.builder(
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PDFScreen(document: documentList[index]),
              ));
            },
            leading: Image.file(File(documentList[index].documentPath)),
            title: Text(documentList[index].name),
            subtitle: Text(
                "${documentList[index].dateTime.day.toString()}/${documentList[index].dateTime.month.toString()}/${documentList[index].dateTime.year.toString()}"),
          ),
        ),
        itemCount: documentList.length - 1,
      );
    } else {
      List<DocumentModel> documentList = getAllDocuments(context)
          .where((element) => element.name.startsWith(query))
          .toList();
      return ListView.builder(
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PDFScreen(document: documentList[index]),
              ));
            },
            leading: Image.file(File(documentList[index].documentPath)),
            title: RichText(
              text: TextSpan(
                  text: documentList[index].name.substring(0, query.length),
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                        text: documentList[index].name.substring(query.length),
                        style: const TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.normal))
                  ]),
            ),
            subtitle: Text(
                "${documentList[index].dateTime.day.toString()}/${documentList[index].dateTime.month.toString()}/${documentList[index].dateTime.year.toString()}"),
          ),
        ),
        itemCount: documentList.length,
      );
    }
  }
}

List<DocumentModel> getAllDocuments(BuildContext context) {
  return Provider.of<ImagesProvider>(context, listen: false).listDocuments;
}
