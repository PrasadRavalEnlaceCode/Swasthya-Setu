import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_opd_reg.dart';
import 'package:silvertouch/podo/model_profile_patient.dart';
import 'package:silvertouch/podo/model_templates_advice_investigations.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/progress_dialog.dart';

import '../utils/color.dart';

List<ModelOPDRegistration> listOPDRegistration = [];
List<ModelOPDRegistration> listOPDRegistrationSelected = [];
List<ModelOPDRegistration> listOPDRegistrationSearchResults = [];
List<AdviceInvestigationTemplateModel> listTemplates = [];

class SelectInvestigationsToSendToLabScreen extends StatefulWidget {
  SelectInvestigationsToSendToLabScreen(
      List<ModelOPDRegistration> listInvestigationsResults) {
    //listOPDRegistrationSelected = listInvestigationsResults;
  }

  @override
  State<StatefulWidget> createState() {
    return SelectInvestigationsToSendToLabScreenState();
  }
}

class SelectInvestigationsToSendToLabScreenState
    extends State<SelectInvestigationsToSendToLabScreen> {
  Icon icon = Icon(
    Icons.search,
    color: Colors.black,
  );
  Widget titleWidget = Text("Select Lab");
  TextEditingController? searchController;
  var focusNode = new FocusNode();
  bool apiCalled = false;
  Widget? emptyMessageWidget;
  String emptyMessage = "No Lab added.";

  @override
  void initState() {
    super.initState();
    emptyMessageWidget = Center(
      child: SizedBox(
        height: SizeConfig.blockSizeVertical! * 80,
        width: SizeConfig.blockSizeHorizontal! * 100,
        child: Container(
          padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
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
                "${emptyMessage}",
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
    getLabs();
  }

  @override
  void dispose() {
    listOPDRegistration = [];
    listOPDRegistrationSelected = [];
    listOPDRegistrationSearchResults = [];
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
            color: Colorsblack, size: SizeConfig.blockSizeVertical! * 2.5),
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
                                model.name!
                                    .toLowerCase()
                                    .contains(text.toLowerCase()) ||
                                model.amount!
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
                      hintText: "Search Advice Investigations",
                    ),
                  );
                } else {
                  icon = Icon(
                    Icons.search,
                    color: Colorsblack,
                  );
                  titleWidget = Text("Select Advice Investigations");
                  listOPDRegistrationSearchResults = listOPDRegistration;
                }
              });
            },
            icon: icon,
          )
        ],
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
      body: Column(
        children: <Widget>[
          /*Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 3,
            ),
            child: MaterialButton(
                child: Text(
                  "Add New Lab",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeConfig.blockSizeHorizontal * 3.8,
                  ),
                ),
                minWidth: double.maxFinite,
                color: Color(0xFF06A759),
                onPressed: () async {
                  var patientIDP = await getPatientIDP();
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return AddNewLabScreen();
                  })).then((value) {
                    getLabs();
                  });
                }),
          ),*/
          Expanded(
            child: buildWidget(),
          ),
          Align(
            alignment: Alignment.topRight,
            child: RawMaterialButton(
              padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 2.0),
              onPressed: () {
                getSelectedListAndGoToAddOPDProcedureScreen(context);
              },
              elevation: 2.0,
              fillColor: Color(0xFF06A759),
              child: Image(
                width: SizeConfig.blockSizeHorizontal! * 5.5,
                height: SizeConfig.blockSizeHorizontal! * 5.5,
                //height: 80,
                image: AssetImage("images/ic_right_arrow_triangular.png"),
              ),
              shape: CircleBorder(),
            ),
          )
        ],
      ),
    );
  }

  void getLabs() async {
    listOPDRegistration = [];
    listOPDRegistrationSearchResults = [];
    String loginUrl = "${baseURL}doctorLabList.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new List();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String doctorIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr =
        "{" + "\"" + "DoctorIDP" + "\"" + ":" + "\"" + doctorIDP + "\"" + "}";

    debugPrint("json request :- " + jsonStr);

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
    debugPrint("response :- " + response.body.toString());
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
          jo['HealthCareProviderIDP'].toString(),
          jo['ProviderCompanyName'].toString(),
          jo['ProviderArea'],
          "",
        ));
      }
      listOPDRegistrationSearchResults = listOPDRegistration;
      setState(() {});
      apiCalled = true;
      if (listOPDRegistrationSelected.length > 0) {
        debugPrint("Inside for loop");
        for (int i = 0; i < listOPDRegistrationSearchResults.length; i++) {
          var modelNotSelected = listOPDRegistrationSearchResults[i];
          for (int j = 0; j < listOPDRegistrationSelected.length; j++) {
            var modelSelected = listOPDRegistrationSelected[j];
            if (modelSelected.idp == modelNotSelected.idp) {
              modelNotSelected.isChecked = true;
            }
          }
        }
        setState(() {});
      }
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
    if (listOPDRegistrationSelected.length > 0)
      Navigator.of(context).pop({'selection': listOPDRegistrationSelected});
    else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select atleast one lab."),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  buildWidget() {
    if (!apiCalled) return Container();
    if (apiCalled && listOPDRegistration.length > 0)
      return ListView.builder(
          shrinkWrap: true,
          itemCount: listOPDRegistrationSearchResults.length,
          itemBuilder: (context, index) {
            return Padding(
                padding: EdgeInsets.only(
                    left: SizeConfig.blockSizeHorizontal! * 2,
                    right: SizeConfig.blockSizeHorizontal! * 2,
                    top: SizeConfig.blockSizeHorizontal! * 2),
                child: InkWell(
                  onTap: () {
                    listOPDRegistrationSearchResults[index].isChecked =
                        !listOPDRegistrationSearchResults[index].isChecked!;
                    setState(() {});
                  },
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Card(
                            child: Padding(
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal! * 2),
                          child: Row(
                            children: [
                              Checkbox(
                                value: listOPDRegistrationSearchResults[index]
                                    .isChecked,
                                onChanged: (bool? value) {
                                  listOPDRegistrationSearchResults[index]
                                      .isChecked = value!;
                                  setState(() {});
                                },
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        listOPDRegistrationSearchResults[index]
                                            .name!,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: SizeConfig
                                                    .blockSizeHorizontal! *
                                                4,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          SizeConfig.blockSizeHorizontal! * 1,
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        listOPDRegistrationSearchResults[index]
                                            .amount!,
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: SizeConfig
                                                    .blockSizeHorizontal! *
                                                2.8,
                                            fontWeight: FontWeight.w500),
                                      ),
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
                              ),
                            ],
                          ),
                        )),
                      ),
                    ],
                  ),
                ));
          });
    return emptyMessageWidget;
  }
}
