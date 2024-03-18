import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swasthyasetu/app_screens/exercise_screen.dart';
import 'package:swasthyasetu/controllers/exercise_list_controller.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/podo/exercise_model.dart';

class ExerciseListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ExerciseListController exerciseListController =
        Get.put(ExerciseListController());
    SizeConfig().init(context);
    //ExerciseListController exerciseListController = ExerciseListController();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          title: Text(
            "Exercises",
            style: TextStyle(
              color: Colors.black,
              fontSize: SizeConfig.blockSizeHorizontal !* 5.5,
              fontStyle: FontStyle.italic,
              letterSpacing: 1.0,
            ),
          ),
        ),
        body: ColoredBox(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockSizeHorizontal !* 3.0,
                vertical: SizeConfig.blockSizeVertical !* 1.0),
            child: ListView(
              children: [
                Text(
                  "We all want to exercise. But we may be confused by the variety of available options out there. Images of exercises lack details. Videos of exercises are overwhelming. GIF animations are easier to follow. So we included them here for you. We have selected exercises that are suitable for most people, and require no equipments. And you can do your modifications.",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: SizeConfig.blockSizeHorizontal !* 3.8,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1.0,
                    wordSpacing: 1.2,
                    height: 1.6,
                  ),
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical !* 2.0,
                ),
                Container(
                  child: ListView.builder(
                      addRepaintBoundaries: false,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      /*gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: SizeConfig.blockSizeHorizontal * 2.0,
                      crossAxisSpacing: SizeConfig.blockSizeHorizontal * 2.0,
                    ),*/
                      itemCount: exerciseListController.listExercises.length,
                      itemBuilder: (context, index) {
                        ExerciseModel exercise =
                            exerciseListController.listExercises[index];
                        return Center(
                          child: MaterialButton(
                            onPressed: () {
                              Get.to(() => ExerciseScreen(exercise));
                            },
                            padding: EdgeInsets.all(0),
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.grey,
                                    )),
                                margin: EdgeInsets.symmetric(
                                  horizontal:
                                      SizeConfig.blockSizeHorizontal !* 2.0,
                                  vertical:
                                      SizeConfig.blockSizeHorizontal !* 2.0,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      SizeConfig.blockSizeHorizontal !* 3.0,
                                  vertical:
                                      SizeConfig.blockSizeHorizontal !* 3.0,
                                ),
                                child: Row(
                                  children: [
                                    Image(
                                      image: AssetImage(
                                          "images/ic_exercise_placeholder.png"),
                                      width:
                                          SizeConfig.blockSizeHorizontal !* 10,
                                      height:
                                          SizeConfig.blockSizeHorizontal !* 10,
                                      color: Colors.green,
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(
                                      width:
                                          SizeConfig.blockSizeHorizontal !* 5.0,
                                    ),
                                    Text(
                                      exercise.exerciseName!,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal !*
                                                4.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        );
                      }),
                )
              ],
            ),
          ),
        ));
  }
}
