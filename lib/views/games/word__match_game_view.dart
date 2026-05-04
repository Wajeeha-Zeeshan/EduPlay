import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/games/word_match_game_viewmodel.dart';
import '../reward_view.dart';

class WordMatchPage extends StatelessWidget {
  final String studentId;

  const WordMatchPage({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WordMatchViewModel()..init(studentId),
      child: Scaffold(
        body: Consumer<WordMatchViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/wordmatch.jpg'),
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
                  image: AssetImage('assets/images/wordmatch.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  _buildHeader(),
                                  const SizedBox(height: 8),
                                  _buildSubtitle(),
                                  const SizedBox(height: 20),
                                  _buildWordDisplay(vm),
                                ],
                              ),
                              Column(
                                children: [
                                  const SizedBox(height: 10),
                                  _buildOptions(vm),
                                  _buildFeedback(vm),
                                ],
                              ),
                              _buildProgressBar(vm),
                              const SizedBox(height: 10),
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
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        "Word Match",
        style: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w900,
          color: Color(0xFF6A1B9A),
          letterSpacing: 1.6,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12),
        ],
      ),
      child: const Text(
        "Tap the picture that matches the word!",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6A1B9A),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildWordDisplay(WordMatchViewModel vm) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.85, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder:
          (context, scale, child) => Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                vm.currentWord,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      offset: Offset(4, 4),
                      blurRadius: 12,
                      color: Colors.black45,
                    ),
                    Shadow(
                      offset: Offset(0, 0),
                      blurRadius: 20,
                      color: Color(0xFFEC407A),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
    );
  }

  Widget _buildOptions(WordMatchViewModel vm) {
    final options = vm.options;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildImageOption(options[0], vm),
              _buildImageOption(options[1], vm),
            ],
          ),
          const SizedBox(height: 20),
          Center(child: _buildImageOption(options[2], vm)),
        ],
      ),
    );
  }

  Widget _buildImageOption(String imagePath, WordMatchViewModel vm) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      child: GestureDetector(
        onTap: () => vm.selectAnswer(imagePath),
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white, width: 6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 20,
                spreadRadius: 4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder:
                  (_, __, ___) => const Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
            ),
          ),
        ),
      ),
      builder:
          (context, scale, child) =>
              Transform.scale(scale: scale, child: child),
    );
  }

  Widget _buildFeedback(WordMatchViewModel vm) {
    if (vm.feedbackMessage == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 400),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color:
                vm.isCorrect
                    ? const Color(0xFF4CAF50).withOpacity(0.92)
                    : const Color(0xFFFF5252).withOpacity(0.92),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15),
            ],
          ),
          child: Text(
            vm.feedbackMessage!,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(WordMatchViewModel vm) {
    double progress = (vm.currentLevel + 1) / vm.levels.length.toDouble();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 6),
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
                  const Icon(Icons.stars, color: Colors.amber, size: 24),
                  const SizedBox(width: 6),
                  Text(
                    "${vm.score}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEC407A),
                    ),
                  ),
                ],
              ),
              Text(
                "Level ${vm.currentLevel + 1}/${vm.levels.length}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6A1B9A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.5),
              color: const Color(0xFFEC407A),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen(BuildContext context, WordMatchViewModel vm) {
    int totalRetries = vm.getTotalRetries();
    String rewardMessage = vm.getRewardMessage();

    var crowns = vm.earnedRewards.where((r) => r.type == 'crown').toList();
    var stars = vm.earnedRewards.where((r) => r.type == 'star').toList();
    var gems = vm.earnedRewards.where((r) => r.type == 'gem').toList();
    var candies = vm.earnedRewards.where((r) => r.type == 'candy').toList();
    var stickers = vm.earnedRewards.where((r) => r.type == 'sticker').toList();

    bool hasRewards = vm.earnedRewards.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/wordmatch.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.45)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),

                  const SizedBox(height: 18),
                  Text(
                    "You're Amazing 🌟",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: const Offset(2, 2),
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.7),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "You completed Word Match!",
                    style: TextStyle(fontSize: 20, color: Colors.white70),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.94),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
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
                              "${((vm.score / (vm.levels.length * 10)) * 100).toStringAsFixed(0)}%",
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
                              colors: [Color(0xFFEC407A), Color(0xFFBA68C8)],
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                size: 22,
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

                  const SizedBox(height: 24),

                  if (hasRewards)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    RewardView(studentId: vm.studentId!),
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

                  const SizedBox(height: 16),

                  // Go Home Button
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFEC407A),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
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
                        Icon(Icons.home, size: 24),
                        SizedBox(width: 10),
                        Text(
                          "Go Home",
                          style: TextStyle(
                            fontSize: 18,
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
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(
            "$title ×$count",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
