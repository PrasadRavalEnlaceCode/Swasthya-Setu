// import 'dart:async';
// import 'dart:convert';
//
// import 'package:agora_rtc_engine/rtc_engine.dart';
// import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
// import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
// import 'package:flutter/material.dart';
// import 'package:swasthyasetu/enums/call_connected_status.dart';
// import 'package:swasthyasetu/global/SizeConfig.dart';
// import 'package:swasthyasetu/global/utils.dart';
// import 'package:swasthyasetu/podo/model_message.dart';
// import 'package:swasthyasetu/podo/response_main_model.dart';
// import 'package:swasthyasetu/utils/progress_dialog.dart';
//
// import 'package:http/http.dart' as http;
//
// class AudioCallScreen extends StatefulWidget {
//   final String patientIDP, channelID, patientName, patientImage, chatIDP;
//   final Message message;
//
//   AudioCallScreen({
//     this.patientIDP,
//     this.channelID,
//     this.message,
//     this.patientName,
//     this.patientImage,
//     this.chatIDP,
//   });
//
//   @override
//   _AudioCallScreenState createState() => _AudioCallScreenState();
// }
//
// class _AudioCallScreenState extends State<AudioCallScreen> {
//   final _users = <int>[];
//   final _infoStrings = <String>[];
//   bool muted = false;
//   bool mutedCamera = false;
//   RtcEngine _engine;
//   final String APP_ID = "368ba9e4f7664587ac95d7588a86d2f1";
//   String channelName = "";
//   String doctorIDP = "", userType = "";
//   String patientImage = "";
//   ConnectedStatus connectedStatus = ConnectedStatus.connecting;
//
//   @override
//   void dispose() {
//     // clear users
//     _users.clear();
//     // destroy sdk
//     _engine.leaveChannel();
//     _engine.destroy();
//     super.dispose();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     getImage();
//     initialize();
//   }
//
//   Future<void> initialize() async {
//     getPatientOrDoctorIDP().then((value) => doctorIDP = value);
//     await _initAgoraRtcEngine();
//     _addAgoraEventHandlers();
//     /*VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
//     configuration.dimensions = VideoDimensions(1920, 1080);
//     await _engine.setVideoEncoderConfiguration(configuration);*/
//     await _engine.joinChannel(null, widget.channelID, null, 0);
//   }
//
//   Future<void> _initAgoraRtcEngine() async {
//     /*_engine = await RtcEngine.create(APP_ID);
//     await _engine.enableVideo();
//     await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
//     await _engine.setClientRole(*/ /*widget.role*/ /* ClientRole.Broadcaster);*/
//     _engine = await RtcEngine.create(APP_ID);
//     await _engine.enableAudio();
//     await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
//     await _engine.setClientRole(ClientRole.Broadcaster);
//   }
//
//   /// Add agora event handlers
//   void _addAgoraEventHandlers() {
//     _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
//       setState(() {
//         final info = 'onError: $code';
//         _infoStrings.add(info);
//       });
//     }, joinChannelSuccess: (channel, uid, elapsed) {
//       setState(() {
//         final info = 'onJoinChannel: $channel, uid: $uid';
//         _infoStrings.add(info);
//       });
//     }, leaveChannel: (stats) {
//       setState(() {
//         _infoStrings.add('onLeaveChannel');
//         _users.clear();
//         setState(() {
//           connectedStatus = ConnectedStatus.disconnected;
//         });
//       });
//     }, userJoined: (uid, elapsed) {
//       setState(() {
//         final info = 'userJoined: $uid';
//         _infoStrings.add(info);
//         _users.add(uid);
//         setState(() {
//           connectedStatus = ConnectedStatus.connected;
//         });
//       });
//     }, userOffline: (uid, elapsed) {
//       setState(() {
//         final info = 'userOffline: $uid';
//         _infoStrings.add(info);
//         _users.remove(uid);
//         setState(() {
//           connectedStatus = ConnectedStatus.offline;
//         });
//       });
//     }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
//       setState(() {
//         final info = 'firstRemoteVideo: $uid ${width}x $height';
//         _infoStrings.add(info);
//       });
//     }));
//   }
//
//   /// Helper function to get list of native views
//   List<Widget> _getRenderViews() {
//     final List<StatefulWidget> list = [];
//     //if (widget.role == ClientRole.Broadcaster) {
//     list.add(RtcLocalView.SurfaceView());
//     //}
//     _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
//     return list;
//   }
//
//   /// Video view wrapper
//   Widget _videoView(view) {
//     return Expanded(child: Container(child: view));
//   }
//
//   /// Video view row wrapper
//   Widget _expandedVideoRow(List<Widget> views) {
//     final wrappedViews = views.map<Widget>(_videoView).toList();
//     return Expanded(
//       child: Row(
//         children: wrappedViews,
//       ),
//     );
//   }
//
//   Widget positionedVideoRow(List<Widget> views) {
//     final wrappedViews = views.map<Widget>(_videoView).toList();
//     return Positioned(
//       left: 0,
//       right: 0,
//       top: 0,
//       bottom: 0,
//       child: Row(
//         children: wrappedViews,
//       ),
//     );
//   }
//
//   Widget normalVideoRow(List<Widget> views) {
//     final wrappedViews = views.map<Widget>(_videoView).toList();
//     return Row(
//       children: wrappedViews,
//     );
//   }
//
//   /// Video layout wrapper
//   Widget _viewRows() {
//     final views = _getRenderViews();
//     switch (views.length) {
//       case 1:
//         return Container(
//             child: Column(
//           children: <Widget>[_videoView(views[0])],
//         ));
//       case 2:
//         return Container(
//             child: Stack(
//           children: <Widget>[
//             positionedVideoRow([views[1]]),
//             Align(
//               alignment: Alignment.topRight,
//               child: Container(
//                 width: 120,
//                 height: 170,
//                 padding: EdgeInsets.only(
//                   right: 12.0,
//                   top: 38.0,
//                 ),
//                 child: normalVideoRow([views[0]]),
//               ),
//             ),
//           ],
//         ));
//       case 3:
//         return Container(
//             child: Column(
//           children: <Widget>[
//             _expandedVideoRow(views.sublist(0, 2)),
//             _expandedVideoRow(views.sublist(2, 3))
//           ],
//         ));
//       case 4:
//         return Container(
//             child: Column(
//           children: <Widget>[
//             _expandedVideoRow(views.sublist(0, 2)),
//             _expandedVideoRow(views.sublist(2, 4))
//           ],
//         ));
//       default:
//     }
//     return Container();
//   }
//
//   Widget _toolbar() {
//     /*if (widget.role == ClientRole.Audience) return Container();*/
//     return Container(
//       alignment: Alignment.bottomCenter,
//       padding: const EdgeInsets.symmetric(vertical: 20),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           RawMaterialButton(
//             onPressed: _onToggleMute,
//             child: Image(
//               image: AssetImage(
//                 muted ? "images/ic_mic_off.png" : "images/ic_mic_on.png",
//               ),
//               color: muted ? Colors.white : Colors.blueAccent,
//               width: SizeConfig.blockSizeHorizontal * 7.0,
//               height: SizeConfig.blockSizeHorizontal * 7.0,
//             ),
//             shape: CircleBorder(),
//             elevation: 2.0,
//             fillColor: muted ? Colors.blueAccent : Colors.white,
//             padding: const EdgeInsets.all(12.0),
//           ),
//           /*RawMaterialButton(
//             onPressed: _onToggleMuteCamera,
//             child: Image(
//               image: AssetImage(
//                 mutedCamera
//                     ? "images/ic_camera_off.png"
//                     : "images/ic_camera_on.png",
//               ),
//               color: mutedCamera ? Colors.white : Colors.blueAccent,
//               width: SizeConfig.blockSizeHorizontal * 7.0,
//               height: SizeConfig.blockSizeHorizontal * 7.0,
//             ),
//             shape: CircleBorder(),
//             elevation: 2.0,
//             fillColor: mutedCamera ? Colors.blueAccent : Colors.white,
//             padding: const EdgeInsets.all(12.0),
//           ),*/
//           RawMaterialButton(
//             onPressed: () => _onCallEnd(context),
//             child: Icon(
//               Icons.call_end,
//               color: Colors.white,
//               size: SizeConfig.blockSizeHorizontal * 8.5,
//             ),
//             shape: CircleBorder(),
//             elevation: 2.0,
//             fillColor: Colors.redAccent,
//             padding: const EdgeInsets.all(15.0),
//           ),
//           RawMaterialButton(
//             onPressed: _onSwitchCamera,
//             child: Image(
//               image: AssetImage(
//                 "images/ic_change_camera.png",
//               ),
//               color: Colors.blueAccent,
//               width: SizeConfig.blockSizeHorizontal * 8.5,
//               height: SizeConfig.blockSizeHorizontal * 8.5,
//             ),
//             /*Icon(
//               Icons.switch_camera,
//               color: Colors.blueAccent,
//               size: 20.0,
//             )*/
//             shape: CircleBorder(),
//             elevation: 2.0,
//             fillColor: Colors.white,
//             padding: const EdgeInsets.all(8.0),
//           )
//         ],
//       ),
//     );
//   }
//
//   /// Info panel to show logs
//   Widget _panel() {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 20),
//       alignment: Alignment.bottomCenter,
//       child: FractionallySizedBox(
//         heightFactor: 0.5,
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 48),
//           child: ListView.builder(
//             reverse: true,
//             itemCount: _infoStrings.length,
//             itemBuilder: (BuildContext context, int index) {
//               if (_infoStrings.isEmpty) {
//                 return null;
//               }
//               return Padding(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 3,
//                   horizontal: 10,
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Flexible(
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 2,
//                           horizontal: 5,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.yellowAccent,
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                         child: Text(
//                           _infoStrings[index],
//                           style: TextStyle(color: Colors.blueGrey),
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   void endVidCallAPI(String startOrEnd) async {
//     final String urlGetChannelIDForVidCall = "${baseURL}audiocall.php";
//     ProgressDialog pr = ProgressDialog(context);
//     pr.show();
//
//     try {
//       String patientUniqueKey = await getPatientUniqueKey();
//       String userType = await getUserType();
//       String doctorIDP = await getPatientOrDoctorIDP();
//       debugPrint("Key and type");
//       debugPrint(patientUniqueKey);
//       debugPrint(userType);
//       String fromType = "";
//       String patientIDPValue = "";
//       String doctorIDPValue = "";
//
//       if (userType == "patient") {
//         patientIDPValue = doctorIDP;
//         doctorIDPValue = widget.patientIDP;
//         fromType = "P";
//       } else if (userType == "doctor") {
//         patientIDPValue = widget.patientIDP;
//         doctorIDPValue = doctorIDP;
//         fromType = "D";
//       }
//       String startOrEndCall = "";
//       if (startOrEnd == "0") {
//         startOrEndCall = "startcall";
//       } else if (startOrEnd == "1") {
//         startOrEndCall = "endcall";
//       }
//       String jsonStr = "{" +
//           "\"PatientIDP\":\"$patientIDPValue\"" +
//           ",\"DoctorIDP\":\"$doctorIDPValue\"" +
//           ",\"FromType\":\"$fromType\"" +
//           ",\"CallType\":\"$startOrEndCall\"" +
//           ",\"ChatIDP\":\"${widget.chatIDP}\"" +
//           "}";
//
//       debugPrint(jsonStr);
//
//       String encodedJSONStr = encodeBase64(jsonStr);
//       var response = await apiHelper.callApiWithHeadersAndBody(
//         url: urlGetChannelIDForVidCall,
//         headers: {
//           "u": patientUniqueKey,
//           "type": userType,
//         },
//         body: {"getjson": encodedJSONStr},
//       );
//       debugPrint(response.body.toString());
//       final jsonResponse = json.decode(response.body.toString());
//       ResponseModel model = ResponseModel.fromJSON(jsonResponse);
//       pr.hide();
//       if (model.status == "OK") {
//         Navigator.of(context).pop();
//       } else {}
//     } catch (exception) {}
//   }
//
//   String encodeBase64(String text) {
//     var bytes = utf8.encode(text);
//     return base64.encode(bytes);
//   }
//
//   String decodeBase64(String text) {
//     var bytes = base64.decode(text);
//     return String.fromCharCodes(bytes);
//   }
//
//   void _onCallEnd(BuildContext context) {
//     endVidCallAPI("1");
//     //Navigator.pop(context);
//   }
//
//   void _onToggleMute() {
//     setState(() {
//       muted = !muted;
//     });
//     _engine.muteLocalAudioStream(muted);
//   }
//
//   void _onToggleMuteCamera() {
//     setState(() {
//       mutedCamera = !mutedCamera;
//     });
//     _engine.muteLocalVideoStream(mutedCamera);
//     _engine.muteRemoteVideoStream(_users[0], muted);
//   }
//
//   void _onSwitchCamera() {
//     _engine.switchCamera();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);
//     return SafeArea(
//       child: Scaffold(
//         /*appBar: AppBar(
//         title: Text('Agora Flutter QuickStart'),
//       ),*/
//         //backgroundColor: Colors.black,
//         body: Builder(
//           builder: (context) {
//             return WillPopScope(
//               onWillPop: () {
//                 endVidCallAPI("1");
//               },
//               child: Container(
//                 width: SizeConfig.screenWidth,
//                 height: SizeConfig.screenHeight,
//                 decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Color(0xFFC3E291),
//                     Color(0xFFA1DBB8),
//                     Color(0xFF61C6C6),
//                   ],
//                 )),
//                 child: Column(
//                   children: <Widget>[
//                     SizedBox(
//                       height: SizeConfig.blockSizeVertical * 3.0,
//                     ),
//                     Container(
//                       width: SizeConfig.blockSizeHorizontal * 35,
//                       height: SizeConfig.blockSizeHorizontal * 35,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(color: Colors.black),
//                         image: DecorationImage(
//                           image: NetworkImage(patientImage),
//                           fit: BoxFit.fill,
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       height: SizeConfig.blockSizeVertical * 3.0,
//                     ),
//                     Text(
//                       widget.patientName,
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontSize: SizeConfig.blockSizeHorizontal * 5.5,
//                         fontWeight: FontWeight.w500,
//                         letterSpacing: 1.5,
//                       ),
//                     ),
//                     SizedBox(
//                       height: SizeConfig.blockSizeVertical * 5.0,
//                     ),
//                     Text(
//                       getConnectedStatusString(),
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: SizeConfig.blockSizeHorizontal * 4.5,
//                         fontWeight: FontWeight.w500,
//                         letterSpacing: 1.5,
//                       ),
//                     ),
//                     Expanded(
//                       child: Align(
//                         alignment: Alignment.bottomCenter,
//                         child: RawMaterialButton(
//                           onPressed: () => _onCallEnd(context),
//                           child: Icon(
//                             Icons.call_end,
//                             color: Colors.white,
//                             size: SizeConfig.blockSizeHorizontal * 8.5,
//                           ),
//                           shape: CircleBorder(),
//                           elevation: 2.0,
//                           fillColor: Colors.redAccent,
//                           padding: const EdgeInsets.all(15.0),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       height: SizeConfig.blockSizeVertical * 3.0,
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   void getImage() async {
//     userType = await getUserType();
//     if (userType == "patient") {
//       getDoctorProfileDetails();
//     } else {
//       getPatientProfileDetails();
//     }
//   }
//
//   void getDoctorProfileDetails() async {
//     String patientUniqueKey = await getPatientUniqueKey();
//     String userType = await getUserType();
//     String patientIDP = await getPatientOrDoctorIDP();
//     debugPrint("Key and type");
//     debugPrint(patientUniqueKey);
//     debugPrint(userType);
//     String jsonStr = "{" +
//         "\"" +
//         "DoctorIDP" +
//         "\"" +
//         ":" +
//         "\"" +
//         widget.patientIDP +
//         "\"" +
//         "}";
//
//     debugPrint(jsonStr);
//
//     String encodedJSONStr = encodeBase64(jsonStr);
//     var response = await apiHelper.callApiWithHeadersAndBody(
//       url: "${baseURL}doctorProfileData.php",
//       //Uri.parse(loginUrl),
//       headers: {
//         "u": patientUniqueKey,
//         "type": userType,
//       },
//       body: {"getjson": encodedJSONStr},
//     );
//     //var resBody = json.decode(response.body);
//     debugPrint(response.body.toString());
//     final jsonResponse = json.decode(response.body.toString());
//     ResponseModel model = ResponseModel.fromJSON(jsonResponse);
//     if (model.status == "OK") {
//       var data = jsonResponse['Data'];
//       var strData = decodeBase64(data);
//       debugPrint("Decoded Data Array : " + strData);
//       debugPrint("Decoded Data Array : " + strData);
//       final jsonData = json.decode(strData);
//       patientImage = '$doctorImgUrl${jsonData[0]['DoctorImage']}';
//       debugPrint("doctor img url");
//       debugPrint(patientImage);
//       setState(() {});
//     } else {}
//   }
//
//   void getPatientProfileDetails() async {
//     String patientUniqueKey = await getPatientUniqueKey();
//     String userType = await getUserType();
//     String patientIDP = await getPatientOrDoctorIDP();
//     debugPrint("Key and type");
//     debugPrint(patientUniqueKey);
//     debugPrint(userType);
//     String jsonStr = "{" +
//         "\"" +
//         "PatientIDP" +
//         "\"" +
//         ":" +
//         "\"" +
//         widget.patientIDP +
//         "\"" +
//         "}";
//
//     debugPrint(jsonStr);
//
//     String encodedJSONStr = encodeBase64(jsonStr);
//     //listIcon = new List();
//     var response = await apiHelper.callApiWithHeadersAndBody(
//       url: "${baseURL}patientProfileData.php",
//       //Uri.parse(loginUrl),
//       headers: {
//         "u": patientUniqueKey,
//         "type": userType,
//       },
//       body: {"getjson": encodedJSONStr},
//     );
//     //var resBody = json.decode(response.body);
//     debugPrint(response.body.toString());
//     final jsonResponse = json.decode(response.body.toString());
//     ResponseModel model = ResponseModel.fromJSON(jsonResponse);
//     if (model.status == "OK") {
//       var data = jsonResponse['Data'];
//       var strData = decodeBase64(data);
//       debugPrint("Decoded Data Array : " + strData);
//       final jsonData = json.decode(strData);
//       patientImage = '$userImgUrl${jsonData[0]['Image']}';
//       setState(() {});
//       debugPrint("patient img url");
//       debugPrint(patientImage);
//     } else {}
//   }
//
//   String getConnectedStatusString() {
//     switch (connectedStatus) {
//       case ConnectedStatus.connecting:
//         return "Connecting...";
//       case ConnectedStatus.connected:
//         return "Connected";
//       case ConnectedStatus.disconnected:
//         return "Disconnected";
//       case ConnectedStatus.offline:
//         return "Disconnected";
//       default:
//         return "Connecting...";
//     }
//   }
// }
