import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silvertouch/global/SizeConfig.dart';

import '../controllers/add_camp_controller.dart';
import '../utils/color.dart';
import '../utils/string_resource.dart';

class MarketPlaceScreen extends StatelessWidget {
  final idp;
  final patientIDP;

  MarketPlaceScreen({Key? key, this.idp, this.patientIDP}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    var controller = Get.put(AddCampController(), permanent: false);
    return Scaffold(
        appBar: AppBar(
          title: Text(str_add_camp),
          backgroundColor: Color(0xFFFFFFFF),
          iconTheme: IconThemeData(
              color: Colorsblack, size: SizeConfig.blockSizeVertical! * 2.2),
          toolbarTextStyle: TextTheme(
                  titleMedium: TextStyle(
                      color: Colorsblack,
                      fontFamily: FONT_NAME,
                      fontSize: SizeConfig.blockSizeVertical! * 2.5))
              .bodyMedium,
          titleTextStyle: TextTheme(
                  titleMedium: TextStyle(
                      color: Colorsblack,
                      fontFamily: FONT_NAME,
                      fontSize: SizeConfig.blockSizeVertical! * 2.5))
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
                        width: SizeConfig.blockSizeHorizontal! * 85,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 1),
                        child: TextField(
                          controller: controller.campNameController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical! * 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelText: str_camp_name,
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal! * 85,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 1),
                        child: TextField(
                          controller: controller.campDetailController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical! * 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelText: str_camp_details,
                            hintText: "",
                          ),
                          maxLines: 5,
                          minLines: 3,
                          maxLength: 500,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                        onPressed: () {
                          controller.showDateSelectionDialog(
                              context,
                              controller.campDateController!.text,
                              str_effect_fromDate);
                        },
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal! * 90,
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal! * 1),
                          child: IgnorePointer(
                            child: TextField(
                              controller: controller.campDateController,
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize:
                                      SizeConfig.blockSizeVertical! * 2.3),
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.calendar_today),
                                  onPressed: () => null,
                                ),
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical! * 2.3),
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical! * 2.3),
                                labelText: str_camp_date,
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
                          controller.showTimeSelectionDialog(
                              context, controller.campTimeController!.text);
                        },
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal! * 90,
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal! * 1),
                          child: IgnorePointer(
                            child: TextField(
                              controller: controller.campTimeController,
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize:
                                      SizeConfig.blockSizeVertical! * 2.3),
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.access_time),
                                  onPressed: () => null,
                                ),
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical! * 2.3),
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical! * 2.3),
                                labelText: str_camp_time,
                                hintText: "",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: EdgeInsets.all(
                            SizeConfig.blockSizeHorizontal! * 2.5),
                        decoration: BoxDecoration(
                          color: Color(0xFF06A759),
                          shape: BoxShape.circle,
                        ),
                        child: InkWell(
                          onTap: () {
                            controller.webcallSubmitAddCamp(context);
                          },
                          child: Image(
                            width: SizeConfig.blockSizeHorizontal! * 5.5,
                            height: SizeConfig.blockSizeHorizontal! * 5.5,
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
