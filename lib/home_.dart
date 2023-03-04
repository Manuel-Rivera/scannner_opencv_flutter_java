import 'dart:io';

import 'package:document_scanner/Providers/document_provider.dart';
import 'package:document_scanner/drawer.dart';
import 'package:document_scanner/new_image.dart';
import 'package:document_scanner/pdf_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PDFScreen(
                  document: Provider.of<DocumentProvider>(context)
                      .allDocuments[index],
                  animatedListKey: animatedListKey,
                ),
              ));
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
                      // child: Image.file(
                      //     File(Provider.of<DocumentProvider>(context)
                      //         .allDocuments[index]
                      //         .documentPath),
                      //     fit: BoxFit.cover,
                      //     height: 150,
                      //     width: 130)
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  )
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
}
