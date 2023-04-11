import 'dart:math' as math;

import 'package:chess_4p/chess_4p.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_4p/flutter_4p_chess.dart';

/// Creates a chess piece animation that flips vertically and then horizontally
/// and each time changes its displayed chess piece
class ChessLoadingAnimation extends StatefulWidget {
  /// Size of the whole square containing the animation.
  ///
  /// Default size is set to [50].
  final double size;

  /// Total duration for one cycle of animation.
  ///
  /// Default value is set to 1.5 seconds
  final Duration duration;

  /// Where to get the chess pieces from,
  /// only the [Direction.up] pieces will be used.
  final PlayerStyles pieces;

  /// Default constructor
  const ChessLoadingAnimation({
    super.key,
    this.size = 50,
    this.duration = const Duration(milliseconds: 1500),
    required this.pieces,
  });

  @override
  ChessLoadingAnimationState createState() => ChessLoadingAnimationState();
}

class ChessLoadingAnimationState extends State<ChessLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late final List<Widget> widgets;

  Widget get _currentWidget => widgets[_widgetIndex];

  var _widgetIndex = 0;

  void _setNextWidgetIndex() {
    if (_widgetIndex == 5) {
      _widgetIndex = 0;
    } else {
      _widgetIndex++;
    }
  }

  var _lastAnimationQuarter = 0;

  void _updateWidgetIndex(double animation) {
    final currentAnimationQuarter = (animation * 4).toInt();
    if (_lastAnimationQuarter != currentAnimationQuarter) {
      if (currentAnimationQuarter == 1 || currentAnimationQuarter == 3) {
        _setNextWidgetIndex();
      }
    }
    _lastAnimationQuarter = currentAnimationQuarter;
  }

  @override
  void initState() {
    super.initState();
    widgets = List.generate(6, (index) {
      return widget.pieces.createPiece(PieceType.values[index], Direction.up);
    });
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller.view,
        builder: (context, child) {
          final value = _controller.value;
          var x = 0.0;
          var y = 0.0;
          var switchTransform = false;
          if (value <= 0.25) {
            x = math.pi * value * 2;
          } else if (value <= 0.5) {
            x = math.pi * (0.5 - value) * 2;
            switchTransform = true;
          } else if (value <= 0.75) {
            y = math.pi * (value - 0.5) * 2;
            switchTransform = true;
          } else {
            y = math.pi * (1 - value) * 2;
          }
          final Matrix4 transform = Matrix4.identity()
            ..setEntry(switchTransform ? 3 : 2, switchTransform ? 2 : 3, 0.005)
            ..rotateX(x)
            ..rotateY(y);

          _updateWidgetIndex(value);
          return Transform(
            transform: transform,
            alignment: FractionalOffset.center,
            child: SizedBox.fromSize(
              size: Size.square(widget.size),
              child: _currentWidget,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
