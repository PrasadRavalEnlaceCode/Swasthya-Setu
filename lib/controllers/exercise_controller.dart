import 'package:get/get.dart';
import 'package:silvertouch/enums/exercise_states.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class ExerciseController extends GetxController {
  /*RxBool isCounterOn = false.obs;*/
  Rx<ExerciseStates> exerciseStates = ExerciseStates.needUserInput.obs;
  RxString startEndSeconds = "".obs;
  RxString repeatInterval = "".obs;
  StopWatchTimer? _stopWatchTimer;
  RxString secondsRemaining = "".obs;
  RxInt reps = 0.obs;
  RxBool counterStarted = false.obs;
  RxBool playVisible = false.obs;
  RxBool pauseVisible = true.obs;
  RxBool stopVisible = true.obs;

  @override
  void onInit() {
    super.onInit();
    reps.value = 0;
    /*Future.delayed(Duration(seconds: 1), () {
      showBottomSheetDialog();
    });*/
  }

  @override
  void onClose() {
    if (_stopWatchTimer != null) _stopWatchTimer!.dispose();
    super.onClose();
  }

  startTimer() {
    _stopWatchTimer = StopWatchTimer(
      onChange: (value) {},
      onChangeRawSecond: (value) => print('onChangeRawSecond $value'),
      onChangeRawMinute: (value) => print('onChangeRawMinute $value'),
    );
    _stopWatchTimer!.secondTime.listen((value) {
      secondsRemaining.value = value.toString();
      if (int.parse(startEndSeconds.value) == value - 1) {
        _stopWatchTimer!.dispose();
        reps++;
        if (reps < int.parse(repeatInterval.value)) {
          startTimer();
        } else {
          secondsRemaining.value = "0";
          stopTimer();
        }
      }
    });
    exerciseStates.value = ExerciseStates.startCounter;
    counterStarted.value = false;
    playVisible.value = false;
    pauseVisible.value = false;
    stopVisible.value = false;
    Future.delayed(Duration(seconds: 3), () {
      counterStarted.value = true;
      playVisible.value = false;
      pauseVisible.value = true;
      stopVisible.value = true;
      _stopWatchTimer!.onExecute.add(StopWatchExecute.start);
    });
  }

  pauseTimer() {
    playVisible.value = true;
    pauseVisible.value = false;
    stopVisible.value = true;
    _stopWatchTimer!.onExecute.add(StopWatchExecute.stop);
  }

  stopTimer() {
    reps.value = 0;
    playVisible.value = true;
    pauseVisible.value = false;
    stopVisible.value = false;
    if (_stopWatchTimer != null) {
      _stopWatchTimer!.onExecute.add(StopWatchExecute.reset);
      _stopWatchTimer = null;
    }
    exerciseStates.value = ExerciseStates.userInput;
  }

  playTimer() {
    playVisible.value = false;
    pauseVisible.value = true;
    stopVisible.value = true;
    if (_stopWatchTimer != null) {
      printInfo(info: "Continuing.....");
      _stopWatchTimer!.onExecute.add(StopWatchExecute.start);
    } else {
      printInfo(info: "Starting over.....");
      startTimer();
    }
  }

/*showBottomSheetDialog() {
    Get.bottomSheet(MyBottomSheet());
  }*/
}

/*class MyBottomSheet extends StatefulWidget {
  const MyBottomSheet({Key key}) : super(key: key);

  @override
  _MyBottomSheetState createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  final TextEditingController startEndSecondsController =
      TextEditingController();
  final TextEditingController repeatController = TextEditingController();
  final ExerciseController exerciseController = Get.find();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: startEndSecondsController,
            onChanged: (text) {
              exerciseController.startEndSeconds.value = text;
            },
            style: TextStyle(
                color: Colors.green,
                fontSize: SizeConfig.blockSizeVertical * 2.3),
            decoration: InputDecoration(
              hintStyle: TextStyle(
                  color: Colors.black,
                  fontSize: SizeConfig.blockSizeVertical * 2.3),
              labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: SizeConfig.blockSizeVertical * 2.3),
              labelText: "Start-End seconds",
              hintText: "",
            ),
          ),
          TextField(
            controller: repeatController,
            onChanged: (text) {
              exerciseController.repeatInterval.value = text;
            },
            style: TextStyle(
                color: Colors.green,
                fontSize: SizeConfig.blockSizeVertical * 2.3),
            decoration: InputDecoration(
              hintStyle: TextStyle(
                  color: Colors.black,
                  fontSize: SizeConfig.blockSizeVertical * 2.3),
              labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: SizeConfig.blockSizeVertical * 2.3),
              labelText: "Repeat Interval",
              hintText: "",
            ),
          ),
        ],
      ),
    );
  }
}*/
