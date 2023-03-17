import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:xml/xml.dart';

import '../../Model/docuement_model.dart';
import '../../Model/informacion_formulario.dart';
import '../../Providers/document_provider.dart';
import '../../Providers/login_provider.dart';
import '../../widgets/widgets.dart';
import '../scanner_screen/drawer.dart';
import '../scanner_screen/new_image.dart';
import '../scanner_screen/pdf_screen.dart';
import 'search.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //!DRAWER
      drawer: const SafeArea(
        child: Drawer(child: DocDrawer()),
      ),
      //!APPBAR
      appBar: AppBar(
        title: const Text("Scanner UMSNH"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              showSearch(context: context, delegate: Search());
            },
          ), /*
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              /!IMPLEMENTAR MAS OPCIONES
            },
          ),*/
        ],
      ),
      //!SELECCIONAR IMAGEN
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          label: Row(
            //!SE SELECCIONA DE DONDE OBTENER LA IMAGEN
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                  //!Se selecciona imagen de camara
                  onPressed: () async {
                    chooseIImage(context, ImageSource.camera);
                  },
                  icon: const Icon(Icons.camera)),
              Container(
                color: Colors.white.withOpacity(0.2),
                width: 2,
                height: 15,
              ),
              IconButton(
                  onPressed: () {
                    //!Se selecciona imagen de galeria
                    chooseIImage(context, ImageSource.gallery);
                  },
                  icon: const Icon(Icons.image))
            ],
          )),
      //!BODY DE HOME LISTA DE CARDS
      body: SizedBox(
        child: Consumer<ImagesProvider>(builder: (context, docProvider, child) {
          return docProvider.listDocuments.isNotEmpty
              ? AnimatedList(
                  //!Se instancia la global key animatedListKey
                  key: Provider.of<GlobalKeyStore>(context, listen: false)
                      .animatedListKey,
                  initialItemCount: docProvider.listDocuments.length,
                  itemBuilder: (context, index, animation) {
                    DocumentModel document = docProvider.listDocuments[index];
                    return _documentCard(context, document, animation);
                  })
              : const Center(child: CircularProgressIndicator());
        }),
      ),
    );
  }

  //!SELECCIONA IMAGEN DE GALERIA O CAMARA
  void chooseIImage(BuildContext context, ImageSource source) {
    ImagePicker().pickImage(source: source).then((xfile) {
      if (xfile != null) {
        //!Se otrienta la imagen acorde a los metadatos EXIF  y posterior a ello se pasa la imagen a NewImage
        FlutterExifRotation.rotateImage(path: xfile.path).then((fileGalery) {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => NewImage(fileGalery)));
        });
      } else {
        return;
      }
    });
  }

  //!DOCUMENT CARD
  Widget _documentCard(BuildContext context, DocumentModel document,
      Animation<double> animation) {
    bool enviando = false;
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        margin: const EdgeInsets.only(left: 12, right: 12, bottom: 5, top: 5),
        elevation: 3,
        color: ThemeData.dark().cardColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 12, right: 12, top: 12, bottom: 12),
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.grey),
                    right: BorderSide(color: Colors.grey),
                    top: BorderSide(color: Colors.grey),
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    //*Visualizar PDF en card
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PDFScreen(
                        document: document,
                      ),
                    ));
                  },
                  child: document.pdfPath.isNotEmpty
                      ? Image.file(File(document.documentPath),
                          fit: BoxFit.cover, height: 150, width: 130)
                      : const SizedBox(
                          height: 150,
                          width: 130,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 150,
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    document.name,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    "${document.dateTime.day}-${document.dateTime.month}-${document.dateTime.year}",
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
                        onPressed: () {
                          //TODO:SHARE DOCUMENT
                        },
                        icon: Icon(
                          Icons.share,
                          color: ThemeData.dark().colorScheme.secondary,
                        ),
                      ),
                      StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          if (enviando) {
                            return const CircularProgressIndicator();
                          } else {
                            return IconButton(
                              icon: Icon(
                                Icons.cloud_upload,
                                color: ThemeData.dark().colorScheme.secondary,
                              ),
                              onPressed: () async {
                                InformacionFormulario? result =
                                    await formularioEnvio(context);
                                if (result != null &&
                                    result.respuesta.compareTo("cancel") != 0) {
                                  print(
                                      "************ result.respuesta: ${result.respuesta}");
                                  print(
                                      "************ matricula: ${result.matricula}");
                                  print(
                                      "************ tipoDocumento: ${result.tipoDocumento}");
                                  print(
                                      "************ Comentarios: ${result.comentarios}");
                                  print(
                                      "************ tipoDocumentoPersonal: ${result.tipoDocumentoPersonal}");
                                  //Evita el envio multiple del mismo archivo si ya esta enviandose
                                  if (!enviando) {
                                    print("ENVIADO");
                                    enviando = true;
                                    setState(() {});
                                    sendFile(context, document, result)
                                        .then((tuple) {
                                      //int arriva = tuple.item1;
                                      String mensaje = tuple.item2;
                                      enviando = false;
                                      setState(() {});
                                      alertaDocumentoSubido(context, mensaje);
                                    });
                                  }
                                }
                              },
                            );
                          }
                        },
                      ),
                      IconButton(
                          icon: Icon(
                            Icons.more_vert,
                            color: ThemeData.dark().colorScheme.secondary,
                          ),
                          onPressed: () {
                            //!SHOW MODAL SHEET
                            showModalSheet(
                                document: document, context: context);
                          })
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  //!SHOW MODAL SHEET
  void showModalSheet(
      {required DocumentModel document, required BuildContext context}) {
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
                      File(document.documentPath),
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
                        document.name,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 18),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          "${document.dateTime.day}-${document.dateTime.month}-${document.dateTime.year}",
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
              title: const Text("Renombrar documento"),
              onTap: () {
                //!RENAME DOCUMENT
                Navigator.pop(context);
                showRenameDialog(document: document, context: context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text("Print"),
              onTap: () async {
                Navigator.pop(context);
                final pdf = File(document.pdfPath);
                await Printing.layoutPdf(
                    onLayout: (_) => pdf.readAsBytesSync());
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Delete"),
              onTap: () {
                //!DELETE DOCUMENT
                Navigator.pop(context);
                showDeleteDialog1(context: context, document: document);
              },
            )
          ],
        );
      },
    );
  }

//!SHOW RENAME DIALOG
  void showRenameDialog({
    required BuildContext context,
    required DocumentModel document,
  }) {
    TextEditingController controller = TextEditingController();
    controller.text = document.name;
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
          Consumer<ImagesProvider>(
            builder: ((context, docProvider, child) {
              return OutlinedButton(
                onPressed: () {
                  //!SE cambia el estado de animatedlist al realizar el cambio del nombre
                  Provider.of<GlobalKeyStore>(context, listen: false)
                      .animatedListKey
                      .currentState
                      // ignore: invalid_use_of_protected_member
                      ?.setState(() {});
                  //!Se cambia el nombre del documento
                  docProvider.renameDocument(document, controller.text);
                  //!Se regresa a la pagina anterior
                  Navigator.of(context).pop();
                },
                child: const Text("Rename"),
              );
            }),
          ),
        ],
      ),
    );
  }

  //!SHOW DELETE DIALOG
  void showDeleteDialog1(
      {required BuildContext context, required DocumentModel document}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              "Eliminar Archivo",
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
              //!SE LLAMA AL METODO REMOVEITEM
              _removeItem(context, document);
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
        ?.removeItem(
            index,
            (context, animation) =>
                _documentCard(context, document, animation));
    //!SE ELIMINA ITEM DE LISTA DE DOCUMENTOS
    docProvider.remove(document);
    //!SE REGRESA A LA PANTALL ANTERIOR
    Navigator.of(context).pop();
  }

  //Envia una peticion para obtener el nombre del archivo a subir (numero consecutivo)
  Future<Tuple2<int, String>> numeroArchivo(BuildContext context) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://148.216.31.181:8080/siia/ldXML'),
    );

    // Parametros
    request.fields['lista'] = 'lista';
    request.fields['cuso'] = 'comun.cntArchis';

    print('JSESSIONID=${context.read<LoginProvider>().obtenerIdSesion()}');
    // Set the session ID as a cookie in the request headers
    request.headers['cookie'] =
        'JSESSIONID=${context.read<LoginProvider>().obtenerIdSesion()}';
    try {
      // Send the request and get the response
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      //var responseBody = "";

      //La respuesta viene en un HTML asi que se convierte en un XmlDocument
      final document = XmlDocument.parse(responseBody);
      final cntElement = document.findAllElements('CNT').first;
      final cntValue = cntElement.text;
      return Tuple2(1, cntValue);
    } catch (e) {
      return Tuple2(0, e.toString());
    }
  }

  Future<Tuple2<int, String>> sendFile(BuildContext context,
      DocumentModel document, InformacionFormulario formInfo) async {
        print("SEND FILE");
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://148.216.31.181:8080/siia/carPDF'),
    );

    // Add the file parameter to the request
    var file = File(document.pdfPath);
    var stream = http.ByteStream(file.openRead());
    var length = await file.length();
    var multipartFile =
        http.MultipartFile('archi', stream, length, filename: 'example.pdf');

    request.files.add(multipartFile);

    //Secuencia del archivo a subir
    Tuple2<int, String> respNum = await numeroArchivo(context);

    //Si hubo un fallo al obtener el siguiente numero de secuencia
    print("respNum: $respNum");
    if (respNum.item1 == 0) {
      return respNum;
    }

    // Add other parameters to the request
    request.fields['usr'] = context.read<LoginProvider>().obtenerUsuario();
    request.fields['num'] = respNum.item2;                        //Numero de la secuencia que le corresponde al archivo
    request.fields['dir'] = 'archivos';                           //Directorio donde se guardara el arhivo
    request.fields['id'] = respNum.item2;                         //Id del archivo
    request.fields['coments'] = 'Desde flutter';                  //Comentarios
    request.fields['arch_alumno'] = formInfo.matricula;           //Matricula del alumno que le corresponde el archivo
    request.fields['arch_nombre'] = document.name;                //Nombre real del archivo
                                                                  //Tipo de documento (Por defecto es PDF)
    request.fields['arch_ctype'] = formInfo.tipoDocumento.isNotEmpty ? formInfo.tipoDocumento : "PDF";
    request.fields['arch_size'] = file.lengthSync().toString();   //Tamaño del archivo en bytes
    request.fields['arch_tdoc'] = formInfo.tipoDocumentoPersonal; //Tipo de documento
    request.fields['arch_boveda'] = '1';                          //Identificador en la boveda
    //request.fields['arch_wid'] = '';                            //Identificador ascendente para el siia web (OPCIONAL) Se obtiene desde el servlet
    request.fields['arch_warchid'] = '';                          //Identificador archivo siia web            (OPCIONAL)
    request.fields['arch_comen'] = formInfo.comentarios;          //Comentarios                               (OPCIONAL)
    // Set the session ID as a cookie in the request headers
    request.headers['cookie'] =
        'JSESSIONID=${context.read<LoginProvider>().obtenerIdSesion()}';

    try {
      // Send the request and get the response
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseBody);
      print("jsonResponse: $jsonResponse");
      //Si se recibio una respuesta
      if (response.statusCode == 200) {
        //Si la respuesta contiene un error
        if (jsonResponse.containsKey('ERROR')) {
          return Tuple2(0, jsonResponse["ERROR"]);
        }
        if (jsonResponse.containsKey('OK')) {
          return const Tuple2(1, "OK");
        }
      }
      //Respuesta negativa
      return Tuple2(0, response.statusCode.toString());
    } catch (e) {
      //Cuando no se reciba una respuesta
      return Tuple2(0, e.toString());
    }
  }
}
