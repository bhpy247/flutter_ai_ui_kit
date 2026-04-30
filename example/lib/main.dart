import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_ai_ui_kit/flutter_ai_ui_kit.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    return AiUiThemeScope(
      data: _isDark ? AiUiThemeData.dark() : AiUiThemeData.light(),
      child: MaterialApp(
        title: 'flutter_ai_ui_kit Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          colorSchemeSeed: const Color(0xFF6366F1),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorSchemeSeed: const Color(0xFF6366F1),
          useMaterial3: true,
        ),
        themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
        home: _HomeScreen(isDark: _isDark, onToggleTheme: () => setState(() => _isDark = !_isDark)),
      ),
    );
  }
}

// ─── Home / Navigation ────────────────────────────────────────────────────────

class _HomeScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const _HomeScreen({required this.isDark, required this.onToggleTheme});

  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = AiUiTheme.of(context);
    final screens = [const _ChatDemoScreen(), const _WidgetShowcaseScreen()];

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.surfaceColor,
          border: Border(top: BorderSide(color: theme.borderColor)),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.chat_bubble_outline_rounded,
                activeIcon: Icons.chat_bubble_rounded,
                label: 'Chat',
                isActive: _selectedIndex == 0,
                onTap: () => setState(() => _selectedIndex = 0),
                theme: theme,
              ),
              _NavItem(
                icon: Icons.widgets_outlined,
                activeIcon: Icons.widgets_rounded,
                label: 'Widgets',
                isActive: _selectedIndex == 1,
                onTap: () => setState(() => _selectedIndex = 1),
                theme: theme,
              ),
              // Theme toggle
              GestureDetector(
                onTap: widget.onToggleTheme,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: theme.inputHintColor,
                        size: 22,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.isDark ? 'Light' : 'Dark',
                        style: theme.timestampTextStyle.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final AiUiThemeData theme;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? theme.accentColor : theme.inputHintColor,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.timestampTextStyle.copyWith(
                fontSize: 11,
                color: isActive ? theme.accentColor : theme.inputHintColor,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab 1: Full Chat Demo ────────────────────────────────────────────────────

class _ChatDemoScreen extends StatefulWidget {
  const _ChatDemoScreen();

  @override
  State<_ChatDemoScreen> createState() => _ChatDemoScreenState();
}

class _ChatDemoScreenState extends State<_ChatDemoScreen> {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  final _rng = Random();

  static const _demoReplies = [
    "Sure! Here's a simple **Flutter StatefulWidget** example:\n\n```dart\nclass Counter extends StatefulWidget {\n  @override\n  State<Counter> createState() => _CounterState();\n}\n\nclass _CounterState extends State<Counter> {\n  int count = 0;\n  @override\n  Widget build(BuildContext context) {\n    return Text('\$count');\n  }\n}\n```\n\nThis creates a counter that holds state internally.",
    "Great question! **BLoC** (Business Logic Component) is a state management pattern in Flutter that:\n\n- Separates UI from business logic\n- Uses `Stream`s for reactive data flow\n- Makes your app **testable** and **scalable**\n\nThe core idea is: *events go in, states come out*.",
    "Here are 5 ways to optimise Flutter performance:\n\n1. Use `const` constructors wherever possible\n2. Avoid rebuilding large widget trees,use `RepaintBoundary`\n3. Leverage `ListView.builder` for long lists\n4. Profile with **Flutter DevTools**\n5. Use `isolate`s for heavy computation",
    "Absolutely! Here's a quick **Dart async** cheat sheet:\n\n```dart\n// Future,single async value\nFuture<String> fetchData() async {\n  await Future.delayed(Duration(seconds: 1));\n  return 'Hello!';\n}\n\n// Stream,multiple async values\nStream<int> countdown() async* {\n  for (int i = 5; i >= 0; i--) {\n    await Future.delayed(Duration(seconds: 1));\n    yield i;\n  }\n}\n```",
    "The **pub.dev score** is based on:\n\n| Criterion | Max Points |\n|-----------|------------|\n| Follow Dart conventions | 30 |\n| Provide documentation | 20 |\n| Platform support | 20 |\n| Pass static analysis | 30 |\n\nAim for **140/160** to get the pub points badge! 🏆",
  ];

  @override
  void initState() {
    super.initState();
    // Add a welcome message
    _messages.add(
      ChatMessage.assistant(
        text:
            "👋 Welcome to **flutter_ai_ui_kit**! I'm your AI demo assistant.\n\nTry sending a message below,I'll respond with a realistic AI reply demonstrating markdown, code blocks, and streaming!",
      ),
    );
  }

  Future<void> _handleSend(String text) async {
    setState(() {
      _messages.add(ChatMessage.user(text: text));
      _isTyping = true;
    });

    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 800 + _rng.nextInt(800)));

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add(
        ChatMessage.assistant(
          text: _demoReplies[_rng.nextInt(_demoReplies.length)],
          contentType: MessageContentType.streaming,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChatScreenScaffold(
      messages: _messages,
      isTyping: _isTyping,
      onSend: _handleSend,
      onAttachment: () => _showSnack('📎 Attachment tapped'),
      onVoice: () => _showSnack('🎤 Voice tapped'),
      onMessageLongPress: (msg) =>
          _showSnack('📋 Copied: ${msg.text.substring(0, min(30, msg.text.length))}…'),
      appBarTitle: 'AI Assistant',
      appBarSubtitle: 'flutter_ai_ui_kit demo',
      appBarLeading: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AiUiTheme.of(context).accentColor, AiUiTheme.of(context).accentSecondary],
            ),
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
        ),
      ),
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showSnack('Options tapped'),
        ),
      ],
      enableStreaming: true,
      animateMessages: true,
      streamingSpeed: const Duration(milliseconds: 22),
      emptyStateTitle: 'How can I help?',
      emptyStateSubtitle: 'Ask me about Flutter, Dart, or anything!',
      promptCards: const [
        PromptCardConfig(
          icon: Icons.code_rounded,
          title: 'Explain BLoC',
          subtitle: 'State management pattern',
          promptText: 'Explain the BLoC pattern in Flutter',
        ),
        PromptCardConfig(
          icon: Icons.speed_rounded,
          title: 'Optimise Flutter',
          subtitle: 'Performance tips',
          promptText: 'How do I optimise Flutter app performance?',
        ),
        PromptCardConfig(
          icon: Icons.bolt_rounded,
          title: 'Async/Await',
          subtitle: 'Dart concurrency',
          promptText: 'Show me how async/await works in Dart',
        ),
        PromptCardConfig(
          icon: Icons.star_outline_rounded,
          title: 'pub.dev Score',
          subtitle: 'Package publishing tips',
          promptText: 'How do I get a high pub.dev score?',
        ),
      ],
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }
}

// ─── Tab 2: Widget Showcase ───────────────────────────────────────────────────

class _WidgetShowcaseScreen extends StatefulWidget {
  const _WidgetShowcaseScreen();

  @override
  State<_WidgetShowcaseScreen> createState() => _WidgetShowcaseScreenState();
}

class _WidgetShowcaseScreenState extends State<_WidgetShowcaseScreen> {
  bool _voiceActive = false;
  bool _typingVisible = true;
  Set<String> _selectedReactions = {};
  final _streamCtrl = StreamingTextController();
  bool _streamStarted = false;

  static const _streamSample =
      "This is a **streaming text** demo with *markdown support*, `inline code`, and even:\n\n```dart\nvoid main() => print('Hello, flutter_ai_ui_kit!');\n```\n\nIsn't it smooth? ✨";

  @override
  Widget build(BuildContext context) {
    final theme = AiUiTheme.of(context);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.surfaceColor,
        elevation: 0,
        title: Text(
          'Widget Showcase',
          style: TextStyle(
            color: theme.messageTextStyle.color,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: theme.borderColor),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── ChatBubble ──────────────────────────────────────────────────
          _SectionHeader('ChatBubble', theme),
          const SizedBox(height: 8),
          ChatBubble(
            message: ChatMessage.user(text: 'Hey! Can you show me some code?'),
            showAvatar: true,
          ),
          const SizedBox(height: 4),
          ChatBubble(
            message: ChatMessage.assistant(
              text:
                  'Sure! Here\'s a **Dart** hello world:\n\n```dart\nvoid main() {\n  print(\'Hello, World!\');\n}\n```\n\nSimple and elegant!',
            ),
            showAvatar: true,
          ),
          const SizedBox(height: 4),
          ChatBubble(message: ChatMessage.loading(), showAvatar: true),

          // ── TypingIndicator ─────────────────────────────────────────────
          const SizedBox(height: 28),
          _SectionHeader('TypingIndicator', theme),
          const SizedBox(height: 8),
          Row(
            children: [
              TypingIndicator(
                isVisible: _typingVisible,
                label: 'Claude is thinking…',
                showAvatar: true,
              ),
              const Spacer(),
              Switch(
                value: _typingVisible,
                onChanged: (v) => setState(() => _typingVisible = v),
                activeColor: theme.accentColor,
              ),
            ],
          ),

          // ── StreamingText ───────────────────────────────────────────────
          const SizedBox(height: 28),
          _SectionHeader('StreamingText', theme),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.assistantBubbleColor,
              borderRadius: BorderRadius.circular(theme.cardRadius),
              boxShadow: theme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamingText(
                  key: ValueKey(_streamStarted),
                  text: _streamSample,
                  speed: const Duration(milliseconds: 25),
                  controller: _streamCtrl,
                  autoStart: _streamStarted,
                  onComplete: () => setState(() {}),
                  textStyle: theme.messageTextStyle.copyWith(color: theme.assistantBubbleTextColor),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _SmallButton(
                      label: 'Start',
                      onTap: () => setState(() {
                        _streamStarted = true;
                        _streamCtrl.start();
                      }),
                      theme: theme,
                    ),
                    const SizedBox(width: 8),
                    _SmallButton(
                      label: 'Reset',
                      onTap: () => setState(() {
                        _streamStarted = false;
                      }),
                      theme: theme,
                    ),
                    const SizedBox(width: 8),
                    _SmallButton(
                      label: 'Complete',
                      onTap: () => _streamCtrl.complete(),
                      theme: theme,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── VoiceWave ───────────────────────────────────────────────────
          const SizedBox(height: 28),
          _SectionHeader('VoiceWave', theme),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.surfaceColor,
              borderRadius: BorderRadius.circular(theme.cardRadius),
              boxShadow: theme.cardShadow,
            ),
            child: Column(
              children: [
                VoiceWave(
                  isActive: _voiceActive,
                  barCount: 30,
                  maxBarHeight: 40,
                  barGradient: LinearGradient(colors: [theme.accentColor, theme.accentSecondary]),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => setState(() => _voiceActive = !_voiceActive),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: _voiceActive
                          ? LinearGradient(colors: [Colors.red.shade400, Colors.red.shade600])
                          : theme.accentGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: (_voiceActive ? Colors.red : theme.accentColor).withValues(alpha:0.3),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _voiceActive ? Icons.stop_rounded : Icons.mic_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _voiceActive ? 'Stop Recording' : 'Start Recording',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── PromptCard ──────────────────────────────────────────────────
          const SizedBox(height: 28),
          _SectionHeader('PromptCard', theme),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.4,
            children: const [
              PromptCard(
                icon: Icons.translate_rounded,
                title: 'Translate text',
                subtitle: 'Any language',
              ),
              PromptCard(
                icon: Icons.summarize_rounded,
                title: 'Summarise',
                subtitle: 'TL;DR anything',
              ),
              PromptCard(
                icon: Icons.bug_report_outlined,
                title: 'Debug code',
                subtitle: 'Find & fix bugs',
              ),
              PromptCard(
                icon: Icons.auto_stories_rounded,
                title: 'Write a story',
                subtitle: 'Creative writing',
              ),
            ],
          ),

          // ── PromptChipRow ───────────────────────────────────────────────
          const SizedBox(height: 16),
          PromptChipRow(
            prompts: const [
              PromptChipData(label: 'Make it shorter', icon: Icons.compress),
              PromptChipData(label: 'Add examples', icon: Icons.list_alt),
              PromptChipData(label: 'More formal', icon: Icons.business),
              PromptChipData(label: 'Translate', icon: Icons.translate),
            ],
            padding: EdgeInsets.zero,
          ),

          // ── GlassInputField ─────────────────────────────────────────────
          const SizedBox(height: 28),
          _SectionHeader('GlassInputField', theme),
          const SizedBox(height: 8),
          GlassInputField(
            hintText: 'Type a message…',
            onSend: (t) => _showSnack(context, 'Sent: $t'),
            onAttachment: () => _showSnack(context, 'Attachment!'),
            onVoice: () => _showSnack(context, 'Voice!'),
          ),

          // ── MessageReactionBar ──────────────────────────────────────────
          const SizedBox(height: 28),
          _SectionHeader('MessageReactionBar', theme),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.surfaceColor,
              borderRadius: BorderRadius.circular(theme.cardRadius),
              boxShadow: theme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tap to react:', style: theme.timestampTextStyle),
                const SizedBox(height: 8),
                MessageReactionBar(
                  selectedReactions: _selectedReactions,
                  onReactionToggled: (emoji) {
                    setState(() {
                      if (_selectedReactions.contains(emoji)) {
                        _selectedReactions.remove(emoji);
                      } else {
                        _selectedReactions.add(emoji);
                      }
                    });
                  },
                ),
                if (_selectedReactions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Selected: ${_selectedReactions.join(' ')}',
                    style: theme.messageTextStyle.copyWith(fontSize: 14),
                  ),
                ],
              ],
            ),
          ),

          // ── ReactionCountRow ────────────────────────────────────────────
          const SizedBox(height: 16),
          ReactionCountRow(
            counts: const {'👍': 12, '❤️': 7, '😂': 3, '🔥': 5},
            myReactions: const {'👍'},
          ),

          // ── ShimmerBox ──────────────────────────────────────────────────
          const SizedBox(height: 28),
          _SectionHeader('ShimmerBox (Loading)', theme),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: double.infinity, height: 16, borderRadius: 8),
              const SizedBox(height: 8),
              ShimmerBox(width: 220, height: 16, borderRadius: 8),
              const SizedBox(height: 8),
              ShimmerBox(width: 160, height: 16, borderRadius: 8),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showSnack(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(
      ctx,
    ).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 1)));
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final AiUiThemeData theme;

  const _SectionHeader(this.title, this.theme);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.accentColor, theme.accentSecondary],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: theme.messageTextStyle.color,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final AiUiThemeData theme;

  const _SmallButton({required this.label, required this.onTap, required this.theme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: theme.accentGradient,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
