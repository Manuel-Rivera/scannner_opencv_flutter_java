import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';

import 'crop_painter.dart';

// ignore: must_be_immutable
class CropImage extends StatefulWidget {
  late File file;
  CropImage(this.file, {super.key});
  @override
  State<CropImage> createState() => _NewImageState();
}

class _NewImageState extends State<CropImage> {
  bool isFile = false;
  late Offset tl, tr, bl, br;
  bool isLoading = false;
  late double width, height;
  final GlobalKey _containerkey = GlobalKey();
  late Size imagePixel;
  MethodChannel channel = const MethodChannel('opencv');
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(),
              Stack(
                children: [
                  GestureDetector(
                    onPanDown: (details) {
                      double x1 = details.localPosition.dx;
                      double y1 = details.localPosition.dy;
                      double x2 = tl.dx;
                      double y2 = tl.dy;
                      double x3 = tr.dx;
                      double y3 = tr.dy;
                      double x4 = bl.dx;
                      double y4 = bl.dy;
                      double x5 = br.dx;
                      double y5 = br.dy;
                      if (sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)) <
                              60 &&
                          x1 >= 0 &&
                          y1 >= 0 &&
                          x1 < width / 2 &&
                          y1 < height / 2) {
                        // ignore: avoid_print
                        print(details.localPosition);
                        setState(() {
                          tl = details.localPosition;
                        });
                      } else if (sqrt((x3 - x1) * (x3 - x1) +
                                  (y3 - y1) * (y3 - y1)) <
                              60 &&
                          x1 >= width / 2 &&
                          y1 >= 0 &&
                          x1 < width &&
                          y1 < height / 2) {
                        setState(() {
                          tr = details.localPosition;
                        });
                      } else if (sqrt((x4 - x1) * (x4 - x1) +
                                  (y4 - y1) * (y4 - y1)) <
                              60 &&
                          x1 >= 0 &&
                          y1 >= height / 2 &&
                          x1 < width / 2 &&
                          y1 < height) {
                        setState(() {
                          bl = details.localPosition;
                        });
                      } else if (sqrt((x5 - x1) * (x5 - x1) +
                                  (y5 - y1) * (y5 - y1)) <
                              60 &&
                          x1 >= width / 2 &&
                          y1 >= height / 2 &&
                          x1 < width &&
                          y1 < height) {
                        setState(() {
                          br = details.localPosition;
                        });
                      } else {
                        // ignore: avoid_print
                        //print(height);
                      }
                    },
                    onPanUpdate: ((details) {
                      double x1 = details.localPosition.dx;
                      double y1 = details.localPosition.dy;
                      double x2 = tl.dx;
                      double y2 = tl.dy;
                      double x3 = tr.dx;
                      double y3 = tr.dy;
                      double x4 = bl.dx;
                      double y4 = bl.dy;
                      double x5 = br.dx;
                      double y5 = br.dy;
                      if (sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)) <
                              60 &&
                          x1 >= 0 &&
                          y1 >= 0 &&
                          x1 < width / 2 &&
                          y1 < height / 2) {
                        // ignore: avoid_print
                        print(details.localPosition);
                        setState(() {
                          tl = details.localPosition;
                        });
                      } else if (sqrt((x3 - x1) * (x3 - x1) +
                                  (y3 - y1) * (y3 - y1)) <
                              60 &&
                          x1 >= width / 2 &&
                          y1 >= 0 &&
                          x1 < width &&
                          y1 < height / 2) {
                        setState(() {
                          tr = details.localPosition;
                        });
                      } else if (sqrt((x4 - x1) * (x4 - x1) +
                                  (y4 - y1) * (y4 - y1)) <
                              60 &&
                          x1 >= 0 &&
                          y1 >= height / 2 &&
                          x1 < width / 2 &&
                          y1 < height) {
                        setState(() {
                          bl = details.localPosition;
                        });
                      } else if (sqrt((x5 - x1) * (x5 - x1) +
                                  (y5 - y1) * (y5 - y1)) <
                              60 &&
                          x1 >= width / 2 &&
                          y1 >= height / 2 &&
                          x1 < width &&
                          y1 < height) {
                        setState(() {
                          br = details.localPosition;
                        });
                      }
                    }),
                    child: SafeArea(
                      child: Container(
                        color: Colors.amber,
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 20,
                            maxHeight:
                                MediaQuery.of(context).size.height - 200),
                        child: Image.file(
                          key: _containerkey,
                          widget.file,
                          fit: BoxFit.contain,
                          frameBuilder:
                              (context, child, frame, wasSynchronouslyLoaded) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              // ignore: avoid_print
                              print(frame);
                              if (frame == 0 && isFile == false) {
                                // ignore: avoid_print
                                //print("SIZE");
                                //Size? containersize = context.size;
                                //Size? containersize =
                                //    _containerkey.currentContext?.size as Size;
                                // ignore: avoid_print
                                imagePixel = ImageSizeGetter.getSize(
                                    FileInput(widget.file));

                                width =
                                    _containerkey.currentContext!.size!.width;
                                height =
                                    _containerkey.currentContext!.size!.height;

                                setState(() {
                                  tl = const Offset(0, 0);
                                  tr = Offset(width - 0, 0);
                                  bl = Offset(0, height - 0);
                                  br = Offset(width - 0, height - 0);
                                  isFile = true;
                                });
                              }
                            });
                            return child;
                          },
                        ),
                      ),
                    ),
                  ),
                  isFile
                      ? SafeArea(
                          child: SafeArea(
                          child: CustomPaint(
                            painter: CropPainter(tl, tr, bl, br),
                          ),
                        ))
                      : const SizedBox()
                ],
              ),
              bottomSheet()
            ]),
      ),
    );
  }

  Widget bottomSheet() {
    return Container(
        color: ThemeData.dark().canvasColor,
        //TODO:width
        width: MediaQuery.of(context).size.width,
        height: 120,
        child: Center(
          child: Column(
            children: [
              const Text("Drag the handles to adjust the borders. You can",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "also do this later using the ",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Icon(
                    Icons.crop,
                    color: Colors.white,
                  ),
                  Text(
                    " tool.",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        //TODO:RETAKE
                      },
                      child: const Text("Retake")),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 100,
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.blue),
                        // ignore: sort_child_properties_last
                        child: isLoading
                            ? const SizedBox(
                                width: 60.0,
                                height: 20.0,
                                child: Center(
                                  child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      // ignore: prefer_const_constructors
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.white),
                                      )),
                                ))
                            : isFile
                                ? TextButton(
                                    onPressed: () {
                                      //TODO:On preset
                                      setState(() {
                                        isLoading = true;
                                      });
                                      //TODO:Agregar funciones
                                      double tlX =
                                          (imagePixel.width / width) * tl.dx;
                                      double trX =
                                          (imagePixel.width / width) * tr.dx;
                                      double blX =
                                          (imagePixel.width / width) * bl.dx;
                                      double brX =
                                          (imagePixel.width / width) * br.dx;

                                      double tlY =
                                          (imagePixel.height / height) * tl.dy;
                                      double trY =
                                          (imagePixel.height / height) * tr.dy;
                                      double blY =
                                          (imagePixel.height / height) * bl.dy;
                                      double brY =
                                          (imagePixel.height / height) * br.dy;
                                      Timer(const Duration(seconds: 1),
                                          () async {
                                        var bytesArray = await channel
                                            .invokeMethod('convertToGray', {
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
                                        // ignore: use_build_context_synchronously
                                        Navigator.of(context).pop([
                                          bytesArray,
                                          tlX,
                                          tlY,
                                          trX,
                                          trY,
                                          blX,
                                          blY,
                                          brX,
                                          brY
                                        ]);
                                      });
                                    },
                                    child: const Text(
                                      "Continue",
                                      softWrap: true,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ))
                                : const SizedBox(
                                    width: 60,
                                    height: 20,
                                    child: Center(
                                        child: SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        Colors.white))))),
                      ))
                ],
              )
            ],
          ),
        ));
  }
}
