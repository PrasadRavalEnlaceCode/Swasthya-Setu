import 'package:get/get.dart';

class ConsultationVitalsController extends GetxController {
  RxBool isCheckedBPSystolic = false.obs,
      isCheckedBPDiastolic = false.obs,
      isCheckedSPO2 = false.obs,
      isCheckedPulse = false.obs,
      isCheckedTemperature = false.obs,
      isCheckedHeight = false.obs,
      isCheckedWeight = false.obs;

  reset() {
    isCheckedBPSystolic = false.obs;
    isCheckedBPDiastolic = false.obs;
    isCheckedSPO2 = false.obs;
    isCheckedPulse = false.obs;
    isCheckedTemperature = false.obs;
    isCheckedHeight = false.obs;
    isCheckedWeight = false.obs;
  }
}
