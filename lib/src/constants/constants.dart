import 'package:flutter/cupertino.dart';

const double kBackGestureWidth = 20.0;

const double kMinFlingVelocity = 1.0; // Screen widths per second.

// An eyeballed value for the maximum time it takes for a page to animate forward
// if the user releases a page mid swipe.
const int kMaxDroppedSwipePageForwardAnimationTime = 800; // Milliseconds.

// The maximum time for a page to get reset to it's original position if the
// user releases a page mid swipe.
const int kMaxPageBackAnimationTime = 300; // Milliseconds.

/// Barrier color used for a barrier visible during transitions for Cupertino
/// page routes.
///
/// This barrier color is only used for full-screen page routes with
/// `fullscreenDialog: false`.
///
/// By default, `fullscreenDialog` Cupertino route transitions have no
/// `barrierColor`, and [CupertinoDialogRoute]s and [CupertinoModalPopupRoute]s
/// have a `barrierColor` defined by [kCupertinoModalBarrierColor].
///
/// A relatively rigorous eyeball estimation.
const Color kCupertinoPageTransitionBarrierColor = Color(0x18000000);

/// Barrier color for a Cupertino modal barrier.
///
/// Extracted from https://developer.apple.com/design/resources/.
const Color kCupertinoModalBarrierColor = CupertinoDynamicColor.withBrightness(
  color: Color(0x33000000),
  darkColor: Color(0x7A000000),
);

// The duration of the transition used when a modal popup is shown.
const Duration kModalPopupTransitionDuration = Duration(milliseconds: 335);

// Offset from offscreen to the right to fully on screen.
final Animatable<Offset> kRightMiddleTween = Tween<Offset>(
  begin: const Offset(1.0, 0.0),
  end: Offset.zero,
);

// Offset from fully on screen to 1/3 offscreen to the left.
final Animatable<Offset> kMiddleLeftTween = Tween<Offset>(
  begin: Offset.zero,
  end: const Offset(-1.0 / 3.0, 0.0),
);

// Offset from offscreen below to fully on screen.
final Animatable<Offset> kBottomUpTween = Tween<Offset>(
  begin: const Offset(0.0, 1.0),
  end: Offset.zero,
);
