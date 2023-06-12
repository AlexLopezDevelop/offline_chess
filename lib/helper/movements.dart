import 'package:offlinechess/game_board.dart';

bool isInBoard(int row, int col) {
  return row >= 0 && row < kBoardWidth && col >= 0 && col < kBoardWidth;
}