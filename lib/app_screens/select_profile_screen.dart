import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silvertouch/global/SizeConfig.dart';

import '../utils/color.dart';

class SelectProfileScreen extends StatefulWidget {
  final json;

  SelectProfileScreen({Key? key, @required this.json}) : super(key: key);

  @override
  _SelectProfileScreenState createState() => _SelectProfileScreenState();
}

class _SelectProfileScreenState extends State<SelectProfileScreen> {
  @override
  void initState() {
    // Future.delayed(Duration(milliseconds: 1000), () {
    //   showDialog(
    //       context: context,
    //       builder: (BuildContext context) {
    //         return AlertDialog(
    //           title: Text('Switch Profile'),
    //           content: Text(
    //               'You can any time change the profile and switch to other account from profile section'),
    //         );
    //       });
    // });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Select Profile to proceed'),
          backgroundColor: blueThemeColor,
          toolbarTextStyle: TextTheme(
                  titleLarge: TextStyle(
                      color: Colorsblack,
                      fontFamily: "Ubuntu",
                      fontSize: SizeConfig.blockSizeVertical! * 2.5))
              .bodyMedium,
          titleTextStyle: TextTheme(
                  titleLarge: TextStyle(
                      color: Colorsblack,
                      fontFamily: "Ubuntu",
                      fontSize: SizeConfig.blockSizeVertical! * 2.5))
              .titleLarge,
        ),
        body: ListView.builder(
            itemBuilder: _rawProfile, itemCount: widget.json.length + 1));
  }

  Widget _rawProfile(BuildContext context, int index) {
    return (index == 0)
        ? Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'You can any time change the profile and switch to other account from profile section',
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
          )
        : InkWell(
            onTap: () => Get.back(result: index - 1),
            child: Card(
              child: Padding(
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 2),
                  child: Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                    CircleAvatar(
                        radius: SizeConfig.blockSizeHorizontal! * 6,
                        backgroundImage:
                            AssetImage("images/ic_user_placeholder.png")),
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal! * 5,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          (widget.json[index - 1]["FirstName"].trim() +
                                  " " +
                                  widget.json[index - 1]["LastName"].trim())
                              .trim(),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: SizeConfig.blockSizeHorizontal! * 4.2,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            letterSpacing: 1.3,
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical! * 0.5,
                        ),
                        Text(
                          widget.json[index - 1]["PatientID"],
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: SizeConfig.blockSizeHorizontal! * 3.3,
                            color: Colors.grey,
                            letterSpacing: 1.3,
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical! * 0.5,
                        ),
                        Text(
                          widget.json[index - 1]["Gender"] +
                              ' / ' +
                              widget.json[index - 1]['Age'],
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: SizeConfig.blockSizeHorizontal! * 3.3,
                            color: Colors.grey,
                            letterSpacing: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ])),
            ),
          );
  }
}
