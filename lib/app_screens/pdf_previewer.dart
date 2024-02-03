
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:swasthyasetu/app_screens/pdf_preview.dart';
import 'package:swasthyasetu/app_screens/pdf_resume.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/podo/model_profile_patient.dart';

class PDFPreviewer extends StatelessWidget {
  PatientProfileModel patientProfileModel;
  dynamic jsonObj;

  PDFPreviewer(this.patientProfileModel, this.jsonObj);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      /*appBar: AppBar(title: Text("Profile")),*/
      body: PdfPreview(
        build: (format) => generateResume(
            PdfPageFormat(SizeConfig.screenWidth!, SizeConfig.screenHeight!),
            patientProfileModel,
            jsonObj),
      ),
    );
  }
}
