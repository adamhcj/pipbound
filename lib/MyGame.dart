


import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pipstory/Platform.dart';

import 'Background.dart';
import 'Bubble.dart';
import 'Buttons.dart';
import 'Monster.dart';
import 'Player.dart';
import 'RareCandy.dart';

// Game
class MyGame extends FlameGame with KeyboardEvents, HasTappables , HasCollisionDetection {
  @override
  Color backgroundColor() => const Color(0x59A3F4FF);

  int candyCounter = 5;
  final TextComponent candyCounterText = TextComponent();
  late TextComponent angleControlText;
  late TextComponent powerControlText;
  late double power = 1000;


  final player = Player();
  final playerHitboxComponent = PlayerHitboxComponent();
  final angleControl = AngleControl();
  final powerBar = PowerBar();
  final powerBarBackground = PowerBarBackground();
  final cameraObject = CameraObject();
  final leftButton = LeftButton();
  final rightButton = RightButton();
  final upButton = UpButton();
  final downButton = DownButton();
  final spaceBar = SpaceBar();
  final cButton = CButton();
  final background = Background();
  final gravity = 10;

  // bubble list
  List<Bubble> bubbles = [];

  // keypresses
  static late bool isSpace = false;
  static late bool isLeft = false;
  static late bool isRight = false;
  static late bool isC = false;
  static late bool isUp = false;
  static late bool isDown = false;

  // for screen markers, setting the text format
  TextPaint textPaint = TextPaint(
    style: TextStyle(
      color: Color(0xFFFF0000),
      fontSize: 30,
    ),
  );

  // function to add markers in the world
  void addMarker(double x, double y) {
    String text = '$x, $y';
    // add(TextBoxComponent(text: text, position: Vector2(x, y)));
  }

  TextComponent addTextAt(String text, double x, double y) {
    TextComponent textComponent = TextComponent();
    textComponent.text = text;
    textComponent.position = Vector2(x, y);
    textComponent.textRenderer = textPaint;
    textComponent.priority = 5;
    add(textComponent);
    return textComponent;
  }

  void addPlatform(double x, double y, double width, double height) {
    Platform platform = Platform();
    platform.position = Vector2(x, y);
    platform.size = Vector2(width, height);
    addRareCandy(x, y-60);
    add(platform);
  }

  void addRareCandy(double x, double y) {
    RareCandy rareCandy = RareCandy();
    rareCandy.position = Vector2(x, y);
    rareCandy.priority = 1;
    add(rareCandy);
  }

  @override
  Future<void> onLoad() async {
    // initial world population


    leftButton.priority = 1;
    leftButton.positionType = PositionType.viewport;
    add(leftButton);

    rightButton.priority = 1;
    rightButton.positionType = PositionType.viewport;
    add(rightButton);

    upButton.priority = 1;
    upButton.positionType = PositionType.viewport;
    add(upButton);

    downButton.priority = 1;
    downButton.positionType = PositionType.viewport;
    add(downButton);

    spaceBar.priority = 1;
    spaceBar.positionType = PositionType.viewport;
    // add(spaceBar);

    cButton.priority = 1;
    cButton.positionType = PositionType.viewport;
    add(cButton);

    background.priority = -100;
    background.positionType = PositionType.viewport;
    add(background);

    addRareCandy(0, 0);
    // adds screen markers for reference
    // for (double i = 800; i <= 8000; i+=800) {
    //   for (double j = 0; j <= 1000; j+=200) {
    //     // addMarker(i, j);
    //     addPlatform(i, j, 400, 50);
    //   }
    // }
    addPlatform(0, 0, 900, 50);
    addPlatform(-900, 0, 900, 50);
    addPlatform(900, 0, 900, 50);

    // for (double i = 1; i <= 20; i++) {
    //   addPlatform(300*i, 250*-i, 80, 50);
    //   addPlatform(300*i, 500*-i, 80, 50);
    // }
    // for (double i = 1; i <= 20; i++) {
    //   // addMarker(300*-i, 250*-i);
    //   addPlatform(300*-i, 250*-i, 80, 50);
    // }

    // addPlatform(100, 1200, 1000, 50);


    addTextAt("Jump quest here! >>>", 20, -230);
    addTextAt("^ Jump quest on top! ^", 70, 900);

    addTextAt("Collect rare candies and grow stronger\nwith more bubble attacks! ", -250, -330);




    // candy counter component
    candyCounterText.text = 'Candy: 0';
    candyCounterText.textRenderer = textPaint;

    candyCounterText.priority = 1;
    candyCounterText.positionType = PositionType.viewport;

    // add(candyCounterText);

    angleControlText = addTextAt('angle: 0', 0, 100);
    angleControlText.priority = 1;
    angleControlText.positionType = PositionType.viewport;


    powerBar.priority = 1;
    powerBar.positionType = PositionType.viewport;
    add(powerBar);

    powerBarBackground.priority = 0;
    powerBarBackground.positionType = PositionType.viewport;
    add(powerBarBackground);

    powerControlText = addTextAt('power: 0', 0, 50);
    powerControlText.priority = 1;
    powerControlText.positionType = PositionType.viewport;

    player.priority = 1;
    add(player);
    add(playerHitboxComponent);
    add(angleControl);

    add(cameraObject);
    camera.followComponent(cameraObject);
    camera.zoom = 0.5;

    add(Monster());
    addTextAt("Enemy piplup for you to attack", 0, 0);

    FlameAudio.bgm.play('gbstart.mp3', volume: 0.3);



  }

  // on resize
  @override
  Future<void> onGameResize(Vector2 vector2) async {
    super.onGameResize(vector2);
    leftButton.onClientResize();
    rightButton.onClientResize();
    upButton.onClientResize();
    downButton.onClientResize();
    // spaceBar.onClientResize();
    cButton.onClientResize();
    background.onClientResize();

    if (canvasSize.y < 350) {
      camera.zoom = 0.3;
    }
    else if (canvasSize.y < 600) {
      camera.zoom = 0.5;
    }
    else {
      camera.zoom = 0.6;
    }

  }


  void addBubble(Vector2 location, Vector2 velocity, int number) {
    Bubble bubble = Bubble(number);
    bubble.position = location;
    bubble.velocity = velocity;
    bubble.priority = 1;
    bubbles.add(bubble);
    add(bubble);

    // destroy bubble after 6 seconds
    Future.delayed(Duration(milliseconds: 5000), () {
      if (bubble.current != BubbleState.splash) {
        remove(bubble);
        bubbles.remove(bubble);
      }

    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    // calls all the tick methods in all the objects
    player.tick(dt);
    cameraObject.tick(dt);
    powerControlText.text = "power: ${power.round()}";
    if (power >= 200 && !isC) {
      player.attack();
    }
    // leftButton.tick(dt);
    // rightButton.tick(dt);
    // spaceBar.tick(dt);
    // cButton.tick(dt);

    // iterate through monsters in game
    children.whereType<Monster>().forEach((monster) {
      monster.tick(dt);
    });

    // iterate through bubble list
    for (var bubble in bubbles) {
      bubble.tick(dt);
    }

    if (isLeft) {
      leftButton.current = LeftButtonState.pressed;
    } else {
      leftButton.current = LeftButtonState.unpressed;
    }
    if (isRight) {
      rightButton.current = RightButtonState.pressed;
    } else {
      rightButton.current = RightButtonState.unpressed;
    }
    if (isUp) {
      upButton.current = UpButtonState.pressed;
    } else {
      upButton.current = UpButtonState.unpressed;
    }
    if (isDown) {
      downButton.current = DownButtonState.pressed;
    } else {
      downButton.current = DownButtonState.unpressed;
    }
    if (isSpace) {
      spaceBar.current = SpaceBarState.pressed;
    } else {
      spaceBar.current = SpaceBarState.unpressed;
    }
    if (isC) {
      cButton.current = CButtonState.pressed;
    } else {
      cButton.current = CButtonState.unpressed;
    }

  }

  // on key event
  @override
  KeyEventResult onKeyEvent(
      RawKeyEvent event,
      Set<LogicalKeyboardKey> keysPressed,
      ) {
    final isKeyDown = event is RawKeyDownEvent;

    isSpace = keysPressed.contains(LogicalKeyboardKey.space);
    isLeft = keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    isRight = keysPressed.contains(LogicalKeyboardKey.arrowRight);
    isC = keysPressed.contains(LogicalKeyboardKey.keyC);
    isUp = keysPressed.contains(LogicalKeyboardKey.arrowUp);
    isDown = keysPressed.contains(LogicalKeyboardKey.arrowDown);

    // if (isSpace) {
    //   player.jump();
    // }
    // if (isLeft) {
    //   player.moveLeft();
    // }
    // if (isRight) {
    //   player.moveRight();
    // }
    //
    // if (isC) {
    //   player.attack();
    // }


    return KeyEventResult.handled;
  }


}
