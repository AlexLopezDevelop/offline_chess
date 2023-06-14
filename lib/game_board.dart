import 'package:flutter/material.dart';
import 'package:offlinechess/components/piece.dart';
import 'package:offlinechess/components/square.dart';
import 'package:offlinechess/helper/movements.dart';
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

  // list of a valids moves for the selected piece
  // each move is represented as a list of two elements row and col
  List<List<int>> validMoves = [];

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
      validMoves = _calculateValidMoves(
          col: selectedPieceCol, row: selectedPieceRow, piece: selectedPiece);
    });
  }

  List<List<int>> _calculateValidMoves(
      {required int row, required int col, required ChessPiece? piece}) {
    List<List<int>> validMoves = [];

    int direction = piece!.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
        // pawn can move forward if the square is empty
        if (isInBoard(row + direction, col) && board[row + direction][col] == null) {
          validMoves.add([row + direction, col]);
        }

        //pawn can move two squares forward if it is in its starting position
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null && board[row + direction][col] == null) {
            validMoves.add([row + 2 * direction, col]);
          }
        }

        // pawn can kill diagonally
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite) {
          validMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            !board[row + direction][col + 1]!.isWhite) {
          validMoves.add([row + direction, col + 1]);
        }
        break;
      case ChessPieceType.rook:
        break;
      case ChessPieceType.knight:
        break;

      case ChessPieceType.bishop:
        break;
      case ChessPieceType.queen:
        break;
      case ChessPieceType.king:
        break;
    }
    return validMoves;
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

              // check if square is a valid move
              bool isValidMove = false;
              for (var position in validMoves) {
                if (position[0] == row && position[1] == col) {
                  isValidMove = true;
                  break;
                }
              }

              return Center(
                child: Square(
                  index: index,
                  piece: board[row][col],
                  isSelected: isSelected,
                  isValidMove: isValidMove,
                  onTap: () => _selectPiece(row, col),
                ),
              );
            }));
  }
}
