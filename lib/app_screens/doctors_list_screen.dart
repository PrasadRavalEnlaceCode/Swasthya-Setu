import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silvertouch/app_screens/ask_for_appointment_screen.dart';
import 'package:silvertouch/app_screens/doctor_full_details_screen.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';
import '../podo/dropdown_item.dart';
import '../utils/color.dart';
import '../utils/progress_dialog.dart';
import 'appointment_doctors_list.dart';
import 'fullscreen_image.dart';

List<DropDownItem> listCities = [];
List<DropDownItem> listCitiesSearchResults = [];

DropDownItem selectedState = DropDownItem("", "");
DropDownItem selectedCity = DropDownItem("", "");
String cityName = "";

TextEditingController cityController = new TextEditingController();

class DoctorsListScreen extends StatefulWidget {
  String patientIDP = "";
  final String urlFetchPatientProfileDetails =
      "${baseURL}patientProfileData.php";

  String emptyTextMyDoctors1 =
      "Ask your Doctor to send you bind request from Silver Touch Doctor panel so that you can able to share all your Health records to your prefered doctor.";

  String emptyMessage = "";
  bool? fromMenu = false;
  var selectedCategoryIDP = "2";

  Widget? emptyMessageWidget;

  DoctorsListScreen(String patientIDP, bool fromMenu, var selectedCategoryIDP) {
    this.patientIDP = patientIDP;
    this.fromMenu = fromMenu;
    this.selectedCategoryIDP = selectedCategoryIDP;
  }

  @override
  State<StatefulWidget> createState() {
    return DoctorsListScreenState();
  }
}

class DoctorsListScreenState extends State<DoctorsListScreen> {
  List<Map<String, String>> listDoctors = [];
  List<Map<String, String>> listDoctorsSearchResults = [];
  // List<Map<String, String>> listNonBindedDoctors = [];
  // List<Map<String, String>> listNonBindedDoctorsSearchResults = [];
  String cityIDF = "";
  String firstName = "";
  String lastName = "";
  List<Map<String, String>> listCategories = [];
  var selectedCategoryIDP = "-";

  var searchController = TextEditingController();
  var focusNode = new FocusNode();
  // var isFABVisible = true;
  // bool doctorApiCalled = false;
  // bool apiCalled = false;

  Icon icon = Icon(
    Icons.search,
    color: Colors.black,
  );
  Widget titleWidget = Text("Doctors");
  // ScrollController hideFABController;

  @override
  void initState() {
    super.initState();
    cityName = "";
    widget.emptyMessage = "${widget.emptyTextMyDoctors1}";
    widget.emptyMessageWidget = SizedBox(
      height: SizeConfig.blockSizeVertical! * 80,
      child: Container(
        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage("images/ic_idea_new.png"),
              width: 100,
              height: 100,
            ),
            SizedBox(
              height: 30.0,
            ),
            Text(
              "${widget.emptyMessage}",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
    listCategories
        .add({"categoryName": "Connected Doctors", "categoryIDP": "1"});
    listCategories.add({"categoryName": "New Doctors", "categoryIDP": "2"});
    if (widget.selectedCategoryIDP != "1") {
      selectedCategoryIDP = "2";
    } else {
      selectedCategoryIDP = widget.selectedCategoryIDP;
    }
    // hideFABController = ScrollController();
    // hideFABController.addListener(() {
    //   if (hideFABController.position.userScrollDirection ==
    //       ScrollDirection.reverse) {
    //     if (isFABVisible == true) {
    //       /* only set when the previous state is false
    //          * Less widget rebuilds
    //          */
    //       print("**** $isFABVisible up"); //Move IO away from setState
    //       setState(() {
    //         isFABVisible = false;
    //       });
    //     }
    //   } else {
    //     if (hideFABController.position.userScrollDirection ==
    //         ScrollDirection.forward) {
    //       if (isFABVisible == false) {
    //         print("**** ${isFABVisible} down"); //Move IO away from setState
    //         setState(() {
    //           isFABVisible = true;
    //         });
    //       }
    //     }
    //   }
    // });
    // getPatientProfileDetails("");
    if (widget.fromMenu == false) {
      getNonBindedDoctors("");
    } else {
      getPatientProfileDetails("");
    }
    // getNotBindedDoctorDetails();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: titleWidget,
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(
            color: Colorsblack, size: SizeConfig.blockSizeVertical! * 2.5),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                if (icon.icon == Icons.search) {
                  searchController = TextEditingController(text: "");
                  focusNode.requestFocus();
                  this.icon = Icon(
                    Icons.cancel,
                    color: Colors.black,
                  );
                  this.titleWidget = TextField(
                    controller: searchController,
                    focusNode: focusNode,
                    cursorColor: Colors.white,
                    onChanged: (text) {
                      setState(() {
                        if (listDoctors.length > 0)
                          listDoctorsSearchResults = listDoctors
                              .where((objDoctor) =>
                                  objDoctor["FirstName"]!
                                      .toLowerCase()
                                      .contains(text.toLowerCase()) ||
                                  objDoctor["LastName"]!
                                      .toLowerCase()
                                      .contains(text.toLowerCase()) ||
                                  objDoctor["Specility"]!
                                      .toLowerCase()
                                      .contains(text.toLowerCase()) ||
                                  objDoctor["CityName"]!
                                      .toLowerCase()
                                      .contains(text.toLowerCase()))
                              .toList();
                        else
                          listDoctorsSearchResults = [];
                      });
                    },
                    style: TextStyle(
                      color: Colorsblack,
                      fontSize: SizeConfig.blockSizeHorizontal! * 4.0,
                      letterSpacing: 1.5,
                    ),
                    decoration: InputDecoration(
                      /*hintStyle: TextStyle(
                          color: Colors.black,
                          fontSize:
                          SizeConfig.blockSizeVertical * 2.1),
                      labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize:
                          SizeConfig.blockSizeVertical * 2.1),*/
                      hintText: "Doc Name, Speciality or City",
                    ),
                  );
                } else {
                  this.icon = Icon(
                    Icons.search,
                    color: Colors.black,
                  );
                  this.titleWidget = Text("Doctors");
                  listDoctorsSearchResults = listDoctors;
                }
              });
            },
            icon: icon,
          )
        ],
        toolbarTextStyle: TextTheme(
                titleLarge: TextStyle(
                    color: Colorsblack,
                    fontFamily: "Ubuntu",
                    fontSize: SizeConfig.blockSizeVertical! * 2.5))
            .bodyMedium,
        titleTextStyle: TextTheme(
                titleLarge: TextStyle(
                    color: Colorsblack,
                    fontFamily: "Ubuntu",
                    fontSize: SizeConfig.blockSizeVertical! * 2.5))
            .titleLarge,
      ),
      body: Builder(
        builder: (context) {
          return RefreshIndicator(
            child: listDoctorsSearchResults.length > 0
                ? Column(
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          showCitySelectionDialog(
                              listCitiesSearchResults, "City");
                        },
                        child: Container(
                          margin: EdgeInsets.all(
                            SizeConfig.blockSizeHorizontal! * 3.0,
                          ),
                          padding: EdgeInsets.all(
                            SizeConfig.blockSizeHorizontal! * 3.0,
                          ),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                image: AssetImage("images/ic_city.png"),
                                color: Colors.blue,
                                width: SizeConfig.blockSizeHorizontal! * 6.0,
                                height: SizeConfig.blockSizeHorizontal! * 6.0,
                              ),
                              SizedBox(
                                width: SizeConfig.blockSizeHorizontal! * 3.0,
                              ),
                              Text(
                                selectedCity.value,
                                style: TextStyle(
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal! * 5.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey,
                                size: SizeConfig.blockSizeHorizontal! * 6.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      (widget.fromMenu == false)
                          ? Padding(
                              padding: EdgeInsets.only(
                                  left: SizeConfig.blockSizeHorizontal! * 2,
                                  right: SizeConfig.blockSizeHorizontal! * 2),
                              child: Container(
                                height: SizeConfig.blockSizeVertical! * 10,
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
                                              listCategories[index]
                                                  ["categoryIDP"]!;
                                          if (selectedCategoryIDP == "2")
                                            getNonBindedDoctors("");
                                          else
                                            getPatientProfileDetails("");
                                        });
                                      },
                                      child: Chip(
                                        padding: EdgeInsets.all(
                                            SizeConfig.blockSizeHorizontal! *
                                                3),
                                        label: Text(
                                          listCategories[index]
                                              ["categoryName"]!,
                                          style: TextStyle(
                                            color: listCategories[index]
                                                        ["categoryIDP"] ==
                                                    selectedCategoryIDP
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        backgroundColor: listCategories[index]
                                                    ["categoryIDP"] ==
                                                selectedCategoryIDP
                                            ? colorBlueDark
                                            : colorWhite,
                                      ),
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return SizedBox(
                                      width:
                                          SizeConfig.blockSizeHorizontal! * 5,
                                    );
                                  },
                                ),
                              ),
                            )
                          : Container(),
                      Expanded(
                        child: ListView.builder(
                            itemCount: listDoctorsSearchResults.length,
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  if (selectedCategoryIDP == "1") {
                                    Get.to(() => DoctorFullDetailsScreen(
                                              listDoctorsSearchResults[index],
                                              widget.patientIDP!,
                                            ))!
                                        .then((value) {
                                      if (value != null && value == 1)
                                        getPatientProfileDetails("");
                                    });
                                  }
                                },
                                child: Container(
                                    child: Padding(
                                        padding: EdgeInsets.all(
                                            SizeConfig.blockSizeHorizontal! *
                                                2),
                                        child: Column(
                                          children: [
                                            Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  (listDoctorsSearchResults[
                                                                      index]
                                                                  [
                                                                  "DoctorImage"]
                                                              .toString()
                                                              .length >
                                                          0)
                                                      ? InkWell(
                                                          onTap: () {
                                                            Navigator.of(
                                                                    context)
                                                                .push(MaterialPageRoute(
                                                                    builder:
                                                                        (context) {
                                                              return FullScreenImage(
                                                                "$doctorImgUrl${listDoctorsSearchResults[index]["DoctorImage"]}",
                                                                heroTag:
                                                                    "fullImg_$doctorImgUrl${listDoctorsSearchResults[index]["DoctorImage"]}_${listDoctorsSearchResults[index]['DoctorIDP']}",
                                                                showPlaceholder:
                                                                    !isImageNotNullAndBlank(
                                                                        index),
                                                              );
                                                            }));
                                                          },
                                                          child: CircleAvatar(
                                                              radius: SizeConfig
                                                                      .blockSizeHorizontal! *
                                                                  6,
                                                              backgroundImage:
                                                                  NetworkImage(
                                                                      "$doctorImgUrl${listDoctorsSearchResults[index]["DoctorImage"]}")))
                                                      : CircleAvatar(
                                                          radius: SizeConfig
                                                                  .blockSizeHorizontal! *
                                                              6,
                                                          backgroundColor:
                                                              Colors.grey,
                                                          backgroundImage:
                                                              AssetImage(
                                                                  "images/ic_user_placeholder.png") /*),*/
                                                          ),
                                                  SizedBox(
                                                    width: SizeConfig
                                                            .blockSizeHorizontal! *
                                                        5,
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Container(
                                                        width: SizeConfig
                                                                .blockSizeHorizontal! *
                                                            70,
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                (listDoctorsSearchResults[index]["FirstName"]!
                                                                            .trim() +
                                                                        " " +
                                                                        listDoctorsSearchResults[index]["LastName"]!
                                                                            .trim())
                                                                    .trim(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      SizeConfig
                                                                              .blockSizeHorizontal! *
                                                                          4.2,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: listDoctorsSearchResults[index]
                                                                              [
                                                                              "BindedTag"] ==
                                                                          "1"
                                                                      ? Colors
                                                                          .black
                                                                      : Colors
                                                                          .black,
                                                                  letterSpacing:
                                                                      1.3,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: SizeConfig
                                                                .blockSizeVertical! *
                                                            0.5,
                                                      ),
                                                      SizedBox(
                                                        width: SizeConfig
                                                                .blockSizeHorizontal! *
                                                            70,
                                                        child: Text(
                                                          listDoctorsSearchResults[
                                                                      index][
                                                                  "Specility"]! +
                                                              " - " +
                                                              listDoctorsSearchResults[
                                                                      index]
                                                                  ["CityName"]!,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            fontSize: SizeConfig
                                                                    .blockSizeHorizontal! *
                                                                3.3,
                                                            color: listDoctorsSearchResults[
                                                                            index]
                                                                        [
                                                                        "BindedTag"] ==
                                                                    "1"
                                                                ? Colors.grey
                                                                : Colors.grey,
                                                            letterSpacing: 1.3,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ]),
                                            SizedBox(
                                              height: SizeConfig
                                                      .blockSizeVertical! *
                                                  0.5,
                                            ),
                                            (selectedCategoryIDP == "1")
                                                ? Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal: SizeConfig
                                                                .blockSizeHorizontal! *
                                                            1,
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              listDoctorsSearchResults[
                                                                              index]
                                                                          [
                                                                          "BindedTag"] ==
                                                                      "1"
                                                                  ? Container()
                                                                  : Container(),
                                                              InkWell(
                                                                  onTap: () {
                                                                    // String patientIDP =
                                                                    // listDoctorsSearchResults[
                                                                    // index][
                                                                    // 'DoctorIDP']!;
                                                                    // String patientName = listDoctorsSearchResults[
                                                                    // index]
                                                                    // [
                                                                    // 'FirstName']!
                                                                    //     .trim() +
                                                                    //     " " +
                                                                    //     listDoctorsSearchResults[
                                                                    //     index]
                                                                    //     [
                                                                    //     'LastName']!
                                                                    //         .trim();
                                                                    // String doctorImage =
                                                                    //     "$doctorImgUrl${listDoctorsSearchResults[index]["DoctorImage"]}";
                                                                    // Get.to(() =>
                                                                    //     ChatScreen(
                                                                    //       patientIDP:
                                                                    //       patientIDP,
                                                                    //       patientName:
                                                                    //       patientName,
                                                                    //       patientImage:
                                                                    //       doctorImage,
                                                                    //       heroTag:
                                                                    //       "selectedDoctor_${listDoctorsSearchResults[index]['DoctorIDP']}",
                                                                    //     ))
                                                                    // !.then((value) {
                                                                    //   getPatientProfileDetails("");
                                                                    // });
                                                                    bindUnbindDoctor(
                                                                        listDoctorsSearchResults[
                                                                            index]);
                                                                  },
                                                                  child: Row(
                                                                    children: [
                                                                      Image(
                                                                        image: AssetImage(
                                                                            "images/ic_ask_to_doctor_filled.png"),
                                                                        width: SizeConfig.blockSizeHorizontal! *
                                                                            6.0,
                                                                        height: SizeConfig.blockSizeHorizontal! *
                                                                            6.0,
                                                                      ),
                                                                      SizedBox(
                                                                        width: SizeConfig.blockSizeHorizontal! *
                                                                            1.0,
                                                                      ),
                                                                      Text(
                                                                        "Chat",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.green[700]),
                                                                      )
                                                                    ],
                                                                  )),
                                                              SizedBox(
                                                                width: SizeConfig
                                                                        .blockSizeHorizontal! *
                                                                    2.0,
                                                              ),
                                                              InkWell(
                                                                  onTap: () {
                                                                    Get.to(() =>
                                                                            DoctorFullDetailsScreen(
                                                                              listDoctorsSearchResults[index],
                                                                              widget.patientIDP!,
                                                                            ))!
                                                                        .then(
                                                                            (value) {
                                                                      if (value !=
                                                                              null &&
                                                                          value ==
                                                                              1)
                                                                        getPatientProfileDetails(
                                                                            "");
                                                                    });
                                                                  },
                                                                  child: Row(
                                                                    children: [
                                                                      Image(
                                                                        image: AssetImage(
                                                                            "images/ic_doctor_profile.png"),
                                                                        width: SizeConfig.blockSizeHorizontal! *
                                                                            6.0,
                                                                        height: SizeConfig.blockSizeHorizontal! *
                                                                            6.0,
                                                                      ),
                                                                      SizedBox(
                                                                        width: SizeConfig.blockSizeHorizontal! *
                                                                            1.0,
                                                                      ),
                                                                      Text(
                                                                        "Profile",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.blue[700]),
                                                                      )
                                                                    ],
                                                                  )),
                                                              SizedBox(
                                                                width: SizeConfig
                                                                        .blockSizeHorizontal! *
                                                                    2.0,
                                                              ),
                                                              InkWell(
                                                                  onTap: () {
                                                                    // Get.to(() =>
                                                                    // AppointmentDoctorsListScreen(widget.patientIDP!));
                                                                    if (listDoctorsSearchResults[index]
                                                                            [
                                                                            'AvailableStatus'] ==
                                                                        "1") {
                                                                      Navigator.of(context).push(MaterialPageRoute(
                                                                          builder: (context) => AskForAppointmentScreen(
                                                                                widget.patientIDP!,
                                                                                listDoctorsSearchResults[index]['DoctorIDP']!,
                                                                                listDoctorsSearchResults[index]['AppointmentStatus']!,
                                                                              )));
                                                                    } else {
                                                                      showDoctorIsNotAvailableDialog(
                                                                          context);
                                                                    }
                                                                  },
                                                                  child: Row(
                                                                    children: [
                                                                      Image(
                                                                        image: AssetImage(
                                                                            "images/ic_ask_for_appointment_filled.png"),
                                                                        width: SizeConfig.blockSizeHorizontal! *
                                                                            6.0,
                                                                        height: SizeConfig.blockSizeHorizontal! *
                                                                            6.0,
                                                                      ),
                                                                      SizedBox(
                                                                        width: SizeConfig.blockSizeHorizontal! *
                                                                            1.0,
                                                                      ),
                                                                      Text(
                                                                        "Appointment",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.blue[700]),
                                                                      )
                                                                    ],
                                                                  )),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ))
                                                : Align(
                                                    alignment: Alignment.center,
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal: SizeConfig
                                                                .blockSizeHorizontal! *
                                                            1,
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              listDoctorsSearchResults[
                                                                              index]
                                                                          [
                                                                          "BindedTag"] ==
                                                                      "1"
                                                                  ? Container()
                                                                  : Container(),
                                                              InkWell(
                                                                  onTap: () {
                                                                    String
                                                                        patientIDP =
                                                                        listDoctorsSearchResults[index]
                                                                            [
                                                                            'DoctorIDP']!;
                                                                    // String patientName = listDoctorsSearchResults[
                                                                    // index]
                                                                    // [
                                                                    // 'FirstName']!
                                                                    //     .trim() +
                                                                    //     " " +
                                                                    //     listDoctorsSearchResults[
                                                                    //     index]
                                                                    //     [
                                                                    //     'LastName']!
                                                                    //         .trim();
                                                                    // String doctorImage =
                                                                    //     "$doctorImgUrl${listDoctorsSearchResults[index]["DoctorImage"]}";
                                                                    // Get.to(() =>
                                                                    //     ChatScreen(
                                                                    //       patientIDP:
                                                                    //       patientIDP,
                                                                    //       patientName:
                                                                    //       patientName,
                                                                    //       patientImage:
                                                                    //       doctorImage,
                                                                    //       heroTag:
                                                                    //       "selectedDoctor_${listDoctorsSearchResults[index]['DoctorIDP']}",
                                                                    //     ))
                                                                    // !.then((value) {
                                                                    //   getPatientProfileDetails("");
                                                                    // });
                                                                    bindUnbindDoctor(
                                                                        listDoctorsSearchResults[
                                                                            index]);
                                                                  },
                                                                  child: Row(
                                                                    children: [
                                                                      Image(
                                                                        image: AssetImage(
                                                                            "images/ic_imp_links.png"),
                                                                        width: SizeConfig.blockSizeHorizontal! *
                                                                            6.0,
                                                                        height: SizeConfig.blockSizeHorizontal! *
                                                                            6.0,
                                                                      ),
                                                                      SizedBox(
                                                                        width: SizeConfig.blockSizeHorizontal! *
                                                                            1.0,
                                                                      ),
                                                                      Text(
                                                                        "Connect \nto Doctor",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.green[700]),
                                                                      )
                                                                    ],
                                                                  )),
                                                              SizedBox(
                                                                width: SizeConfig
                                                                        .blockSizeHorizontal! *
                                                                    5.0,
                                                              ),
                                                              InkWell(
                                                                  onTap: () {
                                                                    Get.to(() =>
                                                                        AskForAppointmentScreen(
                                                                          widget
                                                                              .patientIDP,
                                                                          listDoctorsSearchResults[index]
                                                                              [
                                                                              "DoctorIDP"]!,
                                                                          listDoctorsSearchResults[index]
                                                                              [
                                                                              "AppointmentStatus"]!,
                                                                        ));
                                                                    // Get.to(() => AppointmentDoctorsListScreen(widget.patientIDP));
                                                                    // if (listDoctorsSearchResults[
                                                                    // index][
                                                                    // 'AvailableStatus'] ==
                                                                    //     "1") {
                                                                    //   Navigator.of(
                                                                    //       context)
                                                                    //       .push(MaterialPageRoute(
                                                                    //       builder:
                                                                    //           (context) {
                                                                    //         return AskForAppointmentScreen(
                                                                    //           widget
                                                                    //               .patientIDP,
                                                                    //           listDoctorsSearchResults[
                                                                    //           index][
                                                                    //           'DoctorIDP']!,
                                                                    //           listDoctorsSearchResults[
                                                                    //           index][
                                                                    //           'AppointmentStatus']!,
                                                                    //         );
                                                                    //       }
                                                                    //   )
                                                                    //   );
                                                                    // } else {
                                                                    //   showDoctorIsNotAvailableDialog(
                                                                    //       context);
                                                                    // }
                                                                  },
                                                                  child: Row(
                                                                    children: [
                                                                      Image(
                                                                        image: AssetImage(
                                                                            "images/ic_ask_for_appointment_filled.png"),
                                                                        width: SizeConfig.blockSizeHorizontal! *
                                                                            6.0,
                                                                        height: SizeConfig.blockSizeHorizontal! *
                                                                            6.0,
                                                                      ),
                                                                      SizedBox(
                                                                        width: SizeConfig.blockSizeHorizontal! *
                                                                            1.0,
                                                                      ),
                                                                      Text(
                                                                        "Appointment",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.blue[700]),
                                                                      )
                                                                    ],
                                                                  )),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                            Container(
                                              color: Colors.grey,
                                              height: 0.5,
                                            )
                                                .paddingSymmetric(
                                                    horizontal: SizeConfig
                                                            .blockSizeHorizontal! *
                                                        2)
                                                .paddingOnly(
                                                  top: SizeConfig
                                                          .blockSizeVertical! *
                                                      1.8,
                                                )
                                          ],
                                        ))),
                              );
                            }),
                      )
                    ],
                  )
                : widget.emptyMessageWidget!,
            onRefresh: () {
              return getPatientProfileDetails("");
            },
          );
        },
      ),
    );
  }

  isImageNotNullAndBlank(int index) {
    return (listDoctorsSearchResults[index]["DoctorImage"] != "" &&
        listDoctorsSearchResults[index]["DoctorImage"] != null &&
        listDoctorsSearchResults[index]["DoctorImage"] != "null");
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

  Future<String> getPatientProfileDetails(String cityidp) async {
    print('Connected Doctors');
    /*List<IconModel> listIcon;*/
    var doctorApiCalled = false;
    ProgressDialog pr = ProgressDialog(context);
    Future.delayed(Duration.zero, () {
      pr.show();
    });

    try {
      String patientUniqueKey = await getPatientUniqueKey();
      String userType = await getUserType();
      debugPrint("Key and type");
      debugPrint(patientUniqueKey);
      debugPrint(userType);
      String jsonStr = "{" +
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
        url: widget.urlFetchPatientProfileDetails,
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
      if (model.status == "OK") {
        var data = jsonResponse['Data'];
        var strData = decodeBase64(data);
        debugPrint("Decoded Data Array : " + strData);
        final jsonData = json.decode(strData);
        debugPrint("Selected City IDP : " + cityidp);
        (cityidp.length > 0)
            ? cityIDF = cityidp
            : cityIDF = jsonData[0]['CityIDF'];
        firstName = jsonData[0]['FirstName'];
        lastName = jsonData[0]['LastName'];

        selectedCity =
            DropDownItem(jsonData[0]['CityIDF'], jsonData[0]['CityName']);
        selectedState =
            DropDownItem(jsonData[0]['StateIDF'], jsonData[0]['StateName']);
        getCitiesList();
        // listNonBindedDoctors = [];
        // listNonBindedDoctorsSearchResults = [];

        //getBindedDoctors();
        listDoctors = [];
        listDoctors.clear();
        listDoctorsSearchResults = [];
        listDoctorsSearchResults.clear();
        String loginUrl = "${baseURL}doctorList.php";
        //listIcon = new List();
        var cityIdp = "";
        if (cityIDF != "")
          cityIdp = cityIDF;
        else
          cityIdp = "-";
        String jsonStr = "{" +
            "\"" +
            "PatientIDP" +
            "\"" +
            ":" +
            "\"" +
            widget.patientIDP! +
            "\"" +
            "," +
            "\"" +
            "CityIDP" +
            "\"" +
            ":" +
            "\"" +
            cityIdp +
            "\"" +
            "}";

        debugPrint("Doctor API request object");
        debugPrint(jsonStr);

        String encodedJSONStr = encodeBase64(jsonStr);
        var response = await apiHelper.callApiWithHeadersAndBody(
          url: loginUrl,
          //Uri.parse(loginUrl),
          headers: {
            "u": patientUniqueKey,
            "type": userType,
          },
          body: {"getjson": encodedJSONStr},
        );
        //var resBody = json.decode(response.body);
        debugPrint(response.body.toString());
        final jsonResponse1 = json.decode(response.body.toString());
        ResponseModel model = ResponseModel.fromJSON(jsonResponse1);
        pr.hide();

        if (model.status == "OK") {
          var data = jsonResponse1['Data'];
          var strData = decodeBase64(data);
          debugPrint("Decoded Data Array Dashboard : " + strData);
          final jsonData = json.decode(strData);
          if (jsonData.length > 0)
            doctorApiCalled = true;
          else
            doctorApiCalled = false;
          for (var i = 0; i < jsonData.length; i++) {
            var jo = jsonData[i];
            listDoctors.add({
              "DoctorIDP": jo['DoctorIDP'].toString(),
              "DoctorID": jo['DoctorID'].toString(),
              "FirstName": jo['FirstName'].toString(),
              "LastName": jo['LastName'].toString(),
              "MobileNo": jo['MobileNo'].toString(),
              "Specility": jo['Specility'].toString(),
              "DoctorImage": jo['DoctorImage'].toString(),
              "CityName": jo['CityName'].toString(),
              "BindedTag": jo['BindedTag'].toString(),
              "HealthRecordsDisplayStatus":
                  jo['HealthRecordsDisplayStatus'].toString(),
              "ConsultationDisplayStatus":
                  jo['ConsultationDisplayStatus'].toString(),
              "DueAmount": jo['DueAmount'].toString(),
            });
            listDoctorsSearchResults.add({
              "DoctorIDP": jo['DoctorIDP'].toString(),
              "DoctorID": jo['DoctorID'].toString(),
              "FirstName": jo['FirstName'].toString(),
              "LastName": jo['LastName'].toString(),
              "MobileNo": jo['MobileNo'].toString(),
              "Specility": jo['Specility'].toString(),
              "DoctorImage": jo['DoctorImage'].toString(),
              "CityName": jo['CityName'].toString(),
              "BindedTag": jo['BindedTag'].toString(),
              "HealthRecordsDisplayStatus":
                  jo['HealthRecordsDisplayStatus'].toString(),
              "ConsultationDisplayStatus":
                  jo['ConsultationDisplayStatus'].toString(),
              "DueAmount": jo['DueAmount'].toString(),
            });
          }
          setState(() {});
        }
        //setState(() {});
      } else {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text(model.message!),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (exception) {
      if (!doctorApiCalled) {
        try {
          listDoctors = [];
          listDoctors.clear();
          listDoctorsSearchResults = [];
          listDoctorsSearchResults.clear();
          String loginUrl = "${baseURL}doctorList.php";
          //listIcon = new List();
          String patientUniqueKey = await getPatientUniqueKey();
          String userType = await getUserType();
          debugPrint("Key and type");
          debugPrint(patientUniqueKey);
          debugPrint(userType);
          var cityIdp = "";
          if (cityIDF != "")
            cityIdp = cityIDF;
          else
            cityIdp = "-";
          String jsonStr = "{" +
              "\"" +
              "PatientIDP" +
              "\"" +
              ":" +
              "\"" +
              widget.patientIDP! +
              "\"" +
              "," +
              "\"" +
              "CityIDP" +
              "\"" +
              ":" +
              "\"" +
              cityIdp +
              "\"" +
              "}";

          debugPrint("Doctor API request object");
          debugPrint(jsonStr);

          String encodedJSONStr = encodeBase64(jsonStr);
          var response = await apiHelper.callApiWithHeadersAndBody(
            url: loginUrl,
            //Uri.parse(loginUrl),
            headers: {
              "u": patientUniqueKey,
              "type": userType,
            },
            body: {"getjson": encodedJSONStr},
          );
          //var resBody = json.decode(response.body);
          debugPrint(response.body.toString());
          final jsonResponse1 = json.decode(response.body.toString());
          ResponseModel model = ResponseModel.fromJSON(jsonResponse1);
          pr.hide();

          if (model.status == "OK") {
            var data = jsonResponse1['Data'];
            var strData = decodeBase64(data);
            debugPrint("Decoded Data Array Dashboard : " + strData);
            final jsonData = json.decode(strData);
            if (jsonData.length > 0)
              doctorApiCalled = true;
            else
              doctorApiCalled = false;
            for (var i = 0; i < jsonData.length; i++) {
              var jo = jsonData[i];
              listDoctors.add({
                "DoctorIDP": jo['DoctorIDP'].toString(),
                "DoctorID": jo['DoctorID'].toString(),
                "FirstName": jo['FirstName'].toString(),
                "LastName": jo['LastName'].toString(),
                "MobileNo": jo['MobileNo'].toString(),
                "Specility": jo['Specility'].toString(),
                "DoctorImage": jo['DoctorImage'].toString(),
                "CityName": jo['CityName'].toString(),
                "BindedTag": jo['BindedTag'].toString(),
                "HealthRecordsDisplayStatus":
                    jo['HealthRecordsDisplayStatus'].toString(),
                "ConsultationDisplayStatus":
                    jo['ConsultationDisplayStatus'].toString(),
                "DueAmount": jo['DueAmount'].toString(),
              });
              listDoctorsSearchResults.add({
                "DoctorIDP": jo['DoctorIDP'].toString(),
                "DoctorID": jo['DoctorID'].toString(),
                "FirstName": jo['FirstName'].toString(),
                "LastName": jo['LastName'].toString(),
                "MobileNo": jo['MobileNo'].toString(),
                "Specility": jo['Specility'].toString(),
                "DoctorImage": jo['DoctorImage'].toString(),
                "CityName": jo['CityName'].toString(),
                "BindedTag": jo['BindedTag'].toString(),
                "HealthRecordsDisplayStatus":
                    jo['HealthRecordsDisplayStatus'].toString(),
                "ConsultationDisplayStatus":
                    jo['ConsultationDisplayStatus'].toString(),
                "DueAmount": jo['DueAmount'].toString(),
              });
            }
            setState(() {});
          }
        } catch (exception) {
          pr.hide();
        }
      } else {
        pr.hide();
      }
    }
    return 'success';
  }

  Future<String> getNonBindedDoctors(String cityidp) async {
    /*List<IconModel> listIcon;*/
    print('Non Connected Doctors');
    var doctorApiCalled = false;
    ProgressDialog pr = ProgressDialog(context);
    Future.delayed(Duration.zero, () {
      pr.show();
    });

    try {
      String patientUniqueKey = await getPatientUniqueKey();
      String userType = await getUserType();
      debugPrint("Key and type");
      debugPrint(patientUniqueKey);
      debugPrint(userType);
      String jsonStr = "{" +
          "\"" +
          "PatientIDP" +
          "\"" +
          ":" +
          "\"" +
          widget.patientIDP +
          "\"" +
          "}";

      debugPrint(jsonStr);

      String encodedJSONStr = encodeBase64(jsonStr);
      //listIcon = new List();
      var response = await apiHelper.callApiWithHeadersAndBody(
        url: widget.urlFetchPatientProfileDetails,
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
      if (model.status == "OK") {
        var data = jsonResponse['Data'];
        var strData = decodeBase64(data);
        debugPrint("Decoded Data Array : " + strData);
        final jsonData = json.decode(strData);
        debugPrint("Selected City IDP : " + cityidp);
        (cityidp.length > 0)
            ? cityIDF = cityidp
            : cityIDF = jsonData[0]['CityIDF'];
        firstName = jsonData[0]['FirstName'];
        lastName = jsonData[0]['LastName'];

        selectedCity =
            DropDownItem(jsonData[0]['CityIDF'], jsonData[0]['CityName']);
        selectedState =
            DropDownItem(jsonData[0]['StateIDF'], jsonData[0]['StateName']);
        getCitiesList();
        // listNonBindedDoctors = [];
        // listNonBindedDoctorsSearchResults = [];
        // listDoctors = [];
        // listDoctorsSearchResults = [];
        //getBindedDoctors();
        listDoctors = [];
        listDoctors.clear();
        listDoctorsSearchResults = [];
        listDoctorsSearchResults.clear();
        String loginUrl = "${baseURL}doctorPatientNotBinded.php";
        //listIcon = new List();
        var cityIdp = "";
        if (cityIDF != "")
          cityIdp = cityIDF;
        else
          cityIdp = "-";
        String jsonStr = "{" +
            "\"" +
            "PatientIDP" +
            "\"" +
            ":" +
            "\"" +
            widget.patientIDP! +
            "\"" +
            "," +
            "\"" +
            "CityIDP" +
            "\"" +
            ":" +
            "\"" +
            cityIdp +
            "\"" +
            "}";

        debugPrint("Doctor API request object");
        debugPrint(jsonStr);

        String encodedJSONStr = encodeBase64(jsonStr);
        var response = await apiHelper.callApiWithHeadersAndBody(
          url: loginUrl,
          //Uri.parse(loginUrl),
          headers: {
            "u": patientUniqueKey,
            "type": userType,
          },
          body: {"getjson": encodedJSONStr},
        );
        //var resBody = json.decode(response.body);
        debugPrint(response.body.toString());
        final jsonResponse1 = json.decode(response.body.toString());
        ResponseModel model = ResponseModel.fromJSON(jsonResponse1);
        pr.hide();

        if (model.status == "OK") {
          var data = jsonResponse1['Data'];
          var strData = decodeBase64(data);
          debugPrint("Decoded Data Array Dashboard : " + strData);
          final jsonData = json.decode(strData);
          if (jsonData.length > 0)
            doctorApiCalled = true;
          else
            doctorApiCalled = false;
          for (var i = 0; i < jsonData.length; i++) {
            var jo = jsonData[i];
            listDoctors.add({
              "DoctorIDP": jo['DoctorIDP'].toString(),
              "DoctorID": jo['DoctorID'].toString(),
              "FirstName": jo['FirstName'].toString(),
              "LastName": jo['LastName'].toString(),
              "MobileNo": jo['MobileNo'].toString(),
              "Specility": jo['Specility'].toString(),
              "DoctorImage": jo['DoctorImage'].toString(),
              "CityName": jo['CityName'].toString(),
              "BindedTag": jo['BindedTag'].toString(),
              "HealthRecordsDisplayStatus":
                  jo['HealthRecordsDisplayStatus'].toString(),
              "ConsultationDisplayStatus":
                  jo['ConsultationDisplayStatus'].toString(),
              "DueAmount": jo['DueAmount'].toString(),
              "AvailableStatus": jo['AvailableStatus'].toString(),
              "AppointmentStatus": jo['AppointmentStatus'].toString()
            });
            listDoctorsSearchResults.add({
              "DoctorIDP": jo['DoctorIDP'].toString(),
              "DoctorID": jo['DoctorID'].toString(),
              "FirstName": jo['FirstName'].toString(),
              "LastName": jo['LastName'].toString(),
              "MobileNo": jo['MobileNo'].toString(),
              "Specility": jo['Specility'].toString(),
              "DoctorImage": jo['DoctorImage'].toString(),
              "CityName": jo['CityName'].toString(),
              "BindedTag": jo['BindedTag'].toString(),
              "HealthRecordsDisplayStatus":
                  jo['HealthRecordsDisplayStatus'].toString(),
              "ConsultationDisplayStatus":
                  jo['ConsultationDisplayStatus'].toString(),
              "DueAmount": jo['DueAmount'].toString(),
              "AvailableStatus": jo['AvailableStatus'].toString(),
              "AppointmentStatus": jo['AppointmentStatus'].toString()
            });
          }
          setState(() {});
        }
        //setState(() {});
      } else {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text(model.message!),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (exception) {
      if (!doctorApiCalled) {
        try {
          listDoctors = [];
          listDoctors.clear();
          listDoctorsSearchResults = [];
          listDoctorsSearchResults.clear();
          String loginUrl = "${baseURL}doctorPatientNotBinded.php";
          //listIcon = new List();
          String patientUniqueKey = await getPatientUniqueKey();
          String userType = await getUserType();
          debugPrint("Key and type");
          debugPrint(patientUniqueKey);
          debugPrint(userType);
          var cityIdp = "";
          if (cityIDF != "")
            cityIdp = cityIDF;
          else
            cityIdp = "-";
          String jsonStr = "{" +
              "\"" +
              "PatientIDP" +
              "\"" +
              ":" +
              "\"" +
              widget.patientIDP! +
              "\"" +
              "," +
              "\"" +
              "CityIDP" +
              "\"" +
              ":" +
              "\"" +
              cityIdp +
              "\"" +
              "}";

          debugPrint("Doctor API request object");
          debugPrint(jsonStr);

          String encodedJSONStr = encodeBase64(jsonStr);
          var response = await apiHelper.callApiWithHeadersAndBody(
            url: loginUrl,
            //Uri.parse(loginUrl),
            headers: {
              "u": patientUniqueKey,
              "type": userType,
            },
            body: {"getjson": encodedJSONStr},
          );
          //var resBody = json.decode(response.body);
          debugPrint(response.body.toString());
          final jsonResponse1 = json.decode(response.body.toString());
          ResponseModel model = ResponseModel.fromJSON(jsonResponse1);
          pr.hide();

          if (model.status == "OK") {
            var data = jsonResponse1['Data'];
            var strData = decodeBase64(data);
            debugPrint("Decoded Data Array Dashboard : " + strData);
            final jsonData = json.decode(strData);
            if (jsonData.length > 0)
              doctorApiCalled = true;
            else
              doctorApiCalled = false;
            for (var i = 0; i < jsonData.length; i++) {
              var jo = jsonData[i];
              listDoctors.add({
                "DoctorIDP": jo['DoctorIDP'].toString(),
                "DoctorID": jo['DoctorID'].toString(),
                "FirstName": jo['FirstName'].toString(),
                "LastName": jo['LastName'].toString(),
                "MobileNo": jo['MobileNo'].toString(),
                "Specility": jo['Specility'].toString(),
                "DoctorImage": jo['DoctorImage'].toString(),
                "CityName": jo['CityName'].toString(),
                "BindedTag": jo['BindedTag'].toString(),
                "HealthRecordsDisplayStatus":
                    jo['HealthRecordsDisplayStatus'].toString(),
                "ConsultationDisplayStatus":
                    jo['ConsultationDisplayStatus'].toString(),
                "DueAmount": jo['DueAmount'].toString(),
                "AvailableStatus": jo['AvailableStatus'].toString(),
                "AppointmentStatus": jo['AppointmentStatus'].toString()
              });
              listDoctorsSearchResults.add({
                "DoctorIDP": jo['DoctorIDP'].toString(),
                "DoctorID": jo['DoctorID'].toString(),
                "FirstName": jo['FirstName'].toString(),
                "LastName": jo['LastName'].toString(),
                "MobileNo": jo['MobileNo'].toString(),
                "Specility": jo['Specility'].toString(),
                "DoctorImage": jo['DoctorImage'].toString(),
                "CityName": jo['CityName'].toString(),
                "BindedTag": jo['BindedTag'].toString(),
                "HealthRecordsDisplayStatus":
                    jo['HealthRecordsDisplayStatus'].toString(),
                "ConsultationDisplayStatus":
                    jo['ConsultationDisplayStatus'].toString(),
                "DueAmount": jo['DueAmount'].toString(),
                "AvailableStatus": jo['AvailableStatus'].toString(),
                "AppointmentStatus": jo['AppointmentStatus'].toString()
              });
            }
            setState(() {});
          }
        } catch (exception) {
          pr.hide();
        }
      } else {
        pr.hide();
      }
    }
    return 'success';
  }

  // Future<String> getNotBindedDoctorDetails() async {
  //   /*List<IconModel> listIcon;*/
  //   var doctorNonBindedApiCalled = false;
  //   ProgressDialog pr = ProgressDialog(context);
  //   Future.delayed(Duration.zero, () {
  //     pr.show();
  //   });
  //
  //   try {
  //     String patientUniqueKey = await getPatientUniqueKey();
  //     String userType = await getUserType();
  //     debugPrint("Key and type");
  //     debugPrint(patientUniqueKey);
  //     debugPrint(userType);
  //     String jsonStr = "{" +
  //         "\"" +
  //         "PatientIDP" +
  //         "\"" +
  //         ":" +
  //         "\"" +
  //         widget.patientIDP +
  //         "\"" +
  //         "}";
  //
  //     debugPrint(jsonStr);
  //
  //     String encodedJSONStr = encodeBase64(jsonStr);
  //     //listIcon = new [];
  //     var response = await apiHelper.callApiWithHeadersAndBody(
  //       url: widget.urlFetchPatientProfileDetails,
  //       //Uri.parse(loginUrl),
  //       headers: {
  //         "u": patientUniqueKey,
  //         "type": userType,
  //       },
  //       body: {"getjson": encodedJSONStr},
  //     );
  //     //var resBody = json.decode(response.body);
  //     debugPrint(response.body.toString());
  //     final jsonResponse = json.decode(response.body.toString());
  //     ResponseModel model = ResponseModel.fromJSON(jsonResponse);
  //     if (model.status == "OK") {
  //       var data = jsonResponse['Data'];
  //       var strData = decodeBase64(data);
  //       debugPrint("Decoded Data Array : " + strData);
  //       final jsonData = json.decode(strData);
  //       cityIDF = jsonData[0]['CityIDF'];
  //       cityName = jsonData[0]['CityName'];
  //       firstName = jsonData[0]['FirstName'];
  //       lastName = jsonData[0]['LastName'];
  //
  //       selectedCity =
  //           DropDownItem(jsonData[0]['CityIDF'], jsonData[0]['CityName']);
  //       selectedState =
  //           DropDownItem(jsonData[0]['StateIDF'], jsonData[0]['StateName']);
  //       getCitiesList();
  //       listNonBindedDoctors = [];
  //       listNonBindedDoctorsSearchResults = [];
  //
  //       //getBindedDoctors();
  //       getNonBindedDoctors();
  //       pr.hide();
  //       //setState(() {});
  //     } else {
  //       final snackBar = SnackBar(
  //         backgroundColor: Colors.red,
  //         content: Text(model.message),
  //       );
  //       ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //     }
  //   } catch (exception) {
  //     if (!doctorNonBindedApiCalled) {
  //       try {
  //         listNonBindedDoctors = [];
  //         listNonBindedDoctorsSearchResults = [];
  //         String loginUrl = "${baseURL}doctorPatientNotBinded.php";
  //         //listIcon = new [];
  //         String patientUniqueKey = await getPatientUniqueKey();
  //         String userType = await getUserType();
  //         debugPrint("Key and type");
  //         debugPrint(patientUniqueKey);
  //         debugPrint(userType);
  //         var cityIdp = "";
  //         if (cityIDF != "")
  //           cityIdp = cityIDF;
  //         else
  //           cityIdp = "-";
  //         String jsonStr = "{" +
  //             "\"" +
  //             "PatientIDP" +
  //             "\"" +
  //             ":" +
  //             "\"" +
  //             widget.patientIDP +
  //             "\"" +
  //             "," +
  //             "\"" +
  //             "CityIDP" +
  //             "\"" +
  //             ":" +
  //             "\"" +
  //             cityIdp +
  //             "\"" +
  //             "}";
  //
  //         debugPrint("Doctor API request object");
  //         debugPrint(jsonStr);
  //
  //         String encodedJSONStr = encodeBase64(jsonStr);
  //         var response = await apiHelper.callApiWithHeadersAndBody(
  //           url: loginUrl,
  //           //Uri.parse(loginUrl),
  //           headers: {
  //             "u": patientUniqueKey,
  //             "type": userType,
  //           },
  //           body: {"getjson": encodedJSONStr},
  //         );
  //         //var resBody = json.decode(response.body);
  //         debugPrint(response.body.toString());
  //         final jsonResponse1 = json.decode(response.body.toString());
  //         ResponseModel model = ResponseModel.fromJSON(jsonResponse1);
  //         pr.hide();
  //
  //         if (model.status == "OK") {
  //           var data = jsonResponse1['Data'];
  //           var strData = decodeBase64(data);
  //           debugPrint("Decoded Data Array Dashboard : " + strData);
  //           final jsonData = json.decode(strData);
  //           if (jsonData.length > 0)
  //             doctorNonBindedApiCalled = true;
  //           else
  //             doctorNonBindedApiCalled = false;
  //           for (var i = 0; i < jsonData.length; i++) {
  //             var jo = jsonData[i];
  //             listNonBindedDoctors.add({
  //               "DoctorIDP": jo['DoctorIDP'].toString(),
  //               "DoctorID": jo['DoctorID'].toString(),
  //               "FirstName": jo['FirstName'].toString(),
  //               "LastName": jo['LastName'].toString(),
  //               "MobileNo": jo['MobileNo'].toString(),
  //               "Specility": jo['Specility'].toString(),
  //               "DoctorImage": jo['DoctorImage'].toString(),
  //               "CityName": jo['CityName'].toString(),
  //               "BindedTag": jo['BindedTag'].toString(),
  //               "AvailableStatus": jo['AvailableStatus'].toString(),
  //               "AppointmentStatus": jo['AppointmentStatus'].toString(),
  //               "DueAmount": jo['DueAmount'].toString(),
  //               "BindStatus": jo['BindStatus'].toString(),
  //             });
  //             listNonBindedDoctorsSearchResults.add({
  //               "DoctorIDP": jo['DoctorIDP'].toString(),
  //               "DoctorID": jo['DoctorID'].toString(),
  //               "FirstName": jo['FirstName'].toString(),
  //               "LastName": jo['LastName'].toString(),
  //               "MobileNo": jo['MobileNo'].toString(),
  //               "Specility": jo['Specility'].toString(),
  //               "DoctorImage": jo['DoctorImage'].toString(),
  //               "CityName": jo['CityName'].toString(),
  //               "BindedTag": jo['BindedTag'].toString(),
  //               "AvailableStatus": jo['AvailableStatus'].toString(),
  //               "AppointmentStatus": jo['AppointmentStatus'].toString(),
  //               "DueAmount": jo['DueAmount'].toString(),
  //               "BindStatus": jo['BindStatus'].toString(),
  //             });
  //           }
  //           setState(() {});
  //         }
  //       } catch (exception) {
  //         pr.hide();
  //       }
  //     } else {
  //       pr.hide();
  //     }
  //   }
  //   return 'success';
  // }

  void getCitiesList() async {
    String loginUrl = "${baseURL}city_list.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new [];
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr = "{" +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDP +
        "\"" +
        "," +
        "\"" +
        "StateIDP" +
        "\"" +
        ":" +
        "\"" +
        selectedState.idp +
        "\"" +
        "}";

    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);
    var response = await apiHelper.callApiWithHeadersAndBody(
      url: loginUrl,
      //Uri.parse(loginUrl),
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
    pr!.hide();
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      listCities = [];
      listCitiesSearchResults = [];
      listCities.add(DropDownItem("-", "All"));
      listCitiesSearchResults.add(DropDownItem("-", "All"));
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listCities.add(DropDownItem(jo['CityIDP'], jo['CityName']));
        listCitiesSearchResults
            .add(DropDownItem(jo['CityIDP'], jo['CityName']));
      }
      setState(() {});
    }
  }

  // Future<String> getNonBindedDoctors() async {
  //   var doctorNonBindedApiCalled = false;
  //   String loginUrl = "${baseURL}doctorPatientNotBinded.php";
  //   //listIcon = new [];
  //   String patientUniqueKey = await getPatientUniqueKey();
  //   String userType = await getUserType();
  //   debugPrint("Key and type");
  //   debugPrint(patientUniqueKey);
  //   debugPrint(userType);
  //   var cityIdp = "";
  //   if (cityIDF != "")
  //     cityIdp = cityIDF;
  //   else
  //     cityIdp = "-";
  //   String jsonStr = "{" + "\"" + "PatientIDP" + "\"" + ":" + "\"" + widget.patientIDP + "\"" + "," + "\"" + "CityIDP" + "\"" + ":" + "\"" + cityIdp + "\"" + "}";
  //
  //   debugPrint("Nonconnected Doctor API request object");
  //   debugPrint(jsonStr);
  //
  //   String encodedJSONStr = encodeBase64(jsonStr);
  //   var response = await apiHelper.callApiWithHeadersAndBody(
  //     url: loginUrl,
  //     //Uri.parse(loginUrl),
  //     headers: {
  //       "u": patientUniqueKey,
  //       "type": userType,
  //     },
  //     body: {"getjson": encodedJSONStr},
  //   );
  //   //var resBody = json.decode(response.body);
  //   debugPrint(response.body.toString());
  //   final jsonResponse1 = json.decode(response.body.toString());
  //   ResponseModel model = ResponseModel.fromJSON(jsonResponse1);
  //   if (model.status == "OK") {
  //     var data = jsonResponse1['Data'];
  //     var strData = decodeBase64(data);
  //     debugPrint("Decoded Data Array Dashboard : " + strData);
  //     final jsonData = json.decode(strData);
  //     if (jsonData.length > 0)
  //       doctorNonBindedApiCalled = true;
  //     else
  //       doctorNonBindedApiCalled = false;
  //     for (var i = 0; i < jsonData.length; i++) {
  //       var jo = jsonData[i];
  //       listDoctors.add({
  //         "DoctorIDP": jo['DoctorIDP'].toString(),
  //         "DoctorID": jo['DoctorID'].toString(),
  //         "FirstName": jo['FirstName'].toString(),
  //         "LastName": jo['LastName'].toString(),
  //         "MobileNo": jo['MobileNo'].toString(),
  //         "Specility": jo['Specility'].toString(),
  //         "DoctorImage": jo['DoctorImage'].toString(),
  //         "CityName": jo['CityName'].toString(),
  //         "BindedTag": jo['BindedTag'].toString(),
  //         "AvailableStatus": jo['AvailableStatus'].toString(),
  //         "AppointmentStatus": jo['AppointmentStatus'].toString(),
  //         "DueAmount": jo['DueAmount'].toString(),
  //         "BindStatus": jo['BindStatus'].toString(),
  //       });
  //       // listNonBindedDoctorsSearchResults.add({
  //       //   "DoctorIDP": jo['DoctorIDP'].toString(),
  //       //   "DoctorID": jo['DoctorID'].toString(),
  //       //   "FirstName": jo['FirstName'].toString(),
  //       //   "LastName": jo['LastName'].toString(),
  //       //   "MobileNo": jo['MobileNo'].toString(),
  //       //   "Specility": jo['Specility'].toString(),
  //       //   "DoctorImage": jo['DoctorImage'].toString(),
  //       //   "CityName": jo['CityName'].toString(),
  //       //   "BindedTag": jo['BindedTag'].toString(),
  //       //   "AvailableStatus": jo['AvailableStatus'].toString(),
  //       //   "AppointmentStatus": jo['AppointmentStatus'].toString(),
  //       //   "DueAmount": jo['DueAmount'].toString(),
  //       //   "BindStatus": jo['BindStatus'].toString(),
  //       // });
  //     }
  //     setState(() {});
  //   }
  // }

  void showCitySelectionDialog(List<DropDownItem> list, String type) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            CountryDialog(list, type, callbackFromCountryDialog));
  }

  void callbackFromCountryDialog(String type) {
    setState(() {
      if (type == "City") {
        //getDoctorsListFromCityIDF(selectedCity.idp);
        getPatientProfileDetails(selectedCity.idp);
      }
    });
  }

  // getDoctorsListFromCityIDF(String cityIdp) async {
  //   var apiCalled = false;
  //   ProgressDialog pr;
  //   try {
  //     Future.delayed(Duration.zero, () {
  //       pr = ProgressDialog(context);
  //       pr.show();
  //     });
  //     listNonBindedDoctors = [];
  //     listNonBindedDoctorsSearchResults = [];
  //     String loginUrl = "${baseURL}doctorPatientNotBinded.php";
  //     //listIcon = new [];
  //     String patientUniqueKey = await getPatientUniqueKey();
  //     String userType = await getUserType();
  //     debugPrint("Key and type");
  //     debugPrint(patientUniqueKey);
  //     debugPrint(userType);
  //     String jsonStr = "{" +
  //         "\"" +
  //         "PatientIDP" +
  //         "\"" +
  //         ":" +
  //         "\"" +
  //         widget.patientIDP +
  //         "\"" +
  //         "," +
  //         "\"" +
  //         "CityIDP" +
  //         "\"" +
  //         ":" +
  //         "\"" +
  //         cityIdp +
  //         "\"" +
  //         "}";
  //
  //     debugPrint("Doctor API request object");
  //     debugPrint(jsonStr);
  //
  //     String encodedJSONStr = encodeBase64(jsonStr);
  //     var response = await apiHelper.callApiWithHeadersAndBody(
  //       url: loginUrl,
  //       //Uri.parse(loginUrl),
  //       headers: {
  //         "u": patientUniqueKey,
  //         "type": userType,
  //       },
  //       body: {"getjson": encodedJSONStr},
  //     );
  //     //var resBody = json.decode(response.body);
  //     debugPrint(response.body.toString());
  //     final jsonResponse1 = json.decode(response.body.toString());
  //     ResponseModel model = ResponseModel.fromJSON(jsonResponse1);
  //     apiCalled = true;
  //     if (model.status == "OK") {
  //       var data = jsonResponse1['Data'];
  //       var strData = decodeBase64(data);
  //       debugPrint("Decoded Data Array Dashboard : " + strData);
  //       final jsonData = json.decode(strData);
  //       for (var i = 0; i < jsonData.length; i++) {
  //         var jo = jsonData[i];
  //         listNonBindedDoctors.add({
  //           "DoctorIDP": jo['DoctorIDP'].toString(),
  //           "DoctorID": jo['DoctorID'].toString(),
  //           "FirstName": jo['FirstName'].toString(),
  //           "LastName": jo['LastName'].toString(),
  //           "MobileNo": jo['MobileNo'].toString(),
  //           "Specility": jo['Specility'].toString(),
  //           "DoctorImage": jo['DoctorImage'].toString(),
  //           "CityName": jo['CityName'].toString(),
  //           "BindedTag": jo['BindedTag'].toString(),
  //           "DueAmount": jo['DueAmount'].toString(),
  //           "BindStatus": jo['BindStatus'].toString(),
  //         });
  //         listNonBindedDoctorsSearchResults.add({
  //           "DoctorIDP": jo['DoctorIDP'].toString(),
  //           "DoctorID": jo['DoctorID'].toString(),
  //           "FirstName": jo['FirstName'].toString(),
  //           "LastName": jo['LastName'].toString(),
  //           "MobileNo": jo['MobileNo'].toString(),
  //           "Specility": jo['Specility'].toString(),
  //           "DoctorImage": jo['DoctorImage'].toString(),
  //           "CityName": jo['CityName'].toString(),
  //           "BindedTag": jo['BindedTag'].toString(),
  //           "DueAmount": jo['DueAmount'].toString(),
  //           "BindStatus": jo['BindStatus'].toString(),
  //         });
  //       }
  //       pr.hide();
  //       setState(() {});
  //     }
  //   } catch (exception) {
  //     pr.hide();
  //   }
  // }

  void bindUnbindDoctor(Map<String, String> doctorData) async {
    //String loginUrl = "${baseURL}patientBindDoctor.php";
    String loginUrl = "${baseURL}patientBindRequesttoDoctor.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new [];
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr = "{" +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.patientIDP! +
        "\"" +
        "," +
        "\"" +
        "DoctorIDP" +
        "\"" +
        ":" +
        "\"" +
        doctorData["DoctorIDP"]! +
        "\"" +
        "}";

    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);
    var response = await apiHelper.callApiWithHeadersAndBody(
      url: loginUrl,
      //Uri.parse(loginUrl),
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
    pr!.hide();

    if (model.status == "OK") {
      /*final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(model.message),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);*/
      showBindRequestSentDialog(
        (doctorData["FirstName"]!.trim() + " " + doctorData["LastName"]!.trim())
            .trim(),
      );
    } else if (model.status == "ERROR") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void showBindRequestSentDialog(String patientName) {
    showDialog(
        context: context,
        barrierDismissible: false,
        // user must tap button for close dialog!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Request has been sent to $patientName to connect with you. You will be connected once doctor accepts your request.",
              style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! * 3.8,
                color: Colors.black,
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Okay",
                    style: TextStyle(
                      color: Colors.green,
                    ),
                  )),
            ],
          );
        });
  }

  isImageNotNullAndBlank1(int index) {
    isImageNotNullAndBlank(index)
        ? NetworkImage(
            "$doctorImgUrl${listDoctorsSearchResults[index]["DoctorImage"]}")
        : AssetImage("images/ic_user_placeholder.png");
  }

  void showDoctorIsNotAvailableDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        // user must tap button for close dialog!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Doctor not available for Appointment.",
              style: TextStyle(
                color: Colors.red,
                fontSize: SizeConfig.blockSizeHorizontal! * 4.1,
              ),
            ),
            actions: <Widget>[
              /*TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("No")),*/
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Ok"))
            ],
          );
        });
  }
}

class CountryDialog extends StatefulWidget {
  List<DropDownItem> list;
  String type;
  Function callbackFromCountryDialog;

  CountryDialog(this.list, this.type, this.callbackFromCountryDialog);

  @override
  State<StatefulWidget> createState() {
    return CountryDialogState();
  }
}

class CountryDialogState extends State<CountryDialog> {
  Icon? icon;

  Widget? titleWidget;

  @override
  void initState() {
    super.initState();
    icon = Icon(
      Icons.search,
      color: Colors.blue,
      size: SizeConfig.blockSizeHorizontal! * 6.2,
    );

    titleWidget = Text(
      "Select ${widget.type}",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: SizeConfig.blockSizeHorizontal! * 4.8,
        fontWeight: FontWeight.bold,
        color: Colors.green,
        decoration: TextDecoration.none,
      ),
    );
  }

  var searchController = TextEditingController();
  var focusNode = new FocusNode();

  void getCitiesList() async {
    String loginUrl = "${baseURL}city_list.php";
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr = "{" +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDP +
        "\"" +
        "," +
        "\"" +
        "StateIDP" +
        "\"" +
        ":" +
        "\"" +
        selectedState.idp +
        "\"" +
        "}";

    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);
    var response = await apiHelper.callApiWithHeadersAndBody(
      url: loginUrl,
      //Uri.parse(loginUrl),
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
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      listCities = [];
      listCitiesSearchResults = [];
      listCities.add(DropDownItem("-", "All"));
      listCitiesSearchResults.add(DropDownItem("-", "All"));
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listCities.add(DropDownItem(jo['CityIDP'], jo['CityName']));
        listCitiesSearchResults
            .add(DropDownItem(jo['CityIDP'], jo['CityName']));
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              height: SizeConfig.blockSizeVertical! * 8,
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.red,
                        size: SizeConfig.blockSizeHorizontal! * 6.2,
                      ),
                      onTap: () {
                        /*setState(() {
                          widget.type = "My type";
                        });*/
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal! * 6,
                    ),
                    Container(
                      width: SizeConfig.blockSizeHorizontal! * 50,
                      height: SizeConfig.blockSizeVertical! * 8,
                      child: Center(
                        child: titleWidget,
                      ),
                    ),
                    Expanded(
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal! * 1),
                            child: InkWell(
                              child: icon,
                              onTap: () {
                                setState(() {
                                  if (icon!.icon == Icons.search) {
                                    searchController =
                                        TextEditingController(text: "");
                                    focusNode.requestFocus();
                                    this.icon = Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                      size:
                                          SizeConfig.blockSizeHorizontal! * 6.2,
                                    );
                                    this.titleWidget = TextField(
                                      controller: searchController,
                                      focusNode: focusNode,
                                      cursorColor: Colors.black,
                                      onChanged: (text) {
                                        setState(() {
                                          if (widget.type == "City")
                                            widget.list =
                                                listCitiesSearchResults
                                                    .where((dropDownObj) =>
                                                        dropDownObj.value
                                                            .toLowerCase()
                                                            .contains(text
                                                                .toLowerCase()))
                                                    .toList();
                                        });
                                      },
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal! *
                                                4.0,
                                      ),
                                      decoration: InputDecoration(
                                        hintStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                SizeConfig.blockSizeVertical! *
                                                    2.1),
                                        labelStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                SizeConfig.blockSizeVertical! *
                                                    2.1),
                                        //hintStyle: TextStyle(color: Colors.grey),
                                        hintText: "Search ${widget.type}",
                                      ),
                                    );
                                  } else {
                                    this.icon = Icon(
                                      Icons.search,
                                      color: Colors.blue,
                                      size:
                                          SizeConfig.blockSizeHorizontal! * 6.2,
                                    );
                                    this.titleWidget = Text(
                                      "Select ${widget.type}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal! *
                                                4.8,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                        decoration: TextDecoration.none,
                                      ),
                                    );
                                    if (widget.type == "City")
                                      widget.list = listCities;
                                  }
                                });
                                //Navigator.of(context).pop();
                              },
                            ),
                          )),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: widget.list.length,
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return InkWell(
                        onTap: () {
                          if (widget.type == "City") {
                            selectedCity = widget.list[index];
                            cityController =
                                TextEditingController(text: selectedCity.value);
                            Navigator.of(context).pop();
                            //setState(() {});
                            widget.callbackFromCountryDialog(widget.type);
                          }
                        },
                        child: Padding(
                            padding: EdgeInsets.all(0.0),
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
                                    bottom: BorderSide(
                                        width: 2.0, color: Colors.grey),
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
                                    widget.list[index].value,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ))));
                  }),
            ),
          ],
        ));
  }
}
