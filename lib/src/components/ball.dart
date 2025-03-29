import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import 'package:flutter/material.dart';

import 'package:brick_breaker/src/brick_breaker.dart';
import 'package:brick_breaker/src/components/bat.dart';
import 'package:brick_breaker/src/components/brick.dart';
import 'package:brick_breaker/src/components/play_area.dart';

class Ball extends CircleComponent
    with //
        CollisionCallbacks,
        HasGameReference<BrickBreaker> {
  Ball({
    required this.velocity,
    required super.position,
    required double radius,
    required this.difficultyModifier,
  }) : super(
          radius: radius,
          anchor: Anchor.center,
          paint: Paint()
            ..color = const Color(0xff1e6091)
            ..style = PaintingStyle.fill,
          children: [
            CircleHitbox(),
          ],
        );

  final Vector2 velocity;
  final double difficultyModifier;

  @override
  void update(double dt) {
    super.update(dt);
    // update a discrete simulation of motion over time
    position += velocity * dt;
  }

  // Flame's collision callbacks have a life cycle. The
  // callbacks are onCollisionStart, onCollision, and
  // onCollisionEnd. The initial version of this game
  // was written in terms of onCollision and required
  // additional code to handle follow-on collision
  // callbacks on later game ticks. Using the right
  // callback for the right purpose significantly
  // simplifies your code!
  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(
      intersectionPoints,
      other,
    );

    // Tests if the Ball collided with PlayArea.
    if (other is PlayArea) {
      if (intersectionPoints.first.y <= 0) {
        velocity.y = -velocity.y;
      } else if (intersectionPoints.first.x <= 0) {
        velocity.x = -velocity.x;
      } else if (intersectionPoints.first.x >= game.width) {
        velocity.x = -velocity.x;
      } else if (intersectionPoints.first.y >= game.height) {
        // removes the ball from the game world after letting
        // the ball exit the viewable play area.
        add(
          RemoveEffect(
            delay: 0.35,
            // Triggers the gameOver play state.
            onComplete: () {
              game.playState = PlayState.gameOver;
            },
          ),
        );
      }
    } else if (other is Bat) {
      // reverse the y component of the velocity
      velocity.y = -velocity.y;
      // updates the x component in a way that depends
      // on the relative position of the bat and ball
      // at the time of contact.
      velocity.x = velocity.x + //
          (position.x - other.position.x) / other.size.x * game.width * 0.3;
    } else if (other is Brick) {
      if (position.y < other.position.y - other.size.y / 2) {
        velocity.y = -velocity.y;
      } else if (position.y > other.position.y + other.size.y / 2) {
        velocity.y = -velocity.y;
      } else if (position.x < other.position.x) {
        velocity.x = -velocity.x;
      } else if (position.x > other.position.x) {
        velocity.x = -velocity.x;
      }
      //  difficulty modifier that increases the ball velocity
      //  after each brick collision
      velocity.setFrom(velocity * difficultyModifier);
    }
  }
}
