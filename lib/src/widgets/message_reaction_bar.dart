import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/reaction_model.dart';
import '../theme/ai_ui_theme.dart';
import '../animations/ai_animations.dart';

/// An animated emoji reaction bar that appears below a chat message.
///
/// Shows a horizontally scrollable row of emoji buttons. Selected reactions
/// animate with a scale-bounce and highlight. Supports single or multi-select.
///
/// ### Usage
/// ```dart
/// MessageReactionBar(
///   selectedReactions: _selected,
///   onReactionToggled: (emoji) => _toggleReaction(emoji),
/// )
/// ```
///
/// ### Custom Reactions
/// ```dart
/// MessageReactionBar(
///   reactions: [
///     ReactionModel(emoji: '🚀', label: 'rocket'),
///     ReactionModel(emoji: '💯', label: 'perfect'),
///   ],
///   onReactionToggled: (emoji) => print(emoji),
/// )
/// ```
class MessageReactionBar extends StatefulWidget {
  /// The list of available reactions. Defaults to [kDefaultReactions].
  final List<ReactionModel> reactions;

  /// Currently selected emoji strings.
  final Set<String> selectedReactions;

  /// Called when a reaction is tapped (toggled on or off).
  final void Function(String emoji)? onReactionToggled;

  /// Whether multiple reactions can be selected simultaneously.
  final bool multiSelect;

  /// Size of each emoji character.
  final double emojiSize;

  /// Whether to show the reaction label below the emoji on long press.
  final bool showLabels;

  /// Padding around the entire row.
  final EdgeInsets padding;

  const MessageReactionBar({
    super.key,
    this.reactions = kDefaultReactions,
    this.selectedReactions = const {},
    this.onReactionToggled,
    this.multiSelect = true,
    this.emojiSize = 20,
    this.showLabels = false,
    this.padding = const EdgeInsets.symmetric(vertical: 4),
  });

  @override
  State<MessageReactionBar> createState() => _MessageReactionBarState();
}

class _MessageReactionBarState extends State<MessageReactionBar> {
  @override
  Widget build(BuildContext context) {
    final theme = AiUiTheme.of(context);

    return FadeSlideIn(
      slideOffset: 8,
      child: SizedBox(
        height: 56,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: widget.padding,
          itemCount: widget.reactions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 4),
          itemBuilder: (_, i) {
            final reaction = widget.reactions[i];
            final isSelected = widget.selectedReactions.contains(reaction.emoji);

            return _ReactionButton(
              reaction: reaction,
              isSelected: isSelected,
              emojiSize: widget.emojiSize,
              theme: theme,
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onReactionToggled?.call(reaction.emoji);
              },
            );
          },
        ),
      ),
    );
  }
}

// ─── Individual Reaction Button ───────────────────────────────────────────────

class _ReactionButton extends StatefulWidget {
  final ReactionModel reaction;
  final bool isSelected;
  final double emojiSize;
  final AiUiThemeData theme;
  final VoidCallback onTap;

  const _ReactionButton({
    required this.reaction,
    required this.isSelected,
    required this.emojiSize,
    required this.theme,
    required this.onTap,
  });

  @override
  State<_ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<_ReactionButton> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.35).chain(CurveTween(curve: Curves.easeOut)), weight: 30),
      TweenSequenceItem(
          tween: Tween(begin: 1.35, end: 0.9).chain(CurveTween(curve: Curves.easeIn)), weight: 30),
      TweenSequenceItem(
          tween: Tween(begin: 0.9, end: 1.0).chain(CurveTween(curve: AiCurves.snappy)), weight: 40),
    ]).animate(_ctrl);

    _bounce = _scale; // alias
  }

  @override
  void didUpdateWidget(_ReactionButton old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final isSelected = widget.isSelected;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(
          scale: _ctrl.isAnimating ? _scale.value : 1.0,
          child: child,
        ),
        child: AnimatedContainer(
          clipBehavior: Clip.none,
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
          decoration: BoxDecoration(
            // color: isSelected ? theme.reactionSelectedColor : theme.promptCardColor,
            borderRadius: BorderRadius.circular(22),
            // border: Border.all(
            //   color: isSelected ? theme.accentColor.withOpacity(0.5) : theme.borderColor,
            //   width: isSelected ? 1.5 : 1.0,
            // ),
            // boxShadow: isSelected
            //     ? [
            //         BoxShadow(
            //           color: theme.accentColor.withOpacity(0.15),
            //           blurRadius: 8,
            //           spreadRadius: 1,
            //         ),
            //       ]
            //     : null,
          ),
          child: Center(
            child: Text(
              widget.reaction.emoji,
              style: TextStyle(fontSize: isSelected ? (widget.emojiSize + 5) : widget.emojiSize),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Compact Inline Reaction Count Row ───────────────────────────────────────

/// Shows active reaction counts on a message bubble — e.g. "👍 3  ❤️ 1".
///
/// ```dart
/// ReactionCountRow(
///   counts: {'👍': 3, '❤️': 1},
///   onTap: (emoji) => showReactionDetails(emoji),
/// )
/// ```
class ReactionCountRow extends StatelessWidget {
  /// Map of emoji → count of users who reacted.
  final Map<String, int> counts;

  /// Called when a specific reaction is tapped.
  final void Function(String emoji)? onTap;

  /// Whether the current user has added a reaction.
  final Set<String> myReactions;

  const ReactionCountRow({
    super.key,
    required this.counts,
    this.onTap,
    this.myReactions = const {},
  });

  @override
  Widget build(BuildContext context) {
    final theme = AiUiTheme.of(context);
    final entries = counts.entries.where((e) => e.value > 0).toList();
    if (entries.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: entries.map((e) {
        final isMine = myReactions.contains(e.key);
        return GestureDetector(
          onTap: () => onTap?.call(e.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isMine ? theme.reactionSelectedColor : theme.assistantBubbleColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isMine ? theme.accentColor.withOpacity(0.4) : theme.borderColor,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(e.key, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Text(
                  '${e.value}',
                  style: theme.timestampTextStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
