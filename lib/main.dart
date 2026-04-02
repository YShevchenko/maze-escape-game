import 'package:flutter/material.dart';
import 'dart:async';
import 'maze_generator.dart';

void main() => runApp(const MazeEscapeApp());

class MazeEscapeApp extends StatelessWidget {
  const MazeEscapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maze Escape',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const MenuScreen(),
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🌀 Maze Escape'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDifficultyButton(context, 'Easy', 8),
            const SizedBox(height: 16),
            _buildDifficultyButton(context, 'Medium', 12),
            const SizedBox(height: 16),
            _buildDifficultyButton(context, 'Hard', 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(BuildContext context, String label, int size) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MazeGameScreen(gridSize: size)),
        );
      },
      child: Text('$label (${size}x$size)'),
    );
  }
}

class MazeGameScreen extends StatefulWidget {
  final int gridSize;

  const MazeGameScreen({super.key, required this.gridSize});

  @override
  State<MazeGameScreen> createState() => _MazeGameScreenState();
}

class _MazeGameScreenState extends State<MazeGameScreen> {
  late Maze maze;
  late int playerRow;
  late int playerCol;
  late DateTime startTime;
  int elapsedSeconds = 0;
  Timer? timer;
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    maze = Maze(widget.gridSize, widget.gridSize);
    maze.generate();
    playerRow = 0;
    playerCol = 0;
    startTime = DateTime.now();
    isCompleted = false;

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isCompleted) {
        setState(() {
          elapsedSeconds = DateTime.now().difference(startTime).inSeconds;
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _move(int dx, int dy) {
    if (isCompleted) return;

    final currentCell = maze.grid[playerRow][playerCol];
    final newRow = playerRow + dy;
    final newCol = playerCol + dx;

    if (newRow < 0 || newRow >= widget.gridSize || newCol < 0 || newCol >= widget.gridSize) {
      return;
    }

    // Check if movement is blocked by wall
    if (dx == 1 && currentCell.rightWall) return;
    if (dx == -1 && currentCell.leftWall) return;
    if (dy == 1 && currentCell.bottomWall) return;
    if (dy == -1 && currentCell.topWall) return;

    setState(() {
      playerRow = newRow;
      playerCol = newCol;

      // Check win condition
      if (playerRow == widget.gridSize - 1 && playerCol == widget.gridSize - 1) {
        isCompleted = true;
        timer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return Scaffold(
        appBar: AppBar(title: const Text('Maze Complete!')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎉 You Escaped!', style: TextStyle(fontSize: 32)),
              const SizedBox(height: 24),
              Text('Time: ${elapsedSeconds}s', style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Menu'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Time: ${elapsedSeconds}s'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: CustomPaint(
                size: const Size(400, 400),
                painter: MazePainter(maze, playerRow, playerCol),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_upward, size: 48),
                      onPressed: () => _move(0, -1),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 48),
                      onPressed: () => _move(-1, 0),
                    ),
                    const SizedBox(width: 80),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward, size: 48),
                      onPressed: () => _move(1, 0),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_downward, size: 48),
                      onPressed: () => _move(0, 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MazePainter extends CustomPainter {
  final Maze maze;
  final int playerRow;
  final int playerCol;

  MazePainter(this.maze, this.playerRow, this.playerCol);

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / maze.cols;
    final wallPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;

    final playerPaint = Paint()..color = Colors.green;
    final exitPaint = Paint()..color = Colors.red;

    // Draw walls
    for (int i = 0; i < maze.rows; i++) {
      for (int j = 0; j < maze.cols; j++) {
        final cell = maze.grid[i][j];
        final x = j * cellSize;
        final y = i * cellSize;

        if (cell.topWall) {
          canvas.drawLine(
            Offset(x, y),
            Offset(x + cellSize, y),
            wallPaint,
          );
        }
        if (cell.rightWall) {
          canvas.drawLine(
            Offset(x + cellSize, y),
            Offset(x + cellSize, y + cellSize),
            wallPaint,
          );
        }
        if (cell.bottomWall) {
          canvas.drawLine(
            Offset(x, y + cellSize),
            Offset(x + cellSize, y + cellSize),
            wallPaint,
          );
        }
        if (cell.leftWall) {
          canvas.drawLine(
            Offset(x, y),
            Offset(x, y + cellSize),
            wallPaint,
          );
        }
      }
    }

    // Draw exit
    final exitX = (maze.cols - 1) * cellSize;
    final exitY = (maze.rows - 1) * cellSize;
    canvas.drawCircle(
      Offset(exitX + cellSize / 2, exitY + cellSize / 2),
      cellSize / 3,
      exitPaint,
    );

    // Draw player
    final playerX = playerCol * cellSize;
    final playerY = playerRow * cellSize;
    canvas.drawCircle(
      Offset(playerX + cellSize / 2, playerY + cellSize / 2),
      cellSize / 3,
      playerPaint,
    );
  }

  @override
  bool shouldRepaint(MazePainter oldDelegate) => true;
}
