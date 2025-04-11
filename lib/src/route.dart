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
  }) {
    assert(opaque);
  }

  /// Builds the primary contents of the route.
  final WidgetBuilder builder;

  @override
  Widget buildContent(BuildContext context) => builder(context);

  @override
  final String? title;

  @override
  final bool maintainState;
  
  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';
}
