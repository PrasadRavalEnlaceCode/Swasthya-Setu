import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:swasthyasetu/controllers/exercise_controller.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/podo/exercise_model.dart';
import 'package:swasthyasetu/enums/exercise_states.dart';

class ExerciseScreen extends StatelessWidget {
  final ExerciseModel exerciseModel;
  final TextEditingController startEndSecondsController =
      TextEditingController();
  final TextEditingController repeatIntervalController =
      TextEditingController();

  ExerciseScreen(this.exerciseModel);

  @override
  Widget build(BuildContext context) {
    ExerciseController exerciseController = Get.put(ExerciseController());

    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          exerciseModel.exerciseName!,
          style: TextStyle(
            color: Colors.black,
            fontSize: SizeConfig.blockSizeHorizontal !* 5.5,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          InkWell(
              onTap: () {
                exerciseController.stopTimer();
                exerciseController.exerciseStates.value =
                    ExerciseStates.needUserInput;
              },
              child: Padding(
                padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 3.0),
                child: Image(
                  image: AssetImage("images/ic_reps.png"),
                  width: SizeConfig.blockSizeHorizontal !* 9.0,
                  height: SizeConfig.blockSizeHorizontal !* 9.0,
                ),
              )),
        ],
      ),
      body: ColoredBox(
        color: Colors.white,
        child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockSizeHorizontal !* 3.0,
                vertical: SizeConfig.blockSizeVertical !* 1.0),
            child: Obx(
              () => ListView(
                children: [
                  Text(
                    exerciseController.exerciseStates.value ==
                            ExerciseStates.needUserInput
                        ? "Choose Exercise Interval and Repeat Exercise"
                        : exerciseController.exerciseStates.value ==
                                ExerciseStates.userInput
                            ? "Do you want to Start Now?"
                            : "",
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: exerciseController.exerciseStates.value ==
                                  ExerciseStates.needUserInput ||
                              exerciseController.exerciseStates.value ==
                                  ExerciseStates.startCounter
                          ? SizeConfig.blockSizeHorizontal !* 4.0
                          : SizeConfig.blockSizeHorizontal !* 6.0,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1.0,
                      wordSpacing: 1.2,
                    ),
                  ),
                  AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      child: exerciseController.exerciseStates.value ==
                              ExerciseStates.needUserInput
                          ? needUserInputWidget(exerciseController)
                          : exerciseController.exerciseStates.value ==
                                  ExerciseStates.userInput
                              ? userInputWidget(exerciseController)
                              : startCounterWidget(exerciseController)),
                ],
              ),
            )),
      ),
    );
  }

  void validateAndSetTimer() {
    ExerciseController exerciseController = Get.find();
    if (startEndSecondsController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please type Start-End time",
        colorText: Colors.white,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    if (repeatIntervalController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please type Repeat Interval",
        colorText: Colors.white,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    exerciseController.exerciseStates.value = ExerciseStates.userInput;
    //exerciseController.startTimer();
  }

  void validateAndStarTimer(ExerciseController exerciseController) {
    /*if (startEndSecondsController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please type Start-End time",
        colorText: Colors.white,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    if (repeatIntervalController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please type Repeat Interval",
        colorText: Colors.white,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }*/
    exerciseController.startTimer();
  }

  needUserInputWidget(ExerciseController exerciseController) {
    return Column(
      children: [
        /*Row(
          children: [
            Expanded(
              child: TextField(
                controller: startEndSecondsController,
                onChanged: (text) {
                  exerciseController.startEndSeconds.value = text;
                },
                style: TextStyle(
                    color: Colors.green,
                    fontSize: SizeConfig.blockSizeVertical * 2.3),
                keyboardType: TextInputType.number,
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
            ),
            SizedBox(
              width: SizeConfig.blockSizeHorizontal * 5.0,
            ),
            Expanded(
              child: TextField(
                controller: repeatIntervalController,
                onChanged: (text) {
                  exerciseController.repeatInterval.value = text;
                },
                style: TextStyle(
                    color: Colors.green,
                    fontSize: SizeConfig.blockSizeVertical * 2.3),
                keyboardType: TextInputType.number,
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
            ),
          ],
        ),*/
        TextField(
          controller: startEndSecondsController,
          onChanged: (text) {
            exerciseController.startEndSeconds.value = text;
          },
          style: TextStyle(
              color: Colors.green,
              fontSize: SizeConfig.blockSizeVertical !* 2.3),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintStyle: TextStyle(
                color: Colors.black,
                fontSize: SizeConfig.blockSizeVertical !* 2.3),
            labelStyle: TextStyle(
                color: Colors.black,
                fontSize: SizeConfig.blockSizeVertical !* 2.3),
            labelText: "Exercise Interval (In seconds)",
            hintText: "",
          ),
        ),
        SizedBox(
          height: SizeConfig.blockSizeVertical !* 0.5,
        ),
        TextField(
          controller: repeatIntervalController,
          onChanged: (text) {
            exerciseController.repeatInterval.value = text;
          },
          style: TextStyle(
              color: Colors.green,
              fontSize: SizeConfig.blockSizeVertical !* 2.3),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintStyle: TextStyle(
                color: Colors.black,
                fontSize: SizeConfig.blockSizeVertical !* 2.3),
            labelStyle: TextStyle(
                color: Colors.black,
                fontSize: SizeConfig.blockSizeVertical !* 2.3),
            labelText: "Repeat Exercise",
            hintText: "",
          ),
        ),
        SizedBox(
          height: SizeConfig.blockSizeVertical !* 0.5,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "e.g. 2 times, 3 times,...",
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ),
        SizedBox(
          height: SizeConfig.blockSizeVertical !* 1.5,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: MaterialButton(
            onPressed: () {
              validateAndSetTimer();
            },
            color: Colors.green,
            child: Text(
              "SET",
              style: TextStyle(
                color: Colors.white,
                fontSize: SizeConfig.blockSizeHorizontal !* 4.5,
              ),
            ),
          ),
        )
      ],
    );
  }

  userInputWidget(ExerciseController exerciseController) {
    return Column(
      children: [
        SizedBox(
          height: SizeConfig.blockSizeVertical !* 1.5,
        ),
        Align(
            alignment: Alignment.center,
            child: MaterialButton(
              onPressed: () {
                exerciseController.playTimer();
              },
              color: Colors.green,
              //shape: CircleBorder(),
              child: Text(
                "START",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeConfig.blockSizeHorizontal !* 4.5,
                ),
              ),
            ))
      ],
    );
  }

  startCounterWidget(ExerciseController exerciseController) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            setsText(exerciseController),
            style: TextStyle(
              fontSize:
                  /*!exerciseController.counterStarted.value
                  ? SizeConfig.blockSizeHorizontal * 8.0
                  :*/
                  SizeConfig.blockSizeHorizontal !* 6.0,
              color: Colors.green,
            ),
          ),
        ),
        SizedBox(
          height: SizeConfig.blockSizeVertical !* 1.0,
        ),
        !exerciseController.counterStarted.value
            ? Container(
                height: SizeConfig.blockSizeVertical !* 4,
                child: Text(
                  !exerciseController.counterStarted.value
                      ? "Get Ready to move..."
                      : exerciseController.secondsRemaining.value,
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal !* 5.0,
                  ),
                ),
              )
            : Container(
                height: SizeConfig.blockSizeVertical !* 4,
              ),
        SizedBox(
          height: SizeConfig.blockSizeVertical !* 1.5,
        ),
        CircularPercentIndicator(
          radius: SizeConfig.blockSizeHorizontal !* 20.0,
          lineWidth: 8.0,
          percent: int.parse(exerciseController.secondsRemaining.value) /
              int.parse(exerciseController.startEndSeconds.value),
          backgroundColor: Colors.grey,
          center: new Text(
            exerciseController.secondsRemaining.value,
            style: TextStyle(
              fontSize: SizeConfig.blockSizeHorizontal !* 8.0,
            ),
          ),
          progressColor: Colors.green,
        ),
        SizedBox(
          height: SizeConfig.blockSizeVertical !* 1.5,
        ),
        Image(
          image: AssetImage("images/${exerciseModel.exerciseImage}"),
          height: SizeConfig.blockSizeVertical !* 40,
          fit: BoxFit.fitWidth,
        ),
        SizedBox(
          height: SizeConfig.blockSizeVertical !* 2.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /*Expanded(
              child: */
            exerciseController.playVisible.value
                ? Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockSizeHorizontal !* 5.0,
                    ),
                    child: FloatingActionButton(
                      onPressed: () {
                        exerciseController.playTimer();
                      },
                      backgroundColor: Colors.green,
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: SizeConfig.blockSizeHorizontal !* 12.0,
                      ),
                    ))
                : Container(),
            /*SizedBox(
              width: SizeConfig.blockSizeHorizontal * 5.0,
            ),*/
            /*),*/
            /*Expanded(
              child:*/
            /*exerciseController.pauseVisible.value
                ? Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockSizeHorizontal * 5.0,
                    ),
                    child: FloatingActionButton(
                      onPressed: () {
                        exerciseController.pauseTimer();
                      },
                      backgroundColor: mainColor,
                      child: Icon(
                        Icons.pause,
                        color: Colors.white,
                        size: SizeConfig.blockSizeHorizontal * 12.0,
                      ),
                    ))
                : Container(),*/
            exerciseController.stopVisible.value
                ? Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockSizeHorizontal !* 5.0,
                    ),
                    child: FloatingActionButton(
                      onPressed: () {
                        exerciseController.stopTimer();
                      },
                      backgroundColor: Colors.green,
                      child: Icon(
                        Icons.stop,
                        color: Colors.white,
                        size: SizeConfig.blockSizeHorizontal !* 12.0,
                      ),
                    ))
                : Container(),
            /* ),*/
            /*Expanded(
              child: FloatingActionButton(
                onPressed: () {},
                backgroundColor: mainColor,
                child: Text(
                  "Start",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeConfig.blockSizeHorizontal * 4.0,
                  ),
                ),
              ),
            ),*/
          ],
        ),
      ],
    );
  }

  String setsText(ExerciseController exerciseController) {
    int repeatInterval = int.parse(repeatIntervalController.text);
    if (!exerciseController.counterStarted.value) {
      if (exerciseController.reps.value == 0)
        return "Starting Set - 1";
      else if (exerciseController.reps.value == repeatInterval)
        return "Staring Set - ${exerciseController.reps + 1}";
      /*else
        return "Set - ${(exerciseController.reps.value + 1).toString()}";*/
    }
    if (exerciseController.reps.value == repeatInterval)
      return "All sets done.";
    else
      return "Set - ${(exerciseController.reps.value + 1).toString()}";
  }
}
