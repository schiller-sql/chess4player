import 'package:chess44/blocs/participants_count/participants_count_cubit.dart';
import 'package:chess44/theme/chess_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chess_4p/flutter_4p_chess.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

class WhichPlayersInRoomDisplay extends StatelessWidget {
  const WhichPlayersInRoomDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: EmptyChessBoard(
        color1: NordColors.$3,
        color2: NordColors.$2,
        child: BlocBuilder<ParticipantsCountCubit, int>(
          builder: (context, count) {
            List<bool> playersPlaying = List.generate(4, (index) => false);
            if (count == 2) {
              playersPlaying[0] = true;
              playersPlaying[2] = true;
            } else {
              for (var i = 0; i < count; i++) {
                playersPlaying[i] = true;
              }
            }
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 750),
              child: Stack(
                key: ValueKey(count),
                children: [
                  for (var i = 0; i < 4; i++)
                    if (playersPlaying[i])
                      RotatedBox(
                        quarterTurns: i,
                        child: Align(
                          alignment: const Alignment(0, 0.65),
                          child: Icon(
                            Icons.arrow_upward_sharp,
                            size: 90,
                            color: baseColors.getFromInt(i),
                          ),
                        ),
                      ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
