import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silvertouch/api/api_helper.dart';

String baseURL = "https://www.swasthyasetu.com/ws_silvertouch/";
String baseImagePath = "https://www.swasthyasetu.com/ws/";
String userImgUrl = "${baseImagePath}images/patientphoto/";
String doctorImgUrl = "${baseImagePath}images/doctorphoto/";
String chatImgUrl = "${baseImagePath}images/chatimage/";
String doctorLogoUrl = "${baseImagePath}images/doctorlogo/";
String doctorSignatureUrl = "${baseImagePath}images/doctorsignature/";
String certificateUrl = "${baseImagePath}images/patientreport/";
ApiHelper apiHelper = ApiHelper();

setIsLoggedIn(bool isLoggedIn) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setBool("IsLoggedIn", isLoggedIn);
}

Future<bool> getIsLoggedIn() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getBool("IsLoggedIn")!;
}

/*setLoginDetails(LoginModel obj, String u, String p, String type) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString("UserIDP", obj.userIDP);
  sharedPreferences.setString("FirstName", obj.firstName);
  sharedPreferences.setString("MiddleName", obj.middleName);
  sharedPreferences.setString("LastName", obj.lastName);
  sharedPreferences.setString("MemberID", obj.memberID);
  sharedPreferences.setString("Mobile", obj.mobile);
  sharedPreferences.setString("AlternateMobile", obj.alternateMobile);
  sharedPreferences.setString("Email", obj.email);
  sharedPreferences.setString("AlternateEmail", obj.alternateEmail);
  sharedPreferences.setString("Photo", obj.photo);
  sharedPreferences.setString("Password", obj.password);
  sharedPreferences.setString("TimeStamp", obj.timeStamp);
  sharedPreferences.setString("user", u);
  sharedPreferences.setString("password", p);
  sharedPreferences.setString("type", type);
}*/

setIsTokenAvailable(bool isTokenAvailable) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setBool("isTokenAvailable", isTokenAvailable);
}

Future<bool> isTokenAvailable() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getBool("isTokenAvailable") ?? false;
}

Future<String> getToken() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getString("token") ?? "";
}

setToken(String token) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString("token", token);
}

Future<String> getUserDetails() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getString("userDetails") ?? "";
}

setUserDetails(String userDetails) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString("userDetails", userDetails);
}

setIconList(List<String> listIconName, List<String> listImage,
    List<String> listWebViewUrl) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setStringList("listIconName", listIconName);
  sharedPreferences.setStringList("listImage", listImage);
  sharedPreferences.setStringList("listWebViewUrl", listWebViewUrl);
}

setSliderPhotosList(
    List<String> listPhotos,
    List<String> listPhotosSliderWebView,
    List<String> listPhotosSliderWebViewTitle) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setStringList("listSliderImages", listPhotos);
  sharedPreferences.setStringList("listSliderImagesWebView", listPhotos);
  sharedPreferences.setStringList("listSliderImagesWebViewTitle", listPhotos);
}

setViewPagerImagesList(
    List<String> listViewPagerImages,
    List<String> listViewPagerWebViewUrl,
    List<String> listViewPagerWebViewTitle) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setStringList("listViewPagerImages", listViewPagerImages);
  sharedPreferences.setStringList(
      "listViewPagerWebViewUrl", listViewPagerWebViewUrl);
  sharedPreferences.setStringList(
      "listViewPagerWebViewTitle", listViewPagerWebViewTitle);
}

setProgressList(
    List<String> listProgressTitle, List<String> listProgressValue) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setStringList("listProgressTitle", listProgressTitle);
  sharedPreferences.setStringList("listProgressValue", listProgressValue);
}

/*Future<LoginModel> getLoginDetails() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //sharedPreferences.getString(key)
}*/

Future<List<String>> getListIconName() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getStringList("listIconName")!;
  //sharedPreferences.getString(key)
}

Future<List<String>> getListImage() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getStringList("listImage")!;
  //sharedPreferences.getString(key)
}

Future<List<String>> getSliderPhotos() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getStringList("listSliderImages")!;
  //sharedPreferences.getString(key)
}

Future<List<String>> getSliderPhotosWebView() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getStringList("listSliderImagesWebView")!;
  //sharedPreferences.getString(key)
}

Future<List<String>> getSliderPhotosWebViewTitle() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getStringList("listSliderImagesWebViewTitle")!;
  //sharedPreferences.getString(key)
}

Future<List<String>> getViewPagerImages() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getStringList("listViewPagerImages")!;
  //sharedPreferences.getString(key)
}

Future<List<String>> getViewPagerWebViewUrl() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getStringList("listViewPagerWebViewUrl")!;
  //sharedPreferences.getString(key)
}

Future<List<String>> getViewPagerWebViewTitle() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getStringList("listViewPagerWebViewTitle")!;
  //sharedPreferences.getString(key)
}

Future<List<String>> getListProgressTitle() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getStringList("listProgressTitle")!;
  //sharedPreferences.getString(key)
}

Future<List<String>> getListProgressValue() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getStringList("listProgressValue")!;
  //sharedPreferences.getString(key)
}

Future<List<String>> getListWebViewUrl() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getStringList("listWebViewUrl")!;
  //sharedPreferences.getString(key)
}

Future<String> getPassword() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getString("password")!;
}

Future<String> getType() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getString("type")!;
}

Future<String> getFullName() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String fullName = "";
  if (sharedPreferences.getString("FirstName") != null) {
    fullName = sharedPreferences.getString("FirstName")!;
  }

  if (sharedPreferences.getString("MiddleName") != null) {
    fullName = fullName + " " + sharedPreferences.getString("MiddleName")!;
  }

  if (sharedPreferences.getString("LastName") != null) {
    fullName = fullName + " " + sharedPreferences.getString("LastName")!;
  }
  return fullName.trim();
}

Future<String> getFirstName() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getString("FirstName")!.trim();
}

Future<String> getLastName() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getString("LastName")!.trim();
}

Future<String> getEmail() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  if (sharedPreferences.getString("Email") != null) {
    return sharedPreferences.getString("Email")!;
  } else {
    return "";
  }
}

setMobNo(String mobNo) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString("Mobile", mobNo);
}

setEmail(String email) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString("Email", email);
}

Future<String> getMobNo() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  if (sharedPreferences.getString("Mobile") != null) {
    return sharedPreferences.getString("Mobile")!;
  } else {
    return "";
  }
}

setEmergencyNumber(String emergencyNumber) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString("EmergencyNumber", emergencyNumber);
}

Future<String> getEmergencyNumber() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  if (sharedPreferences.getString("EmergencyNumber") != null) {
    return sharedPreferences.getString("EmergencyNumber")!;
  } else {
    return "";
  }
}

setUserType(String userType) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString("UserType", userType);
}

setReception(String userType) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString("Reception", userType ?? '');
}

Future<String> getUserType() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  if (sharedPreferences.getString("UserType") != null) {
    return sharedPreferences.getString("UserType")!;
  } else {
    return "";
  }
}

setPatientIDP(String patientIDP) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString("PatientIDP", patientIDP);
}

Future<String> getPatientOrDoctorIDP() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  if (sharedPreferences.getString("PatientIDP") != null) {
    return sharedPreferences.getString("PatientIDP")!;
  } else {
    return "";
  }
}

setPatientID(String patientID) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString("PatientID", patientID);
}

Future<String> getPatientID() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  if (sharedPreferences.getString("PatientID") != null) {
    return sharedPreferences.getString("PatientID")!;
  } else {
    return "";
  }
}

setPatientUniqueKey(String patientUniqueKey) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString("PatientUniqueKey", patientUniqueKey);
}

Future<String> getPatientUniqueKey() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  if (sharedPreferences.getString("PatientUniqueKey") != null) {
    return sharedPreferences.getString("PatientUniqueKey")!;
  } else {
    return "";
  }
}

setPopUpIDP(String popUpIDP) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString("PopUpIDP", popUpIDP);
}

Future<String> getPopUpIDP() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  if (sharedPreferences.getString("PopUpIDP") != null) {
    return sharedPreferences.getString("PopUpIDP")!;
  } else {
    return "";
  }
}

setUserName(String userName) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString("user", userName);
}

setFirstName(String userName) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString("FirstName", userName);
}

setLastName(String userName) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString("LastName", userName);
}

Future<String> getUserName() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getString("user")!;
}

setDoctorIDP(String doctorIDP) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString("doctorIDP", doctorIDP);
}

Future<String> getDoctorIDP() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getString("doctorIDP")!;
}

setCityIDF(String cityIDF) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString("cityIDF", cityIDF);
}

Future<String> getCityIDF() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getString("cityIDF")!;
}

setStateIDF(String stateIDF) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString("stateIDF", stateIDF);
}

Future<String> getStateIDF() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getString("stateIDF")!;
}

setCityName(String cityName) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString("cityName", cityName);
}

Future<String> getCityName() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getString("cityName")!;
}

String replaceNewLineBySlashN(String text) {
  /* converts   Hello     to     Hello\nWorld */
  //            World

  return text.replaceAll("\n", "\\r\\n");
}

Future<TimeOfDay> showTimeSelectionDialog(
    BuildContext context, TimeOfDay pickedTime) async {
  TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: pickedTime,
      builder: (BuildContext? context, Widget? child) {
        return MediaQuery(
            child: child!,
            data:
                MediaQuery.of(context!).copyWith(alwaysUse24HourFormat: false));
      });

  if (time != null) {
    return time;
  }
  return null!;
}

String getFormattedTimeInStrFromTimeOfDay(TimeOfDay time) {
  DateTime dateTime = DateTime(DateTime.now().year, DateTime.now().month,
      DateTime.now().day, time.hour, time.minute);
  var formatter = new DateFormat('h:mm a');
  return formatter.format(dateTime);
}

Future<File> chooseImageWithExIfRotate(
    ImagePicker picker, ImageSource imageSource) async {
  final ImagePicker picker = ImagePicker();
  // Pick an image.
  final XFile? image = await picker.pickImage(source: imageSource);
  File notRotatedFile = File(image!.path);
  File rotatedFile =
      await FlutterExifRotation.rotateImage(path: notRotatedFile.path);
  return rotatedFile;
}

DateTime dateTimeFromTimeOfDay(TimeOfDay time) {
  DateTime now = DateTime.now();
  DateTime dateTime =
      DateTime(now.year, now.month, now.day, time.hour, time.minute);
  return dateTime;
}

IconData getBackIconCorrespondingToPlatform() {
  if (Platform.isAndroid) return Icons.keyboard_backspace;
  return Icons.arrow_back_ios;
}
