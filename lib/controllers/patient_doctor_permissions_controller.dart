import 'package:get/get.dart';

class PatientDoctorPermissionsController extends GetxController {
  RxBool shareMyRecords = true.obs;
  RxBool shareMyConsultationHistory = true.obs;

  @override
  void onClose() {
    shareMyRecords.close();
    shareMyConsultationHistory.close();
    super.onClose();
  }

  PatientDoctorPermissionsController() {
    /*shareMyRecords.value = getBoolValueFromString(healthRecordsDisplayStatus);
    shareMyConsultationHistory.value =
        getBoolValueFromString(consultationDisplayStatus);*/
  }

  bool getBoolValueFromString(String val) {
    if (val == "1") return true;
    return false;
  }
}
