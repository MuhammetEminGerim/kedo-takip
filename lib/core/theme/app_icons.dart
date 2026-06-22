import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class AppIcons {
  static Widget _build(IconData iconData, Color? color, double size) {
    return Icon(
      iconData,
      color: color ?? const Color(0xFF5D4037),
      size: size,
    );
  }

  static Widget mic({Color? color, double size = 32}) => _build(FluentIcons.mic_24_filled, color, size);
  static Widget bowl({Color? color, double size = 32}) => _build(FluentIcons.food_grains_24_filled, color, size);
  static Widget litter({Color? color, double size = 32}) => _build(FluentIcons.box_24_filled, color, size);
  static Widget water({Color? color, double size = 32}) => _build(FluentIcons.drop_24_filled, color, size);
  static Widget meow({Color? color, double size = 32}) => _build(FluentIcons.animal_cat_24_filled, color, size);
  
  static Widget navHome({Color? color, double size = 28}) => _build(FluentIcons.home_24_filled, color, size);
  static Widget navRecord({Color? color, double size = 28}) => _build(FluentIcons.mic_24_filled, color, size);
  static Widget navCare({Color? color, double size = 28}) => _build(FluentIcons.heart_pulse_24_filled, color, size);
  static Widget navStats({Color? color, double size = 28}) => _build(FluentIcons.data_bar_vertical_24_filled, color, size);
  static Widget navLearn({Color? color, double size = 28}) => _build(FluentIcons.book_24_filled, color, size);
}
