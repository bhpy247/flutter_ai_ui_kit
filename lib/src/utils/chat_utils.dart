import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utility functions used by `flutter_ai_ui_kit` widgets.
class ChatUtils {
  ChatUtils._();

  /// Formats a [DateTime] into a human-readable time string.
  ///
  /// - Same day → `"2:34 PM"`
  /// - Yesterday → `"Yesterday"`
  /// - This week → `"Mon"`
  /// - Older → `"Jan 3"`
  static String formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(msgDay).inDays;

    if (diff == 0) return DateFormat.jm().format(dt);
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat.E().format(dt);
    return DateFormat.MMMd().format(dt);
  }

  /// Detects if a string contains Markdown formatting.
  static bool hasMarkdown(String text) {
    final patterns = [
      RegExp(r'\*\*.*?\*\*'), // bold
      RegExp(r'\*.*?\*'), // italic
      RegExp(r'`.*?`'), // inline code
      RegExp(r'```[\s\S]*?```'), // code block
      RegExp(r'^#{1,6}\s', multiLine: true), // headings
      RegExp(r'^\s*[-*+]\s', multiLine: true), // lists
      RegExp(r'\[.*?\]\(.*?\)'), // links
    ];
    return patterns.any((p) => p.hasMatch(text));
  }

  /// Returns initials from a display name (max 2 chars).
  static String initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  /// Builds a simple gradient avatar for a given name.
  static Widget buildInitialsAvatar({
    required String? name,
    double size = 36,
    List<Color>? gradientColors,
  }) {
    final colors = gradientColors ?? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initials(name),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.38,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  /// Generates a consistent color from a string (useful for avatars).
  static Color colorFromString(String input) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF14B8A6),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFFF97316),
      const Color(0xFF3B82F6),
    ];
    int hash = 0;
    for (final c in input.codeUnits) {
      hash = (hash * 31 + c) & 0x7fffffff;
    }
    return colors[hash % colors.length];
  }
}
