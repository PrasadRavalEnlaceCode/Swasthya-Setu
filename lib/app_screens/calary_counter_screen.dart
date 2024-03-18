import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/model_calorie_gain.dart';
import 'package:swasthyasetu/podo/model_calorie_loss.dart';
import 'package:swasthyasetu/podo/model_graph_values.dart';
import 'package:swasthyasetu/podo/model_vitals_list.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/flutter_echarts_custom.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';
import 'package:swasthyasetu/utils/ultimate_slider.dart';
import 'package:swasthyasetu/widgets/date_range_picker_custom.dart'
    as DateRagePicker;

import '../utils/color.dart';

List<ModelCalorieGain> listModelCalorieGain = [];
List<ModelCalorieLoss> listModelCalorieLoss = [];
var bottomNavBarIndex = 0;
double totalCalorieGain = 0;
double totalCalorieLoss = 0;
double tempTotalCalorieLoss = 0;
double totalCalorie = 0;

bool fruitsVisible = false;
bool vegetablesVisible = false;
bool milkProductsVisible = false;
bool grainVisible = false;
bool dishesVisible = false;
bool fastFoodVisible = false;
bool drinksVisible = false;

double weightValue = 0;
double heightValue = 0;

List<ModelGraphValues> listVital = [];
List<String> listVitalOnlyString = [];
List<String> listVitalOnlyStringDate = [];

class CalaryCounterScreen extends StatefulWidget {
  String patientIDP;
  var fromDate = DateTime.now().subtract(Duration(days: 7));
  var toDate = DateTime.now();

  var fromDateString = "";
  var toDateString = "";

  CalaryCounterScreen(this.patientIDP);

  @override
  State<StatefulWidget> createState() {
    return CalaryCounterScreenState();
  }
}

class CalaryCounterScreenState extends State<CalaryCounterScreen> {
  String mainType = "today";
  Widget? emptyMessageWidget;
  GlobalKey<MyEChartState> keyForChart = GlobalKey();
  int apiCalledCount = 0;
  ProgressDialog? pr;

  @override
  void initState() {
    super.initState();
    keyForChart = GlobalKey();
    apiCalledCount = 0;
    var formatter = new DateFormat('dd-MM-yyyy');
    widget.fromDateString = formatter.format(widget.fromDate);
    widget.toDateString = formatter.format(widget.toDate);
    listModelCalorieGain = [];
    listModelCalorieLoss = [];
    bottomNavBarIndex = 0;
    totalCalorieGain = 0;
    totalCalorieLoss = 0;
    totalCalorie = 0;
    fruitsVisible = false;
    vegetablesVisible = false;
    milkProductsVisible = false;
    grainVisible = false;
    dishesVisible = false;
    fastFoodVisible = false;
    drinksVisible = false;
    weightValue = 0;
    heightValue = 0;
    listVital = [];
    listVitalOnlyString = [];
    listVitalOnlyStringDate = [];
    emptyMessageWidget = Container(
      padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 5),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage("images/ic_idea_new.png"),
              width: 100,
              height: 100,
            ),
            SizedBox(
              height: 30.0,
            ),
            Text(
              "Please Enter your today's Calories.",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
    Future.delayed(Duration.zero, () {
      getAllTheData();
    });

    // Add fruits
    listModelCalorieGain.add(
        ModelCalorieGain("Fruits", "Apple", "1 piece(182 g)", 95, 0, 0, true));
    listModelCalorieGain.add(ModelCalorieGain(
        "Fruits", "Banana", "1 piece(125 g)", 111, 0, 0, false));
    listModelCalorieGain.add(
        ModelCalorieGain("Fruits", "Cherries", "1 piece(8 g)", 4, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Fruits", "Custard Apple", "1 piece(135 g)", 136, 0, 0, false));
    listModelCalorieGain.add(
        ModelCalorieGain("Fruits", "Dates", "1 piece(7.1 g)", 20, 0, 0, false));
    listModelCalorieGain.add(
        ModelCalorieGain("Fruits", "Grapes", "1 cup(125 g)", 104, 0, 0, false));
    listModelCalorieGain.add(
        ModelCalorieGain("Fruits", "Guava", "1 piece(55 g)", 37, 0, 0, false));
    listModelCalorieGain.add(
        ModelCalorieGain("Fruits", "Kiwi", "1 piece(183 g)", 112, 0, 0, false));
    listModelCalorieGain.add(
        ModelCalorieGain("Fruits", "Lemon", "1 piece(58 g)", 17, 0, 0, false));
    listModelCalorieGain.add(
        ModelCalorieGain("Fruits", "Lychees", "1 piece(10 g)", 7, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Fruits", "Mango", "1 piece(336 g)", 202, 0, 0, false));
    listModelCalorieGain.add(
        ModelCalorieGain("Fruits", "Orange", "1 cup(131 g)", 62, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Fruits", "Papaya", "1 piece(500 g)", 215, 0, 0, false));
    listModelCalorieGain.add(
        ModelCalorieGain("Fruits", "Peach", "1 piece(150 g)", 59, 0, 0, false));
    listModelCalorieGain.add(
        ModelCalorieGain("Fruits", "Pear", "1 piece(178 g)", 101, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Fruits", "Pineapple", "1 plate(100 g)", 50, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Fruits", "Pomegranate", "1 piece(282 g)", 234, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Fruits", "Raspberries", "1 cup(123 g)", 64, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Fruits", "Strawberries", "1 cup(152 g)", 49, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Fruits", "Watermelon", "1 cup(286 g)", 86, 0, 0, false));

    //Add vegetables
    listModelCalorieGain.add(ModelCalorieGain(
        "Vegetables", "Beetroot", "1 piece(82 g)", 35, 0, 0, true));
    listModelCalorieGain.add(ModelCalorieGain(
        "Vegetables", "Cabbage", "1 cup(150 g)", 38, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Vegetables", "Capsicum", "1 piece(45 g)", 12, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Vegetables", "Cauliflower", "1 floweret(13 g)", 3, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Vegetables", "Corn", "1 cup(154 g)", 562, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Vegetables", "Cucumber", "1 piece(205 g)", 33, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Vegetables", "Garlic", "1 clove(3 g)", 4, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Vegetables", "Green Beans", "1 cup(110 g)", 34, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Vegetables", "Onion", "1 piece(85 g)", 34, 0, 0, false));
    listModelCalorieGain.add(
        ModelCalorieGain("Vegetables", "Peas", "1 cup(98 g)", 79, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Vegetables", "Potato", "1 piece(213 g)", 164, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Vegetables", "Pumpkin", "1/4 piece", 12.75, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Vegetables", "Spinach", "1 bunch(110 g)", 39, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Vegetables", "Sweet potato", "1 piece(130 g)", 112, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Vegetables", "Tomato", "1 piece(111 g)", 20, 0, 0, false));

    //Add Milk and Dairy Products
    listModelCalorieGain.add(ModelCalorieGain("Milk and Dairy Products",
        "Cow Milk", "1 cup(244 ml)", 148, 0, 0, true));
    listModelCalorieGain.add(ModelCalorieGain("Milk and Dairy Products",
        "Buffalo Milk", "1 cup(244 ml)", 237, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Milk and Dairy Products", "Yogurt", "1 cup(227 g)", 138, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Milk and Dairy Products", "Cheese", "1 slice(21 g)", 31, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain("Milk and Dairy Products",
        "Mozzarella Cheese", "1 slice(28 g)", 78, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain("Milk and Dairy Products",
        "Butter", "1 tbsp(14.2 g)", 102, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Milk and Dairy Products", "Ghee", "1 tbsp(15 g)", 120, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Milk and Dairy Products", "Paneer", "1 cup(122 g)", 262, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Milk and Dairy Products", "Cream", "1 tbsp(15 g)", 36, 0, 0, false));

    //Add Grains
    listModelCalorieGain.add(ModelCalorieGain(
        "Grains", "Chapatti", "1 medium(20 g)", 70, 0, 0, true));
    listModelCalorieGain.add(ModelCalorieGain(
        "Grains", "Parantha", "1 medium(30 g)", 121, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Grains", "Aloo Parantha", "1 medium(40 g)", 210, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Grains", "Bajra Rotlo", "1 medium(45 g)", 180, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Grains", "Wheat Bread", "1 slice(28 g)", 75, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Grains", "Brown Bread", "1 slice(28 g)", 72, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Grains", "Maida Bread", "1 slice(28 g)", 78, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Grains", "Cooked Plain rice", "1 bowl(70 g)", 272, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Grains", "Veg pulao", "1 bowl(80 g)", 322, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Grains", "Rajma Rice", "1 bowl(100 g)", 434, 0, 0, false));
    listModelCalorieGain.add(
        ModelCalorieGain("Grains", "Poha", "1 plate(50 g)", 180, 0, 0, false));

    //Add Dishes
    listModelCalorieGain.add(
        ModelCalorieGain("Dishes", "Idli", "1 piece(60 g)", 100, 0, 0, true));
    listModelCalorieGain.add(
        ModelCalorieGain("Dishes", "Medu Vada", "1 piece", 73, 0, 0, false));
    listModelCalorieGain.add(
        ModelCalorieGain("Dishes", "Plain Dosa", "1 piece", 120, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Dishes", "Plain Rava Dosa", "1 piece", 147, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Dishes", "Masala Dosa", "1 piece(120 g)", 250, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Dishes", "Sambhar", "1 bowl(250 ml)", 253, 0, 0, false));
    listModelCalorieGain
        .add(ModelCalorieGain("Dishes", "Upma", "1 plate", 192, 0, 0, false));
    listModelCalorieGain.add(
        ModelCalorieGain("Dishes", "Uttapam", "1 piece", 170, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Dishes", "Boiled Egg", "1 piece(60 g)", 78, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Dishes", "Fried Egg", "1 piece(55 g)", 90, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Dishes", "Dal Chawal", "1 bowl(207 g)", 293, 0, 0, false));

    //Add Fast food
    listModelCalorieGain.add(ModelCalorieGain(
        "Fast Food", "Pizza", "1 slice(108 g)", 277, 0, 0, true));
    listModelCalorieGain.add(ModelCalorieGain(
        "Fast Food", "Veg Burger", "1 piece", 354, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Fast Food", "Cheese Sandwich", "1 slice", 261, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Fast Food", "Grilled Cheese Sandwhich", "1 slice", 291, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Fast Food", "Peanut Butter Sandwich", "1 slice", 342, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Fast Food", "Veg Sandwich", "1 slice", 266, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Fast Food", "Aloo Mutter Sandwich", "1 slice", 250, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Fast Food", "Vada Pav", "1 serving", 197, 0, 0, false));
    listModelCalorieGain.add(
        ModelCalorieGain("Fast Food", "Dabeli", "1 serving", 199, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Fast Food", "Maska Bun", "1 slice(65 g)", 198, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Fast Food", "Maska Bun with Jam", "1 slice(90 g)", 280, 0, 0, false));
    listModelCalorieGain.add(
        ModelCalorieGain("Fast Food", "Maggie", "1 serving", 325, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Fast Food", "Chinese noodles", "1 bowl", 460, 0, 0, false));
    listModelCalorieGain.add(
        ModelCalorieGain("Fast Food", "Pani puri", "1 piece", 54, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Fast Food", "Bhel puri", "1 plate", 320, 0, 0, false));
    listModelCalorieGain.add(
        ModelCalorieGain("Fast Food", "Khaman", "1 piece", 81, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Fast Food", "Dhokla", "1 plate(80 g)", 128, 0, 0, false));
    listModelCalorieGain.add(
        ModelCalorieGain("Fast Food", "Samosa", "1 piece", 262, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Fast Food", "Pakora (Bhajiya)", "1 piece", 76, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Fast Food", "Gathiya", "1 plate(65 g)", 250, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Fast Food", "Jalebi", "1 piece(30 g)", 78, 0, 0, false));
    listModelCalorieGain.add(
        ModelCalorieGain("Fast Food", "Sev Usal", "1 bowl", 238, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Fast Food", "Veg Puff", "1 piece(60 g)", 170, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain("Fast Food", "Bhaji Pav",
        "1.5 cup bhaji with 2 pav", 390, 0, 0, false));

    //Add drinks
    listModelCalorieGain.add(
        ModelCalorieGain("Drinks", "Buttermilk", "1 glass", 80.5, 0, 0, true));
    listModelCalorieGain.add(
        ModelCalorieGain("Drinks", "Aam Ras", "1 glass", 273, 0, 0, false));
    listModelCalorieGain.add(
        ModelCalorieGain("Drinks", "Nimbu Pani", "1 glass", 113, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Drinks", "Rooh Afza Milk", "1 glass", 185, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Drinks", "Orange juice", "1 glass", 111, 0, 0, false));
    listModelCalorieGain.add(
        ModelCalorieGain("Drinks", "Sweet lassi", "1 glass", 185, 0, 0, false));
    listModelCalorieGain.add(
        ModelCalorieGain("Drinks", "Falooda", "1 glass", 108, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Drinks", "Falooda with ice cream", "1 glass", 437, 0, 0, false));
    listModelCalorieGain.add(
        ModelCalorieGain("Drinks", "Thandaai", "1 glass", 378, 0, 0, false));
    listModelCalorieGain.add(ModelCalorieGain(
        "Drinks", "Kokum sarbat", "1 glass", 297.5, 0, 0, false));
    listModelCalorieGain
        .add(ModelCalorieGain("Drinks", "Green tea", "1 cup", 2, 0, 0, false));
    listModelCalorieGain
        .add(ModelCalorieGain("Drinks", "Tea", "1 cup", 75, 0, 0, false));
    listModelCalorieGain
        .add(ModelCalorieGain("Drinks", "Coffee", "1 cup", 90, 0, 0, false));

    //Add calorie loss activities
    listModelCalorieLoss.add(ModelCalorieLoss(
        "Reading a Book / Magazine / Newspaper", 1.5, 0, 15, 0));
    listModelCalorieLoss
        .add(ModelCalorieLoss("Sitting on Computer", 1.33, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss("Standing", 1.33, 0, 15, 0));
    listModelCalorieLoss
        .add(ModelCalorieLoss("Study / Note Taking", 1.8, 0, 15, 0));
    listModelCalorieLoss
        .add(ModelCalorieLoss("Talking on phone / Using phone", 1.5, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss(
        "Walking at a slow pace (upto 3.5 km/h)", 2, 0, 15, 0));
    listModelCalorieLoss
        .add(ModelCalorieLoss("Playing Musical Instrument", 2, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss("Light gardening", 2, 0, 15, 0));
    listModelCalorieLoss
        .add(ModelCalorieLoss("Walking downstairs", 2.5, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss("Cooking", 2.5, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss("Shopping", 2.5, 0, 15, 0));
    listModelCalorieLoss
        .add(ModelCalorieLoss("Pushing stroller with child", 2.5, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss("Walking dog", 2.5, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss(
        "Walking at an average pace (3.5 to 4 km/h)", 2.75, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss("Slow dancing", 2.75, 0, 15, 0));
    listModelCalorieLoss.add(
        ModelCalorieLoss("Playing Golf (using power cart)", 2.75, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss("Bowling", 2.75, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss("Fishing", 2.75, 0, 15, 0));
    listModelCalorieLoss.add(
        ModelCalorieLoss("Driving heavy tractor, bus or truck", 3, 0, 15, 0));
    listModelCalorieLoss
        .add(ModelCalorieLoss("Washing car or windows", 3, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss("Mopping", 3, 0, 15, 0));
    listModelCalorieLoss
        .add(ModelCalorieLoss("Playing with children", 3, 0, 15, 0));
    listModelCalorieLoss
        .add(ModelCalorieLoss("Picking fruit or vegetables", 3, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss("Scrubbing Floors", 3, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss(
        "Walking at a brisk pace (4 to 5 km/h)", 3.5, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss("Weight lifting", 3.5, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss("Water aerobics", 3.5, 0, 15, 0));
    listModelCalorieLoss
        .add(ModelCalorieLoss("Golf (not carrying clubs)", 3.5, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss(
        "Walking at a very brisk pace (5 to 6.5 km/h)", 4, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss("Climbing stairs", 4, 0, 15, 0));
    listModelCalorieLoss
        .add(ModelCalorieLoss("Dancing (moderately fast)", 4, 0, 15, 0));
    listModelCalorieLoss
        .add(ModelCalorieLoss("Leisurely bicycling (<16 km/h)", 4, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss("Raking lawn", 4, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss(
        "Heavy yard work or gardening activities", 4, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss("Painting", 4, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss("Slow swimming", 4.5, 0, 15, 0));
    listModelCalorieLoss
        .add(ModelCalorieLoss("Golf (carrying clubs)", 4.5, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss("Digging", 5, 0, 15, 0));
    listModelCalorieLoss
        .add(ModelCalorieLoss("Slow jogging (at 6.5 km/h)", 6, 0, 15, 0));
    listModelCalorieLoss
        .add(ModelCalorieLoss("Ice or roller skating", 6, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss("Doubles tennis", 6, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss("Hiking", 7, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss("Basketball", 7, 0, 15, 0));
    listModelCalorieLoss
        .add(ModelCalorieLoss("Bicycling (at 25 km/h)", 8, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss("Singles tennis", 9, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss("Squash", 9, 0, 15, 0));
    listModelCalorieLoss.add(ModelCalorieLoss("Football", 9, 0, 15, 0));
    listModelCalorieLoss
        .add(ModelCalorieLoss("Running (at 9-10 km/h)", 10, 0, 15, 0));
    listModelCalorieLoss
        .add(ModelCalorieLoss("Running (at 12-13 km/h)", 13.5, 0, 15, 0));
    listModelCalorieLoss
        .add(ModelCalorieLoss("Running (at 16 km/h)", 16, 0, 15, 0));
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String> getPatientProfileDetails() async {
    final String urlFetchPatientProfileDetails =
        "${baseURL}patientProfileData.php";
    var doctorApiCalled = false;

    try {
      String patientUniqueKey = await getPatientUniqueKey();
      String userType = await getUserType();
      debugPrint("Key and type");
      debugPrint(patientUniqueKey);
      debugPrint(userType);
      String jsonStr = "{" +
          "\"" +
          "PatientIDP" +
          "\"" +
          ":" +
          "\"" +
          widget.patientIDP +
          "\"" +
          "}";

      debugPrint(jsonStr);

      String encodedJSONStr = encodeBase64(jsonStr);
      //listIcon = new List();
      var response = await apiHelper.callApiWithHeadersAndBody(
        url: urlFetchPatientProfileDetails,
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
      apiCalledCount++;
      if (apiCalledCount == 3) pr!.hide();
      if (model.status == "OK") {
        var data = jsonResponse['Data'];
        var strData = decodeBase64(data);
        debugPrint("Decoded Data Array : " + strData);
        final jsonData = json.decode(strData);
        heightValue = double.parse(jsonData[0]['Height']);
        weightValue = double.parse(jsonData[0]['Wieght']);
        debugPrint("weight is :");
        //debugPrint(weightValue)
        setState(() {});
      } else {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text(model.message!),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (exception) {}
    return 'success';
  }

  Future<String> getTodayCalories() async {
    final String urlFetchPatientProfileDetails =
        "${baseURL}PatientCaloriesDataSelect.php";
    var doctorApiCalled = false;

    try {
      String patientUniqueKey = await getPatientUniqueKey();
      String userType = await getUserType();
      debugPrint("Key and type");
      debugPrint(patientUniqueKey);
      debugPrint(userType);
      String jsonStr = "{" +
          "\"" +
          "PatientIDP" +
          "\"" +
          ":" +
          "\"" +
          widget.patientIDP +
          "\"" +
          "}";

      debugPrint(jsonStr);

      String encodedJSONStr = encodeBase64(jsonStr);
      //listIcon = new List();
      var response = await apiHelper.callApiWithHeadersAndBody(
        url: urlFetchPatientProfileDetails,
        //Uri.parse(loginUrl),
        headers: {
          "u": patientUniqueKey,
          "type": userType,
        },
        body: {"getjson": encodedJSONStr},
      );
      //var resBody = json.decode(response.body);
      debugPrint("calories today");
      debugPrint(response.body.toString());
      final jsonResponse = json.decode(response.body.toString());
      ResponseModel model = ResponseModel.fromJSON(jsonResponse);
      apiCalledCount++;
      if (apiCalledCount == 3) pr!.hide();
      if (model.status == "OK") {
        var data = jsonResponse['Data'];
        var strData = decodeBase64(data);
        debugPrint("Decoded Data Array today calories : " + strData);
        final jsonData = json.decode(strData);
        totalCalorieGain = double.parse(jsonData[0]['calorygained']);
        totalCalorieLoss = double.parse(jsonData[0]['caloryburned']);
        tempTotalCalorieLoss = double.parse(jsonData[0]['caloryburned']);
        totalCalorie = double.parse(jsonData[0]['totalcalories']);
        setState(() {});
      } else {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text(model.message!),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (exception) {
      debugPrint("Caught exception");
      debugPrint(exception.toString());
    }
    return 'success';
  }

  void submitCalorieDetails(BuildContext context) async {
    String loginUrl = "${baseURL}PatientCaloriesData.php";
    pr!.show();
    String patientIDP = await getPatientOrDoctorIDP();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr = "{" +
        "\"PatientIDP\":\"${widget.patientIDP}\"," +
        /*"PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.patientIDP +
        "\"," +*/
        "\"calorygained\":\"$totalCalorieGain\"," +
        "\"caloryburned\":\"$totalCalorieLoss\"," +
        "\"totalcalories\":\"$totalCalorie\"" +
        "}";

    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);
    var response = await apiHelper.callApiWithHeadersAndBody(
      url: loginUrl,
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
    if (model.status == "OK") {
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      getAllTheData();
      /*Future.delayed(Duration(milliseconds: 300), () {
        Navigator.of(context).pop();
      });*/
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        /*key: navigatorKey,*/
        appBar: AppBar(
          title: Text("Calorie Counter"),
          backgroundColor: Color(0xFFFFFFFF),
          iconTheme: IconThemeData(color: Colorsblack),
          actions: [
            AnimatedSwitcher(
              duration: Duration(milliseconds: 1500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: mainType == "today"
                  ? InkWell(
                      onTap: () {
                        setState(() {
                          mainType = "chart";
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Image(
                          image: AssetImage("images/graph.png"),
                          width: 23,
                          height: 23,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: () {
                        setState(() {
                          mainType = "today";
                        });
                      },
                      child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Image(
                                image: AssetImage(
                                  "images/ic_calories.png",
                                ),
                                width: SizeConfig.blockSizeHorizontal !* 6.0,
                                height: SizeConfig.blockSizeHorizontal !* 6.0,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: SizeConfig.blockSizeHorizontal !* 2.0,
                              ),
                              Text(
                                "Today",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal !* 4.0,
                                ),
                              ),
                            ],
                          )),
                    ),
            )
          ], toolbarTextStyle: TextTheme(
              titleMedium: TextStyle(
            color: Colorsblack,
            fontFamily: "Ubuntu",
            fontSize: SizeConfig.blockSizeVertical !* 2.5,
          )).bodyMedium, titleTextStyle: TextTheme(
              titleMedium: TextStyle(
            color: Colorsblack,
            fontFamily: "Ubuntu",
            fontSize: SizeConfig.blockSizeVertical !* 2.5,
          )).titleLarge,
        ),
        body: Builder(
          builder: (context) {
            return mainType == "today"
                ? Column(
                    children: <Widget>[
                      /*BottomNavigationBarItem(
                      activeIcon: Padding(
                        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 5),
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(
                                    SizeConfig.blockSizeHorizontal * 5)),
                            child: Padding(
                              padding:
                              EdgeInsets.all(SizeConfig.blockSizeHorizontal * 3),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image(
                                    image: AssetImage(
                                      "images/ic_up.png",
                                    ),
                                    color: Colors.white,
                                    width: SizeConfig.blockSizeHorizontal * 3.5,
                                  ),
                                  SizedBox(
                                    width: SizeConfig.blockSizeHorizontal * 2,
                                  ),
                                  Text(
                                    "Calories Gained",
                                    style: TextStyle(
                                        fontSize:
                                        SizeConfig.blockSizeHorizontal * 3.0,
                                        color: Colors.white),
                                  )
                                ],
                              ),
                            )),
                      ),
                      icon: Padding(
                          padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 5),
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(width: 1.0, color: Colors.grey),
                                  borderRadius: BorderRadius.circular(
                                      SizeConfig.blockSizeHorizontal * 5)),
                              child: Padding(
                                padding: EdgeInsets.all(
                                    SizeConfig.blockSizeHorizontal * 3),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image(
                                      image: AssetImage(
                                        "images/ic_up.png",
                                      ),
                                      width: SizeConfig.blockSizeHorizontal * 3.5,
                                    ),
                                    SizedBox(
                                      width: SizeConfig.blockSizeHorizontal * 2,
                                    ),
                                    Text(
                                      "Calories Gained",
                                      style: TextStyle(
                                          fontSize:
                                          SizeConfig.blockSizeHorizontal * 3.0,
                                          color: Colors.black),
                                    )
                                  ],
                                ),
                              ))),
                      title: SizedBox.shrink()),
                  BottomNavigationBarItem(
                      activeIcon: Padding(
                        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 5),
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(
                                    SizeConfig.blockSizeHorizontal * 5)),
                            child: Padding(
                              padding:
                              EdgeInsets.all(SizeConfig.blockSizeHorizontal * 3),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image(
                                    image: AssetImage(
                                      "images/ic_down.png",
                                    ),
                                    color: Colors.white,
                                    width: SizeConfig.blockSizeHorizontal * 3.5,
                                  ),
                                  SizedBox(
                                    width: SizeConfig.blockSizeHorizontal * 2,
                                  ),
                                  Text(
                                    "Calories Burned",
                                    style: TextStyle(
                                        fontSize:
                                        SizeConfig.blockSizeHorizontal * 3.0,
                                        color: Colors.white),
                                  )
                                ],
                              ),
                            )),
                      ),
                      icon: Padding(
                          padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 5),
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(width: 1.0, color: Colors.grey),
                                  borderRadius: BorderRadius.circular(
                                      SizeConfig.blockSizeHorizontal * 5)),
                              child: Padding(
                                padding: EdgeInsets.all(
                                    SizeConfig.blockSizeHorizontal * 3),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image(
                                      image: AssetImage(
                                        "images/ic_down.png",
                                      ),
                                      width: SizeConfig.blockSizeHorizontal * 3.5,
                                    ),
                                    SizedBox(
                                      width: SizeConfig.blockSizeHorizontal * 2,
                                    ),
                                    Text(
                                      "Calories Burned",
                                      style: TextStyle(
                                          fontSize:
                                          SizeConfig.blockSizeHorizontal * 3.0,
                                          color: Colors.black),
                                    )
                                  ],
                                ),
                              ))),
                      title: SizedBox.shrink()),*/
                      Expanded(
                          child: Column(
                        children: [
                          SizedBox(
                            height: SizeConfig.blockSizeVertical !* 2.5,
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                left: SizeConfig.blockSizeHorizontal !* 3,
                                right: SizeConfig.blockSizeHorizontal !* 3,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "Today",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal !* 8,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  totalCalorie >= 0 &&
                                          (totalCalorieGain != 0 ||
                                              totalCalorieLoss != 0)
                                      ? Expanded(
                                          child: Align(
                                            alignment: Alignment.topRight,
                                            child: InkWell(
                                              onTap: () {
                                                submitCalorieDetails(context);
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50.0),
                                                  border: Border.all(
                                                    width: 1.0,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: SizeConfig
                                                              .blockSizeHorizontal !*
                                                          1,
                                                      horizontal: SizeConfig
                                                              .blockSizeHorizontal !*
                                                          3.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.check,
                                                        color:
                                                            Colors.green[800],
                                                        size: SizeConfig
                                                                .blockSizeHorizontal !*
                                                            6,
                                                      ),
                                                      SizedBox(
                                                        width: SizeConfig
                                                                .blockSizeHorizontal !*
                                                            1,
                                                      ),
                                                      Text(
                                                        "Save",
                                                        style: TextStyle(
                                                          color:
                                                              Colors.green[800],
                                                          fontSize: SizeConfig
                                                                  .blockSizeHorizontal !*
                                                              4.0,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container()
                                ],
                              )),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical !* 2.5,
                          ),
                          Text(
                            "Normal Daily Calorie Range is 1800 - 2600 cal",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: SizeConfig.blockSizeHorizontal !* 3,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              SizedBox(
                                width: SizeConfig.blockSizeHorizontal !* 3,
                              ),
                              Expanded(
                                child: Text(
                                  "${totalCalorie.toStringAsFixed(2)} cal",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal !* 8,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              /*Align(
                                alignment: Alignment.centerRight,
                                child:*/
                              Image(
                                image: AssetImage(
                                  totalCalorie >= 1800 && totalCalorie <= 2600
                                      ? "images/ic_happy.png"
                                      : "images/ic_sad.png",
                                ),
                                width: SizeConfig.blockSizeHorizontal !* 10,
                                height: SizeConfig.blockSizeHorizontal !* 10,
                              ),
                              /*),*/
                              SizedBox(
                                width: SizeConfig.blockSizeHorizontal !* 3,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical !* 1,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image(
                                      image: AssetImage("images/ic_up.png"),
                                      width:
                                          SizeConfig.blockSizeHorizontal !* 3.5,
                                      color: Colors.green,
                                    ),
                                    SizedBox(
                                      width: SizeConfig.blockSizeHorizontal !* 2,
                                    ),
                                    Text(
                                      "${totalCalorieGain.toStringAsFixed(2)} cal",
                                      style: TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal !*
                                                5.0,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image(
                                      image: AssetImage("images/ic_down.png"),
                                      width:
                                          SizeConfig.blockSizeHorizontal !* 3.5,
                                      color: Colors.red,
                                    ),
                                    SizedBox(
                                      width: SizeConfig.blockSizeHorizontal !* 2,
                                    ),
                                    Text(
                                      "${totalCalorieLoss.toStringAsFixed(2)} cal",
                                      style: TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal !*
                                                5.0,
                                        color: Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical !* 1,
                          ),
                          Divider(
                            color: Colors.blueGrey,
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical !* 0.5,
                          ),
                          Visibility(
                              visible: bottomNavBarIndex == 0,
                              child: Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left:
                                            SizeConfig.blockSizeHorizontal !* 3),
                                    child: Text(
                                      "Add Items you ate today",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        decorationThickness: 2.5,
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal !*
                                                4.5,
                                        color: Colors.teal,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ))),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical !* 1,
                          ),
                          Visibility(
                            visible: bottomNavBarIndex == 0,
                            child: Expanded(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  itemCount: listModelCalorieGain.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: <Widget>[
                                        Align(
                                            alignment: Alignment.topLeft,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: SizeConfig
                                                          .blockSizeHorizontal !*
                                                      2,
                                                  right: SizeConfig
                                                          .blockSizeHorizontal !*
                                                      2),
                                              child: Visibility(
                                                  visible: listModelCalorieGain[
                                                          index]
                                                      .showCategory,
                                                  child: InkWell(
                                                    onTap: () {
                                                      changeThisCategoryVisibility(
                                                          listModelCalorieGain[
                                                                  index]
                                                              .category);
                                                    },
                                                    child: Container(
                                                        margin:
                                                            EdgeInsets.all(5.0),
                                                        padding:
                                                            EdgeInsets.all(3.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                            width: 0.5,
                                                            color: Colors.green,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5.0)),
                                                        ),
                                                        child: Row(
                                                          children: <Widget>[
                                                            Icon(
                                                              isThisCategoryVisible(
                                                                      listModelCalorieGain[
                                                                              index]
                                                                          .category)
                                                                  ? Icons
                                                                      .arrow_drop_down
                                                                  : Icons
                                                                      .arrow_right,
                                                              size: SizeConfig
                                                                      .blockSizeHorizontal !*
                                                                  8,
                                                            ),
                                                            Text(
                                                              listModelCalorieGain[
                                                                      index]
                                                                  .category,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                fontSize: SizeConfig
                                                                        .blockSizeHorizontal !*
                                                                    5.3,
                                                                color:
                                                                    Colors.teal,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                                /*fontWeight:
                                                        FontWeight.w500*/
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                                  )),
                                            )),
                                        Visibility(
                                          visible: isThisCategoryVisible(
                                              listModelCalorieGain[index]
                                                  .category),
                                          child: SizedBox(
                                            height:
                                                SizeConfig.blockSizeVertical !*
                                                    1,
                                          ),
                                        ),
                                        Visibility(
                                            visible: isThisCategoryVisible(
                                                listModelCalorieGain[index]
                                                    .category),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Expanded(
                                                  child: Column(
                                                    children: <Widget>[
                                                      Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Padding(
                                                            padding: EdgeInsets.only(
                                                                left: SizeConfig
                                                                        .blockSizeHorizontal !*
                                                                    5),
                                                            child: Text(
                                                              listModelCalorieGain[
                                                                      index]
                                                                  .foodName,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                fontSize: SizeConfig
                                                                        .blockSizeHorizontal !*
                                                                    4.0,
                                                              ),
                                                            ),
                                                          )),
                                                      Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Padding(
                                                            padding: EdgeInsets.only(
                                                                left: SizeConfig
                                                                        .blockSizeHorizontal !*
                                                                    5),
                                                            child: Text(
                                                              listModelCalorieGain[
                                                                      index]
                                                                  .foodDesc,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      SizeConfig
                                                                              .blockSizeHorizontal !*
                                                                          3.0,
                                                                  color: Colors
                                                                      .grey),
                                                            ),
                                                          )),
                                                      Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Padding(
                                                            padding: EdgeInsets.only(
                                                                left: SizeConfig
                                                                        .blockSizeHorizontal !*
                                                                    5),
                                                            child: Text(
                                                              "${listModelCalorieGain[index].foodCalorie.toString()} cal",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      SizeConfig
                                                                              .blockSizeHorizontal !*
                                                                          3.0,
                                                                  color: Colors
                                                                      .grey),
                                                            ),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child:
                                                      NumberInputWithIncrementDecrement(
                                                          index,
                                                          0,
                                                          20,
                                                          callbackFromMain),
                                                ),
                                              ],
                                            )),
                                      ],
                                    );
                                  }),
                            ),
                          ),
                          /*Visibility(
                              visible: bottomNavBarIndex == 1,
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left:
                                            SizeConfig.blockSizeHorizontal * 3),
                                    child: Text(
                                      "Your Weight",
                                      textAlign: TextAlign.left,
                                    ),
                                  ))),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical * 1,
                          ),*/
                          Visibility(
                            visible: bottomNavBarIndex == 1,
                            child: SliderWidget(
                              min: 0,
                              max: 120,
                              value: weightValue.toDouble(),
                              title: "Weight",
                              unit: "kg",
                              callbackFromMain: callbackFromMainForLoss,
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical !* 0.5,
                          ),
                          Visibility(
                              visible: bottomNavBarIndex == 1,
                              child: Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left:
                                            SizeConfig.blockSizeHorizontal !* 3),
                                    child: Text(
                                      "Add Activities you did today",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal !*
                                                4.5,
                                        color: Colors.teal,
                                        decorationThickness: 2.5,
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ))),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical !* 0.5,
                          ),
                          Visibility(
                            visible: bottomNavBarIndex == 1,
                            child: Expanded(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  itemCount: listModelCalorieLoss.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: <Widget>[
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Expanded(
                                              child: Column(
                                                children: <Widget>[
                                                  Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Padding(
                                                        padding: EdgeInsets.only(
                                                            left: SizeConfig
                                                                    .blockSizeHorizontal !*
                                                                5),
                                                        child: Text(
                                                          listModelCalorieLoss[
                                                                  index]
                                                              .activityName,
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            fontSize: SizeConfig
                                                                    .blockSizeHorizontal !*
                                                                4.0,
                                                          ),
                                                        ),
                                                      )),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child:
                                                  NumberInputWithIncrementDecrementForCalorieLoss(
                                                      index,
                                                      0,
                                                      180,
                                                      listModelCalorieLoss[
                                                              index]
                                                          .interval,
                                                      callbackFromMainForLoss),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  }),
                            ),
                          ),
                        ],
                      )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    SizeConfig.blockSizeHorizontal !* 1.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  bottomNavBarIndex = 0;
                                });
                              },
                              child: Chip(
                                backgroundColor: bottomNavBarIndex == 0
                                    ? Colors.green[800]
                                    : Colors.grey,
                                label: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image(
                                      image: AssetImage(
                                        "images/ic_up.png",
                                      ),
                                      color: bottomNavBarIndex == 0
                                          ? Colors.white
                                          : Colors.white,
                                      width:
                                          SizeConfig.blockSizeHorizontal !* 3.5,
                                    ),
                                    SizedBox(
                                      width: SizeConfig.blockSizeHorizontal !* 2,
                                    ),
                                    Text(
                                      "Calories Gained",
                                      style: TextStyle(
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal !*
                                                  3.8,
                                          color: bottomNavBarIndex == 0
                                              ? Colors.white
                                              : Colors.white),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    SizeConfig.blockSizeHorizontal !* 1.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  bottomNavBarIndex = 1;
                                });
                              },
                              child: Chip(
                                backgroundColor: bottomNavBarIndex == 1
                                    ? Colors.green[800]
                                    : Colors.grey,
                                label: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image(
                                      image: AssetImage(
                                        "images/ic_down.png",
                                      ),
                                      color: bottomNavBarIndex == 1
                                          ? Colors.white
                                          : Colors.white,
                                      width:
                                          SizeConfig.blockSizeHorizontal !* 3.5,
                                    ),
                                    SizedBox(
                                      width: SizeConfig.blockSizeHorizontal !* 2,
                                    ),
                                    Text(
                                      "Calories Burned",
                                      style: TextStyle(
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal !*
                                                  3.8,
                                          color: bottomNavBarIndex == 1
                                              ? Colors.white
                                              : Colors.white),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  )
                : mainType == "chart"
                    ? Column(
                        children: <Widget>[
                          SizedBox(
                            height: SizeConfig.blockSizeVertical !* 1,
                          ),
                          Container(
                            height: SizeConfig.blockSizeVertical !* 8,
                            child: Padding(
                              padding: EdgeInsets.only(left: 5.0, right: 5.0),
                              child: Container(
                                child: InkWell(
                                    onTap: () {
                                      showDateRangePickerDialog();
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            "${widget.fromDateString}  to  ${widget.toDateString}",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: SizeConfig
                                                        .blockSizeVertical !*
                                                    2.6,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black),
                                          ),
                                        ),
                                        Container(
                                          width:
                                              SizeConfig.blockSizeHorizontal !*
                                                  15,
                                          child: Icon(
                                            Icons.arrow_drop_down,
                                            size:
                                                SizeConfig.blockSizeHorizontal !*
                                                    8,
                                          ),
                                        ),
                                      ],
                                    )),
                                padding: EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical !* 1,
                          ),
                          listVitalOnlyString.length == 0
                              ? Align(
                                  alignment: Alignment.center,
                                  child: emptyMessageWidget,
                                )
                              : MyEChart(
                                  key: keyForChart,
                                  chartTypeID: "1",
                                  titleOfChart: "Calories"),
                        ],
                      )
                    : Container();
          },
        ));
  }

  Future<void> showDateRangePickerDialog() async {
    // final List<DateTime>? listPicked = await DateRagePicker.showDatePicker(
    //     context: context,
    //     initialFirstDate: widget.fromDate,
    //     initialLastDate: widget.toDate,
    //     firstDate: DateTime.now().subtract(Duration(days: 365 * 100)),
    //     lastDate: DateTime.now(),
    //     handleOk: () {},
    //     handleCancel: () {});
    // if (listPicked != null && listPicked.length == 2) {
    //   widget.fromDate = listPicked[0];
    //   widget.toDate = listPicked[1];
    //   var formatter = new DateFormat('dd-MM-yyyy');
    //   widget.fromDateString = formatter.format(widget.fromDate);
    //   widget.toDateString = formatter.format(widget.toDate);
    //   getVitalsListWithVitalIDP("500", 0);
    // }
  }

  Future<String?> getVitalsListWithVitalIDP(
      String vitalIDP, int vitalSerialNo) async {
    pr!.show();
    String loginUrl = "${baseURL}patientVitalsData.php";
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr = "{" +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.patientIDP +
        "\"" +
        "," +
        "\"" +
        "FromDate" +
        "\"" +
        ":" +
        "\"" +
        widget.fromDateString +
        "\"" +
        "," +
        "\"" +
        "ToDate" +
        "\"" +
        ":" +
        "\"" +
        widget.toDateString +
        "\"" +
        "," +
        "\"" +
        "VitalIDP" +
        "\"" +
        ":" +
        "\"" +
        vitalIDP +
        "\"" +
        "}";

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
    debugPrint("Actual 1");
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);

    //vitalsAPICount++;

    listVital = [];
    listVitalOnlyString = [];
    listVitalOnlyStringDate = [];

    /*switch (vitalSerialNo) {
      case 1:
        listVital = [];
        listVitalOnlyString = [];
        listVitalOnlyStringDate = [];
        break;
      case 2:
        widget.listVitals = [];
        listVital2 = [];
        listVitalOnlyString2 = [];
        listVitalOnlyStringDate2 = [];
        break;
      case 3:
        widget.listVitals = [];
        listVital3 = [];
        listVitalOnlyString3 = [];
        listVitalOnlyStringDate3 = [];
        break;
      case 4:
        widget.listVitals = [];
        listVital4 = [];
        listVitalOnlyString4 = [];
        listVitalOnlyStringDate4 = [];
        break;
      case 5:
        widget.listVitals = [];
        listVital5 = [];
        listVitalOnlyString5 = [];
        listVitalOnlyStringDate5 = [];
        break;
      default:
    }*/

    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        var model = ModelVitalsList(
          widget.patientIDP,
          "",
          jo['totalcalories'],
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          jo['EntryDate'],
          "",
          "",
        );
        listVitalOnlyString.add(jo['totalcalories']);
        var date = model.vitalEntryDate;
        var time = model.vitalEntryTime;
        String year = date.split("-")[2];
        String month = date.split("-")[1];
        String day = date.split("-")[0];
        /*String hour = time.split(":")[0];
        String min = time.split(":")[1];*/
        var current =
            DateTime(int.parse(year), int.parse(month), int.parse(day));
        var formatter = new DateFormat('dd MMM');
        listVitalOnlyStringDate.add("${formatter.format(current)}");
      }
      apiCalledCount++;
      if (apiCalledCount == 3) pr!.hide();
      setState(() {
        setStateOfTheEChartWidget();
      });
    }
    return null;
  }

  void setStateOfTheEChartWidget() {
    if (keyForChart == null)
      debugPrint("key null");
    else if (keyForChart.currentState == null)
      debugPrint("currentState null");
    else {
      debugPrint(
          "nothing null, setting state of chart  - chart 1 idp - x, title - Investigation");
      keyForChart.currentState!.setStateInsideTheChart();
    }
  }

  void callbackFromMain() {
    //for (int i = 0; i < listModelCalorieGain.length; i++) {}
    setState(() {
      totalCalorie = totalCalorieGain - totalCalorieLoss;
    });
  }

  void callbackFromMainForLoss() {
    double tempLoss = 0;
    for (int i = 0; i < listModelCalorieLoss.length; i++) {
      tempLoss = tempLoss +
          (listModelCalorieLoss[i].metValue * weightValue / 60) *
              listModelCalorieLoss[i].time;
    }
    totalCalorieLoss = tempTotalCalorieLoss + tempLoss;
    setState(() {
      totalCalorie = totalCalorieGain - totalCalorieLoss;
    });
  }

  Future<void> onTabTapped(int index, BuildContext context) async {
    setState(() {
      bottomNavBarIndex = index;
    });
  }

  bool isThisCategoryVisible(String category) {
    if (category.toLowerCase() == "fruits")
      return fruitsVisible;
    else if (category.toLowerCase() == "vegetables")
      return vegetablesVisible;
    else if (category.toLowerCase() == "milk and dairy products")
      return milkProductsVisible;
    else if (category.toLowerCase() == "grains")
      return grainVisible;
    else if (category.toLowerCase() == "dishes")
      return dishesVisible;
    else if (category.toLowerCase() == "fast food")
      return fastFoodVisible;
    else if (category.toLowerCase() == "drinks") return drinksVisible;
    return false;
  }

  changeThisCategoryVisibility(String category) {
    if (category.toLowerCase() == "fruits")
      setState(() {
        fruitsVisible = !fruitsVisible;
      });
    else if (category.toLowerCase() == "vegetables")
      setState(() {
        vegetablesVisible = !vegetablesVisible;
      });
    else if (category.toLowerCase() == "milk and dairy products")
      setState(() {
        milkProductsVisible = !milkProductsVisible;
      });
    else if (category.toLowerCase() == "grains")
      setState(() {
        grainVisible = !grainVisible;
      });
    else if (category.toLowerCase() == "dishes")
      setState(() {
        dishesVisible = !dishesVisible;
      });
    else if (category.toLowerCase() == "fast food")
      setState(() {
        fastFoodVisible = !fastFoodVisible;
      });
    else if (category.toLowerCase() == "drinks")
      setState(() {
        drinksVisible = !drinksVisible;
      });
  }

  void getAllTheData() {
    apiCalledCount = 0;
    pr = ProgressDialog(context);
    pr!.show();
    getPatientProfileDetails();
    getTodayCalories();
    getVitalsListWithVitalIDP("500", 0);
  }
}

/*class SliderWidget extends StatefulWidget {
  final double sliderHeight;
  int min;

  int max;
  String title = "";
  double value;
  final fullWidth;
  String unit;
  Function callbackFromMain;
  int index;

  SliderWidget(
      {this.sliderHeight = 50,
      this.max = 1000,
      this.min = 0,
      this.value,
      this.title = "",
      this.fullWidth = true,
      this.unit = "",
      this.callbackFromMain,
      this.index});

  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  double _value = 0;

  @override
  void initState() {
    //_value = widget.value / (widget.max - widget.min);
    _value = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double paddingFactor = .2;

    if (this.widget.fullWidth) paddingFactor = .3;

    return Container(
      padding: widget.title == "Systolic" || widget.title == "Diastolic"
          ? EdgeInsets.only(
              left: SizeConfig.blockSizeHorizontal * 8,
              right: SizeConfig.blockSizeHorizontal * 3,
            )
          : EdgeInsets.only(
              left: SizeConfig.blockSizeHorizontal * 3,
              right: SizeConfig.blockSizeHorizontal * 3,
            ),
      width: this.widget.fullWidth
          ? double.infinity
          : (this.widget.sliderHeight) * 5.5,
      height: SizeConfig.blockSizeVertical * 12,
      decoration: new BoxDecoration(
        borderRadius: new BorderRadius.all(
          Radius.circular((this.widget.sliderHeight * .3)),
        ),
      ),
      child: Padding(
          padding: EdgeInsets.fromLTRB(this.widget.sliderHeight * paddingFactor,
              1, this.widget.sliderHeight * paddingFactor, 1),
          child: Column(
            children: <Widget>[
              Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: <Widget>[
                      */ /*Text(
                        '${this.widget.title} - ',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),*/ /*
                      Text(
                        ' ${widget.value.round()} ',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 4,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        ' (${widget.unit})',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 3.2,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  )),
              Row(
                children: <Widget>[
                  Text(
                    '${this.widget.min}',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 3.2,
                      fontWeight: FontWeight.w500,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(
                    width: SizeConfig.blockSizeHorizontal * 1,
                  ),
                  Expanded(
                    child: Center(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.teal.withOpacity(1),
                          inactiveTrackColor: Colors.teal.withOpacity(.5),
                          trackHeight: 2.0,
                          */ /*thumbShape: CustomSliderThumbCircle(
                            thumbRadius: this.widget.sliderHeight * .3,
                            min: 0,
                            max: this.widget.max,
                          ),*/ /*
                          overlayColor: Colors.teal.withOpacity(.4),
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 5.0),
                          thumbColor: Colors.blueGrey,
                          //valueIndicatorColor: Colors.white,
                          activeTickMarkColor: Colors.teal,
                          inactiveTickMarkColor: Colors.teal.withOpacity(.7),
                        ),
                        child: Slider(
                            min: this.widget.min.toDouble(),
                            max: this.widget.max.toDouble(),
                            value: widget.value,
                            onChanged: (val) {
                              setState(() {
                                weightValue = val.toDouble();
                                */ /*final oldTotal =
                                    listModelCalorieGain[widget.index].total;
                                listModelCalorieGain[widget.index]
                                    .foodQuantity = val.toInt();
                                listModelCalorieGain[widget.index].total =
                                    listModelCalorieGain[widget.index]
                                            .foodCalorie *
                                        val.toInt();
                                totalCalorieGain = totalCalorieGain -
                                    oldTotal +
                                    listModelCalorieGain[widget.index]
                                            .foodCalorie *
                                        val.toInt();
                                totalCalorie =
                                    totalCalorieGain - totalCalorieLoss;*/ /*
                                widget.callbackFromMain();
                              });
                            }),
                      ),
                    ),
                  ),
                  Text(
                    '${this.widget.max}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 3.2,
                      fontWeight: FontWeight.w700,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }
}*/

class SliderWidget extends StatefulWidget {
  final double sliderHeight;
  double min;
  double max;
  String title = "";
  double? value;
  final fullWidth;
  String unit;
  Function? callbackFromMain;
  bool? isChecked;
  bool isDecimal = false;

  SliderWidget({
    this.sliderHeight = 50,
    this.max = 1000,
    this.min = 0,
    this.value,
    this.title = "",
    this.fullWidth = true,
    this.unit = "",
    this.callbackFromMain,
    this.isChecked,
    this.isDecimal = false,
  });

  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  double _value = 0;

  @override
  void initState() {
    _value = widget.value!;
    if (widget.title == "Weight") {
      weightValue = _value;
      //widget.callbackFromBMI();
    } else if (widget.title == "Height") {
      heightValue = _value;
      //widget.callbackFromBMI();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double paddingFactor = .2;

    if (this.widget.fullWidth) paddingFactor = .3;

    return Container(
        /*padding: widget.title == "Systolic" || widget.title == "Diastolic"
          ? EdgeInsets.only(
              left: SizeConfig.blockSizeHorizontal * 8,
              right: SizeConfig.blockSizeHorizontal * 3,
            )
          : EdgeInsets.only(
              left: SizeConfig.blockSizeHorizontal * 3,
              right: SizeConfig.blockSizeHorizontal * 3,
            ),
      width: this.widget.fullWidth
          ? double.infinity
          : (this.widget.sliderHeight) * 5.5,
      height: SizeConfig.blockSizeVertical * 13,
      decoration: new BoxDecoration(
        borderRadius: new BorderRadius.all(
          Radius.circular((this.widget.sliderHeight * .3)),
        ),
      ),*/
        color: Colors.white,
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal !* 6),
        child: Column(
          children: [
            Row(
              children: <Widget>[
                Expanded(
                  child: UltimateSlider(
                    minValue: widget.min.toDouble(),
                    maxValue: widget.max.toDouble(),
                    value: widget.value!,
                    showDecimals: widget.isDecimal,
                    decimalInterval: 0.05,
                    titleText: widget.title,
                    unitText: widget.unit,
                    indicatorColor: getColorFromTitle(widget.title),
                    bubbleColor: getColorFromTitle(widget.title),
                    onValueChange: (value) {
                      widget.isChecked = true;
                      widget.value = value.toDouble();
                      if (widget.title == "Weight") {
                        weightValue = value.toDouble();
                        widget.callbackFromMain!();
                      }
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: SizeConfig.blockSizeVertical !* 5.0,
            )
            /*Text(
                      '${this.widget.title} - ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      ' ${widget.value.round()} ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal * 5.3,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      ' (${widget.unit})',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    Visibility(
                      visible: widget.title == "Height",
                      child: Text(
                        ' - $heightInFeet',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: widget.title == "Walking",
                      child: Text(
                        '$walkingStepsValue steps',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    )*/
          ],
        )
        /*],
          )*/

        );
  }

  getColorFromTitle(String title) {
    if (title == "Systolic" ||
        title == "Temperature" ||
        title == "FBS" ||
        title == "Height" ||
        title == "Exercise" ||
        title == "TSH" ||
        title == "Sleep")
      return Colors.amber;
    else if (title == "Diastolic" ||
        title == "Pulse" ||
        title == "FBS" ||
        title == "Weight" ||
        title == "Walking" ||
        title == "T3")
      return Colors.blue;
    else if (title == "SPO2" ||
        title == "RBS" ||
        title == "Waist" ||
        title == "T4")
      return Colors.green;
    else if (title == "Respiratory Rate" ||
        title == "HbA1C" ||
        title == "Hip" ||
        title == "Free T3")
      return Colors.deepOrangeAccent;
    else if (title == "Free T4") return Colors.teal;
    return Colors.amber;
  }
}

class NumberInputWithIncrementDecrement extends StatefulWidget {
  void Function() callbackFromMain;
  int index, min, max;

  NumberInputWithIncrementDecrement(
      this.index, this.min, this.max, this.callbackFromMain);

  @override
  _NumberInputWithIncrementDecrementState createState() =>
      _NumberInputWithIncrementDecrementState();
}

class _NumberInputWithIncrementDecrementState
    extends State<NumberInputWithIncrementDecrement> {
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = listModelCalorieGain[widget.index]
        .foodQuantity
        .toString(); // Setting the initial value for the field.
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 3),
      child: Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            width: 70.0,
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(
                color: Colors.blueGrey,
                width: 1.0,
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: IgnorePointer(
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8.0),
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                      controller: _controller,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: false,
                        signed: true,
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 60.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      /*Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: */
                      InkWell(
                        child: Icon(
                          Icons.arrow_drop_up,
                          size: 27.0,
                        ),
                        onTap: () {
                          int currentValue = int.parse(_controller.text);
                          setState(() {
                            if (currentValue >= widget.min &&
                                currentValue < widget.max) {
                              currentValue++;
                              _controller.text = (currentValue)
                                  .toString(); // incrementing value
                              final oldTotal =
                                  listModelCalorieGain[widget.index].total;
                              listModelCalorieGain[widget.index].foodQuantity =
                                  currentValue.toInt();
                              listModelCalorieGain[widget.index].total =
                                  listModelCalorieGain[widget.index]
                                          .foodCalorie *
                                      currentValue.toInt();
                              totalCalorieGain = totalCalorieGain -
                                  oldTotal +
                                  listModelCalorieGain[widget.index]
                                          .foodCalorie *
                                      currentValue.toInt();
                              widget.callbackFromMain();
                            }
                          });
                        },
                      ),
                      /*),*/
                      InkWell(
                        child: Icon(
                          Icons.arrow_drop_down,
                          size: 27.0,
                        ),
                        onTap: () {
                          int currentValue = int.parse(_controller.text);
                          setState(() {
                            print("Setting state");
                            if (currentValue > widget.min &&
                                currentValue <= widget.max) {
                              currentValue--;
                              _controller.text =
                                  (currentValue > 0 ? currentValue : 0)
                                      .toString(); // decrementing value
                              final oldTotal =
                                  listModelCalorieGain[widget.index].total;
                              listModelCalorieGain[widget.index].foodQuantity =
                                  currentValue.toInt();
                              listModelCalorieGain[widget.index].total =
                                  listModelCalorieGain[widget.index]
                                          .foodCalorie *
                                      currentValue.toInt();
                              totalCalorieGain = totalCalorieGain -
                                  oldTotal +
                                  listModelCalorieGain[widget.index]
                                          .foodCalorie *
                                      currentValue.toInt();
                              widget.callbackFromMain();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: SizeConfig.blockSizeHorizontal !* 2,
          ),
          Container(
            width: SizeConfig.blockSizeHorizontal !* 25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  "${listModelCalorieGain[widget.index].foodCalorie} cal * ${_controller.text}",
                  style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal !* 3.5,
                      color: Colors.blueGrey),
                ),
                Text(
                  " = ${listModelCalorieGain[widget.index].foodCalorie * int.parse(_controller.text)} cal",
                  style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal !* 3.5,
                      color: Colors.black),
                ),
              ],
            ),
          )
        ],
      )),
    );
  }
}

class NumberInputWithIncrementDecrementForCalorieLoss extends StatefulWidget {
  void Function() callbackFromMain;
  int index, min, max, interval;

  NumberInputWithIncrementDecrementForCalorieLoss(
      this.index, this.min, this.max, this.interval, this.callbackFromMain);

  @override
  NumberInputWithIncrementDecrementForCalorieLossState createState() =>
      NumberInputWithIncrementDecrementForCalorieLossState();
}

class NumberInputWithIncrementDecrementForCalorieLossState
    extends State<NumberInputWithIncrementDecrementForCalorieLoss> {
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = listModelCalorieLoss[widget.index]
        .time
        .toString(); // Setting the initial value for the field.
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 3),
      child: Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            width: 70.0,
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(
                color: Colors.blueGrey,
                width: 1.0,
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: IgnorePointer(
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      /* decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),*/
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8.0),
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                      controller: _controller,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: false,
                        signed: true,
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 60.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      /*Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: */
                      InkWell(
                        child: Icon(
                          Icons.arrow_drop_up,
                          size: 27.0,
                        ),
                        onTap: () {
                          int currentValue = int.parse(_controller.text);
                          setState(() {
                            if (weightValue != 0) {
                              if (currentValue >= widget.min &&
                                  currentValue < widget.max) {
                                currentValue = currentValue + widget.interval;
                                _controller.text = (currentValue)
                                    .toString(); // incrementing value
                                listModelCalorieLoss[widget.index].time =
                                    currentValue.toInt();
                                listModelCalorieLoss[widget.index].total =
                                    (listModelCalorieLoss[widget.index].time *
                                            currentValue)
                                        .toDouble();
                                widget.callbackFromMain();
                              }
                            } else {
                              final snackBar = SnackBar(
                                backgroundColor: Colors.red,
                                content:
                                    Text("Please select your weight first"),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                          });
                        },
                      ),
                      /*),*/
                      InkWell(
                        child: Icon(
                          Icons.arrow_drop_down,
                          size: 27.0,
                        ),
                        onTap: () {
                          int currentValue = int.parse(_controller.text);
                          setState(() {
                            print("Setting state");
                            if (weightValue != 0) {
                              if (currentValue > widget.min &&
                                  currentValue <= widget.max) {
                                currentValue = currentValue - widget.interval;
                                _controller.text =
                                    (currentValue > 0 ? currentValue : 0)
                                        .toString(); // decrementing value
                                _controller.text = (currentValue)
                                    .toString(); // incrementing value
                                listModelCalorieLoss[widget.index].time =
                                    currentValue.toInt();
                                listModelCalorieLoss[widget.index].total =
                                    (listModelCalorieLoss[widget.index].time *
                                            currentValue)
                                        .toDouble();
                                widget.callbackFromMain();
                              }
                            } else {
                              final snackBar = SnackBar(
                                backgroundColor: Colors.red,
                                content: Text("Please select weight first"),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: SizeConfig.blockSizeHorizontal !* 3,
          ),
          Text(
            "mins.",
            style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal !* 3.5,
                color: Colors.blueGrey),
          ),
          /*Column(
            children: <Widget>[
              Text(
                "${listModelCalorieGain[widget.index].foodCalorie} cal * ${_controller.text}",
                style: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                    color: Colors.blueGrey),
              ),
              Text(
                " = ${listModelCalorieGain[widget.index].foodCalorie * int.parse(_controller.text)} cal",
                style: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                    color: Colors.blueGrey),
              ),
            ],
          )*/
        ],
      )),
    );
  }
}

class MyEChart extends StatefulWidget {
  String chartTypeID, titleOfChart;

  MyEChart({required Key key,required this.chartTypeID,required this.titleOfChart}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyEChartState();
  }
}

class MyEChartState extends State<MyEChart> {
  var yAxisData = StringBuffer();
  var xAxisDatesData = StringBuffer();
  var yAxisData2 = StringBuffer();

  var color;
  var colorRGB;
  var series;

  var listOnlyString, listOnlyDate;

  void setStateInsideTheChart() {
    debugPrint("Let's set chart state");
    yAxisData = StringBuffer();
    yAxisData2 = StringBuffer();
    xAxisDatesData = StringBuffer();

    color = "'rgb(255, 0, 0)'";
    colorRGB = Color.fromRGBO(255, 0, 0, 1);

    series =
        "[{data: $yAxisData,type: 'line',symbol: 'circle',symbolSize: 8,smooth: true,itemStyle: {color: $color},},]";

    listOnlyString = listVitalOnlyString;
    listOnlyDate = listVitalOnlyStringDate;

    debugPrint(listOnlyString.toString());

    if (listOnlyString.length > 1) {
      for (int i = 0; i < listOnlyString.length; i++) {
        if (i == 0)
          yAxisData
              .write("[${double.parse(listOnlyString[i]).round().toInt()},");
        else if (i == listOnlyString.length - 1)
          yAxisData
              .write("${double.parse(listOnlyString[i]).round().toInt()}]");
        else
          yAxisData
              .write("${double.parse(listOnlyString[i]).round().toInt()},");

        if (i == 0)
          xAxisDatesData.write("['${listOnlyDate[i]}',");
        else if (i == listOnlyDate.length - 1)
          xAxisDatesData.write("'${listOnlyDate[i]}']");
        else
          xAxisDatesData.write("'${listOnlyDate[i]}',");
      }
    } else if (listOnlyString.length == 1) {
      yAxisData.write("[${double.parse(listOnlyString[0]).round().toInt()}]");
      xAxisDatesData.write("['${listOnlyDate[0]}']");
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(MyEChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    setStateInsideTheChart();
  }

  @override
  void initState() {
    //setState(() {});
    super.initState();
    setStateInsideTheChart();
  }

  @override
  Widget build(BuildContext context) {
    return listOnlyString.length > 0
        ? Container(
            width: SizeConfig.screenWidth,
            height: SizeConfig.blockSizeVertical !* 60,
            child: widget.chartTypeID != "5"
                ? EchartsCustom(
                    option: '''
                        {
                          tooltip: {
                                trigger: 'axis',
                            },
                          xAxis: {
                            type: 'category',
                            boundaryGap: false,
                            data: $xAxisDatesData,x
                          },
                          yAxis: {
                            type: 'value',
                            boundaryGap: false
                          },
                          legend: {
                            show: true,
                            data: [{name: '${widget.titleOfChart}', icon: 'square', textStyle: {color: $color}}]
                          },
                          series: [{data: $yAxisData,type: 'line',symbol: 'circle',symbolSize: 8,smooth: true,itemStyle: {color: $color},name:'${widget.titleOfChart}'}]
                        }
                        ''',

                    //,name:'BP'
                  )
                : EchartsCustom(
                    option: '''
                  {
                    tooltip: {
                          trigger: 'axis',
                      },
                    xAxis: {
                      type: 'category',
                      boundaryGap: false,
                      data: $xAxisDatesData,
                    },
                    yAxis: {
                      type: 'value',
                      boundaryGap: false
                    },
                    title: {
                            text: 'BP',
                            show: true
                          },
                    legend: {
                            show: true,
                            orient: 'vertical',
                            data: [{name: 'Systolic (mm of hg)', icon: 'square', textStyle: {color: 'rgb(255, 0, 0)', padding: 2}}, {name: 'Diastolic (mm of hg)', icon: 'square', textStyle: {color: 'rgb(0, 145, 234)'}}]
                          },
                    series: [{data: $yAxisData,type: 'line',symbol: 'circle',symbolSize: 8,smooth: true,itemStyle: {color: 'rgb(255, 0, 0)'}, name:'Systolic (mm of hg)'},
                    {data: $yAxisData2,type: 'line',symbol: 'circle',symbolSize: 8,smooth: true,itemStyle: {color: 'rgb(0, 145, 234)'}, name:'Diastolic (mm of hg)'}]
                  }
                ''',
                  ),
          )
        : Container();
  }
}
