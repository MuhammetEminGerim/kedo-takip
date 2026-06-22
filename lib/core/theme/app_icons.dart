import 'package:flutter/material.dart';

class AppIcons {
  // Helper to build icon from asset — no color tinting (icons have white bg)
  static Widget _build(String assetName, Color? color, double size) {
    return Image.asset(
      'assets/icons/$assetName',
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.broken_image_outlined,
        size: size,
        color: color ?? const Color(0xFF594236),
      ),
    );
  }

  // ── Navigation Bar ──
  static Widget navHome({Color? color, double size = 28}) => _build('nav_home.png', color, size);
  static Widget navRecord({Color? color, double size = 28}) => _build('nav_record.png', color, size);
  static Widget navCare({Color? color, double size = 28}) => _build('nav_care.png', color, size);
  static Widget navStats({Color? color, double size = 28}) => _build('nav_stats.png', color, size);
  static Widget navLearn({Color? color, double size = 28}) => _build('nav_learn.png', color, size);

  // ── Dashboard Quick Actions ──
  static Widget mic({Color? color, double size = 32}) => _build('nav_record.png', color, size);
  static Widget bowl({Color? color, double size = 32}) => _build('care_food.png', color, size);
  static Widget litter({Color? color, double size = 32}) => _build('care_litter.png', color, size);
  static Widget water({Color? color, double size = 32}) => _build('care_water.png', color, size);
  static Widget meow({Color? color, double size = 32}) => _build('care_mood.png', color, size);

  // ── Care Screen ──
  static Widget careFood({Color? color, double size = 32}) => _build('care_food.png', color, size);
  static Widget careWater({Color? color, double size = 32}) => _build('care_water.png', color, size);
  static Widget careLitter({Color? color, double size = 32}) => _build('care_litter.png', color, size);
  static Widget careMood({Color? color, double size = 32}) => _build('care_mood.png', color, size);
  static Widget careWeight({Color? color, double size = 32}) => _build('care_weight.png', color, size);

  // ── Mood Faces ──
  static Widget moodVeryHappy({Color? color, double size = 32}) => _build('mood_very_happy.png', color, size);
  static Widget moodHappy({Color? color, double size = 32}) => _build('mood_happy.png', color, size);
  static Widget moodNeutral({Color? color, double size = 32}) => _build('mood_neutral.png', color, size);
  static Widget moodSad({Color? color, double size = 32}) => _build('mood_sad.png', color, size);
  static Widget moodAngry({Color? color, double size = 32}) => _build('mood_angry.png', color, size);

  // ── Record Context Tags ──
  static Widget tagBeforeMeal({Color? color, double size = 20}) => _build('tag_before_meal.png', color, size);
  static Widget tagAfterPlay({Color? color, double size = 20}) => _build('tag_after_play.png', color, size);
  static Widget tagNight({Color? color, double size = 20}) => _build('tag_night.png', color, size);
  static Widget tagAtDoor({Color? color, double size = 20}) => _build('tag_at_door.png', color, size);
  static Widget tagAlone({Color? color, double size = 20}) => _build('tag_alone.png', color, size);
  static Widget tagOther({Color? color, double size = 20}) => _build('tag_other.png', color, size);

  // ── Training ──
  static Widget trainSit({Color? color, double size = 32}) => _build('train_sit.png', color, size);
  static Widget trainCome({Color? color, double size = 32}) => _build('train_come.png', color, size);
  static Widget trainHighFive({Color? color, double size = 32}) => _build('train_high_five.png', color, size);
  static Widget trainCarrier({Color? color, double size = 32}) => _build('train_carrier.png', color, size);

  // ── General UI ──
  static Widget settings({Color? color, double size = 24}) => _build('icon_settings.png', color, size);
  static Widget camera({Color? color, double size = 24}) => _build('icon_camera.png', color, size);
  static Widget gallery({Color? color, double size = 24}) => _build('icon_gallery.png', color, size);
  static Widget play({Color? color, double size = 24}) => _build('icon_play.png', color, size);
  static Widget stop({Color? color, double size = 24}) => _build('icon_stop.png', color, size);
  static Widget delete({Color? color, double size = 24}) => _build('icon_delete.png', color, size);
  static Widget add({Color? color, double size = 24}) => _build('icon_add.png', color, size);
  static Widget streak({Color? color, double size = 24}) => _build('icon_streak.png', color, size);
}
