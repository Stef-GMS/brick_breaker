import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'package:brick_breaker/src/brick_breaker.dart';
import 'package:brick_breaker/src/config.dart';
import 'package:brick_breaker/src/components/ball.dart';
import 'package:brick_breaker/src/components/bat.dart';

class Brick extends RectangleComponent
    with //
        CollisionCallbacks,
        HasGameReference<BrickBreaker> {
  Brick({required super.position, required Color color})
      : super(
          size: Vector2(
            brickWidth,
            brickHeight,
          ),
          anchor: Anchor.center,
          paint: Paint()
            ..color = color
            ..style = PaintingStyle.fill,
          children: [
            RectangleHitbox(),
          ],
        );

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(
      intersectionPoints,
      other,
    );
    removeFromParent();

    // The win condition check queries the world for bricks,
    // and confirms that only one remains.
    if (game.world.children.query<Brick>().length == 1) {
      // if the player can break all the bricks,
      // they have earned a "game won" screen.
      game.playState = PlayState.won;

      // component removal is a queued command. It removes
      // the brick after this code runs, but before the next
      // tick of the game world.
      game.world.removeAll(game.world.children.query<Ball>());
      game.world.removeAll(game.world.children.query<Bat>());
    }
  }
}
