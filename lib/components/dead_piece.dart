import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeadPiece extends StatelessWidget {
  const DeadPiece({Key? key, required this.imagePath, required this.isWhite}) : super(key: key);

  final String imagePath;
  final bool isWhite;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: Image.asset(
        imagePath,
        color: isWhite ? Colors.white : Colors.black,
      ),
    );
  }
}