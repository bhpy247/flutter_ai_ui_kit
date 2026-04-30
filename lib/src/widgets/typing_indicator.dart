import 'package:flutter/material.dart';
import '../theme/ai_ui_theme.dart';
import '../animations/ai_animations.dart';
import '../models/chat_message.dart';
import '../utils/chat_utils.dart';

/// An animated typing indicator showing three bouncing dots.
///
/// Commonly rendered below the message list when the AI is generating a response.
///
/// ### Usage
/// ```dart
/// TypingIndicator(isVisible: _isTyping)
/// ```
///
/// ### With custom colors
/// ```dart
/// TypingIndicator(
///   isVisible: true,
///   dotColor: Colors.purple,
///   dotSize: 9,
///   label: 'GPT is thinking...',
/// )
/// ```
class TypingIndicator extends StatefulWidget {
  /// Whether the indicator is currently visible.
  final bool isVisible;

  /// Color of the three animated dots. Defaults to [AiUiThemeData.typingDotColor].
  final Color? dotColor;

  /// Diameter of each dot. Defaults to 8.
  final double dotSize;

  /// Gap between dots. Defaults to 5.
  final double dotSpacing;

  /// Optional label shown beside the dots (e.g. "Claude is typing…").
  final String? label;

  /// Whether to show the assistant avatar to the left.
  final bool showAvatar;

  /// Custom avatar widget. Falls back to the AI gradient icon.
  final Widget? avatarWidget;

  /// Duration of one full bounce cycle per dot.
  final Duration cycleDuration;

  const TypingIndicator({
    super.key,
    this.isVisible = true,
    this.dotColor,
    this.dotSize = 8,
    this.dotSpacing = 5,
    this.label,
    this.showAvatar = true,
    this.avatarWidget,
    this.cycleDuration = const Duration(milliseconds: 600),
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _bounces;

  static const _dotCount = 3;
  static const _stagger = Duration(milliseconds: 160);

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _dotCount,
      (i) => AnimationController(vsync: this, duration: widget.cycleDuration),
    );
    _bounces = _controllers
        .map(
          (c) => Tween<double>(begin: 0, end: -8).animate(
            CurvedAnimation(parent: c, curve: Curves.easeInOut),
          ),
        )
        .toList();

    _startAnimations();
  }

  void _startAnimations() {
    for (var i = 0; i < _dotCount; i++) {
      Future.delayed(_stagger * i, () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AiUiTheme.of(context);
    final dotColor = widget.dotColor ?? theme.typingDotColor;

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: AiCurves.smooth,
      child: widget.isVisible
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: FadeSlideIn(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Avatar
                    if (widget.showAvatar) ...[
                      widget.avatarWidget ?? _AiAvatarMini(theme: theme),
                      const SizedBox(width: 8),
                    ],

                    // Bubble
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.assistantBubbleColor,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(4),
                          topRight: Radius.circular(theme.bubbleRadius),
                          bottomLeft: Radius.circular(theme.bubbleRadius),
                          bottomRight: Radius.circular(theme.bubbleRadius),
                        ),
                        boxShadow: theme.cardShadow,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Three animated dots
                          ...List.generate(_dotCount, (i) {
                            return AnimatedBuilder(
                              animation: _bounces[i],
                              builder: (_, __) => Padding(
                                padding: EdgeInsets.only(
                                  right: i < _dotCount - 1 ? widget.dotSpacing : 0,
                                ),
                                child: Transform.translate(
                                  offset: Offset(0, _bounces[i].value),
                                  child: _Dot(
                                    size: widget.dotSize,
                                    color: dotColor.withOpacity(
                                      0.4 + (0.6 * _controllers[i].value),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),

                          // Optional label
                          if (widget.label != null) ...[
                            const SizedBox(width: 10),
                            Text(
                              widget.label!,
                              style: theme.timestampTextStyle.copyWith(
                                fontSize: 12,
                                color: theme.assistantBubbleTextColor.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _Dot extends StatelessWidget {
  final double size;
  final Color color;

  const _Dot({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _AiAvatarMini extends StatelessWidget {
  final AiUiThemeData theme;

  const _AiAvatarMini({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [theme.accentColor, theme.accentSecondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.auto_awesome, color: Colors.white, size: 18),
      ),
    );
  }
}
