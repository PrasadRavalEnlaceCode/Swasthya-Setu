import 'package:flutter/material.dart';

class ModelIcon {
  String? iconType = "", iconName = "", iconImg;
  IconData? iconData;
  Color iconColor, iconBgColor;

  ModelIcon({
    this.iconType,
    this.iconName,
    this.iconImg,
    this.iconData,
    this.iconBgColor = const Color(0xFFC8E6C9),
    this.iconColor = const Color(0xFF06A759),
  });
}
