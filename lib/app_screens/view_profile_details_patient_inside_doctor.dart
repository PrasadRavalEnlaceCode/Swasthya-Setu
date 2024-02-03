import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:swasthyasetu/app_screens/edit_my_profile_medical_patient.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/model_profile_patient.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/color.dart';
import 'edit_my_profile_patient.dart';

class ViewProfileDetailsInsideDoctor extends StatefulWidget {
  String? patientIDP, from = "";

  ViewProfileDetailsInsideDoctor(this.patientIDP, {this.from});

  @override
  State<StatefulWidget> createState() {
    return ViewProfileDetailsInsideDoctorState();
  }
}

class ViewProfileDetailsInsideDoctorState
    extends State<ViewProfileDetailsInsideDoctor> {
  String userName = "",
      mobNo = "",
      emailId = "",
      imgUrl = "",
      dob = "",
      age = "-",
      address = "",
      city = "",
      state = "",
      country = "",
      married = "",
      noOfFamilyMembers = "",
      yourPositionInFamily = "";
  String firstName = "",
      lastName = "",
      countryIDF = "",
      stateIDF = "",
      cityIDF = "",
      patientID = "";
  String middleName = "",
      weight = "",
      height = "",
      bloodGroup = "",
      emergencyNumber = "";
  String gender = "";
  bool dataShown = false;
  static File? image;
  static Stream<String>? stream;
  final String urlFetchPatientProfileDetails =
      "${baseURL}patientProfileData.php";

  String heightInFeet = "0 Foot 0 Inches";
  String selectedCategoryIDP = "0";
  String selectedCategory = "";
  List<Map<String, String>> listCategories = [];
  dynamic jsonObj;

  @override
  void initState() {
    super.initState();
    listCategories = [];
    jsonObj = {};
    listCategories.add({"categoryName": "Medical", "categoryIDP": "0"});
    listCategories.add({"categoryName": "General", "categoryIDP": "1"});
    getPatientProfileDetails();
  }

  @override
  Widget build(BuildContext context) {
    //if (!dataShown) getUserDetailsFromMemory();
    SizeConfig().init(context);
    return Builder(
      builder: (context) {
        return SafeArea(
            child: Scaffold(
                appBar: AppBar(
                  title: Text("Patient Profile"),
                  actions: <Widget>[
                    Visibility(
                      visible: widget.from != "notification",
                      child: IconButton(
                        icon: Icon(
                          Icons.call,
                          size: 25.0,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          showConfirmationDialogForSaveContact(context);
                          /*saveContactInPhone(context);*/
                        },
                      ),
                    ),
                    Visibility(
                      visible: widget.from != "notification",
                      child: IconButton(
                        icon: Icon(
                          Icons.edit,
                          size: 25.0,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          if (selectedCategoryIDP == "0") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditMyProfilePatient(
                                          PatientProfileModel(
                                              firstName,
                                              lastName,
                                              mobNo,
                                              emailId,
                                              imgUrl,
                                              dob,
                                              age,
                                              address,
                                              city,
                                              state,
                                              country,
                                              married,
                                              noOfFamilyMembers,
                                              yourPositionInFamily,
                                              countryIDF,
                                              stateIDF,
                                              cityIDF,
                                              middleName,
                                              weight,
                                              height,
                                              bloodGroup,
                                              emergencyNumber,
                                              gender,
                                              patientID: patientID),
                                          imgUrl,
                                          widget.patientIDP!,
                                        ))).then((value) {
                              getPatientProfileDetails();
                            });
                          } else if (selectedCategoryIDP == "1") {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            EditMyProfileMedicalPatient(
                                                jsonObj, widget.patientIDP)))
                                .then((value) {
                              getPatientProfileDetails();
                            });
                          }
                        },
                      ),
                    )
                  ],
                  backgroundColor: Color(0xFFFFFFFF),
                  iconTheme: IconThemeData(
                      color: Colorsblack,
                      size: SizeConfig.blockSizeVertical !* 2.2), toolbarTextStyle: TextTheme(
                      titleMedium: TextStyle(
                          color: Colorsblack,
                          fontFamily: "Ubuntu",
                          fontSize: SizeConfig.blockSizeVertical !* 2.5)).bodyMedium, titleTextStyle: TextTheme(
                      titleMedium: TextStyle(
                          color: Colorsblack,
                          fontFamily: "Ubuntu",
                          fontSize: SizeConfig.blockSizeVertical !* 2.5)).titleLarge,
                ),
                body:
                listCategories.isNotEmpty
                ? Column(
                  children: <Widget>[
                    Container(
                        height: SizeConfig.blockSizeVertical !* 10,
                        width: SizeConfig.blockSizeHorizontal !* 100,
                        color: Color(0xFFF0F0F0),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: SizeConfig.blockSizeHorizontal !* 2,
                              right: SizeConfig.blockSizeHorizontal !* 2),
                          child: Center(
                            child: ListView.separated(
                              itemCount: listCategories.length,
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedCategoryIDP =
                                          listCategories[index]["categoryIDP"]!;
                                      selectedCategory =
                                          listCategories[index]["categoryName"]!;
                                    });
                                  },
                                  child: Chip(
                                    padding: EdgeInsets.all(
                                        SizeConfig.blockSizeHorizontal !* 3),
                                    label: Text(
                                      listCategories[index]["categoryName"]
                                          !.trim(),
                                      style: TextStyle(
                                        color: listCategories[index]
                                                    ["categoryIDP"] ==
                                                selectedCategoryIDP
                                            ? Colors.white
                                            : Colors.grey,
                                      ),
                                    ),
                                    shape: StadiumBorder(
                                        side: BorderSide(
                                            color: Colors.grey, width: 1.0)),
                                    backgroundColor: listCategories[index]
                                                ["categoryIDP"] ==
                                            selectedCategoryIDP
                                        ? Color(0xFF06A759)
                                        : Color(0xFFF0F0F0),
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return SizedBox(
                                  width: SizeConfig.blockSizeHorizontal !* 5,
                                );
                              },
                            ),
                          ),
                        )),
                    Expanded(
                      child: selectedCategoryIDP == "1"
                          ? ListView(
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Stack(
                                  alignment: Alignment.topCenter,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        //showImageTypeSelectionDialog(context);
                                      },
                                      child: (imgUrl != "" &&
                                              imgUrl != "null")
                                          ? CircleAvatar(
                                              radius: 60.0,
                                              backgroundImage: NetworkImage(
                                                  "$userImgUrl$imgUrl"))
                                          : CircleAvatar(
                                              radius: 60.0,
                                              backgroundColor: Colors.grey,
                                              backgroundImage:
                                                  /*Image(
                            width: 60,
                            height: 60,
                            fit: BoxFit.fill,
                            image: new */
                                                  AssetImage(
                                                      "images/ic_user_placeholder.png")),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Patient ID",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.2),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        patientID,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Name",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.2),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        userName,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Mobile No.",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.2),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        mobNo,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Gender",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.2),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        gender == "M"
                                            ? "Male"
                                            : (gender == "F" ? "Female" : "-"),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Email",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.2),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        emailId,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                /*SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Emergency Number",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: SizeConfig.blockSizeVertical * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        emergencyNumber,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeVertical * 2.2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                ),*/
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Date of birth",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.2),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        dob,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Age",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.2),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        age,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Height (Centimeters)",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.2),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        "$height Cm - $heightInFeet",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Weight (Kg)",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.2),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        weight,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Blood Group",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.2),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        bloodGroup,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Address",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.2),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        address,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "City",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.2),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        city,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "State",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.2),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        state,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Country",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.2),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        country,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Married",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.2),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        married,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "No. of Family Members",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.2),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        noOfFamilyMembers,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Your position in family",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.2),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        yourPositionInFamily,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            )
                          : ListView(
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: SizeConfig.blockSizeHorizontal !* 3),
                                  child: Text(
                                    "Medical History",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.6,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Diabetes",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.2),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        /*"Since ${jsonObj['DiabetesYear']} Years and ${jsonObj['DiabetesMonth']} Months"*/
                                        jsonObj['DiabetesVal'],
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Hypertension",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.2),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        /*"Since ${jsonObj['HypertensionYear']} Years and ${jsonObj['HypertensionMonth']} Months"*/
                                        jsonObj['HypertensionVal'],
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Heart Disease",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.2),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        /*"Since ${jsonObj['HeartDiseaseYear']} Years and ${jsonObj['HeartDiseaseMonth']} Months"*/
                                        jsonObj['HeartDiseaseVal'],
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Thyroid",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.2),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        /*"Since ${jsonObj['ThyroidYear']} Years and ${jsonObj['ThyroidMonth']} Months"*/
                                        jsonObj['ThyroidVal'],
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: SizeConfig.blockSizeHorizontal !* 3),
                                  child: Text(
                                    "Surgical History",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.6,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 20,
                                    ),
                                    /*Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Surgical History",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize:
                                            SizeConfig.blockSizeVertical * 2.2),
                                  ),
                                ),
                                SizedBox(width: 10),*/
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        jsonObj['SurgicalHistory'],
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: SizeConfig.blockSizeHorizontal !* 3),
                                  child: Text(
                                    "Drug Allergy",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.6,
                                      fontWeight: FontWeight.w500,
                                                                            ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 20,
                                    ),
                                    /*Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Drug Allergy",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize:
                                            SizeConfig.blockSizeVertical * 2.2),
                                  ),
                                ),
                                SizedBox(width: 10),*/
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        jsonObj['DrugAllergy'],
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: SizeConfig.blockSizeHorizontal !* 3),
                                  child: Text(
                                    "Blood Group",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.6,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 20,
                                    ),
                                    /*Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Blood Group",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize:
                                            SizeConfig.blockSizeVertical * 2.2),
                                  ),
                                ),
                                SizedBox(width: 10),*/
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        jsonObj['BloodGroup'],
                                        style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.4,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                    ),
                  ],
                )
                    : Container(),
            )
        );
      },
    );
  }

  /*Future<void> saveContactInPhone(BuildContext context) async {
    try {
      print("saving Conatct");
      PermissionStatus permission = await Permission.contacts.status;

      if (permission != PermissionStatus.granted) {
        await Permission.contacts.request();
        PermissionStatus permission = await Permission.contacts.status;
        if (permission == PermissionStatus.granted) {
          saveTheContact(context);
        } else {
          //_handleInvalidPermissions(context);
        }
      } else {
        saveTheContact(context);
      }
      print("object");
    } catch (e) {
      print(e);
    }
  }*/

  showConfirmationDialogForSaveContact(BuildContext context) {
    //var title = "Are you sure to save this number to number to your contact list?";
    var title = "Do you wish to copy this number to your dial pad ?";
    showDialog(
        context: context,
        barrierDismissible: false,
        // user must tap button for close dialog!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("No")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    launchURL("tel:$mobNo");
                    /*saveContactInPhone(context);*/
                  },
                  child: Text("Yes"))
            ],
          );
        });
  }

  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  String encodeBase64(String text) {
    var bytes = utf8.encode(text);
    //var base64str =
    return base64.encode(bytes);
    //= Base64Encoder().convert()
  }

  String decodeBase64(String text) {
    //var bytes = utf8.encode(text);
    //var base64str =
    var bytes = base64.decode(text);
    return String.fromCharCodes(bytes);
    //= Base64Encoder().convert()
  }

  calculateAge(DateTime birthDate) {
    DateTime birthday = DateTime(1990, 1, 20);
    DateTime today = DateTime.now(); //2020/1/24
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  void cmToFeet() {
    double heightInFeetWithDecimal = double.parse(height) * 0.0328084;
    int intHeightInFeet = heightInFeetWithDecimal.toInt();
    double remainingDecimals = heightInFeetWithDecimal - intHeightInFeet;
    int intHeightInInches = (remainingDecimals * 12).round().toInt();
    if (intHeightInInches == 12) {
      intHeightInFeet++;
      intHeightInInches = 0;
    }
    heightInFeet = "$intHeightInFeet Foot $intHeightInInches Inches";
  }

  void getPatientProfileDetails() async {
    /*List<IconModel> listIcon;*/
    ProgressDialog pr = ProgressDialog(context);
    Future.delayed(Duration.zero, () {
      pr.show();
    });
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    //String patientIDP = await getPatientIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr = "{" +
        "\"" +
        "DoctorIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDP +
        "\"" +
        "," +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.patientIDP! +
        "\"" +
        "}";

    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);
    //listIcon = new List();
    var response = await apiHelper.callApiWithHeadersAndBody(
      url: urlFetchPatientProfileDetails,
      headers: {
        "u": patientUniqueKey,
        "type": userType,
      },
      body: {"getjson": encodedJSONStr},
    );
    //var resBody = json.decode(response.body);
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr.hide();
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array : " + strData);
      final jsonData = json.decode(strData);
      jsonObj = jsonData[0];
      patientID = jsonData[0]['PatientID'];
      firstName = jsonData[0]['FirstName'];
      lastName = jsonData[0]['LastName'];
      middleName = jsonData[0]['MiddleName'];
      userName = (firstName.trim() +
                      " " +
                      middleName.trim() +
                      " " +
                      lastName.trim())
                  .trim() !=
              ""
          ? firstName.trim() + " " + middleName.trim() + " " + lastName.trim()
          : "-";
      mobNo = jsonData[0]['MobileNo'] != "" ? jsonData[0]['MobileNo'] : "-";
      emailId = jsonData[0]['EmailID'] != "" ? jsonData[0]['EmailID'] : "-";
      imgUrl = jsonData[0]['Image'];

      dob = jsonData[0]['DOB'] != "" ? jsonData[0]['DOB'] : "-";
      address = jsonData[0]['Address'] != "" ? jsonData[0]['Address'] : "-";
      city = jsonData[0]['CityName'] != "" ? jsonData[0]['CityName'] : "-";
      state = jsonData[0]['StateName'] != "" ? jsonData[0]['StateName'] : "-";
      country =
          jsonData[0]['CountryName'] != "" ? jsonData[0]['CountryName'] : "-";

      married = jsonData[0]['Married'] != "" ? jsonData[0]['Married'] : "-";
      noOfFamilyMembers = jsonData[0]['NoOfFamilyMember'] != ""
          ? jsonData[0]['NoOfFamilyMember']
          : "-";
      yourPositionInFamily = jsonData[0]['YourPostionInFamily'] != ""
          ? jsonData[0]['YourPostionInFamily']
          : "-";
      age = jsonData[0]['Age'] != "" ? jsonData[0]['Age'] : "-";
      countryIDF = jsonData[0]['CountryIDF'];
      stateIDF = jsonData[0]['StateIDF'];
      cityIDF = jsonData[0]['CityIDF'];

      weight = jsonData[0]['Wieght'] != ""
          ? double.parse(jsonData[0]['Wieght']).round().toString()
          : "0";
      height = jsonData[0]['Height'] != ""
          ? double.parse(jsonData[0]['Height']).round().toString()
          : "0";
      bloodGroup = jsonData[0]['BloodGroup'];
      //emergencyNumber = jsonData[0]['EmergencyNumber'];
      emergencyNumber = "";
      gender = jsonData[0]['Gender'];
      setEmergencyNumber(emergencyNumber);
      cmToFeet();
      setState(() {});
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

/*void saveTheContact(BuildContext context) async {
    Contact newContact = new Contact();
    newContact.givenName =
        firstName.trim() + " " + middleName.trim() + " " + lastName.trim();
    newContact.emails = [Item(label: "email", value: emailId)];
    newContact.phones = [Item(label: "mobile", value: mobNo)];
    newContact.postalAddresses = [PostalAddress(region: address)];
    Stream<Contact> contacts = Contacts.streamContacts(withThumbnails: false);
    bool exist = await contacts.contains(newContact);
    if (exist) {
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text("Contact Already Exist."),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      await Contacts.addContact(newContact);
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text("Contact Saved Successfully."),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }*/
}
