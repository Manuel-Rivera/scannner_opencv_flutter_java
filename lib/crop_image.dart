import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'crop_painter.dart';

// ignore: must_be_immutable
class CropImage extends StatefulWidget {
  late File file;
  CropImage(this.file, {super.key});
  @override
  State<CropImage> createState() => _CropImageState();
}

class _CropImageState extends State<CropImage> {
  //late Size imagePixelSize;
  late double pixelsw, pixelsh;
  final GlobalKey key = GlobalKey();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late double width, height;
  bool isFile = false;
  late Offset tl, tr, bl, br;
  bool isLoading = false;
  late Future<void> _imgFuture;
  @override
  void initState() {
    super.initState();
    _imgFuture = _loadImage();
  }

  Future<void> _loadImage() async {
    final completar = Completer<void>();
    final image = Image.file(widget.file);
    final ImageStream imgstream = image.image.resolve(ImageConfiguration.empty);
    //render box hace referencia al archivo cargado en base al contexto
    //RenderBox imageBox;
    imgstream.addListener(ImageStreamListener((image, synchronousCall) {
      setState(() {
        // ignore: avoid_print
        // ignore: avoid_print
        //Sin ebargo el imageBox no tiene el size de la imagen -> no se usa en este caso ya que espera el key y este no se obtiene hasta que se carga la imagen
        //imageBox = key.currentContext?.findRenderObject() as RenderBox;
        //TODO:Se optienen los datos de la imagen
        //get size image
        // ignore: avoid_print
        pixelsw = image.image.width.toDouble();
        pixelsh = image.image.height.toDouble();

        //imagePixelSize = ImageSizeGetter.getSize(FileInput(widget.file));
        // ignore: avoid_print
        //print(imagePixelSize.width);

        //Sin embargo se usara tamaño de container en lugar de las dimesiones de la imagen se obtiene el tamaño del container
        double cwidth = MediaQuery.of(context).size.width;
        width = cwidth - 20;
        double cheight = MediaQuery.of(context).size.height;
        height = cheight - 200;

        //Se cargan los valores de las variables para Render Box
        tl = const Offset(30, 30);
        tr = Offset(width - 30, 30);
        bl = Offset(30, height - 30);
        br = Offset(width - 30, height - 30);
        //Se indica que se cargo imagen
        isFile = true;
      });
      completar.complete();
    }));
    await completar.future;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_print
    return FutureBuilder(
        future: _imgFuture,
        builder: ((context, snapshot) {
          // ignore: avoid_print
          print(snapshot.connectionState);
          return Container(
            child: snapshot.connectionState == ConnectionState.done
                ? Scaffold(
                    backgroundColor: ThemeData.dark().canvasColor,
                    key: _scaffoldKey,
                    body: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                                  if (sqrt((x2 - x1) * (x2 - x1) +
                                              (y2 - y1) * (y2 - y1)) <
                                          50 &&
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
                                          50 &&
                                      x1 >= width / 2 &&
                                      y1 >= 0 &&
                                      x1 < width &&
                                      y1 < height / 2) {
                                    setState(() {
                                      tr = details.localPosition;
                                    });
                                  } else if (sqrt((x4 - x1) * (x4 - x1) +
                                              (y4 - y1) * (y4 - y1)) <
                                          50 &&
                                      x1 >= 0 &&
                                      y1 >= height / 2 &&
                                      x1 < width / 2 &&
                                      y1 < height) {
                                    setState(() {
                                      bl = details.localPosition;
                                    });
                                  } else if (sqrt((x5 - x1) * (x5 - x1) +
                                              (y5 - y1) * (y5 - y1)) <
                                          50 &&
                                      x1 >= width / 2 &&
                                      y1 >= height / 2 &&
                                      x1 < width &&
                                      y1 < height) {
                                    setState(() {
                                      br = details.localPosition;
                                    });
                                  } else {
                                    // ignore: avoid_print
                                    print(height);
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
                                  if (sqrt((x2 - x1) * (x2 - x1) +
                                              (y2 - y1) * (y2 - y1)) <
                                          50 &&
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
                                          50 &&
                                      x1 >= width / 2 &&
                                      y1 >= 0 &&
                                      x1 < width &&
                                      y1 < height / 2) {
                                    setState(() {
                                      tr = details.localPosition;
                                    });
                                  } else if (sqrt((x4 - x1) * (x4 - x1) +
                                              (y4 - y1) * (y4 - y1)) <
                                          50 &&
                                      x1 >= 0 &&
                                      y1 >= height / 2 &&
                                      x1 < width / 2 &&
                                      y1 < height) {
                                    setState(() {
                                      bl = details.localPosition;
                                    });
                                  } else if (sqrt((x5 - x1) * (x5 - x1) +
                                              (y5 - y1) * (y5 - y1)) <
                                          50 &&
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
                                        width: width,
                                        height: height,
                                        color: ThemeData.dark().canvasColor,
                                        //TODO:VALIDAR TAMAÑO DE IMAGEN
                                        //constraints: BoxConstraints(
                                        //     maxHeight: height, maxWidth: width),
                                        child: Image.file(
                                          widget.file,
                                          key: key,
                                        ))),
                              ),
                              isFile
                                  ? SafeArea(
                                      child: CustomPaint(
                                      painter: CropPainter(tl, tr, bl, br),
                                    ))
                                  : const SizedBox()
                            ],
                          ),
                          bottomSheet()
                        ],
                      ),
                    ))
                : const Text("Cargando Imagen"),
          );
        }));
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
              const Text(
                "Drag the handles to adjust the borders. You can",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
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
                    child: const Text("Retake"),
                  ),
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
                                      //TODO:sddsdfs
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
