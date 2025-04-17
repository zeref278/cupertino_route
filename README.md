# Cupertino Route

A Flutter package that enhances navigation with a customizable drag-to-go-back gesture that works from anywhere on the screen, providing a more intuitive and iOS-like navigation experience.

## Features

- 🔙 **Drag from Anywhere**: Navigate back by dragging from anywhere on the screen, not just from the edge
- ➡️ **Drag Right to New Widget**: Swipe right to reveal additional content or widgets
- 🎨 **Beautiful Animations**: Smooth parallax animations for both push and pop transitions
- 📐 **Flexible Integration**: Works with existing navigation systems and state management solutions
- 📱 **Native Feel**: Provides an iOS-like experience on any platform
- 🔄 **Event Bus**: Synchronize swipe states across multiple routes
- 🎨 **Customizable Theme**: Fine-tune animations and gestures with CupertinoRouteTheme

<div align="center">


<a href="https://www.buymeacoffee.com/zeref278" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>


</div>

### Demo!
| Horizontal ListView | Tabbar View | Swipeable |
| ----------- | -------------- | ----------------------- |
| ![gif](https://github.com/zeref278/media_attachments/raw/main/cupertino_route/hor.gif) | ![gif](https://github.com/zeref278/media_attachments/raw/main/cupertino_route/tabbar.gif) | ![gif](https://github.com/zeref278/media_attachments/raw/main/cupertino_route/swipe.gif) |

## Usage

```dart
import 'package:cupertino_route/cupertino_route.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Wrap your route in CupertinoRoute to enable drag-from-anywhere feature
      onGenerateRoute: (settings) {
        return CupertinoRoute(
          settings: settings,
          builder: (context) {
            // Your page content
            return YourPage();
          },
          // Optional: Add swipeable content that appears when dragging right
          swipeableBuilder: (context) => YourSwipeableWidget(),
          // Optional: Enable event bus for swipe state synchronization
          enableEventBus: true,
          // Optional: Customize theme for this route
          theme: CupertinoRouteTheme(
            swipeParallaxScale: 0.3,
            swipeThreshold: 0.5,
            minFlingVelocity: 1.0,
            backGestureWidth: 20.0,
          ),
        );
      },
      home: HomePage(),
    );
  }
}
```

## Features in Detail

### Drag Right to New Widget
The `swipeableBuilder` parameter allows you to define content that appears when users swipe right. This feature is perfect for:
- Side menus
- Additional information panels
- Quick actions
- Contextual content

### Event Bus
The event bus feature allows you to synchronize swipe states across multiple routes:

```dart
// Listen to swipe state changes
CupertinoRouteEventBus.on<SwipeStateChangedEvent>().listen((event) {
  if (event.routeHashCode == yourRouteHashCode) {
    // Handle swipe state change
    if (event.open) {
      // Swipeable content is open
    } else {
      // Swipeable content is closed
    }
  }
});

// Emit to update swipe state
CupertinoRouteEventBus.emit(
  ChangeSwipeStateEvent(
    routeHashCode: yourRouteHashCode,
    open: true,
  ),
);
```

### CupertinoRouteTheme
Customize the behavior and appearance of your routes through ThemeData:

```dart
MaterialApp(
  theme: ThemeData(
    extensions: [
      CupertinoRouteTheme(
        // Scale of parallax effect when swipe
        swipeParallaxScale: 0.3,
        // Threshold for swipe gesture
        swipeThreshold: 0.5,
        // Minimum velocity for fling gesture
        minFlingVelocity: 1.0,
        // Width of back gesture area
        backGestureWidth: 20.0,
      ),
    ],
  ),
  // ... rest of MaterialApp configuration
)
```

You can also access the theme in your widgets:

```dart
final theme = CupertinoRouteTheme.of(context);
// Use theme values
final parallaxScale = theme.swipeParallaxScale;
final threshold = theme.swipeThreshold;
```

### Parallax Animation
Requirements:
- The initial route, current route, and previous route must be either `CupertinoRoute` or `CupertinoPageRoute`
- You must customize the `pageTransitionsTheme` to enable the effect across all platforms

```dart
MaterialApp(
  title: 'Cupertino Route',
  onGenerateRoute: (settings) {
    return CupertinoRoute(
      builder: (context) => YourPage(),
    );
  },
  onGenerateInitialRoutes: (settings) {
    return [
      CupertinoRoute(
        builder: (context) => const MyHomePage(),
      )
    ];
  },
  theme: ThemeData(
    ///...
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        for (final platform in TargetPlatform.values)
          platform: const CupertinoPageTransitionsBuilder(),
      },
    ),
  ),
)
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
