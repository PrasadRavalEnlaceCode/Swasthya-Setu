import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swasthyasetu/app_screens/my_document_doctor/my_document_doctor_screen.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/color.dart';
import 'package:swasthyasetu/utils/multipart_request_with_progress.dart';
import 'package:swasthyasetu/utils/progress_dialog_with_percentage.dart';

TextEditingController tagNameController = TextEditingController();

TextEditingController entryDateController = new TextEditingController();
TextEditingController entryTimeController = new TextEditingController();
// List<Map<String, dynamic>> listDoc = <Map<String, dynamic>>[];NurseAddDocumentScreen
List<String> listOfDocumentDropDown = [];
List<int> listOfDocumentIDP = [];
Map<String, int> documentIDMap = {};
String? selectedDocument;

var pickedDate = DateTime.now();
var pickedTime = TimeOfDay.now();

class NurseAddDocumentScreen extends StatefulWidget {
  String? patientIDP;

  NurseAddDocumentScreen(String? patientIDP) {
    this.patientIDP = patientIDP;
  }

  @override
  State<StatefulWidget> createState() {
    return NurseAddDocumentScreenState();
  }
}

class NurseAddDocumentScreenState extends State<NurseAddDocumentScreen> {
  File? selectedFile;
  String selectedFileType = "";
  GlobalKey<ProgressDialogWithPercentageState> progressKey = GlobalKey();
  final picker = ImagePicker();

  @override
  void dispose() {
    tagNameController.clear();
    entryDateController.clear();
    entryTimeController.clear();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    var pickedDate = DateTime.now();
    var formatter = new DateFormat('dd-MM-yyyy');
    String formatted = formatter.format(pickedDate);
    entryDateController = TextEditingController(text: formatted);
    getListOfDocumentDropDown(context);
    final now = new DateTime.now();
    var dateOfTime =
    DateTime(now.year, now.month, now.day, now.hour, now.minute);

    pickedTime = TimeOfDay.now();

    var formatterTime = new DateFormat('HH:mm');
    String formattedTime = formatterTime.format(dateOfTime);
    entryTimeController = TextEditingController(text: formattedTime);
    setState(() {});
  }


  void getListOfDocumentDropDown(BuildContext context) async{
    listOfDocumentDropDown = [];
    String loginUrl = "${baseURL}doctor_category_wise_document_type_list.php";
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
        "}";

    debugPrint(jsonStr);
    debugPrint("----------");
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
    if (response.statusCode == 200)
      try{
        if (model.status == "OK") {
          var data = jsonResponse['Data'];
          var strData = decodeBase64(data);
          debugPrint("Decoded Buttton List: " + strData);

          final jsonData = json.decode(strData);

          for (var i = 0; i < jsonData.length; i++) {
            final jo = jsonData[i];
            String category = jo['Category'].toString();
            listOfDocumentDropDown.add(category);

            int documentCategoryIDP = jo['DocumentCategoryIDP'];
            listOfDocumentIDP.add(documentCategoryIDP);

            // Populate the map
            documentIDMap[category] = documentCategoryIDP;
          }

          // for (var i = 0; i < jsonData.length; i++)
          // {
          //   final jo = jsonData[i];
          //   String category = jo['Category'].toString();
          //   listOfDocumentDropDown.add(category);
          //
          //   int DocumentCategoryIDP = jo['DocumentCategoryIDP'];
          //   listOfDocumentIDP.add(DocumentCategoryIDP);
          // }
          setState(() {});
        }
      }catch(e){
        print("Error decoding JSON: $e");
      }else {
      print("HTTP error: ${response.statusCode}");
    }
  }

  // Method to handle document selection
  void onDocumentSelected(String selectedDocument) {
    int? selectedDocumentIDP = documentIDMap[selectedDocument];
    if (selectedDocumentIDP != null) {

    } else {
      print("Document ID not found for selected document: $selectedDocument");
    }
  }


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Add in My Document",
            style: TextStyle(fontSize: SizeConfig.blockSizeVertical !* 2.5),
          ),
          backgroundColor: Color(0xFFFFFFFF),
          iconTheme: IconThemeData(color: Colorsblack),
          toolbarTextStyle: TextTheme(
              titleMedium: TextStyle(color: Colorsblack, fontFamily: "Ubuntu")).bodyMedium, titleTextStyle: TextTheme(
            titleMedium: TextStyle(color: Colorsblack, fontFamily: "Ubuntu")).titleLarge,
        ),
        body: Builder(
          builder: (context) {
            return Column(
              children: <Widget>[
                (selectedFile != null)
                    ? SizedBox(
                  height: 20,
                )
                    : Container(),
                Expanded(
                    child: ListView(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                //showDocumentTypeSelectionDialog(context);
                                showDocumentTypeSelectionDialog(context);
                              },
                              child: (selectedFile != null)
                                  ?
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Stack(
                                    /*mainAxisAlignment: MainAxisAlignment.center,*/
                                    children: <Widget>[
                                      Container(
                                        child: selectedFileType == "image"
                                            ? Image(
                                          fit: BoxFit.fill,
                                          image:
                                          FileImage(selectedFile!),
                                          height: SizeConfig
                                              .blockSizeVertical !*
                                              25,
                                        )
                                            : Image(
                                          fit: BoxFit.fill,
                                          image: AssetImage(
                                              "images/ic_doc.png"),
                                          height: SizeConfig
                                              .blockSizeVertical !*
                                              18,
                                        ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            showDocumentTypeSelectionDialog(
                                                context);
                                            //showDocumentTypeSelectionDialog(context);
                                          },
                                          child: Opacity(
                                            opacity: 0.6,
                                            child: CircleAvatar(
                                              radius: SizeConfig
                                                  .blockSizeHorizontal !*
                                                  5,
                                              child: Image(
                                                width: SizeConfig
                                                    .blockSizeHorizontal !*
                                                    4,
                                                height: SizeConfig
                                                    .blockSizeHorizontal !*
                                                    4,
                                                color: Colors.white,
                                                //height: 80,
                                                image: AssetImage(
                                                    "images/ic_edit_black.png"),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height:
                                    SizeConfig.blockSizeVertical !* 1.3,
                                  ),
                                  Text(
                                    selectedFile!.path.split("/")[
                                    selectedFile!.path.split("/").length -
                                        1],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              )
                                  : Container(
                                  width: double.infinity,
                                  color: Colors.blueGrey,
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                        SizeConfig.blockSizeHorizontal !* 5.0),
                                    child: Column(children: [
                                      Image(
                                        image: AssetImage(
                                            "images/ic_file_upload.png"),
                                        width:
                                        SizeConfig.blockSizeHorizontal !* 12,
                                        height:
                                        SizeConfig.blockSizeHorizontal !* 12,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        height:
                                        SizeConfig.blockSizeVertical !* 2.0,
                                      ),
                                      Text(
                                        "Click to upload document",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                            SizeConfig.blockSizeHorizontal !*
                                                3.8),
                                      ),
                                    ]),
                                  )
                                /*BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 3.0, sigmaY: 3.0),
                                        child: Container(
                                          color: Colors.black.withOpacity(0.3),
                                        ),
                                      ),*/
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),  // Border color
                              borderRadius: BorderRadius.circular(8.0),  // Border radius
                            ),
                            width: SizeConfig.blockSizeHorizontal !* 90,
                            child: DropdownButton<String>(
                              value: selectedDocument ?? "10th MarkSheet",
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedDocument = newValue;
                                  tagNameController.text = selectedDocument ?? '';
                                });
                                if (newValue != null) {
                                  onDocumentSelected(newValue);
                                }
                              },
                              isExpanded: true,
                              items: listOfDocumentDropDown.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Center(child: Text(value)),
                                );
                              }).toList(),

                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: SizeConfig.blockSizeHorizontal !* 90,
                            padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 3),
                            child: TextField(
                              controller: tagNameController,
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: SizeConfig.blockSizeVertical !* 2.3),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: SizeConfig.blockSizeVertical !* 2.3),
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: SizeConfig.blockSizeVertical !* 2.3),
                                labelText: "Document Name",
                                hintText: "",
                              ),

                            ),
                          ),
                        ),
                      ],
                    )),
                /*Container(
                  height: 80.0,
                  padding: EdgeInsets.only(
                      right: SizeConfig.blockSizeHorizontal * 3.5,
                      top: SizeConfig.blockSizeVertical * 3.5),
                  child:*/
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: SizeConfig.blockSizeHorizontal !* 12,
                    height: SizeConfig.blockSizeHorizontal !* 12,
                    child: RawMaterialButton(
                      onPressed: () {
                        submitDocumentDoctor(context, selectedFile);
                      },
                      elevation: 2.0,
                      fillColor: Color(0xFF06A759),
                      child: Image(
                        width: SizeConfig.blockSizeHorizontal !* 5.5,
                        height: SizeConfig.blockSizeHorizontal !* 5.5,
                        //height: 80,
                        image:
                        AssetImage("images/ic_right_arrow_triangular.png"),
                      ),
                      shape: CircleBorder(),
                    ),
                  ),
                ),
                /*),*/
              ],
            );
          },
        ));
  }

  dialogContent(BuildContext context, String title) {
    SizeConfig().init(context);

    Future getImageFromCamera() async {
      /*ViewProfileDetailsState.image =
        await ImagePicker.pickImage(source: ImageSource.camera);*/
      File imgSelected =
      await chooseImageWithExIfRotate(picker, ImageSource.camera);
      if (imgSelected != null) {
        CroppedFile? croppedImage = await ImageCropper().cropImage(
          sourcePath: imgSelected.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Cropper',
                toolbarColor: Colors.deepOrange,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            IOSUiSettings(
              title: 'Cropper',
            ),
            WebUiSettings(
              context: context,
            ),
          ],
        );
        final path = croppedImage!.path;
        selectedFile = File(path);
        selectedFileType = "image";
        Navigator.of(context).pop();
        setState(() {});
      }
      //if (image != null) submitImageForUpdate(context, image);
      //_controller.add(image);
    }

    Future removeImage() async {
      /*ViewProfileDetailsState.image =
        await ImagePicker.pickImage(source: ImageSource.camera);*/
      selectedFile = null;
      Navigator.of(context).pop();
      setState(() {});
      //if (image != null) submitImageForUpdate(context, image);
      //_controller.add(image);
    }

    Future getImageFromGallery() async {
      /*ViewProfileDetailsState.image =
        await ImagePicker.pickImage(source: ImageSource.gallery);*/
      File imgSelected =
      await chooseImageWithExIfRotate(picker, ImageSource.gallery);
      if (imgSelected != null) {
        CroppedFile? croppedImage = await ImageCropper().cropImage(
          sourcePath: imgSelected.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Cropper',
                toolbarColor: Colors.deepOrange,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            IOSUiSettings(
              title: 'Cropper',
            ),
            WebUiSettings(
              context: context,
            ),
          ],
        );
        final path = croppedImage!.path;
        selectedFile = File(path);
        selectedFileType = "image";
        Navigator.of(context).pop();
        setState(() {});
      }
    }

    return Stack(
      children: <Widget>[
        //...bottom card part,
        Container(
          width: SizeConfig.blockSizeHorizontal !* 90,
          height: SizeConfig.blockSizeVertical !* 45,
          padding: EdgeInsets.only(
            top: SizeConfig.blockSizeHorizontal !* 1,
            bottom: SizeConfig.blockSizeHorizontal !* 1,
            left: SizeConfig.blockSizeHorizontal !* 1,
            right: SizeConfig.blockSizeHorizontal !* 1,
          ),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: SizeConfig.blockSizeHorizontal !* 3.0,
                  ),
                  InkWell(
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.red[800],
                      size: SizeConfig.blockSizeVertical !* 3.2,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(
                    width: SizeConfig.blockSizeHorizontal !* 5.0,
                  ),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal !* 4.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical !* 1.5,
              ),
              Container(
                margin: EdgeInsets.only(
                  left: SizeConfig.blockSizeHorizontal !* 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.rectangle,
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.grey),
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    getImageFromCamera();
                  },
                  child: Row(
                    children: [
                      Image(
                        fit: BoxFit.contain,
                        width: SizeConfig.blockSizeHorizontal !* 8,
                        height: SizeConfig.blockSizeVertical !* 8,
                        //height: 80,
                        image: AssetImage("images/ic_camera.png"),
                      ),
                      SizedBox(
                        width: SizeConfig.blockSizeHorizontal !* 3.0,
                      ),
                      Text(
                        "Camera",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: SizeConfig.blockSizeHorizontal !* 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.rectangle,
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.grey),
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    getImageFromGallery();
                  },
                  child: Row(
                    children: [
                      Image(
                        fit: BoxFit.contain,
                        width: SizeConfig.blockSizeHorizontal !* 8,
                        height: SizeConfig.blockSizeVertical !* 8,
                        //height: 80,
                        image: AssetImage("images/ic_gallery.png"),
                      ),
                      SizedBox(
                        width: SizeConfig.blockSizeHorizontal !* 3.0,
                      ),
                      Text(
                        "Gallery",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: SizeConfig.blockSizeHorizontal !* 10,
                ),
                padding: EdgeInsets.only(
                  top: SizeConfig.blockSizeVertical !* 1.3,
                  bottom: SizeConfig.blockSizeVertical !* 1.3,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.rectangle,
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.grey),
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    openDocumentPicker();
                    //getImageFromGallery();
                  },
                  child: Row(
                    children: [
                      Image(
                        fit: BoxFit.contain,
                        width: SizeConfig.blockSizeHorizontal !* 8,
                        height: SizeConfig.blockSizeVertical !* 5,
                        //height: 80,
                        image: AssetImage("images/ic_doc.png"),
                      ),
                      SizedBox(
                        width: SizeConfig.blockSizeHorizontal !* 3.0,
                      ),
                      Text(
                        "Document Files",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical !* 1.5,
              ),
              Container(
                margin: EdgeInsets.only(
                  left: SizeConfig.blockSizeHorizontal !* 10,
                ),
                child: InkWell(
                  onTap: () {
                    removeImage();
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.close,
                        color: Colors.red,
                        size: SizeConfig.blockSizeHorizontal !* 8,
                      ),
                      SizedBox(
                        width: SizeConfig.blockSizeHorizontal !* 3.0,
                      ),
                      Text(
                        "No Document",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical !* 1.0,
              ),

            ],
          ),
        ),


      ],
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

  showDocumentTypeSelectionDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: dialogContent(context, "Select Document Type"),
        )
    );
  }


  void showDateSelectionDialog() async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    DateTime firstDate = DateTime.now().subtract(Duration(days: 365 * 100));
    DateTime? date = await showDatePicker(
        context: context,
        initialDate: pickedDate,
        firstDate: firstDate,
        lastDate: DateTime.now());

    if (date != null) {
      pickedDate = date;
      var formatter = new DateFormat('dd-MM-yyyy');
      String formatted = formatter.format(pickedDate);
      entryDateController = TextEditingController(text: formatted);
      setState(() {});
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
      entryTimeController = TextEditingController(text: formatted);
      setState(() {});
    }
  }

  void submitDocumentDoctor(BuildContext context, image) async {
    if (image == null) {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select Document"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    if (tagNameController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please type Document Name"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

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
      Uri.parse("${baseURL}doctor_add_staff_document_submit.php"),
      onProgress: (int bytes, int total) {
        final progress = bytes / total;
        progressKey.currentState!.setProgress(progress);
      },
    );

    // Get selected document IDP
    int? selectedDocumentIDP = documentIDMap[selectedDocument] ?? 4;

    // Check if selectedDocumentIDP is null
    if (selectedDocumentIDP == null) {
      // Show snackbar if document ID is not found
      print("Document ID not found for selected document: $selectedDocument");
      return;
    }

    // String selectedValue = selectedDocument ?? "10th MarkSheet"; // Use the selected value or a default value if none is selected
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    String staffIDP = await getDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr;
    jsonStr = "{" +
        "\"" + "DocumentIDP" + "\"" + ":" + "\"" + "" + "\"" + "," +
        "\"" + "StaffIDF" + "\"" + ":" + "\"" + staffIDP + "\"" + "," +
        "\"" + "documenttype" + "\"" + ":" + "\"" + selectedDocumentIDP.toString() + "\"" + "," +
        "\"" + "DoctorIDP" + "\"" + ":" + "\"" + patientIDP + "\"" + "," +
        "\"" + "documentname" + "\"" + ":" + "\"" + tagNameController.text + "\"" + "," +
        "\"" + "DeleteFlag" + "\"" + ":" + "\"" + "0" + "\"" +
        "}";

    // {"DocumentIDP":"","documenttype":"2","StaffIDF":"120",
    // "DoctorIDP":"1","documentname":"12th MarkSheet","DeleteFlag":"0"}

    debugPrint("Jsonstr - $jsonStr");
    debugPrint(image.path);
    String encodedJSONStr = encodeBase64(jsonStr);

    multipartRequest.fields['getjson'] = encodedJSONStr;
    Map<String, String> headers = Map();
    headers['u'] = patientUniqueKey;
    headers['type'] = userType;
    multipartRequest.headers.addAll(headers);
    if (image != null) {
      var imgLength = await image.length();
      debugPrint(image.path);
      multipartRequest.files.add(new http.MultipartFile(
          'image', image.openRead(), imgLength,
          filename: image.path)
      );
      debugPrint(image.path);
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
      //pr.hide();
      Navigator.of(context).pop();

      if (model.status == "OK") {
        final snackBar = SnackBar(
          backgroundColor: Colors.green,
          content: Text(model.message!),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Future.delayed(Duration(milliseconds: 300), () {
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => MyDocumentDoctorScreen())) ;
        });
        // Future.delayed(Duration(milliseconds: 300), () {
        //   Navigator.of(context).pop();
        // });
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
  }

  void openDocumentPicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );
    if (result != null) {
      File fileSelected = File((result.files.single.path)!);
      if (fileSelected != null) selectedFile = fileSelected;
      selectedFileType = "doc";
      Navigator.of(context).pop();
      setState(() {});
    } else {}
  }

  void selectPDFFromTheDevice(BuildContext context) async {
    /*File selectedPdf = await FilePicker.getFile(
        type: FileType.custom, allowedExtensions: ['pdf']);
    if (selectedPdf != null) selectedFile = selectedPdf;*/
  }
}
