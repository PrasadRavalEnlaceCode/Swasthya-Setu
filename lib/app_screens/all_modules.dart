import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:silvertouch/app_screens/VitalsCombineListScreen.dart';
import 'package:silvertouch/app_screens/all_consultation.dart';
import 'package:silvertouch/app_screens/calary_counter_screen.dart';
import 'package:silvertouch/app_screens/documents_list_screen.dart';
import 'package:silvertouch/app_screens/exercise_list_screen.dart';
import 'package:silvertouch/app_screens/feelings_list_screen.dart';
import 'package:silvertouch/app_screens/health_tips_screen.dart';
import 'package:silvertouch/app_screens/investigations_list_with_graph.dart';
import 'package:silvertouch/app_screens/music_list_screen.dart';
import 'package:silvertouch/app_screens/order_blood_screen.dart';
import 'package:silvertouch/app_screens/order_medicine_screen.dart';
import 'package:silvertouch/app_screens/reminders_list_screen.dart';
import 'package:silvertouch/app_screens/report_patient_screen.dart';
import 'package:silvertouch/app_screens/vitals_list.dart';
// import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';

import '../enums/list_type.dart';
import '../global/SizeConfig.dart';
import '../global/utils.dart';
import '../podo/model_icon.dart';
import '../utils/color.dart';
import 'coming_soon_screen.dart';
import 'corona_questionnaire.dart';

class AllModules extends StatefulWidget {
  const AllModules({Key? key}) : super(key: key);

  @override
  State<AllModules> createState() => _AllModulesState();
}

class _AllModulesState extends State<AllModules> {
  List<ModelIcon> listIcons = [];

  @override
  void initState() {
    super.initState();
    listIcons.add(ModelIcon(
        iconType: "image",
        iconName: "Consultation",
        iconImg: "v-2-icn-briefcase.png",
        iconColor: Color(0xFF615E3F),
        iconBgColor: Color(0xFFF2EEBF),
        iconData: null));
    listIcons.add(ModelIcon(
        iconType: "image",
        iconName: "Order\nMedicine",
        iconImg: "v-2-icn-order-medicine.png",
        iconColor: Color(0xFFFF6347),
        iconBgColor: Colors.orange,
        iconData: null));
    listIcons.add(ModelIcon(
        iconType: "image",
        iconName: "Order\nBlood Test",
        iconImg: "v-2-icn-blood-test.png",
        iconColor: Colors.pink,
        iconBgColor: Colors.red,
        iconData: null));
    listIcons.add(ModelIcon(
        iconType: "image",
        iconName: "Blood\nPressure",
        iconImg: "v-2-icn-blood-pressure.png",
        iconColor: Colors.red,
        iconBgColor: Colors.red,
        iconData: null));
    listIcons.add(ModelIcon(
        iconType: "image",
        iconName: "Blood\nSugar",
        iconImg: "v-2-icn-blood-sugar.png",
        iconColor: Colors.lightBlue,
        iconBgColor: Colors.lightBlue,
        iconData: null));
    listIcons.add(ModelIcon(
        iconType: "image",
        iconName: "Vitals",
        iconImg: "v-2-icn-pulse.png",
        iconData: null));

    listIcons.add(ModelIcon(
        iconType: "image",
        iconName: "Thyroid",
        iconImg: "ic_thyroid_dashboard.png",
        iconColor: Color(0xFF7F00FF),
        iconBgColor: Color(0xFFB1C3F8),
        iconData: null));
    listIcons.add(ModelIcon(
        iconType: "image",
        iconName: "Investigation",
        iconImg: "ic_investigation_dashbaord.png",
        iconColor: Colors.teal,
        iconBgColor: Colors.teal,
        iconData: null));
    // listIcons.add(ModelIcon(
    //     iconType: "image",
    //     iconName: "Prescription",
    //     iconImg: "ic_prescription_dashboard.png",
    //     iconColor: Color(0xFFFF6347),
    //     iconBgColor: Colors.orange[100],
    //     iconData: null));
    listIcons.add(ModelIcon(
        iconType: "image",
        iconName: "Reminders",
        iconImg: "ic_reminder.png",
        iconColor: Color(0xFF5AB577),
        iconBgColor: Color(0xFFCFE9D8),
        iconData: null));
    listIcons.add(ModelIcon(
        iconType: "image",
        iconName: "Weight \n Measurement",
        iconImg: "ic_weight_dashboard.png",
        iconColor: Colors.pink,
        iconBgColor: Colors.red,
        iconData: null));
    listIcons.add(ModelIcon(
        iconType: "image",
        iconName: "Calorie \n Counter",
        iconImg: "ic_calories_dashboard.png",
        iconColor: Color(0xFF4A766E),
        iconBgColor: Color(0xFFB1F2EC),
        iconData: null));
    listIcons.add(ModelIcon(
        iconType: "image",
        iconName: "Health Meter",
        iconImg: "ic_performance_dashboard.png",
        iconColor: Colors.lightGreen,
        iconBgColor: Colors.lightGreen,
        iconData: null));
    listIcons.add(ModelIcon(
        iconType: "image",
        iconName: "Meditation",
        iconImg: "ic_music_dashboard.png",
        iconColor: Color(0xFFDAA520),
        iconBgColor: Color(0xFFFAFAD2),
        iconData: null));
    listIcons.add(ModelIcon(
        iconType: "image",
        iconName: "Water Intake",
        iconImg: "ic_water_dashboard.png",
        iconColor: Colors.blueAccent,
        iconBgColor: Colors.blue,
        iconData: null));
    listIcons.add(ModelIcon(
        iconType: "image",
        iconName: "Sleep",
        iconImg: "ic_sleep_dashboard.png",
        iconColor: Color(0xFF457371),
        iconBgColor: Color(0xFFB5DBD8),
        iconData: null));
    listIcons.add(ModelIcon(
        iconType: "image",
        iconName: "Feelings",
        iconImg: "ic_feelings_dashboard.png",
        iconColor: Color(0xFF996515),
        iconBgColor: Colors.brown,
        iconData: null));
    listIcons.add(ModelIcon(
        iconType: "image",
        iconName: "Documents",
        iconImg: "ic_report_dashbaord.png",
        iconColor: Colors.redAccent,
        iconBgColor: Colors.red,
        iconData: null));
    listIcons.add(ModelIcon(
        iconType: "image",
        iconName: "Food",
        iconImg: "ic_food_dashboard.png",
        iconColor: Color(0xFF3B3178),
        iconBgColor: Color(0xFFC1BBEA),
        iconData: null));
    listIcons.add(ModelIcon(
        iconType: "image",
        iconName: "Links to \n follow",
        iconImg: "ic_links_dashboard.png",
        iconColor: Color(0xFF3F6826),
        iconBgColor: Color(0xFFD1DBCB),
        iconData: null));
    listIcons.add(ModelIcon(
        iconType: "image",
        iconName: "Health Tips",
        iconImg: "ic_health_tips_dashboard.png",
        iconColor: Color(0xFF20B2AA),
        iconBgColor: Color(0xFFADFEFC),
        iconData: null));
    listIcons.add(ModelIcon(
        iconType: "image",
        iconName: "Health\nBriefcase",
        iconImg: "v-2-icn-briefcase.png",
        iconColor: Color(0xFF615E3F),
        iconBgColor: Color(0xFFF2EEBF),
        iconData: null));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "All Modules",
          style: TextStyle(
            color: Colorsblack,
            fontFamily: "Ubuntu",
          ),
        ),
        backgroundColor: colorWhite,
        elevation: 0,
        iconTheme: IconThemeData(color: Colorsblack),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal! * 3.0,
              vertical: SizeConfig.blockSizeHorizontal! * 1.0,
            ),
            color: Color(0xfff0f1f5),
            child: Column(
              children: [
                SizedBox(
                  height: SizeConfig.blockSizeVertical! * 1.0,
                ),
                Center(
                  child: GridView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: listIcons.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 1.0, crossAxisCount: 3),
                      itemBuilder: (context, index) {
                        return IconCard(listIcons[
                            index]) /*IconModel(listIconName[index], listImage[index], "")*/;
                        /*);*/
                      }),
                ),
              ],
            )),
      ),
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
        if (model!.iconName == "Consultation") {
          Get.to(() => AllConsultation());
        } else if (model!.iconName == "Health\nBriefcase") {
          Get.to(() => DocumentsListScreen(patientIDP));
        } else if (model!.iconName == "Order\nMedicine") {
          Get.to(() => OrderMedicineListScreen(patientIDP));
        } else if (model!.iconName == "Order\nBlood Test") {
          Get.to(() => OrderBloodListScreen(patientIDP));
        } else if (model!.iconName == "Blood\nPressure") {
          Get.to(() => VitalsCombineListScreen(patientIDP, "1"));
        } else if (model!.iconName == "Blood\nSugar") {
          Get.to(() => InvestigationsListWithGraph(
                patientIDP,
                from: "sugar",
              ));
        } else if (model!.iconName == "Vitals") {
          Get.to(() => VitalsListScreen(patientIDP, "2"));
        } else if (model!.iconName == "Weight \n Measurement") {
          Get.to(() => VitalsListScreen(patientIDP, "4"));
        } else if (model!.iconName == "Eye Examination") {
          Get.to(() => ComingSoonScreen());
        } else if (model!.iconName == "Meditation") {
          Get.to(() => MusicListScreen(patientIDP));
        } else if (model!.iconName == "Health Questions") {
          showLanguageSelectionDialog(context, patientIDP);
        } else if (model!.iconName == "Investigation") {
          Get.to(() => InvestigationsListWithGraph(
                patientIDP,
              ));
        } else if (model!.iconName == "Appointment") {
          Get.to(() => ComingSoonScreen());
        } else if (model!.iconName == "Documents") {
          Get.to(() => PatientReportScreen(patientIDP, "dashboard", false));
        } else if (model!.iconName == "Prescription") {
          Get.to(() =>
              PatientReportScreen(patientIDP, "prescription_fixed", false));
        } else if (model!.iconName == "Calorie \n Counter") {
          Get.to(() => CalaryCounterScreen(patientIDP));
        } else if (model!.iconName == "Reminders") {
          Get.to(() => RemindersListScreen());
        } else if (model!.iconName == "Health Meter") {
          Get.to(() => VitalsListScreen(patientIDP, "5"));
        } else if (model!.iconName == "Health Exercise") {
          Get.to(() => ExerciseListScreen());
        } else if (model!.iconName == "Thyroid") {
          Get.to(() => InvestigationsListWithGraph(
                patientIDP,
                from: "thyroid",
              ));
          //Get.to(() => VitalsListScreen(patientIDP, "6"));
        } else if (model!.iconName == "Water Intake") {
          Get.to(() => VitalsListScreen(patientIDP, "7"));
        } else if (model!.iconName == "Sleep") {
          Get.to(() => VitalsListScreen(patientIDP, "8"));
        } else if (model!.iconName == "Feelings") {
          Get.to(() => FeelingsListScreen(patientIDP));
        } else if (model!.iconName == "Health Tips") {
          Get.to(() => TypicalListsScreen(patientIDP, ListTypes.HealthTips));
        } else if (model!.iconName == "Food") {
          Get.to(() => TypicalListsScreen(patientIDP, ListTypes.Recipes));
        } else if (model!.iconName == "Links to \n follow") {
          Get.to(
              () => TypicalListsScreen(patientIDP, ListTypes.ImportantLinks));
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal! * 0.0),
        child: Card(
          color: colorWhite,
          elevation: 2.0,
          //shadowColor: model.iconColor,
          margin: EdgeInsets.all(
            SizeConfig.blockSizeHorizontal! * 2.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              SizeConfig.blockSizeHorizontal! * 2.0,
            ),
          ),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: SizeConfig.blockSizeHorizontal! * 15,
                  height: SizeConfig.blockSizeHorizontal! * 15,
                  child: Padding(
                    padding: EdgeInsets.all(
                      SizeConfig.blockSizeHorizontal! * 3.0,
                    ),
                    child: model!.iconType == "image"
                        ? Image(
                            width: SizeConfig.blockSizeHorizontal! * 5,
                            height: SizeConfig.blockSizeHorizontal! * 5,
                            image: AssetImage(
                              'images/${model!.iconImg}',
                            ),
                            color: colorBlueDark,
                          )
                        : model!.iconType == "faIcon"
                            ? FaIcon(
                                model!.iconData,
                                size: SizeConfig.blockSizeHorizontal! * 5,
                                color: Color(0xFF06A759),
                              )
                            : Container(
                                width: SizeConfig.blockSizeHorizontal! * 5,
                                height: SizeConfig.blockSizeHorizontal! * 5,
                              ),
                  ),
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical! * 0,
                ),
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(model!.iconName ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: SizeConfig.blockSizeHorizontal! * 3.2,
                        letterSpacing: 1.2,
                      )),
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
                      SizeConfig.blockSizeHorizontal! * 3,
                    ),
                    child: Row(
                      children: <Widget>[
                        InkWell(
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.red,
                            size: SizeConfig.blockSizeHorizontal! * 6.2,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal! * 6,
                        ),
                        Text(
                          "Choose Language",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: SizeConfig.blockSizeHorizontal! * 4.8,
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
                          width: SizeConfig.blockSizeHorizontal! * 90,
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
                          width: SizeConfig.blockSizeHorizontal! * 90,
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
