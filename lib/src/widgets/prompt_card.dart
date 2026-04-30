import 'package:flutter/material.dart';
import '../theme/ai_ui_theme.dart';
import '../animations/ai_animations.dart';

/// A tappable suggestion prompt card shown in the empty state or as quick
/// prompts below the input field.
///
/// Features icon, title, subtitle, tap callback, and smooth hover/press effect.
///
/// ### Usage
/// ```dart
/// PromptCard(
///   icon: Icons.lightbulb_outline,
///   title: 'Explain quantum computing',
///   subtitle: 'Simple analogies, no jargon',
///   onTap: () => sendMessage('Explain quantum computing'),
/// )
/// ```
///
/// ### Grid of prompts
/// ```dart
/// GridView.count(
///   crossAxisCount: 2,
///   children: prompts.map((p) => PromptCard(...)).toList(),
/// )
/// ```
class PromptCard extends StatefulWidget {
  /// Icon shown at the top-left of the card.
  final IconData? icon;

  /// Custom widget used instead of [icon].
  final Widget? iconWidget;

  /// Short headline text.
  final String title;

  /// Optional supporting text beneath the title.
  final String? subtitle;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// Card background color. Defaults to [AiUiThemeData.promptCardColor].
  final Color? backgroundColor;

  /// Hover background color. Defaults to [AiUiThemeData.promptCardHoverColor].
  final Color? hoverColor;

  /// Icon color. Defaults to [AiUiThemeData.accentColor].
  final Color? iconColor;

  /// Icon background color.
  final Color? iconBackgroundColor;

  /// Whether to show a trailing arrow icon.
  final bool showArrow;

  /// Entrance animation delay (for staggered grids).
  final Duration animationDelay;

  /// Border radius override.
  final double? borderRadius;

  /// Fixed card height. If null, sizes to content.
  final double? height;

  /// Padding inside the card.
  final EdgeInsets contentPadding;

  const PromptCard({
    super.key,
    this.icon,
    this.iconWidget,
    required this.title,
    this.subtitle,
    this.onTap,
    this.backgroundColor,
    this.hoverColor,
    this.iconColor,
    this.iconBackgroundColor,
    this.showArrow = true,
    this.animationDelay = Duration.zero,
    this.borderRadius,
    this.height,
    this.contentPadding = const EdgeInsets.all(14),
  }) : assert(
          icon != null || iconWidget != null || true,
          'Provide either icon or iconWidget',
        );

  @override
  State<PromptCard> createState() => _PromptCardState();
}

class _PromptCardState extends State<PromptCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;

  late final AnimationController _scaleCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _onHoverChange(bool hovering) {
    setState(() => _isHovered = hovering);
  }

  void _onTapDown(_) {
    setState(() => _isPressed = true);
    _scaleCtrl.forward();
  }

  void _onTapUp(_) {
    setState(() => _isPressed = false);
    _scaleCtrl.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _scaleCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AiUiTheme.of(context);
    final radius = widget.borderRadius ?? theme.cardRadius;
    final bgColor = widget.backgroundColor ?? theme.promptCardColor;
    final hoverColor = widget.hoverColor ?? theme.promptCardHoverColor;
    final iconColor = widget.iconColor ?? theme.accentColor;
    final iconBg = widget.iconBackgroundColor ?? iconColor.withValues(alpha:0.1);

    final effectiveBg = (_isHovered || _isPressed) ? hoverColor : bgColor;

    return ScaleIn(
      delay: widget.animationDelay,
      fromScale: 0.92,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: MouseRegion(
          onEnter: (_) => _onHoverChange(true),
          onExit: (_) => _onHoverChange(false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: widget.height,
              padding: widget.contentPadding,
              decoration: BoxDecoration(
                color: effectiveBg,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: _isHovered ? iconColor.withValues(alpha:0.35) : theme.borderColor,
                  width: 1.2,
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: iconColor.withValues(alpha:0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : theme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Icon
                      if (widget.iconWidget != null)
                        widget.iconWidget!
                      else if (widget.icon != null)
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: iconBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(widget.icon, color: iconColor, size: 18),
                        ),

                      const Spacer(),

                      // Arrow
                      if (widget.showArrow)
                        AnimatedRotation(
                          turns: _isHovered ? 0.125 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.arrow_outward_rounded,
                            color: iconColor.withValues(alpha:_isHovered ? 0.9 : 0.4),
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Title
                  Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: theme.messageTextStyle.color,
                      height: 1.35,
                    ),
                  ),

                  // Subtitle
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.timestampTextStyle.copyWith(
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A horizontally scrollable row of [PromptCard] chips,compact version.
///
/// ```dart
/// PromptChipRow(
///   prompts: [
///     PromptChipData(label: 'Summarise this', icon: Icons.summarize),
///     PromptChipData(label: 'Translate to Hindi', icon: Icons.translate),
///   ],
///   onSelect: (label) => sendMessage(label),
/// )
/// ```
class PromptChipRow extends StatelessWidget {
  final List<PromptChipData> prompts;
  final void Function(String label)? onSelect;
  final EdgeInsets padding;

  const PromptChipRow({
    super.key,
    required this.prompts,
    this.onSelect,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final theme = AiUiTheme.of(context);
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: prompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final p = prompts[i];
          return _PromptChip(
            data: p,
            theme: theme,
            onTap: () => onSelect?.call(p.label),
          );
        },
      ),
    );
  }
}

class PromptChipData {
  final String label;
  final IconData? icon;
  const PromptChipData({required this.label, this.icon});
}

class _PromptChip extends StatefulWidget {
  final PromptChipData data;
  final AiUiThemeData theme;
  final VoidCallback? onTap;

  const _PromptChip({
    required this.data,
    required this.theme,
    this.onTap,
  });

  @override
  State<_PromptChip> createState() => _PromptChipState();
}

class _PromptChipState extends State<_PromptChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _pressed ? theme.promptCardHoverColor : theme.promptCardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: theme.borderColor, width: 1.2),
          boxShadow: theme.cardShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.data.icon != null) ...[
              Icon(widget.data.icon, size: 14, color: theme.accentColor),
              const SizedBox(width: 6),
            ],
            Text(
              widget.data.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: theme.messageTextStyle.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
