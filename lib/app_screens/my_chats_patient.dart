import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:silvertouch/app_screens/chat_screen.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_investigation_list_doctor.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';
import '../utils/color.dart';
import 'fullscreen_image.dart';

class MyChats extends StatefulWidget {
  String? patientIDP = "";
  final String urlFetchPatientProfileDetails =
      "${baseURL}doctorPatientChatList.php";

  String emptyTextMyDoctors1 =
      "Ask your Doctor to send you bind request from Silver Touch Doctor panel so that you can able to share all your Health records to your prefered doctor.";

  String emptyMessage = "";

  Widget? emptyMessageWidget;

  MyChats(String patientIDP) {
    this.patientIDP = patientIDP;
  }

  @override
  State<StatefulWidget> createState() {
    return MyChatsState();
  }
}

class MyChatsState extends State<MyChats> {
  List<Map<String, String>> listDoctors = [];
  List<Map<String, String>> listDoctorsSearchResults = [];
  var cityIDF = "";
  var firstName = "";
  var lastName = "";
  var searchController = TextEditingController();
  var focusNode = new FocusNode();
  String userType = "";
  String toolbarTitle = "";

  Icon icon = Icon(
    Icons.search,
    color: Colors.white,
  );
  Widget? titleWidget;

  @override
  void initState() {
    super.initState();
    getUserType().then((value) {
      userType = value;
      if (userType == "patient") toolbarTitle = "Ask Doctor";
      if (userType == "doctor") toolbarTitle = "Chat with Patient";
      titleWidget = Text(toolbarTitle, style: TextStyle(color: Colorsblack));
    });
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
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
    getPatientProfileDetails();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: titleWidget,
        centerTitle: true,
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
                      color: Colors.white,
                      fontSize: SizeConfig.blockSizeHorizontal! * 4.0,
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
                  this.titleWidget =
                      Text(toolbarTitle, style: TextStyle(color: Colorsblack));
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
                ? Container(
                    color: Color(0xFFDCDCDC),
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: ListView.builder(
                              itemCount: listDoctorsSearchResults.length,
                              shrinkWrap: true,
                              physics: ScrollPhysics(),
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    String patientIDP =
                                        listDoctorsSearchResults[index]
                                            ["DoctorIDP"]!;
                                    //"FirstName": jo['FirstName'].toString(),
                                    //              "LastName": jo['LastName'].toString(),
                                    String patientName =
                                        (listDoctorsSearchResults[index]
                                                        ["FirstName"]!
                                                    .trim() +
                                                " " +
                                                listDoctorsSearchResults[index]
                                                        ["LastName"]!
                                                    .trim())
                                            .replaceAll("  ", " ");
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return ChatScreen(
                                        patientIDP: patientIDP,
                                        patientName: patientName,
                                        patientImage:
                                            listDoctorsSearchResults[index]
                                                ["DoctorImage"],
                                      );
                                    })).then((value) {
                                      getPatientProfileDetails();
                                    });
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: listDoctorsSearchResults[index]
                                                      ["BindedTag"] ==
                                                  "1"
                                              ? Colors.white
                                              : Colors.white,
                                          border: Border(
                                              bottom: BorderSide(
                                                  width: 1.0,
                                                  color: Colors.grey))),
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                            SizeConfig.blockSizeHorizontal! *
                                                4),
                                        child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              InkWell(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) {
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
                                                child: Hero(
                                                  tag:
                                                      "fullImg_$doctorImgUrl${listDoctorsSearchResults[index]["DoctorImage"]}_${listDoctorsSearchResults[index]['DoctorIDP']}",
                                                  child: CircleAvatar(
                                                      radius: SizeConfig
                                                              .blockSizeHorizontal! *
                                                          6,
                                                      backgroundImage:
                                                          ifImageNotNullAndBlank1(
                                                              index)),
                                                ),
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
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    (listDoctorsSearchResults[
                                                                        index][
                                                                    "FirstName"]!
                                                                .trim() +
                                                            " " +
                                                            listDoctorsSearchResults[
                                                                        index][
                                                                    "LastName"]!
                                                                .trim())
                                                        .trim(),
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      fontSize: SizeConfig
                                                              .blockSizeHorizontal! *
                                                          4.2,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: listDoctorsSearchResults[
                                                                      index][
                                                                  "BindedTag"] ==
                                                              "1"
                                                          ? Colors.black
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: SizeConfig
                                                            .blockSizeVertical! *
                                                        0.5,
                                                  ),
                                                  Text(
                                                    listDoctorsSearchResults[
                                                                index]
                                                            ["Specility"]! +
                                                        " - " +
                                                        listDoctorsSearchResults[
                                                            index]["CityName"]!,
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      fontSize: SizeConfig
                                                              .blockSizeHorizontal! *
                                                          3.3,
                                                      color: listDoctorsSearchResults[
                                                                      index][
                                                                  "BindedTag"] ==
                                                              "1"
                                                          ? Colors.grey
                                                          : Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Expanded(
                                                child: Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        listDoctorsSearchResults[
                                                                            index]
                                                                        [
                                                                        "TotalCount"] !=
                                                                    "" &&
                                                                listDoctorsSearchResults[
                                                                            index]
                                                                        [
                                                                        "TotalCount"] !=
                                                                    "0"
                                                            ? Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                  SizeConfig
                                                                          .blockSizeHorizontal! *
                                                                      1.0,
                                                                ),
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: Colors
                                                                        .green),
                                                                child: Text(
                                                                  listDoctorsSearchResults[
                                                                          index]
                                                                      [
                                                                      "TotalCount"]!,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        SizeConfig.blockSizeHorizontal! *
                                                                            4.0,
                                                                  ),
                                                                ),
                                                              )
                                                            : Container(),
                                                      ],
                                                    )),
                                              )
                                            ]),
                                      )),
                                );
                              }),
                        ),
                        /*Container(
                          height: SizeConfig.blockSizeVertical * 15,
                          width: SizeConfig.blockSizeHorizontal * 100,
                          color: Colors.blueGrey,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                  width: SizeConfig.blockSizeHorizontal * 3),
                              Icon(
                                Icons.warning,
                                color: Colors.white,
                                size: SizeConfig.blockSizeHorizontal * 8,
                              ),
                              SizedBox(
                                  width: SizeConfig.blockSizeHorizontal * 3),
                              SizedBox(
                                  width: SizeConfig.blockSizeHorizontal * 82,
                                  child: Text(
                                    "You can un-bind any doctor by selecting minus sign beside the doctor name. \nOnce unbinded you need to contact doctor to send bind request.",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal *
                                                3.6),
                                  )),
                            ],
                          )),*/
                      ],
                    ))
                : Center(
                    child: widget.emptyMessageWidget,
                  ),
            /*Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image(
                          image: AssetImage("images/ic_no_result_found.png"),
                          width: 200,
                          height: 200,
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        Text(
                          "No Doctors Added.",
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ],
                    ),
                  )*/
            onRefresh: () {
              return getPatientProfileDetails();
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

  ifImageNotNullAndBlank1(int index) {
    isImageNotNullAndBlank(index)
        ? NetworkImage(userType == "patient"
            ? "$doctorImgUrl${listDoctorsSearchResults[index]["DoctorImage"]}"
            : "$userImgUrl${listDoctorsSearchResults[index]["DoctorImage"]}")
        : AssetImage("images/ic_user_placeholder.png");
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

  Future<String> getPatientProfileDetails() async {
    ProgressDialog pr = ProgressDialog(context);
    Future.delayed(Duration.zero, () {
      pr.show();
    });

    try {
      String patientUniqueKey = await getPatientUniqueKey();
      String userType = await getUserType();
      String patientIDP = await getPatientOrDoctorIDP();
      debugPrint("Key and type");
      debugPrint(patientUniqueKey);
      debugPrint(userType);
      String patientIDPValue = "";
      String doctorIDPValue = "";
      String fromType = "";

      if (userType == "patient") {
        patientIDPValue = patientIDP;
        doctorIDPValue = /*widget.patientIDP*/ "";
        fromType = "P";
      } else if (userType == "doctor") {
        patientIDPValue = /*widget.patientIDP*/ "";
        doctorIDPValue = patientIDP;
        fromType = "D";
      }
      String jsonStr = "{" +
          "\"PatientIDP\":\"$patientIDPValue\"" +
          ",\"DoctorIDP\":\"$doctorIDPValue\"" +
          ",\"FromType\":\"$fromType\"" +
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
      pr.hide();
      if (model.status == "OK") {
        var data = jsonResponse['Data'];
        var strData = decodeBase64(data);
        debugPrint("Decoded Data Array : " + strData);
        final jsonData = json.decode(strData);

        listDoctors = [];
        listDoctorsSearchResults = [];

        for (var i = 0; i < jsonData.length; i++) {
          var jo = jsonData[i];
          listDoctors.add({
            "DoctorIDP": jo['IDP'].toString(),
            "DoctorID": "",
            "FirstName": jo['FirstName'].toString(),
            "LastName": jo['LastName'].toString(),
            "MobileNo": "",
            "Specility": "",
            "DoctorImage": jo['Photo'].toString(),
            "CityName": "",
            "TotalCount": jo['TotalCount'].toString(),
          });
          listDoctorsSearchResults.add({
            "DoctorIDP": jo['IDP'].toString(),
            "DoctorID": "",
            "FirstName": jo['FirstName'].toString(),
            "LastName": jo['LastName'].toString(),
            "MobileNo": "",
            "Specility": "",
            "DoctorImage": jo['Photo'].toString(),
            "CityName": "",
            "TotalCount": jo['TotalCount'].toString(),
          });
        }
        setState(() {});
      } else {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text(model.message!),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (exception) {}

    return 'success';
  }
}
