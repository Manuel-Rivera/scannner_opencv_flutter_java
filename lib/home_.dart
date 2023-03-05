import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import 'Providers/document_provider.dart';
import 'drawer.dart';
import 'new_image.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static GlobalKey<AnimatedListState> animatedListKey =
      GlobalKey<AnimatedListState>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                  onPressed: () async {
                    chooseIImage(ImageSource.camera);
                  },
                  icon: const Icon(Icons.camera)),
              Container(
                color: Colors.white.withOpacity(0.2),
                width: 2,
                height: 15,
              ),
              IconButton(
                  onPressed: () {
                    chooseIImage(ImageSource.gallery);
                  },
                  icon: const Icon(Icons.image))
            ],
          )),
      drawer: const SafeArea(child: Drawer(child: DocDrawer())),
      appBar: AppBar(
        title: const Text("Doc Scan"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              //showSearch(context: context, delegate: Search());
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder(
          future: getAllDocuments(),
          builder: ((context, snapshot) {
            if (!snapshot.hasData) {
              // ignore: avoid_print
              print("has not data");
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              // ignore: avoid_print
              print("error");
              return const CircularProgressIndicator();
            }
            return SizedBox(
                height: MediaQuery.of(context).size.height - 81,
                child: AnimatedList(
                  key: animatedListKey,
                  itemBuilder: ((context, index, animation) {
                    // ignore: avoid_print
                    print(index);
                    if (index ==
                        Provider.of<DocumentProvider>(context)
                                .allDocuments
                                .length -
                            1) {
                      // ignore: avoid_print
                      print("last");
                      return const SizedBox(height: 100);
                    }
                    return buildDocumentCard(index, animation);
                  }),
                  initialItemCount: Provider.of<DocumentProvider>(context)
                      .allDocuments
                      .length,
                ));
          })),
    );
  }

  Future<bool> getAllDocuments() async {
    // ignore: avoid_print
    print("inside get documents");
    return await Provider.of<DocumentProvider>(context, listen: false)
        .getDocuments();
  }

  Future<void> onRefresh() async {
    // ignore: avoid_print
    print("refreshed");
    Provider.of<DocumentProvider>(context, listen: false).getDocuments();
  }

  Widget buildDocumentCard(int index, Animation<double> animation) {
    return SizeTransition(
        sizeFactor: animation,
        child: StatefulBuilder(
          builder: (context, setState) => GestureDetector(
            onTap: () {
              /*Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PDFScreen(
                  document: Provider.of<DocumentProvider>(context)
                      .allDocuments[index],
                  animatedListKey: animatedListKey,
                ),
              ));*/
            },
            child: Card(
              color: ThemeData.dark().cardColor,
              elevation: 3,
              margin:
                  const EdgeInsets.only(left: 12, right: 12, bottom: 5, top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 12, top: 12, right: 12),
                    child: Container(
                        decoration: const BoxDecoration(
                            border: Border(
                                left: BorderSide(color: Colors.grey),
                                right: BorderSide(color: Colors.grey),
                                top: BorderSide(color: Colors.grey))),
                        child: Image.file(
                            File(Provider.of<DocumentProvider>(context)
                                .allDocuments[index]
                                .documentPath),
                            fit: BoxFit.cover,
                            height: 150,
                            width: 130)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 150,
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          Provider.of<DocumentProvider>(context)
                              .allDocuments[index]
                              .name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          "${Provider.of<DocumentProvider>(context).allDocuments[index].dateTime.day}-${Provider.of<DocumentProvider>(context).allDocuments[index].dateTime.month}-${Provider.of<DocumentProvider>(context).allDocuments[index].dateTime.year}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(
                        height: 60,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 180,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.share,
                                color: ThemeData.dark().colorScheme.secondary,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.cloud_upload,
                                color: ThemeData.dark().colorScheme.secondary,
                              ),
                              onPressed: () {},
                            ),
                            IconButton(
                                icon: Icon(
                                  Icons.more_vert,
                                  color: ThemeData.dark().colorScheme.secondary,
                                ),
                                onPressed: () {
                                  showModalSheet(
                                      index: index,
                                      filePath: Provider.of<DocumentProvider>(
                                              context,
                                              listen: false)
                                          .allDocuments[index]
                                          .documentPath,
                                      dateTime: Provider.of<DocumentProvider>(
                                              context,
                                              listen: false)
                                          .allDocuments[index]
                                          .dateTime,
                                      name: Provider.of<DocumentProvider>(
                                              context,
                                              listen: false)
                                          .allDocuments[index]
                                          .name,
                                      pdfPath: Provider.of<DocumentProvider>(
                                              context,
                                              listen: false)
                                          .allDocuments[index]
                                          .pdfPath);
                                })
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  void chooseIImage(ImageSource source) async {
    final xfile = await ImagePicker().pickImage(source: source);
    late final File fileGallery;
    if (mounted && xfile != null) {
      fileGallery = File(xfile.path);
      Navigator.of(context).push(MaterialPageRoute(
          builder: ((context) => NewImage(fileGallery, animatedListKey))));
    } else {
      return;
    }
  }

  void showModalSheet(
      {required int index,
      required String filePath,
      required String name,
      required DateTime dateTime,
      required String pdfPath}) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 15),
                  child: Container(
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: Image.file(
                      File(filePath),
                      height: 80,
                      width: 50,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 150,
                      padding: const EdgeInsets.only(left: 12, bottom: 12),
                      child: Text(
                        name,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 18),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          "${dateTime.day}-${dateTime.month}-${dateTime.year}",
                          style: TextStyle(color: Colors.grey[400]),
                        )),
                  ],
                )
              ],
            ),
            const Divider(
              thickness: 2,
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Rename"),
              onTap: () {
                Navigator.pop(context);
                showRenameDialog(index: index, name: name, dateTime: dateTime);
              },
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text("Print"),
              onTap: () async {
                Navigator.pop(context);
                final pdf = File(pdfPath);
                await Printing.layoutPdf(
                    onLayout: (_) => pdf.readAsBytesSync());
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Delete"),
              onTap: () {
                Navigator.pop(context);
                showDeleteDialog1(index: index, dateTime: dateTime);
              },
            )
          ],
        );
      },
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

              Provider.of<DocumentProvider>(context, listen: false)
                  .deleteDocument(
                      index, dateTime.millisecondsSinceEpoch.toString());
              Timer(const Duration(milliseconds: 300), () {
                animatedListKey.currentState?.removeItem(
                    index,
                    (context, animation) =>
                        buildDocumentCard(index, animation));
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
}
