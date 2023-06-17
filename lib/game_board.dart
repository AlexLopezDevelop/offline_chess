import 'package:flutter/material.dart';
import 'package:offlinechess/components/dead_piece.dart';
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

  // a list of white and black pieces that have been captured
  List<ChessPiece> whiteCapturedPieces = [];
  List<ChessPiece> blackCapturedPieces = [];

  // a boolean to keep track of whose turn it is
  bool isWhiteTurn = true;

  // initial position of king (keep track of this to make it easier later to see if king is in check)
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;

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
      // no piece selected yet, this is the first selection
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedPieceRow = row;
          selectedPieceCol = col;
        }
      } else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedPieceRow = row;
        selectedPieceCol = col;
      } else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        _movePiece(row, col);
      }

      validMoves = _calculateRealValidMoves(
          col: selectedPieceCol, row: selectedPieceRow, piece: selectedPiece!, checkSimulation: true);
    });
  }

  List<List<int>> _calculateRawValidMoves(
      {required int row, required int col, required ChessPiece? piece}) {
    List<List<int>> validMoves = [];

    if (piece == null) {
      return [];
    }

    int direction = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
        // pawn can move forward if the square is empty
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          validMoves.add([row + direction, col]);
        }

        //pawn can move two squares forward if it is in its starting position
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            validMoves.add([row + 2 * direction, col]);
          }
        }

        // pawn can kill diagonally
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          validMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          validMoves.add([row + direction, col + 1]);
        }
        break;
      case ChessPieceType.rook:
        // horizontal and vertical directions
        final directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
        ];

        for (var direction in directions) {
          int newRow = row + direction[0];
          int newCol = col + direction[1];
          while (isInBoard(newRow, newCol)) {
            if (board[newRow][newCol] == null) {
              validMoves.add([newRow, newCol]);
            } else {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                validMoves.add([newRow, newCol]);
              }
              break;
            }
            newRow += direction[0];
            newCol += direction[1];
          }
        }
        break;
      case ChessPieceType.knight:
        // all 8 possible moves
        final moves = [
          [-2, -1], // up 2 left 1
          [-2, 1], // up 2 right 1
          [-1, -2], // up 1 left 2
          [-1, 2], // up 1 right 2
          [1, -2], // down 1 left 2
          [1, 2], // down 1 right 2
          [2, -1], // down 2 left 1
          [2, 1], // down 2 right 1
        ];

        for (var move in moves) {
          final newRow = row + move[0];
          final newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              validMoves.add([newRow, newCol]); // kill
            }
            continue; // blocked
          }
          validMoves.add([newRow, newCol]);
        }
        break;
      case ChessPieceType.bishop:
        // diagonal directions
        final directions = [
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1], // down right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            final newRow = row + i * direction[0];
            final newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                validMoves.add([newRow, newCol]); // kill
              }
              break; // blocked
            }
            validMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.queen:
        // all 8 directions
        final directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1], // down right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            final newRow = row + i * direction[0];
            final newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                validMoves.add([newRow, newCol]); // kill
              }
              break; // blocked
            }
            validMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.king:
        // all 8 directions
        final directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1], // down right
        ];

        for (var direction in directions) {
          final newRow = row + direction[0];
          final newCol = col + direction[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              validMoves.add([newRow, newCol]); // kill
            }
            continue; // blocked
          }
          validMoves.add([newRow, newCol]);
        }
        break;
    }
    return validMoves;
  }

  List<List<int>> _calculateRealValidMoves({
      required int row, required int col, required ChessPiece piece, required bool checkSimulation}) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidatesMoves =
        _calculateRawValidMoves(row: row, col: col, piece: piece);

    if (checkSimulation) {
      for (var candidateMove in candidatesMoves) {
        final endRow = candidateMove[0];
        final endCol = candidateMove[1];

        if (simulateMoveIsSafe(piece, row, col, endRow, endCol)) {
          realValidMoves.add(candidateMove);
        }
      }
    } else {
      realValidMoves = candidatesMoves;
    }

    return realValidMoves;
  }

  void _movePiece(int newRow, int newCol) {
    // if new spot has an enemy piece
    if (board[newRow][newCol] != null) {
      final capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whiteCapturedPieces.add(capturedPiece);
      } else {
        blackCapturedPieces.add(capturedPiece);
      }
    }

    // check if the piece begin moved is a king
    if (selectedPiece!.type == ChessPieceType.king) {
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }

    board[newRow][newCol] = selectedPiece;
    board[selectedPieceRow][selectedPieceCol] = null;

    // see if kings are in check
    if (_isKingInCheck(isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    // clear selection
    setState(() {
      selectedPiece = null;
      selectedPieceRow = -1;
      selectedPieceCol = -1;
      validMoves = [];
    });

    // check if it is checkmate
    if (isCheckMate(!isWhiteTurn)) {
      showDialog(context: context, builder: (context) => AlertDialog(
        title: const Text('Checkmate!'),
        content: Text('Winner is ${isWhiteTurn ? 'Black' : 'White'}'),
        actions: [
          TextButton(onPressed: () {
            Navigator.of(context).pop();
            resetBoard();
          }, child: const Text('Play Again'))
        ],
      ));
    }

    // change turn
    isWhiteTurn = !isWhiteTurn;
  }

  bool _isKingInCheck(bool isWhiteKing) {
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

    // check if any enemy piece can kill king
    for (var row = 0; row < kBoardWidth; row++) {
      for (var col = 0; col < kBoardWidth; col++) {
        if (board[row][col] == null ||
            board[row][col]!.isWhite != isWhiteKing) {
          continue;
        }

        List<List<int>> moves = _calculateRealValidMoves(
            row: row, col: col, piece: board[row][col]!, checkSimulation: false);

        // check if the king position is in this piece valid moves
        if (moves.any((element) =>
            element[0] == kingPosition[0] && element[1] == kingPosition[1])) {
          return true;
        }
      }
    }
    return false;
  }

  bool simulateMoveIsSafe(ChessPiece piece, int startRow, int startCol, int endRow, int endCol) {
    // save current the current board state
    ChessPiece? originalDestinationPiece = board[endRow][endCol];

    List<int>? originalKingPosition;

    // if the piece is the king, save it's position and update new one
    if (piece.type == ChessPieceType.king) {
      originalKingPosition =
      piece.isWhite ? whiteKingPosition : blackKingPosition;

      // update king position
      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }

      // simulate move
      board[endRow][endCol] = piece;
      board[startRow][startCol] = null;

      // check if our king is under attack
      bool kingInCheck = _isKingInCheck(piece.isWhite);

      // restore board to original state
      board[startRow][startCol] = piece;
      board[endRow][endCol] = originalDestinationPiece;

      // if the piece was the king, restore it original position
      if (piece.type == ChessPieceType.king) {
        if (piece.isWhite) {
          whiteKingPosition = originalKingPosition!;
        } else {
          blackKingPosition = originalKingPosition!;
        }
      }

    return !kingInCheck;
  }

  bool isCheckMate(bool isWhiteKing) {
    if (!_isKingInCheck(isWhiteKing)) {
      return false;
    }

    // if there at least one move that is safe, it's not checkmate
    for (int i = 0; i < kBoardWidth; i++) {
      for (int j = 0; j < kBoardWidth; j++) {
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }

        List<List<int>> moves = _calculateRealValidMoves(
            row: i, col: j, piece: board[i][j]!, checkSimulation: true);

        if (moves.isNotEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  void resetBoard() {
    _initBoard();
    checkStatus = false;
    whiteCapturedPieces.clear();
    blackCapturedPieces.clear();
    whiteKingPosition = [0, 4];
    blackKingPosition = [7, 4];
    isWhiteTurn = true;
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kBackgroundColor,
        body: Column(
          children: [
            // white pieces taken
            Expanded(
                child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 8),
                    itemCount: whiteCapturedPieces.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => DeadPiece(
                          imagePath: whiteCapturedPieces[index].imagePath,
                          isWhite: true,
                        ))),
            Text(checkStatus ? 'Check!' : ''),
            Expanded(
              flex: 3,
              child: GridView.builder(
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
                  }),
            ),
            Expanded(
                child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 8),
                    itemCount: blackCapturedPieces.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => DeadPiece(
                          imagePath: blackCapturedPieces[index].imagePath,
                          isWhite: false,
                        ))),
          ],
        ));
  }
}
