import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:silvertouch/api/api_helper.dart';
import 'package:silvertouch/app_screens/add_prescription_screen.dart';
import 'package:silvertouch/app_screens/add_vital_screen.dart';
import 'package:silvertouch/app_screens/chat_screen.dart';
import 'package:silvertouch/app_screens/fitness_certificate_screen.dart';
import 'package:silvertouch/app_screens/fullscreen_image.dart';
import 'package:silvertouch/app_screens/opd_reg_details_screen.dart';
import 'package:silvertouch/app_screens/patient_resources_from_profile_screen.dart';
import 'package:silvertouch/app_screens/patient_resources_screen.dart';
import 'package:silvertouch/app_screens/selected_patient_screen.dart';
import 'package:silvertouch/app_screens/view_profile_details_patient_inside_doctor.dart';
import 'package:silvertouch/controllers/consultation_vitals_controller.dart';
import 'package:silvertouch/controllers/pdf_type_controller.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/consultation_template_model.dart';
import 'package:silvertouch/podo/model_certificate.dart';
import 'package:silvertouch/podo/model_health_doc.dart';
import 'package:silvertouch/podo/model_opd_reg.dart';
import 'package:silvertouch/podo/model_templates_advice_investigations.dart';
import 'package:silvertouch/podo/model_templates_complaint.dart';
import 'package:silvertouch/podo/model_templates_diagnosis.dart';
import 'package:silvertouch/podo/model_templates_examination.dart';
import 'package:silvertouch/podo/model_templates_remarks.dart';
import 'package:silvertouch/podo/pdf_type.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/ultimate_slider.dart';
import 'package:silvertouch/widgets/autocomplete_custom.dart';
import 'package:silvertouch/widgets/blinking_text.dart';
import 'package:silvertouch/widgets/extensions.dart';

import '../controllers/certificate_controller.dart';
import '../podo/dropdown_item.dart';
import '../podo/dropdown_item_consultation.dart';
import '../utils/color.dart';
import '../utils/common_methods.dart';
import '../utils/string_resource.dart';
import 'medical_certificate.dart';
import 'select_investigations_to_send_to_lab.dart';

TextEditingController historyController = TextEditingController();


TextEditingController complaintController = TextEditingController();
TextEditingController complaintSupportController = TextEditingController();

TextEditingController examinationController = TextEditingController();
TextEditingController examinationSupportController = TextEditingController();

TextEditingController adviceInvestigationController = TextEditingController();
TextEditingController adviceInvestigationSupportController = TextEditingController();

TextEditingController diagnosisController = TextEditingController();
TextEditingController diagnosisSupportController = TextEditingController();

TextEditingController radiologyInvestigationsController = TextEditingController();
TextEditingController radiologyInvestigationsSupportController = TextEditingController();



TextEditingController systemicIllnessController = TextEditingController();
TextEditingController adviceController = TextEditingController();
TextEditingController nextVisitPlanController = TextEditingController();
TextEditingController followUpDateController = TextEditingController();
TextEditingController followUpTimeController = TextEditingController();


TextEditingController bpSystolicController = TextEditingController();
TextEditingController bpDiastolicController = TextEditingController();
TextEditingController temperatureController = TextEditingController();
TextEditingController pulseController = TextEditingController();
TextEditingController spo2Controller = TextEditingController();

TextEditingController remarksController = TextEditingController();
TextEditingController referredDoctorController = TextEditingController();
TextEditingController referredDoctorNameController = TextEditingController();
TextEditingController referredDoctorMobileController = TextEditingController();
TextEditingController referenceNoteController = TextEditingController();
TextEditingController internalNotesController = TextEditingController();

List<ModelOPDRegistration> listInvestigationsResults = [];
List<ModelOPDRegistration> listRadiologyInvestigationsResults = [];
List<ConsultationTemplateModel> listConsultationTemplates = [];
List<AdviceInvestigationTemplateModel> listTemplates = [];
List<RemarksTemplateModel> listRemarks = [];
List<ComplaintTemplateModel> listComplaints = [];
List<ExaminationTemplateModel> listExamination = [];
List<DiagnosisTemplateModel> listDiagnosis = [];
List<ModelOPDRegistration> listOPDRegistrationSelected = [];

List<ModelOPDRegistration> listSendToLabInvestigationsResults = [];

List<String> listComplaintDetails = [];
List<String> listExaminationDetails = [];
List<String> listDiagnosisDetails = [];
List<String> listRadiologyDetails = [];
List<String> listPathologyDetails = [];


List<String> _selectedComplaints = [];
List<String> _selectedExamination = [];
List<String> _selectedDiagnosis = [];
List<String> _selectedAdviceInvestigation = [];
List<String> _selectedRadiologyInvestigations = [];


// ScrollController _scrollController = new ScrollController();

double pulseValue = 20,
    bpSystolicValue = 30,
    bpDiastolicValue = 10,
    spo2Value = 0;

double tempValue = 90;

double weightValue = 0, heightValue = 0;

var pickedDate = DateTime.now();
var pickedTime = TimeOfDay.now();

bool markAsCheckout = false;
bool vitalsVisible = false;
String totalServices = "";
bool initialState = true;

dynamic jsonConsultation = {};
String heightInFeet = "0 Ft  0 In";

ProgressDialog? pr;
String paymentDueStatus = "";
var isCertificate = '';
var certId = '';
var isCamp = '0';
// For Doctor Referred Dropdown
DropDownItemConsultation selectedReferredDoctor = DropDownItemConsultation(idp:"", value:"");
var selectedReferredDoctorId = '-';
List<DropDownItemConsultation> listReferredDoctor = [];
List<DropDownItemConsultation> listReferredDoctorSearchResults = [];

class AddConsultationScreen extends StatefulWidget {
  final String idp, patientIDP;
  ModelOPDRegistration modelOPDRegistration;
  ConsultationVitalsController consultationVitalsController =
  Get.put(ConsultationVitalsController());

  String imgUrl = "",
      fullName = "",
      patientID = "",
      gender = "",
      age = "",
      cityName = "";

  String? from = "",
      appointmentDate = "";

  AddConsultationScreen(this.idp, this.patientIDP, this.modelOPDRegistration,
      {this.from, this.appointmentDate});

  @override
  State<StatefulWidget> createState() {
    return AddConsultationScreenState();
  }
}

class AddConsultationScreenState extends State<AddConsultationScreen> {
  final String urlFetchPatientProfileDetails =
      "${baseURL}patientProfileData.php";
  ScrollController _scrollController = new ScrollController();
  var taskId;
  String firstEditStatus = "0";
  PdfTypeController pdfTypeController = Get.put(PdfTypeController());
  ApiHelper apiHelper = ApiHelper();
  String healthRecordsDisplayStatus = "", notificationDisplayStatus = "";
  String slashFormatted = "";
  bool notify = false;
  String clearedFromDueStatus = "", paymentDueStatus = "";
  List<PdfType> listPdfType = [];
  double dueAmount = 0;
  bool isCheckedSendToLab = false;
  List<ModelCertificate> certList = [];
  List<ModelHealthDoc> healthDocList = [];
  String selectedReferredDoctorId1 = "";

  @override
  void initState() {
    super.initState();
    selectedReferredDoctorId = '-';
    widget.consultationVitalsController.reset();
    jsonConsultation = {};
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
    historyController = TextEditingController();
    complaintController = TextEditingController();
    diagnosisController = TextEditingController();
    systemicIllnessController = TextEditingController();
    examinationController = TextEditingController();
    adviceController = TextEditingController();
    nextVisitPlanController = TextEditingController();
    followUpDateController = TextEditingController();
    followUpTimeController = TextEditingController();
    bpSystolicController = TextEditingController();
    bpDiastolicController = TextEditingController();
    temperatureController = TextEditingController();
    pulseController = TextEditingController();
    spo2Controller = TextEditingController();
    radiologyInvestigationsController = TextEditingController();
    adviceInvestigationController = TextEditingController();
    remarksController = TextEditingController();
    referredDoctorController = TextEditingController();
    referredDoctorNameController = TextEditingController();
    referredDoctorMobileController = TextEditingController();
    referenceNoteController = TextEditingController();
    listInvestigationsResults = [];
    markAsCheckout = false;
    vitalsVisible = false;
    pickedDate = DateTime.now();

    /*var formatter = new DateFormat('dd-MM-yyyy');
    String formatted = formatter.format(pickedDate);
    followUpDateController = TextEditingController(text: formatted);*/

    pulseValue = 80;
    bpSystolicValue = 100;
    bpDiastolicValue = 70;
    tempValue = 98;
    spo2Value = 97;

    final now = new DateTime.now();
    var dateOfTime =
    DateTime(now.year, now.month, now.day, now.hour, now.minute);

    var slashFormatter = new DateFormat('dd/MM/yyyy');
    slashFormatted = slashFormatter.format(now);
    debugPrint("formatted appt date");
    debugPrint(slashFormatted);

    pickedTime = TimeOfDay.now();
    getRadiologyList(context);
    getPathologyList(context);
    getExaminationList(context);
    getComplaintList(context);
    getDiagnosisList(context);

    var formatterTime = new DateFormat('HH:mm');
    String formattedTime = formatterTime.format(dateOfTime);
    debugPrint("formatted time");
    debugPrint(formattedTime);
    followUpTimeController = TextEditingController(text: formattedTime);
    getPatientProfileDetails();
    getCertificates();
    getMaterials();
    getTemplatesForConsultation();
    getTemplatesForAdviceInvestigations();
    getTemplatesForRemarks();
    getTemplatesForComplaint();
    getTemplatesForExamination();
    getTemplatesForDiagnosis();

    getReferredDoctorList();
    getConsultationDetails(context);


    setState(() {});
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    _scrollController.dispose();
    super.dispose();
  }

  void getReferredDoctorList() async {
    print('getReferredDoctorList');
    String loginUrl = "${baseURL}doctorRefferedList.php";
    ProgressDialog pr = ProgressDialog(context);
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr.show();
    });
    //listIcon = new List();

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
    pr.hide();
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      listReferredDoctor = [];
      listReferredDoctorSearchResults = [];
      listReferredDoctor.add(DropDownItemConsultation(idp: '-1', value: 'Other'));
      listReferredDoctorSearchResults.add(DropDownItemConsultation(idp: '-1', value: 'Other'));
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listReferredDoctor.add(DropDownItemConsultation(idp: jo['DoctorIDP'].toString(),
            value: jo['FirstName'] + " " + jo['LastName']));
        listReferredDoctorSearchResults.add(DropDownItemConsultation(
            idp: jo['DoctorIDP'].toString(),
            value: jo['FirstName'] + " " + jo['LastName']));
      }
      setState(() {});
    }
  }

  showVideoCallRequestDialog(
      BuildContext context, String patientIDP, patientName, doctorImage) {
    var title = "Do you want to send Video call request?";
    showDialog(
        context: context,
        barrierDismissible: false,
        // user must tap button for close dialog!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "No",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    requestVideoCallFromDoctor(
                        patientIDP, patientName, doctorImage);
                  },
                  child: Text("Yes"))
            ],
          );
        });
  }

  void requestVideoCallFromDoctor(
      String patientIDP, String patientName, String doctorImage) async {
    final String urlGetChannelIDForVidCall = "${baseURL}videocallRequest.php";
    ProgressDialog pr = ProgressDialog(context);
    pr.show();

    try {
      String patientUniqueKey = await getPatientUniqueKey();
      String userType = await getUserType();
      String doctorIDP = await getPatientOrDoctorIDP();
      debugPrint("Key and type");
      debugPrint(patientUniqueKey);
      debugPrint(userType);
      String fromType = "";
      if (userType == "patient") {
        fromType = "P";
      } else if (userType == "doctor") {
        fromType = "D";
      }
      String jsonStr = "{" +
          "\"PatientIDP\":\"$patientIDP\"" +
          ",\"DoctorIDP\":\"$doctorIDP\"" +
          ",\"messagefrom\":\"$fromType\"" +
          "}";

      debugPrint(jsonStr);

      String encodedJSONStr = encodeBase64(jsonStr);
      var response = await apiHelper.callApiWithHeadersAndBody(
        url: urlGetChannelIDForVidCall,
        //Uri.parse(loginUrl),
        headers: {
          "u": patientUniqueKey,
          "type": userType,
        },
        body: {"getjson": encodedJSONStr},
      );
      debugPrint(response.body.toString());
      final jsonResponse = json.decode(response.body.toString());
      ResponseModel model = ResponseModel.fromJSON(jsonResponse);
      pr.hide();
      if (model.status == "OK") {
        var data = jsonResponse['Data'];
        var strData = decodeBase64(data);
        debugPrint("Decoded Data Array : " + strData);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return ChatScreen(
              patientIDP: patientIDP,
              patientName: patientName,
              patientImage: doctorImage,
            );
          },
        ));
      } else {}
    } catch (exception) {}
  }

  @override
  Widget build(BuildContext context) {
    var certController = Get.put(CertificateController());
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: (){
        _selectedComplaints.clear();
        _selectedExamination.clear();
        _selectedDiagnosis.clear();
        _selectedAdviceInvestigation.clear();
        _selectedRadiologyInvestigations.clear();

        return Future.value(true); // Return true or false based on your condition
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Add Consultation"),
          iconTheme: IconThemeData(color: Colorsblack),
          actions: [
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return ChatScreen(
                    patientIDP: widget.patientIDP,
                    patientName: widget.modelOPDRegistration.name,
                    patientImage: "",
                  );
                }));
              },
              customBorder: CircleBorder(),
              child: Container(
                padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 2.0),
                /*decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),*/
                child: Image(
                  width: SizeConfig.blockSizeHorizontal !* 5.5,
                  color: Colors.black,
                  //height: 80,
                  image: AssetImage("images/ic_chat.png"),
                ),
              ),
            ),
            SizedBox(
              width: SizeConfig.blockSizeHorizontal !* 2.0,
            ),
            InkWell(
                onTap: () {
                  showVideoCallRequestDialog(context, widget.patientIDP,
                      widget.modelOPDRegistration.name, "");
                },
                customBorder: CircleBorder(),
                child: Container(
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 2.0),
                  /*decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),*/
                  child: Image(
                    width: SizeConfig.blockSizeHorizontal !* 5.5,
                    color: Colors.black,
                    //height: 80,
                    image: AssetImage("images/ic_video_consultation.png"),
                  ),
                )),
            SizedBox(
              width: SizeConfig.blockSizeHorizontal !* 2.0,
            ),
          ], toolbarTextStyle: TextTheme(
            titleMedium: TextStyle(
              color: Colorsblack,
              fontFamily: "Ubuntu",
              fontSize: SizeConfig.blockSizeVertical !* 2.5,
            )).bodyMedium, titleTextStyle: TextTheme(
            titleMedium: TextStyle(
              color: Colorsblack,
              fontFamily: "Ubuntu",
              fontSize: SizeConfig.blockSizeVertical !* 2.5,
            )).titleLarge,
        ),
        body: Builder(
          builder: (context) {
            return Column(
              children: <Widget>[
                Container(
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 7,
                      ),
                      Expanded(
                        child: Card(
                          elevation: 0,
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) {
                                                    return FullScreenImage(
                                                        "$userImgUrl${widget.imgUrl}");
                                                  }));
                                        },
                                        child: CircleAvatar(
                                          radius: SizeConfig.blockSizeHorizontal !*
                                              6.5,
                                          backgroundColor: colorBlueApp,
                                          child: (widget.imgUrl != "") ?
                                          CircleAvatar(
                                              radius: SizeConfig.blockSizeHorizontal !* 6,
                                              backgroundColor: Colors.grey,
                                              backgroundImage: NetworkImage("$userImgUrl${widget.imgUrl}")) :
                                          CircleAvatar(
                                              radius: SizeConfig.blockSizeHorizontal !* 6,
                                              backgroundColor: Colors.grey,
                                              backgroundImage: AssetImage("images/ic_user_placeholder.png")
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: SizeConfig.blockSizeVertical !* 5,
                                      ),
                                      isCamp == '1'
                                          ? Image.asset('images/ic_camp.png',
                                          scale: 25, color: colorBlueApp)
                                          : Container()
                                    ],
                                  ),
                                  SizedBox(
                                    width: SizeConfig.blockSizeHorizontal !* 5,
                                  ),
                                  Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical:
                                            SizeConfig.blockSizeHorizontal !*
                                                1.5),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              widget.fullName,
                                              style: TextStyle(
                                                  color: colorBlueApp,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: SizeConfig
                                                      .blockSizeHorizontal !*
                                                      4),
                                            ),
                                            SizedBox(
                                              height:
                                              SizeConfig.blockSizeVertical !*
                                                  1,
                                            ),
                                            Row(
                                                children: <Widget>[
                                                  Text(
                                                    "ID - ${widget.patientID}",
                                                    style: TextStyle(
                                                      fontSize: SizeConfig
                                                          .blockSizeHorizontal !*
                                                          3.5,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: SizeConfig
                                                        .blockSizeHorizontal !*
                                                        5,
                                                  ),
                                                  Text(
                                                    "${widget.gender}/${widget.age}",
                                                    style: TextStyle(
                                                      fontSize: SizeConfig
                                                          .blockSizeHorizontal !*
                                                          3.5,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  /*VerticalDivider(
                                    color: Colors.grey,
                                  ),*/
                                                  SizedBox(
                                                    width: SizeConfig
                                                        .blockSizeHorizontal !*
                                                        5,
                                                  ),
                                                  Text(
                                                    widget.cityName,
                                                    style: TextStyle(
                                                        fontSize: SizeConfig
                                                            .blockSizeHorizontal !*
                                                            3.5,
                                                        color: Colors.grey),
                                                  ),
                                                ]),
                                          ],
                                        )),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: SizeConfig.blockSizeVertical !* 0.6,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    right: SizeConfig.blockSizeHorizontal !* 3),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width:
                                      SizeConfig.blockSizeHorizontal !* 17.0,
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                                    return SelectedPatientScreen(
                                                      widget.patientIDP,
                                                      healthRecordsDisplayStatus,
                                                      "consultation_${widget.patientIDP}",
                                                      notificationDisplayStatus:
                                                      notificationDisplayStatus,
                                                    );
                                                  }));
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(
                                                  SizeConfig.blockSizeHorizontal !*
                                                      1),
                                              decoration: BoxDecoration(
                                                  color: colorBlueApp,
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(10))),
                                              child: Text(
                                                "View Records",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width:
                                              SizeConfig.blockSizeHorizontal !*
                                                  1,
                                            ),
                                            /*Image(
                                              image: AssetImage(
                                                  "images/ic_right_arrow_double.png"),
                                              width:
                                                  SizeConfig.blockSizeHorizontal *
                                                      2.0,
                                              color: Colors.blue,
                                            ),*/
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                                    return ViewProfileDetailsInsideDoctor(
                                                        widget.patientIDP);
                                                  }));
                                          //ViewProfileDetailsInsideDoctor
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "View Profile",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: Colors.blue,
                                              ),
                                            ),
                                            SizedBox(
                                              width:
                                              SizeConfig.blockSizeHorizontal !*
                                                  1,
                                            ),
                                            /*Image(
                                              image: AssetImage(
                                                  "images/ic_right_arrow_double.png"),
                                              width:
                                                  SizeConfig.blockSizeHorizontal *
                                                      2.0,
                                              color: Colors.blue,
                                            ),*/
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical !* 2,
                ),
                /*Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Notify me upon entry of health records",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                        letterSpacing: 1.3,
                      ),
                    ),
                    Switch(
                      activeColor: Colors.green,
                      value: notify,
                      onChanged: (isOn) {
                        setState(() {
                          notify = isOn;
                        });
                      },
                    ),
                  ],
                ),*/
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xFF06A759),
                            borderRadius: BorderRadius.all(Radius.circular(10))),
                        margin: EdgeInsets.only(
                            left: SizeConfig.blockSizeHorizontal !* 3,
                            right: SizeConfig.blockSizeHorizontal !* 3),
                        child: MaterialButton(
                            elevation: 0,
                            child: Row(
                              children: [
                                Image(
                                  image: AssetImage(
                                    "images/icn-template.png",
                                  ),
                                  width: SizeConfig.blockSizeHorizontal !* 5,
                                  height: SizeConfig.blockSizeHorizontal !* 5,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: SizeConfig.blockSizeHorizontal !* 2.0,
                                ),
                                Flexible(
                                  child: Text(
                                    "Consultation\nTemplate",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                      SizeConfig.blockSizeHorizontal !* 3.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            minWidth: double.maxFinite,
                            color: Color(0xFF06A759),
                            onPressed: () async {
                              var patientIDP = await getPatientOrDoctorIDP();
                              if (selectedPatientOfSameDate()) {
                                showTemplateSelectionDialog(
                                    context, "Con", setStateOfParent);
                              }
                            }),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xFF06A759),
                            borderRadius: BorderRadius.all(Radius.circular(10))),
                        margin: EdgeInsets.only(
                            left: SizeConfig.blockSizeHorizontal !* 3,
                            right: SizeConfig.blockSizeHorizontal !* 3),
                        child: MaterialButton(
                            child: Row(
                              children: [
                                Image(
                                  image: AssetImage(
                                    "images/icn-add-prescription.png",
                                  ),
                                  width: SizeConfig.blockSizeHorizontal !* 5,
                                  height: SizeConfig.blockSizeHorizontal !* 5,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: SizeConfig.blockSizeHorizontal !* 2.0,
                                ),
                                Flexible(
                                  child: Text(
                                    "Add\nPrescription",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                      SizeConfig.blockSizeHorizontal !* 3.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            elevation: 0,
                            minWidth: double.maxFinite,
                            color: Color(0xFF06A759),
                            onPressed: () async {
                              var patientIDP = await getPatientOrDoctorIDP();
                              if (selectedPatientOfSameDate()) {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return AddPrescriptionScreen(
                                    patientIDP,
                                    widget.idp,
                                    widget.imgUrl,
                                    widget.fullName,
                                    widget.patientID,
                                    widget.gender,
                                    widget.age,
                                    widget.cityName,
                                    // widget.campID,
                                  );
                                }));
                              }
                            }),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    children: <Widget>[
                      SizedBox(
                        height: SizeConfig.blockSizeVertical !* 1,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.blockSizeHorizontal !* 3),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              vitalsVisible = !vitalsVisible;
                            });
                          },
                          child: Container(
                            color: const Color(0xFFeef2df),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: SizeConfig.blockSizeHorizontal !* 3,
                                  vertical: SizeConfig.blockSizeVertical !* 0.5),
                              child: Row(
                                children: [
                                  Text(
                                    "Vitals",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                        SizeConfig.blockSizeHorizontal !* 4.2),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Icon(
                                        vitalsVisible
                                            ? Icons.arrow_drop_up
                                            : Icons.arrow_drop_down,
                                        size: SizeConfig.blockSizeHorizontal !* 8,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: vitalsVisible,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.blockSizeHorizontal !* 3),
                          child: Container(
                            color: const Color(0x70eef2df),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: SizeConfig.blockSizeVertical !* 1,
                                ),
                                Row(
                                  children: [
                                    SliderWidget(
                                      min: 30,
                                      max: 300,
                                      value: bpSystolicValue.toDouble(),
                                      title: "BP Systolic",
                                      unit: "mm of hg",
                                      selectedPatientOfSameDate:
                                      selectedPatientOfSameDate,
                                    ),
                                  ],
                                ),
                                SliderWidget(
                                  min: 10,
                                  max: 200,
                                  value: bpDiastolicValue.toDouble(),
                                  title: "BP Diastolic",
                                  unit: "mm of hg",
                                  selectedPatientOfSameDate:
                                  selectedPatientOfSameDate,
                                ),
                                SliderWidget(
                                  min: 0,
                                  max: 100,
                                  value: spo2Value.toDouble(),
                                  title: "SPO2",
                                  unit: "%",
                                  selectedPatientOfSameDate:
                                  selectedPatientOfSameDate,
                                ),
                                SliderWidget(
                                  min: 20,
                                  max: 250,
                                  value: pulseValue.toDouble(),
                                  title: "Pulse",
                                  unit: "per min.",
                                  selectedPatientOfSameDate:
                                  selectedPatientOfSameDate,
                                ),
                                SliderWidget(
                                  min: 90,
                                  max: 105,
                                  value: tempValue,
                                  title: "Temperature",
                                  unit: "per min.",
                                  selectedPatientOfSameDate:
                                  selectedPatientOfSameDate,
                                  isDecimal: true,
                                ),
                                // SliderWidget(
                                //   min: 0,
                                //   max: 200,
                                //   value: heightValue.toDouble(),
                                //   title: "Height",
                                //   unit: "Cm",
                                //   callbackFromBMI: setStateOfParent,
                                //   selectedPatientOfSameDate:
                                //       selectedPatientOfSameDate,
                                // ),
                                // SliderWidget(
                                //   min: 0,
                                //   max: 120,
                                //   value: weightValue.toDouble(),
                                //   title: "Weight",
                                //   unit: "Kg",
                                //   callbackFromBMI: setStateOfParent,
                                //   selectedPatientOfSameDate:
                                //       selectedPatientOfSameDate,
                                // ),
                                /*Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          SizeConfig.blockSizeHorizontal * 8),
                                  child: TextField(
                                    enabled:
                                        jsonConsultation['CheckOutStatus'] == "0",
                                    controller: temperatureController,
                                    style: TextStyle(color: Colors.green),
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(color: Colors.black),
                                      labelStyle: TextStyle(color: Colors.black),
                                      labelText: "Temperature",
                                      hintText: "",
                                      counterText: "",
                                    ),
                                  ),
                                ),*/
                                SizedBox(
                                  height: SizeConfig.blockSizeVertical !* 2.5,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical !* 2,
                      ),
                      Padding(
                        padding:
                        EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                              onTap: () {
                                if (isCertificate.length > 0) {
                                  certController
                                      .viewCertificate(
                                      widget.patientIDP, certId, context)
                                      .then((value) {
                                    if (value.length > 0) {
                                      downloadAndOpenTheFile(
                                          "$certificateUrl$value", value);
                                    }
                                  });
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Certificate List'),
                                          content: showCertificates(),
                                        );
                                      });
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: colorBlueApp,
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                                padding: EdgeInsets.all(
                                    SizeConfig.blockSizeHorizontal !* 3),
                                child: Text(
                                  isCertificate.length > 0
                                      ? 'View Certificate'
                                      : 'Issue Certificate',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                      SizeConfig.blockSizeVertical !* 2.1),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) =>
                                        PatientResourcesFromProfileScreen(patientIDP: widget.patientIDP,)));
                                // showDialog(
                                //     context: context,
                                //     builder: (BuildContext context) {
                                //       return AlertDialog(
                                //         title: Text('Material List'),
                                //         content: showMaterial(certController),
                                //       );
                                //     });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: colorBlueApp,
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                                padding: EdgeInsets.all(
                                    SizeConfig.blockSizeHorizontal !* 3),
                                child: Text(
                                  'Patient Resources',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                      SizeConfig.blockSizeVertical !* 2.1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: SizeConfig.blockSizeVertical !* 5,
                                horizontal: SizeConfig.blockSizeHorizontal !* 3),
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Container(
                                        width: SizeConfig.blockSizeVertical !* 40,
                                        child:
                                        TypeAheadField<String>(
                                          textFieldConfiguration: TextFieldConfiguration(
                                            controller: complaintSupportController,
                                            enabled:
                                            jsonConsultation['CheckOutStatus'] == "0" &&
                                                selectedPatientOfSameDate(),
                                            decoration: InputDecoration(
                                              labelText: 'Complaints',
                                              // border: OutlineInputBorder(),
                                            ),
                                          ),
                                          // suggestionsCallback: (pattern) {
                                          //   return listComplaintDetails.where((listComplaintDetails) =>
                                          //       listComplaintDetails.toLowerCase().contains(pattern.toLowerCase()));
                                          // },
                                          suggestionsCallback: (pattern) {
                                            // Always return the full list of options
                                            // return listComplaintDetails;

                                            return listComplaintDetails.where((listComplaintDetails) =>
                                                listComplaintDetails.toLowerCase().contains(pattern.toLowerCase()));
                                          },
                                          itemBuilder: (context,String  suggestion) {
                                            return ListTile(
                                              title: Text(suggestion),
                                            );
                                          },
                                          onSuggestionSelected: (String suggestion) {
                                            setState(() {
                                              setState(() {
                                                // complaintSupportController.clear();
                                                _selectedComplaints.add(suggestion);
                                              });
                                            });
                                          },
                                        )
                                      // CustomAutocompleteSearch1(
                                      //   suggestions: listComplaintDetails,
                                      //     enabled:
                                      //     jsonConsultation['CheckOutStatus'] == "0" &&
                                      //         selectedPatientOfSameDate(),
                                      //     hint: "Complaint",
                                      //     controller: complaintController,
                                      //     hideSuggestionsOnCreate: true,
                                      //     onSelected: (text) => selectedFieldComplaint(
                                      //         context, complaintController, text,_selectedOptions ),
                                      //     onTap: () {
                                      //       if (onTapStatus != "Tapped") {
                                      //         _scrollController.animateTo(
                                      //             _scrollController
                                      //                 .position.maxScrollExtent,
                                      //             duration:
                                      //             Duration(milliseconds: 500),
                                      //             curve: Curves.easeOut);
                                      //         onTapStatus = "Tapped";
                                      //       }
                                      //     },
                                      // ),
                                    ),
                                    SizedBox(height: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context).size.width -50, // Set maximum width
                                          ),
                                          child:
                                          Wrap(
                                            spacing: 8.0,
                                            runSpacing: 4.0,
                                            children: _selectedComplaints
                                                .map(
                                                  (String option) => Chip(
                                                label: Text(option),
                                                onDeleted: () {
                                                  setState(() {
                                                    _selectedComplaints.remove(option);
                                                  });
                                                },
                                              ),
                                            )
                                                .toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // TextField(
                                //   controller: complaintController,
                                //   enabled:
                                //       jsonConsultation['CheckOutStatus'] == "0" &&
                                //           selectedPatientOfSameDate(),
                                //   style: TextStyle(color: Colors.green),
                                //   decoration: InputDecoration(
                                //     hintStyle: TextStyle(color: Colors.black),
                                //     labelStyle: TextStyle(color: darkgrey),
                                //     labelText: "Complaint",
                                //     hintText: "",
                                //     counterText: "",
                                //   ),
                                //   keyboardType: TextInputType.multiline,
                                //   maxLines: 5,
                                //   minLines: 5,
                                //   maxLength: 500,
                                // ),
                                InkWell(
                                  onTap: () {
                                    if (jsonConsultation['CheckOutStatus'] ==
                                        "0" &&
                                        selectedPatientOfSameDate()) {
                                      showTemplateSelectionDialog(
                                          context, "C", setStateOfParent);
                                    }
                                  },
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Icon(Icons.add_box_rounded),
                                    // Container(
                                    //   margin: EdgeInsets.only(
                                    //       top:
                                    //           SizeConfig.blockSizeHorizontal !* 2),
                                    //   decoration: BoxDecoration(
                                    //       border: Border.all(
                                    //         color: colorBlueApp,
                                    //       ),
                                    //       color: white,
                                    //       borderRadius: BorderRadius.all(
                                    //           Radius.circular(10))),
                                    //   child: Padding(
                                    //     padding: EdgeInsets.all(
                                    //         SizeConfig.blockSizeHorizontal !* 3),
                                    //     child: Text(
                                    //       "From Templates",
                                    //       style: TextStyle(
                                    //         color: colorBlueApp,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                  ),
                                ),
                              ],
                            )),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: SizeConfig.blockSizeVertical !* 5,
                                horizontal: SizeConfig.blockSizeHorizontal !* 3),
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Container(
                                        width: SizeConfig.blockSizeVertical !* 40,
                                        child:
                                        TypeAheadField<String>(
                                          textFieldConfiguration: TextFieldConfiguration(
                                            controller: examinationSupportController,
                                            enabled:
                                            jsonConsultation['CheckOutStatus'] == "0" &&
                                                selectedPatientOfSameDate(),
                                            decoration: InputDecoration(
                                              labelText: 'Examinations',
                                              // border: OutlineInputBorder(),
                                            ),
                                          ),
                                          suggestionsCallback: (pattern) {
                                            // Always return the full list of options
                                            // return listExaminationDetails;

                                            return listExaminationDetails.where((listExaminationDetails) =>
                                                listExaminationDetails.toLowerCase().contains(pattern.toLowerCase()));
                                          },
                                          itemBuilder: (context,String  suggestion) {
                                            return ListTile(
                                              title: Text(suggestion),
                                            );
                                          },
                                          onSuggestionSelected: (String suggestion) {
                                            setState(() {
                                              setState(() {
                                                // complaintSupportController.clear();
                                                _selectedExamination.add(suggestion);
                                              });
                                            });
                                          },
                                        )
                                      // CustomAutocompleteSearch1(
                                      //   suggestions: listComplaintDetails,
                                      //     enabled:
                                      //     jsonConsultation['CheckOutStatus'] == "0" &&
                                      //         selectedPatientOfSameDate(),
                                      //     hint: "Complaint",
                                      //     controller: complaintController,
                                      //     hideSuggestionsOnCreate: true,
                                      //     onSelected: (text) => selectedFieldComplaint(
                                      //         context, complaintController, text,_selectedOptions ),
                                      //     onTap: () {
                                      //       if (onTapStatus != "Tapped") {
                                      //         _scrollController.animateTo(
                                      //             _scrollController
                                      //                 .position.maxScrollExtent,
                                      //             duration:
                                      //             Duration(milliseconds: 500),
                                      //             curve: Curves.easeOut);
                                      //         onTapStatus = "Tapped";
                                      //       }
                                      //     },
                                      // ),
                                    ),
                                    SizedBox(height: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context).size.width -50, // Set maximum width
                                          ),
                                          child:
                                          Wrap(
                                            spacing: 8.0,
                                            runSpacing: 4.0,
                                            children: _selectedExamination
                                                .map(
                                                  (String option) => Chip(
                                                label: Text(option),
                                                onDeleted: () {
                                                  setState(() {
                                                    _selectedExamination.remove(option);
                                                  });
                                                },
                                              ),
                                            )
                                                .toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // TextField(
                                //   controller: examinationController,
                                //   enabled:
                                //       jsonConsultation['CheckOutStatus'] == "0" &&
                                //           selectedPatientOfSameDate(),
                                //   style: TextStyle(color: Colors.green),
                                //   decoration: InputDecoration(
                                //     hintStyle: TextStyle(color: Colors.black),
                                //     labelStyle: TextStyle(color: darkgrey),
                                //     labelText: "Examination",
                                //     hintText: "",
                                //     counterText: "",
                                //   ),
                                //   maxLines: 5,
                                //   minLines: 5,
                                //   maxLength: 500,
                                // ),
                                InkWell(
                                  onTap: () {
                                    if (jsonConsultation['CheckOutStatus'] ==
                                        "0" &&
                                        selectedPatientOfSameDate()) {
                                      showTemplateSelectionDialog(
                                          context, "E", setStateOfParent);
                                    }
                                  },
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Icon(Icons.add_box_rounded),
                                    // Container(
                                    //   margin: EdgeInsets.only(
                                    //       top:
                                    //           SizeConfig.blockSizeHorizontal !* 2),
                                    //   decoration: BoxDecoration(
                                    //       border: Border.all(
                                    //         color: colorBlueApp,
                                    //       ),
                                    //       color: white,
                                    //       borderRadius: BorderRadius.all(
                                    //           Radius.circular(10))),
                                    //   child: Padding(
                                    //     padding: EdgeInsets.all(
                                    //         SizeConfig.blockSizeHorizontal !* 3),
                                    //     child: Text(
                                    //       "From Templates",
                                    //       style: TextStyle(
                                    //         color: colorBlueApp,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                  ),
                                ),
                              ],
                            )),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: SizeConfig.blockSizeVertical !* 5,
                                horizontal: SizeConfig.blockSizeHorizontal !* 3),
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Container(
                                        width: SizeConfig.blockSizeVertical !* 40,
                                        child:
                                        TypeAheadField<String>(
                                          textFieldConfiguration: TextFieldConfiguration(
                                            controller: diagnosisSupportController,
                                            enabled:
                                            jsonConsultation['CheckOutStatus'] == "0" &&
                                                selectedPatientOfSameDate(),
                                            decoration: InputDecoration(
                                              labelText: 'Diagnosis',
                                              // border: OutlineInputBorder(),
                                            ),
                                          ),
                                          suggestionsCallback: (pattern) {
                                            // Always return the full list of options
                                            // return listDiagnosisDetails;

                                            return listDiagnosisDetails.where((listDiagnosisDetails) =>
                                                listDiagnosisDetails.toLowerCase().contains(pattern.toLowerCase()));
                                          },
                                          itemBuilder: (context,String  suggestion) {
                                            return ListTile(
                                              title: Text(suggestion),
                                            );
                                          },
                                          onSuggestionSelected: (String suggestion) {
                                            setState(() {
                                              setState(() {
                                                // complaintSupportController.clear();
                                                _selectedDiagnosis.add(suggestion);
                                              });
                                            });
                                          },
                                        )
                                      // CustomAutocompleteSearch1(
                                      //   suggestions: listComplaintDetails,
                                      //     enabled:
                                      //     jsonConsultation['CheckOutStatus'] == "0" &&
                                      //         selectedPatientOfSameDate(),
                                      //     hint: "Complaint",
                                      //     controller: complaintController,
                                      //     hideSuggestionsOnCreate: true,
                                      //     onSelected: (text) => selectedFieldComplaint(
                                      //         context, complaintController, text,_selectedOptions ),
                                      //     onTap: () {
                                      //       if (onTapStatus != "Tapped") {
                                      //         _scrollController.animateTo(
                                      //             _scrollController
                                      //                 .position.maxScrollExtent,
                                      //             duration:
                                      //             Duration(milliseconds: 500),
                                      //             curve: Curves.easeOut);
                                      //         onTapStatus = "Tapped";
                                      //       }
                                      //     },
                                      // ),
                                    ),
                                    SizedBox(height: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context).size.width -50, // Set maximum width
                                          ),
                                          child:
                                          Wrap(
                                            spacing: 8.0,
                                            runSpacing: 4.0,
                                            children: _selectedDiagnosis
                                                .map(
                                                  (String option) => Chip(
                                                label: Text(option),
                                                onDeleted: () {
                                                  setState(() {
                                                    _selectedDiagnosis.remove(option);
                                                  });
                                                },
                                              ),
                                            )
                                                .toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // TextField(
                                //   controller: diagnosisController,
                                //   enabled:
                                //       jsonConsultation['CheckOutStatus'] == "0" &&
                                //           selectedPatientOfSameDate(),
                                //   style: TextStyle(color: Colors.green),
                                //   decoration: InputDecoration(
                                //     hintStyle: TextStyle(color: Colors.black),
                                //     labelStyle: TextStyle(color: darkgrey),
                                //     labelText: "Diagnosis",
                                //     hintText: "",
                                //     counterText: "",
                                //   ),
                                //   maxLines: 5,
                                //   minLines: 5,
                                //   maxLength: 500,
                                // ),
                                InkWell(
                                  onTap: () {
                                    if (jsonConsultation['CheckOutStatus'] ==
                                        "0" &&
                                        selectedPatientOfSameDate()) {
                                      showTemplateSelectionDialog(
                                          context, "D", setStateOfParent);
                                    }
                                  },
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Icon(Icons.add_box_rounded),
                                    // Container(
                                    //   margin: EdgeInsets.only(
                                    //       top:
                                    //           SizeConfig.blockSizeHorizontal !* 2),
                                    //   decoration: BoxDecoration(
                                    //       border: Border.all(
                                    //         color: colorBlueApp,
                                    //       ),
                                    //       color: white,
                                    //       borderRadius: BorderRadius.all(
                                    //           Radius.circular(10))),
                                    //   child: Padding(
                                    //     padding: EdgeInsets.all(
                                    //         SizeConfig.blockSizeHorizontal !* 3),
                                    //     child: Text(
                                    //       "From Templates",
                                    //       style: TextStyle(
                                    //         color: colorBlueApp,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                  ),
                                  // child: Align(
                                  //   alignment: Alignment.centerRight,
                                  //   child: Container(
                                  //     margin: EdgeInsets.only(
                                  //         top:
                                  //             SizeConfig.blockSizeHorizontal !* 2),
                                  //     decoration: BoxDecoration(
                                  //         border: Border.all(
                                  //           color: colorBlueApp,
                                  //         ),
                                  //         color: white,
                                  //         borderRadius: BorderRadius.all(
                                  //             Radius.circular(10))),
                                  //     child: Padding(
                                  //       padding: EdgeInsets.all(
                                  //           SizeConfig.blockSizeHorizontal !* 3),
                                  //       child: Text(
                                  //         "From Templates",
                                  //         style: TextStyle(
                                  //           color: colorBlueApp,
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ),
                              ],
                            )),
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical !* 1,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.blockSizeHorizontal !* 3),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                            width: SizeConfig.blockSizeVertical !* 40,
                                            child:
                                            TypeAheadField<String>(
                                              textFieldConfiguration: TextFieldConfiguration(
                                                controller: radiologyInvestigationsSupportController,
                                                enabled:
                                                jsonConsultation['CheckOutStatus'] == "0" &&
                                                    selectedPatientOfSameDate(),
                                                decoration: InputDecoration(
                                                  labelText: 'Radiology Investigation',
                                                  // border: OutlineInputBorder(),
                                                ),
                                              ),
                                              suggestionsCallback: (pattern) {
                                                // Always return the full list of options
                                                // return listRadiologyDetails;

                                                return listRadiologyDetails.where((listRadiologyDetails) =>
                                                    listRadiologyDetails.toLowerCase().contains(pattern.toLowerCase()));
                                              },
                                              itemBuilder: (context,String  suggestion) {
                                                return ListTile(
                                                  title: Text(suggestion),
                                                );
                                              },
                                              onSuggestionSelected: (String suggestion) {
                                                setState(() {
                                                  setState(() {
                                                    // complaintSupportController.clear();
                                                    _selectedRadiologyInvestigations.add(suggestion);
                                                  });
                                                });
                                              },
                                            )
                                          // CustomAutocompleteSearch1(
                                          //   suggestions: listComplaintDetails,
                                          //     enabled:
                                          //     jsonConsultation['CheckOutStatus'] == "0" &&
                                          //         selectedPatientOfSameDate(),
                                          //     hint: "Complaint",
                                          //     controller: complaintController,
                                          //     hideSuggestionsOnCreate: true,
                                          //     onSelected: (text) => selectedFieldComplaint(
                                          //         context, complaintController, text,_selectedOptions ),
                                          //     onTap: () {
                                          //       if (onTapStatus != "Tapped") {
                                          //         _scrollController.animateTo(
                                          //             _scrollController
                                          //                 .position.maxScrollExtent,
                                          //             duration:
                                          //             Duration(milliseconds: 500),
                                          //             curve: Curves.easeOut);
                                          //         onTapStatus = "Tapped";
                                          //       }
                                          //     },
                                          // ),
                                        ),
                                        SizedBox(height: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context).size.width -50, // Set maximum width
                                              ),
                                              child:
                                              Wrap(
                                                spacing: 8.0,
                                                runSpacing: 4.0,
                                                children: _selectedRadiologyInvestigations
                                                    .map(
                                                      (String option) => Chip(
                                                    label: Text(option),
                                                    onDeleted: () {
                                                      setState(() {
                                                        _selectedRadiologyInvestigations.remove(option);
                                                      });
                                                    },
                                                  ),
                                                )
                                                    .toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                            width: SizeConfig.blockSizeVertical !* 40,
                                            child:
                                            TypeAheadField<String>(
                                              textFieldConfiguration: TextFieldConfiguration(
                                                controller: adviceInvestigationSupportController,
                                                enabled:
                                                jsonConsultation['CheckOutStatus'] == "0" &&
                                                    selectedPatientOfSameDate(),
                                                decoration: InputDecoration(
                                                  labelText: 'Pathology Investigations',
                                                  // border: OutlineInputBorder(),
                                                ),
                                              ),
                                              suggestionsCallback: (pattern) {
                                                // Always return the full list of options
                                                // return listPathologyDetails;

                                                return listPathologyDetails.where((listPathologyDetails) =>
                                                    listPathologyDetails.toLowerCase().contains(pattern.toLowerCase()));
                                              },
                                              itemBuilder: (context,String  suggestion) {
                                                return ListTile(
                                                  title: Text(suggestion),
                                                );
                                              },
                                              onSuggestionSelected: (String suggestion) {
                                                setState(() {
                                                  setState(() {
                                                    // complaintSupportController.clear();
                                                    _selectedAdviceInvestigation .add(suggestion);
                                                  });
                                                });
                                              },
                                            )
                                          // CustomAutocompleteSearch1(
                                          //   suggestions: listComplaintDetails,
                                          //     enabled:
                                          //     jsonConsultation['CheckOutStatus'] == "0" &&
                                          //         selectedPatientOfSameDate(),
                                          //     hint: "Complaint",
                                          //     controller: complaintController,
                                          //     hideSuggestionsOnCreate: true,
                                          //     onSelected: (text) => selectedFieldComplaint(
                                          //         context, complaintController, text,_selectedOptions ),
                                          //     onTap: () {
                                          //       if (onTapStatus != "Tapped") {
                                          //         _scrollController.animateTo(
                                          //             _scrollController
                                          //                 .position.maxScrollExtent,
                                          //             duration:
                                          //             Duration(milliseconds: 500),
                                          //             curve: Curves.easeOut);
                                          //         onTapStatus = "Tapped";
                                          //       }
                                          //     },
                                          // ),
                                        ),
                                        SizedBox(height: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context).size.width -50, // Set maximum width
                                              ),
                                              child:
                                              Wrap(
                                                spacing: 8.0,
                                                runSpacing: 4.0,
                                                children: _selectedAdviceInvestigation
                                                    .map(
                                                      (String option) => Chip(
                                                    label: Text(option),
                                                    onDeleted: () {
                                                      setState(() {
                                                        _selectedAdviceInvestigation.remove(option);
                                                      });
                                                    },
                                                  ),
                                                )
                                                    .toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (jsonConsultation['CheckOutStatus'] ==
                                            "0" &&
                                            selectedPatientOfSameDate()) {
                                          showTemplateSelectionDialog(
                                              context, "I", setStateOfParent);
                                        }
                                      },
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Icon(Icons.add_box_rounded),
                                        // Container(
                                        //   margin: EdgeInsets.only(
                                        //       top:
                                        //           SizeConfig.blockSizeHorizontal !* 2),
                                        //   decoration: BoxDecoration(
                                        //       border: Border.all(
                                        //         color: colorBlueApp,
                                        //       ),
                                        //       color: white,
                                        //       borderRadius: BorderRadius.all(
                                        //           Radius.circular(10))),
                                        //   child: Padding(
                                        //     padding: EdgeInsets.all(
                                        //         SizeConfig.blockSizeHorizontal !* 3),
                                        //     child: Text(
                                        //       "From Templates",
                                        //       style: TextStyle(
                                        //         color: colorBlueApp,
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                      ),

                                    ),
                                  ],
                                ),
                                // TextField(
                                //   controller: adviceInvestigationController,
                                //   enabled:
                                //       jsonConsultation['CheckOutStatus'] == "0" &&
                                //           selectedPatientOfSameDate(),
                                //   readOnly:
                                //       jsonConsultation['CheckOutStatus'] == "1" ||
                                //           !selectedPatientOfSameDate(),
                                //   style: TextStyle(
                                //       color: Colors.green,
                                //       fontSize:
                                //           SizeConfig.blockSizeVertical !* 2.1),
                                //   decoration: InputDecoration(
                                //     hintStyle: TextStyle(
                                //         color: Colors.black,
                                //         fontSize:
                                //             SizeConfig.blockSizeVertical !* 2.1),
                                //     labelStyle: TextStyle(
                                //         color: darkgrey,
                                //         fontSize:
                                //             SizeConfig.blockSizeVertical !* 2.1),
                                //     labelText: "Pathology Investigations",
                                //     hintText: "",
                                //   ),
                                // ),

                              ],
                            )),
                      ),
                      InkWell(
                        onTap: () {
                          selectInvestigationsToSendToLab();
                        },
                        child: Row(
                          children: [
                            Checkbox(
                              value: isCheckedSendToLab,
                              onChanged: (isChecked) {
                                if (isChecked!)
                                  selectInvestigationsToSendToLab();
                                else {
                                  setState(() {
                                    isCheckedSendToLab = isChecked;
                                  });
                                }
                              },
                            ),
                            Text(
                              "Send to Lab",
                              style: TextStyle(
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w500,
                                  fontSize: SizeConfig.blockSizeHorizontal !* 3.6),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.blockSizeHorizontal !* 3),
                        child: Row(
                          children: [
                            Container(
                              width: SizeConfig.blockSizeVertical !* 40,
                              child: TextField(
                                controller: remarksController,
                                enabled:
                                jsonConsultation['CheckOutStatus'] == "0" &&
                                    selectedPatientOfSameDate(),
                                style: TextStyle(
                                  color: Colors.green,
                                ),
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(color: Colors.black),
                                  labelStyle: TextStyle(color: darkgrey),
                                  labelText: "Notes",
                                  hintText: "",
                                  counterText: "",
                                ),
                                maxLines: 5,
                                minLines: 5,
                                maxLength: 500,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (jsonConsultation['CheckOutStatus'] == "0" &&
                                    selectedPatientOfSameDate()) {
                                  showTemplateSelectionDialog(
                                      context, "R", setStateOfParent);
                                }
                              },
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Icon(Icons.add_box_rounded),
                                // Container(
                                //   margin: EdgeInsets.only(
                                //       top:
                                //           SizeConfig.blockSizeHorizontal !* 2),
                                //   decoration: BoxDecoration(
                                //       border: Border.all(
                                //         color: colorBlueApp,
                                //       ),
                                //       color: white,
                                //       borderRadius: BorderRadius.all(
                                //           Radius.circular(10))),
                                //   child: Padding(
                                //     padding: EdgeInsets.all(
                                //         SizeConfig.blockSizeHorizontal !* 3),
                                //     child: Text(
                                //       "From Templates",
                                //       style: TextStyle(
                                //         color: colorBlueApp,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical !* 1,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.center,
                              child: MaterialButton(
                                onPressed: () {
                                  if (jsonConsultation['CheckOutStatus'] == "0" &&
                                      selectedPatientOfSameDate()) {
                                    showDateSelectionDialog();
                                  }
                                },
                                child: Container(
                                  child: IgnorePointer(
                                    child: TextField(
                                      controller: followUpDateController,
                                      enabled:
                                      jsonConsultation['CheckOutStatus'] ==
                                          "0" &&
                                          selectedPatientOfSameDate(),
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontSize:
                                          SizeConfig.blockSizeVertical !* 2.1),
                                      decoration: InputDecoration(
                                        hintStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                            SizeConfig.blockSizeVertical !*
                                                2.1),
                                        labelStyle: TextStyle(
                                            color: darkgrey,
                                            fontSize:
                                            SizeConfig.blockSizeVertical !*
                                                2.1),
                                        labelText: "Next Appointment",
                                        hintText: "",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical !* 1.0,
                      ),
                      Row(
                        children: <Widget>[
                          Checkbox(
                              value: markAsCheckout,
                              onChanged: (isChecked) {
                                if (jsonConsultation['CheckOutStatus'] == "0" &&
                                    selectedPatientOfSameDate()) {
                                  setState(() {
                                    markAsCheckout = isChecked!;
                                  });
                                }
                              }),
                          InkWell(
                            onTap: () {
                              if (jsonConsultation['CheckOutStatus'] == "0" &&
                                  selectedPatientOfSameDate()) {
                                setState(() {
                                  markAsCheckout = !markAsCheckout;
                                });
                              }
                            },
                            child: Text("Mark as Checkout"),
                          )
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.blockSizeHorizontal !* 3),
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal !* 90,
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal !* 1),
                          child: TextField(
                            controller: internalNotesController,
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: SizeConfig.blockSizeVertical !* 2.1),
                            decoration: InputDecoration(
                              hintStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: SizeConfig.blockSizeVertical !* 2.1),
                              labelStyle: TextStyle(
                                  color: darkgrey,
                                  fontSize: SizeConfig.blockSizeVertical !* 2.1),
                              labelText: "Internal Notes",
                              hintText: "",
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: MaterialButton(
                          onPressed: () {
                            // if(str_referred_to_doctor==null)
                            // {
                            //
                            // }
                            print('selectedReferredDoctorId1 ${selectedReferredDoctorId1.length}');
                            if(selectedReferredDoctorId1.length==0)
                            {
                              showDropdownDialog(listReferredDoctorSearchResults,
                                  str_referred_to_doctor);
                            }
                          },
                          child: IgnorePointer(
                            child:
                            TextField(
                              controller: referredDoctorController,
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: SizeConfig.blockSizeVertical !* 2.3),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: SizeConfig.blockSizeVertical !* 2.3),
                                labelStyle: TextStyle(
                                    color: darkgrey,
                                    fontSize: SizeConfig.blockSizeVertical !* 2.3),
                                labelText: str_referred_to_doctor,
                                hintText: "",
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: selectedReferredDoctorId == '-1'
                              ? Container(
                            width: SizeConfig.blockSizeHorizontal !* 90,
                            padding: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal !* 1),
                            child: TextField(
                              controller: referredDoctorNameController,
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize:
                                  SizeConfig.blockSizeVertical !* 2.3),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                    SizeConfig.blockSizeVertical !* 2.3),
                                labelStyle: TextStyle(
                                    color: darkgrey,
                                    fontSize:
                                    SizeConfig.blockSizeVertical !* 2.3),
                                labelText: str_referred_doctor_name,
                                hintText: "",
                              ),
                            ),
                          )
                              : Container()),
                      Align(
                          alignment: Alignment.center,
                          child: selectedReferredDoctorId == "-1"
                              ? Container(
                            width: SizeConfig.blockSizeHorizontal !* 90,
                            padding: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal !* 1),
                            child: TextField(
                              controller: referredDoctorMobileController,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize:
                                  SizeConfig.blockSizeVertical !* 2.3),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                    SizeConfig.blockSizeVertical !* 2.3),
                                labelStyle: TextStyle(
                                    color: darkgrey,
                                    fontSize:
                                    SizeConfig.blockSizeVertical !* 2.3),
                                labelText: str_referred_doctor_no,
                                hintText: "",
                              ),
                            ),
                          )
                              : Container()),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal !* 90,
                          padding:
                          EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 1),
                          child: TextField(
                            controller: referenceNoteController,
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            decoration: InputDecoration(
                              hintStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: SizeConfig.blockSizeVertical !* 2.3),
                              labelStyle: TextStyle(
                                  color: darkgrey,
                                  fontSize: SizeConfig.blockSizeVertical !* 2.3),
                              labelText: str_reference_note,
                              hintText: "",
                            ),
                            maxLines: 5,
                            minLines: 3,
                            maxLength: 500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.blockSizeHorizontal !* 3,
                        vertical: SizeConfig.blockSizeHorizontal !* 1,
                      ),
                      child: Row(children: [
                        Expanded(
                          child: firstEditStatus == "1"
                              ? Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  pdfButtonClick(context,
                                      widget.modelOPDRegistration, "full");
                                },
                                customBorder: CircleBorder(),
                                child: Container(
                                  padding: EdgeInsets.all(
                                      SizeConfig.blockSizeHorizontal !* 2.0),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[800],
                                    shape: BoxShape.circle,
                                  ),
                                  child: FaIcon(
                                    FontAwesomeIcons.print,
                                    size:
                                    SizeConfig.blockSizeHorizontal !* 5,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: SizeConfig.blockSizeHorizontal !* 3.0,
                              ),
                              InkWell(
                                  onTap: () {
                                    preparePdfList();
                                    showPdfTypeSelectionDialog(
                                      listPdfType,
                                      ModelOPDRegistration(
                                          widget.idp, "", "", "",
                                          patientIDP: widget.patientIDP),
                                      context,
                                    );
                                  },
                                  customBorder: CircleBorder(),
                                  child: Container(
                                    padding: EdgeInsets.all(
                                        SizeConfig.blockSizeHorizontal !*
                                            2.0),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Image(
                                      width:
                                      SizeConfig.blockSizeHorizontal !*
                                          5,
                                      color: Colors.white,
                                      //height: 80,
                                      image: AssetImage(
                                          "images/ic_download.png"),
                                    ),
                                  )),
                              Expanded(
                                child: Row(
                                  children: [
                                    dueAmount > 0
                                        ? Center(
                                      child: BlinkingText(
                                        "Due Amount : \u20B9$dueAmount",
                                        //textAlign: TextAlign.left,
                                        textStyle: TextStyle(
                                          color: Colors.red,
                                          fontSize: SizeConfig
                                              .blockSizeHorizontal !*
                                              3.8,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ).expanded()
                                        : Container(),
                                    jsonConsultation['CheckOutStatus'] ==
                                        "0" &&
                                        selectedPatientOfSameDate()
                                        ? Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius
                                              .circular(SizeConfig
                                              .blockSizeHorizontal !*
                                              20.0),
                                          color: colorBlueDark,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: SizeConfig
                                                .blockSizeHorizontal !*
                                                3.0,
                                            vertical: SizeConfig
                                                .blockSizeHorizontal !*
                                                3.0),
                                        child: InkWell(
                                          onTap: () {
                                            combineAndStoreValues(); // Call the function to combine and store values
                                            submitConsultationDetails(
                                                context);
                                          },
                                          child: Text(
                                            "Send",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: SizeConfig
                                                    .blockSizeHorizontal !*
                                                    4.0),
                                          ),
                                        ),
                                      ),
                                    )
                                        : Container()
                                  ],
                                ),
                              ),
                            ],
                          )
                              : Container(),
                        ),
                        firstEditStatus == "1"
                            ? Container()
                            : Container(
                          width: SizeConfig.blockSizeHorizontal !* 90,
                          child: Row(
                            children: [
                              Expanded(
                                  child: dueAmount > 0
                                      ? Center(
                                    child: BlinkingText(
                                      "Due Amount : \u20B9$dueAmount",
                                      //textAlign: TextAlign.left,
                                      textStyle: TextStyle(
                                        color: Colors.red,
                                        fontSize: SizeConfig
                                            .blockSizeHorizontal !*
                                            3.8,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  )
                                      : Container()),
                              selectedPatientOfSameDate()
                                  ? Expanded(
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius
                                            .circular(SizeConfig
                                            .blockSizeHorizontal !*
                                            20.0),
                                        color: colorBlueDark,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: SizeConfig
                                              .blockSizeHorizontal !*
                                              3.0,
                                          vertical: SizeConfig
                                              .blockSizeHorizontal !*
                                              3.0),
                                      child: InkWell(
                                        onTap: () {
                                          combineAndStoreValues(); // Call the function to combine and store values
                                          submitConsultationDetails(
                                              context);
                                        },
                                        child: Text(
                                          "SEND",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: SizeConfig
                                                  .blockSizeHorizontal !*
                                                  4.0),
                                        ),
                                      ),
                                    ),
                                  ))
                                  : Container()
                            ],
                          ),
                        )
                      ]),
                    )),
                /*Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 2.5),
                    margin: EdgeInsets.only(
                      right: SizeConfig.blockSizeHorizontal * 2.5,
                      bottom: SizeConfig.blockSizeHorizontal * 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFF06A759),
                      shape: BoxShape.circle,
                    ),
                    child: InkWell(
                      onTap: () {
                        submitConsultationDetails(context);
                      },
                      child: Image(
                        width: SizeConfig.blockSizeHorizontal * 5.5,
                        height: SizeConfig.blockSizeHorizontal * 5.5,
                        //height: 80,
                        image: AssetImage("images/ic_right_arrow_triangular.png"),
                      ),
                      customBorder: CircleBorder(),
                    ),
                  ),
                )*/
              ],
            );
          },
        ),
      ),
    );
  }

  void callbackFromDialog(String type) {
    setState(() {
      if (type == str_referred_to_doctor) {
        // getStatesList();
      }
    });
  }

  void showDropdownDialog(List<DropDownItemConsultation> list, String type) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            DropDownDialog(list, type, callbackFromDialog));
  }

  void setStateOfParent() {
    setState(() {});
  }

  void getPdfDownloadPath(
      BuildContext context, String idp, String patientIDPLocal) async {
    String? loginUrl;
    if (pdfTypeController.pdfType.value == "prescription")
      loginUrl = "${baseURL}prescriptiondocpdf.php";
    else if (pdfTypeController.pdfType.value == "receipt")
      loginUrl = "${baseURL}receiptpdfdoc.php";
    else if (pdfTypeController.pdfType.value == "invoice")
      loginUrl = "${baseURL}invoicepdfdoc.php";
    else if (pdfTypeController.pdfType.value == "full")
      loginUrl = "${baseURL}consultationpdfdoc.php";
    debugPrint("pdf url -  $loginUrl");

    pr = ProgressDialog(context);
    pr!.show();
    String patientIDP = await getPatientOrDoctorIDP();
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
        patientIDP +
        "\"," +
        "\"" +
        "HospitalConsultationIDF" +
        "\"" +
        ":" +
        "\"" +
        idp +
        "\"" +
        ",\"PatientIDP\":\"$patientIDPLocal\"" +
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
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr!.hide();
    if (model.status == "OK") {
      String encodedFileName = model.data!;
      String strData = decodeBase64(encodedFileName);
      final jsonData = json.decode(strData);
      String fileName = jsonData[0]['FileName'].toString();
      String downloadPdfUrl = "";
      if (pdfTypeController.pdfType.value == "prescription")
        downloadPdfUrl = "${baseURL}images/prescriptionDoc/$fileName";
      else if (pdfTypeController.pdfType.value == "receipt")
        downloadPdfUrl = "${baseURL}images/receiptDoc/$fileName";
      else if (pdfTypeController.pdfType.value == "invoice")
        downloadPdfUrl = "${baseURL}images/invoiceDoc/$fileName";
      else if (pdfTypeController.pdfType.value == "full")
        downloadPdfUrl = "${baseURL}images/consultationDoc/$fileName";
      downloadAndOpenTheFile(downloadPdfUrl, fileName);
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      pr!.hide();
    }
  }

  // void downloadAndOpenTheFile(String url, String fileName) async {
  //   var tempDir = Platform.isAndroid
  //       ? await getExternalStorageDirectory()
  //       : await getApplicationDocumentsDirectory();
  //   //await tempDir.create(recursive: true);
  //   String fullPath = tempDir!.path + "/$fileName";
  //   debugPrint("full path");
  //   debugPrint(fullPath);
  //   Dio dio = Dio();
  //   downloadFileAndOpenActually(dio, url, fullPath);
  // }

  Future downloadFileAndOpenActually(
      Dio dio, String url, String savePath) async {
    try {
      pr = ProgressDialog(context);
      pr!.show();

      final savedDir = Directory(savePath);
      bool hasExisted = await savedDir.exists();
      if (!hasExisted) {
        await savedDir.create();
      }
      taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: savePath,
        showNotification: false,
        saveInPublicStorage: true,
        // show download progress in status bar (for Android)
        openFileFromNotification:
        false, // click on notification to open downloaded file (for Android)
      ) /*.then((value) {
        taskId = value;
      })*/
      ;
      var tasks = await FlutterDownloader.loadTasks();
      debugPrint("File path");
    } catch (e) {
      print("Error downloading");
      print(e.toString());
    }
  }

  void _bindBackgroundIsolate() {
    ReceivePort _port = ReceivePort();
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      if (/*status == DownloadTaskStatus.complete*/ status.toString() ==
          "DownloadTaskStatus(3)" &&
          progress == 100) {
        debugPrint("Successfully downloaded");
        pr!.hide();
        String query = "SELECT * FROM task WHERE task_id='" + id + "'";
        var tasks = FlutterDownloader.loadTasksWithRawQuery(query: query);
        FlutterDownloader.open(taskId: id);
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(
      String id, int status, int progress) {
    final SendPort? send =
    IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  void showTimeSelectionDialog() async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: pickedTime,
        builder: (BuildContext? context, Widget? child) {
          return MediaQuery(
              child: child!,
              data:
              MediaQuery.of(context!).copyWith(alwaysUse24HourFormat: true));
        });

    if (time != null) {
      pickedTime = time;
      final now = new DateTime.now();
      var dateOfTime = DateTime(
          now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);

      var formatter = new DateFormat('HH:mm');
      String formatted = formatter.format(dateOfTime);
      followUpTimeController = TextEditingController(text: formatted);

      setState(() {});
    }
  }

  void showDateSelectionDialog() async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    DateTime lastDate = DateTime.now().add(Duration(days: 365 * 100));
    DateTime? date = await showDatePicker(
        context: context,
        initialDate: pickedDate,
        firstDate: DateTime.now(),
        lastDate: lastDate);

    if (date != null) {
      pickedDate = date;
      var formatter = new DateFormat('dd-MM-yyyy');
      String formatted = formatter.format(pickedDate);
      followUpDateController = TextEditingController(text: formatted);
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

  void getPatientProfileDetails() async {
    print('getPatientProfileDetails');
    /*List<IconModel> listIcon;*/
    ProgressDialog pr = ProgressDialog(context);
    Future.delayed(Duration.zero, () {
      pr.show();
    });
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
        widget.patientIDP +
        "\"" +
        "}";

    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);
    //listIcon = new List();
    var response = await apiHelper.callApiWithHeadersAndBody(
      url: urlFetchPatientProfileDetails,
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
    pr.hide();
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array : " + strData);
      final jsonData = json.decode(strData);
      if (jsonData.length > 0) {
        widget.patientID = jsonData[0]['PatientID'];
        String firstName = jsonData[0]['FirstName'];
        String lastName = jsonData[0]['LastName'];
        String middleName = jsonData[0]['MiddleName'];
        widget.fullName = (firstName.trim() +
            " " +
            middleName.trim() +
            " " +
            lastName.trim())
            .trim() !=
            ""
            ? firstName.trim() + " " + middleName.trim() + " " + lastName.trim()
            : "-";
        widget.imgUrl = jsonData[0]['Image'];

        widget.cityName =
        jsonData[0]['CityName'] != "" ? jsonData[0]['CityName'] : "-";

        widget.gender =
        jsonData[0]['Gender'] != "" ? jsonData[0]['Gender'] : "-";
        widget.age = jsonData[0]['Age'] != "" ? jsonData[0]['Age'] : "-";
        heightValue = double.parse(jsonData[0]['Height']);
        weightValue = double.parse(jsonData[0]['Wieght']);
        debugPrint("height is - $heightValue");
        cmToFeet();
      }
      setState(() {});
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void cmToFeet() {
    double heightInFeetWithDecimal = heightValue * 0.0328084;
    int intHeightInFeet = heightInFeetWithDecimal.toInt();
    double remainingDecimals = heightInFeetWithDecimal - intHeightInFeet;
    int intHeightInInches = (remainingDecimals * 12).round().toInt();
    if (intHeightInInches == 12) {
      intHeightInFeet++;
      intHeightInInches = 0;
    }
    heightInFeet = "$intHeightInFeet Foot $intHeightInInches Inches";
  }

  void getConsultationDetails(BuildContext context) async {
    print('getConsultationDetails');
    String loginUrl = "${baseURL}doctorConsultationDetails.php";
    // ProgressDialog pr;
    // Future.delayed(Duration.zero, () {
    //   pr = ProgressDialog(context);
    //   // pr.show();
    // });
    //listIcon = new List();

    complaintSupportController.clear();
    examinationSupportController.clear();
    adviceInvestigationSupportController.clear();
    diagnosisSupportController.clear();
    radiologyInvestigationsSupportController.clear();

    String patientIDP = await getPatientOrDoctorIDP();
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
        patientIDP +
        "\"," +
        "\"" +
        "HospitalConsultationIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.idp +
        "\"" +
        "}";


    debugPrint("--------------------------------------------------");
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
    // pr.hide();
    print(jsonResponse);
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      if (strData != "[]") {
        final jsonData = json.decode(strData);
        jsonConsultation = jsonData[0];
        isCertificate = jsonConsultation['CertificateDetailsIDF'];
        certId = jsonConsultation['CertificateDetailsIDF'];
        isCamp = jsonConsultation['DoctorCampStatus'].toString();

        historyController.text =
            append(historyController, jsonData[0]['History']);
        complaintSupportController.text =
            append(complaintSupportController, jsonData[0]['Complain']);
        diagnosisSupportController.text =
            append(diagnosisSupportController, jsonData[0]['Diagnosis']);
        /*systemicIllnessController =
          TextEditingController(text: jsonData[0]['SystemicIllness']);*/
        examinationSupportController.text =
            append(examinationSupportController, jsonData[0]['Examination']);
        firstEditStatus = jsonData[0]['FirstEditStatus'];
        /*adviceController = TextEditingController(text: jsonData[0]['Advice']);*/
        /*nextVisitPlanController =
          TextEditingController(text: jsonData[0]['NextVisitPlan']);*/
        /*var formatter = new DateFormat('dd-MM-yyyy');
        String formatted = formatter.format(pickedDate);*/
        remarksController.text =
            append(remarksController, jsonData[0]['Remarks']);
        followUpDateController.text = append(
            followUpDateController,
            jsonData[0]['FollowUpDate'] != ""
                ? jsonData[0]['FollowUpDate']
                : "");
        if (jsonData[0]['CheckOutStatus'] == "1") markAsCheckout = true;
        totalServices = jsonData[0]['TotalServices'];
        healthRecordsDisplayStatus = jsonData[0]['HealthRecordsDisplayStatus'];
        notificationDisplayStatus = jsonData[0]['NotificationDisplayStatus'];
        paymentDueStatus = jsonData[0]['PaymentDueStatus'].toString();
        radiologyInvestigationsSupportController.text = append(
            radiologyInvestigationsSupportController,jsonData[0]['RadiologyInvestigations']);
        adviceInvestigationSupportController.text = append(
            adviceInvestigationSupportController, jsonData[0]['AdviceInvestigations']);
        internalNotesController.text = jsonData[0]['InternalNotes'];
        clearedFromDueStatus = jsonData[0]['ClearedFromDueStatus'];
        referenceNoteController.text = jsonData[0]['Reason'];
        // print('Here ${jsonData[0]['ToDoctorIDF']}');
        selectedReferredDoctorId1 = jsonData[0]['ToDoctorIDF'];
        //paymentDueStatus = jsonData[0]['PaymentDueStatus'];
        for(int i=0;i<listReferredDoctor.length;i++)
        {
          if(selectedReferredDoctorId1 == listReferredDoctor[i].idp)
          {
            selectedReferredDoctor = listReferredDoctor[i];
            print('selectedReferredDoctor ${selectedReferredDoctor.idp} ${selectedReferredDoctor.value}');
            referredDoctorController.text = selectedReferredDoctor.value;
            break;
          }
        }
        dueAmount = double.parse(jsonData[0]['DueAmount']);
        if (jsonData[0]['SendtoStatus'] == "1")
          isCheckedSendToLab = true;
        else
          isCheckedSendToLab = false;
        setState(() {});
      } else {
        setState(() {
          jsonConsultation['CheckOutStatus'] = "0";
        });
      }
    }
  }

  void getCertificates() async {
    print('getCertificates');
    String loginUrl = "${baseURL}doctorIssueCertificate.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new List();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();

    var response = await apiHelper.callApiWithHeadersAndBody(
      url: loginUrl,
      headers: {
        "u": patientUniqueKey,
        "type": userType,
      },
    );
    //var resBody = json.decode(response.body);
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr!.hide();
    print("Certificate $jsonResponse");
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      for (var i = 0; i < jsonData.length; i++) {
        certList.add(ModelCertificate(
            certificateTypeIDP: jsonData[i]['CertificateTypeIDP'],
            certificateTypeName: jsonData[i]['CertificateTypeName']));
      }
    }
  }

  void getMaterials() async {
    print('getMaterials');
    String loginUrl = "${baseURL}doctorHealthInfoDocument.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new List();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();

    var response = await apiHelper.callApiWithHeadersAndBody(
      url: loginUrl,
      headers: {
        "u": patientUniqueKey,
        "type": userType,
      },
    );
    //var resBody = json.decode(response.body);
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr!.hide();
    print("Certificate $jsonResponse");
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      for (var i = 0; i < jsonData.length; i++)
      {
        healthDocList.add(
            ModelHealthDoc(
                healthInfoDocumentIDP: jsonData[i]['HealthInfoDocumentIDP'],
                fileName: jsonData[i]['FileName']));
      }
    }
  }

  Widget showCertificates() {
    return Wrap(
      children: [
        ListView.builder(
          shrinkWrap: true,
          itemCount: certList.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                Navigator.of(context).pop();
                if (index == 0)
                  Get.to(FitnessCertificateScreen(
                      cert: certList[0],
                      idp: widget.idp,
                      patientIDP: widget.patientIDP))
                      ?.then((value) {
                    getConsultationDetails(context);
                  });
                if (index == 1)
                  Get.to(MedicalCertificate(
                      cert: certList[1],
                      idp: widget.idp,
                      patientIDP: widget.patientIDP))
                      ?.then((value) {
                    getConsultationDetails(context);
                  });
                // Get.to(MedicalCertificate(
                //     cert: certList[0],
                //     idp: widget.idp,
                //     patientIDP: widget.patientIDP));
                print(certList[index].certificateTypeName);
              },
              child: ListTile(
                title: Text(certList[index].certificateTypeName!),
              ),
            );
          },
        ),
      ],
    );
  }

  // Widget showMaterial(
  //     CertificateController certController) {
  //   return Column(
  //     children: [
  //       Expanded(
  //         child: DefaultTabController(
  //           length: 2,
  //           child: Column(
  //             children: [
  //               Expanded(
  //                 child: TabBarView(
  //                   children: [
  //                     ListView.builder(
  //                       shrinkWrap: true,
  //                       itemCount: healthDocList.length,
  //                       itemBuilder: (BuildContext context, int index) {
  //                         return Column(
  //                           children: [
  //                             InkWell(
  //                               onTap: () {
  //                                 certController
  //                                     .submitHealthDoc(
  //                                     widget.patientIDP,healthDocList[index],context)
  //                                     .then((value) {
  //                                   Navigator.of(context).pop();
  //                                 });
  //                                 print(healthDocList[index].fileName);
  //                               },
  //                               child: ListTile(
  //                                 title: Text(healthDocList[index].fileName!),
  //
  //                               ),
  //                             ),
  //                             Divider(),
  //                           ],
  //                         );
  //                       },
  //                     ),
  //                     ListView.builder(
  //                       shrinkWrap: true,
  //                       itemCount: healthDocList.length,
  //                       itemBuilder: (BuildContext context, int index) {
  //                         return Column(
  //                           children: [
  //                             InkWell(
  //                               onTap: () {
  //                                 certController
  //                                     .submitHealthDoc(
  //                                     widget.patientIDP, healthDocList[index], context)
  //                                     .then((value) {
  //                                   Navigator.of(context).pop();
  //                                 });
  //                                 print(healthDocList[index].fileName);
  //                               },
  //                               child: ListTile(
  //                                 title: Text(healthDocList[index].fileName!),
  //
  //                               ),
  //                             ),
  //                             Divider(),
  //                           ],
  //                         );
  //                       },
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               TabBar(
  //                   tabs:[
  //                     Tab(text: "Material List"),
  //                     Tab(text: "Health Videos"),
  //                   ] )
  //             ],
  //           )
  //
  //         )
  //       ),
  //     ],
  //   );
  // }

  TextEditingController complaintController = TextEditingController();
  TextEditingController complaintSupportController = TextEditingController();

  TextEditingController examinationController = TextEditingController();
  TextEditingController examinationSupportController = TextEditingController();

  TextEditingController adviceInvestigationController = TextEditingController();
  TextEditingController adviceInvestigationSupportController = TextEditingController();

  TextEditingController diagnosisController = TextEditingController();
  TextEditingController diagnosisSupportController = TextEditingController();

  TextEditingController radiologyInvestigationsController = TextEditingController();
  TextEditingController radiologyInvestigationsSupportController = TextEditingController();

  void combineAndStoreValues() {
    // Combine selected options and text from the controller
    String combinedValue = _selectedComplaints.join(', ') + (_selectedComplaints.isNotEmpty && complaintSupportController.text.isNotEmpty ? ', ' : '') + complaintSupportController.text;
    // Store the combined value into the complaintController (which is also textEditingController)
    complaintController.text = combinedValue;

    // Combine selected options and text from the controller
    String combinedValueExaminations = _selectedExamination.join(', ') + (_selectedExamination.isNotEmpty && examinationSupportController.text.isNotEmpty ? ', ' : '') + examinationSupportController.text;
    // String combinedValueExaminations = _selectedExamination .join(', ') + (examinationSupportController.text.isNotEmpty ? ', ${examinationSupportController.text}' : '');

    // Store the combined value into the complaintController (which is also textEditingController)
    examinationController.text = combinedValueExaminations;

    // Combine selected options and text from the controller
    String combinedValueDiagnosis = _selectedDiagnosis.join(', ') + (_selectedDiagnosis.isNotEmpty && diagnosisSupportController.text.isNotEmpty ? ', ' : '') + diagnosisSupportController.text;
    // String combinedValueDiagnosis = _selectedDiagnosis .join(', ') + (diagnosisSupportController.text.isNotEmpty ? ', ${diagnosisSupportController.text}' : '');

    // Store the combined value into the complaintController (which is also textEditingController)
    diagnosisController.text = combinedValueDiagnosis;

    // Combine selected options and text from the controller
    String combinedValueAdviceInvestigation = _selectedAdviceInvestigation.join(', ') + (_selectedAdviceInvestigation.isNotEmpty && adviceInvestigationSupportController.text.isNotEmpty ? ', ' : '') + adviceInvestigationSupportController.text;
    // String combinedValueAdviceInvestigation = _selectedAdviceInvestigation .join(', ') + (adviceInvestigationSupportController.text.isNotEmpty ? ', ${adviceInvestigationSupportController.text}' : '');

    // Store the combined value into the complaintController (which is also textEditingController)
    adviceInvestigationController.text = combinedValueAdviceInvestigation;

    // Combine selected options and text from the controller
    String combinedValueRadiologyInvestigations = _selectedRadiologyInvestigations.join(', ') + (_selectedRadiologyInvestigations.isNotEmpty && radiologyInvestigationsSupportController.text.isNotEmpty ? ', ' : '') + radiologyInvestigationsSupportController.text;
    // String combinedValueRadiologyInvestigations = _selectedRadiologyInvestigations .join(', ') + (radiologyInvestigationsSupportController.text.isNotEmpty ? ', ${radiologyInvestigationsSupportController.text}' : '');

    // Store the combined value into the complaintController (which is also textEditingController)
    radiologyInvestigationsController.text = combinedValueRadiologyInvestigations;

    // Clear the selectedOptions and the textEditingController
    setState(() {
      _selectedComplaints.clear();
      _selectedExamination.clear();
      _selectedDiagnosis.clear();
      _selectedAdviceInvestigation.clear();
      _selectedRadiologyInvestigations.clear();
      complaintSupportController.clear();
    });
  }

  // void selectedFieldComplaint(
  //     BuildContext context,
  //     TextEditingController anyController,
  //     text,
  //     List<String> selectedOptions
  //     ) {
  //   FocusScopeNode currentFocus = FocusScope.of(context);
  //   String mergedText = '';
  //
  //   if (!currentFocus.hasPrimaryFocus) {
  //     currentFocus.unfocus();
  //   }
  //
  //   if (listComplaintDetails.isNotEmpty) {
  //     int index = listComplaintDetails.indexOf(text);
  //     if (index != -1) {
  //       debugPrint(listComplaintDetails[index]);
  //       // Handle the logic related to the selected complaint
  //       // Assuming that getComplaintList is a function to fetch the details
  //       getComplaintList(context);
  //
  //       // Add the selected option to the list of selected options
  //       selectedOptions.add(text);
  //
  //       // Concatenate the selected options to form a single string
  //       mergedText = selectedOptions.join(', ');
  //
  //       // Set the concatenated text as the controller's text
  //       anyController.text = mergedText;
  //       initialState = false;
  //     } else {
  //       debugPrint("Text not found in listComplaintDetails");
  //     }
  //   } else {
  //     debugPrint("List is empty");
  //   }
  // }
  //
  // selectedFieldDiagnosis(
  //     BuildContext context, TextEditingController anyController, text){
  //   FocusScopeNode currentFocus = FocusScope.of(context);
  //   if (!currentFocus.hasPrimaryFocus) {
  //     currentFocus.unfocus();
  //   }
  //   if (listDiagnosisDetails.isNotEmpty) {
  //     int index = listDiagnosisDetails.indexOf(text);
  //     if (index != -1) {
  //       debugPrint(listDiagnosisDetails[index]);
  //       // Handle the logic related to the selected complaint
  //
  //       // Assuming that getComplaintList is a function to fetch the details
  //       getDiagnosisList(context);
  //
  //       anyController.text = text;
  //       initialState = false;
  //     } else {
  //       debugPrint("Text not found in listDiagnosisDetails");
  //     }
  //   } else {
  //     debugPrint("List is empty");
  //   }
  // }
  //
  // selectedFieldExamination(
  //     BuildContext context, TextEditingController anyController, text){
  //   FocusScopeNode currentFocus = FocusScope.of(context);
  //   if (!currentFocus.hasPrimaryFocus) {
  //     currentFocus.unfocus();
  //   }
  //   if (listExaminationDetails.isNotEmpty) {
  //     int index = listExaminationDetails.indexOf(text);
  //     if (index != -1) {
  //       debugPrint(listExaminationDetails[index]);
  //       // Handle the logic related to the selected complaint
  //
  //       // Assuming that getComplaintList is a function to fetch the details
  //       getExaminationList(context);
  //
  //       anyController.text = text;
  //       initialState = false;
  //     } else {
  //       debugPrint("Text not found in listExaminationDetails");
  //     }
  //   } else {
  //     debugPrint("List is empty");
  //   }
  // }
  //
  // selectedFieldRadiology(
  //     BuildContext context, TextEditingController anyController, text){
  //   FocusScopeNode currentFocus = FocusScope.of(context);
  //   if (!currentFocus.hasPrimaryFocus) {
  //     currentFocus.unfocus();
  //   }
  //   if (listRadiologyDetails.isNotEmpty) {
  //     int index = listRadiologyDetails.indexOf(text);
  //     if (index != -1) {
  //       debugPrint(listRadiologyDetails[index]);
  //       // Handle the logic related to the selected complaint
  //
  //       // Assuming that getComplaintList is a function to fetch the details
  //       getRadiologyList(context);
  //
  //       anyController.text = text;
  //       initialState = false;
  //     } else {
  //       debugPrint("Text not found in listDiagnosisDetails");
  //     }
  //   } else {
  //     debugPrint("List is empty");
  //   }
  // }
  //
  // selectedFieldPathology(
  //     BuildContext context, TextEditingController anyController, text){
  //   FocusScopeNode currentFocus = FocusScope.of(context);
  //   if (!currentFocus.hasPrimaryFocus) {
  //     currentFocus.unfocus();
  //   }
  //   if (listPathologyDetails.isNotEmpty) {
  //     int index = listPathologyDetails.indexOf(text);
  //     if (index != -1) {
  //       debugPrint(listPathologyDetails[index]);
  //       // Handle the logic related to the selected complaint
  //
  //       // Assuming that getComplaintList is a function to fetch the details
  //       getPathologyList(context);
  //
  //       anyController.text = text;
  //       initialState = false;
  //     } else {
  //       debugPrint("Text not found in listDiagnosisDetails");
  //     }
  //   } else {
  //     debugPrint("List is empty");
  //   }
  // }

  void getRadiologyList(BuildContext context) async{
    listRadiologyDetails = [];
    String loginUrl = "${baseURL}doctor_radiology_list.php";
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("------");
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
        ","+
        "\"" +
        "type" +
        "\"" +
        ":" +
        "\"" +
        "radiology" +
        "\"" +
        "}";

    debugPrint(jsonStr);
    debugPrint("----------");
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
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr?.hide();
    if (response.statusCode == 200)
      try{
        if (model.status == "OK") {
          var data = jsonResponse['Data'];
          var strData = decodeBase64(data);
          debugPrint("Decoded Radiology List: " + strData);

          final jsonData = json.decode(strData);

          for (var i = 0; i < jsonData.length; i++)
          {
            final jo = jsonData[i];
            String adviceInvestigationName = jo['AdviceInvestigationName'].toString();
            listRadiologyDetails.add(adviceInvestigationName);
            // debugPrint("Added to list: $diagnosisName");
          }

          // for (var i = 0; i < jsonData.length; i++) {
          //
          //   final jo = jsonData[i];
          //   String organizationLogoImage = jo['OrganizationLogoImage'].toString();
          //   String organizationIDF = jo['OrganizationIDF'].toString();
          //   String organizationName = jo['OrganizationName'].toString();
          //   String unit = jo['Unit'].toString();
          //
          //   Map<String, dynamic> OrganizationMap = {
          //     "OrganizationLogoImage": organizationLogoImage,
          //     "OrganizationIDF": organizationIDF,
          //     "OrganizationName" : organizationName,
          //     "Unit" : unit,
          //   };
          //   listRadiologyDetails.add(OrganizationMap);
          //   // debugPrint("Added to list: $complainName");
          //
          // }
          setState(() {});
        }
      }catch(e){
        print("Error decoding JSON: $e");
      }else {
      print("HTTP error: ${response.statusCode}");
    }
  }

  void getPathologyList(BuildContext context) async{
    listPathologyDetails = [];
    String loginUrl = "${baseURL}doctor_pathology_list.php";
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("---------------------################");
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
        ","+
        "\"" +
        "type" +
        "\"" +
        ":" +
        "\"" +
        "pathology" +
        "\"" +
        "}";

    debugPrint(jsonStr);
    debugPrint("------------------##############");
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
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr?.hide();
    if (response.statusCode == 200)
      try{
        if (model.status == "OK") {
          var data = jsonResponse['Data'];
          var strData = decodeBase64(data);
          debugPrint("Decoded Pathology List: " + strData);

          final jsonData = json.decode(strData);

          for (var i = 0; i < jsonData.length; i++)

          {
            final jo = jsonData[i];
            String adviceInvestigationName = jo['AdviceInvestigationName'].toString();
            listPathologyDetails.add(adviceInvestigationName);
            // debugPrint("Added to list: $diagnosisName");
          }

          // for (var i = 0; i < jsonData.length; i++) {
          //
          //   final jo = jsonData[i];
          //   String adviceInvestigationsMasterIDP = jo['AdviceInvestigationsMasterIDP'].toString();
          //   String adviceInvestigationName = jo['AdviceInvestigationName'].toString();
          //   String doctorIDF = jo['DoctorIDF'].toString();
          //   String organizationIDF = jo['OrganizationIDF'].toString();
          //
          //   Map<String, dynamic> OrganizationMap = {
          //     "AdviceInvestigationsMasterIDP": adviceInvestigationsMasterIDP,
          //     "AdviceInvestigationName": adviceInvestigationName,
          //     "DoctorIDF" : doctorIDF,
          //     "OrganizationIDF" : organizationIDF,
          //   };
          //   listRadiologyDetails.add(OrganizationMap);
          //   // debugPrint("Added to list: $complainName");
          //
          // }
          setState(() {});
        }
      }catch(e){
        print("Error decoding JSON: $e");
      }else {
      print("HTTP error: ${response.statusCode}");
    }
  }

  void getDiagnosisList(BuildContext context) async{
    listDiagnosisDetails = [];
    String loginUrl = "${baseURL}doctor_diagnosis_list.php";
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("---------------------------------#####################");
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
        "}";

    debugPrint(jsonStr);
    debugPrint("--------------------------------#####################");
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
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr?.hide();
    if (response.statusCode == 200)
      try{
        if (model.status == "OK") {
          var data = jsonResponse['Data'];
          var strData = decodeBase64(data);
          debugPrint("Decoded Diagnosis List: " + strData);
          final jsonData = json.decode(strData);
          for (var i = 0; i < jsonData.length; i++)
          {
            final jo = jsonData[i];
            String diagnosisName = jo['DiagnosisName'].toString();
            listDiagnosisDetails.add(diagnosisName);
            // debugPrint("Added to list: $diagnosisName");
          }
          setState(() {});
        }
      }catch(e){
        print("Error decoding JSON: $e");
      }else {
      print("HTTP error: ${response.statusCode}");
    }
  }

  void getExaminationList(BuildContext context) async{
    listExaminationDetails = [];
    String loginUrl = "${baseURL}doctor_examination_list.php";
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("#####################");
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
        "}";

    debugPrint(jsonStr);
    debugPrint("#####################");
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
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr?.hide();
    if (response.statusCode == 200)
      try{
        if (model.status == "OK") {
          var data = jsonResponse['Data'];
          var strData = decodeBase64(data);
          debugPrint("Decoded Examination List: " + strData);
          final jsonData = json.decode(strData);
          for (var i = 0; i < jsonData.length; i++)
          {
            final jo = jsonData[i];
            String examinationName = jo['ExaminationName'].toString();
            listExaminationDetails.add(examinationName);
            // debugPrint("Added to list: $examinationName");
          }
          setState(() {});
        }
      }catch(e){
        print("Error decoding JSON: $e");
      }else {
      print("HTTP error: ${response.statusCode}");
    }
  }

  void getComplaintList(BuildContext context) async{
    listComplaintDetails = [];
    String loginUrl = "${baseURL}doctor_complain_list.php";
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("#####################--------------------------------------------------------");
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
        "}";

    debugPrint(jsonStr);
    debugPrint("#####################--------------------------------------------------------");
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
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr?.hide();
    if (response.statusCode == 200)
      try{
        if (model.status == "OK") {
          var data = jsonResponse['Data'];
          var strData = decodeBase64(data);
          debugPrint("Decoded Complaint List: " + strData);
          final jsonData = json.decode(strData);
          for (var i = 0; i < jsonData.length; i++)
          {
            final jo = jsonData[i];
            String complainName = jo['ComplainName'].toString();
            listComplaintDetails.add(complainName);
            // debugPrint("Added to list: $complainName");
          }
          setState(() {});
        }
      }catch(e){
        print("Error decoding JSON: $e");
      }else {
      print("HTTP error: ${response.statusCode}");
    }
  }

  void getTemplatesForAdviceInvestigations() async {
    print('getTemplatesForAdviceInvestigations');
    String loginUrl = "${baseURL}doctorInvestigationTemplete.php";
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr =
        "{" + "\"" + "DoctorIDP" + "\"" + ":" + "\"" + patientIDP + "\"" + "}";

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
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      listTemplates = adviceInvestigationTemplateModelFromJson(strData);
      setState(() {});
    }
  }

  void getTemplatesForRemarks() async {
    print('getTemplatesForRemarks');
    String loginUrl = "${baseURL}doctorRemarksTemplate.php";
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr =
        "{" + "\"" + "DoctorIDP" + "\"" + ":" + "\"" + patientIDP + "\"" + "}";

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
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Remarks Templates : " + strData);
      if (strData != null || strData.trim() != "null") {
        listRemarks = remarksTemplateModelFromJson(strData);
        setState(() {});
      }
    }
  }

  void showTemplateSelectionDialog(BuildContext context, String whichTemplate,
      void Function() setStateOfParent) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => Dialog(
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
                        IconButton(
                          padding: EdgeInsets.all(1.0),
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.red,
                            size: SizeConfig.blockSizeHorizontal !* 6.2,
                          ),
                          onPressed: () {
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
                            child: Text(
                              "Select from templates",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ListView(
                  shrinkWrap: true,
                  children: [
                    ListView.builder(
                        itemCount: getListLength(whichTemplate),
                        physics: ScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                                //if (getNullCondition(whichTemplate, index)) {
                                /*if (whichTemplate == "I") {
                                  onClickTemplate(whichTemplate, index);
                                } else if (whichTemplate == "R") {
                                  String remarks = "";
                                  if (getNullCondition(whichTemplate, index)) {
                                    if (remarksController.text != "") {
                                      remarksController.text
                                          .substring(remarksController.text.length);
                                      remarks = remarksController.text +
                                          " " +
                                          */
                                /*", " +*/ /*
                                          listRemarks[index]
                                              .remarksTemplateDetails
                                              .trim();
                                    } else {
                                      remarks = listRemarks[index]
                                          .remarksTemplateDetails
                                          .trim();
                                    }
                                    debugPrint(remarks);
                                    remarksController.text = remarks;
                                  } else {
                                    remarksController.text = "";
                                  }
                                }*/
                                onClickTemplate(whichTemplate, index);
                                setState(() {});
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
                                          getNameFromTemplatePrefix(
                                              whichTemplate, index),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ))));
                        }),
                  ],
                ),
              ],
            )));
  }

  String getNameFromTemplatePrefix(String prefix, int index) {
    if (prefix == "I") return listTemplates[index].investTemplateName!;
    if (prefix == "R") return listRemarks[index].remarkTemplateName!;
    if (prefix == "C") return listComplaints[index].complainTemplateName!;
    if (prefix == "Con")
      return listConsultationTemplates[index].consultationTemplateName!;
    if (prefix == "D") return listDiagnosis[index].diagnosisTemplateName!;
    if (prefix == "E") return listExamination[index].examinationTemplateName!;
    return "";
  }

  int getIDFromTemplatePrefix(String prefix, int index) {
    if (prefix == "I") return listTemplates[index].investTemplateIdp!;
    if (prefix == "R") return listRemarks[index].remarkTemplateIdp!;
    if (prefix == "C") return listComplaints[index].complainTemplateIdp!;
    if (prefix == "Con")
      return listConsultationTemplates[index].consultationTemplateIdp!;
    if (prefix == "D") return listDiagnosis[index].dignosisTemplateIdp!;
    if (prefix == "E") return listExamination[index].examinationTemplateIdp!;
    return -1;
  }

  int getListLength(String prefix) {
    if (prefix == "I") return listTemplates.length;
    if (prefix == "R") return listRemarks.length;
    if (prefix == "C") return listComplaints.length;
    if (prefix == "Con") return listConsultationTemplates.length;
    if (prefix == "D") return listDiagnosis.length;
    if (prefix == "E") return listExamination.length;
    return -1;
  }

  bool getNullCondition(String prefix, int index) {
    /*if (prefix == "I")*/
    return getDetailsElement(prefix, index) != null &&
        getDetailsElement(prefix, index) != "null" &&
        getDetailsElement(prefix, index) != "";
    /*if (prefix == "R")
      return listRemarks[index].remarksTemplateDetails != null &&
          listRemarks[index].remarksTemplateDetails != "null" &&
          listRemarks[index].remarksTemplateDetails != "";
    return false;*/
  }

  TextEditingController? getController(String prefix) {
    if (prefix == "I") return adviceInvestigationSupportController;
    // if (prefix == "P") return radiologyInvestigationsController;
    if (prefix == "R") return remarksController;
    if (prefix == "C") return complaintSupportController;
    if (prefix == "Con") return complaintController;
    if (prefix == "D") return diagnosisSupportController;
    if (prefix == "E") return examinationSupportController;
    return null;
  }

  String? getDetailsElement(String prefix, int index) {
    if (prefix == "I") return listTemplates[index].investTemplateDetails;
    if (prefix == "R") return listRemarks[index].remarksTemplateDetails;
    if (prefix == "C") return listComplaints[index].complainTemplateDetails;
    if (prefix == "D") return listDiagnosis[index].diagnosisTemplateDetails;
    if (prefix == "E") return listExamination[index].examinationTemplateDetails;
    return null;
  }

  void getInvestigationListFromTemplate(int templateIDP) async {
    listOPDRegistrationSelected = [];
    String loginUrl = "${baseURL}doctorInvestigationTempleteDetails.php";
    Navigator.of(context).pop();
    pr!.show();
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
        "\"," +
        "\"" +
        "InvestTemplateIDP" +
        "\"" +
        ":" +
        "\"" +
        templateIDP.toString() +
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
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr!.hide();
    listConsultationTemplates = [];
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      listConsultationTemplates = consultationTemplateModelFromJson(strData);
      setState(() {});
    }
  }

  void submitConsultationDetails(BuildContext context) async {
    /*var jArrayAdviceInvestigation = "[";
    for (var i = 0; i < listInvestigationsResults.length; i++) {
      if (listInvestigationsResults[i].isChecked) {
        jArrayAdviceInvestigation =
            "$jArrayAdviceInvestigation{\"PreInvestTypeIDP\":\"${listInvestigationsResults[i].idp}\"},";
      }
    }
    jArrayAdviceInvestigation = jArrayAdviceInvestigation + "]";
    jArrayAdviceInvestigation = jArrayAdviceInvestigation.replaceAll(",]", "]");*/
    var jArrayLabInvestigation = "[";
    for (var i = 0; i < listSendToLabInvestigationsResults.length; i++) {
      if (listSendToLabInvestigationsResults[i].isChecked!) {
        jArrayLabInvestigation =
        "$jArrayLabInvestigation{\"HealthCareProviderIDP\":\"${listSendToLabInvestigationsResults[i].idp}\"},";
      }
    }

    jArrayLabInvestigation = jArrayLabInvestigation + "]";
    jArrayLabInvestigation = jArrayLabInvestigation.replaceAll(",]", "]");

    var markAsCheckoutVal = markAsCheckout ? "1" : "0";
    var sendToLab = isCheckedSendToLab ? "1" : "0";
    debugPrint(
        "Payment due status - $paymentDueStatus, mark as checkout - $markAsCheckoutVal");
    if (paymentDueStatus == "1" && markAsCheckoutVal == "0") {
      showPaymentDueDialog();
      return;
    }
    String loginUrl = "${baseURL}doctorConsultationAdd.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    String patientIDP = await getPatientOrDoctorIDP();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    if (selectedReferredDoctorId == '-1') {
      selectedReferredDoctorId = "-";
    }
    debugPrint("Send selectedReferredDoctorId $selectedReferredDoctorId");
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String bpSystolic = "",
        bpDiastolic = "",
        pulse = "",
        spo2 = "",
        temperature = "";
    // height = "",
    // weight = "";
    if (widget.consultationVitalsController.isCheckedBPSystolic.value) {
      bpSystolic = bpSystolicValue.toString();
      bpDiastolic = bpDiastolicValue.toString();
    }
    /*if (widget.consultationVitalsController.isCheckedBPDiastolic.value)*/
    if (widget.consultationVitalsController.isCheckedPulse.value)
      pulse = pulseValue.toString();
    if (widget.consultationVitalsController.isCheckedSPO2.value)
      spo2 = spo2Value.toString();
    if (widget.consultationVitalsController.isCheckedTemperature.value)
      temperature = tempValue.toStringAsFixed(2);
    // if (widget.consultationVitalsController.isCheckedHeight.value)
    //   height = heightValue.toString();
    // if (widget.consultationVitalsController.isCheckedWeight.value)
    //   weight = weightValue.toString();

    String jsonStr = "{" +
        "\"" +
        "DoctorIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDP +
        "\"," +
        "\"" +
        "HospitalConsultationIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.idp +
        "\"" +
        ",\"PatientIDP\":\"${widget.patientIDP}\"" +
        ",\"BPSystolic\":\"$bpSystolic\"" +
        ",\"BPDystolic\":\"$bpDiastolic\"" +
        ",\"Temperature\":\"$temperature\"" +
        ",\"Pulse\":\"$pulse\"" +
        ",\"SPO2\":\"$spo2\"" +
        // ",\"Height\":\"$height\"" +
        // ",\"Weight\":\"$weight\"" +
        /*",\"History\":\"${historyController.text.trim()}\"" +*/
        ",\"History\":\"\"" +
        ",\"Complain\":\"${replaceNewLineBySlashN(complaintController.text.toString().trim())}\"" +
        ",\"Diagnosis\":\"${replaceNewLineBySlashN(diagnosisController.text.toString().trim())}\"" +
        /*",\"SystemicIllness\":\"${systemicIllnessController.text.trim()}\"" +*/
        ",\"Examination\":\"${replaceNewLineBySlashN(examinationController.text.toString().trim())}\"" +
        /*",\"Advice\":\"${adviceController.text.trim()}\"" +*/
        ",\"CheckOutStatus\":\"$markAsCheckoutVal\"" +
        /*",\"NextVisitPlan\":\"${nextVisitPlanController.text.trim()}\"" +*/
        ",\"FollowUpDate\":\"${followUpDateController.text.trim()}\"" +
        ",\"FollowUpTime\":\"${followUpTimeController.text.trim()}\"" +
        ",\"RadiologyInvestigations\":\"${radiologyInvestigationsController.text.trim()}\""+
        ",\"InvestigationData\":\"${adviceInvestigationController.text.trim()}\"" +
        ",\"remarks\":\"${replaceNewLineBySlashN(remarksController.text.toString().trim())}\"" +
        ",\"PaymentStatus\":\"$paymentDueStatus\"" +
        ",\"SendtoStatus\":\"$sendToLab\"" +
        ",\"InternalNotes\":\"${internalNotesController.text}\"" +
        ",\"refferdoctor\":\"$selectedReferredDoctorId\"" +
        ",\"referrdoctorname\":\"${referredDoctorNameController.text.trim()}\"" +
        ",\"referrdoctormobile\":\"${referredDoctorMobileController.text.trim()}\"" +
        ",\"reason\":\"${referenceNoteController.text.trim()}\"" +
        ",\"LabInvestigationData\":$jArrayLabInvestigation" +
        "}";



    debugPrint('Check------------------------------------------------');
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
      if (totalServices == "0") {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return OPDRegistrationDetailsScreen(widget.idp, widget.patientIDP);
        })).then((value) {
          Navigator.of(context).pop();
        });
      } else {
        Future.delayed(Duration(milliseconds: 300), () {
          Navigator.of(context).pop();
        });
      }
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      pr!.hide();
    }
  }

  void setRadiologyString() {
    String radiologyInvestigationStr = "";
    for (int i = 0; i < listRadiologyInvestigationsResults.length; i++) {
      ModelOPDRegistration model = listInvestigationsResults[i];
      if (i != 0) {
        radiologyInvestigationStr = radiologyInvestigationStr + ", " + model.name!;
      } else {
        radiologyInvestigationStr = model.name!;
      }
      //listInvestigations.add(ModelOPDRegistration());
    }
    setState(() {
      radiologyInvestigationsController=
          TextEditingController(text: radiologyInvestigationStr);
      // adviceInvestigationController =
      //     TextEditingController(text: adviceInvestigationStr);
    });
  }

  void setAdviceString() {
    String adviceInvestigationStr = "";
    for (int i = 0; i < listInvestigationsResults.length; i++) {
      ModelOPDRegistration model = listInvestigationsResults[i];
      if (i != 0) {
        adviceInvestigationStr = adviceInvestigationStr + ", " + model.name!;
      } else {
        adviceInvestigationStr = model.name!;
      }
      //listInvestigations.add(ModelOPDRegistration());
    }
    setState(() {
      adviceInvestigationController =
          TextEditingController(text: adviceInvestigationStr);
    });
  }

  void setLabInvestigationIDPS() {
    debugPrint(
        "length of lab inv - ${listSendToLabInvestigationsResults.length}");
    if (listSendToLabInvestigationsResults.length > 0) {
      setState(() {
        isCheckedSendToLab = true;
      });
    }
    /* String adviceInvestigationStr = "";
    for (int i = 0; i < listSendToLabInvestigationsResults.length; i++) {
      ModelOPDRegistration model = listSendToLabInvestigationsResults[i];
      if (i != 0) {
        adviceInvestigationStr = adviceInvestigationStr + ", " + model.name;
      } else {
        adviceInvestigationStr = model.name;
      }
    }
    setState(() {
      adviceInvestigationController =
          TextEditingController(text: adviceInvestigationStr);
    });*/
  }

  void pdfButtonClick(BuildContext context,
      ModelOPDRegistration modelOPDRegistration, String pdfType) {
    pdfTypeController.setPdfType(pdfType);
    /*if (modelOPDRegistration.checkOutStatus == "1") {*/
    getPdfDownloadPath(context, modelOPDRegistration.idp!, widget.patientIDP);
    /*} else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please checkout this patient to view the document."),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }*/
  }

  void getTemplatesForComplaint() async {
    print('getTemplatesForComplaint');
    String loginUrl = "${baseURL}doctorComplainTemplate.php";
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr =
        "{" + "\"" + "DoctorIDP" + "\"" + ":" + "\"" + patientIDP + "\"" + "}";

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
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Complaints Templates : " + strData);
      if (//strData != null ||
      strData.trim() != "null") {
        listComplaints = complaintTemplateModelFromJson(strData);
        setState(() {});
      }
    }
  }

  void getTemplatesForExamination() async {
    print('getTemplatesForExamination');
    String loginUrl = "${baseURL}doctorExaminationTemplate.php";
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr =
        "{" + "\"" + "DoctorIDP" + "\"" + ":" + "\"" + patientIDP + "\"" + "}";

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
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Remarks Templates : " + strData);
      if (strData != null || strData.trim() != "null") {
        listExamination = examinationTemplateModelFromJson(strData);
        setState(() {});
      }
    }
  }

  void getTemplatesForDiagnosis() async {
    print('getTemplatesForDiagnosis');
    String loginUrl = "${baseURL}doctorDiagnosisTemplate.php";
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr =
        "{" + "\"" + "DoctorIDP" + "\"" + ":" + "\"" + patientIDP + "\"" + "}";

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
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Remarks Templates : " + strData);
      if (strData != null || strData.trim() != "null") {
        listDiagnosis = diagnosisTemplateModelFromJson(strData);
        setState(() {});
      }
    }
  }

  void onClickTemplate(String whichTemplate, int index) {
    if (whichTemplate == "Con") {
      getConsultationDetailsFromTemplate(listConsultationTemplates[index]);
      return;
    }
    if (getNullCondition(whichTemplate, index)) {
      String temp = "";
      if (getController(whichTemplate)!.text != "") {
        temp = getController(whichTemplate)!.text +
            ", " +
            getDetailsElement(whichTemplate, index).toString().trim();
      } else {
        temp = getDetailsElement(whichTemplate, index).toString().trim();
      }
      debugPrint(temp);
      getController(whichTemplate)!.text = temp;
    } else {
      getController(whichTemplate)!.text = "";
    }
  }

  bool selectedPatientOfSameDate() {
    /*if (widget.from == "selectedPatient") {

    }
    return true;*/
    DateTime now = DateTime.now();
    debugPrint("appointment date");
    //debugPrint(slashFormatted);
    var dateArray = widget.appointmentDate!.split("/");
    String day = dateArray[0];
    String month = dateArray[1];
    String year = dateArray[2];
    int intDay = int.parse(day);
    int intMonth = int.parse(month);
    int intYear = int.parse(year);
    debugPrint("appt date");
    debugPrint("$day $month $year");
    DateTime appointmentDate = DateTime(intYear, intMonth, intDay);
    int diff = appointmentDate.difference(now).inDays;
    debugPrint("diff. - $diff");
    if (diff < 0) {
      debugPrint("before");
      return false;
    }
    debugPrint("equal or after");
    return true;
  }

  void getTemplatesForConsultation() async {
    print('getTemplatesForConsultation');
    String loginUrl = "${baseURL}doctorConsultationTemplate.php";
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr =
        "{" + "\"" + "DoctorIDP" + "\"" + ":" + "\"" + patientIDP + "\"" + "}";

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
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Consultation templates : " + strData);
      listConsultationTemplates = consultationTemplateModelFromJson(strData);
      setState(() {});
    }
  }

  void getConsultationDetailsFromTemplate(
      ConsultationTemplateModel modelConsultationTemplateModel) async {
    pr = ProgressDialog(context);
    pr!.show();
    String loginUrl = "${baseURL}doctorConsultationTemplateSelect.php";
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
        ",\"ConsultationTemplateIDP\":\"${modelConsultationTemplateModel.consultationTemplateIdp}\"" +
        ",\"HospitalConsultationIDP\":\"${widget.idp}\"" +
        "}";
    debugPrint("consultation template object");
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
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr!.hide();
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Consultation templates : " + strData);
      final jsonData = json.decode(strData);
      final jo = jsonData[0];
      complaintSupportController.text =
          append(complaintSupportController, jo['ComplainTemplateName']);
      examinationSupportController.text =
          append(examinationSupportController, jo['ExaminationTemplateName']);
      diagnosisSupportController.text =
          append(diagnosisSupportController, jo['DiagnosisTemplateName']);
      adviceInvestigationSupportController.text = append(
          adviceInvestigationSupportController, jo['InvestigationTemplateName']);
      remarksController.text =
          append(remarksController, jo['NotesTemplateName']);
      setState(() {});
    }
  }

  String append(TextEditingController controller, String text) {
    // debugPrint("controller text");
    debugPrint(controller.text.trim());
    if (controller.text.trim() == "")
      return text.replaceAll("\r", '');
    else
      return controller.text.trim() + ", " + text.replaceAll("\r", '');
  }

  void showPdfTypeSelectionDialog(List<PdfType> list,
      ModelOPDRegistration modelOPDRegistration, BuildContext mContext) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                            child: Text(
                              "Select Pdf to download",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                                color: Colors.blue,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                /*Expanded(
                  child:*/
                ListView.builder(
                    itemCount: list.length,
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            pdfButtonClick(
                              mContext,
                              modelOPDRegistration,
                              listPdfType[index].typeKeyword,
                            );
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
                                          width: 2.0, color: Colors.white),
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
                                      child: Row(
                                        children: [
                                          FaIcon(
                                            list[index].iconData,
                                            size:
                                            SizeConfig.blockSizeHorizontal !*
                                                5,
                                            color: Colors.green,
                                          ),
                                          SizedBox(
                                            width:
                                            SizeConfig.blockSizeHorizontal !*
                                                6.0,
                                          ),
                                          Text(
                                            list[index].typeName,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize: SizeConfig
                                                  .blockSizeHorizontal !*
                                                  4.3,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        ],
                                      )))));
                    }),
                /*),*/
              ],
            )));
  }

  void showPaymentDueDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Container(
              height: SizeConfig.blockSizeVertical !* 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  InkWell(
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.red,
                      size: SizeConfig.blockSizeHorizontal !* 6.2,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  )
                      .paddingSymmetric(
                    horizontal: SizeConfig.blockSizeHorizontal !* 3.0,
                  )
                      .paddingOnly(
                    bottom: SizeConfig.blockSizeVertical !* 3.0,
                    top: SizeConfig.blockSizeVertical !* 1.5,
                  ),
                  Column(
                    children: [
                      Text(
                        "To keep the payment pending/due you need to 'Mark as Checkout' this consultation.\n\nIf you don't want to checkout you can make this Consultation Paid.",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeHorizontal !* 3.8,
                          letterSpacing: 1.4,
                        ),
                      ).paddingOnly(
                        bottom: SizeConfig.blockSizeVertical !* 1.0,
                      ),
                      Text(
                        "\nDo you want to make the Consultation Paid?",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeHorizontal !* 3.8,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ).paddingOnly(
                        bottom: SizeConfig.blockSizeVertical !* 2.5,
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "No",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: SizeConfig.blockSizeHorizontal !* 3.6,
                              ),
                            ),
                          ).expanded(),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              paymentDueStatus = "0";
                            },
                            child: Text(
                              "Yes",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: SizeConfig.blockSizeHorizontal !* 3.6,
                              ),
                            ),
                          ).expanded(),
                        ],
                      )
                    ],
                  ).paddingSymmetric(
                    horizontal: SizeConfig.blockSizeHorizontal !* 3.0,
                  ),
                ],
              ))),
    );
  }

  void preparePdfList() {
    if (clearedFromDueStatus == "1" || paymentDueStatus == "1") {
      listPdfType = [
        PdfType(
          "Prescription",
          "prescription",
          FontAwesomeIcons.prescription,
        ),
        PdfType(
          "Invoice",
          "invoice",
          FontAwesomeIcons.fileInvoice,
        ),
      ];
    } else {
      listPdfType = [
        PdfType(
          "Prescription",
          "prescription",
          FontAwesomeIcons.prescription,
        ),
        PdfType(
          "Receipt",
          "receipt",
          FontAwesomeIcons.rupeeSign,
        ),
        PdfType(
          "Invoice",
          "invoice",
          FontAwesomeIcons.fileInvoice,
        ),
      ];
    }
  }

  void selectInvestigationsToSendToLab() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SelectInvestigationsToSendToLabScreen(
              listSendToLabInvestigationsResults)),
    ).then((result) {
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
      if (result != null && result.containsKey('selection')) {
        listSendToLabInvestigationsResults = result['selection'];
        setLabInvestigationIDPS();
      }
    });
  }
}

backgroundImage(String imgUrl) {
  (imgUrl != "")
      ? NetworkImage(
      "$userImgUrl${imgUrl}")
      : AssetImage("images/ic_user_placeholder.png");
}

class DropDownDialog extends StatefulWidget {
  List<DropDownItemConsultation> list;
  String type;
  Function callbackFromDialog;

  DropDownDialog(this.list, this.type, this.callbackFromDialog);

  @override
  State<StatefulWidget> createState() {
    return DropDownDialogState();
  }
}

class DropDownDialogState extends State<DropDownDialog> {
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
                                          widget.list = listReferredDoctor
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
                                    widget.list = listReferredDoctor;
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
                          if (widget.type == str_referred_to_doctor) {
                            selectedReferredDoctor = widget.list[index];
                            referredDoctorController = TextEditingController(
                                text: selectedReferredDoctor.value);
                            selectedReferredDoctorId =
                                selectedReferredDoctor.idp;
                            print('selectedReferredDoctorId $selectedReferredDoctorId');
                            Navigator.of(context).pop();
                            setState(() {});
                            //getStatesList();
                            widget.callbackFromDialog(widget.type);
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

class SliderWidget extends StatefulWidget {
  final double sliderHeight;
  int min;

  int max;
  String title = "";
  double value;
  final fullWidth;
  String unit;
  Function? callbackFromBMI;
  Function? selectedPatientOfSameDate;
  bool isDecimal;

  SliderWidget({
    this.sliderHeight = 50,
    this.max = 1000,
    this.min = 0,
    this.value = 0,
    this.title = "",
    this.fullWidth = true,
    this.unit = "",
    this.callbackFromBMI,
    this.selectedPatientOfSameDate,
    this.isDecimal = false,
  });

  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  double _value = 0;
  ConsultationVitalsController consultationVitalsController = Get.find();

  @override
  void initState() {
    //_value = widget.value / (widget.max - widget.min);
    _value = widget.value;
    if (widget.title == "Pulse") pulseValue = _value;
    if (widget.title == "Temperature")
      tempValue = _value;
    else if (widget.title == "BP Systolic")
      bpSystolicValue = _value;
    else if (widget.title == "BP Diastolic")
      bpDiastolicValue = _value;
    else if (widget.title == "SPO2")
      spo2Value = _value;
    else if (widget.title == "Height")
      heightValue = _value;
    else if (widget.title == "Weight") weightValue = _value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color getColorFromTitle(String title) {
      if (title == "BP Systolic")
        return Colors.amber;
      else if (title == "BP Diastolic")
        return Colors.blue;
      else if (title == "SPO2")
        return Colors.green;
      else if (title == "Pulse")
        return Colors.deepOrangeAccent;
      else if (title == "Temperature")
        return Colors.teal;
      else if (title == "Height")
        return Colors.purpleAccent;
      else if (title == "Weight") return Colors.cyan;
      return Colors.amber;
    }

    return Container(
      color: Colors.white,
      width: SizeConfig.blockSizeHorizontal !* 92.0,
      padding:
      EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal !* 6),
      child: Obx(
            () => Column(
          children: <Widget>[
            Visibility(
              visible: widget.title == "Height",
              child: Text(
                '$heightInFeet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal !* 3.8,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            Visibility(
              visible: widget.title == "Walking",
              child: Text(
                '$walkingStepsValue steps',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal !* 3.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Checkbox(
                    value: getValueOfCheckBox(),
                    onChanged: (isChecked) {
                      if (widget.title == "Pulse") {
                        consultationVitalsController.isCheckedPulse.value =
                        isChecked!;
                        /*if (!isChecked) {
                                widget.value = widget.min.toDouble();
                                pulseValue = widget.min.toDouble();
                                setState(() {});
                              }*/
                      } else if (widget.title == "BP Systolic") {
                        consultationVitalsController.isCheckedBPSystolic.value =
                        isChecked!;
                        /*if (!isChecked) {
                                widget.value = widget.min.toDouble();
                                bpSystolicValue = widget.min;
                                setState(() {});
                              }*/
                      } else if (widget.title == "BP Diastolic") {
                        consultationVitalsController.isCheckedBPSystolic.value =
                        isChecked!;
                        /*if (!isChecked) {
                                widget.value = widget.min.toDouble();
                                bpDiastolicValue = widget.min;
                                setState(() {});
                              }*/
                      } else if (widget.title == "Temperature") {
                        consultationVitalsController
                            .isCheckedTemperature.value = isChecked!;
                      } else if (widget.title == "Height") {
                        consultationVitalsController.isCheckedHeight.value =
                        isChecked!;
                        /*if (!isChecked) {
                                widget.value = widget.min.toDouble();
                                heightValue = widget.min;
                                setState(() {});
                              }*/
                      } else if (widget.title == "Weight") {
                        consultationVitalsController.isCheckedWeight.value =
                        isChecked!;
                        /*if (!isChecked) {
                                widget.value = widget.min.toDouble();
                                weightValue = widget.min;
                                setState(() {});
                              }*/
                      } else if (widget.title == "SPO2") {
                        consultationVitalsController.isCheckedSPO2.value =
                        isChecked!;
                        /*if (!isChecked) {
                                widget.value = widget.min.toDouble();
                                spo2Value = widget.min;
                                setState(() {});
                              }*/
                      }
                    }),
                Expanded(
                  child: UltimateSlider(
                      minValue: widget.min.toDouble(),
                      maxValue: widget.max.toDouble(),
                      value: widget.value,
                      showDecimals: widget.isDecimal,
                      decimalInterval: 0.05,
                      titleText: widget.title,
                      unitText: widget.unit,
                      indicatorColor: getColorFromTitle(widget.title),
                      bubbleColor: getColorFromTitle(widget.title),
                      onValueChange: (val) {
                        widget.value = val.toDouble();
                        if (jsonConsultation['CheckOutStatus'] == "0" &&
                            widget.selectedPatientOfSameDate!()) {
                          setState(() {
                            _value = val.toDouble();
                            widget.value = val.toDouble();
                            if (widget.title == "Pulse") {
                              pulseValue = widget.value;
                              consultationVitalsController
                                  .isCheckedPulse.value = true;
                              debugPrint(pulseValue.round().toString());
                            }
                            if (widget.title == "Temperature") {
                              tempValue = widget.value;
                              consultationVitalsController
                                  .isCheckedTemperature.value = true;
                            } else if (widget.title == "BP Systolic") {
                              bpSystolicValue = widget.value;
                              consultationVitalsController
                                  .isCheckedBPSystolic.value = true;
                              debugPrint(bpSystolicValue.round().toString());
                            } else if (widget.title == "BP Diastolic") {
                              bpDiastolicValue = widget.value;
                              consultationVitalsController
                                  .isCheckedBPSystolic.value = true;
                              /*consultationVitalsController
                                        .isCheckedBPDiastolic.value = true;*/
                              debugPrint(bpDiastolicValue.round().toString());
                            } else if (widget.title == "SPO2") {
                              spo2Value = widget.value;
                              consultationVitalsController.isCheckedSPO2.value =
                              true;
                              debugPrint(spo2Value.round().toString());
                            } else if (widget.title == "Weight") {
                              weightValue = widget.value;
                              consultationVitalsController
                                  .isCheckedWeight.value = true;
                              widget.callbackFromBMI!();
                            } else if (widget.title == "Height") {
                              heightValue = widget.value;
                              consultationVitalsController
                                  .isCheckedHeight.value = true;
                              cmToFeet();
                              widget.callbackFromBMI!();
                            }
                          });
                        }
                      }),
                ),
              ],
            ),
            SizedBox(
              height: SizeConfig.blockSizeVertical !* 5.0,
            )
          ],
        ),
      ),
    );
  }

  void cmToFeet() {
    double heightInFeetWithDecimal = heightValue * 0.0328084;
    int intHeightInFeet = heightInFeetWithDecimal.toInt();
    double remainingDecimals = heightInFeetWithDecimal - intHeightInFeet;
    int intHeightInInches = (remainingDecimals * 12).round().toInt();
    if (intHeightInInches == 12) {
      intHeightInFeet++;
      intHeightInInches = 0;
    }
    heightInFeet = "$intHeightInFeet Ft  $intHeightInInches In";
  }

  bool getValueOfCheckBox() {
    if (widget.title == "Pulse") {
      return consultationVitalsController.isCheckedPulse.value;
    }
    if (widget.title == "Temperature") {
      return consultationVitalsController.isCheckedTemperature.value;
    } else if (widget.title == "BP Systolic") {
      return consultationVitalsController.isCheckedBPSystolic.value;
    } else if (widget.title == "BP Diastolic") {
      return consultationVitalsController.isCheckedBPSystolic.value;
      /*return consultationVitalsController.isCheckedBPDiastolic.value;*/
    } else if (widget.title == "SPO2") {
      return consultationVitalsController.isCheckedSPO2.value;
    } else if (widget.title == "Height") {
      return consultationVitalsController.isCheckedHeight.value;
    } else if (widget.title == "Weight") {
      return consultationVitalsController.isCheckedWeight.value;
    }
    return false;
  }
}
