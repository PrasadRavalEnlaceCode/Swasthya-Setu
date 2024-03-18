import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/model_opd_reg.dart';
import 'package:swasthyasetu/podo/model_templates_advice_investigations.dart';
import 'package:swasthyasetu/podo/response_login_icons_model.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';

import '../utils/color.dart';
import '../utils/multipart_request_with_progress.dart';
import '../utils/progress_dialog_with_percentage.dart';

List<ModelOPDRegistration> listPatients = [];
List<ModelOPDRegistration> listPatientsSelected = [];
List<ModelOPDRegistration> listPatientsSearchResults = [];
List<ModelOPDRegistration> listCategories = [];
List<ModelOPDRegistration> listCategoriesSelected = [];
List<ModelOPDRegistration> listCategoriesSearchResults = [];
List<AdviceInvestigationTemplateModel> listTemplates = [];

class SelectPatientsForShareVideo extends StatefulWidget {
  IconModel? videoModel;
  String doctorName;
  GlobalKey<ProgressDialogWithPercentageState> progressKey = GlobalKey();

  SelectPatientsForShareVideo(this.videoModel, this.doctorName);

  @override
  State<StatefulWidget> createState() {
    return SelectPatientsForShareVideoState();
  }
}

class SelectPatientsForShareVideoState
    extends State<SelectPatientsForShareVideo> {
  Icon icon = Icon(
    Icons.search,
    color: Colors.black,
  );
  Widget titleWidget = Text(
    "Select Patients",
    style: TextStyle(
        fontSize: SizeConfig.blockSizeHorizontal !* 3.8, color: Colors.black),
  );
  TextEditingController? searchController;
  var focusNode = new FocusNode();
  bool apiCalled = false;
  Widget? emptyMessageWidget;
  String emptyMessage = "No Patients found.";
  bool allSelected = false;
  int _radioValueSendType = -1;
  final _formKey = GlobalKey<FormState>();

  var description = TextEditingController();
  var title = TextEditingController();
  var link = TextEditingController();
  final picker = ImagePicker();
  File? selectedFile1;
  String selectedFileType = "";
  CroppedFile? selectedFile;

  @override
  void initState() {
    super.initState();
    listCategories = [
      ModelOPDRegistration("Diabetes", "Diabetes", "", ""),
      ModelOPDRegistration("Hypertension", "Hypertension", "", ""),
      ModelOPDRegistration("HeartDisease", "Heart Disease", "", ""),
      ModelOPDRegistration("Thyroid", "Thyroid", "", ""),
    ];
    listCategoriesSearchResults.addAll(listCategories);
    emptyMessageWidget = Center(
      child: SizedBox(
        height: SizeConfig.blockSizeVertical !* 80,
        width: SizeConfig.blockSizeHorizontal !* 100,
        child: Container(
          padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 5),
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
                "$emptyMessage",
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
    listPatients = [];
    listPatientsSelected = [];
    listPatientsSearchResults = [];
    listCategories = [];
    listCategoriesSelected = [];
    listCategoriesSearchResults = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: titleWidget,
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(
            color: Colors.black, size: SizeConfig.blockSizeVertical !* 2.5),
        actions: <Widget>[
          _radioValueSendType == 1
              ?
          IconButton(
                  onPressed: () {
                    setState(() {
                      if (icon.icon == Icons.search) {
                        searchController = TextEditingController(text: "");
                        focusNode.requestFocus();
                        icon = Icon(
                          Icons.cancel,
                          color:Colors.black,
                        );
                        titleWidget = TextField(
                          controller: searchController,
                          focusNode: focusNode,
                          cursorColor: Colors.black,
                          onChanged: (text) {
                            setState(() {
                              if (_radioValueSendType == 1)
                                listPatientsSearchResults = listPatients
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
                            color: Colors.black,
                            fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                          ),
                          decoration: InputDecoration(
                            hintText: "Search Patients",
                          ),
                        );
                      } else {
                        icon = Icon(
                          Icons.search,
                          color: Colors.black,
                        );
                        titleWidget = Text("Search Patients",style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                        ));
                        listPatientsSearchResults = listPatients;
                      }
                    });
                  },
                  icon: icon,
                )
              : Container(),
        ], toolbarTextStyle: TextTheme(
            titleMedium: TextStyle(
                color: Colors.black,
                fontFamily: "Ubuntu",
                fontSize: SizeConfig.blockSizeVertical !* 2.5)).bodyMedium, titleTextStyle: TextTheme(
            titleMedium: TextStyle(
                color: Colors.black,
                fontFamily: "Ubuntu",
                fontSize: SizeConfig.blockSizeVertical !* 2.5)).titleLarge,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: SizeConfig.blockSizeVertical !* 1.0,
                ),
                widget.videoModel == null
                    ? Padding(
                        padding: EdgeInsets.fromLTRB(
                            SizeConfig.blockSizeVertical !* 1.5,
                            0,
                            SizeConfig.blockSizeVertical !* 1,
                            0),
                        child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: title,
                                  style: TextStyle(color: Colors.green),
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(color: Colors.black),
                                    labelStyle: TextStyle(color: Colors.black),
                                    labelText: "Notification Title",
                                    hintText: "",
                                    counterText: "",
                                  ),
                                  validator: (value) {
                                    if (value!.length == 0)
                                      return 'Please enter title';
                                    return null;
                                  },
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 2,
                                  minLines: 1,
                                  maxLength: 500,
                                ),
                                TextFormField(
                                  controller: description,
                                  style: TextStyle(color: Colors.green),
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(color: Colors.black),
                                    labelStyle: TextStyle(color: Colors.black),
                                    labelText: "Description",
                                    hintText: "",
                                    counterText: "",
                                  ),
                                  validator: (value) {
                                    if (value!.length == 0)
                                      return 'Please enter Description';
                                    return null;
                                  },
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 3,
                                  minLines: 1,
                                  maxLength: 500,
                                ),
                                SizedBox(
                                  height: SizeConfig.blockSizeVertical !* 1.0,
                                ),
                                Row(
                                  children: [
                                    MaterialButton(
                                      onPressed: () {
                                        getImageFromGallery();
                                      },
                                      child: Image(
                                        width: 70,
                                        height: 70,
                                        //height: 80,
                                        image:
                                            AssetImage("images/ic_gallery.png"),
                                      ),
                                    ),
                                    Text(
                                      selectedFile == null
                                          ? ''
                                          : selectedFile!.path.split('/').last,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: SizeConfig.blockSizeVertical !* 1.0,
                                ),
                                Row(
                                  children: [
                                    MaterialButton(
                                      onPressed: () {
                                        openDocumentPicker();
                                      },
                                      child: Image(
                                        width: 70,
                                        height: 70,
                                        //height: 80,
                                        image:
                                        AssetImage("images/ic_doc.png"),
                                      ),
                                    ),
                                    Text(
                                      selectedFile1 == null
                                          ? ''
                                          : selectedFile1!.path.split('/').last,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: SizeConfig.blockSizeVertical !* 1.0,
                                ),
                                TextFormField(
                                  controller: description,
                                  style: TextStyle(color: Colors.green),
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(color: Colors.black),
                                    labelStyle: TextStyle(color: Colors.black),
                                    labelText: "Enter link",
                                    hintText: "",
                                    counterText: "",
                                  ),
                                  validator: (value) {
                                    if (value!.length == 0)
                                      return 'Please enter Link';
                                    return null;
                                  },
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 3,
                                  minLines: 1,
                                  maxLength: 500,
                                ),
                              ],
                            )
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: SizeConfig.blockSizeVertical !* 1.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _handleRadioValueChangeSendType(0);
                        },
                        child: Row(
                          children: [
                            Radio(
                              value: 0,
                              groupValue: _radioValueSendType,
                              onChanged: _handleRadioValueChangeSendType,
                            ),
                            Text(
                              'Categories',
                              style: TextStyle(
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal !* 4.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _handleRadioValueChangeSendType(1);
                        },
                        child: Row(
                          children: [
                            Radio(
                              value: 1,
                              groupValue: _radioValueSendType,
                              onChanged: _handleRadioValueChangeSendType,
                            ),
                            Text(
                              'Patients',
                              style: TextStyle(
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal !* 4.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                _radioValueSendType == 1
                    ? Row(
                        children: [
                          Spacer(),
                          InkWell(
                            customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                SizeConfig.blockSizeHorizontal !* 10.0,
                              ),
                            ),
                            onTap: () {
                              listPatientsSearchResults.every((element) {
                                element.isChecked = true;
                                return true;
                              });
                              setState(() {
                                allSelected = true;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal !* 3.0,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black,
                                  width: 0.8,
                                ),
                                borderRadius: BorderRadius.circular(5.0),
                                //color: allSelected ? Colors.green : Colors.transparent,
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    "images/ic_check_all.png",
                                    width: SizeConfig.blockSizeHorizontal !* 5.0,
                                    color: Colors.blueGrey,
                                  ),
                                  SizedBox(
                                    width: SizeConfig.blockSizeHorizontal !* 3.0,
                                  ),
                                  Text(
                                    "Select All",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.blueGrey[600],
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal !* 4.0,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal !* 3.0,
                          ),
                          InkWell(
                            customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                SizeConfig.blockSizeHorizontal !* 10.0,
                              ),
                            ),
                            onTap: () {
                              listPatientsSearchResults.every((element) {
                                element.isChecked = false;
                                return true;
                              });
                              setState(() {
                                allSelected = false;
                              });
                            },
                            child: Container(
                                padding: EdgeInsets.all(
                                  SizeConfig.blockSizeHorizontal !* 3.0,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 0.8,
                                  ),
                                  borderRadius: BorderRadius.circular(5.0),
                                  //color: !allSelected ? Colors.green : Colors.transparent,
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      "images/ic_uncheck_all.png",
                                      width:
                                          SizeConfig.blockSizeHorizontal !* 5.0,
                                      color: Colors.blueGrey,
                                    ),
                                    SizedBox(
                                      width:
                                          SizeConfig.blockSizeHorizontal !* 3.0,
                                    ),
                                    Text(
                                      "De-Select All",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: Colors.blueGrey[600],
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal !*
                                                4.0,
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                          Spacer(),
                        ],
                      )
                    : Container(),
                buildWidget(),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: RawMaterialButton(
              padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 2.0),
              onPressed: () {
                getSelectedPatientListAndSubmit(context);
              },
              elevation: 2.0,
              fillColor: Color(0xFF06A759),
              child: Image(
                width: SizeConfig.blockSizeHorizontal !* 5.5,
                height: SizeConfig.blockSizeHorizontal !* 5.5,
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

  _handleRadioValueChangeSendType(int? value) {
    setState(() {
      _radioValueSendType = value!;
    });
  }

  void getLabs() async {
    listPatients = [];
    listPatientsSearchResults = [];
    String loginUrl = "${baseURL}doctorPatientList.php";
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
        listPatients.add(ModelOPDRegistration(
          jo['PatientIDP'].toString(),
          (jo['FName'].toString().trim() +
                  " " +
                  jo['MiddleName'].toString().trim() +
                  " " +
                  jo['LName'].toString().trim())
              .toString()
              .trim(),
          "",
          "",
        ));
      }
      listPatientsSearchResults = listPatients;
      setState(() {});
      apiCalled = true;
      if (listPatientsSelected.length > 0) {
        debugPrint("Inside for loop");
        for (int i = 0; i < listPatientsSearchResults.length; i++) {
          var modelNotSelected = listPatientsSearchResults[i];
          for (int j = 0; j < listPatientsSelected.length; j++) {
            var modelSelected = listPatientsSelected[j];
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

  void getSelectedPatientListAndSubmit(BuildContext context) {
    if (_radioValueSendType == -1) {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select either Categories or Patients type."),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (_radioValueSendType == 0) {
      listCategoriesSelected = [];
      listCategoriesSearchResults.forEach((element) {
        if (element.isChecked!) {
          listCategoriesSelected.add(element);
        }
      });
    } else if (_radioValueSendType == 1) {
      listPatientsSelected = [];
      listPatientsSearchResults.forEach((element) {
        if (element.isChecked!) {
          listPatientsSelected.add(element);
        }
      });
    }
    if (_radioValueSendType == 0) {
      if (listCategoriesSelected.length > 0) {
        if (widget.videoModel == null) {
          if (_formKey.currentState!.validate())
            submitPatientsForNotificationShare(context, listPatients);
        } else
          submitPatientsForVideoShare(context, listCategoriesSelected);
      } else {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text("Please select at least one Category."),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else if (_radioValueSendType == 1) {
      if (listPatientsSelected.length > 0) {
        if (widget.videoModel == null) {
          if (_formKey.currentState!.validate())
            submitPatientsForNotificationShare(context, listPatients);
        } else
          submitPatientsForVideoShare(context, listPatientsSelected);
      } else {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text("Please select at least one Patient."),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  buildWidget() {
    if (!apiCalled) return Container();
    if (apiCalled && getIfListContainsAtleastOneElement()) {
      if (_radioValueSendType == 0)
        return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: listCategoriesSearchResults.length,
            itemBuilder: (context, index) {
              return Padding(
                  padding: EdgeInsets.only(
                    left: SizeConfig.blockSizeHorizontal !* 2,
                    right: SizeConfig.blockSizeHorizontal !* 2,
                    top: SizeConfig.blockSizeHorizontal !* 2,
                  ),
                  child: InkWell(
                    onTap: () {
                      listCategoriesSearchResults[index].isChecked =
                          !listCategoriesSearchResults[index].isChecked!;
                      if (!listCategoriesSearchResults[index].isChecked!) {
                        allSelected = false;
                      }
                      setState(() {});
                    },
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Card(
                              child: Padding(
                            padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal !* 2,
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: listCategoriesSearchResults[index]
                                      .isChecked,
                                  onChanged: (bool? value) {
                                    listCategoriesSearchResults[index]
                                        .isChecked = value!;
                                    setState(() {});
                                  },
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          listCategoriesSearchResults[index]
                                              .name!,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal !*
                                                  4,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            SizeConfig.blockSizeHorizontal !* 1,
                                      ),
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
      else if (_radioValueSendType == 1)
        return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: listPatientsSearchResults.length,
            itemBuilder: (context, index) {
              return Padding(
                  padding: EdgeInsets.only(
                    left: SizeConfig.blockSizeHorizontal !* 2,
                    right: SizeConfig.blockSizeHorizontal !* 2,
                    top: SizeConfig.blockSizeHorizontal !* 2,
                  ),
                  child: InkWell(
                    onTap: () {
                      listPatientsSearchResults[index].isChecked =
                          !listPatientsSearchResults[index].isChecked!;
                      if (!listPatientsSearchResults[index].isChecked!) {
                        allSelected = false;
                      }
                      setState(() {});
                    },
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Card(
                              child: Padding(
                            padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal !* 2,
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: listPatientsSearchResults[index]
                                      .isChecked,
                                  onChanged: (bool? value) {
                                    listPatientsSearchResults[index].isChecked =
                                        value!;
                                    setState(() {});
                                  },
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          listPatientsSearchResults[index].name!,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal !*
                                                  4,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            SizeConfig.blockSizeHorizontal !* 1,
                                      ),
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
    } else {
      if (getIfListContainsAtleastOneElement())
        return Container();
      else
        return Container();
    }
    return Container();
  }

  void submitPatientsForVideoShare(
      BuildContext context, List<ModelOPDRegistration> listPatients) async {
    var jArrayPatientsData = "[";
    for (var i = 0; i < listPatients.length; i++) {
      if (listPatients[i].isChecked!) {
        jArrayPatientsData =
            "$jArrayPatientsData{\"${getParamName()}\":\"${listPatients[i].idp}\"},";
      }
    }
    jArrayPatientsData = jArrayPatientsData + "]";
    jArrayPatientsData = jArrayPatientsData.replaceAll(",]", "]");

    String loginUrl = "${baseURL}doctorSendVideoNotification.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    String doctorIDP = await getPatientOrDoctorIDP();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);

    String jsonStr = "{" +
        "\"DoctorName\":\"${widget.doctorName}\"" +
        ",\"DoctorIDP\":\"$doctorIDP\"" +
        ",\"VideoURL\":\"${widget.videoModel!.webView}\"" +
        ",\"VideoTitle\":\"${widget.videoModel!.iconName}\"" +
        ",\"VideoID\":\"${widget.videoModel!.image}\"" +
        ",\"PatientData\":$jArrayPatientsData" +
        ",\"SendType\":\"${getSendType()}\"" +
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
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      pr!.hide();
      Future.delayed(
        Duration(
          seconds: 2,
        ),
        () {
          Navigator.of(context).pop();
        },
      );
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      pr!.hide();
    }
  }

  void submitPatientsForNotificationShare(
      BuildContext context, List<ModelOPDRegistration> listPatients) async {
    GlobalKey<ProgressDialogWithPercentageState> progressKey = GlobalKey();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ProgressDialogWithPercentage(
            key: progressKey,
          );
        });

    final multipartRequest = MultipartRequest(
      'POST',
      Uri.parse("${baseURL}doctorsendNotification.php"),
      onProgress: (int bytes, int total) {
        final progress = bytes / total;
        progressKey.currentState!.setProgress(progress);
      },
    );

    var jArrayPatientsData = "[";
    for (var i = 0; i < listPatients.length; i++) {
      if (listPatients[i].isChecked!) {
        jArrayPatientsData =
            "$jArrayPatientsData{\"${getParamName()}\":\"${listPatients[i].idp}\"},";
      }
    }
    jArrayPatientsData = jArrayPatientsData + "]";
    jArrayPatientsData = jArrayPatientsData.replaceAll(",]", "]");

    /*ProgressDialog pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr.show();
    });*/
    String doctorIDP = await getPatientOrDoctorIDP();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);

    String jsonStr = "{" +
        "\"DoctorName\":\"${widget.doctorName}\"" +
        ",\"DoctorIDP\":\"$doctorIDP\"" +
        ",\"NotificationType\":\"text\"" +
        ",\"NotificationTitle\":\"${title.text}\"" +
        ",\"NotificationDesc\":\"${description.text}\"" +
        ",\"PatientData\":$jArrayPatientsData" +
        ",\"SendType\":\"${getSendType()}\"" +
        "}";

    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);

    multipartRequest.fields['getjson'] = encodedJSONStr;
    Map<String, String> headers = Map();
    headers['u'] = patientUniqueKey;
    headers['type'] = userType;
    multipartRequest.headers.addAll(headers);
    if (selectedFile != null) {
      var imgLength = await selectedFile!.path.length;
      multipartRequest.files.add(new http.MultipartFile(
          'NotificationImage', selectedFile!.openRead(), imgLength,
          filename: selectedFile!.path));
    }
    var response = await apiHelper.callMultipartApi(multipartRequest);
    //pr.hide();
    debugPrint("Status code - " + response.statusCode.toString());
    response.stream.transform(utf8.decoder).listen((value) async {
      debugPrint("Response of image upload " + value);
      final jsonResponse = json.decode(value);

      ResponseModel model = ResponseModel.fromJSON(jsonResponse);
      String jArrayStr = decodeBase64(jsonResponse['Data']);
      debugPrint("Resonse Upload image ...");
      debugPrint(jArrayStr);
      Navigator.of(context).pop();

      if (model.status == "OK") {
        final snackBar = SnackBar(
          backgroundColor: Colors.green,
          content: Text(model.message!),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Future.delayed(Duration(milliseconds: 300), () {
          Navigator.of(context).pop();
        });
      } else {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text(model.message!),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      //Navigator.of(context).pop();
      debugPrint("response :" + value.toString());
    });

    /*var response = await apiHelper.callApiWithHeadersAndBody(
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
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);*/
  }

  void openDocumentPicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );
    if (result != null) {
      File fileSelected1 = File((result.files.single.path)!);
      if (fileSelected1 != null) selectedFile1 = fileSelected1;
      selectedFileType = "doc";
      // Navigator.of(context).pop();
      setState(() {});
    } else {}
  }

  Future getImageFromGallery() async {
    /*ViewProfileDetailsState.image =
        await ImagePicker.pickImage(source: ImageSource.gallery);*/
    File imgSelected =
        await chooseImageWithExIfRotate(picker, ImageSource.gallery);
    selectedFile = await ImageCropper().cropImage(
        sourcePath: imgSelected.path,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            minimumAspectRatio: 1.0,
          )
        ],
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ]);
    //selectedFile = imgSelected;
    // selectedFileType = "image";
    print(selectedFile!.path);
    // Navigator.of(context).pop();
    setState(() {});
    //if (image != null) submitImageForUpdate(context, image);
    //_controller.add(image);
  }

  bool getIfListContainsAtleastOneElement() {
    if (_radioValueSendType == 0) return listCategories.length > 0;
    if (_radioValueSendType == 1) return listPatients.length > 0;
    return false;
  }

  String getParamName() {
    if (_radioValueSendType == 0)
      return "CategoryName";
    else if (_radioValueSendType == 1) return "PatientIDP";
    return "";
  }

  String getSendType() {
    if (_radioValueSendType == 0)
      return "category";
    else if (_radioValueSendType == 1) return "patient";
    return "";
  }
}
