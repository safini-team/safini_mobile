import 'package:flutter/material.dart';

/// Shadow tokens. CSS `0 Ypx Bpx Spx rgba(...)` maps to
/// `BoxShadow(offset: (0, Y), blurRadius: B, spreadRadius: S)`.
///
/// The design leans on two-layer shadows: a 1px contact shadow that keeps the
/// card edge crisp, plus a wide negative-spread lift that only shows under the
/// card. Both layers matter - dropping the contact layer makes cards float.
class AppShadows {
  const AppShadows._();

  static const Color _ink04 = Color(0x0A0C231C);
  static const Color _ink06 = Color(0x0F0C231C);
  static const Color _ink18 = Color(0x2E0C231C);
  static const Color _ink20 = Color(0x330C231C);
  static const Color _ink24 = Color(0x3D0C231C);
  static const Color _ink30 = Color(0x4D0C231C);
  static const Color _ink35 = Color(0x590C231C);

  /// `0 1px 2px rgba(12,35,28,.04)` - flat card, no lift.
  static const List<BoxShadow> flat = [
    BoxShadow(color: _ink04, offset: Offset(0, 1), blurRadius: 2),
  ];

  /// `0 1px 2px rgba(12,35,28,.06)` - pill button, settings icon button.
  static const List<BoxShadow> hairline = [
    BoxShadow(color: _ink06, offset: Offset(0, 1), blurRadius: 2),
  ];

  /// `0 1px 2px …04, 0 14px 30px -20px …18` - the standard grouped-list card.
  static const List<BoxShadow> card = [
    BoxShadow(color: _ink04, offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(
      color: _ink18,
      offset: Offset(0, 14),
      blurRadius: 30,
      spreadRadius: -20,
    ),
  ];

  /// `0 1px 2px …04, 0 12px 28px -18px …16` - form card on onboarding.
  static const List<BoxShadow> cardSoft = [
    BoxShadow(color: _ink04, offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(
      color: Color(0x290C231C),
      offset: Offset(0, 12),
      blurRadius: 28,
      spreadRadius: -18,
    ),
  ];

  /// `0 1px 2px …04, 0 16px 34px -22px …24` - next-task card, the one the eye
  /// is meant to land on.
  static const List<BoxShadow> cardLifted = [
    BoxShadow(color: _ink04, offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(
      color: _ink24,
      offset: Offset(0, 16),
      blurRadius: 34,
      spreadRadius: -22,
    ),
  ];

  /// `0 1px 2px …04, 0 14px 30px -22px …20` - store tile.
  static const List<BoxShadow> tile = [
    BoxShadow(color: _ink04, offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(
      color: _ink20,
      offset: Offset(0, 14),
      blurRadius: 30,
      spreadRadius: -22,
    ),
  ];

  /// `0 1px 2px …06, 0 10px 22px -16px …30` - coin pill on the kid header.
  static const List<BoxShadow> pill = [
    BoxShadow(color: _ink06, offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(
      color: _ink30,
      offset: Offset(0, 10),
      blurRadius: 22,
      spreadRadius: -16,
    ),
  ];

  /// `0 6px 16px -10px rgba(12,35,28,.4)` - selected kid chip.
  static const List<BoxShadow> chipSelected = [
    BoxShadow(
      color: Color(0x660C231C),
      offset: Offset(0, 6),
      blurRadius: 16,
      spreadRadius: -10,
    ),
  ];

  /// `0 10px 28px -14px rgba(16,59,47,.65)` - primary button shadow.
  static const List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: Color(0xA6103B2F),
      offset: Offset(0, 10),
      blurRadius: 28,
      spreadRadius: -14,
    ),
  ];

  /// `0 12px 28px -14px rgba(16,59,47,.65)` - sheet primary button, hold pill.
  static const List<BoxShadow> primaryGlowLg = [
    BoxShadow(
      color: Color(0xA6103B2F),
      offset: Offset(0, 12),
      blurRadius: 28,
      spreadRadius: -14,
    ),
  ];

  /// `0 14px 30px -12px rgba(16,59,47,.6)` - floating "New task" button.
  static const List<BoxShadow> fabGlow = [
    BoxShadow(
      color: Color(0x99103B2F),
      offset: Offset(0, 14),
      blurRadius: 30,
      spreadRadius: -12,
    ),
  ];

  /// `0 18px 40px -22px rgba(12,35,28,.7)` - deep panel (code, limits).
  static const List<BoxShadow> deep = [
    BoxShadow(
      color: Color(0xB30C231C),
      offset: Offset(0, 18),
      blurRadius: 40,
      spreadRadius: -22,
    ),
  ];

  /// `0 20px 44px -24px rgba(12,35,28,.75)` - kid hero card.
  static const List<BoxShadow> deepHero = [
    BoxShadow(
      color: Color(0xBF0C231C),
      offset: Offset(0, 20),
      blurRadius: 44,
      spreadRadius: -24,
    ),
  ];

  /// `0 -20px 50px -20px rgba(12,35,28,.35)` - bottom sheet.
  static const List<BoxShadow> sheet = [
    BoxShadow(
      color: _ink35,
      offset: Offset(0, -20),
      blurRadius: 50,
      spreadRadius: -20,
    ),
  ];

  /// `0 16px 34px -16px rgba(0,0,0,.5)` - toast.
  static const List<BoxShadow> toast = [
    BoxShadow(
      color: Color(0x80000000),
      offset: Offset(0, 16),
      blurRadius: 34,
      spreadRadius: -16,
    ),
  ];

  /// `0 1px 3px rgba(0,0,0,.2)` - toggle knob.
  static const List<BoxShadow> knob = [
    BoxShadow(color: Color(0x33000000), offset: Offset(0, 1), blurRadius: 3),
  ];

  /// `0 8px 24px -10px rgba(16,59,47,.4)` - app logo on Welcome.
  static const List<BoxShadow> logo = [
    BoxShadow(
      color: Color(0x66103B2F),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -10,
    ),
  ];
}
