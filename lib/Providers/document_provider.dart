import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/docuement_model.dart';

//!GLOBAL KEYS PROVIDER
class GlobalKeyStore extends ChangeNotifier {
  GlobalKey<AnimatedListState> animatedListKey = GlobalKey<AnimatedListState>();
}

//!IMAGEPROVIDER
class ImagesProvider extends ChangeNotifier {
  final List<DocumentModel> _documents = [
    //!DOCUMENTO DEPRUEBA
    /*
    DocumentModel(
        name: "firstCard55466222",
        documentPath: "",
        dateTime: DateTime.utc(1969, 7, 20, 20, 18, 04),
        pdfPath: "",
        shareLink: "")*/
  ];

  //!CONSTRUCTOR DE PROVIDER
  ImagesProvider() {
    loadDocuments();
  }

  //!LOAD DATA FOR SHAREPREFERENCES PERSIST DATA
  loadDocuments() {
    SharedPreferences.getInstance().then((instanse) {
      instanse.getKeys().forEach((key) {
        var jsonDocument = json.decode(instanse.getString(key) ?? "");
        DocumentModel document = DocumentModel(
            name: jsonDocument['name'],
            documentPath: jsonDocument['documentPath'],
            dateTime: DateTime.parse(jsonDocument['dateTime']),
            pdfPath: jsonDocument['pdfPath'],
            shareLink: jsonDocument['shareLink']);
        _documents.add(document);
        notifyListeners();
      });
    });
  }

  //!GET DOCUMENTS
  List<DocumentModel> get listDocuments => _documents;

  //!ADD IMAGE
  void addImage(
      {required String name,
      required String documentPath,
      required DateTime dateTime,
      required String shareLink,
      required int angle}) async {
    final pdf = pw.Document();
    //!CONVERT IMAGE TO PDF
    final image = pw.MemoryImage(File(documentPath).readAsBytesSync());
    pdf.addPage(pw.Page(
      pageFormat: const PdfPageFormat(2480, 3508),
      build: (pw.Context context) {
        return pw.Center(child: pw.Image(image));
        /*return pw.Image(image,
            fit: angle == 0 || angle == 180
                ? pw.BoxFit.fill
                : pw.BoxFit.fitWidth);*/
      },
    ));
    final tempDir = await getApplicationDocumentsDirectory();
    String pdfPath = "${tempDir.path}/$name.pdf";
    File pdfFile = File(pdfPath);
    pdfFile.writeAsBytes(await pdf.save());
    //!GENERATE MODEL DOCUMENT
    final DocumentModel newDocumnt = DocumentModel(
        name: name,
        documentPath: documentPath,
        dateTime: dateTime,
        shareLink: shareLink,
        pdfPath: pdfPath);
    //!SAVE NEW DOCUMENT
    _documents.add(newDocumnt);

    //!SORT DOCUMENTS PARA MOSTRAR EL ELEMENTO NUEVO HASTA ARRIDA EN EL ANIMMATEDLIST
    _documents.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    notifyListeners();

    //!SAVE NEWDOCUMENTE IN SHARE PREFERENCES

    String jsonDocument = json.encode({
      "name": name,
      "documentPath": documentPath,
      "dateTime": dateTime.toString(),
      "shareLink": shareLink,
      "pdfPath": pdfPath
    });
    SharedPreferences.getInstance().then((instance) {
      instance.setString(
          dateTime.millisecondsSinceEpoch.toString(), jsonDocument);
    });
  }

//!REMOVE DOCUMENT
  void remove(DocumentModel document) {
    final index = _documents.indexOf(document);
    if (index >= 0) {
      _documents.removeAt(index);
      notifyListeners();
    }

    SharedPreferences.getInstance().then((instanse) {
      instanse.remove(document.dateTime.millisecondsSinceEpoch.toString());
    });
  }

  //!RENAME DOCUMENTS
  void renameDocument(DocumentModel document, String newName) async {
    //!Se Cambia el nombre
    document.name = newName;
    notifyListeners();

    //!Se actualiza el nombre en Share preferences
    SharedPreferences.getInstance().then((instanse) {
      //!Se elimina el anterior documento
      instanse.remove(document.dateTime.millisecondsSinceEpoch.toString());
      //! Se guarda el nuevo documento con los datos actualizados
      String jsonDocument = json.encode({
        "name": document.name,
        "documentPath": document.documentPath,
        "dateTime": document.dateTime.toString(),
        "shareLink": document.shareLink,
        "pdfPath": document.pdfPath
      });
      instanse.setString(
          document.dateTime.millisecondsSinceEpoch.toString(), jsonDocument);
    });
  }
}
