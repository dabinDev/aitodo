import 'package:flutter/material.dart';

var priorityColor = [Colors.red, Colors.orange, Colors.yellow, Colors.white];

class ColorPalette {
  final String colorName;
  final int colorValue;

  ColorPalette(this.colorName, this.colorValue);

  bool operator ==(o) =>
      o is ColorPalette &&
      o.colorValue == colorValue &&
      o.colorName == colorName;
}

var colorsPalettes = <ColorPalette>[
  ColorPalette("红色", Colors.red.value),
  ColorPalette("粉色", Colors.pink.value),
  ColorPalette("紫色", Colors.purple.value),
  ColorPalette("深紫色", Colors.deepPurple.value),
  ColorPalette("靛蓝色", Colors.indigo.value),
  ColorPalette("蓝色", Colors.blue.value),
  ColorPalette("浅蓝色", Colors.lightBlue.value),
  ColorPalette("青色", Colors.cyan.value),
  ColorPalette("青绿色", Colors.teal.value),
  ColorPalette("绿色", Colors.green.value),
  ColorPalette("浅绿色", Colors.lightGreen.value),
  ColorPalette("柠檬色", Colors.lime.value),
  ColorPalette("黄色", Colors.yellow.value),
  ColorPalette("琥珀色", Colors.amber.value),
  ColorPalette("橙色", Colors.orange.value),
  ColorPalette("深橙色", Colors.deepOrange.value),
  ColorPalette("棕色", Colors.brown.value),
  ColorPalette("黑色", Colors.black.value),
  ColorPalette("灰色", Colors.grey.value),
];
