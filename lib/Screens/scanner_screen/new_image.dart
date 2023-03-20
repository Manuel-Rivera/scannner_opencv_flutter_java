import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';

import 'crop_painter.dart';
import 'show_image.dart';

class NewImage extends StatefulWidget {
  final File file;
  const NewImage(this.file, {super.key});
  @override
  State<NewImage> createState() => _NewImageState();
}

class _NewImageState extends State<NewImage> {
  bool isFile = false;
  late Offset tl, tr, bl, br;

  bool isLoading = false;
  late double width, height;
  late Size imagePixel;
  late Uint8List imagebytes = Uint8List(0);
  MethodChannel channel = const MethodChannel('opencv');

  @override
  void initState() {
    super.initState();
    getCornersImage(widget.file.path);
    // imageToUint8List(widget.file.path);
  }

  Future<void> getCornersImage(String imgpath) async {
    Uint8List imgbytes =
        await channel.invokeMethod("getCorners", {"imagePath": imgpath});
    //!Se obtienen las dimeciones de la imagen real
    imagePixel = ImageSizeGetter.getSize(FileInput(widget.file));

    setState(() {
      imagebytes = imgbytes;
    });
  }

  Future<Uint8List> imageToUint8List(String imagePath) async {
    //!Se leé la imagen y se obtienen sus bytes
    final bytes = await File(imagePath).readAsBytes();
    setState(() {
      imagebytes = bytes;
    });
    //!Se obtienen las dimeciones de la imagen real
    imagePixel = ImageSizeGetter.getSize(FileInput(widget.file));
    //!Se retorna imagen en bytes
    return Uint8List.fromList(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: ThemeData.dark().canvasColor,
        child: Center(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(),
                Stack(
                  children: [
                    GestureDetector(
                      onPanDown: (details) => onPanDownImage(details),
                      onPanUpdate: (details) => onPanUpdateImage(details),
                      child: SafeArea(
                        child: Container(
                          constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width - 20,
                              maxHeight:
                                  MediaQuery.of(context).size.height - 200),
                          child: imagebytes.isEmpty
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.blue),
                                  ),
                                )
                              : Image.memory(
                                  imagebytes,
                                  fit: BoxFit.scaleDown,
                                  frameBuilder: (context, child, frame,
                                      wasSynchronouslyLoaded) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      //!alternativas para obtener el size
                                      //!context.size & key.currentcontext.size
                                      final RenderBox img = context
                                          .findRenderObject() as RenderBox;
                                      //!frame sera null ates de que el primer cuadro de la imagen se presente por lo que tiene que ser diferente de null para conocer las dimesiones de la imagen
                                      if (isFile == false && frame != null) {
                                        //!Se obtiene las dimeciones de la imagen renderizada
                                        width = img.size.width;
                                        height = img.size.height;
                                        //!Se asignan cordenadas a custom painter de acuerdo a las dimeciones obtenidas
                                        setState(() {
                                          tl = const Offset(0, 0);
                                          tr = Offset(width - 0, 0);
                                          bl = Offset(0, height - 0);
                                          br = Offset(width - 0, height - 0);
                                          isFile = true;
                                        });
                                      }
                                    });
                                    //!Se renderiza imagen hasta que se evaluan dimesiones
                                    return child;
                                  },
                                ),
                        ),
                      ),
                    ),
                    //!Si exite imagen se pinta cuadro de recorte
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
                //!BOTON DE ACCIONES SOBRE LA IMAGEN SELECCIONADA
                bottomSheet()
              ]),
        ),
      ),
    );
  }

  //!METODOS USADOS AL SELECCIONAR AREA DE IMAGEN PARA RECORTAR

  void onPanDownImage(details) {
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
    if (sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)) < 50 &&
        x1 >= 0 &&
        y1 >= 0 &&
        x1 < width / 2 &&
        y1 < height / 2) {
      //print(details.localPosition);
      setState(() {
        tl = details.localPosition;
      });
    } else if (sqrt((x3 - x1) * (x3 - x1) + (y3 - y1) * (y3 - y1)) < 50 &&
        x1 >= width / 2 &&
        y1 >= 0 &&
        x1 < width &&
        y1 < height / 2) {
      setState(() {
        tr = details.localPosition;
      });
    } else if (sqrt((x4 - x1) * (x4 - x1) + (y4 - y1) * (y4 - y1)) < 50 &&
        x1 >= 0 &&
        y1 >= height / 2 &&
        x1 < width / 2 &&
        y1 < height) {
      setState(() {
        bl = details.localPosition;
      });
    } else if (sqrt((x5 - x1) * (x5 - x1) + (y5 - y1) * (y5 - y1)) < 50 &&
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
  }

  void onPanUpdateImage(details) {
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
    if (sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)) < 50 &&
        x1 >= 0 &&
        y1 >= 0 &&
        x1 < width / 2 &&
        y1 < height / 2) {
      // ignore: avoid_print
      //print(details.localPosition);
      setState(() {
        tl = details.localPosition;
      });
    } else if (sqrt((x3 - x1) * (x3 - x1) + (y3 - y1) * (y3 - y1)) < 50 &&
        x1 >= width / 2 &&
        y1 >= 0 &&
        x1 < width &&
        y1 < height / 2) {
      setState(() {
        tr = details.localPosition;
      });
    } else if (sqrt((x4 - x1) * (x4 - x1) + (y4 - y1) * (y4 - y1)) < 50 &&
        x1 >= 0 &&
        y1 >= height / 2 &&
        x1 < width / 2 &&
        y1 < height) {
      setState(() {
        bl = details.localPosition;
      });
    } else if (sqrt((x5 - x1) * (x5 - x1) + (y5 - y1) * (y5 - y1)) < 50 &&
        x1 >= width / 2 &&
        y1 >= height / 2 &&
        x1 < width &&
        y1 < height) {
      setState(() {
        br = details.localPosition;
      });
    }
  }

  //!BOTON DE ACCIONES SOBRE LA IMAGEN SELECCIONADA
  Widget bottomSheet() {
    return Container(
        color: ThemeData.dark().canvasColor,
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
                  //!CANCELAR EDICIÓN
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Cancelar")),
                  //!BOTÓN CONTINUAR CON LA IMAGEN SELECCIONADA
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 100,
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.blue),
                        child: isLoading
                            //!Loading al presionr continuar una vez que se recorto imagen
                            ? const SizedBox(
                                width: 60.0,
                                height: 20.0,
                                child: Center(
                                  child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.white),
                                      )),
                                ))
                            : isFile
                                //!Se recorto imagen y se presiono en continuar
                                ? TextButton(
                                    onPressed: () {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      Navigator.of(context)
                                          .pushReplacement(MaterialPageRoute(
                                              builder: (context) => ShowImage(
                                                    imagebytes: imagebytes,
                                                    tl: tl,
                                                    tr: tr,
                                                    bl: bl,
                                                    br: br,
                                                    width: width,
                                                    height: height,
                                                    file: widget.file,
                                                    imagePixel: imagePixel,
                                                  )));
                                    },
                                    child: const Text(
                                      "Continue",
                                      softWrap: true,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ))
                                //!Loading que se muestra al cargarce imagen seleccioanda
                                : const SizedBox(
                                    width: 60,
                                    height: 20,
                                    child: Center(
                                      child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(
                                              Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                      ))
                ],
              )
            ],
          ),
        ));
  }
}
