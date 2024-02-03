import 'package:get/get.dart';

class DoctorProfileImageTypeController extends GetxController {
  RxString imageType = "".obs;

  void setImageType(String imageType) {
    this.imageType.value = imageType;
  }
}
