import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/model_profile_patient.dart';

const PdfColor green = PdfColor.fromInt(0xff9ce5d0);
const PdfColor lightGreen = PdfColor.fromInt(0xffcdf1e7);
const sep = 120.0;

Future<Uint8List> generateResume(PdfPageFormat format,
    PatientProfileModel patientProfileModel, jsonObj) async {
  pw.Document doc = pw.Document();

  /*final profileImage = pw.MemoryImage(
    (await rootBundle.load('assets/profile.jpg')).buffer.asUint8List(),
  );*/
  /*final image = PdfImage.file(
    doc.document,
    bytes: File('test.webp').readAsBytesSync(),
  );*/

  //pdfImageFromImage(pdf: , image: null);
  final pageTheme = await _myPageTheme(format);

  ByteData bytes;
  pw.ImageProvider imageProvider;
  if (patientProfileModel.imgUrl != "" &&
      patientProfileModel.imgUrl != null &&
      patientProfileModel.imgUrl != "null") {
    var response =
        await get(Uri.parse("$userImgUrl${patientProfileModel.imgUrl}"));
    bytes = ByteData.sublistView(response.bodyBytes);
    imageProvider = pw.RawImage(
        bytes: bytes.buffer.asUint8List(),
        height: (SizeConfig.blockSizeHorizontal !* 26.0).toInt(),
        width: (SizeConfig.blockSizeHorizontal !* 26.0).toInt());
  } else {
    bytes = await rootBundle.load('images/ic_user_placeholder.png');
    imageProvider = pw.RawImage(
        bytes: bytes.buffer.asUint8List(),
        height: (SizeConfig.blockSizeHorizontal !* 26.0).toInt(),
        width: (SizeConfig.blockSizeHorizontal !* 26.0).toInt());
  }

  doc.addPage(
    pw.MultiPage(
      pageTheme: pageTheme,
      build: (pw.Context context) => [
        pw.Partitions(
          children: [
            pw.Partition(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Container(
                    padding: const pw.EdgeInsets.only(
                      left: 5,
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Image(
                                  /*PdfImage.file(
                                    doc.document,
                                    bytes: bytes.buffer.asUint8List(),
                                  ),*/
                                  imageProvider,
                                  height: SizeConfig.blockSizeHorizontal !* 26.0,
                                  width: SizeConfig.blockSizeHorizontal !* 26.0),
                              pw.SizedBox(
                                height: SizeConfig.blockSizeVertical !* 0.3,
                              ),
                              pw.Text(patientProfileModel.patientID!.trim(),
                                  style: pw.Theme.of(context)
                                      .defaultTextStyle
                                      .copyWith(
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColors.blueGrey,
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal !*
                                                  3.3)),
                            ]),
                        pw.SizedBox(
                          height: SizeConfig.blockSizeVertical !* 2.0,
                        ),
                        pw.Text(
                            patientProfileModel.firstName!.trim() +
                                " " +
                                patientProfileModel.middleName!.trim() +
                                " " +
                                patientProfileModel.lastName!.trim(),
                            textScaleFactor: 2,
                            style: pw.Theme.of(context)
                                .defaultTextStyle
                                .copyWith(fontWeight: pw.FontWeight.bold)),
                        /*pw.Text('Electrotyper',
                            textScaleFactor: 1.2,
                            style: pw.Theme.of(context)
                                .defaultTextStyle
                                .copyWith(
                                    fontWeight: pw.FontWeight.bold,
                                    color: green)),*/
                        /*pw.Padding(padding: const pw.EdgeInsets.only(top: 20)),*/
                      ],
                    ),
                  ),
                  _Category(title: 'General Profile'),
                  pw.Padding(
                    padding:
                        const pw.EdgeInsets.only(left: 10, top: 5, bottom: 5),
                  ),
                  _Block(title: 'Mobile No.', value: patientProfileModel.mobNo),
                  _Block(
                      title: 'Gender',
                      value: patientProfileModel.gender == "M"
                          ? "Male"
                          : patientProfileModel.gender == "F"
                              ? "Female"
                              : "-"),
                  _Block(title: 'Email', value: patientProfileModel.emailId),
                  _Block(
                      title: 'Emergency Number',
                      value: patientProfileModel.emergencyNumber),
                  _Block(
                      title: 'Date of birth', value: patientProfileModel.dob),
                  _Block(title: 'Age', value: patientProfileModel.age),
                  _Block(
                      title: 'Height (cm)', value: patientProfileModel.height),
                  _Block(
                      title: 'Weight (Kg)', value: patientProfileModel.weight),
                  _Block(title: 'Address', value: patientProfileModel.address),
                  _Block(title: 'City', value: patientProfileModel.city),
                  _Block(title: 'State', value: patientProfileModel.state),
                  _Block(title: 'Country', value: patientProfileModel.country),
                  _Block(title: 'Married', value: patientProfileModel.married),
                  _Block(
                      title: 'No. of Family members',
                      value: patientProfileModel.noOfFamilyMembers),
                  _Block(
                      title: 'Your position in family',
                      value: patientProfileModel.yourPositionInFamily),
                  pw.SizedBox(height: 16),
                  _Category(title: 'Medical Profile'),
                  pw.Text(
                    "Medical History",
                    style: pw.TextStyle(
                      color: PdfColor.fromHex("778899"),
                      fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Padding(
                      padding: const pw.EdgeInsets.only(
                          left: 20, top: 5, bottom: 5, right: 20),
                      child: pw.Column(children: [
                        _Block(
                          title: "Diabetes",
                          value: jsonObj[
                              'DiabetesVal'] /*jsonObj['DiabetesYear'] != null
                              ? "Since ${jsonObj['DiabetesYear']} Years and ${jsonObj['DiabetesMonth']} Months"
                              : ""*/
                          ,
                        ),
                        _Block(
                          title: "Hypertension",
                          value: jsonObj[
                              'HypertensionVal'] /*jsonObj['HypertensionYear'] != null
                              ? "Since ${jsonObj['HypertensionYear']} Years and ${jsonObj['HypertensionMonth']} Months"
                              : ""*/
                          ,
                        ),
                        _Block(
                          title: "Heart Disease",
                          value: jsonObj[
                              'HeartDiseaseVal'] /*jsonObj['HeartDiseaseYear'] != null
                              ? "Since ${jsonObj['HeartDiseaseYear']} Years and ${jsonObj['HeartDiseaseMonth']} Months"
                              : ""*/
                          ,
                        ),
                        _Block(
                          title: "Thyroid",
                          value: jsonObj[
                              'ThyroidVal'] /*jsonObj['ThyroidYear'] != null
                              ? "Since ${jsonObj['ThyroidYear']} Years and ${jsonObj['ThyroidMonth']} Months"
                              : ""*/
                          ,
                        ),
                      ])),
                  _Block(
                    title: 'Surgical History',
                    value: jsonObj['SurgicalHistory'] != null
                        ? jsonObj['SurgicalHistory']
                        : "",
                  ),
                  _Block(
                    title: 'Drug Allergy',
                    value: jsonObj['DrugAllergy'] != null
                        ? jsonObj['DrugAllergy']
                        : "",
                  ),
                  _Block(
                    title: 'Blood Group',
                    value: jsonObj['BloodGroup'] != null
                        ? jsonObj['BloodGroup']
                        : "",
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
  return doc.save();
}

Future<pw.PageTheme> _myPageTheme(PdfPageFormat format) async {
  format = format.applyMargin(
      left: 2.0 * PdfPageFormat.cm,
      top: 2.0 * PdfPageFormat.cm,
      right: 2.0 * PdfPageFormat.cm,
      bottom: 2.0 * PdfPageFormat.cm);
  return pw.PageTheme(
    pageFormat: format,
    /*theme: pw.ThemeData.withFont(
      base: pw.Font.ttf(await rootBundle.load('assets/open-sans.ttf')),
      bold: pw.Font.ttf(await rootBundle.load('assets/open-sans-bold.ttf')),
    ),*/
    buildBackground: (pw.Context context) {
      return pw.FullPage(
        ignoreMargins: true,
        child: pw.CustomPaint(
          size: PdfPoint(format.width, format.height),
          painter: (PdfGraphics canvas, PdfPoint size) {
            context.canvas
              ..setColor(lightGreen)
              ..moveTo(0, size.y)
              ..lineTo(0, size.y - 230)
              ..lineTo(60, size.y)
              ..fillPath()
              ..setColor(green)
              ..moveTo(0, size.y)
              ..lineTo(0, size.y - 100)
              ..lineTo(100, size.y)
              ..fillPath()
              ..setColor(lightGreen)
              ..moveTo(30, size.y)
              ..lineTo(110, size.y - 50)
              ..lineTo(150, size.y)
              ..fillPath()
              ..moveTo(size.x, 0)
              ..lineTo(size.x, 230)
              ..lineTo(size.x - 60, 0)
              ..fillPath()
              ..setColor(green)
              ..moveTo(size.x, 0)
              ..lineTo(size.x, 100)
              ..lineTo(size.x - 100, 0)
              ..fillPath()
              ..setColor(lightGreen)
              ..moveTo(size.x - 30, 0)
              ..lineTo(size.x - 110, 50)
              ..lineTo(size.x - 150, 0)
              ..fillPath()
              ..setColor(green)
              ..setLineWidth(2)
              ..moveTo(
                  size.x - sep - format.marginRight + 4, format.marginBottom)
              /*..lineTo(size.x - sep - format.marginRight + 4,
                  size.y - format.marginTop)*/
              ..strokePath();
          },
        ),
      );
    },
  );
}

class _Block extends pw.StatelessWidget {
  _Block({this.title, this.value});

  final String? title, value;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Container(
                  width: 6,
                  height: 6,
                  margin: const pw.EdgeInsets.only(top: 3.5, left: 2, right: 5),
                  decoration: const pw.BoxDecoration(
                      color: green, shape: pw.BoxShape.circle),
                ),
                pw.Row(children: [
                  pw.Container(
                    width: SizeConfig.blockSizeHorizontal !* 30,
                    child: pw.Text(title!,
                        style: pw.Theme.of(context).defaultTextStyle.copyWith(
                              color: PdfColor.fromHex("#696969"),
                            )),
                  ),
                  pw.Text(value!,
                      style: pw.Theme.of(context).defaultTextStyle.copyWith(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromInt(0xFF000000),
                          )),
                ])
              ]),
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 10, top: 5, bottom: 5),
          )
          /*pw.Container(
            decoration: const pw.BoxDecoration(
                border: pw.BoxBorder(left: true, color: green, width: 2)),
            padding: const pw.EdgeInsets.only(left: 10, top: 5, bottom: 5),
            margin: const pw.EdgeInsets.only(left: 5),
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Lorem(length: 20),
                ]),
          ),*/
        ]);
  }
}

class _Category extends pw.StatelessWidget {
  _Category({this.title});

  final String? title;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
        width: double.infinity,
        decoration: const pw.BoxDecoration(
          color: lightGreen,
          /*borderRadiusEx: pw.BorderRadius.all(pw.Radius.circular(6))*/
        ),
        margin: const pw.EdgeInsets.only(bottom: 10, top: 20),
        padding: const pw.EdgeInsets.fromLTRB(10, 7, 10, 4),
        child: pw.Text(title!, textScaleFactor: 1.5));
  }
}

class _Percent extends pw.StatelessWidget {
  _Percent(this.value, this.title, this.fontSize, this.color, this.backgroundColor, this.strokeWidth, {
    @required this.size,
  }) : assert(size != null);

  final double? size;

  final double? value;

  final pw.Widget? title;

  final double fontSize;

  final PdfColor color;

  final PdfColor backgroundColor;

  final double strokeWidth;

  @override
  pw.Widget build(pw.Context context) {
    final widgets = <pw.Widget>[
      pw.Container(
        width: size,
        height: size,
        child: pw.Stack(
          alignment: pw.Alignment.center,
          fit: pw.StackFit.expand,
          children: <pw.Widget>[
            pw.Center(
              child: pw.Text(
                '${(value! * 100).round().toInt()}%',
                textScaleFactor: fontSize,
              ),
            ),
            pw.CircularProgressIndicator(
              value: value!,
              backgroundColor: backgroundColor,
              color: color,
              strokeWidth: strokeWidth,
            ),
          ],
        ),
      )
    ];

    if (title != null) {
      widgets.add(title!);
    }

    return pw.Column(children: widgets);
  }
}

class _UrlText extends pw.StatelessWidget {
  _UrlText(this.text, this.url);

  final String text;
  final String url;

  @override
  pw.Widget build(pw.Context context) {
    return pw.UrlLink(
      destination: url,
      child: pw.Text(text,
          style: const pw.TextStyle(
            decoration: pw.TextDecoration.underline,
            color: PdfColors.blue,
          )),
    );
  }
}
