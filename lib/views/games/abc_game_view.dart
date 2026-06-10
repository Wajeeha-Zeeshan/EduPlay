import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/games/abc_game_viewmodel.dart';
import '../../views/reward_view.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';

class ABCGamePage extends StatefulWidget {
  final String studentId;

  const ABCGamePage({super.key, required this.studentId});
  @override
  State<ABCGamePage> createState() => _ABCGamePageState();
}

class _ABCGamePageState extends State<ABCGamePage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playMusic();
  }

  Future<void> _playMusic() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(1.0);

      _audioPlayer.onPlayerStateChanged.listen((state) {
        print("Player state: $state");
      });

      await _audioPlayer.play(AssetSource('audio/abc_music.mp3'));

      print("Music started");
    } catch (e) {
      print("Audio error: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ABCGameViewModel()..init(widget.studentId),
      child: Scaffold(
        body: Consumer<ABCGameViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/abc.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 6,
                  ),
                ),
              );
            }

            if (vm.isCompleted()) {
              return _buildCompletionScreen(context, vm);
            }

            return Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/abc.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 12),
                              _buildSubtitle(),
                              const SizedBox(height: 24),
                              _buildLetterCard(vm),
                              const SizedBox(height: 28),
                              _buildOptionsRow(vm),
                              _buildFeedback(vm),
                              const Spacer(),
                              _buildProgressBar(vm),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 8),
      child: Text(
        "ABC Game",
        style: GoogleFonts.fredoka(
          fontSize: 44,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF6A1B9A),
          shadows: [
            Shadow(
              color: Color(0xFFD7A6FF),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: const Text(
        "Can you find the same letter?",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6A1B9A),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLetterCard(ABCGameViewModel vm) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.85, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(60),
          border: Border.all(color: Colors.white, width: 14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 30,
              spreadRadius: 8,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Center(
          child: Text(
            vm.currentUpper,
            style: const TextStyle(
              fontSize: 140,
              fontWeight: FontWeight.w900,
              color: Color(0xFF6A1B9A),
              shadows: [
                Shadow(
                  offset: Offset(4, 4),
                  blurRadius: 10,
                  color: Colors.black38,
                ),
              ],
            ),
          ),
        ),
      ),
      builder:
          (context, scale, child) =>
              Transform.scale(scale: scale, child: child),
    );
  }

  Widget _buildOptionsRow(ABCGameViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            vm.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;

              return TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(milliseconds: 300 + index * 100),
                curve: Curves.elasticOut,
                child: GestureDetector(
                  onTap: () => vm.selectAnswer(option),
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getUniqueColor(option),
                          _getUniqueColor(option).withOpacity(0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(color: Colors.white, width: 7),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        option,
                        style: const TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(3, 3),
                              blurRadius: 6,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                builder:
                    (context, scale, child) =>
                        Transform.scale(scale: scale, child: child),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildFeedback(ABCGameViewModel vm) {
    if (vm.feedbackMessage == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 400),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
          decoration: BoxDecoration(
            color:
                vm.isCorrect
                    ? const Color(0xFF4CAF50).withOpacity(0.92)
                    : const Color(0xFFFF5252).withOpacity(0.92),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15),
            ],
          ),
          child: Text(
            vm.feedbackMessage!,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(ABCGameViewModel vm) {
    double progress = (vm.currentLevel + 1) / 26.0;
    int retries = vm.retries[vm.currentUpper] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white, width: 5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.stars, color: Colors.amber, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    "${vm.score}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEC407A),
                    ),
                  ),
                ],
              ),
              Text(
                "Level ${vm.currentLevel + 1}/26",
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6A1B9A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.5),
              color: const Color(0xFFEC407A),
              minHeight: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen(BuildContext context, ABCGameViewModel vm) {
    int totalRetries = vm.getTotalRetries();
    String rewardMessage = vm.getRewardMessage();
    bool hasRewards = vm.earnedRewards.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/abc.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.35)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "You're Amazing ",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Color.fromARGB(255, 116, 8, 152),
                      ),
                    ),
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 36,
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                const Text(
                  "You completed the ABC Game!",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 116, 8, 152),
                  ),
                ),

                const SizedBox(height: 50),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCuteStatCard(
                            Icons.star,
                            "Score",
                            "${vm.score}",
                            Colors.amber,
                          ),
                          _buildCuteStatCard(
                            Icons.favorite,
                            "Tries",
                            "$totalRetries",
                            Colors.pink,
                          ),
                          _buildCuteStatCard(
                            Icons.auto_awesome,
                            "Accuracy",
                            "${((vm.score / 260) * 100).toStringAsFixed(0)}%",
                            Colors.purple,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEC407A), Color(0xFFFF6D00)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              size: 24,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                rewardMessage,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80),

                if (hasRewards)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => RewardView(studentId: vm.studentId!),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9B5DE5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      elevation: 8,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 10),
                        Text(
                          "See Your Rewards ",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Icon(
                          Icons.card_giftcard,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 60),

                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFEC407A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    elevation: 6,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.home, size: 24),
                      SizedBox(width: 10),
                      Text(
                        "Go Home",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCuteStatCard(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 28, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Color _getUniqueColor(String letter) {
    final colors = [
      const Color(0xFFFF8A80),
      const Color(0xFF81D4FA),
      const Color(0xFFFFF176),
      const Color(0xFFCE93D8),
      const Color(0xFFA5D6A7),
      const Color(0xFFFFAB91),
      const Color(0xFF80DEEA),
      const Color(0xFFFFCC80),
      const Color(0xFFB39DDB),
      const Color(0xFF90CAF9),
      const Color(0xFFAED581),
      const Color(0xFFFFE082),
      const Color(0xFFBCAAA4),
      const Color(0xFF9FA8DA),
      const Color(0xFF80CBC4),
      const Color(0xFFFFD54F),
      const Color(0xFFEF9A9A),
      const Color(0xFF81C784),
      const Color(0xFF64B5F6),
      const Color(0xFFFFD740),
      const Color(0xFFBA68C8),
      const Color(0xFF4DD0E1),
      const Color(0xFFFFB74D),
      const Color(0xFF7986CB),
      const Color(0xFF66BB6A),
      const Color(0xFFFF8A65),
    ];

    int index = letter.toUpperCase().codeUnitAt(0) - 65;
    return colors[index % colors.length];
  }
}
