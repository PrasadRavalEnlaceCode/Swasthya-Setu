import 'package:get/get.dart';

class PdfTypeController extends GetxController {
  RxString pdfType = "".obs;

  void setPdfType(String pdfType) {
    this.pdfType.value = pdfType;
  }
}
