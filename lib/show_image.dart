import 'dart:async';
import 'dart:io';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:document_scanner/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShowImage extends StatefulWidget {
  final File file;
  final Offset tl, tr, bl, br;
  final double height, width;
  final GlobalKey<AnimatedListState> animatedListKey;
  final double pixelsw, pixelsh;
  const ShowImage(
      {super.key,
      required this.file,
      required this.bl,
      required this.br,
      required this.tl,
      required this.tr,
      required this.height,
      required this.width,
      required this.pixelsw,
      required this.pixelsh,
      required this.animatedListKey});

  @override
  State<ShowImage> createState() => _ShowImageState();
}

class _ShowImageState extends State<ShowImage> {
  TextEditingController nameController = TextEditingController();
  final _focusNode = FocusNode();
  MethodChannel channel = const MethodChannel('opencv');
  var whiteboardBytes;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  var bytes;
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
    tlX = (widget.pixelsw / widget.width) * widget.tl.dx;
    trX = (widget.pixelsw / widget.width) * widget.tr.dx;
    blX = (widget.pixelsw / widget.width) * widget.bl.dx;
    brX = (widget.pixelsw / widget.width) * widget.br.dx;

    tlY = (widget.pixelsw / widget.height) * widget.tl.dy;
    trY = (widget.pixelsw / widget.height) * widget.tr.dy;
    blY = (widget.pixelsw / widget.height) * widget.bl.dy;
    brY = (widget.pixelsw / widget.height) * widget.br.dy;
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
                  Text("Discart this scan",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Divider(thickness: 2),
                  Text(
                      "This will discart the scans you have captured. Are you sure",
                      style: TextStyle(color: Colors.grey))
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
                    child: const Text("Discart",
                        style: TextStyle(color: Colors.red)))
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
                            onPressed: () {
                              //TODO:SAVE HAS PDF
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
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.black),
                                      )))))
                      : Center(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            constraints: const BoxConstraints(
                                maxHeight: 300, maxWidth: 250),
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
            Navigator.of(context).push(MaterialPageRoute(
                builder: ((context) => CropImage(widget.file))));
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
      print(bytesArray);
      bytes = bytesArray;
      whiteboardBytes = bytesArray;
    });
    return bytesArray;
  }
}
