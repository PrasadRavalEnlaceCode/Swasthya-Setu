import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swasthyasetu/app_screens/doctor_full_details_screen.dart';
import 'package:swasthyasetu/app_screens/laboratory_full_details_screen.dart';
import 'package:swasthyasetu/app_screens/provider_detail.dart';
import 'package:swasthyasetu/app_screens/provider_favourite_screen.dart';
import 'package:swasthyasetu/app_screens/provider_order_screen.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import '../podo/dropdown_item.dart';
import '../utils/color.dart';
import '../utils/progress_dialog.dart';
import 'fullscreen_image.dart';
import 'not_connected_doctors_list.dart';

List<DropDownItem> listCities = [];
List<DropDownItem> listCitiesSearchResults = [];

DropDownItem selectedState = DropDownItem("", "");
DropDownItem selectedCity = DropDownItem("", "");
String cityName = "";

TextEditingController cityController = new TextEditingController();

class OrderBloodListScreen extends StatefulWidget {
  String? patientIDP = "";
  final String urlFetchPatientProfileDetails =
      "${baseURL}patientProfileData.php";

  final String urlSaveRemoveFavouriteDetails =
      "${baseURL}patient_wishlist_save.php";

  String emptyTextMyDoctors1 =
      "Please wait";

  String emptyMessage = "There are no blood test Avaible";

  // Widget? emptyMessageWidget;

  OrderBloodListScreen(String patientIDP) {
    this.patientIDP = patientIDP;
  }

  @override
  State<StatefulWidget> createState() {
    return OrderBloodListScreenState();
  }
}

class OrderBloodListScreenState extends State<OrderBloodListScreen> {
  List<Map<String, String>> listDoctors = [];
  List<Map<String, String>> listDoctorsSearchResults = [];
  String cityIDF = "";
  String firstName = "";
  String lastName = "";

  var searchController = TextEditingController();
  var focusNode = new FocusNode();
  // var isFABVisible = true;
  bool doctorApiCalled = false;
  bool apiCalled = false;

  Icon icon = Icon(
    Icons.search,
    color: Colors.black,
  );
  Widget titleWidget = Text("Laboratory");

  // ScrollController hideFABController;

  @override
  void initState() {
    super.initState();
    cityName = "";
    // widget.emptyMessage = "${widget.emptyTextMyDoctors1}";
    //  SizedBox(
    //   height: SizeConfig.blockSizeVertical !* 80,
    //   child: Container(
    //     padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 5),
    //     child: Center(
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //         children: <Widget>[
    //           Image(
    //             image: AssetImage("images/ic_idea_new.png"),
    //             width: 100,
    //             height: 100,
    //           ),
    //           SizedBox(
    //             height: 30.0,
    //           ),
    //           Text(
    //             "${widget.emptyMessage}",
    //             style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
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
    getPatientProfileDetails("");
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: titleWidget,
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(
            color: Colorsblack, size: SizeConfig.blockSizeVertical !* 2.5),
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
                          objDoctor["FirstName"]
                              !.toLowerCase()
                              .contains(text.toLowerCase()) ||
                              objDoctor["LastName"]
                                  !.toLowerCase()
                                  .contains(text.toLowerCase()) ||
                              objDoctor["Specility"]
                                  !.toLowerCase()
                                  .contains(text.toLowerCase()) ||
                              objDoctor["CityName"]
                                  !.toLowerCase()
                                  .contains(text.toLowerCase()))
                              .toList();
                        else
                          listDoctorsSearchResults = [];
                      });
                    },
                    style: TextStyle(
                      color: Colorsblack,
                      fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
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
                      hintText: "Provider Name, Speciality or City",
                    ),
                  );
                } else {
                  this.icon = Icon(
                    Icons.search,
                    color: Colors.black,
                  );
                  this.titleWidget = titleWidget;
                  listDoctorsSearchResults = listDoctors;
                }
              });
            },
            icon: icon,
          ),
        ], toolbarTextStyle: TextTheme(
          titleLarge: TextStyle(
              color: Colorsblack,
              fontFamily: "Ubuntu",
              fontSize: SizeConfig.blockSizeVertical !* 2.5)).bodyMedium,
        titleTextStyle: TextTheme(
            titleLarge: TextStyle(
                color: Colorsblack,
                fontFamily: "Ubuntu",
                fontSize: SizeConfig.blockSizeVertical !* 2.5)).titleLarge,
      ),
      body: Builder(
        builder: (context) {
          return
            Column(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    showCitySelectionDialog(listCitiesSearchResults, "City");
                  },
                  child: Container(
                    margin: EdgeInsets.all(
                      SizeConfig.blockSizeHorizontal !* 3.0,
                    ),
                    padding: EdgeInsets.all(
                      SizeConfig.blockSizeHorizontal !* 3.0,
                    ),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    child:
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: AssetImage("images/ic_city.png"),
                          color: Colors.blue,
                          width: SizeConfig.blockSizeHorizontal !* 6.0,
                          height: SizeConfig.blockSizeHorizontal !* 6.0,
                        ),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal !* 3.0,
                        ),
                        Text(
                          selectedCity.value,
                          style: TextStyle(
                            fontSize: SizeConfig.blockSizeHorizontal !* 5.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey,
                          size: SizeConfig.blockSizeHorizontal !* 6.0,
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                      itemCount: listDoctorsSearchResults.length,
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Get.to(() => ProviderDetailsScreen(
                              listDoctorsSearchResults[index],
                              widget.patientIDP!,
                            ))!.then((value) {
                              if (value != null && value == 1)
                                getPatientProfileDetails("");
                            });
                          },
                          child: Container(
                              child: Padding(
                                  padding: EdgeInsets.all(
                                      SizeConfig.blockSizeHorizontal !* 2),
                                  child: Column(
                                    children: [
                                      Row(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            InkWell(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
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
                                              child:  isImageNotNullAndBlank(index) ?
                                                CircleAvatar(radius: SizeConfig
                                                      .blockSizeHorizontal !*
                                                      6,
                                                  backgroundImage: NetworkImage(
                                                      "$doctorImgUrl${listDoctorsSearchResults[index]["DoctorImage"]}")) :
                                              CircleAvatar(
                                                radius: 20,
                                                child: Icon(Icons.storefront_sharp,size: 20,),
                                              ),
                                            ),
                                            SizedBox(
                                              width: SizeConfig
                                                  .blockSizeHorizontal !*
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
                                                      .blockSizeHorizontal !*
                                                      70,
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          (listDoctorsSearchResults[index]["ProviderCompanyName"]
                                                              !.trim())
                                                              .trim(),
                                                          textAlign:
                                                          TextAlign
                                                              .left,
                                                          style:
                                                          TextStyle(
                                                            fontSize:
                                                            SizeConfig
                                                                .blockSizeHorizontal !*
                                                                4.2,
                                                            fontWeight:
                                                            FontWeight
                                                                .w500,
                                                            color: Colors
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
                                                      .blockSizeVertical !*
                                                      0.5,
                                                ),
                                                Text(
                                                  listDoctorsSearchResults[index]
                                                  ["ProviderArea"]!,
                                                  textAlign:
                                                  TextAlign.left,
                                                  style: TextStyle(
                                                    fontSize: SizeConfig
                                                        .blockSizeHorizontal !*
                                                        3.3,
                                                    color: Colors.grey,
                                                    letterSpacing: 1.3,
                                                  ),
                                                ),
                                                Text(listDoctorsSearchResults[index]["CityName"]!,
                                                  textAlign:
                                                  TextAlign.left,
                                                  style: TextStyle(
                                                    fontSize: SizeConfig
                                                        .blockSizeHorizontal !*
                                                        3.3,
                                                    color: Colors.grey,
                                                    letterSpacing: 1.3,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            InkWell(
                                              onTap: (){
                                                String? healthcareProviderIDP = listDoctorsSearchResults[index]['HealthCareProviderIDP'];
                                                if(listDoctorsSearchResults[index]['IsFavourite']=="0")
                                                {
                                                  // save
                                                  saveRemovePatientFavouriteDetails(healthcareProviderIDP,"0");
                                                }
                                                else
                                                {
                                                  // remove
                                                  saveRemovePatientFavouriteDetails(healthcareProviderIDP,"1");
                                                }
                                              },
                                              child:
                                              listDoctorsSearchResults[index]['IsFavourite']=="0" ?
                                              Icon(
                                                Icons.star_border,
                                                color: Colors.blue,
                                                size: 30.0,
                                                semanticLabel: 'Add to Favourite',
                                              ) :
                                              Icon(
                                                Icons.star_outlined,
                                                color: Colors.blue,
                                                size: 30.0,
                                                semanticLabel: 'Add to Favourite',
                                              ),
                                            ),
                                          ]),
                                      SizedBox(
                                        height:
                                        SizeConfig.blockSizeVertical !*
                                            0.5,
                                      ),
                                      Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: SizeConfig
                                                  .blockSizeHorizontal !*
                                                  12,
                                            ),
                                            child: Row(
                                              mainAxisSize:
                                              MainAxisSize.min,
                                              children: [
                                                InkWell(
                                                    onTap: () {
                                                      String patientIDP =
                                                      listDoctorsSearchResults[index]['HealthCareProviderIDP']!;
                                                      String patientName = listDoctorsSearchResults[
                                                      index]
                                                      ['ProviderCompanyName']
                                                          !.trim() +
                                                          " " +
                                                          listDoctorsSearchResults[
                                                          index]
                                                          [
                                                          'ProviderArea']
                                                              !.trim();
                                                      String doctorImage =
                                                          "$doctorImgUrl${listDoctorsSearchResults[index]["ProviderLogo"]}";
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
                                                      //     .then((value) {
                                                      //   getPatientProfileDetails("");
                                                      // });
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Image(
                                                          image: AssetImage(
                                                              "images/ic_ask_to_doctor_filled.png"),
                                                          width: SizeConfig
                                                              .blockSizeHorizontal !*
                                                              4.5,
                                                          height: SizeConfig
                                                              .blockSizeHorizontal !*
                                                              4.5,
                                                        ),
                                                        SizedBox(
                                                          width: SizeConfig
                                                              .blockSizeHorizontal !*
                                                              1.0,
                                                        ),
                                                        Text(
                                                          "Message",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .green[
                                                              700]),
                                                        )
                                                      ],
                                                    )),
                                                SizedBox(
                                                  width: SizeConfig
                                                      .blockSizeHorizontal !*
                                                      5.0,
                                                ),
                                                InkWell(
                                                    onTap: () {
                                                      print('Index ${listDoctorsSearchResults[index]}');
                                                      print('ID ${widget.patientIDP!}');
                                                      Get.to(() =>
                                                          ProviderDetailsScreen(
                                                            listDoctorsSearchResults[
                                                            index], widget
                                                                .patientIDP!,
                                                          ))!.then((value) {
                                                        if (value !=
                                                            null &&
                                                            value == 1)
                                                          getPatientProfileDetails("");
                                                      });
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Image(
                                                          image: AssetImage(
                                                              "images/ic_my_profile_footer.png"),
                                                          width: SizeConfig
                                                              .blockSizeHorizontal !*
                                                              4.5,
                                                          height: SizeConfig
                                                              .blockSizeHorizontal !*
                                                              4.5,
                                                        ),
                                                        SizedBox(
                                                          width: SizeConfig
                                                              .blockSizeHorizontal !*
                                                              1.0,
                                                        ),
                                                        Text(
                                                          "View Profile",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .blue[
                                                              700]),
                                                        )
                                                      ],
                                                    )),
                                              ],
                                            ),
                                          )),
                                      Container(
                                        color: Colors.grey,
                                        height: 0.5,
                                      )
                                          .paddingSymmetric(
                                          horizontal: SizeConfig
                                              .blockSizeHorizontal !*
                                              2)
                                          .paddingOnly(
                                        top: SizeConfig
                                            .blockSizeVertical !*
                                            1.8,
                                      )
                                    ],
                                  ))),
                        );
                      }),
                ),
                InkWell(
                  onTap: () {

                  },
                  child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:
                    [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Get.to(() => ProviderFavouriteScreen(
                              widget.patientIDP!,
                              'radiology'
                            ))?.then((value) {
                              getPatientProfileDetails("");
                            });
                          },
                          child:
                          Card(
                            elevation: 0,
                            shadowColor: Colors.grey,
                            color: colorBlueDark,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(
                                        10.0) //                 <--- border radius here
                                ),
                                side: BorderSide(
                                    color: colorBlueDark, width: 1.5)),
                            margin: EdgeInsets.only(
                              left: SizeConfig.blockSizeHorizontal !* 3.0,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal !* 3.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(
                                    image: AssetImage(
                                      "images/ic_favourite.png",
                                    ),
                                    height:
                                    SizeConfig.blockSizeHorizontal !* 7,
                                    width:
                                    SizeConfig.blockSizeHorizontal !* 7,
                                  ),
                                  SizedBox(
                                    width: SizeConfig.blockSizeHorizontal !*
                                        2.0,
                                  ),
                                  Text(
                                    "My Favourite",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: colorWhite),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder:
                                        (context) {
                                      return ProviderOrderScreen(
                                          widget.patientIDP!
                                      );
                                    }));
                          },
                          child:
                          Card(
                            elevation: 0,
                            shadowColor: Colors.grey,
                            color: colorBlueDark,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(
                                        10.0) //                 <--- border radius here
                                ),
                                side: BorderSide(
                                    color: colorBlueDark, width: 1.5)),
                            margin: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal !* 3.0
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal !* 3.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(
                                    image: AssetImage(
                                      "images/ic_order.png",
                                    ),
                                    height:
                                    SizeConfig.blockSizeHorizontal !* 7,
                                    width:
                                    SizeConfig.blockSizeHorizontal !* 7,
                                  ),
                                  SizedBox(
                                    width: SizeConfig.blockSizeHorizontal !*
                                        2.0,
                                  ),
                                  Expanded(
                                    child: Text(
                                      "My Order",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: colorWhite),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
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
        //getDoctorsListFromCityIDF(selectedCity.idp);
        getPatientProfileDetails(selectedCity.idp);
      }
    });
  }

  isImageNotNullAndBlank(int index) {
    return (listDoctorsSearchResults[index]["ProviderLogo"] != "" &&
        listDoctorsSearchResults[index]["ProviderLogo"] != null &&
        listDoctorsSearchResults[index]["ProviderLogo"] != "null");
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
        (cityidp.length>0)
            ? cityIDF = cityidp : cityIDF = jsonData[0]['CityIDF'];
        // cityIDF = jsonData[0]['CityIDF'];
        // cityName = jsonData[0]['CityName'];
        firstName = jsonData[0]['FirstName'];
        lastName = jsonData[0]['LastName'];

        selectedCity =
            DropDownItem(jsonData[0]['CityIDF'], jsonData[0]['CityName']);
        selectedState =
            DropDownItem(jsonData[0]['StateIDF'], jsonData[0]['StateName']);
        getCitiesList();
        listDoctors = [];
        listDoctorsSearchResults = [];
        String loginUrl = "${baseURL}provider_list.php";
        //listIcon = new List();
        String patientUniqueKey = await getPatientUniqueKey();
        String userType = await getUserType();
        debugPrint("Key and type");
        debugPrint(patientUniqueKey);
        debugPrint(userType);
        var cityIdp = "";
        if (cityIDF != "")
          cityIdp = cityIDF;
         else cityIdp = "-";
        String jsonStr = "{" +
            "\"" +
            "ProviderType" +
            "\"" +
            ":" +
            "\"" +
            "radiology" +
            "\"" +
            "," +
            "\"" +
            "CityIDF" +
            "\"" +
            ":" +
            "\"" +
            cityIDF +
            "\"" +
            "," +
            "\"" +
            "UserIDP" +
            "\"" +
            ":" +
            "\"" +
            widget.patientIDP! +
            "\"" +
            "}";

        debugPrint("ProviderList API request object");
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
        //  pr.hide();

        if (model.status == "OK") {
          var data = jsonResponse1['Data'];
          var strData = decodeBase64(data);
          if (jsonResponse1["Data"] == "W10="){
            cityIDF = selectedCity.toString();

            debugPrint(cityIDF);
            // SizedBox(
            //   height: SizeConfig.blockSizeVertical !* 80,
            //   child: Container(
            //     padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 5),
            //     child: Center(
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.center,
            //         children: <Widget>[
            //           Image(
            //             image: AssetImage("images/ic_idea_new.png"),
            //             width: 100,
            //             height: 100,
            //           ),
            //           SizedBox(
            //             height: 30.0,
            //           ),
            //           Text(
            //             "${widget.emptyMessage}",
            //             style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // );
          }
          else{
          debugPrint("Decoded Data Array Dashboard : " + strData);
          final jsonData = json.decode(strData);
          if (jsonData.length > 0)
            doctorApiCalled = true;
          else
            doctorApiCalled = false;
          for (var i = 0; i < jsonData.length; i++) {
            var jo = jsonData[i];
            listDoctors.add({
              "HealthCareProviderIDP": jo['HealthCareProviderIDP'].toString(),
              "ProviderCompanyName": jo['ProviderCompanyName'].toString(),
              "DisplayName": jo['DisplayName'].toString(),
              "ProviderArea": jo['ProviderArea'].toString(),
              "ProviderLogo": jo['ProviderLogo'].toString(),
              "CityName": jo['CityName'].toString(),
              "IsFavourite": jo['IsFavourite'].toString()
            });
            listDoctorsSearchResults.add({
              "HealthCareProviderIDP": jo['HealthCareProviderIDP'].toString(),
              "ProviderCompanyName": jo['ProviderCompanyName'].toString(),
              "DisplayName": jo['DisplayName'].toString(),
              "ProviderArea": jo['ProviderArea'].toString(),
              "ProviderLogo": jo['ProviderLogo'].toString(),
              "CityName": jo['CityName'].toString(),
              "IsFavourite": jo['IsFavourite'].toString()
            });
          }
          pr.hide();
          setState(() {});
        }}
        //setState(() {});
      } else {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text(model.message!),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (exception) {
      print("Exception: $exception");
      if (!doctorApiCalled) {
        try {
          listDoctors = [];
          listDoctorsSearchResults = [];
          String loginUrl = "${baseURL}provider_list.php";
          //listIcon = new List();
          var cityIdp = "";
          if (cityIDF != "") cityIdp = cityIDF;
          else cityIdp = "-";
          String jsonStr = "{" +
              "\"" +
              "ProviderType" +
              "\"" +
              ":" +
              "\"" +
              "radiology" +
              "\"" +
              "," +
              "\"" +
              "CityIDF" +
              "\"" +
              ":" +
              "\"" +
              cityIDF +
              "\"" +
              "," +
              "\"" +
              "UserIDP" +
              "\"" +
              ":" +
              "\"" +
              widget.patientIDP! +
              "\"" +
              "}";

          debugPrint("ProviderList API request object");
          debugPrint(jsonStr);
          String patientUniqueKey = await getPatientUniqueKey();
          String userType = await getUserType();
          debugPrint("Key and type");
          debugPrint(patientUniqueKey);
          debugPrint(userType);
          String encodedJSONStr = encodeBase64(jsonStr);
          debugPrint(encodedJSONStr);
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
          // debugPrint(response.headers.toString());
          debugPrint(response.body.toString());
          final jsonResponse1 = json.decode(response.body.toString());
          ResponseModel model = ResponseModel.fromJSON(jsonResponse1);
          // pr.hide();
          if (model.status == "OK")
          {
            var data = jsonResponse1['Data'];
            var strData = decodeBase64(data);
            if (jsonResponse1["Data"] == "W10="){
              cityIDF = selectedCity.toString();
              // SizedBox(
              //   height: SizeConfig.blockSizeVertical !* 80,
              //   child: Container(
              //     padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 5),
              //     child: Center(
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.center,
              //         children: <Widget>[
              //           Image(
              //             image: AssetImage("images/ic_idea_new.png"),
              //             width: 100,
              //             height: 100,
              //           ),
              //           SizedBox(
              //             height: 30.0,
              //           ),
              //           Text(
              //             "${widget.emptyMessage}",
              //             style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // );
            }
            else{
            debugPrint("Decoded Data Array Dashboard : " + strData);
            final jsonData = json.decode(strData);
            if (jsonData.length > 0)
              doctorApiCalled = true;
            else
              doctorApiCalled = false;
            for (var i = 0; i < jsonData.length; i++)
            {
              var jo = jsonData[i];
              listDoctors.add({
                "HealthCareProviderIDP": jo['HealthCareProviderIDP'].toString(),
                "ProviderCompanyName": jo['ProviderCompanyName'].toString(),
                "DisplayName": jo['DisplayName'].toString(),
                "ProviderArea": jo['ProviderArea'].toString(),
                "ProviderLogo": jo['ProviderLogo'].toString(),
                "CityName": jo['CityName'].toString(),
                "IsFavourite": jo['IsFavourite'].toString()
              });
              listDoctorsSearchResults.add({
                "HealthCareProviderIDP": jo['HealthCareProviderIDP'].toString(),
                "ProviderCompanyName": jo['ProviderCompanyName'].toString(),
                "DisplayName": jo['DisplayName'].toString(),
                "ProviderArea": jo['ProviderArea'].toString(),
                "ProviderLogo": jo['ProviderLogo'].toString(),
                "CityName": jo['CityName'].toString(),
                "IsFavourite": jo['IsFavourite'].toString()
              });
            }
            setState(() {});
          }}
        } catch (exception) {
          pr.hide();
        }
      } else {
        pr.hide();
      }
    }
    return 'success';
  }

  void saveRemoveFavourite(
      String healthCareProviderIDP,String mUpdateType) async {
    print('saveRemoveFavourite');
    String loginUrl = "${baseURL}patient_wishlist_save.php";
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
        "UserIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDP +
        "\"" +
        "," +
        "\"" +
        "HealthcareProviderIDP" +
        "\"" +
        ":" +
        "\"" +
        selectedState.idp +
        "\"" +
        "," +
        "\"" +
        "UpdateType" +
        "\"" +
        ":" +
        "\"" +
        mUpdateType +
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
      getPatientProfileDetails("");
    }
  }

  Future<String> saveRemovePatientFavouriteDetails(String? healthcareProviderIDP,String updateType) async {
    /*List<IconModel> listIcon;*/
    var doctorApiCalled = false;
    ProgressDialog pr = ProgressDialog(context);
    Future.delayed(Duration.zero, () {
      pr.show();
    });

    try
    {
      String patientUniqueKey = await getPatientUniqueKey();
      String userType = await getUserType();
      debugPrint("Key and type");
      debugPrint(patientUniqueKey);
      debugPrint(userType);
      String jsonStr = "{" +
          "\"" +
          "UserIDP" +
          "\"" +
          ":" +
          "\"" +
          widget.patientIDP! +
          "\"" +
          "," +
          "\"" +
          "HealthcareProviderIDP" +
          "\"" +
          ":" +
          "\"" +
          healthcareProviderIDP! +
          "\"" +
          "," +
          "\"" +
          "UpdateType" +
          "\"" +
          ":" +
          "\"" +
          updateType +
          "\"" +
          "}";

      debugPrint(jsonStr);

      String encodedJSONStr = encodeBase64(jsonStr);
      //listIcon = new List();
      print(encodedJSONStr);
      var response = await apiHelper.callApiWithHeadersAndBody(
        url: widget.urlSaveRemoveFavouriteDetails,
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
        debugPrint("jsonData : " + jsonData);
        pr.hide();
        setState(() {});
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
          String loginUrl = "${baseURL}provider_list.php";
          //listIcon = new List();
          var cityIdp = "";
          if (cityIDF != "") cityIdp = cityIDF;
          else cityIdp = "-";
          String jsonStr = "{" +
              "\"" +
              "ProviderType" +
              "\"" +
              ":" +
              "\"" +
              "radiology" +
              "\"" +
              "," +
              "\"" +
              "CityIDF" +
              "\"" +
              ":" +
              "\"" +
              cityIDF +
              "\"" +
              "," +
              "\"" +
              "UserIDP" +
              "\"" +
              ":" +
              "\"" +
              widget.patientIDP! +
              "\"" +
              "}";

          debugPrint("ProviderList API request object");
          debugPrint(jsonStr);
          String patientUniqueKey = await getPatientUniqueKey();
          String userType = await getUserType();
          debugPrint("Key and type");
          debugPrint(patientUniqueKey);
          debugPrint(userType);
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
            for (var i = 0; i < jsonData.length; i++)
            {
              var jo = jsonData[i];
              listDoctors.add({
                "HealthCareProviderIDP": jo['HealthCareProviderIDP'].toString(),
                "ProviderCompanyName": jo['ProviderCompanyName'].toString(),
                "DisplayName": jo['DisplayName'].toString(),
                "ProviderArea": jo['ProviderArea'].toString(),
                "ProviderLogo": jo['ProviderLogo'].toString(),
                "CityName": jo['CityName'].toString(),
                "IsFavourite": jo['IsFavourite'].toString()
              });
              listDoctorsSearchResults.add({
                "HealthCareProviderIDP": jo['HealthCareProviderIDP'].toString(),
                "ProviderCompanyName": jo['ProviderCompanyName'].toString(),
                "DisplayName": jo['DisplayName'].toString(),
                "ProviderArea": jo['ProviderArea'].toString(),
                "ProviderLogo": jo['ProviderLogo'].toString(),
                "CityName": jo['CityName'].toString(),
                "IsFavourite": jo['IsFavourite'].toString()
              });
            }
            setState(() {});
          }
        } catch (exception) {
          pr.hide();
        }
      }
      else
      {
        pr.hide();
      }
    }
    return 'success';
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
      size: SizeConfig.blockSizeHorizontal !* 6.2,
    );

    titleWidget = Text(
      "Select ${widget.type}",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: SizeConfig.blockSizeHorizontal !* 4.8,
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
              height: SizeConfig.blockSizeVertical !* 8,
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.red,
                        size: SizeConfig.blockSizeHorizontal !* 6.2,
                      ),
                      onTap: () {
                        /*setState(() {
                          widget.type = "My type";
                        });*/
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal !* 6,
                    ),
                    Container(
                      width: SizeConfig.blockSizeHorizontal !* 50,
                      height: SizeConfig.blockSizeVertical !* 8,
                      child: Center(
                        child: titleWidget,
                      ),
                    ),
                    Expanded(
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal !* 1),
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
                                      SizeConfig.blockSizeHorizontal !* 6.2,
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
                                            // showCitySelectionDialog(listCitiesSearchResults, "City");
                                        });
                                      },
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                        SizeConfig.blockSizeHorizontal !*
                                            4.0,
                                      ),
                                      decoration: InputDecoration(
                                        hintStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                            SizeConfig.blockSizeVertical !*
                                                2.1),
                                        labelStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                            SizeConfig.blockSizeVertical !*
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
                                      SizeConfig.blockSizeHorizontal !* 6.2,
                                    );
                                    this.titleWidget = Text(
                                      "Select ${widget.type}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize:
                                        SizeConfig.blockSizeHorizontal !*
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