/// flutter_ai_ui_kit
///
/// A production-ready Flutter UI kit for building beautiful AI chat interfaces.
/// Provides fully animated, themed, and customizable widgets for modern AI applications.
///
/// ## Quick Start
/// ```dart
/// import 'package:flutter_ai_ui_kit/flutter_ai_ui_kit.dart';
///
/// // Use ChatScreenScaffold for a full ready-to-use chat UI
/// ChatScreenScaffold(
///   messages: messages,
///   onSend: (text) => handleSend(text),
/// );
/// ```
library flutter_ai_ui_kit;

// Models
export 'src/models/chat_message.dart';
export 'src/models/reaction_model.dart';

// Theme
export 'src/theme/ai_ui_theme.dart';

// Widgets
export 'src/widgets/chat_bubble.dart';
export 'src/widgets/typing_indicator.dart';
export 'src/widgets/streaming_text.dart';
export 'src/widgets/voice_wave.dart';
export 'src/widgets/prompt_card.dart';
export 'src/widgets/glass_input_field.dart';
export 'src/widgets/message_reaction_bar.dart';
export 'src/widgets/chat_screen_scaffold.dart';

// Animations
export 'src/animations/ai_animations.dart';

// Utils
export 'src/utils/chat_utils.dart';
