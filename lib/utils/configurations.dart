import 'package:flutter/material.dart';

class CustomPageScrollPhysics extends ScrollPhysics {
  final double dragForce;

  const CustomPageScrollPhysics({required this.dragForce, ScrollPhysics? parent}) : super(parent: parent);

  @override
  CustomPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageScrollPhysics(dragForce: dragForce, parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    double delta = offset.sign * dragForce;
    return super.applyPhysicsToUserOffset(position, delta);
  }
}

