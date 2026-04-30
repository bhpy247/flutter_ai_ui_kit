import 'dart:async';
import 'package:flutter/material.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/widget/blocks/container/blockquote.dart';
import 'package:markdown_widget/widget/blocks/leaf/code_block.dart';
import 'package:markdown_widget/widget/blocks/leaf/link.dart';
import 'package:markdown_widget/widget/blocks/leaf/paragraph.dart';
import 'package:markdown_widget/widget/inlines/code.dart';
import 'package:markdown_widget/widget/markdown.dart';
import '../theme/ai_ui_theme.dart';

/// A widget that simulates the token-by-token streaming effect of an AI response.
///
/// Accepts a full [text] string and reveals it character-by-character (or
/// token-by-token) at a configurable speed. Supports Markdown rendering and
/// fires lifecycle callbacks.
///
/// ### Basic Usage
/// ```dart
/// StreamingText(
///   text: 'Hello! Here is some **streamed** text.',
///   speed: Duration(milliseconds: 30),
///   onComplete: () => print('Done!'),
/// )
/// ```
///
/// ### Controlled Streaming
/// ```dart
/// final controller = StreamingTextController();
///
/// StreamingText(
///   text: fullText,
///   controller: controller,
///   autoStart: false,
/// )
///
/// // Later:
/// controller.start();
/// controller.pause();
/// controller.complete(); // jumps to end instantly
/// ```
class StreamingText extends StatefulWidget {
  /// The full text to stream (supports Markdown).
  final String text;

  /// Delay between each revealed character/token.
  final Duration speed;

  /// Number of characters to reveal per tick (simulates faster token batches).
  final int charsPerTick;

  /// Whether to render content as Markdown. Defaults to `true`.
  final bool useMarkdown;

  /// Whether to start streaming immediately when mounted. Defaults to `true`.
  final bool autoStart;

  /// External controller for start / pause / stop / complete.
  final StreamingTextController? controller;

  /// Called when streaming starts.
  final VoidCallback? onStart;

  /// Called after each character reveal, with current visible text.
  final void Function(String visibleText)? onTick;

  /// Called when all characters have been revealed.
  final VoidCallback? onComplete;

  /// Text style for plain text mode. Falls back to [AiUiThemeData.messageTextStyle].
  final TextStyle? textStyle;

  /// Color applied to the blinking cursor.
  final Color? cursorColor;

  /// Whether to show a blinking cursor at the end while streaming.
  final bool showCursor;

  /// Called when a Markdown link is tapped.
  final void Function(String href)? onLinkTap;

  const StreamingText({
    super.key,
    required this.text,
    this.speed = const Duration(milliseconds: 28),
    this.charsPerTick = 1,
    this.useMarkdown = true,
    this.autoStart = true,
    this.controller,
    this.onStart,
    this.onTick,
    this.onComplete,
    this.textStyle,
    this.cursorColor,
    this.showCursor = true,
    this.onLinkTap,
  });

  @override
  State<StreamingText> createState() => _StreamingTextState();
}

class _StreamingTextState extends State<StreamingText> with SingleTickerProviderStateMixin {
  String _visible = '';
  bool _isStreaming = false;
  bool _isDone = false;
  Timer? _timer;

  // Cursor blink
  late final AnimationController _cursorCtrl;
  late final Animation<double> _cursorOpacity;

  @override
  void initState() {
    super.initState();
    _cursorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
    _cursorOpacity = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _cursorCtrl, curve: Curves.easeInOut));

    widget.controller?._attach(this);

    if (widget.autoStart) _start();
  }

  @override
  void didUpdateWidget(StreamingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If text changed (e.g. new streaming chunk), reset and restart
    if (widget.text != oldWidget.text && widget.autoStart) {
      _reset();
      _start();
    }
  }

  void _start() {
    if (_isStreaming || _isDone) return;
    _isStreaming = true;
    widget.onStart?.call();

    _timer = Timer.periodic(widget.speed, (_) {
      if (!mounted) {
        _timer?.cancel();
        return;
      }
      final nextLen = (_visible.length + widget.charsPerTick).clamp(0, widget.text.length);
      setState(() => _visible = widget.text.substring(0, nextLen));
      widget.onTick?.call(_visible);

      if (_visible.length >= widget.text.length) {
        _timer?.cancel();
        setState(() {
          _isStreaming = false;
          _isDone = true;
        });
        _cursorCtrl.stop();
        widget.onComplete?.call();
      }
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _isStreaming = false);
  }

  void _resume() {
    if (!_isDone) _start();
  }

  void _complete() {
    _timer?.cancel();
    setState(() {
      _visible = widget.text;
      _isStreaming = false;
      _isDone = true;
    });
    _cursorCtrl.stop();
    widget.onComplete?.call();
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _visible = '';
      _isStreaming = false;
      _isDone = false;
    });
    _cursorCtrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorCtrl.dispose();
    widget.controller?._detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AiUiTheme.of(context);
    final style = widget.textStyle ?? theme.messageTextStyle;
    final cursorColor = widget.cursorColor ?? theme.accentColor;

    return _StreamBody(
      visible: _visible,
      isStreaming: _isStreaming,
      isDone: _isDone,
      useMarkdown: widget.useMarkdown,
      showCursor: widget.showCursor,
      style: style,
      cursorColor: cursorColor,
      cursorOpacity: _cursorOpacity,
      theme: theme,
      onLinkTap: widget.onLinkTap,
    );
  }
}

// ─── Separated build widget for performance ───────────────────────────────────

class _StreamBody extends StatelessWidget {
  final String visible;
  final bool isStreaming;
  final bool isDone;
  final bool useMarkdown;
  final bool showCursor;
  final TextStyle style;
  final Color cursorColor;
  final Animation<double> cursorOpacity;
  final AiUiThemeData theme;
  final void Function(String)? onLinkTap;

  const _StreamBody({
    required this.visible,
    required this.isStreaming,
    required this.isDone,
    required this.useMarkdown,
    required this.showCursor,
    required this.style,
    required this.cursorColor,
    required this.cursorOpacity,
    required this.theme,
    this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    final showCursorNow = showCursor && !isDone;

    if (!useMarkdown) {
      // Plain text with inline cursor
      return AnimatedBuilder(
        animation: cursorOpacity,
        builder: (_, __) {
          return RichText(
            text: TextSpan(
              children: [
                TextSpan(text: visible, style: style),
                if (showCursorNow)
                  TextSpan(
                    text: '▋',
                    style: style.copyWith(
                      color: cursorColor.withOpacity(cursorOpacity.value),
                      fontSize: style.fontSize ?? 15,
                    ),
                  ),
              ],
            ),
          );
        },
      );
    }

    // Markdown mode,cursor appended as inline text
    final displayText = showCursorNow ? '$visible\u200B' : visible;

    return Stack(
      children: [
        MarkdownWidget(
          data: displayText ?? '',
          selectable: true,
          config: MarkdownConfig(
            configs: [
              // Paragraph
              PConfig(
                textStyle: style,
                // textColor: style.color,
                // margin: const EdgeInsets.only(bottom: 8),
              ),

              // Inline code
              CodeConfig(
                style: style,
                // textColor: theme.accentColor,
                // backgroundColor: theme.accentColor.withOpacity(0.1),
                // fontSize: 13,
                // fontFamily: 'monospace',
              ),

              // Code block
              PreConfig(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1F2E),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(12),
              ),

              // Links
              LinkConfig(
                style: style,
                onTap: (url) {
                  if (onLinkTap != null) {
                    onLinkTap!(url);
                  }
                },
              ),
            ],
          ),
        ),
        if (showCursorNow)
          Positioned(
            bottom: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: cursorOpacity,
              builder: (_, __) => Container(
                width: 2,
                height: 18,
                decoration: BoxDecoration(
                  color: cursorColor.withOpacity(cursorOpacity.value),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Controller ───────────────────────────────────────────────────────────────

/// External controller for [StreamingText].
///
/// ```dart
/// final ctrl = StreamingTextController();
///
/// StreamingText(text: text, controller: ctrl, autoStart: false);
///
/// ctrl.start();    // begin streaming
/// ctrl.pause();    // pause
/// ctrl.resume();   // continue
/// ctrl.complete(); // skip to end
/// ctrl.reset();    // restart from beginning
/// ```
class StreamingTextController {
  _StreamingTextState? _state;

  void _attach(_StreamingTextState s) => _state = s;
  void _detach() => _state = null;

  /// Starts streaming from the current position.
  void start() => _state?._start();

  /// Pauses streaming mid-way.
  void pause() => _state?._pause();

  /// Resumes a paused stream.
  void resume() => _state?._resume();

  /// Instantly reveals the full text.
  void complete() => _state?._complete();

  /// Resets to empty and restarts.
  void reset() {
    _state?._reset();
    _state?._start();
  }

  /// Whether the text is currently streaming.
  bool get isStreaming => _state?._isStreaming ?? false;

  /// Whether all text has been revealed.
  bool get isDone => _state?._isDone ?? false;
}
