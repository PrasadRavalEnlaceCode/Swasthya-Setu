import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:silvertouch/app_screens/pdf_preview.dart';
import 'package:silvertouch/app_screens/pdf_resume.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_investigation_list_doctor.dart';
import 'package:silvertouch/podo/model_profile_patient.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';

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
