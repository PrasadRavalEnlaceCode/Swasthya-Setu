import 'package:get/get.dart';
import 'package:silvertouch/enums/coupon_code_states.dart';

class ApplyCouponController extends GetxController {
  Rx<CouponCodeStates> couponCodeState = CouponCodeStates.notEnteredYet.obs;
  RxInt amount = 100.obs;
  RxInt gst = 18.obs;
  RxInt discountAmount = 0.obs;
  RxInt netAmount = 118.obs;

  void countNetAmount() {
    netAmount.value = amount.value + gst.value - discountAmount.value;
    couponCodeState.value = CouponCodeStates.valid;
    //gst.value = ((amountValue * 18) / 100).round();
    //netAmount.value = amountValue + gst.value;
  }

  void resetEverything() {
    couponCodeState = CouponCodeStates.notEnteredYet.obs;
    amount = 100.obs;
    gst = 18.obs;
    discountAmount = 0.obs;
    netAmount = 118.obs;
  }

  @override
  void dispose() {
    resetEverything();
    super.dispose();
  }
}
