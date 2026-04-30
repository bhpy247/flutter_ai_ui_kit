import 'package:flutter/material.dart';

/// A collection of reusable animated wrappers used internally by
/// `flutter_ai_ui_kit`,also exported for consumers to build consistent
/// transitions in their own UI.

// ─── Custom Curves ────────────────────────────────────────────────────────────

/// Gentle spring-like curve for element entrances.
class AiSpringCurve extends Curve {
  const AiSpringCurve();

  @override
  double transformInternal(double t) {
    return 1 - (1 - t) * (1 - t) * (1 - t);
  }
}

/// Anticipation curve,slight pullback before going forward.
class AiAnticipateCurve extends Curve {
  const AiAnticipateCurve();

  @override
  double transformInternal(double t) {
    const s = 1.70158;
    return t * t * ((s + 1) * t - s);
  }
}

/// Pre-defined curve instances.
class AiCurves {
  AiCurves._();

  static const spring = AiSpringCurve();
  static const anticipate = AiAnticipateCurve();
  static const smooth = Cubic(0.25, 0.46, 0.45, 0.94);
  static const snappy = Cubic(0.175, 0.885, 0.32, 1.275);
  static const decelerate = Cubic(0.0, 0.0, 0.2, 1.0);
  static const standard = Cubic(0.4, 0.0, 0.2, 1.0);
}

// ─── Fade + Slide Up ─────────────────────────────────────────────────────────

/// Animates a child in with a fade + upward slide.
///
/// Perfect for new chat messages appearing.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double slideOffset;
  final Curve curve;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 380),
    this.slideOffset = 20,
    this.curve = AiCurves.smooth,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: widget.curve),
    );
    _slide = Tween<double>(begin: widget.slideOffset, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: widget.curve),
    );

    if (widget.delay == Duration.zero) {
      _ctrl.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: Offset(0, _slide.value),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

// ─── Scale In ────────────────────────────────────────────────────────────────

/// Animates a child in with a scale + fade effect.
class ScaleIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double fromScale;
  final Curve curve;
  final Alignment alignment;

  const ScaleIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 300),
    this.fromScale = 0.85,
    this.curve = AiCurves.snappy,
    this.alignment = Alignment.center,
  });

  @override
  State<ScaleIn> createState() => _ScaleInState();
}

class _ScaleInState extends State<ScaleIn> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween<double>(begin: widget.fromScale, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: widget.curve),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );

    if (widget.delay == Duration.zero) {
      _ctrl.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.scale(
          scale: _scale.value,
          alignment: widget.alignment,
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

// ─── Pulse ───────────────────────────────────────────────────────────────────

/// Continuously pulses (scale up/down) to draw attention.
class PulseWidget extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  final Duration period;

  const PulseWidget({
    super.key,
    required this.child,
    this.minScale = 0.96,
    this.maxScale = 1.04,
    this.period = const Duration(milliseconds: 1000),
  });

  @override
  State<PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<PulseWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.period)..repeat(reverse: true);
    _scale = Tween<double>(begin: widget.minScale, end: widget.maxScale)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}

// ─── Shimmer ─────────────────────────────────────────────────────────────────

/// A shimmer loading effect,use as a placeholder while content loads.
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _anim = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = widget.baseColor ?? (isDark ? const Color(0xFF252840) : const Color(0xFFE5E7EB));
    final highlight =
        widget.highlightColor ?? (isDark ? const Color(0xFF2D3260) : const Color(0xFFF3F4F6));

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value + 1, 0),
            colors: [base, highlight, base],
          ),
        ),
      ),
    );
  }
}
