import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/reward_model.dart';
import '../../viewmodels/reward_viewmodel.dart';

class RewardView extends StatelessWidget {
  final String studentId;

  const RewardView({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RewardViewModel()..loadRewards(studentId),
      child: Scaffold(
        body: Consumer<RewardViewModel>(
          builder: (context, vm, _) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6D5FFD), Color(0xFF8A7CFF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  elevation: 0,
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  title: const Text(
                    "Rewards 🏆",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 8,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        if (vm.rewards.isNotEmpty) _statsSummary(vm),
                        const SizedBox(height: 20),

                        vm.rewards.isEmpty
                            ? _empty()
                            : Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: vm.rewards.length,
                                separatorBuilder:
                                    (_, __) => const SizedBox(height: 14),
                                itemBuilder:
                                    (_, i) => _rewardCard(vm.rewards[i]),
                              ),
                            ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _statsSummary(RewardViewModel vm) {
    final totalXP = vm.rewards.fold<int>(0, (sum, r) => sum + r.value);
    final epicCount = vm.rewards.where((r) => r.rarity == "epic").length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.25),
              Colors.white.withOpacity(0.12),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statChip("${vm.rewards.length}", "REWARDS", Icons.card_giftcard),
            _statChip("$totalXP", "TOTAL XP", Icons.star),
            _statChip("$epicCount", "EPIC", Icons.emoji_events),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.75)),
        ),
      ],
    );
  }

  // ==================== REWARD CARD ====================
  Widget _rewardCard(Reward r) {
    final color = _color(r.rarity);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  r.imagePath,
                  height: 48,
                  errorBuilder:
                      (_, __, ___) =>
                          Icon(Icons.emoji_events, color: color, size: 42),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "+${r.value} XP",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),

            // Rarity Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: color.withOpacity(0.4), width: 1.5),
              ),
              child: Text(
                r.rarity.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 100),
      child: Center(
        child: Column(
          children: [
            Text("🎁", style: TextStyle(fontSize: 90)),
            SizedBox(height: 20),
            Text(
              "No rewards yet",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Complete challenges to earn rewards!",
              style: TextStyle(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _color(String rarity) {
    switch (rarity.toLowerCase()) {
      case "epic":
        return const Color(0xFFFFB300);
      case "rare":
        return const Color(0xFF3B82F6);
      case "special":
        return const Color(0xFFEC4899);
      default: // common
        return const Color(0xFF10B981);
    }
  }
}
