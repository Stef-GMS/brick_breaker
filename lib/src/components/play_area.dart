import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'package:brick_breaker/src/brick_breaker.dart';

// In the game of Breakout, the ball bounces off the walls
// of the play area.

class PlayArea extends RectangleComponent with HasGameReference<BrickBreaker> {
  PlayArea()
      : super(
          paint: Paint()..color = const Color(0xfff2e8cf),
          children: [
            // Adding a RectangleHitbox component as a child of the
            // RectangleComponent will construct a hit box for
            // collision detection that matches the size of the
            // RectangleHitbox called relative for times when you
            // want a hitbox that is smaller, or larger, than the
            // parent component.
            RectangleHitbox(),
          ],
        );

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    size = Vector2(
      game.width,
      game.height,
    );
  }
}
