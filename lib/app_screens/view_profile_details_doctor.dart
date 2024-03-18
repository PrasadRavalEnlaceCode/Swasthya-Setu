import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:silvertouch/app_screens/edit_my_profile_doctor.dart';
import 'package:silvertouch/app_screens/edit_my_profile_medical_patient.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_profile_patient.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/progress_dialog.dart';

import '../utils/color.dart';

class ViewProfileDetailsDoctor extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ViewProfileDetailsDoctorState();
  }
}

class ViewProfileDetailsDoctorState extends State<ViewProfileDetailsDoctor> {
  String userName = "",
      mobNo = "",
      emailId = "",
      imgUrl = "",
      dob = "",
      /*age = "-",*/
      address = "",
      city = "",
      state = "",
      country = "";

  /*married = "",
      noOfFamilyMembers = "",
      yourPositionInFamily = "";*/
  String firstName = "",
      middleName = "",
      lastName = "",
      countryIDF = "",
      stateIDF = "",
      cityIDF = "",
      registrationNumber = "-";

  String speciality = "", practisingSince = "", degree = "";
  String residenceMobileNo = "" /*, residenceLandLineNo = ""*/;

  String businessAddress = "",
      businessMobileNo = "" /*, businessLandLineNo = ""*/;

  String businessCountryIDF = "",
      businessStateIDF = "",
      businessCityIDF = "",
      businessCountry = "",
      businessState = "",
      businessCity = "";
  String whatsAppNo = "",
      appointmentNo = "",
      latitude = "",
      longitude = "",
      specialityIDP = "";
  String imgUrlLogo = "", imgUrlSignature = "";

  /*String middleName = "",
      weight = "",
      height = "",
      bloodGroup = "",
      emergencyNumber = "";*/
  String gender = "";
  bool dataShown = false;
  static File? image;
  static Stream<String?>? stream;
  final String urlFetchDoctorProfileDetails = "${baseURL}doctorProfileData.php";

  String heightInFeet = "0 Foot 0 Inches";

  @override
  void initState() {
    getDoctorProfileDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //if (!dataShown) getUserDetailsFromMemory();
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
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditMyProfileDoctor(
                                  PatientProfileModel(
                                    firstName,
                                    lastName,
                                    mobNo,
                                    emailId,
                                    imgUrl,
                                    dob,
                                    /*age*/
                                    "",
                                    address,
                                    city,
                                    state,
                                    country,
                                    /*married,
                                    noOfFamilyMembers,
                                    yourPositionInFamily,*/
                                    "",
                                    "",
                                    "",
                                    countryIDF,
                                    stateIDF,
                                    cityIDF,
                                    middleName,
                                    /*weight,
                                    height,
                                    bloodGroup,
                                    emergencyNumber,*/
                                    "",
                                    "",
                                    "",
                                    "",
                                    gender,
                                    speciality: speciality,
                                    practisingSince: practisingSince,
                                    residenceAddress: address,
                                    residenceMobileNo: residenceMobileNo,
                                    residenceLandLineNo:
                                        "" /*residenceLandLineNo*/,
                                    businessAddress: businessAddress,
                                    businessMobileNo: businessMobileNo,
                                    businessLandLineNo:
                                        "" /*businessLandLineNo*/,
                                    businessCity: businessCity,
                                    businessCityIDP: businessCityIDF,
                                    businessState: businessState,
                                    businessStateIDP: businessStateIDF,
                                    businessCountry: businessCountry,
                                    businessCountryIDP: businessCountryIDF,
                                    degree: degree,
                                    registrationNumber: registrationNumber,
                                    whatsAppNumber: whatsAppNo,
                                    appointmentNumber: appointmentNo,
                                    latitude: latitude,
                                    longitude: longitude,
                                    specialityIDP: specialityIDP,
                                  ),
                                  imgUrl,
                                  imgUrlLogo,
                                  imgUrlSignature,
                                ))).then((value) {
                      getDoctorProfileDetails();
                    });
                  },
                )
              ],
              backgroundColor: Color(0xFFFFFFFF),
              iconTheme: IconThemeData(
                  color: Colorsblack,
                  size: SizeConfig.blockSizeVertical! * 2.2),
              toolbarTextStyle: TextTheme(
                      titleMedium: TextStyle(
                          color: Colorsblack,
                          fontFamily: "Ubuntu",
                          fontSize: SizeConfig.blockSizeVertical! * 2.5))
                  .bodyMedium,
              titleTextStyle: TextTheme(
                      titleMedium: TextStyle(
                          color: Colorsblack,
                          fontFamily: "Ubuntu",
                          fontSize: SizeConfig.blockSizeVertical! * 2.5))
                  .titleLarge,
            ),
            body: ListView(
              children: <Widget>[
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
                      child: (imgUrl != "" && imgUrl != "null")
                          ? CircleAvatar(
                              radius: 60.0,
                              backgroundImage:
                                  NetworkImage("$doctorImgUrl$imgUrl"))
                          : CircleAvatar(
                              radius: 60.0,
                              backgroundColor: Colors.grey,
                              backgroundImage:
                                  /*Image(
                            width: 60,
                            height: 60,
                            fit: BoxFit.fill,
                            image: new */
                                  AssetImage("images/ic_user_placeholder.png")),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                            color: Colors.grey,
                            width: 2,
                          ))),
                          child: Text(
                            "Personal Details",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: SizeConfig.blockSizeVertical! * 2.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
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
                        "Registration Number",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: SizeConfig.blockSizeVertical! * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        registrationNumber,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeVertical! * 2.2,
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
                            fontSize: SizeConfig.blockSizeVertical! * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        userName,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeVertical! * 2.2,
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
                            fontSize: SizeConfig.blockSizeVertical! * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        mobNo,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeVertical! * 2.2,
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
                        "Whatsapp Number",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: SizeConfig.blockSizeVertical! * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        whatsAppNo,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeVertical! * 2.2,
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
                        "Appointment Number",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: SizeConfig.blockSizeVertical! * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        appointmentNo,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeVertical! * 2.2,
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
                            fontSize: SizeConfig.blockSizeVertical! * 2.2),
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
                          fontSize: SizeConfig.blockSizeVertical! * 2.2,
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
                        "Degree",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: SizeConfig.blockSizeVertical! * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        degree,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeVertical! * 2.2,
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
                        "Speciality",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: SizeConfig.blockSizeVertical! * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        speciality,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeVertical! * 2.2,
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
                        "Practising Since (Years)",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: SizeConfig.blockSizeVertical! * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        practisingSince,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeVertical! * 2.2,
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
                            fontSize: SizeConfig.blockSizeVertical! * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        emailId,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeVertical! * 2.2,
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
                        */
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
                            fontSize: SizeConfig.blockSizeVertical! * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        dob,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeVertical! * 2.2,
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
                        "Age",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: SizeConfig.blockSizeVertical * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        age,
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
                        "Height (Centimeters)",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: SizeConfig.blockSizeVertical * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        "$height Cm - $heightInFeet",
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
                        "Weight (Kg)",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: SizeConfig.blockSizeVertical * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        weight,
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
                            fontSize: SizeConfig.blockSizeVertical * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        bloodGroup,
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
                        "Residence Address",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: SizeConfig.blockSizeVertical * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        address,
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
                        "City",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: SizeConfig.blockSizeVertical! * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        city,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeVertical! * 2.2,
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
                            fontSize: SizeConfig.blockSizeVertical! * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        state,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeVertical! * 2.2,
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
                            fontSize: SizeConfig.blockSizeVertical! * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        country,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeVertical! * 2.2,
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
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                            color: Colors.grey,
                            width: 2,
                          ))),
                          child: Text(
                            "Residence Details",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: SizeConfig.blockSizeVertical! * 2.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
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
                        "Residence Address",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: SizeConfig.blockSizeVertical! * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        address,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeVertical! * 2.2,
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
                        "Residence Mobile Number",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: SizeConfig.blockSizeVertical! * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        residenceMobileNo,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeVertical! * 2.2,
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
                /*Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Residence Landline",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: SizeConfig.blockSizeVertical * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        residenceLandLineNo,
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
                ),
                SizedBox(
                  height: 10,
                ),*/
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                            color: Colors.grey,
                            width: 2,
                          ))),
                          child: Text(
                            "Hosp./Clinic Details",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: SizeConfig.blockSizeVertical! * 2.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
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
                        "Hosp./Clinic Address",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: SizeConfig.blockSizeVertical! * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        businessAddress,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeVertical! * 2.2,
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
                        "Hosp./Clinic Mobile Number",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: SizeConfig.blockSizeVertical! * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        businessMobileNo,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeVertical! * 2.2,
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
                /*Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Hosp./Clinic Landline",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: SizeConfig.blockSizeVertical * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        businessLandLineNo,
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
                ),
                SizedBox(
                  height: 10,
                ),*/
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Hosp./Clinic City",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: SizeConfig.blockSizeVertical! * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        businessCity,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeVertical! * 2.2,
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
                        "Hosp./Clinic State",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: SizeConfig.blockSizeVertical! * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        businessState,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeVertical! * 2.2,
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
                        "Hosp./Clinic Country",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: SizeConfig.blockSizeVertical! * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        businessCountry,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeVertical! * 2.2,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Latitude",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: SizeConfig.blockSizeVertical! * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        latitude,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeVertical! * 2.2,
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
                        "Longitude",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: SizeConfig.blockSizeVertical! * 2.2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        longitude,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeVertical! * 2.2,
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
                  children: [
                    Expanded(
                      child: imgUrlLogo != "null" && imgUrlLogo != ""
                          ? Column(
                              children: [
                                Image(
                                  image:
                                      NetworkImage("$doctorLogoUrl$imgUrlLogo"),
                                  width: SizeConfig.blockSizeHorizontal! * 35.0,
                                  height:
                                      SizeConfig.blockSizeHorizontal! * 35.0,
                                  fit: BoxFit.fill,
                                ),
                                SizedBox(
                                  height: SizeConfig.blockSizeVertical! * 0.5,
                                ),
                                Text(
                                  "Logo",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal! *
                                              3.5),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Container(
                                  width: SizeConfig.blockSizeHorizontal! * 35.0,
                                  height:
                                      SizeConfig.blockSizeHorizontal! * 35.0,
                                  color: Colors.grey,
                                  child: Center(
                                    child: Text(
                                      "No Logo uploaded",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal! *
                                                  3.5),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: SizeConfig.blockSizeVertical! * 0.5,
                                ),
                                Text(
                                  "",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal! *
                                              3.5),
                                ),
                              ],
                            ),
                    ),
                    Expanded(
                      child: imgUrlSignature != "null" && imgUrlSignature != ""
                          ? Column(
                              children: [
                                Image(
                                  image: NetworkImage(
                                      "$doctorSignatureUrl$imgUrlSignature"),
                                  width: SizeConfig.blockSizeHorizontal! * 35.0,
                                  height:
                                      SizeConfig.blockSizeHorizontal! * 35.0,
                                  fit: BoxFit.fill,
                                ),
                                SizedBox(
                                  height: SizeConfig.blockSizeVertical! * 0.5,
                                ),
                                Text(
                                  "Signature",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal! *
                                              3.5),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Container(
                                  width: SizeConfig.blockSizeHorizontal! * 35.0,
                                  height:
                                      SizeConfig.blockSizeHorizontal! * 35.0,
                                  color: Colors.grey,
                                  child: Center(
                                      child: Text(
                                    "No Signature uploaded",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal! *
                                                3.5),
                                  )),
                                ),
                                SizedBox(
                                  height: SizeConfig.blockSizeVertical! * 0.5,
                                ),
                                Text(
                                  "",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal! *
                                              3.5),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            )));
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

  /*void cmToFeet() {
    double heightInFeetWithDecimal = int.parse(height) * 0.0328084;
    int intHeightInFeet = heightInFeetWithDecimal.toInt();
    double remainingDecimals = heightInFeetWithDecimal - intHeightInFeet;
    int intHeightInInches = (remainingDecimals * 12).round().toInt();
    if (intHeightInInches == 12) {
      intHeightInFeet++;
      intHeightInInches = 0;
    }
    heightInFeet = "$intHeightInFeet Foot $intHeightInInches Inches";
  }*/

  void getDoctorProfileDetails() async {
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
        "{" + "\"" + "DoctorIDP" + "\"" + ":" + "\"" + patientIDP + "\"" + "}";

    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);
    //listIcon = new List();
    var response = await apiHelper.callApiWithHeadersAndBody(
      url: urlFetchDoctorProfileDetails,
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
      registrationNumber = jsonData[0]['RegistrationNo'];
      firstName = jsonData[0]['FirstName'];
      middleName = jsonData[0]['MiddleName'];
      lastName = jsonData[0]['LastName'];
      //middleName = jsonData[0]['MiddleName'];
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
      imgUrl = jsonData[0]['DoctorImage'];

      dob = jsonData[0]['DOB'] != "" ? jsonData[0]['DOB'] : "-";
      address = jsonData[0]['ResidenceAddress'] != ""
          ? jsonData[0]['ResidenceAddress']
          : "-";
      city = jsonData[0]['CityName'] != "" ? jsonData[0]['CityName'] : "-";
      state = jsonData[0]['StateName'] != "" ? jsonData[0]['StateName'] : "-";
      country =
          jsonData[0]['CountryName'] != "" ? jsonData[0]['CountryName'] : "-";

      /*married = jsonData[0]['Married'] != "" ? jsonData[0]['Married'] : "-";
      noOfFamilyMembers = jsonData[0]['NoOfFamilyMember'] != ""
          ? jsonData[0]['NoOfFamilyMember']
          : "-";
      yourPositionInFamily = jsonData[0]['YourPostionInFamily'] != ""
          ? jsonData[0]['YourPostionInFamily']
          : "-";
      age = jsonData[0]['Age'] != "" ? jsonData[0]['Age'] : "-";*/
      countryIDF = jsonData[0]['CountryIDF'];
      stateIDF = jsonData[0]['StateIDF'];
      cityIDF = jsonData[0]['CityIDF'];

      businessCityIDF = jsonData[0]['CountryIDF'];
      businessStateIDF = jsonData[0]['StateIDF'];
      businessCountryIDF = jsonData[0]['CityIDF'];

      businessCity = jsonData[0]['CityName'];
      businessState = jsonData[0]['StateName'];
      businessCountry = jsonData[0]['CountryName'];

      degree = jsonData[0]['Degree'] != "" ? jsonData[0]['Degree'] : "-";
      speciality =
          jsonData[0]['Specility'] != "" ? jsonData[0]['Specility'] : "-";
      practisingSince = jsonData[0]['PractisingSince'] != ""
          ? jsonData[0]['PractisingSince']
          : "-";
      residenceMobileNo = jsonData[0]['ResidenceMobileNo'] != ""
          ? jsonData[0]['ResidenceMobileNo']
          : "-";
      /*residenceLandLineNo = jsonData[0]['ResidenceLandline'] != ""
          ? jsonData[0]['ResidenceLandline']
          : "-";*/
      businessAddress = jsonData[0]['BusinessAddress'] != ""
          ? jsonData[0]['BusinessAddress']
          : "-";
      businessMobileNo = jsonData[0]['BusinessMobileNo'] != ""
          ? jsonData[0]['BusinessMobileNo']
          : "-";
      /*businessLandLineNo = jsonData[0]['BusinessLandline'] != ""
          ? jsonData[0]['BusinessLandline']
          : "-";*/
      imgUrlLogo = jsonData[0]['Logo_Image'];
      imgUrlSignature = jsonData[0]['Doctor_Signature'];

      /*String speciality = "", practisingSince;
      String residenceMobileNo = "", residenceLandLineNo = "";
      String businessAddress = "", businessMobileNo = "", businessLandLineNo = "";*/

      /*weight = jsonData[0]['Wieght'];
      height = jsonData[0]['Height'];
      bloodGroup = jsonData[0]['BloodGroup'];
      emergencyNumber = jsonData[0]['EmergencyNumber'];*/
      gender = jsonData[0]['Gender'];
      whatsAppNo = jsonData[0]['WhatsappNo'];
      appointmentNo = jsonData[0]['AppointmentNo'];
      latitude = jsonData[0]['Latitude'];
      longitude = jsonData[0]['Longitude'];
      specialityIDP = jsonData[0]['SpecialityIDF'];
      //setEmergencyNumber(emergencyNumber);
      //cmToFeet();
      setState(() {});
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
