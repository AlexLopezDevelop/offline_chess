import 'package:flutter/material.dart';
import 'package:offlinechess/components/piece.dart';
import 'package:offlinechess/values/colors.dart';

class Square extends StatelessWidget {
  const Square({super.key, required this.index, required this.piece});

  final int index;
  final ChessPiece? piece;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: (index + index ~/ 8) % 2 == 0 ? kPrimaryColor : kSecondaryColor,
      child: piece != null ? Padding(
        padding: const EdgeInsets.all(6.0),
        child: Image.asset(piece!.imagePath, color: piece!.isWhite ? Colors.white : Colors.black,),
      ) : null,
    );
  }
}
