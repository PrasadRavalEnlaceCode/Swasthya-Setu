import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/dropdown_item.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/podo/speciality_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';

import 'add_patient_screen.dart';

TextEditingController specialityController = TextEditingController();
TextEditingController cityController = TextEditingController();
DropDownItem selectedCity = DropDownItem("", "");
SpecialityModel? selectedSpeciality;
List<SpecialityModel> listSpeciality = [];
List<DropDownItem> listCitiesSearchResults = [];

class AddNewDoctor extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddNewDoctorState();
  }
}

class AddNewDoctorState extends State<AddNewDoctor> {
  TextEditingController doctorNameController = TextEditingController();
  TextEditingController clinicNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  DropDownItem selectedState = DropDownItem("", "");
  int apiCalledCount = 0;
  ProgressDialog? pr;
  bool showSuccessMessage = false;

  void callbackFromCountryDialog() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    specialityController = TextEditingController();
    cityController = TextEditingController();
    selectedCity = DropDownItem("", "");
    selectedSpeciality = null;
    listSpeciality = [];
    listCitiesSearchResults = [];
    callAPIsForFetch(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Doctor"),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal! * 3.0,
        ),
        child: !showSuccessMessage
            ? Column(
                children: [
                  SizedBox(
                    height: SizeConfig.blockSizeVertical! * 2.5,
                  ),
                  Text(
                    "Invite your doctor to participate in your care",
                    style: TextStyle(
                      color: Colors.blueGrey[700],
                      fontSize: SizeConfig.blockSizeHorizontal! * 4.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical! * 2.5,
                  ),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        TextField(
                          controller: doctorNameController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical! * 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelText: "Doctor Name",
                            hintText: "",
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical! * 1.5,
                        ),
                        TextField(
                          controller: clinicNameController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical! * 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelText: "Clinic Name",
                            hintText: "",
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical! * 1.5,
                        ),
                        InkWell(
                          onTap: () {
                            showSpecialitySelectionDialog();
                          },
                          child: IgnorePointer(
                            child: TextField(
                              controller: specialityController,
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize:
                                      SizeConfig.blockSizeVertical! * 2.3),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical! * 2.3),
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical! * 2.3),
                                labelText: "Speciality",
                                hintText: "",
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical! * 1.5,
                        ),
                        TextField(
                          controller: addressController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical! * 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelText: "Address",
                            hintText: "",
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical! * 1.5,
                        ),
                        InkWell(
                          onTap: () {
                            showCountrySelectionDialog(
                                listCitiesSearchResults, "City");
                          },
                          child: IgnorePointer(
                            child: TextField(
                              controller: cityController,
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize:
                                      SizeConfig.blockSizeVertical! * 2.3),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical! * 2.3),
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical! * 2.3),
                                labelText: "City",
                                hintText: "",
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical! * 1.5,
                        ),
                        TextField(
                          controller: mobileNoController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical! * 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelText: "Mobile",
                            hintText: "",
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical! * 1.5,
                        ),
                        TextField(
                          controller: emailController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical! * 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelText: "Email",
                            hintText: "",
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical! * 1.5,
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: SizeConfig.blockSizeHorizontal! * 10,
                      height: SizeConfig.blockSizeHorizontal! * 10,
                      margin: EdgeInsets.only(
                        bottom: SizeConfig.blockSizeVertical! * 1.0,
                      ),
                      child: RawMaterialButton(
                        onPressed: () {
                          submitAddNewDoctor(context);
                        },
                        elevation: 2.0,
                        fillColor: Color(0xFF06A759),
                        child: Image(
                          width: SizeConfig.blockSizeHorizontal! * 5.5,
                          height: SizeConfig.blockSizeHorizontal! * 5.5,
                          //height: 80,
                          image: AssetImage(
                              "images/ic_right_arrow_triangular.png"),
                        ),
                        shape: CircleBorder(),
                      ),
                    ),
                  )
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 3.0,
                    ),
                    Image(
                      image: AssetImage("images/ic_check_circle.png"),
                      width: SizeConfig.blockSizeHorizontal! * 20.0,
                      height: SizeConfig.blockSizeHorizontal! * 20.0,
                      color: Colors.green,
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 3.0,
                    ),
                    Text(
                      "Doctor Added",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: SizeConfig.blockSizeHorizontal! * 7.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 1.5,
                    ),
                    Text(
                      "Doctor has been added.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: SizeConfig.blockSizeHorizontal! * 4.3,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 2.0,
                    ),
                    MaterialButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      color: Colors.green,
                      child: Text(
                        "Okay",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: SizeConfig.blockSizeHorizontal! * 4.3,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void showSpecialitySelectionDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => SpecialityDialog(listSpeciality, () {
              setState(() {});
            }));
  }

  void showCountrySelectionDialog(List<DropDownItem> list, String type) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            CountryDialog(list, type, callbackFromCountryDialog));
  }

  void getSpecialityList(BuildContext context) async {
    String loginUrl = "${baseURL}doctorSpeciality.php";
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr = "";

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
    closeDialogIfAllCalled(context);
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      listSpeciality = specialityModelFromJson(strData);
      setState(() {});
    }
  }

  void getCitiesList(BuildContext context) async {
    String loginUrl = "${baseURL}city_listnew.php";
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
        "" +
        "\"" +
        "}";

    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);
    var response = await apiHelper.callApiWithHeadersAndBody(
      url: loginUrl,
      headers: {
        "u": patientUniqueKey,
        "type": "patient",
      },
      body: {"getjson": encodedJSONStr},
    );
    debugPrint(response.body.toString());
    closeDialogIfAllCalled(context);
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    //pr.hide();
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      listCitiesSearchResults = [];
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listCitiesSearchResults
            .add(DropDownItem(jo['CityIDP'], jo['CityName']));
      }
      setState(() {});
    }
  }

  String encodeBase64(String text) {
    var bytes = utf8.encode(text);
    return base64.encode(bytes);
  }

  String decodeBase64(String text) {
    var bytes = base64.decode(text);
    return String.fromCharCodes(bytes);
  }

  void callAPIsForFetch(BuildContext context) {
    apiCalledCount = 0;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    getSpecialityList(context);
    getCitiesList(context);
  }

  closeDialogIfAllCalled(BuildContext context) {
    apiCalledCount++;
    if (apiCalledCount == 2) pr!.hide();
  }

  void submitAddNewDoctor(BuildContext context) async {
    String mobileNoToValidate = mobileNoController.text;
    if (mobileNoController.text.length >= 12) {
      if (mobileNoController.text.startsWith("+91")) {
        mobileNoToValidate = mobileNoController.text.replaceFirst("+91", "");
      } else if (mobileNoController.text.startsWith("91")) {
        mobileNoToValidate = mobileNoController.text.replaceFirst("91", "");
      }
    }
    if (doctorNameController.text.trim().isEmpty) {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please Enter Doctor Name"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (selectedSpeciality == null) {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please Select Doctor Speciality"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (selectedCity.idp.trim().isEmpty) {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please Select Doctor City"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (mobileNoToValidate.trim().isEmpty) {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please Enter Doctor Mobile Number"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (mobileNoToValidate.trim().length != 10) {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Mobile Number should be 10 digit"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    String loginUrl = "${baseURL}patienttoAddDoctor.php";
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
        "\"doctorname\":\"${doctorNameController.text.trim()}\"" +
        ",\"clinicname\":\"${clinicNameController.text.trim()}\"" +
        ",\"address\":\"${addressController.text.trim()}\"" +
        ",\"city\":\"${selectedCity.idp}\"" +
        ",\"mobile\":\"${mobileNoToValidate.trim()}\"" +
        ",\"email\":\"${emailController.text.trim()}\"" +
        ",\"SpecialityIDF\":\"${selectedSpeciality!.specialityIdp}\"" +
        ",\"PatientIDP\":\"$patientIDP\"" +
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
      setState(() {
        showSuccessMessage = true;
      });
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
                                          widget.list = listCitiesSearchResults
                                              .where((dropDownObj) =>
                                                  dropDownObj.value
                                                      .toLowerCase()
                                                      .contains(
                                                          text.toLowerCase()))
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
                                    if (widget.type == "Country")
                                      widget.list = listCountries;
                                    else if (widget.type == "State")
                                      widget.list = listStates;
                                    else if (widget.type == "City")
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
                          selectedCity = widget.list[index];
                          cityController =
                              TextEditingController(text: selectedCity.value);
                          Navigator.of(context).pop();
                          widget.callbackFromCountryDialog();
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
            /*Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: MaterialButton(
                        color: Colors.red,
                        onPressed: () {
                          Navigator.of(context).pop(); // To close the dialog
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ))*/
          ],
        ));
  }

  void getStatesList() async {
    String loginUrl = "${baseURL}state_list.php";
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
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDP +
        "\"" +
        "," +
        "\"" +
        "CountryIDP" +
        "\"" +
        ":" +
        "\"" +
        selectedCountry.idp +
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
      listStates = [];
      listCitiesSearchResults = [];
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listStates.add(DropDownItem(jo['StateIDP'], jo['StateName']));
        listCitiesSearchResults
            .add(DropDownItem(jo['StateIDP'], jo['StateName']));
      }
      setState(() {});
    }
  }
}

class SpecialityDialog extends StatefulWidget {
  List<SpecialityModel> listSpeciality;
  Function callbackFromSpecialityDialog;

  SpecialityDialog(this.listSpeciality, this.callbackFromSpecialityDialog);

  @override
  State<StatefulWidget> createState() {
    return SpecialityDialogState();
  }
}

class SpecialityDialogState extends State<SpecialityDialog> {
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
      "Select Speciality",
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

  void hideKeyBoard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    currentFocus.unfocus();
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
                        Navigator.of(context).pop();
                        hideKeyBoard(context);
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
                                  if (icon?.icon == Icons.search) {
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
                                          widget.listSpeciality = listSpeciality
                                              .where((dropDownObj) =>
                                                  dropDownObj.specialityName!
                                                      .toLowerCase()
                                                      .contains(
                                                          text.toLowerCase()))
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
                                        hintText: "Search Speciality",
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
                                      "Select Speciality",
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
                  itemCount: widget.listSpeciality.length,
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return InkWell(
                        onTap: () {
                          selectedSpeciality = widget.listSpeciality[index];
                          specialityController = TextEditingController(
                              text: selectedSpeciality!.specialityName);
                          setState(() {});
                          debugPrint(
                              "Selected speciality : ${selectedSpeciality!.specialityIdp} ${selectedSpeciality!.specialityName}");
                          Navigator.of(context).pop();
                          hideKeyBoard(context);
                          widget.callbackFromSpecialityDialog();
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
                                    widget
                                        .listSpeciality[index].specialityName!,
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
