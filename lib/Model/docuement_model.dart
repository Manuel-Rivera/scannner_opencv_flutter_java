class DocumentModel {
  String name;
  String shareLink;
  String documentPath;
  DateTime dateTime;
  String pdfPath;
  bool enviando = false;
  DocumentModel(
      {required this.name,
      this.shareLink = "",
      required this.documentPath,
      required this.dateTime,
      required this.pdfPath,
      });
}
