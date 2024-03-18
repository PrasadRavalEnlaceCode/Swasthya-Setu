import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silvertouch/app_screens/provider_favourite_doctor_screen.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_investigation_list_doctor.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';
import '../podo/dropdown_item.dart';
import '../utils/color.dart';
import '../utils/progress_dialog.dart';
import 'custom_dialog.dart';
import 'doctor_order_screen.dart';
import 'fullscreen_image.dart';
import 'not_connected_doctors_list.dart';

class MarketPlaceDashboardScreen extends StatefulWidget {
  String? patientIDP = "";
  final String urlFetchPatientProfileDetails = "${baseURL}marketplacelist.php";

  final String urlSaveRemoveFavouriteDetails =
      "${baseURL}doctor_wishlist_save.php";

  final String urlAddToCart = "${baseURL}market_place_doctororder.php";

  String emptyTextMyDoctors1 = "Please wait";

  String emptyMessage = "";

  Widget? emptyMessageWidget;

  MarketPlaceDashboardScreen(String patientIDP) {
    this.patientIDP = patientIDP;
  }

  @override
  State<StatefulWidget> createState() {
    return MarketPlaceDashboardScreenState();
  }
}

class MarketPlaceDashboardScreenState
    extends State<MarketPlaceDashboardScreen> {
  List<Map<String, String>> listDoctorsSearchResults = [];
  String cityIDF = "";
  String firstName = "";
  String lastName = "";
  var focusNode = new FocusNode();

  // var isFABVisible = true;
  bool doctorApiCalled = false;
  bool apiCalled = false;

  // Icon icon = Icon(
  //   Icons.search,
  //   color: Colors.white,
  // );
  Widget titleWidget = Text("Select Products");

  // ScrollController hideFABController;

  @override
  void initState() {
    super.initState();
    widget.emptyMessage = "${widget.emptyTextMyDoctors1}";
    widget.emptyMessageWidget = SizedBox(
      height: SizeConfig.blockSizeVertical! * 80,
      child: Container(
        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 5),
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
                      Expanded(
                        child: ListView.builder(
                            itemCount: listDoctorsSearchResults.length,
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {},
                                child: Container(
                                    child: Padding(
                                        padding: EdgeInsets.all(
                                            SizeConfig.blockSizeHorizontal! *
                                                2),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  // listDoctorsSearchResults[index]['ProviderLogo']
                                                  (listDoctorsSearchResults[
                                                                      index][
                                                                  'ProviderLogo']
                                                              .toString()
                                                              .length) >
                                                          0
                                                      ? InkWell(
                                                          child:
                                                              CachedNetworkImage(
                                                            fadeInDuration:
                                                                Duration.zero,
                                                            placeholder:
                                                                (context,
                                                                        url) =>
                                                                    Image(
                                                              image: AssetImage(
                                                                  'images/shimmer_effect.png'),
                                                              fit: BoxFit.cover,
                                                            ),
                                                            imageUrl: listDoctorsSearchResults[
                                                                        index][
                                                                    'ProviderLogo']
                                                                .toString(),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        )
                                                      : InkWell(
                                                          onTap: () {},
                                                          child: CircleAvatar(
                                                            radius: 20,
                                                            child: Icon(
                                                              Icons
                                                                  .storefront_sharp,
                                                              size: 20,
                                                            ),
                                                          ),
                                                        ),
                                                  SizedBox(
                                                    width: SizeConfig
                                                            .blockSizeHorizontal! *
                                                        2,
                                                  ),
                                                  Container(
                                                    width: 200,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Text(
                                                          (listDoctorsSearchResults[
                                                                      index][
                                                                  "ProductName"]!
                                                              .trim()),
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            fontSize: SizeConfig
                                                                    .blockSizeHorizontal! *
                                                                4.2,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.black,
                                                            letterSpacing: 1.3,
                                                          ),
                                                        ),
                                                        Text(
                                                          "Company - " +
                                                              listDoctorsSearchResults[
                                                                          index]
                                                                      [
                                                                      "ProviderCompanyName"]!
                                                                  .trim(),
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            fontSize: SizeConfig
                                                                    .blockSizeHorizontal! *
                                                                3.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                Colors.black54,
                                                            letterSpacing: 1.3,
                                                          ),
                                                        ),
                                                        Text(
                                                            "Area - " +
                                                                listDoctorsSearchResults[
                                                                            index]
                                                                        [
                                                                        "ProviderArea"]!
                                                                    .trim(),
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              fontSize: SizeConfig
                                                                      .blockSizeHorizontal! *
                                                                  3.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Colors.black,
                                                              letterSpacing:
                                                                  1.3,
                                                            )),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Row(
                                                      children: [
                                                        InkWell(
                                                            onTap: () {
                                                              showOrderDialog(
                                                                  listDoctorsSearchResults[
                                                                      index]);
                                                            },
                                                            child: Icon(
                                                              Icons
                                                                  .shopping_cart,
                                                              color:
                                                                  Colors.blue,
                                                              size: 30.0,
                                                              semanticLabel:
                                                                  'Add to order',
                                                            )),
                                                        SizedBox(
                                                          width: SizeConfig
                                                                  .blockSizeVertical! *
                                                              2.0,
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            print('OnTap');
                                                            print(listDoctorsSearchResults[
                                                                    index][
                                                                'IsFavourite']);
                                                            String?
                                                                healthcareProviderIDP =
                                                                listDoctorsSearchResults[
                                                                        index][
                                                                    'HealthCareProviderIDP'];
                                                            String?
                                                                healthcareProviderProductIDP =
                                                                listDoctorsSearchResults[
                                                                        index][
                                                                    'HealthCareProviderProductIDP'];
                                                            if (listDoctorsSearchResults[
                                                                        index][
                                                                    'IsFavourite'] ==
                                                                "0") {
                                                              // save
                                                              saveRemovePatientFavouriteDetails(
                                                                  healthcareProviderIDP,
                                                                  healthcareProviderProductIDP,
                                                                  "0");
                                                            } else {
                                                              // remove
                                                              saveRemovePatientFavouriteDetails(
                                                                  healthcareProviderIDP,
                                                                  healthcareProviderProductIDP,
                                                                  "1");
                                                            }
                                                          },
                                                          child: listDoctorsSearchResults[
                                                                          index]
                                                                      [
                                                                      'IsFavourite'] ==
                                                                  "0"
                                                              ? Icon(
                                                                  Icons
                                                                      .star_border,
                                                                  color: Colors
                                                                      .blue,
                                                                  size: 30.0,
                                                                  semanticLabel:
                                                                      'Remove from Favourite',
                                                                )
                                                              : Icon(
                                                                  Icons
                                                                      .star_outlined,
                                                                  color: Colors
                                                                      .blue,
                                                                  size: 30.0,
                                                                  semanticLabel:
                                                                      'Add to Favourite',
                                                                ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ]),
                                            SizedBox(
                                              height: SizeConfig
                                                      .blockSizeVertical! *
                                                  0.5,
                                            ),
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
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Get.to(() => ProviderFavouriteDoctorScreen(
                                    widget.patientIDP!))?.then((value) {
                                  getPatientProfileDetails();
                                });
                              },
                              child: Card(
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
                                  left: SizeConfig.blockSizeHorizontal! * 3.0,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    SizeConfig.blockSizeHorizontal! * 3.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image(
                                        image: AssetImage(
                                          "images/ic_favourite.png",
                                        ),
                                        height:
                                            SizeConfig.blockSizeHorizontal! * 7,
                                        width:
                                            SizeConfig.blockSizeHorizontal! * 7,
                                      ),
                                      SizedBox(
                                        width: SizeConfig.blockSizeHorizontal! *
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
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return DoctorOrderScreen(widget.patientIDP!);
                                }));
                              },
                              child: Card(
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
                                    SizeConfig.blockSizeHorizontal! * 3.0),
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    SizeConfig.blockSizeHorizontal! * 3.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image(
                                        image: AssetImage(
                                          "images/ic_order.png",
                                        ),
                                        height:
                                            SizeConfig.blockSizeHorizontal! * 7,
                                        width:
                                            SizeConfig.blockSizeHorizontal! * 7,
                                      ),
                                      SizedBox(
                                        width: SizeConfig.blockSizeHorizontal! *
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
                      )
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
          "," +
          "\"" +
          "ProviderType" +
          "\"" +
          ":" +
          "\"" +
          "surgical" +
          "\"" +
          "," +
          "\"" +
          "CityIDF" +
          "\"" +
          ":" +
          "\"" +
          '-' +
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
        if (listDoctorsSearchResults != null &&
            listDoctorsSearchResults.length > 0) {
          listDoctorsSearchResults.clear();
        }
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
            "ProductDetails": jo['ProductDetails'].toString(),
            "HealthCareProviderProductIDP":
                jo['HealthCareProviderProductIDP'].toString()
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

  Future<String> saveRemovePatientFavouriteDetails(
      String? healthcareProviderIDP,
      String? healthcareProviderProductIDP,
      String updateType) async {
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
          "HealthCareProviderProductIDP" +
          "\"" +
          ":" +
          "\"" +
          healthcareProviderProductIDP! +
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
      print('Url urlSaveRemoveFavouriteDetails');
      //var resBody = json.decode(response.body);
      debugPrint(response.body.toString());
      final jsonResponse = json.decode(response.body.toString());
      ResponseModel model = ResponseModel.fromJSON(jsonResponse);
      if (model.status == "OK") {
        getPatientProfileDetails();
        final snackBar = SnackBar(
          backgroundColor: Colors.green,
          content: Text(model.message!),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
          "HealthcareProviderProductIDP" +
          "\"" +
          ":" +
          "\"" +
          healthcareProviderProductIDP! +
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
      print('Url urlSaveRemoveFavouriteDetails');
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
    }
    return 'success';
  }

  Future<String> addToCart(String? healthcareProviderIDP,
      String? healthcareProviderProductIDP) async {
    /*List<IconModel> listIcon;*/
    var doctorApiCalled = false;
    print('addToCart $healthcareProviderIDP $healthcareProviderProductIDP');
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
          "HealthCareProviderProductIDP" +
          "\"" +
          ":" +
          "\"" +
          healthcareProviderProductIDP! +
          "\"" +
          "}";

      debugPrint(jsonStr);

      String encodedJSONStr = encodeBase64(jsonStr);
      //listIcon = new List();
      print(encodedJSONStr);
      var response = await apiHelper.callApiWithHeadersAndBody(
        url: widget.urlAddToCart,
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
        pr.hide();
        final snackBar = SnackBar(
          backgroundColor: Colors.green,
          content: Text(model.message!),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
          listDoctorsSearchResults = [];
          String loginUrl = "${baseURL}marketplacelist.php";
          //listIcon = new List();
          String jsonStr = "{" +
              "\"" +
              "ProviderType" +
              "\"" +
              ":" +
              "\"" +
              "surgical" +
              "\"" +
              "," +
              "\"" +
              "CityIDF" +
              "\"" +
              ":" +
              "\"" +
              '-' +
              "\"" +
              "," +
              "\"" +
              "DoctorIDP" +
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
            for (var i = 0; i < jsonData.length; i++) {
              var jo = jsonData[i];
              listDoctorsSearchResults.add({
                "HealthCareProviderIDP": jo['HealthCareProviderIDP'].toString(),
                "ProviderCompanyName": jo['ProviderCompanyName'].toString(),
                "DisplayName": jo['DisplayName'].toString(),
                "ProviderArea": jo['ProviderArea'].toString(),
                "ProviderLogo": jo['ProviderLogo'].toString(),
                "CityName": jo['CityName'].toString(),
                "IsFavourite": jo['IsFavourite'].toString(),
                "ProductName": jo['ProductName'].toString(),
                "HealthCareProviderProductIDP":
                    jo['HealthCareProviderProductIDP'].toString()
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

  Future<void> showOrderDialog(
      Map<String, String> listDoctorsSearchResult) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Please confirm'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                    "Once order is placed, vendor will contact you for details."),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Place Order'),
              onPressed: () {
                Navigator.of(context).pop();
                addToCart(listDoctorsSearchResult['HealthCareProviderIDP'],
                    listDoctorsSearchResult['HealthCareProviderProductIDP']);
              },
            ),
          ],
        );
      },
    );
  }
}
