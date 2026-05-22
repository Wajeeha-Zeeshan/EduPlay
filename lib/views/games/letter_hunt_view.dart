// lib/views/games/letter_hunt_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/games/letter_hunt_game_viewmodel.dart';
import '../reward_view.dart';

class LetterHuntPage extends StatelessWidget {
  final String studentId;

  const LetterHuntPage({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LetterHuntViewModel()..init(studentId),
      child: Scaffold(
        body: Consumer<LetterHuntViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/letterhunt.jpg'),
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
                  image: AssetImage('assets/images/letterhunt.jpg'),
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
                              _buildSequenceCard(vm),
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
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        "Letter Hunt",
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 1.8,
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
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12),
        ],
      ),
      child: const Text(
        "What comes next in the sequence?",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF5C2A0E),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSequenceCard(LetterHuntViewModel vm) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.85, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.93),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Colors.white, width: 14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 30,
              spreadRadius: 6,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Center(
          child: Text(
            vm.currentSequence,
            style: const TextStyle(
              fontSize: 68,
              fontWeight: FontWeight.w900,
              color: Color(0xFFEA580C),
              height: 1.0,
              letterSpacing: 4.0,
              shadows: [
                Shadow(
                  offset: Offset(3, 3),
                  blurRadius: 8,
                  color: Colors.black38,
                ),
              ],
            ),
            maxLines: 1,
          ),
        ),
      ),
      builder:
          (context, scale, child) =>
              Transform.scale(scale: scale, child: child),
    );
  }

  Widget _buildOptionsRow(LetterHuntViewModel vm) {
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
                          _getOptionColor(option),
                          _getOptionColor(option).withOpacity(0.85),
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

  Widget _buildFeedback(LetterHuntViewModel vm) {
    if (vm.feedbackMessage == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
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

  Widget _buildProgressBar(LetterHuntViewModel vm) {
    double progress = (vm.currentLevel + 1) / vm.totalLevels;
    int retries = vm.retries["Level${vm.currentLevel + 1}"] ?? 0;

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
                      color: Color(0xFFEA580C),
                    ),
                  ),
                ],
              ),
              Text(
                "Level ${vm.currentLevel + 1}/${vm.totalLevels}",
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5C2A0E),
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
              color: const Color(0xFFFFB300),
              minHeight: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen(BuildContext context, LetterHuntViewModel vm) {
    int totalRetries = vm.getTotalRetries();
    String rewardMessage = vm.getOverallRewardMessage();

    var badges = vm.earnedRewards.where((r) => r.type == 'badge').toList();
    var stars = vm.earnedRewards.where((r) => r.type == 'star').toList();
    var coins = vm.earnedRewards.where((r) => r.type == 'coin').toList();
    int totalCoins = coins.fold(0, (sum, r) => sum + r.value);

    bool hasRewards = vm.earnedRewards.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/letterhunt.jpg'),
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
                const SizedBox(height: 80),
                Text(
                  "You're Amazing 🌟",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: const Offset(2, 2),
                        blurRadius: 8,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 6),
                const Text(
                  "You completed Letter Hunt!",
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),

                const SizedBox(height: 60),

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
                            Colors.orange,
                          ),
                          _buildCuteStatCard(
                            Icons.auto_awesome,
                            "Accuracy",
                            "${((vm.score / (vm.totalLevels * 10)) * 100).toStringAsFixed(0)}%",
                            Colors.deepOrange,
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
                            colors: [Color(0xFFFFB300), Color(0xFFFF6D00)],
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

                const SizedBox(height: 70),

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
                        Icon(Icons.card_giftcard, size: 24),
                        SizedBox(width: 10),
                        Text(
                          "See Your Rewards 🎁",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 60),

                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFEA580C),
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
                TextButton.icon(
                  onPressed: () => vm.init(vm.studentId!),
                  icon: const Icon(
                    Icons.play_arrow,
                    size: 22,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Play Again",
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 20),
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

  Widget _buildCuteRewardItem(
    String title,
    int count,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            "$title ×$count",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Color _getOptionColor(String letter) {
    final colors = [
      const Color(0xFFFF6D00),
      const Color(0xFFEA580C),
      const Color(0xFFFFB300),
      const Color(0xFFAB47BC),
    ];
    return colors[letter.codeUnitAt(0) % colors.length];
  }
}
