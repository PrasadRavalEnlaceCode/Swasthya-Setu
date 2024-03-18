import 'package:flutter/material.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';

class ComingSoonNoBackButtonScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      /*appBar: AppBar(
        elevation: 0,
        title: Text(""),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        *//*iconTheme: IconThemeData(
            color: Color(0xFF06A759), size: SizeConfig.blockSizeVertical * 2.5),*//*
        textTheme: TextTheme(
            subtitle1: TextStyle(
                color: Colors.white,
                fontFamily: "Ubuntu",
                fontSize: SizeConfig.blockSizeVertical * 2.5)),
      ),*/
      body: Center(
        child: Text(
          "Coming Soon",
          style: TextStyle(
            color: Colors.red,
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }
}
