import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_investigation_list_doctor.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';

import '../utils/color.dart';

class MyPaymentCodeScreen extends StatefulWidget {
  String payGatewayURL;

  MyPaymentCodeScreen(this.payGatewayURL);

  @override
  State<StatefulWidget> createState() {
    return MyPaymentCodeScreenState();
  }
}

class MyPaymentCodeScreenState extends State<MyPaymentCodeScreen> {
  // List<Map<String, String>> listImage = [];
  List<Map<String, dynamic>> listImage = <Map<String, dynamic>>[];
  String? imgUrl;
  File? selectedImage;
  bool qrImage = false;
  GlobalKey<ProgressDialogWithPercentageState> progressKey = GlobalKey();
  final picker = ImagePicker();
  String baseImageURL = "https://www.swasthyasetu.com/ws/images/doctorimage/";

  @override
  void initState() {
    super.initState();
    getQrCodeData(context);
    // getQRCodeForDoctor();
    // /*widget.imgUrl = "";*/
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // getQRCodeForDoctor();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment Code"),
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(color: Colorsblack),
        toolbarTextStyle: TextTheme(
            titleMedium: TextStyle(
          color: Colorsblack,
          fontFamily: "Ubuntu",
          fontSize: SizeConfig.blockSizeVertical! * 2.5,
        )).bodyMedium,
        titleTextStyle: TextTheme(
            titleMedium: TextStyle(
          color: Colorsblack,
          fontFamily: "Ubuntu",
          fontSize: SizeConfig.blockSizeVertical! * 2.5,
        )).titleLarge,
      ),
      body: listImage.isNotEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Visibility(
                //   visible: imgUrl != null && imgUrl != "",
                //   child: Align(
                //     alignment: Alignment.center,
                //     child: imgUrl != null && imgUrl != ""
                //         ? Image.network(
                //             imgUrl!,
                //             width: SizeConfig.blockSizeHorizontal !* 80,
                //             height: SizeConfig.blockSizeHorizontal !* 80,
                //             fit: BoxFit.cover,
                //           )
                //         : Container(),
                //   ),
                // ),
                // Visibility(
                //   visible: imgUrl == "",
                //   child: Container(
                //     padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 5),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.center,
                //       children: <Widget>[
                //         Image(
                //           image: AssetImage("images/ic_idea_new.png"),
                //           width: 100,
                //           height: 100,
                //         ),
                //         SizedBox(
                //           height: 30.0,
                //         ),
                //         Text(
                //           "Payment receiving service is not active for your profile.\n\n",
                //           style:
                //               TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                //         ),
                //         Align(
                //           alignment: Alignment.topLeft,
                //           child: Text(
                //             "To receive payment from patients,",
                //             style: TextStyle(
                //                 fontSize: 16.0, fontWeight: FontWeight.w500),
                //           ),
                //         ),
                //         SizedBox(
                //           height: 10.0,
                //         ),
                //         Row(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             Text(
                //               "kindly",
                //               style: TextStyle(
                //                   fontSize: 16.0, fontWeight: FontWeight.w500),
                //             ),
                //             SizedBox(
                //               width: SizeConfig.blockSizeHorizontal !* 2.0,
                //             ),
                //             MaterialButton(
                //               onPressed: () {
                //                 Navigator.of(context)
                //                     .push(MaterialPageRoute(builder: (context) {
                //                   return HelpScreen(patientIDP!);
                //                 }));
                //               },
                //               child: Text(
                //                 "Contact Us",
                //                 style: TextStyle(
                //                   color: Colors.white,
                //                   fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                //                 ),
                //               ),
                //               color: Color(0xFF06A759),
                //             ),
                //           ],
                //         )
                //       ],
                //     ),
                //   ),
                //   /*Align(
                //     alignment: Alignment.center,
                //     child: Text(
                //       "Payment receiving service is not active for your profile.\n\nTo receive payment from patients, kindly contact us.",
                //       textAlign: TextAlign.center,
                //       style: TextStyle(
                //           color: Colors.black,
                //           fontSize: SizeConfig.blockSizeHorizontal * 5.3,
                //           fontWeight: FontWeight.w500),
                //     ),
                //   ),*/
                // ),
                Visibility(
                  visible: listImage[0]["FileName"] == "NULL",
                  child: Column(
                    children: [
                      Visibility(
                        visible: selectedImage == null,
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              showDocumentTypeSelectionDialog(context);
                            },
                            child: Text('Select QR Code Image'),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: selectedImage != null
                            ? Image.file(
                                File(selectedImage!.path),
                                width: SizeConfig.blockSizeHorizontal! * 80,
                                height: SizeConfig.blockSizeHorizontal! * 80,
                                fit: BoxFit.cover,
                              )
                            : Container(),
                      ),
                      Visibility(
                        visible: selectedImage != null,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: SizeConfig.blockSizeHorizontal! * 12,
                            height: SizeConfig.blockSizeHorizontal! * 12,
                            child: RawMaterialButton(
                              onPressed: () {
                                submitDoctorQrCode(context, selectedImage);
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
                        ),
                      ),
                    ],
                  ),
                ),
                // Visibility(
                //   visible: selectedImage != null,
                //   child: Align(
                //     alignment: Alignment.center,
                //     child: selectedImage != null
                //         ? Image.file(
                //       File(selectedImage!.path),
                //       width: SizeConfig.blockSizeHorizontal! * 80,
                //       height: SizeConfig.blockSizeHorizontal! * 80,
                //       fit: BoxFit.cover,
                //     )
                //         : Container(),
                //   ),
                // ),
                // Visibility(
                //   visible: selectedImage != null,
                //   child: Align(
                //     alignment: Alignment.centerRight,
                //     child: Container(
                //       width: SizeConfig.blockSizeHorizontal !* 12,
                //       height: SizeConfig.blockSizeHorizontal !* 12,
                //       child: RawMaterialButton(
                //         onPressed: () {
                //           submitDoctorQrCode(context, selectedImage);
                //         },
                //         elevation: 2.0,
                //         fillColor: Color(0xFF06A759),
                //         child: Image(
                //           width: SizeConfig.blockSizeHorizontal !* 5.5,
                //           height: SizeConfig.blockSizeHorizontal !* 5.5,
                //           //height: 80,
                //           image:
                //           AssetImage("images/ic_right_arrow_triangular.png"),
                //         ),
                //         shape: CircleBorder(),
                //       ),
                //     ),
                //   ),
                // ),
                Visibility(
                    visible: listImage[0]["FileName"] != "NULL",
                    child: Center(
                      child: Container(
                        height: SizeConfig.blockSizeHorizontal! * 145,
                        width: SizeConfig.blockSizeHorizontal! * 95,
                        child: listImage.isNotEmpty
                            ? ListView.builder(
                                itemCount: listImage.length,
                                itemBuilder: (context, index) {
                                  return CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: baseImageURL +
                                        "${listImage[0]["FileName"]}",
                                    // placeholder: (context, url) => CircularProgressIndicator(),
                                    // errorWidget: (context, url, error) => Icon(Icons.error),
                                  );
                                })
                            : Center(
                                child: CircularProgressIndicator(),
                              ),
                      ),
                    )),
                // Visibility(
                //   visible: selectedImage != null,
                //   child: Text( selectedImage!.path.split("/")[
                //   selectedImage!.path.split("/").length -
                //       1],),
                // ),
                Text(
                  "Scan to Pay",
                  style: TextStyle(),
                )
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Future<String> getQrCodeData(BuildContext context) async {
    //getCategoryList(context);
    String loginUrl = "${baseURL}doctor_image_list.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new List();
    String patientUniqueKey = await getPatientUniqueKey();
    String patientIDP = await getPatientOrDoctorIDP();
    String userType = await getUserType();
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
    //var resBody = json.decode(response.body);
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr!.hide();
    debugPrint("response :" + response.body.toString());
    debugPrint("Data :" + model.data!);
    listImage = [];
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array : " + strData);
      final jsonData = json.decode(strData);

      for (var i = 0; i < jsonData.length; i++) {
        final jo = jsonData[i];
        String fileName = jo['FileName'].toString();
        String doctorIDP = jo['DoctorIDP'].toString();

        Map<String, dynamic> OrganizationMap = {
          "FileName": fileName,
          "DoctorIDP": doctorIDP,
        };
        listImage.add(OrganizationMap);
        // debugPrint("Added to list: $complainName");
      }
      setState(() {
        // apiCalled = true;
      });
    } else {
      setState(() {
        // apiCalled = true;
      });
    }
    return 'success';
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
        /* builder: (BuildContext context) =>
          CustomDialogSelectImage(
            title: "Select Image from",
            callback: this.callback,
          ),*/
        );
  }

  void submitDoctorQrCode(BuildContext context, Image) async {
    if (Image == null) {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select Image"),
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
      Uri.parse("${baseURL}image_upload_submit.php"),
      onProgress: (int bytes, int total) {
        final progress = bytes / total;
        progressKey.currentState!.setProgress(progress);
      },
    );

    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr;
    jsonStr =
        "{" + "\"" + "DoctorIDP" + "\"" + ":" + "\"" + patientIDP + "\"" + "}";

    debugPrint("Jsonstr - $jsonStr");

    String encodedJSONStr = encodeBase64(jsonStr);
    multipartRequest.fields['getjson'] = encodedJSONStr;
    Map<String, String> headers = Map();
    headers['u'] = patientUniqueKey;
    headers['type'] = userType;
    multipartRequest.headers.addAll(headers);
    if (Image != null) {
      var imgLength = await Image.length();
      debugPrint("fileName --- " + Image.path.toString());
      multipartRequest.files.add(new http.MultipartFile(
          'image', Image.openRead(), imgLength,
          filename: Image.path));
    }
    var response = await apiHelper.callMultipartApi(multipartRequest);
    //pr.hide();
    debugPrint("Status code - " + response.statusCode.toString());
    // debugPrint("fileName --- " + response.filename.toString());

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

        // Fetch updated data after successful image upload
        await getQrCodeData(context);

        // Future.delayed(Duration(milliseconds: 300), () {
        //   Navigator.of(context).push(MaterialPageRoute(builder: (Context) => MyPaymentCodeScreen(payGatewayURL)));
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

  dialogContent(BuildContext context, String title) {
    SizeConfig().init(context);

    // Future getImageFromCamera() async {
    //   /*ViewProfileDetailsState.image =
    //     await ImagePicker.pickImage(source: ImageSource.camera);*/
    //   File imgSelected =
    //   await chooseImageWithExIfRotate(picker, ImageSource.camera);
    //   if (imgSelected != null) {
    //     CroppedFile? croppedImage = await ImageCropper().cropImage(
    //       sourcePath: imgSelected.path,
    //       aspectRatioPresets: [
    //         CropAspectRatioPreset.square,
    //         CropAspectRatioPreset.ratio3x2,
    //         CropAspectRatioPreset.original,
    //         CropAspectRatioPreset.ratio4x3,
    //         CropAspectRatioPreset.ratio16x9
    //       ],
    //       uiSettings: [
    //         AndroidUiSettings(
    //             toolbarTitle: 'Cropper',
    //             toolbarColor: Colors.deepOrange,
    //             toolbarWidgetColor: Colors.white,
    //             initAspectRatio: CropAspectRatioPreset.original,
    //             lockAspectRatio: false),
    //         IOSUiSettings(
    //           title: 'Cropper',
    //         ),
    //         WebUiSettings(
    //           context: context,
    //         ),
    //       ],
    //     );
    //     final path = croppedImage!.path;
    //     selectedImage = File(path);
    //     // selectedFileType = "image";
    //     Navigator.of(context).pop();
    //     setState(() {});
    //   }
    //   //if (image != null) submitImageForUpdate(context, image);
    //   //_controller.add(image);
    // }

    Future removeImage() async {
      /*ViewProfileDetailsState.image =
        await ImagePicker.pickImage(source: ImageSource.camera);*/
      selectedImage = null;
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
        selectedImage = File(path);
        // selectedFileType = "image";
        Navigator.of(context).pop();
        setState(() {});
      }
      //if (image != null) submitImageForUpdate(context, image);
      //_controller.add(image);
    }

    return Stack(
      children: <Widget>[
        //...bottom card part,
        Container(
          width: SizeConfig.blockSizeHorizontal! * 90,
          height: SizeConfig.blockSizeVertical! * 45,
          padding: EdgeInsets.only(
            top: SizeConfig.blockSizeHorizontal! * 1,
            bottom: SizeConfig.blockSizeHorizontal! * 1,
            left: SizeConfig.blockSizeHorizontal! * 1,
            right: SizeConfig.blockSizeHorizontal! * 1,
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
                    width: SizeConfig.blockSizeHorizontal! * 3.0,
                  ),
                  InkWell(
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.red[800],
                      size: SizeConfig.blockSizeVertical! * 3.2,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(
                    width: SizeConfig.blockSizeHorizontal! * 5.0,
                  ),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal! * 4.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical! * 1.5,
              ),
              /*MaterialButton(
              onPressed: () {},
              child: Image(
                width: 60,
                height: 60,
                //height: 80,
                image: AssetImage("images/ic_camera.png"),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            MaterialButton(
              onPressed: () {},
              child: Image(
                width: 60,
                height: 60,
                //height: 80,
                image: AssetImage("images/ic_gallery.png"),
              ),
            ),*/
              // Container(
              //   margin: EdgeInsets.only(
              //     left: SizeConfig.blockSizeHorizontal !* 10,
              //   ),
              //   decoration: BoxDecoration(
              //     color: Colors.transparent,
              //     shape: BoxShape.rectangle,
              //     border: Border(
              //       bottom: BorderSide(width: 1.0, color: Colors.grey),
              //     ),
              //   ),
              //   child: InkWell(
              //     onTap: () {
              //       getImageFromCamera();
              //     },
              //     child: Row(
              //       children: [
              //         Image(
              //           fit: BoxFit.contain,
              //           width: SizeConfig.blockSizeHorizontal !* 8,
              //           height: SizeConfig.blockSizeVertical !* 8,
              //           //height: 80,
              //           image: AssetImage("images/ic_camera.png"),
              //         ),
              //         SizedBox(
              //           width: SizeConfig.blockSizeHorizontal !* 3.0,
              //         ),
              //         Text(
              //           "Camera",
              //           style: TextStyle(
              //             color: Colors.black,
              //             fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
              //           ),
              //         )
              //       ],
              //     ),
              //   ),
              // ),
              Container(
                margin: EdgeInsets.only(
                  left: SizeConfig.blockSizeHorizontal! * 10,
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
                        width: SizeConfig.blockSizeHorizontal! * 8,
                        height: SizeConfig.blockSizeVertical! * 8,
                        //height: 80,
                        image: AssetImage("images/ic_gallery.png"),
                      ),
                      SizedBox(
                        width: SizeConfig.blockSizeHorizontal! * 3.0,
                      ),
                      Text(
                        "Gallery",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeHorizontal! * 4.0,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              // Container(
              //   margin: EdgeInsets.only(
              //     left: SizeConfig.blockSizeHorizontal !* 10,
              //   ),
              //   padding: EdgeInsets.only(
              //     top: SizeConfig.blockSizeVertical !* 1.3,
              //     bottom: SizeConfig.blockSizeVertical !* 1.3,
              //   ),
              //   decoration: BoxDecoration(
              //     color: Colors.transparent,
              //     shape: BoxShape.rectangle,
              //     border: Border(
              //       bottom: BorderSide(width: 1.0, color: Colors.grey),
              //     ),
              //   ),
              //   child: InkWell(
              //     onTap: () {
              //       openDocumentPicker();
              //       //getImageFromGallery();
              //     },
              //     child: Row(
              //       children: [
              //         Image(
              //           fit: BoxFit.contain,
              //           width: SizeConfig.blockSizeHorizontal !* 8,
              //           height: SizeConfig.blockSizeVertical !* 5,
              //           //height: 80,
              //           image: AssetImage("images/ic_doc.png"),
              //         ),
              //         SizedBox(
              //           width: SizeConfig.blockSizeHorizontal !* 3.0,
              //         ),
              //         Text(
              //           "Document Files",
              //           style: TextStyle(
              //             color: Colors.black,
              //             fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
              //           ),
              //         )
              //       ],
              //     ),
              //   ),
              // ),
              SizedBox(
                height: SizeConfig.blockSizeVertical! * 1.5,
              ),
              Container(
                margin: EdgeInsets.only(
                  left: SizeConfig.blockSizeHorizontal! * 10,
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
                        size: SizeConfig.blockSizeHorizontal! * 8,
                      ),
                      SizedBox(
                        width: SizeConfig.blockSizeHorizontal! * 3.0,
                      ),
                      Text(
                        "No Document",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeHorizontal! * 4.0,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical! * 1.0,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // void getQRCodeForDoctor() async {
  //   String loginUrl = "${baseURL}doctorPayQR.php";
  //   ProgressDialog? pr;
  //   Future.delayed(Duration.zero, () {
  //     pr = ProgressDialog(context);
  //     pr!.show();
  //   });
  //   //listIcon = new List();
  //   String patientUniqueKey = await getPatientUniqueKey();
  //   String userType = await getUserType();
  //   String patientIDP = await getPatientOrDoctorIDP();
  //   debugPrint("Key and type");
  //   debugPrint(patientUniqueKey);
  //   debugPrint(userType);
  //   String jsonStr = "{" +
  //       "\"" +
  //       "DoctorIDP" +
  //       "\"" +
  //       ":" +
  //       "\"" +
  //       patientIDP +
  //       "\"" +
  //       "," +
  //       "\"" +
  //       "PayGatewayURL" +
  //       "\"" +
  //       ":" +
  //       "\"" +
  //       widget.payGatewayURL +
  //       "\"" +
  //       "}";
  //
  //   debugPrint(jsonStr);
  //
  //   String encodedJSONStr = encodeBase64(jsonStr);
  //   var response = await apiHelper.callApiWithHeadersAndBody(
  //     url: loginUrl,
  //     headers: {
  //       "u": patientUniqueKey,
  //       "type": userType,
  //     },
  //     body: {"getjson": encodedJSONStr},
  //   );
  //   //var resBody = json.decode(response.body);
  //   debugPrint(response.body.toString());
  //   final jsonResponse = json.decode(response.body.toString());
  //   ResponseModel model = ResponseModel.fromJSON(jsonResponse);
  //   pr!.hide();
  //   if (model.status == "OK") {
  //     /*var data = jsonResponse['Data'];
  //     var strData = decodeBase64(data);
  //     final jsonData = json.decode(strData);*/
  //     imgUrl = "${baseURL}images/doctorPayQR/$patientIDP.png";
  //     debugPrint(imgUrl);
  //     setState(() {});
  //   } else {
  //     imgUrl = "";
  //     setState(() {});
  //   }
  // }

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
}
