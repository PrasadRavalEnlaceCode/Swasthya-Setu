import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:swasthyasetu/api/api_helper.dart';
import 'package:swasthyasetu/app_screens/edit_my_profile_medical_patient.dart';
import 'package:swasthyasetu/app_screens/pdf_previewer.dart';
//import 'package:swasthyasetu/utils/progress_dialog.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/model_profile_patient.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';

import '../utils/color.dart';
import 'edit_my_profile_patient.dart';

class ViewProfileDetails extends StatefulWidget {
  String? from = "";

  ViewProfileDetails({this.from});

  @override
  State<StatefulWidget> createState() {
    return ViewProfileDetailsState();
  }
}

class ViewProfileDetailsState extends State<ViewProfileDetails> {
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
  ApiHelper apiHelper = ApiHelper();

  @override
  void initState() {
    getPatientProfileDetails();
    jsonObj = {};
    listCategories = [];
    listCategories.add({"categoryName": "General", "categoryIDP": "0"});
    listCategories.add({"categoryName": "Medical", "categoryIDP": "1"});
    if (widget.from == "patientViewMedicalProfile") {
      selectedCategoryIDP = "1";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //if (!dataShown) getUserDetailsFromMemory();
    print('jsonObj');
    print(jsonObj);
    SizeConfig().init(context);
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text("My Profile"),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.black,
                  ),
                  onPressed: () async {
                    String patientIDP = await getPatientOrDoctorIDP();
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
                                  patientIDP))).then((value) {
                        getPatientProfileDetails();
                      });
                    } else if (selectedCategoryIDP == "1") {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditMyProfileMedicalPatient(
                                  jsonObj, patientIDP))).then((value) {
                        getPatientProfileDetails();
                      });
                    }
                  },
                ),
                InkWell(
                    onTap: () {
                      generatePdfAndShare();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: SizeConfig.blockSizeHorizontal !* 3.0,
                          right: SizeConfig.blockSizeHorizontal !* 3.0),
                      child: Image(
                        image: AssetImage("images/ic_pdf.png"),
                        color: Colors.black,
                        width: SizeConfig.blockSizeHorizontal !* 5.3,
                        height: SizeConfig.blockSizeHorizontal !* 5.3,
                      ),
                    ))
              ],
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
            body:
            Column(
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
                                  listCategories[index]["categoryName"]!.trim(),
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
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              width: SizeConfig.blockSizeHorizontal !* 5,
                            );
                          },
                        ),
                      ),
                    )),
                Expanded(
                  child: selectedCategoryIDP == "0"
                      ?
                  ListView(
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
                                          backgroundImage: AssetImage(
                                              "images/ic_user_placeholder.png"),
                                        ),
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
                                            SizeConfig.blockSizeVertical !* 2.2),
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
                                          SizeConfig.blockSizeVertical !* 2.2,
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
                                            SizeConfig.blockSizeVertical !* 2.2),
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
                                          SizeConfig.blockSizeVertical !* 2.2,
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
                                            SizeConfig.blockSizeVertical !* 2.2),
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
                                          SizeConfig.blockSizeVertical !* 2.2,
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
                                            SizeConfig.blockSizeVertical !* 2.2),
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
                                          SizeConfig.blockSizeVertical !* 2.2,
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
                                            SizeConfig.blockSizeVertical !* 2.2),
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
                                          SizeConfig.blockSizeVertical !* 2.2,
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
                                    "Emergency Number",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize:
                                            SizeConfig.blockSizeVertical !* 2.2),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    emergencyNumber,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.2,
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
                                    "Date of birth",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize:
                                            SizeConfig.blockSizeVertical !* 2.2),
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
                                          SizeConfig.blockSizeVertical !* 2.2,
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
                                            SizeConfig.blockSizeVertical !* 2.2),
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
                                          SizeConfig.blockSizeVertical !* 2.2,
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
                                            SizeConfig.blockSizeVertical !* 2.2),
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
                                          SizeConfig.blockSizeVertical !* 2.2,
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
                                            SizeConfig.blockSizeVertical !* 2.2),
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
                                          SizeConfig.blockSizeVertical !* 2.2,
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
                                    "Blood Group",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize:
                                            SizeConfig.blockSizeVertical * 2.2),
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
                                          SizeConfig.blockSizeVertical * 2.2,
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
                                    "Address",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize:
                                            SizeConfig.blockSizeVertical !* 2.2),
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
                                          SizeConfig.blockSizeVertical !* 2.2,
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
                                            SizeConfig.blockSizeVertical !* 2.2),
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
                                          SizeConfig.blockSizeVertical !* 2.2,
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
                                            SizeConfig.blockSizeVertical !* 2.2),
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
                                          SizeConfig.blockSizeVertical !* 2.2,
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
                                            SizeConfig.blockSizeVertical !* 2.2),
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
                                          SizeConfig.blockSizeVertical !* 2.2,
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
                                            SizeConfig.blockSizeVertical !* 2.2),
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
                                          SizeConfig.blockSizeVertical !* 2.2,
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
                                            SizeConfig.blockSizeVertical !* 2.2),
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
                                          SizeConfig.blockSizeVertical !* 2.2,
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
                                            SizeConfig.blockSizeVertical !* 2.2),
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
                                          SizeConfig.blockSizeVertical !* 2.2,
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
                      :
                  ListView(
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
                                  fontSize: SizeConfig.blockSizeVertical !* 2.6,
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
                                            SizeConfig.blockSizeVertical !* 2.2),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    /*jsonObj['DiabetesYear'] != null
                                        ? "Since ${jsonObj['DiabetesYear']} Years and ${jsonObj['DiabetesMonth']} Months"
                                        : ""*/
                                    jsonObj['DiabetesVal'] != null
                                        ? jsonObj['DiabetesVal'] : "",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.2,
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
                                            SizeConfig.blockSizeVertical !* 2.2),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    /*jsonObj['HypertensionYear'] != null
                                        ? "Since ${jsonObj['HypertensionYear']} Years and ${jsonObj['HypertensionMonth']} Months"
                                        : ""*/
                                    jsonObj['HypertensionVal'] != null
                                        ? jsonObj['HypertensionVal'] : "",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.2,
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
                                            SizeConfig.blockSizeVertical !* 2.2),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    /*jsonObj['HeartDiseaseYear'] != null
                                        ? "Since ${jsonObj['HeartDiseaseYear']} Years and ${jsonObj['HeartDiseaseMonth']} Months"
                                        : ""*/
                                    jsonObj['HeartDiseaseVal'] != null
                                  ? jsonObj['HeartDiseaseVal'] : "",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.2,
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
                                            SizeConfig.blockSizeVertical !* 2.2),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    /*jsonObj['ThyroidYear'] != null
                                        ? "Since ${jsonObj['ThyroidYear']} Years and ${jsonObj['ThyroidMonth']} Months"
                                        : ""*/
                                    jsonObj['ThyroidVal'] != null
                                        ? jsonObj['ThyroidVal'] : "",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.2,
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
                                  fontSize: SizeConfig.blockSizeVertical !* 2.6,
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
                                    jsonObj['SurgicalHistory'] != null
                                        ? jsonObj['SurgicalHistory']
                                        : "",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.2,
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
                                  fontSize: SizeConfig.blockSizeVertical !* 2.6,
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
                                    jsonObj['DrugAllergy'] != null
                                        ? jsonObj['DrugAllergy']
                                        : "",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.2,
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
                                  fontSize: SizeConfig.blockSizeVertical !* 2.6,
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
                                    jsonObj['BloodGroup'] != null
                                        ? jsonObj['BloodGroup']
                                        : "",
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.4,
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
                )
              ],
            ))
    );
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
    int intHeightInFeet = heightInFeetWithDecimal.round().toInt();
    double remainingDecimals = heightInFeetWithDecimal - intHeightInFeet;
    int intHeightInInches = (remainingDecimals * 12).round().toInt();
    if (intHeightInInches == 12) {
      intHeightInFeet++;
      intHeightInInches = 0;
    }
    heightInFeet = "$intHeightInFeet Foot $intHeightInInches Inches";
    setState(() {});
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
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr =
        "{" + "\"" + "PatientIDP" + "\"" + ":" + "\"" + patientIDP + "\"" + "}";

    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);
    //listIcon = new List();
    var response = await apiHelper.callApiWithHeadersAndBody(
      url: urlFetchPatientProfileDetails,
      //Uri.parse(loginUrl),
      headers: {
        "u": patientUniqueKey,
        "type": userType,
      },
      body: {"getjson": encodedJSONStr},
    );
    //var resBody = json.decode(response.body);
    // debugPrint(response.body.toString());
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
      emergencyNumber = jsonData[0]['EmergencyNumber'];
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

  void generatePdfAndShare() async {
    /*final pdf = pw.Document();
    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(children: [
            pw.Image(PdfImage.fromImage(pdfDocument, image: null)),
            pw.Text("General Profile",
                style: pw.TextStyle(
                  fontSize: 22.0,
                  fontWeight: pw.FontWeight.bold,
                )),
            pw.Text("----------------------"),
          ]); // Center
        }));
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/${firstName}_profile.pdf");
    await file.writeAsBytes(pdf.save());
    WcFlutterShare.share(
      sharePopupTitle: "Share via",
      mimeType: 'image/jpg',
      fileName: "${firstName}_profile.pdf",
      bytesOfFile: pdf.save(),
    );*/
    /*? CircleAvatar(
        radius: 60.0,
        backgroundImage: NetworkImage(
            "$userImgUrl$imgUrl"))
        : CircleAvatar(
      radius: 60.0,
      backgroundColor: Colors.grey,
      backgroundImage: AssetImage(
          "images/ic_user_placeholder.png"),
    )*/
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return PDFPreviewer(
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
            patientID: patientID,
          ),
          jsonObj);
    }));
  }
}
