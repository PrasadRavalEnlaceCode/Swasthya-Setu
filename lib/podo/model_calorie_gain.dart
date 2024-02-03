class ModelCalorieGain {
  String category = "";
  String foodName = "";
  String foodDesc = "";
  double foodCalorie = 0;
  int foodQuantity = 0;
  double total = 0;
  bool showCategory = false;

  ModelCalorieGain(this.category, this.foodName, this.foodDesc,
      this.foodCalorie, this.foodQuantity, this.total, this.showCategory);
}
