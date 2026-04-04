import 'package:flutter_test/flutter_test.dart';
import 'package:maze_escape/maze_generator.dart';

void main() {
  group('Maze Generator Tests', () {
    test('Maze generates with correct dimensions', () {
      final maze = Maze(8, 8);
      maze.generate();

      expect(maze.rows, equals(8));
      expect(maze.cols, equals(8));
      expect(maze.grid.length, equals(8));
      expect(maze.grid[0].length, equals(8));
    });

    test('All cells are visited after generation', () {
      final maze = Maze(10, 10);
      maze.generate();

      for (var row in maze.grid) {
        for (var cell in row) {
          expect(cell.visited, isTrue, reason: 'Cell at (${cell.row}, ${cell.col}) not visited');
        }
      }
    });

    test('Start cell (0,0) has path out', () {
      final maze = Maze(8, 8);
      maze.generate();

      final startCell = maze.grid[0][0];
      // Start cell must have at least one wall removed
      final wallCount = [
        startCell.topWall,
        startCell.rightWall,
        startCell.bottomWall,
        startCell.leftWall,
      ].where((wall) => wall).length;

      expect(wallCount, lessThan(4), reason: 'Start cell is completely walled in');
    });

    test('End cell (n-1, n-1) has path in', () {
      final maze = Maze(8, 8);
      maze.generate();

      final endCell = maze.grid[7][7];
      // End cell must have at least one wall removed
      final wallCount = [
        endCell.topWall,
        endCell.rightWall,
        endCell.bottomWall,
        endCell.leftWall,
      ].where((wall) => wall).length;

      expect(wallCount, lessThan(4), reason: 'End cell is completely walled in');
    });

    test('Different mazes are generated', () {
      // Generate two mazes and check they're different
      final maze1 = Maze(6, 6);
      final maze2 = Maze(6, 6);
      maze1.generate();
      maze2.generate();

      var differenceFound = false;
      for (var i = 0; i < 6; i++) {
        for (var j = 0; j < 6; j++) {
          final cell1 = maze1.grid[i][j];
          final cell2 = maze2.grid[i][j];
          if (cell1.topWall != cell2.topWall ||
              cell1.rightWall != cell2.rightWall ||
              cell1.bottomWall != cell2.bottomWall ||
              cell1.leftWall != cell2.leftWall) {
            differenceFound = true;
            break;
          }
        }
        if (differenceFound) break;
      }

      expect(differenceFound, isTrue, reason: 'Mazes should be randomly different');
    });

    test('Large maze generates successfully', () {
      final maze = Maze(16, 16);
      expect(() => maze.generate(), returnsNormally);
      expect(maze.grid.length, equals(16));
    });
  });
}
