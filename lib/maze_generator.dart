import 'dart:math';

class Cell {
  final int row;
  final int col;
  bool topWall = true;
  bool rightWall = true;
  bool bottomWall = true;
  bool leftWall = true;
  bool visited = false;

  Cell(this.row, this.col);
}

class Maze {
  final int rows;
  final int cols;
  final List<List<Cell>> grid;

  Maze(this.rows, this.cols)
      : grid = List.generate(
          rows,
          (i) => List.generate(cols, (j) => Cell(i, j)),
        );

  void generate() {
    final random = Random();
    final stack = <Cell>[];
    final startCell = grid[0][0];
    startCell.visited = true;
    stack.add(startCell);

    while (stack.isNotEmpty) {
      final current = stack.last;
      final neighbors = _getUnvisitedNeighbors(current);

      if (neighbors.isEmpty) {
        stack.removeLast();
      } else {
        final next = neighbors[random.nextInt(neighbors.length)];
        _removeWall(current, next);
        next.visited = true;
        stack.add(next);
      }
    }
  }

  List<Cell> _getUnvisitedNeighbors(Cell cell) {
    final neighbors = <Cell>[];
    final directions = [
      [-1, 0], // top
      [0, 1],  // right
      [1, 0],  // bottom
      [0, -1], // left
    ];

    for (final dir in directions) {
      final newRow = cell.row + dir[0];
      final newCol = cell.col + dir[1];

      if (newRow >= 0 &&
          newRow < rows &&
          newCol >= 0 &&
          newCol < cols &&
          !grid[newRow][newCol].visited) {
        neighbors.add(grid[newRow][newCol]);
      }
    }

    return neighbors;
  }

  void _removeWall(Cell current, Cell next) {
    final dx = next.col - current.col;
    final dy = next.row - current.row;

    if (dx == 1) {
      current.rightWall = false;
      next.leftWall = false;
    } else if (dx == -1) {
      current.leftWall = false;
      next.rightWall = false;
    } else if (dy == 1) {
      current.bottomWall = false;
      next.topWall = false;
    } else if (dy == -1) {
      current.topWall = false;
      next.bottomWall = false;
    }
  }
}
