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
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage("assets/images/rewards.png"),
                  fit: BoxFit.cover,
                ),
                color: Colors.black.withOpacity(0.1),
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,

                body: SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 140),
                        Text(
                          "Rewards",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFFB78DFF),
                            shadows: [
                              Shadow(
                                color: Colors.white,
                                blurRadius: 8,
                                offset: Offset(0, 0),
                              ),
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

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

                        const SizedBox(height: 15),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 120),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.workspace_premium_rounded,
              size: 90,
              color: Color(0xFFAF8CFF),
            ),

            SizedBox(height: 20),

            Text(
              "No rewards yet",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFFAF8CFF),
              ),
            ),

            SizedBox(height: 12),

            Text(
              "Complete challenges to earn rewards!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFFAF8CFF),
              ),
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
