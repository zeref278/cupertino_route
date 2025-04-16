library;

import 'package:cupertino_route/src/route/transition_mixin.dart';
import 'package:flutter/cupertino.dart';

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
    this.swipeableBuilder,
    this.physics,
  }) {
    assert(opaque);
  }

  /// Builds the primary contents of the route.
  final WidgetBuilder builder;

  /// Builds the swipeable content of the route.
  final WidgetBuilder? swipeableBuilder;

  @override
  Widget buildContent(BuildContext context) => builder(context);

  @override
  WidgetBuilder? get buildSwipeableContent => swipeableBuilder;

  /// The scroll physics of the route.
  @override
  final ScrollPhysics? physics;

  @override
  final String? title;

  @override
  final bool maintainState;

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';
}
