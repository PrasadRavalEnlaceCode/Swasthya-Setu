import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swasthyasetu/app_screens/chat_screen.dart';
import 'package:swasthyasetu/app_screens/doctor_full_details_screen.dart';
import 'package:swasthyasetu/app_screens/provider_detail.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import '../podo/dropdown_item.dart';
import '../utils/color.dart';
import '../utils/progress_dialog.dart';
import 'fullscreen_image.dart';
import 'not_connected_doctors_list.dart';

class ProviderFavouriteDoctorScreen extends StatefulWidget {
  String? patientIDP = "";
  final String urlFetchPatientProfileDetails =
      "${baseURL}doctor_wishlist.php";

  String emptyTextMyDoctors1 =
      "Please wait";

  String emptyMessage = "";

  Widget? emptyMessageWidget;


  ProviderFavouriteDoctorScreen(String patientIDP) {
    this.patientIDP = patientIDP;
  }

  @override
  State<StatefulWidget> createState() {
    return ProviderFavouriteDoctorScreenState();
  }
}

class ProviderFavouriteDoctorScreenState extends State<ProviderFavouriteDoctorScreen> {
  List<Map<String, String>> listDoctorsSearchResults = [];
  String firstName = "";
  String lastName = "";
  var focusNode = new FocusNode();
  // var isFABVisible = true;
  bool doctorApiCalled = false;
  bool apiCalled = false;

  Icon icon = Icon(
    Icons.search,
    color: Colors.white,
  );
  Widget titleWidget = Text("Favourites");

  // ScrollController hideFABController;

  @override
  void initState() {
    super.initState();
    cityName = "";
    widget.emptyMessage = "${widget.emptyTextMyDoctors1}";
    widget.emptyMessageWidget = SizedBox(
      height: SizeConfig.blockSizeVertical !* 80,
      child: Container(
        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 5),
        child: Center(
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
      ),
    );
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
            color: Colorsblack, size: SizeConfig.blockSizeVertical !* 2.5),
        toolbarTextStyle: TextTheme(
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
          return RefreshIndicator(
            child:
            listDoctorsSearchResults.length > 0
                ?
            Column(
              children: <Widget>[
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
                              widget.patientIDP,
                            ))!.then((value) {
                              if (value != null && value == 1)
                                getPatientProfileDetails();
                            });
                          },
                          child:
                          Container(
                              child: Padding(
                                  padding: EdgeInsets.all(
                                      SizeConfig.blockSizeHorizontal ! * 2),
                                  child: Column(
                                    children: [
                                      Row(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: <Widget>[
                                            (listDoctorsSearchResults[index]['ProviderLogo'].toString().length)>0
                                                ?
                                            InkWell(
                                              child: CachedNetworkImage(
                                                fadeInDuration: Duration.zero,
                                                placeholder: (context, url) => Image(
                                                  image: AssetImage('images/shimmer_effect.png'),
                                                  fit: BoxFit.cover,
                                                ),
                                                imageUrl: listDoctorsSearchResults[index]['ProviderLogo'].toString(),
                                                fit: BoxFit.cover,
                                              ),
                                            )  :
                                            InkWell(
                                              onTap: () {},
                                              child: CircleAvatar(
                                                radius: 20,
                                                child: Icon(
                                                  Icons.storefront_sharp,
                                                  size: 20,),
                                              ),
                                            ),
                                            SizedBox(
                                              width: SizeConfig
                                                  .blockSizeHorizontal ! *
                                                  5,
                                            ),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .start,
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: <Widget>[
                                                Container(
                                                  width: SizeConfig
                                                      .blockSizeHorizontal !*
                                                      70,
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child:
                                                        Text(
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
                                                  'Area - ' + listDoctorsSearchResults[
                                                  index]
                                                  ["ProviderArea"]!
                                                  ,
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
                                          ]
                                      ),
                                      SizedBox(
                                        height:
                                        SizeConfig.blockSizeVertical ! *
                                            0.5,
                                      ),
                                      Container(
                                        color: Colors.grey,
                                        height: 0.5,
                                      )
                                          .paddingSymmetric(
                                          horizontal: SizeConfig
                                              .blockSizeHorizontal ! *
                                              2)
                                          .paddingOnly(
                                        top: SizeConfig
                                            .blockSizeVertical ! *
                                            1.8,
                                      )
                                    ],
                                  ))),
                        );
                      }),
                ),
              ],
            )
                : widget.emptyMessageWidget!,
            onRefresh: () {
              return getPatientProfileDetails();
            },
          );
        },
      ),
    );
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

  Future<String> getPatientProfileDetails() async {
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
          "DoctorIDP" +
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
        debugPrint("Decoded Data Array Dashboard : " + strData);
        final jsonData = json.decode(strData);
        if (jsonData.length > 0)
          doctorApiCalled = true;
        else
          doctorApiCalled = false;
        for (var i = 0; i < jsonData.length; i++) {
          var jo = jsonData[i];
          listDoctorsSearchResults.add({
            "HealthCareProviderIDP": jo['HealthCareProviderIDP'].toString(),
            "ProviderCompanyName": jo['ProviderCompanyName'].toString(),
            "DisplayName": jo['DisplayName'].toString(),
            "ProviderArea": jo['ProviderArea'].toString(),
            "ProviderLogo": jo['ProviderLogo'].toString(),
            "ProductName": jo['ProductName'].toString(),
            "IsFavourite": jo['IsFavourite'].toString(),
            "ProductDetails": jo['ProductDetails'].toString()
          });
        }
        pr.hide();
        setState(() {});
      }
    } catch (exception) {
      if (!doctorApiCalled) {

      } else {
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