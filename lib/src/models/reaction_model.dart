/// Represents a single emoji reaction that can be added to a message.
class ReactionModel {
  /// The emoji character (e.g. '👍').
  final String emoji;

  /// Display label (e.g. 'thumbs up').
  final String label;

  const ReactionModel({
    required this.emoji,
    required this.label,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReactionModel && runtimeType == other.runtimeType && emoji == other.emoji;

  @override
  int get hashCode => emoji.hashCode;
}

/// Default set of reactions available in [MessageReactionBar].
const List<ReactionModel> kDefaultReactions = [
  ReactionModel(emoji: '👍', label: 'thumbs up'),
  ReactionModel(emoji: '❤️', label: 'love'),
  ReactionModel(emoji: '😂', label: 'laugh'),
  ReactionModel(emoji: '😮', label: 'wow'),
  ReactionModel(emoji: '🎯', label: 'on target'),
  ReactionModel(emoji: '🔥', label: 'fire'),
  ReactionModel(emoji: '✨', label: 'sparkle'),
  ReactionModel(emoji: '👎', label: 'thumbs down'),
];
