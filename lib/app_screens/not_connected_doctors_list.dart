import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:silvertouch/app_screens/add_new_doctor.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/dropdown_item.dart';
import 'package:silvertouch/podo/model_investigation_list_doctor.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';
import 'package:silvertouch/widgets/extensions.dart';

import '../utils/color.dart';
import 'doctor_full_details_screen.dart';
import 'fullscreen_image.dart';

List<DropDownItem> listCities = [];
List<DropDownItem> listCitiesSearchResults = [];

DropDownItem selectedState = DropDownItem("", "");
DropDownItem selectedCity = DropDownItem("", "");
String cityName = "";

TextEditingController cityController = new TextEditingController();

class NotConnectedDoctorsListScreen extends StatefulWidget {
  String patientIDP = "";
  final String urlFetchPatientProfileDetails =
      "${baseURL}patientProfileData.php";

  NotConnectedDoctorsListScreen(String patientIDP) {
    this.patientIDP = patientIDP;
  }

  @override
  State<StatefulWidget> createState() {
    return NotConnectedDoctorsListScreenState();
  }
}

class NotConnectedDoctorsListScreenState
    extends State<NotConnectedDoctorsListScreen> {
  List<Map<String, String>> listDoctors = [];
  List<Map<String, String>> listDoctorsSearchResults = [];
  var cityIDF = "";
  var firstName = "";
  var lastName = "";
  var searchController = TextEditingController();
  var focusNode = new FocusNode();

  Icon icon = Icon(
    Icons.search,
    color: Colors.white,
  );
  Widget titleWidget = Text("Doctors");
  bool doctorApiCalled = false;
  bool apiCalled = false;

  @override
  void initState() {
    super.initState();
    cityName = "";
    getPatientProfileDetails();
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
                    color: Colorsblack,
                  );
                  this.titleWidget = TextField(
                    controller: searchController,
                    focusNode: focusNode,
                    cursorColor: Colors.white,
                    onChanged: (text) {
                      setState(() {
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
                      });
                    },
                    style: TextStyle(
                      color: Colorsblack,
                      fontSize: SizeConfig.blockSizeHorizontal! * 4.0,
                    ),
                    decoration: InputDecoration(
                      hintText: "Doc Name, Speciality or City",
                    ),
                  );
                } else {
                  this.icon = Icon(
                    Icons.search,
                    color: Colorsblack,
                  );
                  this.titleWidget = Text("My Doctors");
                  listDoctorsSearchResults = listDoctors;
                }
              });
            },
            icon: icon,
          ),
          /*IconButton(
            onPressed: () {
              showCitySelectionDialog(listCitiesSearchResults, "City");
            },
            icon: Image(
              image: AssetImage('images/ic_filter.png'),
              color: Colors.white,
              width: SizeConfig.blockSizeHorizontal * 5,
            ),
          )*/
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
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    showCitySelectionDialog(listCitiesSearchResults, "City");
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
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
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
                            fontSize: SizeConfig.blockSizeHorizontal! * 5.0,
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
                Expanded(
                  child: listDoctorsSearchResults.length > 0
                      ? ListView(
                          children: [
                            ListView.builder(
                                itemCount: listDoctorsSearchResults.length,
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      Get.to(() => DoctorFullDetailsScreen(
                                                listDoctorsSearchResults[index],
                                                widget.patientIDP,
                                                from: listDoctorsSearchResults[
                                                                index]
                                                            ['BindStatus'] ==
                                                        "1"
                                                    ? "doctorList"
                                                    : "appointmentList",
                                              ))!
                                          .then((value) {
                                        if (value != null && value == 1)
                                          getPatientProfileDetails();
                                      });
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border(
                                                bottom: BorderSide(
                                                    width: 1.0,
                                                    color: Colors.grey))),
                                        child: Padding(
                                            padding: EdgeInsets.all(SizeConfig
                                                    .blockSizeHorizontal! *
                                                3),
                                            child: Column(
                                              children: [
                                                Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: <Widget>[
                                                      InkWell(
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
                                                                  isImageNotNullAndBlank1(
                                                                      index))),
                                                      SizedBox(
                                                        width: SizeConfig
                                                                .blockSizeHorizontal! *
                                                            3,
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                    child:
                                                                        Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      (listDoctorsSearchResults[index]["FirstName"]!.trim() +
                                                                              " " +
                                                                              listDoctorsSearchResults[index]["LastName"]!.trim())
                                                                          .trim(),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            SizeConfig.blockSizeHorizontal! *
                                                                                4.2,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          SizeConfig.blockSizeVertical! *
                                                                              0.5,
                                                                    ),
                                                                    Text(
                                                                      listDoctorsSearchResults[index]
                                                                              [
                                                                              "Specility"]! +
                                                                          " - " +
                                                                          listDoctorsSearchResults[index]
                                                                              [
                                                                              "CityName"]!,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            SizeConfig.blockSizeHorizontal! *
                                                                                3.3,
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: SizeConfig
                                                                      .blockSizeVertical! *
                                                                  1.2,
                                                            ),
                                                            InkWell(
                                                                onTap: () {
                                                                  bindUnbindDoctor(
                                                                      listDoctorsSearchResults[
                                                                          index]);
                                                                },
                                                                child:
                                                                    Container(
                                                                        child:
                                                                            Row(
                                                                  children: [
                                                                    Image(
                                                                      image:
                                                                          AssetImage(
                                                                        "images/ic_imp_links.png",
                                                                      ),
                                                                      height:
                                                                          SizeConfig.blockSizeHorizontal! *
                                                                              6.0,
                                                                      width: SizeConfig
                                                                              .blockSizeHorizontal! *
                                                                          6.0,
                                                                    ).paddingOnly(
                                                                      right: SizeConfig
                                                                              .blockSizeHorizontal! *
                                                                          3.0,
                                                                    ),
                                                                    Text(
                                                                      "Connect to\nDoctor",
                                                                      //Make a\nPayment
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .blue,
                                                                          fontSize:
                                                                              SizeConfig.blockSizeHorizontal! * 3.6),
                                                                    ).expanded(),
                                                                  ],
                                                                ))),
                                                          ],
                                                        ),
                                                      ),
                                                    ]),
                                              ],
                                            ))),
                                  );
                                }),
                            Card(
                                margin: EdgeInsets.all(
                                  SizeConfig.blockSizeHorizontal! * 3.0,
                                ),
                                shadowColor: Colors.green,
                                elevation: 2,
                                borderOnForeground: true,
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    SizeConfig.blockSizeHorizontal! * 3.0,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          FaIcon(
                                            FontAwesomeIcons.questionCircle,
                                            color: Colors.red,
                                            size: SizeConfig
                                                    .blockSizeHorizontal! *
                                                6.5,
                                          ),
                                          SizedBox(
                                            width: SizeConfig
                                                    .blockSizeHorizontal! *
                                                3.0,
                                          ),
                                          Text(
                                            "Didn't find your Doctor?",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  3.8,
                                            ),
                                          ),
                                        ],
                                      ),
                                      MaterialButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return AddNewDoctor();
                                          }));
                                        },
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(60.0)),
                                        color: Colors.green,
                                        child: Text(
                                          "Refer Now",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )),
                          ],
                        )
                      : doctorApiCalled
                          ? Card(
                              margin: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal! * 3.0,
                              ),
                              shadowColor: Colors.red,
                              elevation: 2,
                              borderOnForeground: true,
                              child: Padding(
                                padding: EdgeInsets.all(
                                  SizeConfig.blockSizeHorizontal! * 3.0,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        FaIcon(
                                          FontAwesomeIcons.questionCircle,
                                          color: Colors.red,
                                          size:
                                              SizeConfig.blockSizeHorizontal! *
                                                  6.5,
                                        ),
                                        SizedBox(
                                          width:
                                              SizeConfig.blockSizeHorizontal! *
                                                  3.0,
                                        ),
                                        Text(
                                          "Didn't find your Doctor?",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                            fontSize: SizeConfig
                                                    .blockSizeHorizontal! *
                                                3.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                    MaterialButton(
                                      onPressed: () {},
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(60.0)),
                                      color: Colors.green,
                                      child: Text(
                                        "Refer Now",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          /*Align(
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Image(
                                    image: AssetImage(
                                        "images/ic_no_result_found.png"),
                                    width: 200,
                                    height: 200,
                                  ),
                                  SizedBox(
                                    height: 12.0,
                                  ),
                                  Expanded(child: Text(
                                    "No Doctors in this city.\nChange city from filter option.",
                                    style: TextStyle(fontSize: 18.0),
                                  ),),
                                ],
                              ),
                            )*/
                          : Center(
                              child: CircularProgressIndicator(),
                            ),
                ),
              ],
            ),
            onRefresh: () {
              return getDoctorsListFromCityIDF(selectedCity.idp);
            },
          );
        },
      ),
    );
  }

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
        getDoctorsListFromCityIDF(selectedCity.idp);
      }
    });
  }

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
    /*List<IconModel> listIcon;*/
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
      //listIcon = new [];
      var response = await apiHelper.callApiWithHeadersAndBody(
        url: widget.urlFetchPatientProfileDetails,
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
        debugPrint("Decoded Data Array : " + strData);
        final jsonData = json.decode(strData);
        cityIDF = jsonData[0]['CityIDF'];
        cityName = jsonData[0]['CityName'];
        firstName = jsonData[0]['FirstName'];
        lastName = jsonData[0]['LastName'];

        selectedCity =
            DropDownItem(jsonData[0]['CityIDF'], jsonData[0]['CityName']);
        selectedState =
            DropDownItem(jsonData[0]['StateIDF'], jsonData[0]['StateName']);
        getCitiesList();
        listDoctors = [];
        listDoctorsSearchResults = [];

        //getBindedDoctors();
        getNonBindedDoctors();
        pr.hide();
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
          listDoctorsSearchResults = [];
          String loginUrl = "${baseURL}doctorPatientNotBinded.php";
          //listIcon = new [];
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
              widget.patientIDP +
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
                "AvailableStatus": jo['AvailableStatus'].toString(),
                "AppointmentStatus": jo['AppointmentStatus'].toString(),
                "DueAmount": jo['DueAmount'].toString(),
                "BindStatus": jo['BindStatus'].toString(),
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
                "AvailableStatus": jo['AvailableStatus'].toString(),
                "AppointmentStatus": jo['AppointmentStatus'].toString(),
                "DueAmount": jo['DueAmount'].toString(),
                "BindStatus": jo['BindStatus'].toString(),
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

  getDoctorsListFromCityIDF(String cityIdp) async {
    apiCalled = false;
    ProgressDialog? pr;
    try {
      Future.delayed(Duration.zero, () {
        pr = ProgressDialog(context);
        pr!.show();
      });
      listDoctors = [];
      listDoctorsSearchResults = [];
      String loginUrl = "${baseURL}doctorPatientNotBinded.php";
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
          widget.patientIDP +
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
      pr!.hide();
      apiCalled = true;
      if (model.status == "OK") {
        var data = jsonResponse1['Data'];
        var strData = decodeBase64(data);
        debugPrint("Decoded Data Array Dashboard : " + strData);
        final jsonData = json.decode(strData);
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
            "DueAmount": jo['DueAmount'].toString(),
            "BindStatus": jo['BindStatus'].toString(),
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
            "DueAmount": jo['DueAmount'].toString(),
            "BindStatus": jo['BindStatus'].toString(),
          });
        }
        setState(() {});
      }
    } catch (exception) {
      pr!.hide();
    }
  }

  void bindUnbindDoctor(
      /*String bindFlag,*/
      Map<String, String> doctorData) async {
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
        widget.patientIDP +
        "\"" +
        "," +
        "\"" +
        "DoctorIDP" +
        "\"" +
        ":" +
        "\"" +
        doctorData["DoctorIDP"]! +
        "\"" +
        /*"," +
        "\"" +
        "FirstName" +
        "\"" +
        ":" +
        "\"" +
        firstName +
        "\"" +
        "," +
        "\"" +
        "LastName" +
        "\"" +
        ":" +
        "\"" +
        lastName +
        "\"" +
        "," +
        "\"" +
        "BindFlag" +
        "\"" +
        ":" +
        "\"" +
        bindFlag +
        "\"" +*/
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
      getPatientProfileDetails();
    } else if (model.status == "ERROR") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
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

  isImageNotNullAndBlank(int index) {
    return (listDoctorsSearchResults[index]["DoctorImage"] != "" &&
        listDoctorsSearchResults[index]["DoctorImage"] != null &&
        listDoctorsSearchResults[index]["DoctorImage"] != "null");
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

  Future<String?> getBindedDoctors() async {
    String loginUrl = "${baseURL}doctorList.php";
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
        widget.patientIDP +
        "\"" +
        "," +
        "\"" +
        "CityIDP" +
        "\"" +
        ":" +
        "\"" +
        cityIdp +
        "\"";

    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
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
          "AvailableStatus": jo['AvailableStatus'].toString(),
          "AppointmentStatus": jo['AppointmentStatus'].toString(),
          "DueAmount": jo['DueAmount'].toString(),
          "BindStatus": jo['BindStatus'].toString(),
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
          "AvailableStatus": jo['AvailableStatus'].toString(),
          "AppointmentStatus": jo['AppointmentStatus'].toString(),
          "DueAmount": jo['DueAmount'].toString(),
          "BindStatus": jo['BindStatus'].toString(),
        });
      }
    }
    return null;
  }

  Future<String?> getNonBindedDoctors() async {
    String loginUrl = "${baseURL}doctorPatientNotBinded.php";
    //listIcon = new [];
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
        widget.patientIDP +
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
          "AvailableStatus": jo['AvailableStatus'].toString(),
          "AppointmentStatus": jo['AppointmentStatus'].toString(),
          "DueAmount": jo['DueAmount'].toString(),
          "BindStatus": jo['BindStatus'].toString(),
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
          "AvailableStatus": jo['AvailableStatus'].toString(),
          "AppointmentStatus": jo['AppointmentStatus'].toString(),
          "DueAmount": jo['DueAmount'].toString(),
          "BindStatus": jo['BindStatus'].toString(),
        });
      }
      setState(() {});
    }
    return null;
  }

  isImageNotNullAndBlank1(int index) {
    isImageNotNullAndBlank(index)
        ? NetworkImage(
            "$doctorImgUrl${listDoctorsSearchResults[index]["DoctorImage"]}")
        : AssetImage("images/ic_user_placeholder.png");
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
