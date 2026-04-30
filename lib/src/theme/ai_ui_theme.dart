import 'package:flutter/material.dart';

/// The primary theme data for `flutter_ai_ui_kit`.
///
/// Provides color, typography, spacing, and shape tokens for all widgets.
/// Supports both light and dark modes out of the box.
///
/// ### Usage
/// ```dart
/// AiUiTheme.of(context).userBubbleColor
/// ```
///
/// Or override globally via [AiUiThemeData]:
/// ```dart
/// AiUiThemeScope(
///   data: AiUiThemeData.dark(),
///   child: MyApp(),
/// )
/// ```
class AiUiTheme extends InheritedWidget {
  /// The theme data.
  final AiUiThemeData data;

  const AiUiTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// Retrieves the nearest [AiUiThemeData] from context.
  /// Falls back to [AiUiThemeData.light()] if none is found.
  static AiUiThemeData of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AiUiTheme>();
    if (scope != null) return scope.data;
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? AiUiThemeData.dark() : AiUiThemeData.light();
  }

  @override
  bool updateShouldNotify(AiUiTheme oldWidget) => data != oldWidget.data;
}

/// A convenient wrapper widget that injects [AiUiThemeData] into the tree.
class AiUiThemeScope extends StatelessWidget {
  final AiUiThemeData data;
  final Widget child;

  const AiUiThemeScope({
    super.key,
    required this.data,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AiUiTheme(data: data, child: child);
  }
}

/// Immutable theme data for all `flutter_ai_ui_kit` widgets.
@immutable
class AiUiThemeData {
  // ─── Bubble Colors ───────────────────────────────────────────────────────────
  /// Background color for user chat bubbles.
  final Color userBubbleColor;

  /// Background color for assistant chat bubbles.
  final Color assistantBubbleColor;

  /// Gradient used for user chat bubbles.
  final Gradient? userBubbleGradient;

  /// Text color inside user bubbles.
  final Color userBubbleTextColor;

  /// Text color inside assistant bubbles.
  final Color assistantBubbleTextColor;

  // ─── Input Field ─────────────────────────────────────────────────────────────
  /// Background color / glass tint for [GlassInputField].
  final Color inputBackgroundColor;

  /// Border color for [GlassInputField].
  final Color inputBorderColor;

  /// Hint text color for [GlassInputField].
  final Color inputHintColor;

  /// Focused border color for [GlassInputField].
  final Color inputFocusBorderColor;

  // ─── Accent & Brand ──────────────────────────────────────────────────────────
  /// Primary accent color (buttons, send icon, active states).
  final Color accentColor;

  /// Secondary accent (gradients, hover states).
  final Color accentSecondary;

  /// Brand gradient (send button, active elements).
  final Gradient accentGradient;

  // ─── Surface & Background ────────────────────────────────────────────────────
  /// Chat screen background color.
  final Color backgroundColor;

  /// Surface color for cards, panels.
  final Color surfaceColor;

  /// Subtle border / divider color.
  final Color borderColor;

  // ─── Typography ──────────────────────────────────────────────────────────────
  /// Base text style for message content.
  final TextStyle messageTextStyle;

  /// Text style for timestamps.
  final TextStyle timestampTextStyle;

  /// Text style for sender names.
  final TextStyle senderNameTextStyle;

  // ─── Prompt Card ─────────────────────────────────────────────────────────────
  /// Background for [PromptCard].
  final Color promptCardColor;

  /// Hover / pressed tint for [PromptCard].
  final Color promptCardHoverColor;

  // ─── Typing Indicator ────────────────────────────────────────────────────────
  /// Color of the three animated dots.
  final Color typingDotColor;

  // ─── Voice Wave ──────────────────────────────────────────────────────────────
  /// Active bar color for [VoiceWave].
  final Color voiceWaveActiveColor;

  /// Inactive bar color for [VoiceWave].
  final Color voiceWaveInactiveColor;

  // ─── Reactions ───────────────────────────────────────────────────────────────
  /// Background of the reaction pill when selected.
  final Color reactionSelectedColor;

  // ─── Shape ───────────────────────────────────────────────────────────────────
  /// Default border radius for bubbles.
  final double bubbleRadius;

  /// Corner radius for input field.
  final double inputRadius;

  /// Corner radius for cards.
  final double cardRadius;

  // ─── Shadows ─────────────────────────────────────────────────────────────────
  /// Shadow for assistant bubbles / cards.
  final List<BoxShadow> cardShadow;

  const AiUiThemeData({
    required this.userBubbleColor,
    required this.assistantBubbleColor,
    this.userBubbleGradient,
    required this.userBubbleTextColor,
    required this.assistantBubbleTextColor,
    required this.inputBackgroundColor,
    required this.inputBorderColor,
    required this.inputHintColor,
    required this.inputFocusBorderColor,
    required this.accentColor,
    required this.accentSecondary,
    required this.accentGradient,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.borderColor,
    required this.messageTextStyle,
    required this.timestampTextStyle,
    required this.senderNameTextStyle,
    required this.promptCardColor,
    required this.promptCardHoverColor,
    required this.typingDotColor,
    required this.voiceWaveActiveColor,
    required this.voiceWaveInactiveColor,
    required this.reactionSelectedColor,
    required this.bubbleRadius,
    required this.inputRadius,
    required this.cardRadius,
    required this.cardShadow,
  });

  /// Modern light theme,clean white with vivid indigo accent.
  factory AiUiThemeData.light() {
    const accent = Color(0xFF6366F1);
    const accentSec = Color(0xFF8B5CF6);
    return AiUiThemeData(
      userBubbleColor: accent,
      assistantBubbleColor: const Color(0xFFF3F4F6),
      userBubbleGradient: const LinearGradient(
        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      userBubbleTextColor: Colors.white,
      assistantBubbleTextColor: const Color(0xFF111827),
      inputBackgroundColor: Colors.white.withValues(alpha: 0.8),
      inputBorderColor: const Color(0xFFE5E7EB),
      inputHintColor: const Color(0xFF9CA3AF),
      inputFocusBorderColor: accent,
      accentColor: accent,
      accentSecondary: accentSec,
      accentGradient: const LinearGradient(
        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      surfaceColor: Colors.white,
      borderColor: const Color(0xFFE5E7EB),
      messageTextStyle: const TextStyle(
        fontSize: 15,
        height: 1.55,
        color: Color(0xFF111827),
        fontFamily: 'sans-serif',
      ),
      timestampTextStyle: const TextStyle(
        fontSize: 11,
        color: Color(0xFF9CA3AF),
        letterSpacing: 0.2,
      ),
      senderNameTextStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF6B7280),
        letterSpacing: 0.3,
      ),
      promptCardColor: Colors.white,
      promptCardHoverColor: const Color(0xFFF0F0FF),
      typingDotColor: accent,
      voiceWaveActiveColor: accent,
      voiceWaveInactiveColor: const Color(0xFFD1D5DB),
      reactionSelectedColor: const Color(0xFFEEF2FF),
      bubbleRadius: 18,
      inputRadius: 28,
      cardRadius: 16,
      cardShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Modern dark theme,deep slate with vivid indigo accent.
  factory AiUiThemeData.dark() {
    const accent = Color(0xFF818CF8);
    const accentSec = Color(0xFFA78BFA);
    return AiUiThemeData(
      userBubbleColor: const Color(0xFF4F46E5),
      assistantBubbleColor: const Color(0xFF1E2030),
      userBubbleGradient: const LinearGradient(
        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      userBubbleTextColor: Colors.white,
      assistantBubbleTextColor: const Color(0xFFE5E7EB),
      inputBackgroundColor: const Color(0xFF1A1B2E).withOpacity(0.85),
      inputBorderColor: const Color(0xFF2D3048),
      inputHintColor: const Color(0xFF6B7280),
      inputFocusBorderColor: accent,
      accentColor: accent,
      accentSecondary: accentSec,
      accentGradient: const LinearGradient(
        colors: [Color(0xFF818CF8), Color(0xFFA78BFA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      backgroundColor: const Color(0xFF0F0F1A),
      surfaceColor: const Color(0xFF161628),
      borderColor: const Color(0xFF2D3048),
      messageTextStyle: const TextStyle(
        fontSize: 15,
        height: 1.55,
        color: Color(0xFFE5E7EB),
      ),
      timestampTextStyle: const TextStyle(
        fontSize: 11,
        color: Color(0xFF6B7280),
        letterSpacing: 0.2,
      ),
      senderNameTextStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF9CA3AF),
        letterSpacing: 0.3,
      ),
      promptCardColor: const Color(0xFF1E2030),
      promptCardHoverColor: const Color(0xFF252840),
      typingDotColor: accent,
      voiceWaveActiveColor: accent,
      voiceWaveInactiveColor: const Color(0xFF374151),
      reactionSelectedColor: const Color(0xFF1E2030),
      bubbleRadius: 18,
      inputRadius: 28,
      cardRadius: 16,
      cardShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Creates a copy with overridden fields.
  AiUiThemeData copyWith({
    Color? userBubbleColor,
    Color? assistantBubbleColor,
    Gradient? userBubbleGradient,
    Color? userBubbleTextColor,
    Color? assistantBubbleTextColor,
    Color? inputBackgroundColor,
    Color? inputBorderColor,
    Color? inputHintColor,
    Color? inputFocusBorderColor,
    Color? accentColor,
    Color? accentSecondary,
    Gradient? accentGradient,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? borderColor,
    TextStyle? messageTextStyle,
    TextStyle? timestampTextStyle,
    TextStyle? senderNameTextStyle,
    Color? promptCardColor,
    Color? promptCardHoverColor,
    Color? typingDotColor,
    Color? voiceWaveActiveColor,
    Color? voiceWaveInactiveColor,
    Color? reactionSelectedColor,
    double? bubbleRadius,
    double? inputRadius,
    double? cardRadius,
    List<BoxShadow>? cardShadow,
  }) {
    return AiUiThemeData(
      userBubbleColor: userBubbleColor ?? this.userBubbleColor,
      assistantBubbleColor: assistantBubbleColor ?? this.assistantBubbleColor,
      userBubbleGradient: userBubbleGradient ?? this.userBubbleGradient,
      userBubbleTextColor: userBubbleTextColor ?? this.userBubbleTextColor,
      assistantBubbleTextColor: assistantBubbleTextColor ?? this.assistantBubbleTextColor,
      inputBackgroundColor: inputBackgroundColor ?? this.inputBackgroundColor,
      inputBorderColor: inputBorderColor ?? this.inputBorderColor,
      inputHintColor: inputHintColor ?? this.inputHintColor,
      inputFocusBorderColor: inputFocusBorderColor ?? this.inputFocusBorderColor,
      accentColor: accentColor ?? this.accentColor,
      accentSecondary: accentSecondary ?? this.accentSecondary,
      accentGradient: accentGradient ?? this.accentGradient,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      borderColor: borderColor ?? this.borderColor,
      messageTextStyle: messageTextStyle ?? this.messageTextStyle,
      timestampTextStyle: timestampTextStyle ?? this.timestampTextStyle,
      senderNameTextStyle: senderNameTextStyle ?? this.senderNameTextStyle,
      promptCardColor: promptCardColor ?? this.promptCardColor,
      promptCardHoverColor: promptCardHoverColor ?? this.promptCardHoverColor,
      typingDotColor: typingDotColor ?? this.typingDotColor,
      voiceWaveActiveColor: voiceWaveActiveColor ?? this.voiceWaveActiveColor,
      voiceWaveInactiveColor: voiceWaveInactiveColor ?? this.voiceWaveInactiveColor,
      reactionSelectedColor: reactionSelectedColor ?? this.reactionSelectedColor,
      bubbleRadius: bubbleRadius ?? this.bubbleRadius,
      inputRadius: inputRadius ?? this.inputRadius,
      cardRadius: cardRadius ?? this.cardRadius,
      cardShadow: cardShadow ?? this.cardShadow,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AiUiThemeData && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}
