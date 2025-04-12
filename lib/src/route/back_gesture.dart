import 'dart:math';
import 'dart:ui';

import 'package:cupertino_route/src/constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:cupertino_route/src/route/mono_drag.dart' as mono;
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart';

class BackGestureController<T> {
  /// Creates a controller for an iOS-style back gesture.
  BackGestureController({
    required this.navigator,
    required this.controller,
    required this.getIsActive,
    required this.getIsCurrent,
  }) {
    navigator.didStartUserGesture();
  }

  final AnimationController controller;
  final NavigatorState navigator;
  final ValueGetter<bool> getIsActive;
  final ValueGetter<bool> getIsCurrent;

  /// The drag gesture has changed by [delta]. The total range of the drag
  /// should be 0.0 to 1.0.
  void dragUpdate(double delta) {
    controller.value -= delta;
  }

  /// The drag gesture has ended with a horizontal motion of [velocity] as a
  /// fraction of screen width per second.
  void dragEnd(double velocity) {
    // Fling in the appropriate direction.
    //
    // This curve has been determined through rigorously eyeballing native iOS
    // animations.
    const Curve animationCurve = Curves.fastLinearToSlowEaseIn;
    final bool isCurrent = getIsCurrent();
    final bool animateForward;

    if (!isCurrent) {
      // If the page has already been navigated away from, then the animation
      // direction depends on whether or not it's still in the navigation stack,
      // regardless of velocity or drag position. For example, if a route is
      // being slowly dragged back by just a few pixels, but then a programmatic
      // pop occurs, the route should still be animated off the screen.
      // See https://github.com/flutter/flutter/issues/141268.
      animateForward = getIsActive();
    } else if (velocity.abs() >= kMinFlingVelocity) {
      // If the user releases the page before mid screen with sufficient velocity,
      // or after mid screen, we should animate the page out. Otherwise, the page
      // should be animated back in.
      animateForward = velocity <= 0;
    } else {
      animateForward = controller.value > 0.5;
    }

    if (animateForward) {
      // The closer the panel is to dismissing, the shorter the animation is.
      // We want to cap the animation time, but we want to use a linear curve
      // to determine it.
      final int droppedPageForwardAnimationTime = min(
        lerpDouble(
                kMaxDroppedSwipePageForwardAnimationTime, 0, controller.value)!
            .floor(),
        kMaxPageBackAnimationTime,
      );
      controller.animateTo(1.0,
          duration: Duration(milliseconds: droppedPageForwardAnimationTime),
          curve: animationCurve);
    } else {
      if (isCurrent) {
        // This route is destined to pop at this point. Reuse navigator's pop.
        navigator.pop();
      }

      // The popping may have finished inline if already at the target destination.
      if (controller.isAnimating) {
        // Otherwise, use a custom popping animation duration and curve.
        final int droppedPageBackAnimationTime = lerpDouble(
                0, kMaxDroppedSwipePageForwardAnimationTime, controller.value)!
            .floor();
        controller.animateBack(0.0,
            duration: Duration(milliseconds: droppedPageBackAnimationTime),
            curve: animationCurve);
      }
    }

    if (controller.isAnimating) {
      // Keep the userGestureInProgress in true state so we don't change the
      // curve of the page transition mid-flight since CupertinoPageTransition
      // depends on userGestureInProgress.
      late AnimationStatusListener animationStatusCallback;
      animationStatusCallback = (AnimationStatus status) {
        navigator.didStopUserGesture();
        controller.removeStatusListener(animationStatusCallback);
      };
      controller.addStatusListener(animationStatusCallback);
    } else {
      navigator.didStopUserGesture();
    }
  }
}

class BackGestureDetector<T> extends StatefulWidget {
  const BackGestureDetector({
    super.key,
    required this.enabledCallback,
    required this.onStartPopGesture,
    required this.child,
    this.swipeableBuilder,
  });

  final Widget child;

  final ValueGetter<bool> enabledCallback;

  final ValueGetter<BackGestureController<T>> onStartPopGesture;

  final WidgetBuilder? swipeableBuilder;

  @override
  BackGestureDetectorState<T> createState() => BackGestureDetectorState<T>();
}

enum Edge {
  start,
  middle,
  end;
}

enum SwipeState {
  open,
  close,
}

class BackGestureDetectorState<T> extends State<BackGestureDetector<T>>
    with SingleTickerProviderStateMixin {
  BackGestureController<T>? _backGestureController;

  late mono.HorizontalDragGestureRecognizer _recognizer;

  late final AnimationController? _swipeAnimationController;

  bool _swipeOnce = false;

  @override
  void initState() {
    super.initState();
    if (isSwipeable) {
      _swipeAnimationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(milliseconds: 200),
      );
    } else {
      _swipeAnimationController = null;
    }

    _recognizer = mono.HorizontalDragGestureRecognizer(debugOwner: this)
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..onCancel = _handleDragCancel;
  }

  @override
  void dispose() {
    _recognizer.dispose();

    // If this is disposed during a drag, call navigator.didStopUserGesture.
    if (_backGestureController != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_backGestureController?.navigator.mounted ?? false) {
          _backGestureController?.navigator.didStopUserGesture();
        }
        _backGestureController = null;
      });
    }
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    assert(mounted);
    if (!widget.enabledCallback()) return;
    assert(_backGestureController == null);

    _backGestureController = widget.onStartPopGesture();
  }

  bool get isSwipeable => widget.swipeableBuilder != null;

  Offset _offset = Offset.zero;

  SwipeState _swipeState = SwipeState.close;

  void _handleDragUpdate(DragUpdateDetails details) {
    assert(mounted);
    if (_backGestureController == null) return;
    assert(_backGestureController != null);
    final isHorizontalDrag = details.delta.dx.abs() > details.delta.dy.abs();
    if (!isHorizontalDrag) return;
    final bool isSwiping = isSwipeable &&
        ((details.delta.dx < 0 ||
            (_swipeAnimationController?.value ?? 0) != 0));
    if (isSwiping &&
        _backGestureController!.controller.value == 1 &&
        _offset.dx <= 0) {
      _offset = Offset(_offset.dx + details.delta.dx, 0);
      final value = _offset.dx.abs() / MediaQuery.sizeOf(context).width;
      _swipeOnce = true;

      _swipeAnimationController?.value = value;
    } else {
      _backGestureController!.dragUpdate(
          _convertToLogical(details.primaryDelta! / context.size!.width));
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    assert(mounted);
    if (_backGestureController == null) return;
    assert(_backGestureController != null);
    if (swipeAnimationValue == 0 || !isSwipeable) {
      _backGestureController!.dragEnd(_convertToLogical(
          details.velocity.pixelsPerSecond.dx / context.size!.width));
    } else {
      final velocity = _convertToLogical(
          details.velocity.pixelsPerSecond.dx / context.size!.width);
      if (_swipeState == SwipeState.open) {
        /// Opening
        if (swipeAnimationValue < 0.5 || velocity > 2) {
          _offset = Offset.zero;
          _swipeAnimationController?.animateTo(0);
          _swipeState = SwipeState.close;
        } else {
          _offset = Offset(-MediaQuery.sizeOf(context).width, 0);
          _swipeAnimationController?.animateTo(1);
          _swipeState = SwipeState.open;
        }
      } else {
        /// Closing
        if (swipeAnimationValue > 0.5 || velocity < -2) {
          _offset = Offset(-MediaQuery.sizeOf(context).width, 0);
          _swipeAnimationController?.animateTo(1);
          _swipeState = SwipeState.open;
        } else {
          _offset = Offset.zero;
          _swipeAnimationController?.animateTo(0);
          _swipeState = SwipeState.close;
        }
      }

      _backGestureController!.dragEnd(0);
    }
    _backGestureController = null;
  }

  double get swipeAnimationValue => _swipeAnimationController?.value ?? 0;

  void _handleDragCancel() {
    assert(mounted);
    // This can be called even if start is not called, paired with the "down" event
    // that we don't consider here.
    if (swipeAnimationValue == 0 || !isSwipeable) {
      _backGestureController?.dragEnd(0.0);
    } else {
      if (_swipeState == SwipeState.open) {
        /// Opening
        if (swipeAnimationValue < 0.5) {
          _offset = Offset.zero;
          _swipeAnimationController?.animateTo(0);
          _swipeState = SwipeState.close;
        } else {
          _offset = Offset(-MediaQuery.sizeOf(context).width, 0);
          _swipeAnimationController?.animateTo(1);
          _swipeState = SwipeState.open;
        }
      } else {
        /// Closing
        if (swipeAnimationValue < 0.5) {
          _offset = Offset.zero;
          _swipeAnimationController?.animateTo(0);
          _swipeState = SwipeState.close;
        } else {
          _offset = Offset(-MediaQuery.sizeOf(context).width, 0);
          _swipeAnimationController?.animateTo(1);
          _swipeState = SwipeState.open;
        }
      }

      _backGestureController?.dragEnd(0);
    }
    _backGestureController = null;
  }

  double _convertToLogical(double value) {
    return switch (Directionality.of(context)) {
      TextDirection.rtl => -value,
      TextDirection.ltr => value,
    };
  }

  Set<BuildContext> horizontal = {};

  void updateEdge(BuildContext context, Offset position) {
    final state = (context as StatefulElement).state as ScrollableState;
    if (state.position.axis != Axis.horizontal) return;

    final ro = context.findRenderObject() as RenderBox?;

    if (state.position.maxScrollExtent == 0) {
      return;
    }

    if (state.resolvedPhysics is NeverScrollableScrollPhysics) {
      return;
    }

    if (ro != null) {
      final result = BoxHitTestResult();
      final localPosition = Vector3(position.dx, position.dy, 0) -
          ro.getTransformTo(null).getTranslation();

      final hitted = ro.hitTest(
        result,
        position: Offset(localPosition.x, localPosition.y),
      );

      if (hitted) {
        Edge edge;
        final metrics = state.position;

        var offset = (metrics.pixels - metrics.minScrollExtent) /
            (metrics.maxScrollExtent - metrics.minScrollExtent);

        RouteScrollResolverState? findCustomResolver(
          BuildContext context,
        ) {
          final resolver = context.read<RouteScrollResolverState?>();
          if (resolver == null) return null;
          if (resolver.axis != state.position.axis) {
            return findCustomResolver(resolver.context);
          }

          return resolver;
        }

        offset = findCustomResolver(state.context)?.offset() ?? offset;

        if (offset == 0) {
          edge = Edge.start;
        } else if (offset == 1) {
          edge = Edge.end;
        } else {
          edge = Edge.middle;
        }

        horizontalEdge = edge;
      }
    }
  }

  Edge? horizontalEdge;

  void _handlePointerDown(PointerDownEvent event) {
    if (widget.enabledCallback()) {
      _recognizer.addPointer(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));

    return Stack(
      fit: StackFit.passthrough,
      children: [
        Listener(
          onPointerDown: (event) {
            if (!widget.enabledCallback()) return;
            for (final context in {...horizontal}) {
              if (!context.mounted) horizontal.remove(context);
            }

            int sort(BuildContext a, BuildContext b) {
              final value =
                  (a as Element).depth.compareTo((b as Element).depth);
              return value;
            }

            final horizontalList = horizontal.toList()
              ..sort((a, b) => sort(a, b));

            horizontalEdge = null;

            if (horizontalList.isNotEmpty) {
              updateEdge(horizontalList.last, event.localPosition);
            }
          },
          child: RawGestureDetector(
            gestures: {
              _PanGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<_PanGestureRecognizer>(
                () => _PanGestureRecognizer(
                  () => horizontalEdge,
                  () => null,
                  4,
                  300,
                  widget.enabledCallback,
                ),
                (instance) => instance //
                  ..onStart = _handleDragStart
                  ..onCancel = _handleDragCancel
                  ..onUpdate = _handleDragUpdate
                  ..onEnd = _handleDragEnd,
              ),
            },
            child: NotificationListener<Notification>(
              onNotification: (notification) {
                if (notification is ScrollMetricsNotification &&
                    notification.metrics.axis == Axis.horizontal) {
                  ScrollableState? findTopMostScrollable(BuildContext context) {
                    // Find the nearest ScrollableState ancestor
                    final state =
                        context.findAncestorStateOfType<ScrollableState>();

                    // If no scrollable found, return null
                    if (state == null) return null;

                    // If the found scrollable's axis doesn't match the notification's axis,
                    // keep searching up the tree
                    if (state.position.axis != Axis.horizontal) {
                      return findTopMostScrollable(state.context);
                    }

                    // Return the found scrollable state
                    return state;
                  }

                  var scrollable =
                      findTopMostScrollable(notification.context)?.context;
                  if (scrollable != null) {
                    horizontal.add(scrollable);
                  }
                }
                return false;
              },
              child: _buildChild(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChild() {
    // For devices with notches, the drag area needs to be larger on the side
    // that has the notch.
    final double dragAreaWidth = switch (Directionality.of(context)) {
      TextDirection.rtl => MediaQuery.paddingOf(context).right,
      TextDirection.ltr => MediaQuery.paddingOf(context).left,
    };
    final defaultChild = Stack(
      children: [
        widget.child,
        PositionedDirectional(
          start: 0.0,
          width: max(dragAreaWidth, kBackGestureWidth),
          top: 0.0,
          bottom: 0.0,
          child: Listener(
            onPointerDown: _handlePointerDown,
            behavior: HitTestBehavior.translucent,
          ),
        ),
      ],
    );

    if (widget.swipeableBuilder != null) {
      return Stack(
        children: [
          // Main content that should handle scrolling
          AnimatedBuilder(
            animation: _swipeAnimationController!,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  -(_swipeAnimationController.value) * 100,
                  0,
                ),
                child: IgnorePointer(
                  ignoring: _swipeAnimationController.value != 0,
                  child: child,
                ),
              );
            },
            child: defaultChild,
          ),
          // Swipeable overlay
          AnimatedBuilder(
            animation: _swipeAnimationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  (1 - _swipeAnimationController.value) *
                      MediaQuery.sizeOf(context).width,
                  0,
                ),
                child: !_swipeOnce ? const SizedBox() : child,
              );
            },
            child: widget.swipeableBuilder!(context),
          ),
        ],
      );
    }
    return defaultChild;
  }
}

class _PanGestureRecognizer extends mono.HorizontalDragGestureRecognizer {
  final ValueGetter<Edge?> horizontalEdge;
  final ValueGetter<Edge?> verticalEdge;
  final ValueGetter<bool> enabledCallback;

  final double edgeSlop;
  final double defaultSlop;

  _PanGestureRecognizer(
    this.horizontalEdge,
    this.verticalEdge,
    this.edgeSlop,
    this.defaultSlop,
    this.enabledCallback,
  );

  @override
  bool hasSufficientGlobalDistanceToAccept(
    PointerDeviceKind pointerDeviceKind,
    double? deviceTouchSlop,
  ) {
    if (!enabledCallback()) return false;
    var delta = (finalPosition.global - initialPosition.global);

    var xSlop = switch (horizontalEdge()) {
      Edge.start when delta.dx > 0 => edgeSlop,
      Edge.end when delta.dx < 0 => edgeSlop,
      null => edgeSlop,
      _ => defaultSlop,
    };

    return delta.dx.abs() > xSlop && delta.dy.abs() < 10;
  }
}

class RouteScrollResolver extends StatefulWidget {
  final Widget? child;
  final Axis axis;
  final ValueGetter<double?> offset;

  const RouteScrollResolver({
    super.key,
    required this.axis,
    required this.offset,
    this.child,
  });

  @override
  State<RouteScrollResolver> createState() => RouteScrollResolverState();
}

class RouteScrollResolverState extends State<RouteScrollResolver> {
  ValueGetter<double?> get offset => widget.offset;

  Axis get axis => widget.axis;

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: this,
      child: widget.child ?? const SizedBox(),
    );
  }
}
