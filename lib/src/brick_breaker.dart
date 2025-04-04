import 'dart:async';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:brick_breaker/src/components/components.dart';
import 'package:brick_breaker/src/config.dart';

// Captures where the player is in entering, playing,
// and either losing or winning the game.
enum PlayState {
  welcome,
  playing,
  gameOver,
  won,
}

// This file coordinates the game's actions. During construction
// of the game instance, this code configures the game to use
// fixed resolution rendering. The game resizes to fill the
// screen that contains it and adds letterboxing as required.

class BrickBreaker extends FlameGame
    with
        // HasCollisionDetection tracks the hitboxes of components
        // and triggers collision callbacks on every game tick
        HasCollisionDetection,
        KeyboardEvents,
        TapDetector {
  BrickBreaker()
      : super(
          // expose the width and height of the game so
          // that the children components,
          camera: CameraComponent.withFixedResolution(
            width: gameWidth,
            height: gameHeight,
          ),
        );

  final ValueNotifier<int> score = ValueNotifier(0);
  final rand = math.Random();
  double get width => size.x;
  double get height => size.y;

  //  instantiate enum as a hidden state with matching getters
  //  and setters.
  late PlayState _playState;

  // These getters and setters enable modifying
  // overlays when the various parts of the game
  // trigger play state transitions.
  PlayState get playState => _playState;

  set playState(PlayState playState) {
    _playState = playState;

    switch (playState) {
      case PlayState.welcome:
      case PlayState.gameOver:
      case PlayState.won:
        overlays.add(playState.name);
      case PlayState.playing:
        overlays.remove(PlayState.welcome.name);
        overlays.remove(PlayState.gameOver.name);
        overlays.remove(PlayState.won.name);
    }
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    // Configures the top left as the anchor for the viewfinder.
    // By default, the viewfinder uses the middle of the area as
    // the anchor for (0,0).
    camera.viewfinder.anchor = Anchor.topLeft;

    // Adds the PlayArea to the world. The world represents the
    // game world. It projects all of its children through the
    // CameraComponents view transformation.
    //
    // Warning: You can add Components as children of the FlameGame
    // directly. If you do, instead of adding them as children of
    // the world component, then CameraComponent won't transform
    // those Components. This may confuse you and your app's players
    // when resizing the window doesn't behave how you expect.
    world.add(PlayArea());

    playState = PlayState.welcome;
  }

  void startGame() {
    if (playState == PlayState.playing) return;

    world.removeAll(world.children.query<Ball>());
    world.removeAll(world.children.query<Bat>());
    world.removeAll(world.children.query<Brick>());

    playState = PlayState.playing;
    score.value = 0;

    // Add the Ball component to the world. To set the
    // ball's position to the center of the display area, the code
    // first halves the size of the game, as Vector2 has operator
    // overloads (* and /) to scale a Vector2 by a scalar value.
    //
    // Call to normalized creates a Vector2 object set to the same
    // direction as the original Vector2, but scaled down to a
    // distance of 1. This keeps the speed of the ball consistent
    // no matter which direction the ball goes. The ball's velocity
    // is then scaled up to be a 1/4 of the height of the game.
    world.add(
      Ball(
        difficultyModifier: difficultyModifier,
        radius: ballRadius,
        position: size / 2,
        velocity: Vector2(
          (rand.nextDouble() - 0.5) * width,
          height * 0.2,
        ).normalized()
          ..scale(height / 4),
      ),
    );

    // adds the bat to the game world in the appropriate
    // position and with the right proportions
    world.add(
      Bat(
        size: Vector2(batWidth, batHeight),
        cornerRadius: const Radius.circular(ballRadius / 2),
        position: Vector2(
          width / 2,
          height * 0.95,
        ),
      ),
    );

    // Add the bricks to make a brick wall
    world.addAll(
      [
        // Add from here...
        for (var i = 0; i < brickColors.length; i++)
          for (var j = 1; j <= 5; j++)
            Brick(
              position: Vector2(
                (i + 0.5) * brickWidth + (i + 1) * brickGutter,
                (j + 2.0) * brickHeight + j * brickGutter,
              ),
              color: brickColors[i],
            ),
      ],
    );

    // Turn on the debugging display, which adds additional
    // information to the display to help with debugging.
    //debugMode = true;
  }

  @override // Add from here...
  void onTap() {
    super.onTap();
    startGame();
  } // To here.

  // The addition of the KeyboardEvents mixin and the overridden
  // onKeyEvent method handle the keyboard input.
  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(
      event,
      keysPressed,
    );

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        world.children.query<Bat>().first.moveBy(-batStep);
      case LogicalKeyboardKey.arrowRight:
        world.children.query<Bat>().first.moveBy(batStep);
      case LogicalKeyboardKey.space: // Add from here...
      case LogicalKeyboardKey.enter:
        startGame();
    }
    return KeyEventResult.handled;
  }

  @override
  Color backgroundColor() => const Color(0xfff2e8cf);
}
