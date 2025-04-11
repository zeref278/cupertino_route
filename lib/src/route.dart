library;

import 'package:cupertino_route/src/transition_mixin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Enum defining allowed drag directions for the route.
enum DragDirection {
  leftToRight,
  rightToLeft,
  topToBottom,
  bottomToTop,
}

/// A Cupertino-style route that supports dragging from anywhere on the screen to navigate back.
class CupertinoRoute<T> extends PageRoute<T> with TransitionMixin<T> {
  /// Creates a page route for use in an iOS designed app with enhanced drag navigation.
  ///
  /// The [builder], [maintainState], and [fullscreenDialog] arguments must not
  /// be null.
  CupertinoRoute({
    required this.builder,
    this.title,
    super.settings,
    this.maintainState = true,
    super.fullscreenDialog,
    super.allowSnapshotting = true,
    super.barrierDismissible = false,
    
    // Drag from anywhere customization
    this.fullScreenDrag = false,
    this.dragSensitivity = 1.0,
    this.backThreshold = 0.3,
    this.dragAxis,
    this.allowedDragDirections = const [DragDirection.leftToRight],
    this.dragAreaWidth,
    this.dragAreaBuilder,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.transitionBuilder,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  }) {
    assert(opaque);
    assert(dragSensitivity > 0.0 && dragSensitivity <= 1.0, 'dragSensitivity must be between 0.0 and 1.0');
    assert(backThreshold > 0.0 && backThreshold <= 1.0, 'backThreshold must be between 0.0 and 1.0');
  }

  /// Builds the primary contents of the route.
  final WidgetBuilder builder;

  /// Whether drag can be initiated from anywhere on the screen, not just edges.
  final bool fullScreenDrag;
  
  /// Controls how sensitive the route is to drag gestures.
  /// Value between 0.0 and 1.0, where 1.0 is most sensitive.
  final double dragSensitivity;
  
  /// The threshold for completing a back navigation when dragging.
  /// Value between 0.0 and 1.0 representing the fraction of screen width.
  final double backThreshold;
  
  /// Constrains dragging to a specific axis.
  final Axis? dragAxis;
  
  /// The specific directions that dragging is allowed.
  final List<DragDirection> allowedDragDirections;
  
  /// Width from the edge of the screen where dragging can be initiated.
  /// If null and fullScreenDrag is false, defaults to 20.0.
  final double? dragAreaWidth;
  
  /// Custom builder for defining the area where drag can be initiated.
  final Rect Function(BuildContext context, Size size)? dragAreaBuilder;
  
  /// Duration for the transition animation.
  final Duration animationDuration;
  
  /// Curve for the transition animation.
  final Curve animationCurve;
  
  /// Custom transition builder for the route.
  final Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)? transitionBuilder;
  
  /// Called when a drag gesture is started.
  final void Function(DragStartDetails details)? onDragStart;
  
  /// Called when a drag gesture is updated.
  final void Function(DragUpdateDetails details)? onDragUpdate;
  
  /// Called when a drag gesture ends.
  final void Function(DragEndDetails details)? onDragEnd;

  @override
  Widget buildContent(BuildContext context) => builder(context);

  @override
  final String? title;

  @override
  final bool maintainState;
  
  @override
  Duration get transitionDuration => animationDuration;

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';
}
