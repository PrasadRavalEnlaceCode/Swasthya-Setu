class IconModel {
  String? iconName, image, webView, description;

  IconModel(
      /*this.studentId,
    this.studentName,
    this.studentScores*/
      iconName,
      image,
      webView,
      [description = ""]){
   this.iconName = iconName;
   this.image = image;
   this.webView = webView;
   this.description = description;
  }

/*factory IconModel.fromJSON(){
    return IconModel()
  }*/
}
