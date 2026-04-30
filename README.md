# flutter_ai_ui_kit

[//]: # ([![pub.dev]&#40;https://img.shields.io/pub/v/flutter_ai_ui_kit.svg&#41;]&#40;https://pub.dev/packages/flutter_ai_ui_kit&#41;)

[//]: # ([![License: MIT]&#40;https://img.shields.io/badge/License-MIT-blue.svg&#41;]&#40;LICENSE&#41;)

[//]: # ([![Flutter]&#40;https://img.shields.io/badge/Flutter-3.10%2B-blue&#41;]&#40;https://flutter.dev&#41;)

[//]: # ([![Dart]&#40;https://img.shields.io/badge/Dart-3.0%2B-blue&#41;]&#40;https://dart.dev&#41;)

A **production-ready Flutter UI kit** for building beautiful, animated AI chat interfaces. Drop it into any project and get a polished AI chat experience in minutes — with full theme support, Markdown rendering, streaming text, and more.

---

## ✨ Features

| Widget | Description |
|--------|-------------|
| **ChatBubble** | User & assistant bubbles with Markdown, code blocks, copy action, avatar, timestamp, animated entrance |
| **TypingIndicator** | Smooth bouncing 3-dot loader with optional label and avatar |
| **StreamingText** | Token-by-token typing effect with start/pause/complete controller |
| **VoiceWave** | Animated waveform bars with active/inactive states |
| **PromptCard** | Suggestion card with icon, title, subtitle, hover effect |
| **GlassInputField** | Frosted-glass chat input with send, attach, voice buttons |
| **MessageReactionBar** | Emoji reaction row with animated selection |
| **ChatScreenScaffold** | Complete ready-to-use AI chat screen layout |

**Plus:**
- 🌗 Light & dark themes with a single token system
- 🎞️ Fade-slide, scale-in, pulse, shimmer animations
- 📱 Responsive — Android, iOS, Web, macOS, Windows
- 🧩 Null-safe, lint-friendly, no unnecessary dependencies
- 📝 Full API documentation

---

## 🎬 Demo (GIFs)

💡 Visual demos dramatically increase downloads on pub.dev
![chat-demo-dart](https://raw.githubusercontent.com/bhpy247/flutter_ai_ui_kit/main/assets/gif/dark_mode_chat_ui.gif)
![chat-demo-light](https://raw.githubusercontent.com/bhpy247/flutter_ai_ui_kit/main/assets/gif/light_mode_chat_ui.gif)
![widget-demo-light](https://raw.githubusercontent.com/bhpy247/flutter_ai_ui_kit/main/assets/gif/light_mode_widget_ui.gif)
![widget-demo-dark](https://raw.githubusercontent.com/bhpy247/flutter_ai_ui_kit/main/assets/gif/dark_mode_widget_ui.gif)

---

## 🚀 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_ai_ui_kit: ^0.1.0
```

Then run:

```bash
flutter pub get
```

---

## ⚡ Quick Start

```dart
import 'package:flutter_ai_ui_kit/flutter_ai_ui_kit.dart';

// Wrap your app to inject the theme
AiUiThemeScope(
  data: AiUiThemeData.light(), // or .dark()
  child: MaterialApp(home: MyChatScreen()),
)
```

### Instant full chat screen:

```dart
ChatScreenScaffold(
  messages: _messages,
  isTyping: _isGenerating,
  onSend: (text) => sendMessage(text),
  appBarTitle: 'AI Assistant',
)
```

---

## 📦 Widget Reference

### ChatBubble

```dart
ChatBubble(
  message: ChatMessage.user(
    text: 'Hello! Explain **BLoC** in Flutter.',
    senderName: 'You',
  ),
  showAvatar: true,
  animate: true,
)

ChatBubble(
  message: ChatMessage.assistant(
    text: '**BLoC** is a state management pattern...\n\n```dart\nclass CounterBloc extends Bloc<Event, State> {}\n```',
  ),
  showAvatar: true,
  enableCopy: true,
  onLinkTap: (href) => launchUrl(Uri.parse(href)),
)
```

### TypingIndicator

```dart
TypingIndicator(
  isVisible: _isGenerating,
  label: 'Claude is thinking…',
  dotColor: Colors.indigo,
  showAvatar: true,
)
```

### StreamingText

```dart
final controller = StreamingTextController();

StreamingText(
  text: fullResponseText,
  speed: const Duration(milliseconds: 25),
  controller: controller,
  autoStart: false,
  onComplete: () => print('Done streaming!'),
)

// Control externally:
controller.start();
controller.pause();
controller.complete(); // skip to end
controller.reset();
```

### VoiceWave

```dart
VoiceWave(
  isActive: _isRecording,
  barCount: 28,
  maxBarHeight: 40,
  barGradient: LinearGradient(
    colors: [Colors.indigo, Colors.purple],
  ),
)
```

### PromptCard

```dart
PromptCard(
  icon: Icons.code_rounded,
  title: 'Write a Flutter widget',
  subtitle: 'Clean, production-ready code',
  onTap: () => sendMessage('Write me a Flutter widget that...'),
)

// Horizontal chip row:
PromptChipRow(
  prompts: [
    PromptChipData(label: 'Translate', icon: Icons.translate),
    PromptChipData(label: 'Summarise', icon: Icons.summarize),
  ],
  onSelect: (label) => sendMessage(label),
)
```

### GlassInputField

```dart
GlassInputField(
  hintText: 'Ask me anything…',
  onSend: (text) => handleSend(text),
  onAttachment: () => pickFile(),
  onVoice: () => startRecording(),
  isLoading: _isGenerating,
  showAttachmentButton: true,
  showVoiceButton: true,
)
```

### MessageReactionBar

```dart
MessageReactionBar(
  selectedReactions: _selectedEmojis,
  onReactionToggled: (emoji) {
    setState(() {
      _selectedEmojis.contains(emoji)
          ? _selectedEmojis.remove(emoji)
          : _selectedEmojis.add(emoji);
    });
  },
)

// Compact reaction count display:
ReactionCountRow(
  counts: {'👍': 5, '❤️': 3, '🔥': 1},
  myReactions: {'👍'},
)
```

### ChatScreenScaffold

```dart
ChatScreenScaffold(
  messages: _messages,
  isTyping: _isTyping,
  onSend: _handleSend,
  onAttachment: _pickAttachment,
  onVoice: _startRecording,
  appBarTitle: 'Claude',
  appBarSubtitle: 'claude-3-5-sonnet',
  enableStreaming: true,
  streamingSpeed: Duration(milliseconds: 22),
  showAvatars: true,
  promptCards: [
    PromptCardConfig(
      icon: Icons.code_rounded,
      title: 'Write code',
      subtitle: 'Generate Flutter widgets',
      promptText: 'Help me write a Flutter widget that...',
    ),
  ],
  emptyStateTitle: 'How can I help?',
  emptyStateSubtitle: 'Ask me anything.',
)
```

---

## 🎨 Theming

### Use built-in themes

```dart
AiUiThemeScope(
  data: AiUiThemeData.dark(), // or .light()
  child: child,
)
```

### Customise any token

```dart
AiUiThemeScope(
  data: AiUiThemeData.light().copyWith(
    accentColor: Colors.teal,
    accentSecondary: Colors.cyan,
    accentGradient: LinearGradient(
      colors: [Colors.teal, Colors.cyan],
    ),
    bubbleRadius: 22,
    userBubbleGradient: LinearGradient(
      colors: [Colors.teal, Colors.cyan],
    ),
  ),
  child: child,
)
```

### Access theme inside widgets

```dart
final theme = AiUiTheme.of(context);
// theme.accentColor, theme.backgroundColor, etc.
```

---

## 🎞️ Animations

All animation primitives are exported for use in your own UI:

```dart
// Fade + slide up on mount
FadeSlideIn(
  delay: Duration(milliseconds: 100),
  slideOffset: 20,
  child: MyWidget(),
)

// Scale in from smaller size
ScaleIn(
  fromScale: 0.85,
  curve: AiCurves.snappy,
  child: MyWidget(),
)

// Continuous scale pulse
PulseWidget(
  minScale: 0.97,
  maxScale: 1.03,
  child: MyIcon(),
)

// Shimmer loading placeholder
ShimmerBox(width: 200, height: 16, borderRadius: 8)
```

---

## 📂 Project Structure

```
lib/
├── flutter_ai_ui_kit.dart        ← main export
└── src/
    ├── models/
    │   ├── chat_message.dart     ← ChatMessage, MessageRole, MessageContentType
    │   └── reaction_model.dart   ← ReactionModel, kDefaultReactions
    ├── theme/
    │   └── ai_ui_theme.dart      ← AiUiThemeData, AiUiTheme, AiUiThemeScope
    ├── animations/
    │   └── ai_animations.dart    ← FadeSlideIn, ScaleIn, PulseWidget, ShimmerBox
    ├── utils/
    │   └── chat_utils.dart       ← ChatUtils (timestamps, initials, avatars)
    └── widgets/
        ├── chat_bubble.dart
        ├── typing_indicator.dart
        ├── streaming_text.dart
        ├── voice_wave.dart
        ├── prompt_card.dart
        ├── glass_input_field.dart
        ├── message_reaction_bar.dart
        └── chat_screen_scaffold.dart
```

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/my-widget`
3. Commit changes: `git commit -m 'feat: add MyWidget'`
4. Push to branch: `git push origin feat/my-widget`
5. Open a Pull Request

Please follow existing code style and add doc comments to all public APIs.

---

## 📄 License

MIT License © 2024 — see [LICENSE](LICENSE) for details.