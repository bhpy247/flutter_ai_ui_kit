import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/ai_ui_theme.dart';

/// An animated voice waveform widget with start / stop states.
///
/// When [isActive] is `true`, the bars animate with a randomised wave pattern
/// that gives a realistic audio-recording feel. When inactive the bars sit at
/// a flat resting height.
///
/// ### Usage
/// ```dart
/// VoiceWave(isActive: _isRecording)
/// ```
///
/// ### Custom styling
/// ```dart
/// VoiceWave(
///   isActive: true,
///   barCount: 28,
///   activeColor: Colors.red,
///   inactiveColor: Colors.grey.shade300,
///   maxBarHeight: 40,
///   barWidth: 3,
///   barSpacing: 3,
/// )
/// ```
class VoiceWave extends StatefulWidget {
  /// Whether the waveform is animating (recording/speaking state).
  final bool isActive;

  /// Number of bars in the waveform.
  final int barCount;

  /// Maximum height a bar can reach when active.
  final double maxBarHeight;

  /// Minimum height of a bar (resting state).
  final double minBarHeight;

  /// Width of each bar.
  final double barWidth;

  /// Gap between bars.
  final double barSpacing;

  /// Color of bars when [isActive] is true.
  /// Defaults to [AiUiThemeData.voiceWaveActiveColor].
  final Color? activeColor;

  /// Color of bars when [isActive] is false.
  /// Defaults to [AiUiThemeData.voiceWaveInactiveColor].
  final Color? inactiveColor;

  /// Gradient applied to active bars (overrides [activeColor] if set).
  final Gradient? barGradient;

  /// Corner radius of each bar.
  final double barRadius;

  /// Speed of the animation,smaller = faster.
  final Duration tickRate;

  /// Total width of the widget. If null, uses [barCount] × ([barWidth] + [barSpacing]).
  final double? width;

  /// Fixed height of the widget. Defaults to [maxBarHeight] + 8.
  final double? height;

  const VoiceWave({
    super.key,
    this.isActive = false,
    this.barCount = 24,
    this.maxBarHeight = 36,
    this.minBarHeight = 4,
    this.barWidth = 3,
    this.barSpacing = 3,
    this.activeColor,
    this.inactiveColor,
    this.barGradient,
    this.barRadius = 4,
    this.tickRate = const Duration(milliseconds: 80),
    this.width,
    this.height,
  });

  @override
  State<VoiceWave> createState() => _VoiceWaveState();
}

class _VoiceWaveState extends State<VoiceWave> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _rng = math.Random();
  List<double> _heights = [];
  // List<double> _targetHeights = [];
  List<double> _phases = [];

  @override
  void initState() {
    super.initState();
    _initBars();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // long,we drive via listener
    );

    _ctrl.addListener(_onTick);

    if (widget.isActive) _ctrl.repeat();
  }

  void _initBars() {
    _heights = List.generate(widget.barCount, (_) => widget.minBarHeight);
    // _targetHeights = List.generate(widget.barCount, (_) => widget.minBarHeight);
    _phases = List.generate(
      widget.barCount,
      (i) => (i / widget.barCount) * 2 * math.pi,
    );
  }

  int _tickCount = 0;

  void _onTick() {
    // Only update at ~tickRate frequency
    final ticksNeeded = (_ctrl.duration!.inMilliseconds / widget.tickRate.inMilliseconds).round();
    final currentTick = (_ctrl.value * ticksNeeded).floor();

    if (currentTick == _tickCount && _ctrl.value < 1.0) return;
    _tickCount = currentTick;

    if (!mounted) return;

    setState(() {
      for (var i = 0; i < widget.barCount; i++) {
        if (widget.isActive) {
          // Wave-phase based height with randomness
          _phases[i] += 0.18;
          final wave = (math.sin(_phases[i]) + 1) / 2; // 0..1
          final noise = _rng.nextDouble() * 0.3;
          final raw = (wave * 0.7 + noise) * (widget.maxBarHeight - widget.minBarHeight) +
              widget.minBarHeight;
          // Smooth toward target
          _heights[i] = _heights[i] + (raw - _heights[i]) * 0.4;
        } else {
          _heights[i] = _heights[i] + (widget.minBarHeight - _heights[i]) * 0.15;
        }
      }
    });
  }

  @override
  void didUpdateWidget(VoiceWave oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _ctrl.repeat();
      } else {
        // Let bars decay naturally via onTick, then stop
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted && !widget.isActive) _ctrl.stop();
        });
      }
    }
    if (widget.barCount != oldWidget.barCount) _initBars();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AiUiTheme.of(context);
    final activeColor = widget.activeColor ?? theme.voiceWaveActiveColor;
    final inactiveColor = widget.inactiveColor ?? theme.voiceWaveInactiveColor;

    final totalWidth =
        widget.width ?? widget.barCount * (widget.barWidth + widget.barSpacing) - widget.barSpacing;
    final totalHeight = widget.height ?? widget.maxBarHeight + 8;

    return SizedBox(
      width: totalWidth,
      height: totalHeight,
      child: CustomPaint(
        painter: _WavePainter(
          heights: _heights,
          barWidth: widget.barWidth,
          barSpacing: widget.barSpacing,
          barRadius: widget.barRadius,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          barGradient: widget.barGradient,
          minBarHeight: widget.minBarHeight,
          maxBarHeight: widget.maxBarHeight,
          isActive: widget.isActive,
        ),
      ),
    );
  }
}

// ─── Custom Painter ───────────────────────────────────────────────────────────

class _WavePainter extends CustomPainter {
  final List<double> heights;
  final double barWidth;
  final double barSpacing;
  final double barRadius;
  final Color activeColor;
  final Color inactiveColor;
  final Gradient? barGradient;
  final double minBarHeight;
  final double maxBarHeight;
  final bool isActive;

  _WavePainter({
    required this.heights,
    required this.barWidth,
    required this.barSpacing,
    required this.barRadius,
    required this.activeColor,
    required this.inactiveColor,
    this.barGradient,
    required this.minBarHeight,
    required this.maxBarHeight,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final centerY = size.height / 2;

    for (var i = 0; i < heights.length; i++) {
      final x = i * (barWidth + barSpacing);
      final h = heights[i].clamp(minBarHeight, maxBarHeight);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, centerY - h / 2, barWidth, h),
        Radius.circular(barRadius),
      );

      if (barGradient != null && isActive) {
        paint.shader = barGradient!.createShader(
          Rect.fromLTWH(x, centerY - maxBarHeight / 2, barWidth, maxBarHeight),
        );
      } else {
        paint.shader = null;
        // Interpolate color based on activity level
        final t = (h - minBarHeight) / (maxBarHeight - minBarHeight);
        paint.color = Color.lerp(inactiveColor, activeColor, t.clamp(0, 1))!;
      }

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) => true;
}
