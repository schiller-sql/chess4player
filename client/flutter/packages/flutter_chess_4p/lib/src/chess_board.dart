import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_4p/src/accessible_positions_painter.dart';
import 'package:chess_4p/chess_4p.dart';

import 'chess_board_painter.dart';
import 'domain/chess_board_color_style.dart';
import 'domain/player_styles.dart';
import 'lose_icons.dart';
import 'seconds_countdown_timer.dart';
import 'duration_simple_format_extension.dart';

class ChessBoard extends StatefulWidget {
  final PlayerStyles playerStyles;
  final ChessBoardColorStyle colorStyle;
  final IChessGameRepository chessGameRepository;

  const ChessBoard({
    Key? key,
    required this.playerStyles,
    this.colorStyle = const ChessBoardColorStyle(),
    required this.chessGameRepository,
  }) : super(key: key);

  @override
  State<ChessBoard> createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard>
    with DefaultChessGameRepositoryListener {
  IChessGameRepository get repo => widget.chessGameRepository;
  ReadableBoard get board => repo.board;
  BoardAnalyzer get boardAnalyzer => repo.boardAnalyzer;

  @override
  void initState() {
    super.initState();
    for (Player? player in repo.players) {
      if (player != null) {
        _playerTimeNotifiers[player.name] = ValueNotifier(repo.game.time);
      }
    }
    repo.addListener(this);
  }

  @override
  void dispose() {
    super.dispose();
    repo.removeListener(this);
  }

  Set<Field> selectableFields = {};

  Field? selectedField;

  void tapOwnPiece(Field field) {
    setState(() {
      if (field == selectedField) {
        selectedField = null;
      } else {
        selectedField = field;
      }
      if (selectedField == null ||
          !boardAnalyzer.canAnalyze(selectedField!.x, selectedField!.y)) {
        selectableFields = {};
      } else {
        selectableFields =
            boardAnalyzer.accessibleFields(selectedField!.x, selectedField!.y);
      }
    });
  }

  void movePiece(int toX, int toY) {
    final to = Field(toX, toY);
    if (selectableFields.contains(to) && repo.canMove) {
      setState(() {
        if (repo.moveIsPromotion(selectedField!, to)) {
          promotionCandidate = to;
        } else {
          repo.move(selectedField!, to);
          selectedField = null;
        }
        selectableFields = {};
      });
    }
  }

  void cancelPromotion() {
    setState(() {
      selectedField = null;
      promotionCandidate = null;
    });
  }

  void executePromotion(PieceType pieceType) {
    setState(() {
      repo.move(selectedField!, promotionCandidate!, pieceType);
      promotionCandidate = null;
      selectedField = null;
    });
  }

  Field? promotionCandidate;

  bool get doingPromotion => promotionCandidate != null;

  Widget chessFieldItemBuilder(int x, int y) {
    Widget? child;
    if (!board.isEmpty(x, y)) {
      final piece = board.getPiece(x, y);
      child = widget.playerStyles.createPiece(
        piece.type,
        piece.isDead ? null : piece.direction,
      );
    }
    if (selectedField?.x == x && selectedField?.y == y) {
      child = ColoredBox(
        color: widget.colorStyle.selectedFieldColor,
        child: child,
      );
    }
    if (boardAnalyzer.canAnalyze(x, y)) {
      child = GestureDetector(
        onTapDown: (_) {
          final field = Field(x, y);
          tapOwnPiece(field);
        },
        onTap: () {},
        child: child,
      );
    } else {
      child = GestureDetector(
        onTap: () {
          movePiece(x, y);
        },
        child: child,
      );
    }
    return child;
  }

  Widget _buildPromotionDialogSection({
    required Widget child,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          shape: MaterialStateProperty.all(
            const ContinuousRectangleBorder(),
          ),
          overlayColor: MaterialStateProperty.all(
            Colors.transparent,
          ),
          backgroundColor: MaterialStateProperty.resolveWith(
            (states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.yellow;
              }
              if (states.contains(MaterialState.focused) ||
                  states.contains(MaterialState.hovered)) {
                return Colors.green;
              }
              return null;
            },
          ),
          foregroundColor: MaterialStateProperty.all(Colors.black),
        ),
        child: child,
      ),
    );
  }

  Widget _buildPromotionDialog() {
    Field f = promotionCandidate!;
    return SizedBox.expand(
      child: GestureDetector(
        onTap: cancelPromotion,
        child: ColoredBox(
          color: Colors.black.withAlpha(100), // TODO: not over chess pieces...
          child: Align(
            alignment: FractionalOffset(f.x / 13, (f.y - 4) / (14 - 5)),
            child: FractionallySizedBox(
              widthFactor: 1 / 14,
              heightFactor: 5 / 14,
              child: ColoredBox(
                color: Colors.blueAccent,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPromotionDialogSection(
                      child: const Icon(
                        Icons.close,
                        size: 32,
                      ),
                      onPressed: cancelPromotion,
                    ),
                    for (final pieceType in const [
                      PieceType.knight,
                      PieceType.bishop,
                      PieceType.rook,
                      PieceType.queen
                    ])
                      _buildPromotionDialogSection(
                        child: SizedBox.expand(
                          child: widget.playerStyles.createPiece(
                            pieceType,
                            Direction.up,
                          ),
                        ),
                        onPressed: () => executePromotion(pieceType),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: AccessiblePositionsPainter(selectableFields),
      painter: ChessBoardPainter(
        backgroundTileColor2: widget.colorStyle.fieldColor1,
        backgroundTileColor1: widget.colorStyle.fieldColor2,
        backgroundColor: widget.colorStyle.backgroundColor,
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            for (var playerIndex = 0; playerIndex < 4; playerIndex++)
              _buildPlayerDisplay(playerIndex),
            IgnorePointer(
              ignoring: doingPromotion,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 14 * 14,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 14),
                itemBuilder: (context, i) =>
                    chessFieldItemBuilder(i % 14, i ~/ 14),
              ),
            ),
            if (doingPromotion) _buildPromotionDialog(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerDisplay(int playerIndex) {
    final player = repo.playersFromOwnPerspective[playerIndex];
    if (player == null) {
      return const SizedBox();
    }
    final playerName = player.name;
    final notifier = _playerTimeNotifiers[playerName]!;
    final playerDirection = Direction.fromInt(playerIndex);
    var backgroundColor = widget.playerStyles.getPlayerColor(playerDirection);
    var color = widget.playerStyles.getPlayerAccentColor(playerDirection);
    if (!player.isOnTurn) {
      final tempBackgroundColor = backgroundColor;
      backgroundColor = color.withAlpha(180);
      color = tempBackgroundColor.withAlpha(100);
    }
    if (player.hasLost) {
      backgroundColor = widget.colorStyle.inactiveBaseTextColor ??
          widget.playerStyles.getPlayerColor(null);
      color = widget.colorStyle.inactiveAccentTextColor ??
          widget.playerStyles.getPlayerAccentColor(null).withAlpha(200);
    }
    final isOnTopOfBoard = playerIndex == 1 || playerIndex == 2;
    final isLeftOfBoard = playerIndex <= 1;
    Widget nameDisplay = Text(
      player.name,
      style: TextStyle(
        color: backgroundColor,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
    );
    if (player.hasLost) {
      Widget icon = Icon(
        iconDataFromLoseReason(player.lostReason!),
        color: backgroundColor,
        size: 24,
      );
      if (player.lostReason == LoseReason.checkmate) {
        icon = Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: icon,
        );
      }
      var nameDisplayChildren = [
        nameDisplay,
        const SizedBox(width: 4),
        icon,
      ];
      if (isLeftOfBoard) {
        nameDisplayChildren = nameDisplayChildren.reversed.toList();
      }
      nameDisplay = Row(
        mainAxisSize: MainAxisSize.min,
        children: nameDisplayChildren,
      );
    }
    var children = [
      nameDisplay,
      const SizedBox(height: 4),
      Container(
        width: 116,
        color: backgroundColor,
        padding: const EdgeInsets.all(8),
        child: AnimatedBuilder(
          animation: notifier,
          builder: (context, child) {
            return Wrap(
              children: [
                Icon(
                  Icons.schedule,
                  size: 28,
                  color: color,
                ),
                const SizedBox(width: 4),
                Text(
                  notifier.value.hoursAndMinutesFormat(),
                  style: TextStyle(
                    fontSize: 20,
                    color: color,
                    decoration: TextDecoration.none,
                    fontWeight: player.isOnTurn
                        ? FontWeight.w700
                        : (player.isOut ? FontWeight.w500 : FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ];
    if (!isOnTopOfBoard) {
      children = [...children.reversed];
    }
    return Align(
      alignment: _playerAlignments[playerIndex],
      child: FractionallySizedBox(
        widthFactor: 3 / 14,
        heightFactor: 3 / 14,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: isLeftOfBoard
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            mainAxisAlignment: isOnTopOfBoard
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }

  @override
  void changed(IChessGameRepository chessGameRepository) {
    setState(() {
      if (selectedField != null) {
        if (boardAnalyzer.canAnalyze(selectedField!.x, selectedField!.y)) {
          selectableFields = boardAnalyzer.accessibleFields(
              selectedField!.x, selectedField!.y);
        } else {
          selectedField = null;
          selectableFields = {};
        }
      }
    });
  }

  SecondsCountdownTimer? _lastTimer;

  final Map<String, ValueNotifier<Duration>> _playerTimeNotifiers = {};

  static final _playerAlignments = [
    Alignment.bottomLeft,
    Alignment.topLeft,
    Alignment.topRight,
    Alignment.bottomRight,
  ];

  @override
  void timerChange(String player, Duration duration, bool hasStarted) {
    final notifier = _playerTimeNotifiers[player]!;
    if (!hasStarted) {
      _lastTimer?.cancel();
      _lastTimer = null;
      notifier.value = duration;
    } else {
      assert(_lastTimer == null);
      _lastTimer = SecondsCountdownTimer(
        duration: duration,
        durationChanged: (countdownDuration) {
          notifier.value = countdownDuration;
        },
      );
    }
  }
}
