import 'package:get/get.dart';
import 'package:silvertouch/podo/exercise_model.dart';

class ExerciseListController extends GetxController {
  RxList<ExerciseModel> listExercises = (null as List<ExerciseModel>).obs;
  @override
  void onInit() {
    initializeExerciseList();
    super.onInit();
  }

  void initializeExerciseList() {
    listExercises = [
      ExerciseModel(
          exerciseName: "Wake up",
          exerciseImage: "img_exercises_1_wake_up.gif"),
      ExerciseModel(
          exerciseName: "Run", exerciseImage: "img_exercises_2_run.gif"),
      ExerciseModel(
          exerciseName: "Step", exerciseImage: "img_exercises_3_step.gif"),
      ExerciseModel(
          exerciseName: "Bend", exerciseImage: "img_exercises_4_bend.gif"),
      ExerciseModel(
          exerciseName: "Lunge twist",
          exerciseImage: "img_exercises_5_lunge_twist.gif"),
      ExerciseModel(
          exerciseName: "Squat 1",
          exerciseImage: "img_exercises_6_squat_1.gif"),
      ExerciseModel(
          exerciseName: "Squat 2",
          exerciseImage: "img_exercises_7_squat_2.gif"),
      ExerciseModel(
          exerciseName: "Jump 1", exerciseImage: "img_exercises_8_jump_1.gif"),
      ExerciseModel(
          exerciseName: "Jump 2", exerciseImage: "img_exercises_9_jump_2.gif"),
      ExerciseModel(
          exerciseName: "Crunch", exerciseImage: "img_exercises_10_crunch.gif"),
      ExerciseModel(
          exerciseName: "Flutter kick",
          exerciseImage: "img_exercises_11_flutter_kick.gif"),
      ExerciseModel(
          exerciseName: "Plank", exerciseImage: "img_exercises_12_plank.gif"),
      ExerciseModel(
          exerciseName: "Back stretch",
          exerciseImage: "img_exercises_13_back_stretch.gif"),
      ExerciseModel(
          exerciseName: "Superhuman",
          exerciseImage: "img_exercises_14_superhuman.gif"),
      ExerciseModel(
          exerciseName: "Mt climber",
          exerciseImage: "img_exercises_15_mt_climber.gif"),
      ExerciseModel(
          exerciseName: "Pushup 1",
          exerciseImage: "img_exercises_16_pushup_1.gif"),
      ExerciseModel(
          exerciseName: "Pushup 2",
          exerciseImage: "img_exercises_17_pushup_2.gif"),
      ExerciseModel(
          exerciseName: "Surya Namaskar",
          exerciseImage: "img_exercises_18_surya_namaskar.gif"),
    ].obs;
  }
}
