import 'package:flutter/material.dart';
import 'package:offlinechess/components/piece.dart';
import 'package:offlinechess/values/colors.dart';

import '../game_board.dart';

class Square extends StatelessWidget {
  const Square({super.key, required this.index, required this.piece, required this.isSelected, required this.onTap});

  final int index;
  final ChessPiece? piece;
  final bool isSelected;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    Color? squareColor;

    if (isSelected) {
      squareColor = Colors.green;
    } else {
      if (index % 2 == 0) {
        if (index ~/ kBoardWidth % 2 == 0) {
          squareColor = kPrimaryColor;
        } else {
          squareColor = kSecondaryColor;
        }
      } else {
        if (index ~/ kBoardWidth % 2 == 0) {
          squareColor = kSecondaryColor;
        } else {
          squareColor = kPrimaryColor;
        }
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: squareColor,
        child: piece != null ? Padding(
          padding: const EdgeInsets.all(6.0),
          child: Image.asset(piece!.imagePath, color: piece!.isWhite ? Colors.white : Colors.black,),
        ) : null,
      ),
    );
  }
}
