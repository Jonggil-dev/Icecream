import 'package:flutter/material.dart';
import 'package:icecream/com/const/color.dart';
import 'package:icecream/setting/widget/custom_icon.dart';

class LocationIcons {
  static const home = CustomIcon(color: AppColors.custom_green, icon: Icons.home_filled);
  static const star = CustomIcon(color: AppColors.icon_red_color, icon: Icons.star);
  static const school = CustomIcon(color: AppColors.icon_yellow_color, icon: Icons.local_library);
  static const flag = CustomIcon(color: AppColors.icon_blue_color, icon: Icons.flag);
  static const favorite = CustomIcon(color: AppColors.icon_pink_color, icon: Icons.favorite);
  static const science = CustomIcon(color: AppColors.custom_yellow, icon: Icons.science);
  static const music = CustomIcon(color: AppColors.custom_red, icon: Icons.music_note);
  static const math = CustomIcon(color: AppColors.custom_brown, icon: Icons.calculate);
}

final List<Widget> locationIcons = [
  LocationIcons.star,
  LocationIcons.home,
  LocationIcons.school,
  LocationIcons.flag,
  LocationIcons.favorite,
  LocationIcons.science,
  LocationIcons.music,
  LocationIcons.math,
];