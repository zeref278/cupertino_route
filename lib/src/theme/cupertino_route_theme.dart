import 'package:flutter/material.dart';

const double _kSwipeThreshold = 0.3;

const double _kBackThreshold = 0.3;

const double _kBackGestureWidth = 20.0;

const double _kMinFlingVelocity = 1.0;

/// The theme for a Cupertino route.
class CupertinoRouteTheme extends ThemeExtension<CupertinoRouteTheme> {
  /// Creates a theme for a Cupertino route.
  const CupertinoRouteTheme({
    this.swipeThreshold = _kSwipeThreshold,
    this.backThreshold = _kBackThreshold,
    this.backGestureWidth = _kBackGestureWidth,
    this.minFlingVelocity = _kMinFlingVelocity,
    this.swipeParallaxScale = 1 / 3,
  });

  /// The threshold for the swipe/back gesture.
  final double swipeThreshold;

  final double backThreshold;

  /// The width of the back gesture.
  final double backGestureWidth;

  /// The minimum fling velocity for the swipe/back gesture.
  final double minFlingVelocity;

  /// The parallax scale for the swipe gesture.
  final double swipeParallaxScale;

  /// Returns the theme for a Cupertino route.
  static CupertinoRouteTheme of(BuildContext context) {
    return Theme.of(context).extension<CupertinoRouteTheme>() ??
        const CupertinoRouteTheme();
  }

  /// Returns a copy of the theme with the given values.
  @override
  ThemeExtension<CupertinoRouteTheme> copyWith() {
    return this;
  }

  /// Linearly interpolates between two themes.
  @override
  ThemeExtension<CupertinoRouteTheme> lerp(
    covariant ThemeExtension<CupertinoRouteTheme>? other,
    double t,
  ) {
    return other ?? this;
  }
}
