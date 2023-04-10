import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';

import 'chess_icons.dart';

IconData iconDataFromLoseReason(LoseReason reason) {
  switch (reason) {
    case LoseReason.resign:
      return Icons.flag;
    case LoseReason.remi:
      // TODO: better icon
      return Icons.hide_source;
    case LoseReason.checkmate:
      return ChessIcons.fallen_filled_king;
    case LoseReason.time:
      return Icons.hourglass_bottom;
  }
}