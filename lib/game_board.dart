import 'package:flutter/material.dart';
import 'package:offlinechess/components/piece.dart';
import 'package:offlinechess/components/square.dart';
import 'package:offlinechess/values/colors.dart';

const kBoardWidth = 8;

class GameBoard extends StatefulWidget {
  const GameBoard({Key? key}) : super(key: key);

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late List<List<ChessPiece?>> board;
  ChessPiece? selectedPiece;
  int selectedPieceRow = -1;
  int selectedPieceCol = -1;

  @override
  void initState() {
    super.initState();
    _initBoard();
  }

  void _initBoard() {
    List<List<ChessPiece?>> tempBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    // place pawns
    for (int i = 0; i < kBoardWidth; i++) {
      tempBoard[1][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: false,
          imagePath: 'assets/pieces/pawn.png');
      tempBoard[6][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: true,
          imagePath: 'assets/pieces/pawn.png');
    }

    // place rooks
    tempBoard[0][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'assets/pieces/rook.png');
    tempBoard[0][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'assets/pieces/rook.png');
    tempBoard[7][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'assets/pieces/rook.png');
    tempBoard[7][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'assets/pieces/rook.png');

    // place knights
    tempBoard[0][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'assets/pieces/knight.png');
    tempBoard[0][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'assets/pieces/knight.png');
    tempBoard[7][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'assets/pieces/knight.png');
    tempBoard[7][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'assets/pieces/knight.png');

    // place bishops
    tempBoard[0][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'assets/pieces/bishop.png');
    tempBoard[0][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'assets/pieces/bishop.png');
    tempBoard[7][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'assets/pieces/bishop.png');
    tempBoard[7][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'assets/pieces/bishop.png');

    // place queens
    tempBoard[0][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: false,
        imagePath: 'assets/pieces/queen.png');
    tempBoard[7][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: true,
        imagePath: 'assets/pieces/queen.png');

    // place kings
    tempBoard[0][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: false,
        imagePath: 'assets/pieces/king.png');
    tempBoard[7][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: true,
        imagePath: 'assets/pieces/king.png');

    board = tempBoard;
  }

  void _selectPiece(int row, int col) {
    setState(() {
      if (board[row][col] != null) {
        selectedPiece = board[row][col];
        selectedPieceRow = row;
        selectedPieceCol = col;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kBackgroundColor,
        body: GridView.builder(
            itemCount: kBoardWidth * kBoardWidth,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8),
            itemBuilder: (context, index) {
              int row = index ~/ kBoardWidth;
              int col = index % kBoardWidth;
              bool isSelected =
                  selectedPieceRow == row && selectedPieceCol == col;

              return Center(
                child: Square(
                  index: index,
                  piece: board[row][col],
                  isSelected: isSelected,
                  onTap: () => _selectPiece(row, col),
                ),
              );
            }));
  }
}
