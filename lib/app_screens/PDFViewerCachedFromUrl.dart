import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controllers/pdf_type_controller.dart';

class PDFViewerCachedFromUrl extends StatelessWidget {
   PDFViewerCachedFromUrl({Key? key, required this.url}) : super(key: key);

  final String url;
  // PdfTypeController pdfTypeController = Get.put(PdfTypeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF'),
      ),
      body: const PDF().cachedFromUrl(
        url,
        placeholder: (double progress) => Center(child: Text('$progress %')),
        errorWidget: (dynamic error) => Center(child: Text(error.toString())),
      ),
    );
  }
  // void pdfButtonClick(BuildContext context, String pdfType) {
  //    pdfTypeController.setPdfType(pdfType);
  //    getPdfDownloadPath( context, modelOPDRegistration.patientIDP!);
  //  }
}
