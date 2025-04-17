import 'dart:async';

import 'package:cupertino_route/src/route/back_gesture.dart';
import 'package:event_bus/event_bus.dart';

class CupertinoRouteEventBus {
  static final EventBus _eventBus = EventBus();

  static void emit(CupertinoRouteEvent event) {
    _eventBus.fire(event);
  }

  static Stream<T> on<T extends CupertinoRouteEvent>() => _eventBus.on<T>();
}

abstract class CupertinoRouteEvent {
  const CupertinoRouteEvent();
}

class SwipeStateChangedEvent extends CupertinoRouteEvent {
  const SwipeStateChangedEvent({
    required this.swipeState,
    required this.routeHashCode,
  });

  final SwipeState swipeState;
  final int routeHashCode;
}

class ChangeSwipeStateEvent extends CupertinoRouteEvent {
  const ChangeSwipeStateEvent({
    required this.routeHashCode,
    required this.open,
  });

  final int routeHashCode;
  final bool open;
}

extension SwipeStateExtension on SwipeState {
  bool get isOpen => this == SwipeState.open;
  bool get isClose => this == SwipeState.close;
}
