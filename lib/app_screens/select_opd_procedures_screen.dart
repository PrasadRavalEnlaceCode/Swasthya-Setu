import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:swasthyasetu/api/api_helper.dart';
import 'package:swasthyasetu/app_screens/add_opd_procedures.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/model_opd_reg.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';

import '../utils/color.dart';

List<ModelOPDRegistration> listOPDRegistration = [];
List<ModelOPDRegistration> listOPDRegistrationSelected = [];
List<ModelOPDRegistration> listOPDRegistrationSearchResults = [];

class SelectOPDProceduresScreen extends StatefulWidget {
  String patientIDP;
  String consultationIDP;
  String from;
  var campID;
  String? appointmentRequestIDP = "";

  SelectOPDProceduresScreen(this.patientIDP, this.consultationIDP, this.from,
      {this.appointmentRequestIDP, this.campID});

  @override
  State<StatefulWidget> createState() {
    return SelectOPDProceduresScreenState();
  }
}

class SelectOPDProceduresScreenState extends State<SelectOPDProceduresScreen> {
  Icon icon = Icon(
    Icons.search,
    color: black,
  );
  Widget titleWidget = Text("Select Services", style: TextStyle(color: black));
  TextEditingController? searchController;
  var focusNode = new FocusNode();
  ApiHelper apiHelper = ApiHelper();

  @override
  void initState() {
    super.initState();
    print('appointmentRequestIDP ${widget.appointmentRequestIDP}');
    print('campID ${widget.campID}');
    getOPDProcedures();
  }

  @override
  void dispose() {
    listOPDRegistration = [];
    listOPDRegistrationSelected = [];
    listOPDRegistrationSearchResults = [];
    widget.patientIDP = "";
    super.dispose();
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
                  icon = Icon(
                    Icons.cancel,
                    color: Colorsblack,
                  );
                  titleWidget = TextField(
                    controller: searchController,
                    focusNode: focusNode,
                    cursorColor: Colorsblack,
                    onChanged: (text) {
                      setState(() {
                        listOPDRegistrationSearchResults = listOPDRegistration
                            .where((model) =>
                                model.name
                                !.toLowerCase()
                                    .contains(text.toLowerCase()) ||
                                model.amount
                                !.toLowerCase()
                                    .contains(text.toLowerCase()))
                            .toList();
                      });
                    },
                    style: TextStyle(
                      color: Colorsblack,
                      fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
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
                      hintText: "Search OPD Procedures",
                    ),
                  );
                } else {
                  icon = Icon(
                    Icons.search,
                    color: Colorsblack,
                  );
                  titleWidget =
                      Text("Select Services", style: TextStyle(color: black));
                  listOPDRegistrationSearchResults = listOPDRegistration;
                }
              });
            },
            icon: icon,
          )
        ], toolbarTextStyle: TextTheme(
            titleMedium: TextStyle(
                color: Colorsblack,
                fontFamily: "Ubuntu",
                fontSize: SizeConfig.blockSizeVertical !* 2.5)).bodyMedium, titleTextStyle: TextTheme(
            titleMedium: TextStyle(
                color: Colorsblack,
                fontFamily: "Ubuntu",
                fontSize: SizeConfig.blockSizeVertical !* 2.5)).titleLarge,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
                itemCount: listOPDRegistrationSearchResults.length,
                itemBuilder: (context, index) {
                  return Padding(
                      padding: EdgeInsets.only(
                          left: SizeConfig.blockSizeHorizontal !* 2,
                          right: SizeConfig.blockSizeHorizontal !* 2,
                          top: SizeConfig.blockSizeHorizontal !* 2),
                      child: InkWell(
                        onTap: () {
                          listOPDRegistrationSearchResults[index].isChecked =
                              !listOPDRegistrationSearchResults[index]
                                  .isChecked!;
                          setState(() {});
                        },
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                        SizeConfig.blockSizeHorizontal !* 3),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            listOPDRegistrationSearchResults[
                                                    index]
                                                .name!,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: SizeConfig
                                                        .blockSizeHorizontal !*
                                                    4,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Align(
                                            alignment: Alignment.topRight,
                                            child: Text(
                                              "${listOPDRegistrationSearchResults[index].amount}/-",
                                              style: TextStyle(
                                                  color: colorBlueApp,
                                                  fontSize: SizeConfig
                                                          .blockSizeHorizontal !*
                                                      3.5,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width:
                                              SizeConfig.blockSizeHorizontal !*
                                                  3,
                                        ),
                                        Checkbox(
                                          value:
                                              listOPDRegistrationSearchResults[
                                                      index]
                                                  .isChecked,
                                          onChanged: (bool? value) {
                                            listOPDRegistrationSearchResults[
                                                    index]
                                                .isChecked = value!;
                                            setState(() {});
                                          },
                                        ),
                                        /*InkWell(
                                    child: Image(
                                      image: AssetImage(
                                          "images/ic_pdf_opd_reg.png"),
                                      width: SizeConfig.blockSizeHorizontal * 8,
                                    ),
                                  )*/
                                      ],
                                    ),
                                  )),
                            ),
                            /*SizedBox(
                          width: SizeConfig.blockSizeHorizontal * 2,
                        ),*/
                            /*Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: SizeConfig.blockSizeHorizontal * 6,
                        ),*/
                          ],
                        ),
                      ));
                }),
          ),
          /*Align(
            alignment: Alignment.topRight,
            child: RawMaterialButton(
              onPressed: () {
                getSelectedListAndGoToAddOPDProcedureScreen(context);
                */ /*Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PatientDashboardScreen()));*/ /*
              },
              elevation: 2.0,
              fillColor: Color(0xFF06A759),
              child: Image(
                width: SizeConfig.blockSizeHorizontal * 5.5,
                height: SizeConfig.blockSizeHorizontal * 5.5,
                //height: 80,
                image: AssetImage("images/ic_right_arrow_triangular.png"),
              ),
              shape: CircleBorder(),
            ),
          )*/
          Padding(
            padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 3),
            child: MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: BorderSide(color: Colors.grey, width: 1.0),
                ),
                child: Text(
                  "Proceed".toUpperCase(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeConfig.blockSizeHorizontal !* 4.0),
                ),
                padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 3),
                color: colorBlueApp,
                onPressed: () async {
                  getSelectedListAndGoToAddOPDProcedureScreen(context);
                  //launchURL(decodeBase64(result.rawContent));
                }),
          ),
        ],
      ),
    );
  }

  void getOPDProcedures() async {
    listOPDRegistration = [];
    listOPDRegistrationSearchResults = [];
    String loginUrl = "${baseURL}doctorOpdServiceList.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new List();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
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
        widget.patientIDP +
        "\"" +
        "}";

    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);
    var response = await apiHelper.callApiWithHeadersAndBody(
      url: loginUrl,
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
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listOPDRegistration.add(ModelOPDRegistration(
            jo['HospitalOPDServcesIDP'].toString(),
            jo['OPDService'],
            jo['Price'].toString(),
            "",
            amountBeforeDiscount: jo['Price'].toString(),
            discount: "0"));
      }
      listOPDRegistrationSearchResults = listOPDRegistration;
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

  void getSelectedListAndGoToAddOPDProcedureScreen(BuildContext context) {
    listOPDRegistrationSelected = [];
    listOPDRegistrationSearchResults.forEach((element) {
      if (element.isChecked!) {
        listOPDRegistrationSelected.add(element);
      }
    });
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddOPDProcedures(listOPDRegistrationSelected, widget.patientIDP,
          widget.consultationIDP, widget.from,
          campID: widget.campID ?? '');
    })).then((value) {
      Navigator.of(context).pop();
      /*if (widget.from == "new")
        Navigator.of(context).pop();
      else
        getOPDProcedures();*/
    });
  }
}
