import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import 'maze_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService.instance.init();
  runApp(const MazeEscapeApp());
}

// ============================================================================
// SETTINGS SERVICE
// ============================================================================
class SettingsService {
  static final SettingsService instance = SettingsService._();
  SettingsService._();

  late SharedPreferences _prefs;

  bool soundEnabled = true;
  bool vibrationEnabled = true;
  int highScore = 0; // Fastest time in seconds
  int gamesPlayed = 0;
  bool hasSeenTutorial = false;
  Set<String> unlockedAchievements = {};

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    soundEnabled = _prefs.getBool('sound') ?? true;
    vibrationEnabled = _prefs.getBool('vibration') ?? true;
    highScore = _prefs.getInt('highScore') ?? 999999; // Start with large number (best time)
    gamesPlayed = _prefs.getInt('gamesPlayed') ?? 0;
    hasSeenTutorial = _prefs.getBool('hasSeenTutorial') ?? false;
    unlockedAchievements = (_prefs.getStringList('achievements') ?? []).toSet();
  }

  Future<void> setSoundEnabled(bool value) async {
    soundEnabled = value;
    await _prefs.setBool('sound', value);
  }

  Future<void> setVibrationEnabled(bool value) async {
    vibrationEnabled = value;
    await _prefs.setBool('vibration', value);
  }

  Future<void> saveScore(int timeSeconds) async {
    gamesPlayed++;
    await _prefs.setInt('gamesPlayed', gamesPlayed);

    // For maze, lower time is better
    if (timeSeconds < highScore) {
      highScore = timeSeconds;
      await _prefs.setInt('highScore', timeSeconds);
    }
  }

  Future<void> markTutorialSeen() async {
    hasSeenTutorial = true;
    await _prefs.setBool('hasSeenTutorial', true);
  }

  Future<void> unlockAchievement(String id) async {
    if (!unlockedAchievements.contains(id)) {
      unlockedAchievements.add(id);
      await _prefs.setStringList('achievements', unlockedAchievements.toList());
    }
  }
}

// ============================================================================
// ACHIEVEMENTS
// ============================================================================
class Achievement {
  final String id;
  final String title;
  final String description;
  final int targetTime; // Time in seconds

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.targetTime,
  });
}

final List<Achievement> achievements = [
  Achievement(id: 'speed_30', title: 'Quick Escape', description: 'Complete in under 30 seconds', targetTime: 30),
  Achievement(id: 'speed_20', title: 'Maze Runner', description: 'Complete in under 20 seconds', targetTime: 20),
  Achievement(id: 'speed_15', title: 'Speed Demon', description: 'Complete in under 15 seconds', targetTime: 15),
  Achievement(id: 'speed_10', title: 'Legendary', description: 'Complete in under 10 seconds', targetTime: 10),
];

// ============================================================================
// MAIN APP
// ============================================================================
class MazeEscapeApp extends StatelessWidget {
  const MazeEscapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maze Escape',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.light(
          primary: Colors.purple.shade700,
          secondary: Colors.amber.shade700,
        ),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.purple.shade300,
          secondary: Colors.amber.shade300,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const MenuScreen(),
    );
  }
}

// ============================================================================
// MENU SCREEN
// ============================================================================
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _showTutorialIfNeeded();
  }

  void _showTutorialIfNeeded() {
    if (!SettingsService.instance.hasSeenTutorial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTutorial();
      });
    }
  }

  void _showTutorial() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.school, color: Colors.purple),
            SizedBox(width: 8),
            Text('How to Play'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Navigate through the maze using arrow buttons', style: TextStyle(fontSize: 16)),
            SizedBox(height: 12),
            Text('2. Reach the red exit in the bottom-right corner', style: TextStyle(fontSize: 16)),
            SizedBox(height: 12),
            Text('3. Complete as fast as possible for high scores!', style: TextStyle(fontSize: 16)),
            SizedBox(height: 12),
            Text('4. Larger mazes = harder but more satisfying!', style: TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              SettingsService.instance.markTutorialSeen();
              Navigator.pop(context);
            },
            child: const Text('GOT IT!'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: const Icon(Icons.grid_4x4, size: 120, color: Colors.purple),
              ),
              const SizedBox(height: 24),
              const Text(
                '🌀 Maze Escape',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Find your way out!',
                style: TextStyle(fontSize: 24, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              if (SettingsService.instance.highScore < 999999)
                Text(
                  'Best Time: ${SettingsService.instance.highScore}s',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
                ),
              const SizedBox(height: 48),
              _buildDifficultyButton(context, 'Easy', 8, Colors.green),
              const SizedBox(height: 16),
              _buildDifficultyButton(context, 'Medium', 12, Colors.orange),
              const SizedBox(height: 16),
              _buildDifficultyButton(context, 'Hard', 16, Colors.red),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                    icon: const Icon(Icons.settings, size: 32),
                    tooltip: 'Settings',
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: _showTutorial,
                    icon: const Icon(Icons.help_outline, size: 32),
                    tooltip: 'How to Play',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(BuildContext context, String label, int size, Color color) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MazeGameScreen(gridSize: size)),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 24),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      child: Text('$label (${size}x$size)', style: const TextStyle(fontSize: 24)),
    );
  }
}

// ============================================================================
// SETTINGS SCREEN
// ============================================================================
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.purple.shade700,
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Sound Effects'),
              subtitle: const Text('Play sounds during gameplay'),
              value: SettingsService.instance.soundEnabled,
              onChanged: (value) {
                setState(() {
                  SettingsService.instance.setSoundEnabled(value);
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              title: const Text('Vibration'),
              subtitle: const Text('Haptic feedback during gameplay'),
              value: SettingsService.instance.vibrationEnabled,
              onChanged: (value) {
                setState(() {
                  SettingsService.instance.setVibrationEnabled(value);
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.emoji_events, color: Colors.amber),
              title: const Text('Achievements'),
              subtitle: Text('${SettingsService.instance.unlockedAchievements.length}/${achievements.length} unlocked'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.policy),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.info_outline),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Privacy Policy'),
                    content: const SingleChildScrollView(
                      child: Text(
                        'Maze Escape is a 100% offline game.\n\n'
                        'We do NOT collect, store, or transmit any personal data.\n\n'
                        'All game data (scores, settings, achievements) is stored '
                        'locally on your device and never leaves your device.\n\n'
                        'We do NOT use:\n'
                        '• Analytics or tracking\n'
                        '• Advertising networks\n'
                        '• Third-party services\n'
                        '• Internet connectivity\n\n'
                        'This app works completely offline and respects your privacy.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('GOT IT'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Version'),
              subtitle: Text('1.0.0'),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ACHIEVEMENTS SCREEN
// ============================================================================
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.purple.shade700,
        title: const Text('Achievements'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          final unlocked = SettingsService.instance.unlockedAchievements.contains(achievement.id);

          return Card(
            color: unlocked ? Colors.purple.shade900.withValues(alpha: 0.3) : Colors.grey.shade800,
            child: ListTile(
              leading: Icon(
                unlocked ? Icons.emoji_events : Icons.lock,
                color: unlocked ? Colors.amber : Colors.grey,
                size: 32,
              ),
              title: Text(
                achievement.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: unlocked ? Colors.white : Colors.grey,
                ),
              ),
              subtitle: Text(
                achievement.description,
                style: TextStyle(color: unlocked ? Colors.white70 : Colors.grey.shade600),
              ),
              trailing: unlocked
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// GAME SCREEN
// ============================================================================
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
  bool isPaused = false;
  bool newRecord = false;

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
    isPaused = false;

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isCompleted && !isPaused) {
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
    if (isCompleted || isPaused) return;

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

      if (SettingsService.instance.soundEnabled) {
        SystemSound.play(SystemSoundType.click);
      }

      // Check win condition
      if (playerRow == widget.gridSize - 1 && playerCol == widget.gridSize - 1) {
        isCompleted = true;
        timer?.cancel();
        _onComplete();
      }
    });

    if (SettingsService.instance.vibrationEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  void _onComplete() {
    final time = elapsedSeconds;

    // Check for new record
    if (time < SettingsService.instance.highScore) {
      newRecord = true;
      SettingsService.instance.saveScore(time);
    } else {
      SettingsService.instance.saveScore(time);
    }

    // Check achievements
    _checkAchievements();

    // Request rating after 10 games
    if (SettingsService.instance.gamesPlayed == 10) {
      _requestRating();
    }

    if (SettingsService.instance.soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
    if (SettingsService.instance.vibrationEnabled) {
      HapticFeedback.heavyImpact();
    }
  }

  void _checkAchievements() {
    for (var achievement in achievements) {
      if (elapsedSeconds <= achievement.targetTime) {
        if (!SettingsService.instance.unlockedAchievements.contains(achievement.id)) {
          SettingsService.instance.unlockAchievement(achievement.id);
          _showAchievementPopup(achievement);
        }
      }
    }
  }

  void _showAchievementPopup(Achievement achievement) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 100,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade700,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.white, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Achievement!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        achievement.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });

    if (SettingsService.instance.soundEnabled) {
      SystemSound.play(SystemSoundType.alert);
    }
    if (SettingsService.instance.vibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _requestRating() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

  void _shareScore() {
    SharePlus.instance.share(
      ShareParams(
        text: 'I escaped the maze in $elapsedSeconds seconds! Can you beat my time? #MazeEscape',
        subject: 'Check out my Maze Escape time!',
      ),
    );
  }

  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  void _quit() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (isCompleted) {
      return Scaffold(
        backgroundColor: Colors.grey.shade900,
        appBar: AppBar(
          backgroundColor: Colors.purple.shade700,
          title: const Text('Maze Complete!'),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 80, color: Colors.green),
                const SizedBox(height: 24),
                const Text('🎉 You Escaped!', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text('Time: ${elapsedSeconds}s', style: const TextStyle(fontSize: 28)),
                if (newRecord) ...[
                  const SizedBox(height: 16),
                  const Text(
                    '🏆 New Record!',
                    style: TextStyle(fontSize: 24, color: Colors.amber, fontWeight: FontWeight.bold),
                  ),
                ],
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: _quit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                    backgroundColor: Colors.purple.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('BACK TO MENU', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _shareScore,
                  icon: const Icon(Icons.share),
                  label: const Text('Share Time'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.purple.shade700,
        title: Text('Time: ${elapsedSeconds}s'),
        actions: [
          IconButton(
            onPressed: _togglePause,
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
            tooltip: isPaused ? 'Resume' : 'Pause',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Center(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: Size(
                        min(screenWidth * 0.9, 400),
                        min(screenWidth * 0.9, 400),
                      ),
                      painter: MazePainter(maze, playerRow, playerCol),
                    ),
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

          // Pause overlay
          if (isPaused)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.pause_circle, size: 100, color: Colors.white),
                    const SizedBox(height: 16),
                    const Text(
                      'PAUSED',
                      style: TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _togglePause,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('RESUME', style: TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _quit,
                      child: const Text('QUIT TO MENU', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// MAZE PAINTER
// ============================================================================
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
  bool shouldRepaint(MazePainter oldDelegate) {
    return oldDelegate.playerRow != playerRow ||
           oldDelegate.playerCol != playerCol;
  }
}
