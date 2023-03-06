import 'dart:async';
import 'dart:io';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../Model/docuement_model.dart';
import '../../Providers/document_provider.dart';

// ignore: must_be_immutable
class PDFScreen extends StatefulWidget {
  late DocumentModel document;
  late GlobalKey<AnimatedListState> animatedListKey;

  PDFScreen(
      {super.key,
      required this.document,
      required GlobalKey<AnimatedListState> animatedListKey});

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
                      await FlutterShare.shareFile(
                          title: "pdf", filePath: widget.document.pdfPath);
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
                    Provider.of<DocumentProvider>(context, listen: false)
                        .allDocuments;
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
                    Provider.of<DocumentProvider>(context, listen: false)
                        .allDocuments;
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
                Navigator.of(context).pop();
                setState(() {
                  widget.document.name = controller.text;
                });
                Provider.of<DocumentProvider>(context, listen: false)
                    .renameDocument(
                        index,
                        dateTime.millisecondsSinceEpoch.toString(),
                        controller.text);
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
              "Delete file",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(
              thickness: 2,
            ),
            Text(
              "Are you sure you want to delete this file?",
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
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Provider.of<DocumentProvider>(context, listen: false)
                  .deleteDocument(
                      index, dateTime.millisecondsSinceEpoch.toString());
              Timer(const Duration(milliseconds: 300), () {
                widget.animatedListKey.currentState?.removeItem(
                    index, (context, animation) => const SizedBox());
              });
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
