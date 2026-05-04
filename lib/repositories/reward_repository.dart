import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reward_model.dart';

class RewardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addReward(String studentId, Reward reward) async {
    await _firestore
        .collection('students')
        .doc(studentId)
        .collection('rewards')
        .doc(reward.id)
        .set(reward.toMap());
  }

  Future<List<Reward>> getRewards(String studentId) async {
    final snapshot =
        await _firestore
            .collection('students')
            .doc(studentId)
            .collection('rewards')
            .orderBy('earnedAt', descending: true)
            .get();

    return snapshot.docs.map((doc) => Reward.fromMap(doc.data())).toList();
  }

  Future<void> deleteReward(String studentId, String rewardId) async {
    await _firestore
        .collection('students')
        .doc(studentId)
        .collection('rewards')
        .doc(rewardId)
        .delete();
  }
}
