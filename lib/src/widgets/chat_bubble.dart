import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/chat_message.dart';
import '../theme/ai_ui_theme.dart';
import '../utils/chat_utils.dart';
import '../animations/ai_animations.dart';

/// A highly polished chat bubble widget supporting both user and assistant roles.
///
/// Features:
/// - Markdown + code block rendering
/// - Gradient user bubbles / neutral assistant bubbles
/// - Avatar (URL, widget, or auto-initials)
/// - Timestamp display
/// - Long-press copy to clipboard
/// - Animated entrance (fade + slide)
/// - Shimmer loading state
///
/// ### Basic Usage
/// ```dart
/// ChatBubble(
///   message: ChatMessage.user(text: 'Hello!'),
/// )
/// ```
///
/// ### Custom Avatar
/// ```dart
/// ChatBubble(
///   message: ChatMessage.assistant(text: '**Sure!** Here is the code...'),
///   showAvatar: true,
/// )
/// ```
class ChatBubble extends StatelessWidget {
  /// The message to render.
  final ChatMessage message;

  /// Whether to show the sender avatar.
  final bool showAvatar;

  /// Avatar size in logical pixels.
  final double avatarSize;

  /// Whether the bubble should animate in on first render.
  final bool animate;

  /// Animation entrance delay.
  final Duration animationDelay;

  /// Called when the user taps the bubble.
  final VoidCallback? onTap;

  /// Called when the user long-presses the bubble (defaults to copy).
  final VoidCallback? onLongPress;

  /// If true, shows an in-bubble copy icon on long press.
  final bool enableCopy;

  /// Called when a link inside Markdown is tapped.
  final void Function(String href)? onLinkTap;

  /// Override the maximum bubble width fraction of screen width.
  final double maxWidthFraction;

  const ChatBubble({
    super.key,
    required this.message,
    this.showAvatar = true,
    this.avatarSize = 36,
    this.animate = true,
    this.animationDelay = Duration.zero,
    this.onTap,
    this.onLongPress,
    this.enableCopy = true,
    this.onLinkTap,
    this.maxWidthFraction = 0.78,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AiUiTheme.of(context);
    final isUser = message.isUser;

    Widget bubble = _BubbleContent(
      message: message,
      theme: theme,
      isUser: isUser,
      showAvatar: showAvatar,
      avatarSize: avatarSize,
      maxWidthFraction: maxWidthFraction,
      enableCopy: enableCopy,
      onTap: onTap,
      onLongPress: onLongPress,
      onLinkTap: onLinkTap,
    );

    if (animate) {
      bubble = FadeSlideIn(
        delay: animationDelay,
        slideOffset: isUser ? 10 : 15,
        child: bubble,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: bubble,
    );
  }
}

// ─── Internal: Full bubble layout ────────────────────────────────────────────

class _BubbleContent extends StatefulWidget {
  final ChatMessage message;
  final AiUiThemeData theme;
  final bool isUser;
  final bool showAvatar;
  final double avatarSize;
  final double maxWidthFraction;
  final bool enableCopy;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final void Function(String)? onLinkTap;

  const _BubbleContent({
    required this.message,
    required this.theme,
    required this.isUser,
    required this.showAvatar,
    required this.avatarSize,
    required this.maxWidthFraction,
    required this.enableCopy,
    this.onTap,
    this.onLongPress,
    this.onLinkTap,
  });

  @override
  State<_BubbleContent> createState() => _BubbleContentState();
}

class _BubbleContentState extends State<_BubbleContent> {
  bool _showCopyConfirm = false;

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.message.text));
    if (mounted) {
      setState(() => _showCopyConfirm = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _showCopyConfirm = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.isUser;
    final theme = widget.theme;
    final msg = widget.message;

    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      // crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── Assistant avatar (left side) ──────────────────────────────────
        if (!isUser && widget.showAvatar) ...[
          _Avatar(
            message: msg,
            size: widget.avatarSize,
            theme: theme,
          ),
          const SizedBox(width: 8),
        ],

        // ── Bubble + timestamp ────────────────────────────────────────────
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * widget.maxWidthFraction,
            ),
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Sender name
                if (!isUser && msg.senderName != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child: Text(
                      msg.senderName!,
                      style: theme.senderNameTextStyle,
                    ),
                  ),

                // The bubble itself
                GestureDetector(
                  onTap: widget.onTap,
                  onLongPress: () {
                    if (widget.enableCopy) _copyToClipboard();
                    widget.onLongPress?.call();
                  },
                  child: Stack(
                    children: [
                      _BubbleBody(
                        message: msg,
                        theme: theme,
                        isUser: isUser,
                        onLinkTap: widget.onLinkTap,
                      ),
                      // Copy confirm overlay
                      if (_showCopyConfirm)
                        Positioned.fill(
                          child: _CopyConfirmOverlay(isUser: isUser),
                        ),
                    ],
                  ),
                ),

                // Timestamp + read indicator
                Padding(
                  padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ChatUtils.formatTimestamp(msg.timestamp),
                        style: theme.timestampTextStyle,
                      ),
                      if (isUser) ...[
                        const SizedBox(width: 4),
                        Icon(
                          msg.isRead ? Icons.done_all : Icons.done,
                          size: 13,
                          color: msg.isRead ? theme.accentColor : theme.timestampTextStyle.color,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── User avatar (right side) ──────────────────────────────────────
        if (isUser && widget.showAvatar) ...[
          const SizedBox(width: 8),
          _Avatar(
            message: msg,
            size: widget.avatarSize,
            theme: theme,
          ),
        ],
      ],
    );
  }
}

// ─── Bubble Body ─────────────────────────────────────────────────────────────

class _BubbleBody extends StatelessWidget {
  final ChatMessage message;
  final AiUiThemeData theme;
  final bool isUser;
  final void Function(String)? onLinkTap;

  const _BubbleBody({
    required this.message,
    required this.theme,
    required this.isUser,
    this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    // Loading state → shimmer
    if (message.isLoading) return const _LoadingBubble();

    final radius = theme.bubbleRadius;
    final decoration = isUser
        ? BoxDecoration(
            gradient: theme.userBubbleGradient,
            color: theme.userBubbleGradient == null ? theme.userBubbleColor : null,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(radius),
              topRight: Radius.circular(radius),
              bottomLeft: Radius.circular(radius),
              bottomRight: const Radius.circular(4),
            ),
            boxShadow: theme.cardShadow,
          )
        : BoxDecoration(
            color: theme.assistantBubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(4),
              topRight: Radius.circular(radius),
              bottomLeft: Radius.circular(radius),
              bottomRight: Radius.circular(radius),
            ),
            boxShadow: theme.cardShadow,
          );

    return Container(
      decoration: decoration,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: _MessageContent(
        message: message,
        isUser: isUser,
        theme: theme,
        onLinkTap: onLinkTap,
      ),
    );
  }
}

// ─── Message Content (text / markdown / streaming) ───────────────────────────

class _MessageContent extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;
  final AiUiThemeData theme;
  final void Function(String)? onLinkTap;

  const _MessageContent({
    required this.message,
    required this.isUser,
    required this.theme,
    this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isUser ? theme.userBubbleTextColor : theme.assistantBubbleTextColor;

    final hasMarkdown = ChatUtils.hasMarkdown(message.text);

    if (!hasMarkdown) {
      return SelectableText(
        message.text,
        style: theme.messageTextStyle.copyWith(color: textColor),
      );
    }

    // Markdown rendering
    return MarkdownBody(
      data: message.text,
      selectable: true,
      onTapLink: (_, href, __) {
        if (href != null) onLinkTap?.call(href);
      },
      styleSheet: _markdownStyleSheet(context, isUser, textColor, theme),
    );
  }

  MarkdownStyleSheet _markdownStyleSheet(
    BuildContext context,
    bool isUser,
    Color textColor,
    AiUiThemeData theme,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final codeBg = isUser
        ? Colors.black.withOpacity(0.2)
        : (isDark ? const Color(0xFF1A1B2E) : const Color(0xFFF3F4F6));

    final baseStyle = theme.messageTextStyle.copyWith(color: textColor);

    return MarkdownStyleSheet(
      p: baseStyle,
      h1: baseStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
      h2: baseStyle.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
      h3: baseStyle.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
      strong: baseStyle.copyWith(fontWeight: FontWeight.w700),
      em: baseStyle.copyWith(fontStyle: FontStyle.italic),
      code: baseStyle.copyWith(
        fontFamily: 'monospace',
        fontSize: 13,
        backgroundColor: codeBg,
        color: isUser ? Colors.white : theme.accentColor,
      ),
      codeblockDecoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D0E1A) : const Color(0xFF1E1F2E),
        borderRadius: BorderRadius.circular(10),
      ),
      codeblockPadding: const EdgeInsets.all(12),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: theme.accentColor, width: 3),
        ),
        color: theme.accentColor.withOpacity(0.07),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      blockquotePadding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      listBullet: baseStyle,
      a: baseStyle.copyWith(
        color: isUser ? Colors.white : theme.accentColor,
        decoration: TextDecoration.underline,
      ),
    );
  }
}

// ─── Loading Bubble ───────────────────────────────────────────────────────────

class _LoadingBubble extends StatelessWidget {
  const _LoadingBubble();

  @override
  Widget build(BuildContext context) {
    final theme = AiUiTheme.of(context);
    return Container(
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 180, height: 12, borderRadius: 6),
          const SizedBox(height: 8),
          ShimmerBox(width: 120, height: 12, borderRadius: 6),
        ],
      ),
    );
  }
}

// ─── Copy Confirm Overlay ─────────────────────────────────────────────────────

class _CopyConfirmOverlay extends StatelessWidget {
  final bool isUser;

  const _CopyConfirmOverlay({required this.isUser});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(AiUiTheme.of(context).bubbleRadius),
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text(
                'Copied!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Avatar ───────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final ChatMessage message;
  final double size;
  final AiUiThemeData theme;

  const _Avatar({
    required this.message,
    required this.size,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // Custom widget override
    if (message.avatarWidget != null) {
      return SizedBox(
        width: size,
        height: size,
        child: message.avatarWidget,
      );
    }

    // URL avatar
    if (message.avatarUrl != null) {
      return ClipOval(
        child: Image.network(
          message.avatarUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialsAvatar(context),
        ),
      );
    }

    return _initialsAvatar(context);
  }

  Widget _initialsAvatar(BuildContext context) {
    if (message.isAssistant) {
      // AI logo avatar
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [theme.accentColor, theme.accentSecondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: size * 0.5,
          ),
        ),
      );
    }

    return ChatUtils.buildInitialsAvatar(
      name: message.senderName,
      size: size,
      gradientColors: [
        ChatUtils.colorFromString(message.senderName ?? 'U'),
        ChatUtils.colorFromString((message.senderName ?? 'U') + 'end'),
      ],
    );
  }
}
