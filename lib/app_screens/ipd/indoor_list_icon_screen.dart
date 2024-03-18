import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:swasthyasetu/app_screens/corona_questionnaire.dart';
import 'package:swasthyasetu/app_screens/ipd/billing_screen.dart';
import 'package:swasthyasetu/app_screens/ipd/input_chart_screen.dart';
import 'package:swasthyasetu/app_screens/ipd/output_chart_screen.dart';
import 'package:swasthyasetu/app_screens/ipd/pmr_screen.dart';
import 'package:swasthyasetu/app_screens/ipd/treatment_sheet_screen.dart';
import 'package:swasthyasetu/app_screens/ipd/vital_chart_add_screen.dart';
import 'package:swasthyasetu/app_screens/ipd/vital_chart_table.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_login_icons_model.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/color.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';

class IndoorListIconScreen extends StatefulWidget {


  final String patientindooridp;
  final String PatientIDP;
  final String doctoridp;
  final String firstname;
  final String lastName;

  IndoorListIconScreen({
    required this.patientindooridp,
    required this.PatientIDP,
    required this.doctoridp,
    required this.firstname,
    required this.lastName,
  });


  @override
  State<IndoorListIconScreen> createState() => _IndoorListIconScreenState();
}

class _IndoorListIconScreenState extends State<IndoorListIconScreen> {

  List<Map<String, dynamic>> listOrganizations = <Map<String, dynamic>>[];
  List<String> listIconName = [];
  List<String> listImage = [];

  @override
  void initState() {

    listIconName.add("Vital\nChart");
    listIconName.add("Input\nChart");
    listIconName.add("Output\nChart");
    listIconName.add("PMR");
    listIconName.add("Billing");
    listIconName.add("Treatment\nSheet");

    listImage.add("v-2-icn-add-patient.png");
    listImage.add("v-2-icn-my-patient.png");
    listImage.add("v-2-icn-my-appointment.png");
    listImage.add("v-2-icn-sent-notification.png");
    listImage.add("v-2-icn-my-library.png");
    listImage.add("v-2-icn-market-place.png");

    // getOrganizations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( "${widget.firstname} ${widget.lastName}" ),
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(
            color: Colorsblack, size: SizeConfig.blockSizeVertical !* 2.2), toolbarTextStyle: TextTheme(
          titleMedium: TextStyle(
              color: Colorsblack,
              fontFamily: "Ubuntu",
              fontSize: SizeConfig.blockSizeVertical !* 2.5)).bodyMedium, titleTextStyle: TextTheme(
          titleMedium: TextStyle(
              color: Colorsblack,
              fontFamily: "Ubuntu",
              fontSize: SizeConfig.blockSizeVertical !* 2.5)).titleLarge,
      ),
      body: Builder(builder: (context) {
        return Column(
          children: [
            SizedBox(
              height: SizeConfig.blockSizeVertical! * 4.0,
            ),
            Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal! * 3.0,
                  vertical: SizeConfig.blockSizeHorizontal! * 3.0,
                ),
                decoration: BoxDecoration(
                  color: Color(0xfff0f1f5),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(
                      20,
                    ),
                    topLeft: Radius.circular(
                      20,
                    ),
                  ),
                ),
                child: Center(
                  child: GridView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: listIconName.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 1.3, crossAxisCount: 3),
                      itemBuilder: (context, index) {
                        return IconCard(
                          IconModel(listIconName[index],
                              listImage[index], "",),
                          patientindooridp: widget.patientindooridp,
                          PatientIDP: widget.PatientIDP,
                          doctoridp: widget.doctoridp,
                          firstname: widget.firstname,
                          lastName: widget.lastName,
                        );
                        //: Container(),
                        /*);*/
                      }),
                )),
            SizedBox(
              height: SizeConfig.blockSizeVertical! * 1,
            ),
          ],
        );
      },
      ),
    );
  }

  String encodeBase64(String text) {
    var bytes = utf8.encode(text);
    return base64.encode(bytes);
  }

  String decodeBase64(String text) {
    var bytes = base64.decode(text);
    return String.fromCharCodes(bytes);
  }

}

class IconCard extends StatefulWidget {
  IconModel? model;
  final String patientindooridp;
  final String PatientIDP;
  final String doctoridp;
  final String firstname;
  final String lastName;
  // Function? getDashBoardData;

  IconCard(IconModel model,
      {required this.patientindooridp,
        required this.PatientIDP,
        required this.doctoridp,
        required this.firstname,
        required this.lastName,}
      )
  { this.model = model; }

  @override
  State<IconCard> createState() => _IconCardState();
}

class _IconCardState extends State<IconCard> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return InkWell(
        highlightColor: Colors.green[200],
        customBorder: CircleBorder(),
        onTap: () async {
          if (widget.model!.iconName == "Vital\nChart") {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return VitalChartTableScreen(
                patientindooridp: widget.patientindooridp,
                PatientIDP: widget.PatientIDP,
                doctoridp: widget.doctoridp,
                firstname: widget.firstname,
                lastName: widget.lastName,
              );
            }));
          }
          else if (widget.model!.iconName == "Input\nChart") {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return InputChartScreen();
            }));
          }
          else if (widget.model!.iconName == "Output\nChart") {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return OutputChartScreen();
            }));
          }
          else if (widget.model!.iconName == "PMR") {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return PMRScreen(
                patientindooridp: widget.patientindooridp,
                PatientIDP: widget.PatientIDP,
                doctoridp: widget.doctoridp,
                firstname: widget.firstname,
                lastName: widget.lastName,
              );
            }));
          }
          else if (widget.model!.iconName == "Billing") {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return  BillingScreen(
                patientindooridp: widget.patientindooridp,
                PatientIDP: widget.PatientIDP,
                doctoridp: widget.doctoridp,
                firstname: widget.firstname,
                lastName: widget.lastName,
              );
            }));
          }
          else if (widget.model!.iconName == "Treatment\nSheet") {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return TreatmentSheetScreen();
            }));
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal! * 0.0),
          child: Container(
            child: Card(
              color: colorWhite,
              elevation: 2.0,
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
                    Image(
                      width: SizeConfig.blockSizeHorizontal! * 7,
                      height: SizeConfig.blockSizeHorizontal! * 7,
                      image: AssetImage(
                        'images/${widget.model!.image}',
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 2,
                    ),
                    Flexible(
                      child: Text(widget.model!.iconName!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: SizeConfig.blockSizeHorizontal! * 2.8,
                          )),
                    ),
                  ]),
            ),
          ),
        ));
  }
}

