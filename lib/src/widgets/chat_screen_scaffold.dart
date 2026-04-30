import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../theme/ai_ui_theme.dart';
import '../animations/ai_animations.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/glass_input_field.dart';
import '../widgets/prompt_card.dart';
import '../widgets/streaming_text.dart';

/// A complete, ready-to-use AI chat screen scaffold.
///
/// Handles the full chat layout including message list, typing indicator,
/// input field, empty state with prompt cards, and scroll-to-bottom behavior.
///
/// ### Minimal Usage
/// ```dart
/// ChatScreenScaffold(
///   messages: _messages,
///   onSend: (text) => _sendMessage(text),
/// )
/// ```
///
/// ### Full Configuration
/// ```dart
/// ChatScreenScaffold(
///   messages: _messages,
///   isTyping: _isGenerating,
///   onSend: _handleSend,
///   onAttachment: _pickFile,
///   onVoice: _startRecording,
///   appBarTitle: 'Claude',
///   appBarSubtitle: 'claude-3-5-sonnet',
///   promptCards: _defaultPrompts,
///   emptyStateWidget: MyEmptyState(),
///   inputHintText: 'Ask anything…',
///   showAvatars: true,
///   enableStreaming: true,
/// )
/// ```
class ChatScreenScaffold extends StatefulWidget {
  // ── Data ──────────────────────────────────────────────────────────────────
  /// The list of messages to display. Can be empty.
  final List<ChatMessage> messages;

  /// Whether the AI is currently generating a response.
  final bool isTyping;

  // ── Callbacks ─────────────────────────────────────────────────────────────
  /// Called when the user sends a message.
  final void Function(String text)? onSend;

  /// Called when the attachment button is tapped.
  final VoidCallback? onAttachment;

  /// Called when the voice button is tapped.
  final VoidCallback? onVoice;

  /// Called when a message bubble is long-pressed.
  final void Function(ChatMessage message)? onMessageLongPress;

  /// Called when a message bubble is tapped.
  final void Function(ChatMessage message)? onMessageTap;

  // ── AppBar ────────────────────────────────────────────────────────────────
  /// Title shown in the AppBar.
  final String? appBarTitle;

  /// Subtitle (e.g. model name) shown below the AppBar title.
  final String? appBarSubtitle;

  /// Leading widget in the AppBar (e.g. back button or logo).
  final Widget? appBarLeading;

  /// List of action widgets in the AppBar.
  final List<Widget>? appBarActions;

  /// Whether to show the built-in AppBar. Set to false if wrapping in Scaffold.
  final bool showAppBar;

  // ── Input ─────────────────────────────────────────────────────────────────
  /// Hint text for the input field.
  final String inputHintText;

  /// External text controller for the input field.
  final TextEditingController? inputController;

  /// Whether the input field is enabled.
  final bool inputEnabled;

  // ── Appearance ────────────────────────────────────────────────────────────
  /// Whether to show avatars on messages.
  final bool showAvatars;

  /// Whether to animate new message entrances.
  final bool animateMessages;

  /// Custom background widget (e.g. gradient, image).
  final Widget? backgroundWidget;

  /// Custom header widget shown above the message list.
  final Widget? header;

  // ── Empty State ───────────────────────────────────────────────────────────
  /// Widget shown when [messages] is empty.
  final Widget? emptyStateWidget;

  /// Prompt cards shown in the empty state.
  final List<PromptCardConfig>? promptCards;

  /// App name shown in the empty state hero.
  final String emptyStateTitle;

  /// Subtitle shown in the empty state hero.
  final String emptyStateSubtitle;

  // ── Streaming ─────────────────────────────────────────────────────────────
  /// Whether the last assistant message should stream in with [StreamingText].
  final bool enableStreaming;

  /// Speed of token streaming.
  final Duration streamingSpeed;

  // ── Scroll ────────────────────────────────────────────────────────────────
  /// Whether to show a "scroll to bottom" FAB when scrolled up.
  final bool showScrollToBottom;

  const ChatScreenScaffold({
    super.key,
    required this.messages,
    this.isTyping = false,
    this.onSend,
    this.onAttachment,
    this.onVoice,
    this.onMessageLongPress,
    this.onMessageTap,
    this.appBarTitle,
    this.appBarSubtitle,
    this.appBarLeading,
    this.appBarActions,
    this.showAppBar = true,
    this.inputHintText = 'Message AI…',
    this.inputController,
    this.inputEnabled = true,
    this.showAvatars = true,
    this.animateMessages = true,
    this.backgroundWidget,
    this.header,
    this.emptyStateWidget,
    this.promptCards,
    this.emptyStateTitle = 'How can I help?',
    this.emptyStateSubtitle = 'Ask me anything,I\'m here to help.',
    this.enableStreaming = false,
    this.streamingSpeed = const Duration(milliseconds: 25),
    this.showScrollToBottom = true,
  });

  @override
  State<ChatScreenScaffold> createState() => _ChatScreenScaffoldState();
}

class _ChatScreenScaffoldState extends State<ChatScreenScaffold> {
  final ScrollController _scroll = ScrollController();
  bool _showScrollFab = false;
  // Tracks which message IDs have already been animated so we don't re-animate
  final Set<String> _animatedIds = {};

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    // Mark existing messages as already animated
    for (final m in widget.messages) {
      _animatedIds.add(m.id);
    }
  }

  @override
  void didUpdateWidget(ChatScreenScaffold old) {
    super.didUpdateWidget(old);
    // Auto-scroll when new messages arrive
    if (widget.messages.length != old.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _onScroll() {
    final atBottom = _scroll.position.pixels >= _scroll.position.maxScrollExtent - 80;
    if (atBottom != !_showScrollFab) {
      setState(() => _showScrollFab = !atBottom);
    }
  }

  void _scrollToBottom() {
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 380),
        curve: AiCurves.smooth,
      );
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AiUiTheme.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom;

    final scaffold = Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: widget.showAppBar ? _buildAppBar(theme) : null,
      body: Stack(
        children: [
          // Background
          if (widget.backgroundWidget != null) Positioned.fill(child: widget.backgroundWidget!),

          // Main column
          Column(
            children: [
              if (widget.header != null) widget.header!,
              Expanded(
                child: widget.messages.isEmpty
                    ? _EmptyState(
                        title: widget.emptyStateTitle,
                        subtitle: widget.emptyStateSubtitle,
                        promptCards: widget.promptCards,
                        onPromptTap: (text) => widget.onSend?.call(text),
                        theme: theme,
                        customWidget: widget.emptyStateWidget,
                      )
                    : _MessageList(
                        messages: widget.messages,
                        isTyping: widget.isTyping,
                        scrollController: _scroll,
                        showAvatars: widget.showAvatars,
                        animateMessages: widget.animateMessages,
                        animatedIds: _animatedIds,
                        enableStreaming: widget.enableStreaming,
                        streamingSpeed: widget.streamingSpeed,
                        onMessageTap: widget.onMessageTap,
                        onMessageLongPress: widget.onMessageLongPress,
                        theme: theme,
                      ),
              ),

              // Input bar
              _InputBar(
                hintText: widget.inputHintText,
                controller: widget.inputController,
                enabled: widget.inputEnabled && !widget.isTyping,
                isLoading: widget.isTyping,
                onSend: widget.onSend,
                onAttachment: widget.onAttachment,
                onVoice: widget.onVoice,
                bottomPadding: bottom == 0 ? 12 : bottom,
                theme: theme,
              ),
            ],
          ),

          // Scroll to bottom FAB
          if (widget.showScrollToBottom && _showScrollFab)
            Positioned(
              right: 16,
              bottom: 90 + bottom,
              child: _ScrollToBottomFab(
                onTap: _scrollToBottom,
                theme: theme,
              ),
            ),
        ],
      ),
    );

    return scaffold;
  }

  PreferredSizeWidget _buildAppBar(AiUiThemeData theme) {
    return AppBar(
      backgroundColor: theme.surfaceColor,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: theme.borderColor,
      leading: widget.appBarLeading,
      titleSpacing: widget.appBarLeading != null ? 0 : null,
      title: widget.appBarTitle != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.appBarTitle!,
                  style: TextStyle(
                    color: theme.messageTextStyle.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                if (widget.appBarSubtitle != null)
                  Text(
                    widget.appBarSubtitle!,
                    style: theme.timestampTextStyle.copyWith(fontSize: 11.5),
                  ),
              ],
            )
          : null,
      actions: widget.appBarActions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: theme.borderColor),
      ),
    );
  }
}

// ─── Message List ─────────────────────────────────────────────────────────────

class _MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final bool isTyping;
  final ScrollController scrollController;
  final bool showAvatars;
  final bool animateMessages;
  final Set<String> animatedIds;
  final bool enableStreaming;
  final Duration streamingSpeed;
  final void Function(ChatMessage)? onMessageTap;
  final void Function(ChatMessage)? onMessageLongPress;
  final AiUiThemeData theme;

  const _MessageList({
    required this.messages,
    required this.isTyping,
    required this.scrollController,
    required this.showAvatars,
    required this.animateMessages,
    required this.animatedIds,
    required this.enableStreaming,
    required this.streamingSpeed,
    required this.onMessageTap,
    required this.onMessageLongPress,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      itemCount: messages.length + (isTyping ? 1 : 0),
      itemBuilder: (_, i) {
        // Typing indicator at the end
        if (i == messages.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TypingIndicator(isVisible: isTyping, showAvatar: showAvatars),
          );
        }

        final msg = messages[i];
        final isNew = !animatedIds.contains(msg.id);
        if (isNew) animatedIds.add(msg.id);

        // Date separator
        final showDate = i == 0 || !_isSameDay(messages[i - 1].timestamp, msg.timestamp);

        return Column(
          children: [
            if (showDate) _DateSeparator(date: msg.timestamp, theme: theme),
            _buildBubble(msg, isNew),
          ],
        );
      },
    );
  }

  Widget _buildBubble(ChatMessage msg, bool isNew) {
    // Streaming: last assistant message with streaming enabled
    if (enableStreaming && msg.isAssistant && !msg.isLoading && msg == messages.last) {
      return _StreamingBubbleWrapper(
        message: msg,
        speed: streamingSpeed,
        showAvatar: showAvatars,
        animate: animateMessages && isNew,
        theme: theme,
        onTap: () => onMessageTap?.call(msg),
        onLongPress: () => onMessageLongPress?.call(msg),
      );
    }

    return ChatBubble(
      message: msg,
      showAvatar: showAvatars,
      animate: animateMessages && isNew,
      animationDelay: Duration.zero,
      onTap: () => onMessageTap?.call(msg),
      onLongPress: () => onMessageLongPress?.call(msg),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─── Streaming Bubble Wrapper ─────────────────────────────────────────────────

class _StreamingBubbleWrapper extends StatelessWidget {
  final ChatMessage message;
  final Duration speed;
  final bool showAvatar;
  final bool animate;
  final AiUiThemeData theme;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _StreamingBubbleWrapper({
    required this.message,
    required this.speed,
    required this.showAvatar,
    required this.animate,
    required this.theme,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    Widget bubble = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showAvatar) ...[
            _SmallAiAvatar(theme: theme),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onTap: onTap,
              onLongPress: onLongPress,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                child: StreamingText(
                  text: message.text,
                  speed: speed,
                  textStyle: theme.messageTextStyle.copyWith(
                    color: theme.assistantBubbleTextColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return animate ? FadeSlideIn(slideOffset: 15, child: bubble) : bubble;
  }
}

class _SmallAiAvatar extends StatelessWidget {
  final AiUiThemeData theme;
  const _SmallAiAvatar({required this.theme});

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

// ─── Date Separator ───────────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  final DateTime date;
  final AiUiThemeData theme;

  const _DateSeparator({required this.date, required this.theme});

  String _label() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = today.difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: theme.borderColor, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _label(),
              style: theme.timestampTextStyle.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(child: Divider(color: theme.borderColor, thickness: 1)),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<PromptCardConfig>? promptCards;
  final void Function(String)? onPromptTap;
  final AiUiThemeData theme;
  final Widget? customWidget;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    this.promptCards,
    this.onPromptTap,
    required this.theme,
    this.customWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (customWidget != null) return customWidget!;

    final cards = promptCards ?? _defaultPrompts;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
        child: Column(
          children: [
            // AI Icon hero
            FadeSlideIn(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [theme.accentColor, theme.accentSecondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.accentColor.withValues(alpha:0.35),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            FadeSlideIn(
              delay: const Duration(milliseconds: 80),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: theme.messageTextStyle.color,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),

            FadeSlideIn(
              delay: const Duration(milliseconds: 140),
              child: Text(
                subtitle,
                style: theme.timestampTextStyle.copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 36),

            // Prompt cards grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.4,
              ),
              itemCount: cards.length,
              itemBuilder: (_, i) {
                final c = cards[i];
                return PromptCard(
                  icon: c.icon,
                  title: c.title,
                  subtitle: c.subtitle,
                  onTap: () => onPromptTap?.call(c.promptText ?? c.title),
                  animationDelay: Duration(milliseconds: 60 + i * 60),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Input Bar ────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool enabled;
  final bool isLoading;
  final void Function(String)? onSend;
  final VoidCallback? onAttachment;
  final VoidCallback? onVoice;
  final double bottomPadding;
  final AiUiThemeData theme;

  const _InputBar({
    required this.hintText,
    this.controller,
    required this.enabled,
    required this.isLoading,
    this.onSend,
    this.onAttachment,
    this.onVoice,
    required this.bottomPadding,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.surfaceColor,
      padding: EdgeInsets.fromLTRB(12, 8, 12, bottomPadding > 0 ? bottomPadding : 12),
      child: GlassInputField(
        controller: controller,
        hintText: hintText,
        isLoading: isLoading,
        enabled: enabled,
        onSend: onSend,
        onAttachment: onAttachment,
        onVoice: onVoice,
        showAttachmentButton: onAttachment != null,
        showVoiceButton: onVoice != null,
      ),
    );
  }
}

// ─── Scroll to Bottom FAB ─────────────────────────────────────────────────────

class _ScrollToBottomFab extends StatelessWidget {
  final VoidCallback onTap;
  final AiUiThemeData theme;

  const _ScrollToBottomFab({required this.onTap, required this.theme});

  @override
  Widget build(BuildContext context) {
    return ScaleIn(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.surfaceColor,
            border: Border.all(color: theme.borderColor),
            boxShadow: theme.cardShadow,
          ),
          child: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: theme.accentColor,
            size: 22,
          ),
        ),
      ),
    );
  }
}

// ─── Prompt Card Config ───────────────────────────────────────────────────────

/// Configuration for a prompt card shown in the empty state.
class PromptCardConfig {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final String? promptText;

  const PromptCardConfig({
    this.icon,
    required this.title,
    this.subtitle,
    this.promptText,
  });
}

/// Default prompt cards shown in the empty state.
const _defaultPrompts = [
  PromptCardConfig(
    icon: Icons.code_rounded,
    title: 'Write code',
    subtitle: 'Generate, debug or explain code',
    promptText: 'Help me write a Flutter widget that...',
  ),
  PromptCardConfig(
    icon: Icons.edit_note_rounded,
    title: 'Draft content',
    subtitle: 'Emails, docs, social posts',
    promptText: 'Help me write a professional email about...',
  ),
  PromptCardConfig(
    icon: Icons.lightbulb_outline_rounded,
    title: 'Brainstorm',
    subtitle: 'Ideas, plans, strategies',
    promptText: 'Give me 10 creative ideas for...',
  ),
  PromptCardConfig(
    icon: Icons.translate_rounded,
    title: 'Translate',
    subtitle: 'Any language, any text',
    promptText: 'Translate the following to Hindi: ',
  ),
];
