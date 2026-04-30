import 'package:flutter/material.dart';
import '../theme/ai_ui_theme.dart';
import '../animations/ai_animations.dart';

/// A modern frosted-glass chat input field with send, attachment, and voice buttons.
///
/// Handles focus state with animated border glow, growing textarea, and
/// responsive layout that adapts to mobile / tablet / web breakpoints.
///
/// ### Basic Usage
/// ```dart
/// GlassInputField(
///   onSend: (text) => handleSend(text),
/// )
/// ```
///
/// ### Full Control
/// ```dart
/// GlassInputField(
///   controller: _textCtrl,
///   hintText: 'Ask me anything...',
///   onSend: _handleSend,
///   onAttachment: _pickFile,
///   onVoice: _startRecording,
///   isLoading: _isGenerating,
///   showAttachmentButton: true,
///   showVoiceButton: true,
/// )
/// ```
class GlassInputField extends StatefulWidget {
  /// External text controller. If null, an internal one is created.
  final TextEditingController? controller;

  /// Placeholder text when the field is empty.
  final String hintText;

  /// Called when the user taps Send or presses Enter (desktop).
  final void Function(String text)? onSend;

  /// Called when the attachment button is tapped.
  final VoidCallback? onAttachment;

  /// Called when the voice/mic button is tapped.
  final VoidCallback? onVoice;

  /// Called every time the text changes.
  final ValueChanged<String>? onChanged;

  /// Whether the send button shows a loading indicator (AI generating).
  final bool isLoading;

  /// Whether to show the attachment button.
  final bool showAttachmentButton;

  /// Whether to show the voice/mic button.
  final bool showVoiceButton;

  /// Maximum number of visible lines before scrolling.
  final int maxLines;

  /// Whether pressing Enter sends the message (true by default on web/desktop).
  /// Shift+Enter always inserts a newline.
  final bool? submitOnEnter;

  /// Border radius of the input container.
  final double? borderRadius;

  /// Custom send icon.
  final IconData sendIcon;

  /// Bottom padding,useful to add safe area on iOS.
  final double bottomPadding;

  /// Whether the field and buttons are enabled.
  final bool enabled;

  const GlassInputField({
    super.key,
    this.controller,
    this.hintText = 'Message AI…',
    this.onSend,
    this.onAttachment,
    this.onVoice,
    this.onChanged,
    this.isLoading = false,
    this.showAttachmentButton = true,
    this.showVoiceButton = true,
    this.maxLines = 6,
    this.submitOnEnter,
    this.borderRadius,
    this.sendIcon = Icons.arrow_upward_rounded,
    this.bottomPadding = 0,
    this.enabled = true,
  });

  @override
  State<GlassInputField> createState() => _GlassInputFieldState();
}

class _GlassInputFieldState extends State<GlassInputField> with SingleTickerProviderStateMixin {
  late final TextEditingController _ctrl;
  late final FocusNode _focus;
  bool _isFocused = false;
  bool _hasText = false;

  late final AnimationController _glowCtrl;
  late final Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();
    _ctrl = widget.controller ?? TextEditingController();
    _focus = FocusNode();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _glowOpacity = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeOut);

    _focus.addListener(_onFocusChange);
    _ctrl.addListener(_onTextChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focus.hasFocus);
    if (_focus.hasFocus) {
      _glowCtrl.forward();
    } else {
      _glowCtrl.reverse();
    }
  }

  void _onTextChange() {
    final has = _ctrl.text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty || widget.isLoading) return;
    widget.onSend?.call(text);
    _ctrl.clear();
    setState(() => _hasText = false);
  }

  @override
  void dispose() {
    if (widget.controller == null) _ctrl.dispose();
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AiUiTheme.of(context);
    final radius = widget.borderRadius ?? theme.inputRadius;
    final isWeb = MediaQuery.of(context).size.width > 800;
    final submitOnEnter = widget.submitOnEnter ?? isWeb;

    return Padding(
      padding: EdgeInsets.only(bottom: widget.bottomPadding),
      child: AnimatedBuilder(
        animation: _glowOpacity,
        builder: (_, child) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              // Glass ambient shadow
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -2),
              ),
              // Focus glow
              BoxShadow(
                color: theme.accentColor.withOpacity(0.18 * _glowOpacity.value),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: theme.inputBackgroundColor,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: _isFocused
                    ? theme.inputFocusBorderColor.withOpacity(0.8)
                    : theme.inputBorderColor,
                width: _isFocused ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // ── Attachment button ─────────────────────────────────────
                if (widget.showAttachmentButton)
                  _InputIconButton(
                    icon: Icons.add_circle_outline_rounded,
                    onTap: widget.enabled ? widget.onAttachment : null,
                    color: theme.inputHintColor,
                    tooltip: 'Attach file',
                  ),

                // ── Text field ────────────────────────────────────────────
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    focusNode: _focus,
                    enabled: widget.enabled,
                    maxLines: widget.maxLines,
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: widget.onChanged,
                    onSubmitted: submitOnEnter ? (_) => _send() : null,
                    style: theme.messageTextStyle,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: theme.messageTextStyle.copyWith(
                        color: theme.inputHintColor,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 14,
                      ),
                      isDense: true,
                    ),
                  ),
                ),

                // ── Voice button ──────────────────────────────────────────
                if (widget.showVoiceButton && !_hasText)
                  _InputIconButton(
                    icon: Icons.mic_none_rounded,
                    onTap: widget.enabled ? widget.onVoice : null,
                    color: theme.inputHintColor,
                    tooltip: 'Voice input',
                  ),

                // ── Send button ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: _SendButton(
                    isLoading: widget.isLoading,
                    hasText: _hasText,
                    theme: theme,
                    onTap: _send,
                    icon: widget.sendIcon,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Send Button ─────────────────────────────────────────────────────────────

class _SendButton extends StatelessWidget {
  final bool isLoading;
  final bool hasText;
  final AiUiThemeData theme;
  final VoidCallback onTap;
  final IconData icon;

  const _SendButton({
    required this.isLoading,
    required this.hasText,
    required this.theme,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final active = hasText || isLoading;

    return GestureDetector(
      onTap: active && !isLoading ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: active ? theme.accentGradient : null,
          color: active ? null : theme.borderColor,
          boxShadow: active
              ? [
                  BoxShadow(
                    color: theme.accentColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : AnimatedScale(
                  scale: active ? 1.0 : 0.75,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    icon,
                    color: active ? Colors.white : theme.inputHintColor,
                    size: 20,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─── Icon Button ─────────────────────────────────────────────────────────────

class _InputIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final String tooltip;

  const _InputIconButton({
    required this.icon,
    this.onTap,
    required this.color,
    required this.tooltip,
  });

  @override
  State<_InputIconButton> createState() => _InputIconButtonState();
}

class _InputIconButtonState extends State<_InputIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedOpacity(
          opacity: _pressed ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            child: Icon(widget.icon, color: widget.color, size: 22),
          ),
        ),
      ),
    );
  }
}
