import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:swasthyasetu/enums/list_type.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';

import '../utils/color.dart';
import '../utils/progress_dialog.dart';

class TypicalListsScreen extends StatefulWidget {
  String patientIDP;
  final ListTypes type;

  TypicalListsScreen(this.patientIDP, this.type);

  @override
  State<StatefulWidget> createState() {
    return TypicalListsScreenState();
  }
}

class TypicalListsScreenState extends State<TypicalListsScreen> {
  List<Map<String, dynamic>> listHealthTips = [];
  List<Map<String, dynamic>> listHealthTipsSearchResults = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleWidget = Text(getAppBarTitle());
    getHealthTips(context);
  }

  Icon icon = Icon(
    Icons.search,
    color: Colors.white,
  );
  Widget? titleWidget;
  TextEditingController? searchController;
  var focusNode = new FocusNode();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: titleWidget,
          backgroundColor: Color(0xFFFFFFFF),
          iconTheme: IconThemeData(
              color: Colorsblack, size: SizeConfig.blockSizeVertical !* 2.5),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                setState(() {
                  if (icon.icon == Icons.search) {
                    searchController = TextEditingController(text: "");
                    focusNode.requestFocus();
                    icon = Icon(
                      Icons.cancel,
                      color: Colors.black,
                    );
                    titleWidget = TextField(
                      controller: searchController,
                      focusNode: focusNode,
                      cursorColor: Colors.white,
                      onChanged: (text) {
                        setState(() {
                          listHealthTipsSearchResults = listHealthTips
                              .where((model) =>
                                  model["title"]
                                      .toLowerCase()
                                      .contains(text.toLowerCase()) ||
                                  model["desc"]
                                      .toLowerCase()
                                      .contains(text.toLowerCase()))
                              .toList();
                        });
                      },
                      style: TextStyle(
                        color: Colorsblack,
                        fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                      ),
                      decoration: InputDecoration(
                        /*hintStyle: TextStyle(
                          color: Colors.black,
                          fontSize:
                          SizeConfig.blockSizeVertical * 2.1),
                      labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize:
                          SizeConfig.blockSizeVertical * 2.1),*/
                        hintText: "Search Health Tips",
                      ),
                    );
                  } else {
                    icon = Icon(
                      Icons.search,
                      color: Colorsblack,
                    );
                    titleWidget = Text("Health Tips");
                    listHealthTipsSearchResults = listHealthTips;
                  }
                });
              },
              icon: icon,
            )
          ], toolbarTextStyle: TextTheme(
              titleMedium: TextStyle(
                  color: Colorsblack,
                  fontFamily: "Ubuntu",
                  fontSize: SizeConfig.blockSizeVertical !* 2.5)).bodyMedium, titleTextStyle: TextTheme(
              titleMedium: TextStyle(
                  color: Colorsblack,
                  fontFamily: "Ubuntu",
                  fontSize: SizeConfig.blockSizeVertical !* 2.5)).titleLarge,
        ),
        body: Container(
          color: Color(0xFFDCDCDC),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: createListWidget(context),
              )
            ],
          ),
        ));
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

  void getHealthTips(BuildContext context) async {
    String loginUrl = "$baseURL${getApiName()}";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new List();
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
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listHealthTips.add(getModel(jo));
      }
      listHealthTipsSearchResults = listHealthTips;
      setState(() {});
    }
  }

  createListWidget(BuildContext context) {
    ScrollController _scrollController = ScrollController();
    debugPrint("before listener");
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        debugPrint("scrolled to end...");
        if (!isLoading) {
          getHealthTips(context);
        }
      }
    });
    return ListView.builder(
        //uncommment for paging
        controller: _scrollController,
        shrinkWrap: true,
        itemCount: listHealthTipsSearchResults.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {},
            child: Card(
              margin: EdgeInsets.only(
                  left: SizeConfig.blockSizeHorizontal !* 2,
                  right: SizeConfig.blockSizeHorizontal !* 2,
                  top: SizeConfig.blockSizeHorizontal !* 2,
                  bottom: index == listHealthTipsSearchResults.length - 1
                      ? SizeConfig.blockSizeHorizontal !* 2
                      : 0),
              color: Colors.white,
              elevation: 2.0,
              child: Padding(
                padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Image(
                      image: AssetImage(getImagePath()),
                      width: SizeConfig.blockSizeHorizontal !* 8,
                      height: SizeConfig.blockSizeHorizontal !* 8,
                    ),
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal !* 3,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            listHealthTipsSearchResults[index]["title"],
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeHorizontal !* 4.2,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical !* 0.5,
                          ),
                          Text(
                            listHealthTipsSearchResults[index]["desc"],
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: SizeConfig.blockSizeHorizontal !* 3.5,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  String getAppBarTitle() {
    if (widget.type == ListTypes.HealthTips)
      return "Health Tips";
    else if (widget.type == ListTypes.HealthQuotes)
      return "Health Quotes";
    else if (widget.type == ListTypes.Recipes)
      return "Food";
    else if (widget.type == ListTypes.ImportantLinks) return "Links To Follow";
    return "";
  }

  String getApiName() {
    if (widget.type == ListTypes.HealthTips)
      return "patientHealthTipsData.php";
    else if (widget.type == ListTypes.HealthQuotes)
      return "patientHealthQuotesData.php";
    else if (widget.type == ListTypes.Recipes)
      return "patientHealthRecepiesData.php";
    else if (widget.type == ListTypes.ImportantLinks)
      return "patientHealthLinksData.php";
    return "";
  }

  String getImagePath() {
    if (widget.type == ListTypes.HealthTips)
      return "images/ic_health_tips_colored.png";
    else if (widget.type == ListTypes.HealthQuotes)
      return "images/ic_quotes_colored.png";
    else if (widget.type == ListTypes.Recipes)
      return "images/ic_recipes.png";
    else if (widget.type == ListTypes.ImportantLinks)
      return "images/ic_imp_links.png";
    return "";
  }

  String getTitle(dynamic jo) {
    if (widget.type == ListTypes.HealthTips ||
        widget.type == ListTypes.HealthQuotes ||
        widget.type == ListTypes.Recipes ||
        widget.type == ListTypes.ImportantLinks) return jo['Title'];
    return "";
  }

  getModel(dynamic jo) {
    if (widget.type == ListTypes.HealthTips)
      return {
        "title": jo['Title'],
        "desc": jo['Deatails'],
        "idp": jo['HealthTipsIDP'].toString(),
        "tipDate": jo['TipDate'],
      };
    else if (widget.type == ListTypes.HealthQuotes)
      return {
        "title": jo['Title'],
        "desc": jo['Details'],
        "idp": jo['HealthQuotesIDP'].toString(),
        "tipDate": jo['QuoteDate'],
      };
    else if (widget.type == ListTypes.Recipes)
      return {
        "title": jo['Title'],
        "desc": jo['Details'],
        "idp": jo['HealthRecepiesIDP'].toString(),
        "tipDate": jo['RecepieDate'],
      };
    else if (widget.type == ListTypes.ImportantLinks)
      return {
        "title": jo['Title'],
        "desc": jo['Details'],
        "idp": jo['HealthLinksIDP'].toString(),
        "tipDate": jo['LinkDate'],
        "linkURL": jo['LinkURL'],
      };
  }
}
