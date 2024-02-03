import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:swasthyasetu/app_screens/report_patient_screen.dart';

import '../global/SizeConfig.dart';
import '../global/utils.dart';
import '../podo/model_icon.dart';
import '../utils/color.dart';
import 'corona_questionnaire.dart';

class AllConsultation extends StatefulWidget {

  const AllConsultation({Key? key}) : super(key: key);

  @override
  State<AllConsultation> createState() => _AllConsultationState();
}

class _AllConsultationState extends State<AllConsultation> {
  List<ModelIcon> listIcons = [];

  @override
  void initState() {
    super.initState();
    listIcons.add(ModelIcon(iconType: "image", iconName: "Clinical\nNotes", iconImg: "v-2-icn-briefcase.png", iconColor: Color(0xFF615E3F), iconBgColor: Color(0xFFF2EEBF), iconData: null));
    listIcons.add(ModelIcon(iconType: "image", iconName: "Prescription", iconImg: "v-2-icn-order-medicine.png", iconColor: Color(0xFFFF6347), iconBgColor: Colors.orange, iconData: null));
    listIcons.add(ModelIcon(iconType: "image", iconName: "Certificate", iconImg: "v-2-icn-blood-test.png", iconColor: Colors.pink, iconBgColor: Colors.red, iconData: null));
    listIcons.add(ModelIcon(iconType: "image", iconName: "Reports", iconImg: "v-2-icn-blood-pressure.png", iconColor: Colors.red, iconBgColor: Colors.red, iconData: null));
    listIcons.add(ModelIcon(iconType: "image", iconName: "Receipts", iconImg: "v-2-icn-blood-sugar.png", iconColor: Colors.lightBlue, iconBgColor: Colors.lightBlue, iconData: null));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Consultation",style: TextStyle(
          color: Colorsblack,
          fontFamily: "Ubuntu",
        ),),
        backgroundColor: colorWhite,
        elevation: 0,
        iconTheme: IconThemeData(color: Colorsblack),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
            Container(
            decoration: new BoxDecoration(
            color: Color(0xfff0f1f5)),
            ),
          SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: SizeConfig.blockSizeVertical !* 1.0,
              ),
              GridView.builder
              (
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: listIcons.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(childAspectRatio: 1.0, crossAxisCount: 2),
                  itemBuilder: (context, index)
                  {
                    return IconCard(listIcons[index])/*IconModel(listIconName[index], listImage[index], "")*/;
                    /*);*/
                  }
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

// ignore: must_be_immutable
class IconCard extends StatelessWidget {
  ModelIcon? model;

  IconCard(ModelIcon? model) {
    this.model = model;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return InkWell(
      highlightColor: Colors.green[200],
      customBorder: CircleBorder(),
      onTap: () async {
        String patientIDP = await getPatientOrDoctorIDP();
        if (model!.iconName == "Clinical\nNotes") {
          Get.to(() => PatientReportScreen(patientIDP, "1",false));
        }
        else if(model!.iconName == "Reports")
        {
          // "13" means all id other than all prescription and certificates
          Get.to(() => PatientReportScreen(patientIDP, "Reports",false));
        }
        else if(model!.iconName == "Certificate")
        {
          Get.to(() => PatientReportScreen(patientIDP, "12",false));
        }
        else if(model!.iconName == "Prescription")
        {
          Get.to(() => PatientReportScreen(patientIDP, "1",false));
        }
        else if(model!.iconName == "Receipts")
        {
          Get.to(() => PatientReportScreen(patientIDP, "13",false));
        }
        else
        {

        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal !* 0.0),
        child: Card(
          color: colorWhite,
          elevation: 2.0,
          //shadowColor: model.iconColor,
          margin: EdgeInsets.all(
            SizeConfig.blockSizeHorizontal !* 2.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              SizeConfig.blockSizeHorizontal !* 2.0,
            ),
          ),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: SizeConfig.blockSizeHorizontal !* 15,
                  height: SizeConfig.blockSizeHorizontal !* 15,
                  child: Padding(
                    padding: EdgeInsets.all(
                      SizeConfig.blockSizeHorizontal !* 3.0,
                    ),
                    child: model!.iconType == "image"
                        ? Image(
                      width: SizeConfig.blockSizeHorizontal !* 5,
                      height: SizeConfig.blockSizeHorizontal !* 5,
                      image: AssetImage(
                        'images/${model!.iconImg}',
                      ),
                      color: colorBlueDark,
                    )
                        : model!.iconType == "faIcon"
                        ? FaIcon(
                      model!.iconData,
                      size: SizeConfig.blockSizeHorizontal !* 5,
                      color: Color(0xFF06A759),
                    )
                        : Container(
                      width: SizeConfig.blockSizeHorizontal !* 5,
                      height: SizeConfig.blockSizeHorizontal !* 5,
                    ),
                  ),
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical !* 0,
                ),
                Flexible(
                  child: Text(model!.iconName ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: SizeConfig.blockSizeHorizontal !* 3.2,
                        letterSpacing: 1.2,
                      )),
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical !* 2,
                ),
              ]),
        ),
      ),
    ) /*)*/;
  }

  void showLanguageSelectionDialog(BuildContext context, String patientIDP) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          /*shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),*/
          backgroundColor: Colors.white,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(
                  SizeConfig.blockSizeHorizontal !* 3,
                ),
                child: Row(
                  children: <Widget>[
                    InkWell(
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.red,
                        size: SizeConfig.blockSizeHorizontal !* 6.2,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal !* 6,
                    ),
                    Text(
                      "Choose Language",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal !* 4.8,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.to(
                            () => CoronaQuestionnaireScreen(patientIDP, "eng"));
                  },
                  child: Container(
                      width: SizeConfig.blockSizeHorizontal !* 90,
                      padding: EdgeInsets.only(
                        top: 5,
                        bottom: 5,
                        left: 5,
                        right: 5,
                      ),
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        border: Border(
                          bottom:
                          BorderSide(width: 2.0, color: Colors.grey),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10.0,
                            offset: const Offset(0.0, 10.0),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "English",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ))),
              InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.to(
                            () => CoronaQuestionnaireScreen(patientIDP, "guj"));
                  },
                  child: Container(
                      width: SizeConfig.blockSizeHorizontal !* 90,
                      padding: EdgeInsets.only(
                        top: 5,
                        bottom: 5,
                        left: 5,
                        right: 5,
                      ),
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        border: Border(
                          bottom:
                          BorderSide(width: 2.0, color: Colors.grey),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10.0,
                            offset: const Offset(0.0, 10.0),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Gujarati",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ))),
            ],
          ),
        ));
  }
}
