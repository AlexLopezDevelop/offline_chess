import 'package:flutter/material.dart';
import 'package:offlinechess/components/piece.dart';
import 'package:offlinechess/values/colors.dart';

import '../game_board.dart';

class Square extends StatelessWidget {
  const Square(
      {super.key,
      required this.index,
      required this.piece,
      required this.isSelected,
      required this.onTap,
      required this.isValidMove});

  final int index;
  final ChessPiece? piece;
  final bool isSelected;
  final bool isValidMove;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    Color? squareColor;

    // if the square is selected, highlight it
    if (isSelected) {
      squareColor = Colors.green;
    } else if (isValidMove) {
      squareColor = Colors.green[200];
    } else {
      // if the square is not selected, color it according to its position
      // on the board
      if (index % 2 == 0) {
        if (index ~/ kBoardWidth % 2 == 0) {
          squareColor = kBackgroundColor;
        } else {
          squareColor = kPrimaryColor;
        }
      } else {
        if (index ~/ kBoardWidth % 2 == 0) {
          squareColor = kPrimaryColor;
        } else {
          squareColor = kBackgroundColor;
        }
      }
    }

    // update with isValidMove

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: isValidMove ? const EdgeInsets.all(10) : null,
        decoration: isValidMove
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: squareColor,
              )
            : BoxDecoration(color: squareColor),
        child: piece != null
            ? Padding(
                padding: const EdgeInsets.all(6.0),
                child: Image.asset(
                  piece!.imagePath,
                  color: piece!.isWhite ? Colors.white : Colors.black,
                ),
              )
            : null,
      ),
    );
  }
}
