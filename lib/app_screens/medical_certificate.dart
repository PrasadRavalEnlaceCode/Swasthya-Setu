import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/medical_certificate_controller.dart';
import '../global/SizeConfig.dart';
import '../podo/model_certificate.dart';
import '../utils/color.dart';
import '../utils/string_resource.dart';

class MedicalCertificate extends StatelessWidget {
  String? isfromVerify;

  final ModelCertificate? cert;
  final String? idp;
  final String? patientIDP;

  MedicalCertificate({Key? key, this.cert, this.idp, this.patientIDP})
      : super(key: key);

  // MedicalCertificate(
  //    {Key key, this.cert, this.idp, this.patientIDP})
  //    : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    var controller = Get.put(MedicalCertificateController(), permanent: false);
    return Scaffold(
        appBar: AppBar(
          title: Text(str_medical_certificate),
          backgroundColor: Color(0xFFFFFFFF),
          iconTheme: IconThemeData(
              color: Colorsblack, size: SizeConfig.blockSizeVertical !* 2.2),
          toolbarTextStyle: TextTheme(
                  titleMedium: TextStyle(
                      color: Colorsblack,
                      fontFamily: FONT_NAME,
                      fontSize: SizeConfig.blockSizeVertical !* 2.5))
              .bodyMedium,
          titleTextStyle: TextTheme(
                  titleMedium: TextStyle(
                      color: Colorsblack,
                      fontFamily: FONT_NAME,
                      fontSize: SizeConfig.blockSizeVertical !* 2.5))
              .titleLarge,
        ),
        body: Container(
            child: Form(
          key: controller.key,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal !* 85,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 1),
                        child: TextField(
                          controller: controller.sufferingFromController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical !* 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelText: str_suffering_from,
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal !* 85,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 1),
                        child: TextField(
                          controller: controller.absenceDaysController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical !* 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelText: str_absence_days,
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                        onPressed: () {
                          controller.showDateSelectionDialog(
                              context,
                              controller.effectFromDateController!.text,
                              str_effect_fromDate);
                        },
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal !* 90,
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal !* 1),
                          child: IgnorePointer(
                            child: TextField(
                              controller: controller.effectFromDateController,
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: SizeConfig.blockSizeVertical !* 2.3),
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.calendar_today),
                                  onPressed: () => null,
                                ),
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                                labelText: str_effect_fromDate,
                                hintText: "",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                        onPressed: () {
                          controller.showDateSelectionDialog(
                              context,
                              controller.treatedFromDateController!.text,
                              str_treated_fromDate);
                        },
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal !* 90,
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal !* 1),
                          child: IgnorePointer(
                            child: TextField(
                              controller: controller.treatedFromDateController,
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: SizeConfig.blockSizeVertical !* 2.3),
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.calendar_today), onPressed: () {  },
                                ),
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                                labelText: str_treated_fromDate,
                                hintText: "",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                        onPressed: () {
                          controller.showDateSelectionDialog(
                              context,
                              controller.treatedToDateController!.text,
                              str_treated_toDate);
                        },
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal !* 90,
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal !* 1),
                          child: IgnorePointer(
                            child: TextField(
                              controller: controller.treatedToDateController,
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: SizeConfig.blockSizeVertical !* 2.3),
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.calendar_today), onPressed: () {  },
                                ),
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                                labelText: str_treated_toDate,
                                hintText: "",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                        onPressed: () {
                          controller.showDateSelectionDialog(
                              context,
                              controller.joinDutyDateController!.text,
                              str_join_dutyDate);
                        },
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal !* 90,
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal !* 1),
                          child: IgnorePointer(
                            child: TextField(
                              controller: controller.joinDutyDateController,
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: SizeConfig.blockSizeVertical !* 2.3),
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.calendar_today), onPressed: () {  },
                                ),
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                                labelText: str_join_dutyDate,
                                hintText: "",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal !* 85,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 1),
                        child: TextField(
                          controller: controller.identificationController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical !* 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelText: str_identification_mark1,
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal !* 85,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 1),
                        child: TextField(
                          controller: controller.remarksController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical !* 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelText: str_remarks,
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: EdgeInsets.all(
                            SizeConfig.blockSizeHorizontal !* 2.5),
                        decoration: BoxDecoration(
                          color: Color(0xFF06A759),
                          shape: BoxShape.circle,
                        ),
                        child: InkWell(
                          onTap: () {
                            controller.webcallSubmitMedicalCertificate(idp,
                                patientIDP, cert!.certificateTypeIDP, context);
                          },
                          child: Image(
                            width: SizeConfig.blockSizeHorizontal !* 5.5,
                            height: SizeConfig.blockSizeHorizontal !* 5.5,
                            //height: 80,
                            image: AssetImage(
                                "images/ic_right_arrow_triangular.png"),
                          ),
                          customBorder: CircleBorder(),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ]),
            ),
          ),
        )));
  }
}
