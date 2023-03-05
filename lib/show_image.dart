import 'dart:async';
import 'dart:io';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:provider/provider.dart';

import 'Providers/document_provider.dart';
import 'crop_image.dart';

// ignore: must_be_immutable
class ShowImage extends StatefulWidget {
  final File file;
  final Offset tl, tr, bl, br;
  final double height, width;
  final GlobalKey<AnimatedListState> animatedListKey;
  late Size imagePixel;

  ShowImage(
      {super.key,
      required this.file,
      required this.bl,
      required this.br,
      required this.tl,
      required this.tr,
      required this.height,
      required this.width,
      required this.imagePixel,
      required this.animatedListKey});

  @override
  State<ShowImage> createState() => _ShowImageState();
}

class _ShowImageState extends State<ShowImage> {
  TextEditingController nameController = TextEditingController();
  late PersistentBottomSheetController controller;
  final _focusNode = FocusNode();
  MethodChannel channel = const MethodChannel('opencv');
  dynamic whiteboardBytes;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  dynamic bytes;
  dynamic originalBytes;
  dynamic grayBytes;
  bool isRotating = false;
  bool isBottomOpened = false;
  int index = 0;
  int angle = 0;
  late double tlX;
  late double trX;
  late double blX;
  late double brX;
  late double tlY;
  late double trY;
  late double blY;
  late double brY;
  bool isGrayBytes = false;
  bool isOriginalBytes = false;
  bool isWhiteBoardBytes = false;
  String canvasType = "whiteboard";

  @override
  void initState() {
    super.initState();
    nameController.text = "Scan${DateTime.now()}";
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        nameController.selection = TextSelection(
            baseOffset: 0, extentOffset: nameController.text.length);
      }
    });

    tlX = (widget.imagePixel.width / widget.width) * widget.tl.dx;
    trX = (widget.imagePixel.width / widget.width) * widget.tr.dx;
    blX = (widget.imagePixel.width / widget.width) * widget.bl.dx;
    brX = (widget.imagePixel.width / widget.width) * widget.br.dx;

    tlY = (widget.imagePixel.height / widget.height) * widget.tl.dy;
    trY = (widget.imagePixel.height / widget.height) * widget.tr.dy;
    blY = (widget.imagePixel.height / widget.height) * widget.bl.dy;
    brY = (widget.imagePixel.height / widget.height) * widget.br.dy;

    // ignore: avoid_print
    print("ddd");
    // ignore: avoid_print
    print(tlX);
    // ignore: avoid_print
    print(trX);
    // ignore: avoid_print
    print(blY);
    // ignore: avoid_print
    print(brY);
    // ignore: avoid_print
    print("ff");

    convertToGray();
    BackButtonInterceptor.add(myInterceptor);
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (isBottomOpened) {
      Navigator.of(context).pop();
      isBottomOpened = false;
    }
    showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              content: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    "Discart this scan",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Divider(thickness: 2),
                  Text(
                    "This will discart the scans you have captured. Are you sure",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                OutlinedButton(
                    onPressed: () {},
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.black),
                    )),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text(
                    "Discart",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            )));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.grey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                color: Colors.black,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.clear, color: Colors.white)),
                        TextButton(
                            onPressed: () async {
                              //TODO:SAVE HAS PDF
                              Navigator.of(context).pop();
                              await widget.file
                                  .writeAsBytes(bytes)
                                  .then((_) async {
                                ImageSizeGetter.getSize(FileInput(widget.file));
                                Provider.of<DocumentProvider>(context,
                                        listen: false)
                                    .saveDocument(
                                        name: nameController.text,
                                        documentPath: widget.file.path,
                                        dateTime: DateTime.now(),
                                        shareLink: "",
                                        animatedListKey: widget.animatedListKey,
                                        angle: angle);
                              });
                            },
                            child: const Text("save has pdf"))
                      ],
                    ),
                    Container(
                      width: 150,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: ThemeData.dark().canvasColor),
                      child: TextFormField(
                        focusNode: _focusNode,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                        controller: nameController,
                      ),
                    )
                  ],
                ),
              ),
              bytes == null
                  ? Container()
                  : isRotating
                      ? const Center(
                          child: SizedBox(
                            height: 150,
                            width: 100,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.black),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            //constraints: const BoxConstraints(
                            //+    maxHeight: 300, maxWidth: 250),
                            child: Image.memory(bytes),
                          ),
                        )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        selectedItemColor: Colors.black,
        onTap: (index) async {
          if (index == 0) {
            if (isBottomOpened) {
              isBottomOpened = false;
              Navigator.of(context).pop();
            }
            setState(() {
              isRotating = true;
            });
            Timer(const Duration(seconds: 1), () async {
              bytes = await channel.invokeMethod('rotate', {"bytes": bytes});
            });
            Timer(const Duration(seconds: 4), () async {
              if (angle == 360) {
                angle = 0;
              }
              angle = angle + 90;
              bytes = await channel
                  .invokeMethod('rotateCompleted', {"bytes": bytes});
              setState(() {
                isRotating = false;
              });
            });
          }
          if (index == 1) {
            if (isBottomOpened) {
              isBottomOpened = false;
              Navigator.of(context).pop();
            }
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (context) => CropImage(widget.file),
              ),
            )
                .then((value) {
              if (value != null) {
                tlX = value[1];
                tlY = value[2];
                trX = value[3];
                trY = value[4];
                blX = value[5];
                blY = value[6];
                brX = value[7];
                brY = value[8];
                setState(() {
                  bytes = value[0];
                  isGrayBytes = false;
                  isOriginalBytes = false;
                  isWhiteBoardBytes = false;
                });
              }
            });
          }
          if (index == 2) {
            if (isBottomOpened) {
              Navigator.of(context).pop();
              isBottomOpened = false;
            } else {
              isBottomOpened = true;
              BottomSheet bottomSheet = BottomSheet(
                onClosing: () {},
                builder: (context) => colorBottomsheet(),
                enableDrag: true,
              );
              controller = scaffoldKey.currentState!
                  .showBottomSheet((context) => bottomSheet);
            }
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.rotate_right,
                color: Colors.black,
              ),
              label: "Rotate"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.crop,
                color: Colors.black,
              ),
              label: "Crop"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.color_lens,
                color: Colors.black,
              ),
              label: "Color"),
        ],
      ),
    );
  }

  Widget colorBottomsheet() {
    if (isOriginalBytes == false) {
      //TODO:GRAYandoriginal
      grayandoriginal();
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              if (originalBytes != null) {
                Navigator.of(context).pop();
                isBottomOpened = false;
                canvasType = 'original';
                Timer(const Duration(microseconds: 500), () {
                  angle = 0;
                  setState(() {
                    bytes = originalBytes;
                  });
                });
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: isOriginalBytes
                      ? Image.memory(
                          originalBytes,
                          fit: BoxFit.fill,
                          height: 120,
                        )
                      : const SizedBox(
                          height: 120,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.black),
                              ),
                            ),
                          ),
                        ),
                ),
                const Text("Original"),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // ignore: avoid_print
              print("whiteboard");
              Navigator.of(context).pop();
              isBottomOpened = false;
              angle = 0;
              canvasType = "whiteboard";
              Timer(
                const Duration(microseconds: 500),
                () {
                  setState(() {
                    bytes = whiteboardBytes;
                  });
                },
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: isWhiteBoardBytes
                      ? Image.memory(
                          whiteboardBytes,
                          fit: BoxFit.fill,
                          height: 120,
                        )
                      : const SizedBox(
                          height: 120,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.black),
                              ),
                            ),
                          ),
                        ),
                ),
                const Text("Whiteboard")
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // ignore: avoid_print
              print("gray");
              Navigator.of(context).pop();
              isBottomOpened = false;
              angle = 0;
              canvasType = "gray";
              Timer(
                const Duration(microseconds: 500),
                () {
                  setState(() {
                    bytes = grayBytes;
                  });
                },
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: isWhiteBoardBytes
                      ? Image.memory(
                          grayBytes,
                          fit: BoxFit.fill,
                          height: 120,
                        )
                      : const SizedBox(
                          height: 120,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.black),
                              ),
                            ),
                          ),
                        ),
                ),
                const Text("Grayscale")
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> convertToGray() async {
    var bytesArray = await channel.invokeMethod('convertToGray', {
      'filePath': widget.file.path,
      'tl_x': tlX,
      'tl_y': tlY,
      'tr_x': trX,
      'tr_y': trY,
      'bl_x': blX,
      'bl_y': blY,
      'br_x': brX,
      'br_y': brY,
    });
    setState(() {
      // ignore: avoid_print
      //print(bytesArray);
      bytes = bytesArray;
      whiteboardBytes = bytesArray;
    });
    return bytesArray;
  }

  Future<void> grayandoriginal() async {
    Future.delayed(const Duration(seconds: 1), () {
      channel.invokeMethod('gray', {
        'filePath': widget.file.path,
        'tl_x': tlX,
        'tl_y': tlY,
        'tr_x': trX,
        'tr_y': trY,
        'bl_x': blX,
        'bl_y': blY,
        'br_x': brX,
        'br_y': brY,
      });
      channel.invokeMethod('whiteboard', {
        'filePath': widget.file.path,
        'tl_x': tlX,
        'tl_y': tlY,
        'tr_x': trX,
        'tr_y': trY,
        'bl_x': blX,
        'bl_y': blY,
        'br_x': brX,
        'br_y': brY,
      });
      channel.invokeMethod('original', {
        'filePath': widget.file.path,
        'tl_x': tlX,
        'tl_y': tlY,
        'tr_x': trX,
        'tr_y': trY,
        'bl_x': blX,
        'bl_y': blY,
        'br_x': brX,
        'br_y': brY,
      });
    });
    Timer(const Duration(seconds: 7), () {
      // ignore: avoid_print
      print("this started");
      channel.invokeMethod('grayCompleted').then((value) {
        grayBytes = value;
        isGrayBytes = true;
      });
      channel.invokeMethod('whiteboardCompleted').then((value) {
        whiteboardBytes = value;
        isWhiteBoardBytes = true;
      });
      channel.invokeMethod('originalCompleted').then((value) {
        originalBytes = value;
        isOriginalBytes = true;
        if (isBottomOpened) {
          Navigator.pop(context);
          BottomSheet bottomSheet = BottomSheet(
            onClosing: () {},
            builder: (context) => colorBottomsheet(),
            enableDrag: true,
          );
          controller = scaffoldKey.currentState!
              .showBottomSheet((context) => bottomSheet);
        }
      });
    });
  }
}
