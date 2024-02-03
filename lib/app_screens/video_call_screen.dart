// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// // import 'package:agora_rtc_engine/rtc_engine.dart';
// // import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
// // import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:swasthyasetu/global/SizeConfig.dart';
// import 'package:swasthyasetu/global/utils.dart';
// import 'package:swasthyasetu/podo/response_main_model.dart';
// import 'package:swasthyasetu/utils/progress_dialog.dart';
//
// import 'package:http/http.dart' as http;
//
// class VideoCallScreen extends StatefulWidget {
//   final String patientIDP, channelID, chatIDP;
//
//   /*final ClientRole role;*/
//
//   const VideoCallScreen({
//     this.patientIDP,
//     this.channelID,
//     this.chatIDP,
//   });
//
//   @override
//   _VideoCallScreenState createState() => _VideoCallScreenState();
// }
//
// class _VideoCallScreenState extends State<VideoCallScreen> {
//   final _users = <int>[];
//   final _infoStrings = <String>[];
//   bool muted = false;
//   bool mutedCamera = false;
// //  RtcEngine _engine;
//   final String APP_ID = "368ba9e4f7664587ac95d7588a86d2f1";
//   String channelName = "";
//   String doctorIDP = "", userType = "";
//
//   @override
//   void dispose() {
//     // clear users
//     _users.clear();
//     // destroy sdk
//  //   _engine.leaveChannel();
//  //   _engine.destroy();
//     super.dispose();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     initialize();
//   }
//
//   Future<void> initialize() async {
//     /*if (APP_ID.isEmpty) {
//       setState(() {
//         _infoStrings.add(
//           'APP_ID missing, please provide your APP_ID in settings.dart',
//         );
//         _infoStrings.add('Agora Engine is not starting');
//       });
//       return;
//     }*/
//     getPatientOrDoctorIDP().then((value) => doctorIDP = value);
//     getUserType().then((value) => userType = value);
//     //channelName = "test_channel_1234";
//     await _initAgoraRtcEngine();
//     _addAgoraEventHandlers();
//     //await _engine.enableWebSdkInteroperability(true);
//     VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
//     configuration.dimensions = VideoDimensions(width:1920, height: 1080);
//     await _engine.setVideoEncoderConfiguration(configuration);
//     if (Platform.isAndroid) {
//       await [Permission.microphone, Permission.camera].request();
//     }
//     await _engine.joinChannel(/*Token*/ "", widget.channelID, null, 0);
//     /*showDialog(
//         context: context,
//         builder: (context) {
//           return Text("ID - ${widget.channelID}");
//         });*/
//   }
//
//   Future<void> _initAgoraRtcEngine() async {
//     _engine = await RtcEngine.create(APP_ID);
//     await _engine.enableVideo();
//     await _engine.startPreview();
//     await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
//     await _engine.setAudioProfile(
//         AudioProfile.Default, AudioScenario.GameStreaming);
//     await _engine.setClientRole(/*widget.role*/ ClientRole.Broadcaster);
//   }
//
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
//       });
//     }, userJoined: (uid, elapsed) {
//       setState(() {
//         final info = 'userJoined: $uid';
//         _infoStrings.add(info);
//         _users.add(uid);
//       });
//     }, userOffline: (uid, elapsed) {
//       setState(() {
//         final info = 'userOffline: $uid';
//         _infoStrings.add(info);
//         _users.remove(uid);
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
//     final String urlGetChannelIDForVidCall = "${baseURL}videocall.php";
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
//           /*"PatientIDP" +
//           "\"" +
//           ":" +
//           "\"" +
//           patientIDP +
//           "\"" +*/
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
//     return Scaffold(
//       /*appBar: AppBar(
//         title: Text('Agora Flutter QuickStart'),
//       ),*/
//       backgroundColor: Colors.black,
//       body: Builder(
//         builder: (context) {
//           return WillPopScope(
//             onWillPop: () {
//               endVidCallAPI("1");
//             },
//             child: Center(
//               child: Stack(
//                 children: <Widget>[
//                   _viewRows(),
//                   /*_panel(),*/
//                   _toolbar(),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
