import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class AppIcons {
  static Widget _build(String assetName, Color? color, double size) {
    return Image.asset(
      'assets/icons_petshop/$assetName.png',
      width: size,
      height: size,
    );
  }

  // Quick Action Icons
  static Widget mic({Color? color, double size = 32}) => _build('pet-collar', null, size); // Alternative: cat-toys, pet-spray
  static Widget bowl({Color? color, double size = 32}) => _build('canned-foof', null, size);
  static Widget litter({Color? color, double size = 32}) => _build('liiter-box', null, size);
  static Widget water({Color? color, double size = 32}) => _build('pets-drink', null, size);
  static Widget meow({Color? color, double size = 32}) => _build('cat', null, size);
  
  // Navigation Icons
  static Widget navHome({required bool isModern, Color? color, double size = 28}) => isModern ? Icon(FluentIcons.home_24_filled, color: color, size: size) : _build('dog-house', null, size);
  static Widget navHealth({required bool isModern, Color? color, double size = 28}) => isModern ? Icon(FluentIcons.heart_pulse_24_filled, color: color, size: size) : _build('pet-care', null, size);
  static Widget navCare({required bool isModern, Color? color, double size = 28}) => isModern ? Icon(FluentIcons.animal_cat_24_filled, color: color, size: size) : _build('grooming', null, size);
  static Widget navStats({required bool isModern, Color? color, double size = 28}) => isModern ? Icon(FluentIcons.data_bar_vertical_24_filled, color: color, size: size) : _build('shopping-bag', null, size);
  static Widget navAlbum({required bool isModern, Color? color, double size = 28}) => isModern ? Icon(FluentIcons.library_24_filled, color: color, size: size) : _build('kitten', null, size);

  // Health & Care specific Icons
  static Widget vaccine({Color? color, double size = 24}) => Text('💉', style: TextStyle(fontSize: size));
  static Widget calendar({Color? color, double size = 24}) => Text('📅', style: TextStyle(fontSize: size));
  static Widget medication({Color? color, double size = 24}) => Text('💊', style: TextStyle(fontSize: size));
  static Widget delete({Color? color, double size = 24}) => Icon(Icons.delete_outline_rounded, color: color, size: size);
  static Widget paw({Color? color, double size = 24}) => _build('cat', color, size);
  static Widget add({Color? color, double size = 24}) => Icon(Icons.add_rounded, color: color, size: size);
}
