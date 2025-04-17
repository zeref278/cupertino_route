import 'package:flutter/cupertino.dart';

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
