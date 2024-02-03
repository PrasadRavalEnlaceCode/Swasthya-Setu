import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(Widget navigateWidget) {
    return navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) {
      return navigateWidget;
    }));
  }

  getNavigatorKey(){
    return navigatorKey;
  }
}
