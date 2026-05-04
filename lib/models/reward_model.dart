class Reward {
  final String id;
  final String type;
  final String name;
  final int value;
  final DateTime earnedAt;

  Reward({
    required this.id,
    required this.type,
    required this.name,
    required this.value,
    required this.earnedAt,
  });

  String get imagePath {
    switch (type) {
      case 'candy':
        return 'assets/images/candy.png';
      case 'star':
        return 'assets/images/star1.png';
      case 'crown':
        return 'assets/images/crown.png';
      case 'gem':
        return 'assets/images/gem.png';
      case 'sticker':
        return 'assets/images/sticker.png';
      default:
        return 'assets/images/default.png';
    }
  }

  String get animation {
    switch (type) {
      case 'crown':
        return 'glow';
      case 'star':
        return 'sparkle';
      case 'gem':
        return 'shine';
      case 'sticker':
        return 'pop';
      default:
        return 'bounce';
    }
  }

  String get rarity {
    switch (type) {
      case 'crown':
        return 'epic';
      case 'star':
      case 'gem':
        return 'rare';
      case 'sticker':
        return 'special';
      default:
        return 'common';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'value': value,
      'earnedAt': earnedAt.toIso8601String(),
    };
  }

  factory Reward.fromMap(Map<String, dynamic> map) {
    return Reward(
      id: map['id'] ?? '',
      type: map['type'] ?? 'candy',
      name: map['name'] ?? 'Candy Coin',
      value: map['value'] ?? 0,
      earnedAt: DateTime.parse(map['earnedAt']),
    );
  }
}
