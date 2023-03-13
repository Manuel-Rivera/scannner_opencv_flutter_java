import 'dart:io';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../Model/docuement_model.dart';
import '../../Providers/document_provider.dart';

class PDFScreen extends StatefulWidget {
  final DocumentModel document;

  const PDFScreen({super.key, required this.document});

  @override
  State<PDFScreen> createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  bool isShowDialog = false;
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isShowDialog
          ? moreSheet(widget.document)
          : PDFViewerScaffold(
              appBar: AppBar(
                title: const Text("Document"),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () async {
                      /*
                      await FlutterShare.shareFile(
                          title: "pdf", filePath: widget.document.pdfPath);*/
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.cloud_upload),
                    onPressed: () async {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () async {
                      setState(() {
                        isShowDialog = true;
                      });
                    },
                  ),
                ],
              ),
              path: widget.document.pdfPath),
    );
  }

  Widget moreSheet(DocumentModel document) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Stack(
              children: <Widget>[
                SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 400,
                    child: Image.file(File(document.documentPath))),
                Positioned(
                  top: 350,
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      color: Colors.black.withOpacity(0.7),
                      child: Center(
                        child: Text(
                          document.name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      )),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isShowDialog = false;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(30)),
                      child: const Icon(
                        Icons.clear,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Rename"),
              onTap: () {
                late int docIndex;
                List<DocumentModel> documents =
                    Provider.of<ImagesProvider>(context, listen: false)
                        .listDocuments;
                for (int index = 0; index < documents.length; index++) {
                  if (document.dateTime == documents[index].dateTime) {
                    docIndex = index;
                  }
                }
                showRenameDialog(
                    index: docIndex,
                    dateTime: document.dateTime,
                    name: document.name);
              },
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text("Print"),
              onTap: () async {
                final pdf = File(document.pdfPath);
                await Printing.layoutPdf(
                    onLayout: (_) => pdf.readAsBytesSync());
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Delete"),
              onTap: () {
                late int docIndex;
                List<DocumentModel> documents =
                    Provider.of<ImagesProvider>(context, listen: false)
                        .listDocuments;
                for (int index = 0; index < documents.length; index++) {
                  if (document.dateTime == documents[index].dateTime) {
                    docIndex = index;
                  }
                }
                showDeleteDialog1(index: docIndex, dateTime: document.dateTime);
              },
            )
          ],
        ),
      ),
    );
  }

  void showRenameDialog(
      {required int index, required DateTime dateTime, required String name}) {
    TextEditingController controller = TextEditingController();
    controller.text = name;
    controller.selection =
        TextSelection(baseOffset: 0, extentOffset: controller.text.length);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text("Rename"),
            TextFormField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                  suffix: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                      })),
            ),
          ],
        ),
        actions: <Widget>[
          OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel")),
          OutlinedButton(
              onPressed: () {
                //!SE cambia el estado de animatedlist al realizar el cambio del nombre
                Provider.of<GlobalKeyStore>(context, listen: false)
                    .animatedListKey
                    .currentState
                    ?.setState(() {});
                //!Se cambia el nombre del documento
                Provider.of<ImagesProvider>(context, listen: false)
                    .renameDocument(widget.document, controller.text);
                //!Se regresa a la pagina anterior
                Navigator.of(context).pop();
              },
              child: const Text("Rename")),
        ],
      ),
    );
  }

  void showDeleteDialog1({required int index, required DateTime dateTime}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              "Eliminar archivo",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(
              thickness: 2,
            ),
            Text(
              "¿Estas seguro de querer eliminar este archivo?",
              style: TextStyle(color: Colors.grey[500]),
            )
          ],
        ),
        actions: <Widget>[
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.black),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              _removeItem(context, widget.document);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          )
        ],
      ),
    );
  }

  _removeItem(BuildContext context, DocumentModel document) {
    //!SE INTACIA PROVIDER
    final docProvider = Provider.of<ImagesProvider>(context, listen: false);
    //!SE OBTIENE EL INDEX DEL ELEMENTO A ELIMINAR
    final index = docProvider.listDocuments.indexOf(document);
    //!SE ELIMINA ITEM DE ANIMATEDLIST
    Provider.of<GlobalKeyStore>(context, listen: false)
        .animatedListKey
        .currentState
        ?.removeItem(index, (context, animation) => const SizedBox());
    //!SE ELIMINA ITEM DE LISTA DE DOCUMENTOS
    docProvider.remove(document);
    //!SE REGRESA A LA PANTALL ANTERIOR
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    super.dispose();
    BackButtonInterceptor.remove(myInterceptor);
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (isShowDialog) {
      setState(() {
        isShowDialog = false;
      });
    } else {
      Navigator.of(context).pop();
    }
    return true;
  }
}
